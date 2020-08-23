library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity divebits_config is
	Generic ( DB_RELEASE_HIGH_ACTIVE : boolean := true;
			  DB_DAISY_CHAIN_CRC_CHECK : boolean := false;
			  DB_RELEASE_DELAY_CYCLES: natural range 20 to 259:= 20;
			  -- hidden parametres
			  DB_ADDRESS : natural range 16#000# to 16#000# := 16#000#; -- special config block address
			  DB_TYPE : natural range 1000 to 1000 := 1000; -- special config block type
			  DB_NUM_OF_32K_ROMS: natural range 1 to 8 := 1
			  );			  
	Port  ( -- system ports
			sys_clock_in : in STD_LOGIC;
			sys_release_in : in STD_LOGIC;
			sys_release_out : out STD_LOGIC;
			
			-- DiveBits Master
			db_clock_out : out STD_LOGIC;			
			db_data_out : out STD_LOGIC;
			
			-- DiveBits Slave - for data feedback, optional error checking
			db_clock_in : in STD_LOGIC; -- unused, just for Master-Slave bus compatibility		
			db_data_in : in STD_LOGIC := '0'   -- feedback input
			);
end divebits_config;


architecture RTL of divebits_config is
	
	-- attributes used
	attribute ASYNC_REG : string;
	attribute SHREG_EXTRACT : string;


	-- release/reset/locked input processing, output release
	signal release_in_sync_SR: std_logic_vector(2 downto 0);
		attribute ASYNC_REG of release_in_sync_SR : signal is "TRUE"; -- pack close to avoid metastability
	signal Reset : std_logic;
	
	signal release_count : integer;
	signal release_out_SR: std_logic_vector(3 downto 0);
		attribute SHREG_EXTRACT of release_out_SR : signal is "no"; -- keep as flipflops to ease placement



	-- FSM states
	type DB_CONFIG_STATE_TYPE is (dbcs_reset, dbcs_length_load, dbcs_wait_for_STart, dbcs_send, dbcs_transfer_done, dbcs_wait_for_STop, dbcs_released);
	signal DB_CONFIG_STATE: DB_CONFIG_STATE_TYPE;


	-- size in bits of configuration data length
	constant LENGTH_BITS: integer := 20;
	signal config_data_length: std_logic_vector(LENGTH_BITS-1 downto 0);



	-- token type and conversion functions
	type token_type is (RS, D0, D1, ST);

	function first_token_bit(token: token_type) return std_logic is
	begin
		if (token=D1 or token=ST) then return '1'; else return '0'; end if;
	end function first_token_bit; 
	
	function last_token_bit(token: token_type) return std_logic is
	begin
		if (token=D0 or token=ST) then return '1'; else return '0'; end if;
	end function last_token_bit;
	
	function token(first_bit: std_logic; second_bit: std_logic) return token_type is
		variable bitv:std_logic_vector(1 downto 0);
	begin
		bitv := first_bit & second_bit;
		case (bitv) is
			when "00" => return RS;		
			when "01" => return D0;		
			when "10" => return D1;		
			when others => return ST; --"11"		
		end case;
	end function token; 


	-- config ROM ports	
	signal ROM_address: unsigned(17 downto 0);
	signal ROM_dout: std_logic;
	signal ROM_outputs: std_logic_vector(DB_NUM_OF_32K_ROMS-1 downto 0) := (others => '0');


	-- output data
	signal token_out_strobe: std_logic;
	signal token_out: token_type;
	signal data_out_SR: std_logic_vector(1 downto 0) := (others=>'0'); -- explicitly set out of GLOBAL SET RESET;
		attribute SHREG_EXTRACT of data_out_SR : signal is "no"; -- keep as flipflops to ease placement


	-- incoming feedback data
	signal data_fb_SR: std_logic_vector(5 downto 0);
		attribute SHREG_EXTRACT of data_fb_SR : signal is "no"; -- keep as flipflops to ease placement
	signal token_in_strobe: std_logic;
	signal token_in:token_type;
	
	signal data_in_valid: std_logic;
	signal data_in: std_logic;
	
	--- crc check signals
	signal crc_register: std_logic_vector(32 downto 0) := (others=>'0');
	constant crc_poly: std_logic_vector(32 downto 0) := X"edb88320" & '1';
	signal crc_fill_cnt: unsigned(5 downto 0);
	signal d_data_in_valid: std_logic;


begin
	
	-- handing clock through to DiveBits master port
	db_clock_out <= sys_clock_in;

	-- RELEASE SIGNAL PROCESSING
	
	-- input, making high-active synchronous reset out of release input
	gen_release_high: if (DB_RELEASE_HIGH_ACTIVE) generate
	begin
		release_in_sync_SR <= release_in_sync_SR(1 downto 0) & not sys_release_in;
	end generate gen_release_high;
	
	gen_release_low: if (not DB_RELEASE_HIGH_ACTIVE) generate
	begin
		release_in_sync_SR <= release_in_sync_SR(1 downto 0) & sys_release_in;
	end generate gen_release_low;
	
	Reset <= release_in_sync_SR(2);

	-- release delay count and release shift register
	process(sys_clock_in)
	begin
		if (rising_edge(sys_clock_in)) then
			if (DB_CONFIG_STATE = dbcs_reset) then
				release_count <= DB_RELEASE_DELAY_CYCLES - 4;
			elsif ((DB_CONFIG_STATE = dbcs_transfer_done) and release_count/=0) then
				release_count <= release_count - 1;
			end if;

			release_out_SR(3 downto 1) <= release_out_SR(2 downto 0);
			if (DB_CONFIG_STATE=dbcs_released) then
				release_out_SR(0) <= '1';
			else
				release_out_SR(0) <= '0';
			end if;
		end if;
	end process;	

	-- output release signal
	sys_release_out <= release_out_SR(3) when (DB_RELEASE_HIGH_ACTIVE) else not release_out_SR(3);



	-- STATE MACHINE
	
	FSM: process(sys_clock_in)
	begin
		if (rising_edge(sys_clock_in)) then
			if (Reset='1') then
				DB_CONFIG_STATE <= dbcs_reset;
			else
				case (DB_CONFIG_STATE) is
					when dbcs_reset => -- Output token RS (00)
						if (Reset='0') then
							DB_CONFIG_STATE <= dbcs_length_load;
						end if;
					when dbcs_length_load =>  -- Output token RS (00)
						if (ROM_address = to_unsigned((LENGTH_BITS-1),18) and token_out_strobe='1') then
							 DB_CONFIG_STATE <= dbcs_wait_for_STart;
						end if;
					when dbcs_wait_for_STart =>  -- Output token ST (11)
						if ( (not DB_DAISY_CHAIN_CRC_CHECK and token_out_strobe='1') or
							 (DB_DAISY_CHAIN_CRC_CHECK and token_in_strobe='1' and token_in=ST) ) then
							if (unsigned(config_data_length) /= 0) then
								DB_CONFIG_STATE <= dbcs_send;
							else
								DB_CONFIG_STATE <= dbcs_transfer_done;
							end if;
						end if;	
					when dbcs_send => -- Output tokens D0 (01) and D1(10)
						if (ROM_address = unsigned(config_data_length)-1 and token_out_strobe='1') then
							DB_CONFIG_STATE <= dbcs_wait_for_STop;
						end if;
					when dbcs_wait_for_STop =>  -- Output token ST (11)
						if ( (not DB_DAISY_CHAIN_CRC_CHECK and token_out_strobe='1') or
							 (DB_DAISY_CHAIN_CRC_CHECK and token_in_strobe='1' and token_in=ST) ) then
							DB_CONFIG_STATE <= dbcs_transfer_done;
						end if;	
					when dbcs_transfer_done =>  -- Output token ST (11)
						if (DB_DAISY_CHAIN_CRC_CHECK and (crc_register(32 downto 1)/=X"00000000")) then
							DB_CONFIG_STATE <= dbcs_reset; -- CRC failed, start all over again
						elsif (release_count = 0) then
							DB_CONFIG_STATE <= dbcs_released;
						end if;
					when dbcs_released =>  -- Output token ST (11)
						-- if ERROR_CHECK_FAILED go to dbcs_reset;
				end case;
			end if;
		end if;
	end process FSM;



	-- ROM OPERATION

	-- DO NOT RENAME: used for identification and location retrieval
	divebits_rom32k_gen_magic1701: for R in 0 to DB_NUM_OF_32K_ROMS-1 generate 
		config_rom_R: entity work.divebits_single_ROM_block
			generic map( ROM_ID => R )
			port map(
				clock       => sys_clock_in,
				ROM_address => std_logic_vector(ROM_address(14 downto 0)),
				dout        => ROM_outputs(R)
			);
	end generate divebits_rom32k_gen_magic1701;
	ROM_dout <= ROM_outputs(to_integer(unsigned(ROM_address(17 downto 15))));
	

	-- ROM address
	process(sys_clock_in)
	begin
		if (rising_edge(sys_clock_in)) then
			if (DB_CONFIG_STATE = dbcs_reset) then
				config_data_length <= (others => '0');
			elsif (DB_CONFIG_STATE = dbcs_length_load) then
				if (token_out_strobe='1') then
					config_data_length <= ROM_dout & config_data_length(LENGTH_BITS-1 downto 1);
				end if;
			end if;
		end if;
	end process;

	-- config data length
	process(sys_clock_in)
	begin
		if (rising_edge(sys_clock_in)) then
			if (DB_CONFIG_STATE = dbcs_reset) then
				ROM_address <= (others => '0');
			elsif ((DB_CONFIG_STATE = dbcs_length_load) or (DB_CONFIG_STATE = dbcs_send)) then
				if (token_out_strobe='1') then
					ROM_address <= ROM_address + 1;
				end if;
			end if;
		end if;
	end process;



	-- OUTPUT DATA
	
	-- token assignment
	process(sys_clock_in)
	begin
		if (rising_edge(sys_clock_in)) then
			if (Reset='1') then
				token_out <= RS;
			else
				if (token_out_strobe='1') then
					case (DB_CONFIG_STATE) is
						when dbcs_reset => -- Output token RS (00)
							token_out <= RS;
						when dbcs_length_load =>  -- Output token RS (00)
							token_out <= RS;
						when dbcs_wait_for_STart =>  -- Output token ST (11)
							token_out <= ST;
						when dbcs_send => -- Output tokens D0 (01) and D1(10)
							if (ROM_dout='1') then	token_out <= D1;
							else					token_out <= D0; end if;
						when dbcs_wait_for_STop =>  -- Output token ST (11)
							token_out <= ST;
						when dbcs_transfer_done =>  -- Output token ST (11)
							token_out <= ST;
						when dbcs_released =>  -- Output token ST (11)
							token_out <= ST;
					end case;
				end if;
			end if;
		end if;
	end process;
	
	-- outgoing token strobe
	process(sys_clock_in)
	begin
		if (rising_edge(sys_clock_in)) then
			token_out_strobe <= not token_out_strobe;
			if (Reset='1') then token_out_strobe <= '0'; end if;
		end if;
	end process;

	-- data output shift register
	output_SR:process(sys_clock_in)
	begin
		if (rising_edge(sys_clock_in)) then
			if (token_out_strobe='0') then
				data_out_SR <= data_out_SR(0) & first_token_bit(token_out);
			else	
				data_out_SR <= data_out_SR(0) & last_token_bit(token_out);
			end if;
			if (Reset='1') then data_out_SR <= "00"; end if;
		end if;
	end process output_SR;

	db_data_out <= data_out_SR(1);



	-- INCOMING DATA
	
	-- data feedback shift register
	feedback_SR:process(sys_clock_in)
	begin
		if (rising_edge(sys_clock_in)) then
			data_fb_SR <= data_fb_SR(4 downto 0) & db_data_in;
			if (DB_CONFIG_STATE=dbcs_reset or DB_CONFIG_STATE=dbcs_length_load) then data_fb_SR <= "000000"; end if;
				
			if (token_in_strobe='1') then
				token_in <= token(data_fb_SR(5),data_fb_SR(4)); end if;				
		end if;
	end process feedback_SR;
	
	-- incoming token strobe
	process(sys_clock_in)
	begin
		if (rising_edge(sys_clock_in)) then
			token_in_strobe <= not token_in_strobe;
			if (data_fb_SR(5 downto 2)="0000") then token_in_strobe <= '0'; end if;
			if (DB_CONFIG_STATE=dbcs_reset or DB_CONFIG_STATE=dbcs_length_load) then token_in_strobe <= '0'; end if;
		end if;
	end process;

	-- incoming data/valid
	process(sys_clock_in)
	begin
		if (rising_edge(sys_clock_in)) then
			if (token_in_strobe='1') then
				case (token_in) is
					when RS =>
						data_in_valid <= '0';					
						data_in <= '0';
					when D1 =>
						data_in_valid <= '1';					
						data_in <= '1';
					when D0 =>
						data_in_valid <= '1';					
						data_in <= '0';
					when ST =>
						data_in_valid <= '0';					
						data_in <= '0';
				end case;				
			else
				data_in_valid <= '0';
			end if;
			if (DB_CONFIG_STATE=dbcs_reset or DB_CONFIG_STATE=dbcs_length_load) then
				data_in_valid <= '0';
				data_in <= '0';
			end if;
		end if;
	end process;
	
	
	
	-- CRC

	gen_crc: if (DB_DAISY_CHAIN_CRC_CHECK) generate	
		CRC_SR:process(sys_clock_in)
		begin
			if (rising_edge(sys_clock_in)) then
				if (data_in_valid='1') then
					crc_register <= data_in & crc_register(32 downto 1);
				elsif (d_data_in_valid='1' and crc_fill_cnt=33) then
					if (crc_register(0)='1') then
						crc_register <= crc_register xor crc_poly;
					end if;
				end if;
				if (DB_CONFIG_STATE=dbcs_reset or DB_CONFIG_STATE=dbcs_length_load) then crc_register <= (others=>'0'); end if;
			end if;
		end process CRC_SR;
		
		-- delay data_in_valid
		process(sys_clock_in)
		begin
			if (rising_edge(sys_clock_in)) then
				d_data_in_valid <= data_in_valid;
				if (DB_CONFIG_STATE=dbcs_reset or DB_CONFIG_STATE=dbcs_length_load) then d_data_in_valid <= '0'; end if;
			end if;
		end process;	
	
		-- CRC initial bit counter
		process(sys_clock_in)
		begin
			if (rising_edge(sys_clock_in)) then
				if (crc_fill_cnt/=33 and data_in_valid='1') then
					crc_fill_cnt <= crc_fill_cnt + 1; end if;
				if (DB_CONFIG_STATE=dbcs_reset or DB_CONFIG_STATE=dbcs_length_load) then crc_fill_cnt <= (others=>'0'); end if;
			end if;
		end process;
	end generate gen_crc;

end RTL;

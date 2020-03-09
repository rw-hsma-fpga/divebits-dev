library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity divebits_receiver is
	Generic ( DB_ADDRESS : natural range 16#001# to 16#FFE# := 16#001#;
			  NUM_CHANNELS: positive range 1 to 16 := 1;
			  DAISY_CHAIN: boolean := true
	); -- 0x000 and 0xFFF reserved
	
	Port  ( -- DiveBits Slave 
			db_clock_in : in STD_LOGIC;
			db_data_in : in STD_LOGIC;
			
			-- DiveBits Master - only required for daisy chaining
			db_clock_out : out STD_LOGIC;
			db_data_out : out STD_LOGIC;
			
			-- serial data port - LSB, Lowest Address Word first
			rx_data       : out STD_LOGIC;
			rx_data_valid : out STD_LOGIC_VECTOR(0 to NUM_CHANNELS-1);
			rx_reset      : out STD_LOGIC
			);
end divebits_receiver;


architecture RTL of divebits_receiver is

	-- attributes used
	attribute SHREG_EXTRACT : string;

	-----------------------------------------
	-- token type and conversion functions --
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
	-- end token type ---------------------
	---------------------------------------


	-- incoming data
	signal Reset: std_logic := '1'; -- explicitly set out of GLOBAL SET RESET, then dependent on tokens;

	signal data_in_SR: std_logic_vector(5 downto 0) := (others=>'0'); -- explicitly set out of GLOBAL SET RESET;
		attribute SHREG_EXTRACT of data_in_SR : signal is "no"; -- keep as flipflops to ease placement
	signal token_in_strobe: std_logic;
	signal token_in:token_type := RS; -- explicitly set out of GLOBAL SET RESET;
	signal data_out_SR: std_logic_vector(1 downto 0) := (others=>'0'); -- explicitly set out of GLOBAL SET RESET;
		attribute SHREG_EXTRACT of data_out_SR : signal is "no"; -- keep as flipflops to ease placement
	
	signal rcv_data_valid: std_logic;
	signal rcv_data: std_logic;


	-- FSM states
	type DB_RECEIVE_STATE_TYPE is (dbrs_reset, dbrs_length_rcv, dbrs_address_rcv, dbrs_data_ignore, dbrs_data_rcv, dbrs_done);
	signal DB_RECEIVE_STATE: DB_RECEIVE_STATE_TYPE;



	constant DEST_ADDRESS_BITS: integer := 16;   -- should be 2^x so counter is simple
	constant PAYLOAD_LENGTH_BITS: integer := 16; -- should be 2^x so counter is simple
	
	signal payload_length: std_logic_vector(PAYLOAD_LENGTH_BITS-1 downto 0);
	signal payload_length_count: unsigned(3 downto 0); -- TODO make log2(PAYLOAD_LENGTH_BITS)
	
	signal dest_address: std_logic_vector(DEST_ADDRESS_BITS-1 downto 0);
	signal dest_address_count: unsigned(3 downto 0); -- TODO make log2(DEST_ADDRESS_BITS)
	
	signal address_match : boolean;

	signal payload_count: unsigned(PAYLOAD_LENGTH_BITS-1 downto 0);
	
begin
	
	-- clock feedthrough
	db_clock_out <= db_clock_in;

	-- INCOMING DATA
	
	-- data input shift register, output shift register
	feedback_SR:process(db_clock_in)
	begin
		if (rising_edge(db_clock_in)) then
			data_in_SR <= data_in_SR(4 downto 0) & db_data_in;
				
			if (token_in_strobe='1') then
				token_in <= token(data_in_SR(5),data_in_SR(4)); end if;
				
			data_out_SR <= data_out_SR(0) & data_in_SR(5);			
		end if;
	end process feedback_SR;
	db_data_out <= data_out_SR(1);

	-- make Reset signal (synchronous)
	process(db_clock_in)
	begin
		if (rising_edge(db_clock_in)) then
			if (data_in_SR(5 downto 3)="000") then -- 3 zeroes cannot happen in regular token combinations
				Reset <= '1';
			else
				Reset <= '0';
			end if;
		end if;
	end process;
	
	-- incoming token strobe
	process(db_clock_in)
	begin
		if (rising_edge(db_clock_in)) then
			token_in_strobe <= not token_in_strobe;
			if (Reset='1') then token_in_strobe <= '0'; end if;
		end if;
	end process;	

	-- incoming data/valid
	process(db_clock_in)
	begin
		if (rising_edge(db_clock_in)) then
			if (token_in_strobe='1') then
				case (token_in) is
					when RS =>
						rcv_data_valid <= '0';					
						rcv_data <= '0';
					when D1 =>
						rcv_data_valid <= '1';					
						rcv_data <= '1';
					when D0 =>
						rcv_data_valid <= '1';					
						rcv_data <= '0';
					when ST =>
						rcv_data_valid <= '0';					
						rcv_data <= '0';
				end case;				
			else
				rcv_data_valid <= '0';
			end if;
			if (Reset='1') then
				rcv_data_valid <= '0';
				rcv_data <= '0';
			end if;
		end if;
	end process;



	-- STATE MACHINE
	
	FSM: process(db_clock_in)
	begin
		if (rising_edge(db_clock_in)) then
			if (Reset='1') then
				DB_RECEIVE_STATE <= dbrs_reset;
			else
				case (DB_RECEIVE_STATE) is
					when dbrs_reset =>
						DB_RECEIVE_STATE <= dbrs_address_rcv;
					when dbrs_address_rcv =>
						if ((dest_address_count="1111") and (rcv_data_valid='1')) then -- TODO make flexible max
							DB_RECEIVE_STATE <= dbrs_length_rcv;
						end if;
					when dbrs_length_rcv =>
						if ((payload_length_count="1111") and (rcv_data_valid='1')) then -- TODO make flexible max
							if (address_match) then
								DB_RECEIVE_STATE <= dbrs_data_rcv;
							else
								DB_RECEIVE_STATE <= dbrs_data_ignore;
							end if;
						end if;
					when dbrs_data_rcv =>
						if (payload_count = unsigned(payload_length)) then
							if (token_in = ST) then
								DB_RECEIVE_STATE <= dbrs_done;
							else
								DB_RECEIVE_STATE <= dbrs_address_rcv;
							end if;
						end if;						
					when dbrs_data_ignore =>
						if (payload_count = unsigned(payload_length)) then
							if (token_in = ST) then
								DB_RECEIVE_STATE <= dbrs_done;
							else
								DB_RECEIVE_STATE <= dbrs_address_rcv;
							end if;
						end if;						
					when dbrs_done =>
						DB_RECEIVE_STATE <= dbrs_done;
				end case;
			end if;
		end if;
	end process FSM;


	-- packet_bit counters
	process(db_clock_in)
	begin
		if (rising_edge(db_clock_in)) then
			if (Reset='1') then
				dest_address_count <= (others => '0');
			elsif (rcv_data_valid='1' and DB_RECEIVE_STATE=dbrs_address_rcv) then
				dest_address_count <= dest_address_count + 1;
			end if;

			if (Reset='1') then
				payload_length_count <= (others => '0');
			elsif (rcv_data_valid='1' and DB_RECEIVE_STATE=dbrs_length_rcv) then
				payload_length_count <= payload_length_count + 1;
			end if;

			if (Reset='1' or DB_RECEIVE_STATE=dbrs_address_rcv) then
				payload_count <= (others => '0');
			elsif(rcv_data_valid='1') then
				if (DB_RECEIVE_STATE=dbrs_data_rcv or DB_RECEIVE_STATE=dbrs_data_ignore) then
					payload_count <= payload_count + 1;
				end if;
			end if;
		end if;
	end process;
	

	-- shift registers storing packet length, address
	process(db_clock_in)
	begin
		if (rising_edge(db_clock_in)) then
			if (Reset='1') then
				payload_length <= (others => '0');
				dest_address <= (others => '0');
			elsif (rcv_data_valid='1') then
				if (DB_RECEIVE_STATE=dbrs_length_rcv) then
					payload_length <= rcv_data & payload_length(PAYLOAD_LENGTH_BITS-1 downto 1); -- LSB comes in first
				end if;
				if (DB_RECEIVE_STATE=dbrs_address_rcv) then
					dest_address <= rcv_data & dest_address(DEST_ADDRESS_BITS-1 downto 1); -- LSB comes in first
				end if;
			end if;
		end if;
	end process;
	
	-- only upper 12 bits of 16 used for module identification; lower 4 bits for multiplexing to up to 16 channels
	address_match <= (dest_address(15 downto 4) = std_logic_vector(to_unsigned(DB_ADDRESS,DEST_ADDRESS_BITS-4)));	


	-- payload signal distribution
	-- last 4 address bits enable one of up to 16 channels
	process(db_clock_in)
	begin
		if (rising_edge(db_clock_in)) then
			rx_data  <= rcv_data;
			rx_reset <= Reset;
			for i in 0 to (NUM_CHANNELS-1) loop
				if (to_integer(unsigned(dest_address(3 downto 0))) = i and DB_RECEIVE_STATE=dbrs_data_rcv) then
					rx_data_valid(i) <= rcv_data_valid;
				else
					rx_data_valid(i) <= '0'; 
				end if;
			end loop;
		end if;
	end process;

end RTL;

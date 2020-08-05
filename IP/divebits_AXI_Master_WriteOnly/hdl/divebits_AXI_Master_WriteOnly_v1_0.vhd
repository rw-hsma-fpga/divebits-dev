library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity divebits_AXI4_Master_WriteOnly_v1_0 is
	generic (
			DB_ADDRESS : natural range 16#001# to 16#FFE# := 16#001#;
			DB_TYPE : natural range 2011 to 2011 := 2011; -- must be unique to IP
			
			DB_NUM_CODE_WORDS: natural range 64 to 256 := 64; -- actually only 64,128,256 useful with LUTRAM - do in IP parameter settings
			DB_REPEAT_WAITCYCLES_WIDTH: natural range 3 to 20 := 7; -- re-check after 2^7=128 cycles by default
			DB_REPEAT_AFTER_BUS_ERROR: boolean := true;

			DB_DAISY_CHAIN: boolean := true;

		-- Parameters of Axi Master Bus Interface M00_AXI
		C_M00_AXI_ADDR_WIDTH	: integer range 32 to 32 := 32;
		C_M00_AXI_DATA_WIDTH	: integer range 32 to 32 := 32
	);
	port (
		-- DiveBits Slave 
		db_clock_in : in STD_LOGIC;
		db_data_in : in STD_LOGIC;
		
		-- DiveBits Master - only required for daisy chaining
		db_clock_out : out STD_LOGIC;
		db_data_out : out STD_LOGIC;

		-- Ports of Axi Master Bus Interface M00_AXI
		--m00_axi_init_axi_txn	: in std_logic;
		--m00_axi_error	: out std_logic := '0';
		--m00_axi_txn_done	: out std_logic := '0';
		
		m00_axi_aclk	: in std_logic;
		m00_axi_aresetn	: in std_logic;
		
		m00_axi_awaddr	: out std_logic_vector(C_M00_AXI_ADDR_WIDTH-1 downto 0);
		m00_axi_awprot	: out std_logic_vector(2 downto 0) := "000";
		m00_axi_awvalid	: out std_logic;
		m00_axi_awready	: in std_logic;
		
		m00_axi_wdata	: out std_logic_vector(C_M00_AXI_DATA_WIDTH-1 downto 0);
		m00_axi_wstrb	: out std_logic_vector(C_M00_AXI_DATA_WIDTH/8-1 downto 0) := (others => '1');
		m00_axi_wvalid	: out std_logic;
		m00_axi_wready	: in std_logic;
		
		m00_axi_bresp	: in std_logic_vector(1 downto 0);
		m00_axi_bvalid	: in std_logic;
		m00_axi_bready	: out std_logic;
		
--		m00_axi_araddr	: out std_logic_vector(C_M00_AXI_ADDR_WIDTH-1 downto 0);
--		m00_axi_arprot	: out std_logic_vector(2 downto 0) := "000";
--		m00_axi_arvalid	: out std_logic;
--		m00_axi_arready	: in std_logic;
--		
--		m00_axi_rdata	: in std_logic_vector(C_M00_AXI_DATA_WIDTH-1 downto 0);
--		m00_axi_rresp	: in std_logic_vector(1 downto 0);
--		m00_axi_rvalid	: in std_logic;
--		m00_axi_rready	: out std_logic;
		
		WRITE_ERROR : out std_logic
	);
end divebits_AXI4_Master_WriteOnly_v1_0;

architecture arch_imp of divebits_AXI4_Master_WriteOnly_v1_0 is
	
	function log2ceil (n : integer) return integer is
		variable m, p : integer;
	begin
		m := 0; p := 1;
		for i in 0 to n loop
			if p < n then
				m := m + 1; p := p * 2;
			end if;
		end loop;
		
		return m;
	end function log2ceil;
	
	constant code_addr_width: integer := log2ceil(DB_NUM_CODE_WORDS);

	component divebits_receiver is
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
	end component;

	-- DB CLOCK DOMAIN
	-- receiver signals
	signal rx_data: std_logic;
	signal rx_data_valid: std_logic_vector(0 to 0);
	signal rx_reset: std_logic;
	
	type code_ram_type is array (DB_NUM_CODE_WORDS-1 downto 0) of std_logic_vector(31 downto 0);
	signal CODE_RAM: code_ram_type := (others => (others => '0'));

	signal Data_SR: std_logic_vector(31 downto 0) := (others => '0');
	signal Data_SR_bit_cnt: integer range 0 to 32;
	
	signal code_wr_addr: unsigned(code_addr_width-1 downto 0);
	signal code_wr_en: std_logic;



	-- AXI CLOCK DOMAIN
	signal code_rd_addr: unsigned(code_addr_width-1 downto 0);
	signal code_rd_en: std_logic;	
	signal code_word: std_logic_vector(31 downto 0);
	
	signal fetched_code_word : std_logic_vector(31 downto 0);
	signal opcode : std_logic_vector(1 downto 0);
	constant OPCODE_WRITE_FROM_CODE : std_logic_vector(1 downto 0)   := "00"; -- write next code word
	constant OPCODE_WRITE_FROM_BUFFER : std_logic_vector(1 downto 0) := "01"; -- write what's in data buffer
	
	signal wr_address : std_logic_vector(31 downto 0);
	signal data_buffer : std_logic_vector(31 downto 0);
	
	signal repeat_wait_cnt : unsigned(DB_REPEAT_WAITCYCLES_WIDTH-1 downto 0) := (others => '0');
	
	
	type db_axi_master_state_type is (	ST_idle, ST_fetch, ST_decode,
										ST_wr_addr, ST_wr_data, ST_wr_ack, ST_wr_err,
										ST_repeat_wait,
										ST_done
	);
	signal master_state: db_axi_master_state_type;
	
	
	
begin
	
	-- WRITE SIDE -- DB CLOCK DOMAIN
	
	rcv:component divebits_receiver
		generic map(
			DB_ADDRESS   => DB_ADDRESS,
			NUM_CHANNELS => 1,
			DAISY_CHAIN  => DB_DAISY_CHAIN
		)
		port map(
			db_clock_in   => db_clock_in,
			db_data_in    => db_data_in,
			db_clock_out  => db_clock_out,
			db_data_out   => db_data_out,
			rx_data       => rx_data,
			rx_data_valid => rx_data_valid,
			rx_reset      => rx_reset
		);

	-- Data register
	process(db_clock_in)
	begin
		if (rising_edge(db_clock_in)) then
			if (rx_data_valid(0)='1') then
				Data_SR <= rx_data & Data_SR(31 downto 1);
			end if;
		end if;
	end process;

	process(db_clock_in)
	begin
		if (rising_edge(db_clock_in)) then
			if (rx_reset='1') then
				code_wr_addr <= (others => '0');
			elsif (code_wr_en='1') then
				code_wr_addr <= code_wr_addr + 1; 
			end if;
		end if;
	end process;	

	process(db_clock_in)
	begin
		if (rising_edge(db_clock_in)) then
			if (rx_reset='1') then
				Data_SR_bit_cnt <= 0;
			elsif (code_wr_en='1') then -- wraparound; always in the data_valid "gap"
				Data_SR_bit_cnt <= 0;
			elsif (rx_data_valid(0)='1') then
				Data_SR_bit_cnt <= Data_SR_bit_cnt + 1;
			end if;
		end if;
	end process;

	process(db_clock_in)
	begin
		if (rising_edge(db_clock_in)) then
			if (rx_reset='1') then
				code_wr_en <= '0';
			elsif (rx_data_valid(0)='1' and Data_SR_bit_cnt=31) then
				code_wr_en <= '1';
			else
				code_wr_en <= '0';
			end if;
		end if;
	end process;
	
	process(db_clock_in)
	begin
		if (rising_edge(db_clock_in)) then
			if (code_wr_en='1') then
				CODE_RAM(to_integer(code_wr_addr)) <= Data_SR;
			end if;
		end if;
	end process;
	
	
	
	
	
	
	-- READ SIDE -- AXI CLOCK DOMAIN
	code_word <= CODE_RAM(to_integer(code_rd_addr));
	
	process(m00_axi_aclk)
	begin
		if (rising_edge(m00_axi_aclk)) then
			if (m00_axi_aresetn='0') then
				code_rd_addr <= (others => '0');
			elsif (code_rd_en='1') then
				code_rd_addr <= code_rd_addr + 1; 
			end if;
		end if;
	end process;
	code_rd_en <= '1' when ( (master_state=ST_fetch) or (master_state=ST_decode and opcode=OPCODE_WRITE_FROM_CODE) ) else '0';

	process(m00_axi_aclk)
	begin
		if (rising_edge(m00_axi_aclk)) then
			if (m00_axi_aresetn='0') then
				fetched_code_word <= (others => '0');
			elsif (master_state=ST_fetch) then
				fetched_code_word <= code_word;
			end if;
		end if;
	end process;
	opcode <= fetched_code_word(1 downto 0);
	wr_address(31 downto 2) <= fetched_code_word(31 downto 2);
	wr_address(1 downto 0) <= "00";
	
	process(m00_axi_aclk)
	begin
		if (rising_edge(m00_axi_aclk)) then
			if (m00_axi_aresetn='0') then
				master_state <= ST_idle;
			else
				case master_state is
				 
					when ST_idle =>
						master_state <= ST_fetch;
						
					when ST_fetch =>
						master_state <= ST_decode;
						
					when ST_decode =>
						if ((fetched_code_word=X"00000000") -- write to physical address 0 not possible
							or (opcode(1)/='0')) -- READ operation specified 
						then
							master_state <= ST_done;
						else
							master_state <= ST_wr_addr;
						end if;
						
					when ST_wr_addr =>
						if (m00_axi_awready='1') then
							master_state <= ST_wr_data; end if;
							
					when ST_wr_data =>
						if (m00_axi_wready='1') then
							master_state <= ST_wr_ack; end if;
							
					when ST_wr_ack =>
						if (m00_axi_bvalid='1') then
							if (m00_axi_bresp="00") then
								master_state <= ST_fetch;
							else
								master_state <= ST_wr_err;
							end if;
						end if;
						
					when ST_wr_err =>
						if (DB_REPEAT_AFTER_BUS_ERROR) then
							master_state <= ST_repeat_wait; end if;
						
					when ST_repeat_wait =>
						if (repeat_wait_cnt=0) then
							master_state <= ST_wr_addr; end if;
						
					when ST_done =>
						null;
				end case; 
			end if;
		end if;
	end process;
	WRITE_ERROR <= '1' when (master_state=ST_wr_err) else '0';
	
	-- repeat count
	process(m00_axi_aclk)
	begin
		if (rising_edge(m00_axi_aclk)) then
			if (m00_axi_aresetn='0') then
				repeat_wait_cnt <= (others => '0');
			elsif ((repeat_wait_cnt/=0) or (master_state=ST_wr_err)) then
				repeat_wait_cnt <= repeat_wait_cnt - 1; 
			end if;
		end if;
	end process;
	
	-- AXI BUS SIGNALS
	m00_axi_awaddr(31 downto 0) <= wr_address;
	m00_axi_awvalid <= '1' when (master_state=ST_wr_addr) else '0';
	m00_axi_wvalid <= '1' when (master_state=ST_wr_data) else '0';
	m00_axi_wdata(31 downto 0) <= data_buffer;
	m00_axi_bready <= '1' when (master_state=ST_wr_ack) else '0';
	
	
--	m00_axi_araddr(31 downto 0) <= (others => '0');
--	m00_axi_arvalid <= '0';
--	m00_axi_rready <= '0';

	process(m00_axi_aclk)
	begin
		if (rising_edge(m00_axi_aclk)) then
			if (master_state=ST_decode and opcode=OPCODE_WRITE_FROM_CODE) then
				data_buffer <= code_word; 
			end if;
		end if;
	end process;
	
	
end arch_imp;

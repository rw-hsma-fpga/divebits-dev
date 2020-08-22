library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity divebits_AXIS_Master_v1_0 is
	generic (
			DB_ADDRESS : natural range 16#001# to 16#FFE# := 16#001#;
			DB_TYPE : natural range 2020 to 2020 := 2020; -- must be unique to IP
			
			DB_NUM_DATA_WORDS: natural range 32 to 256 := 64; -- actually only 32,64,128,256 useful with LUTRAM - do in IP parameter settings
			DB_DATA_WIDTH: natural range 32 to 1024 := 32; -- only 32,64,128,256,512,1024 - do in IP parameter settings

			DB_DAISY_CHAIN: boolean := true;

			-- Parameters of Axi Master Bus Interface M00_AXIS
			C_M00_AXIS_TDATA_WIDTH	: integer	:= 32 -- must be locked to DB_DATA_WIDTH in GUI
	);
	port (
		-- DiveBits Slave 
		db_clock_in : in STD_LOGIC;
		db_data_in : in STD_LOGIC;
		
		-- DiveBits Master - only required for daisy chaining
		db_clock_out : out STD_LOGIC;
		db_data_out : out STD_LOGIC;
		

		-- Ports of Axi Master Bus Interface M00_AXIS
		m00_axis_aclk	: in std_logic;
		m00_axis_aresetn	: in std_logic;
		m00_axis_tvalid	: out std_logic;
		m00_axis_tdata	: out std_logic_vector(C_M00_AXIS_TDATA_WIDTH-1 downto 0);
--		m00_axis_tstrb	: out std_logic_vector((C_M00_AXIS_TDATA_WIDTH/8)-1 downto 0);
		m00_axis_tlast	: out std_logic;
		m00_axis_tready	: in std_logic
	);
end divebits_AXIS_Master_v1_0;

architecture arch_imp of divebits_AXIS_Master_v1_0 is

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
	
	constant code_addr_width: integer := log2ceil(DB_NUM_DATA_WORDS);
	
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
	
	type code_ram_type is array (DB_NUM_DATA_WORDS-1 downto 0) of std_logic_vector(C_M00_AXIS_TDATA_WIDTH downto 0);
	signal CODE_RAM: code_ram_type := (others => (others => '0'));

	signal Data_SR: std_logic_vector(C_M00_AXIS_TDATA_WIDTH downto 0) := (others => '0');
	signal Data_SR_bit_cnt: integer range 0 to C_M00_AXIS_TDATA_WIDTH+1;
	
	signal wr_addr: unsigned(code_addr_width-1 downto 0);
	signal wr_en: std_logic;



	-- AXI CLOCK DOMAIN
	signal rd_addr_ceiling: unsigned(code_addr_width downto 0);

	signal rd_addr: unsigned(code_addr_width downto 0);
	signal rd_en: std_logic;	
	

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
				Data_SR <= rx_data & Data_SR(C_M00_AXIS_TDATA_WIDTH downto 1);
			end if;
		end if;
	end process;

	process(db_clock_in)
	begin
		if (rising_edge(db_clock_in)) then
			if (rx_reset='1') then
				wr_addr <= (others => '0');
			elsif (wr_en='1') then
				wr_addr <= wr_addr + 1; 
			end if;
		end if;
	end process;	

	process(db_clock_in)
	begin
		if (rising_edge(db_clock_in)) then
			if (rx_reset='1') then
				Data_SR_bit_cnt <= 0;
			elsif (wr_en='1') then -- wraparound; always in the data_valid "gap"
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
				wr_en <= '0';
			elsif (rx_data_valid(0)='1' and Data_SR_bit_cnt=C_M00_AXIS_TDATA_WIDTH) then
				wr_en <= '1';
			else
				wr_en <= '0';
			end if;
		end if;
	end process;
	
	process(db_clock_in)
	begin
		if (rising_edge(db_clock_in)) then
			if (wr_en='1') then
				CODE_RAM(to_integer(wr_addr)) <= Data_SR;
			end if;
		end if;
	end process;
	
	
	
	
	-- READ SIDE -- AXI CLOCK DOMAIN
	m00_axis_tdata <= CODE_RAM(to_integer(rd_addr))(C_M00_AXIS_TDATA_WIDTH-1 downto 0);
	m00_axis_tlast <= CODE_RAM(to_integer(rd_addr))(C_M00_AXIS_TDATA_WIDTH);
	
	rd_addr_ceiling <= unsigned(Data_SR(C_M00_AXIS_TDATA_WIDTH downto C_M00_AXIS_TDATA_WIDTH-code_addr_width)); -- last shifted, unwritten (<32b) value is ceiling
	m00_axis_tvalid <= '1' when (rd_addr/=rd_addr_ceiling) else '0';
	
	
	process(m00_axis_aclk)
	begin
		if (rising_edge(m00_axis_aclk)) then
			if (m00_axis_aresetn='0') then
				rd_addr <= (others => '0');
			elsif (rd_en='1') then
				rd_addr <= rd_addr + 1; 
			end if;
		end if;
	end process;
	rd_en <= '1' when (m00_axis_tready='1' and (rd_addr/=rd_addr_ceiling)) else '0';

end arch_imp;

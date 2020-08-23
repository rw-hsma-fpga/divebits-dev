library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity divebits_BlockRAM_init is
	Generic ( DB_ADDRESS : natural range 16#001# to 16#FFE# := 16#001#;
	          DB_TYPE : natural range 3000 to 3000 := 3000; -- must be unique to IP

			  DB_BRAM_DATA_WIDTH: natural range 1 to 64 := 32;
			  DB_BRAM_ADDR_WIDTH: natural range 1 to 16 := 10; -- choice somewhat arbitrarily
			  DB_BRAMCTRL_MODE: boolean := false; -- extends address to 32 bit, data width to next power of 2

			  -- computed by block diagram interface
			  FULL_ADDR_WIDTH: natural range 1 to 32 := 32;
			  FULL_DATA_WIDTH: natural range 1 to 64 := 32;
			  FULL_WEN_WIDTH: natural range 1 to 8 := 1;

			  DB_DAISY_CHAIN: boolean := true );
	Port  ( -- DiveBits Slave 
			db_clock_in : in STD_LOGIC;
			db_data_in : in STD_LOGIC;
			
			-- DiveBits Master - only required for daisy chaining
			db_clock_out : out STD_LOGIC;
			db_data_out : out STD_LOGIC;
			--

			-- BRAM interface
			CLK : out STD_LOGIC;
			ADDR : out std_logic_vector(FULL_ADDR_WIDTH-1 downto 0);
			DOUT : out std_logic_vector(FULL_DATA_WIDTH-1 downto 0);
			WEN : out std_logic_vector(FULL_WEN_WIDTH-1 downto 0);
			EN: out std_logic;
			RST: out std_logic
			);
end divebits_BlockRAM_init;


architecture RTL of divebits_BlockRAM_init is
	
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

	-- receiver signals
	signal rx_data: std_logic;
	signal rx_data_valid: std_logic_vector(0 to 0);
	signal rx_reset: std_logic;

	-- rx_reset is for two-dimensional storage where the write address needs to be reset on a second try
	signal Data_SR: std_logic_vector(DB_BRAM_DATA_WIDTH-1 downto 0) := (others => '0');
	signal data_bit_cnt: integer range 0 to DB_BRAM_DATA_WIDTH;
	signal addr_cnt: integer; -- TODO specify required size?
	signal write_en: std_logic;

begin
	
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
				Data_SR <= rx_data & Data_SR(DB_BRAM_DATA_WIDTH-1 downto 1);
			end if;
		end if;
	end process;

	-- BRAM interface
	CLK <= db_clock_in;

	DOUT(DB_BRAM_DATA_WIDTH-1 downto 0) <= Data_SR;
	gen_dout_nofit: if (FULL_DATA_WIDTH/=DB_BRAM_DATA_WIDTH) generate
	begin
		DOUT(FULL_DATA_WIDTH-1 downto DB_BRAM_DATA_WIDTH) <= (others => '1');
	end generate gen_dout_nofit;

	gen_no_bram_ctrl: if (not DB_BRAMCTRL_MODE) generate
	begin
		ADDR <= std_logic_vector(to_unsigned(addr_cnt, FULL_ADDR_WIDTH));
	end generate gen_no_bram_ctrl;

	gen_bram_ctrl: if (DB_BRAMCTRL_MODE) generate
	begin
		gen_bram_ctrl32: if (FULL_DATA_WIDTH=32) generate
		begin
			ADDR(FULL_ADDR_WIDTH-1 downto 2) <= std_logic_vector(to_unsigned(addr_cnt, FULL_ADDR_WIDTH-2));
			ADDR(1 downto 0) <= "00";
		end generate gen_bram_ctrl32;

		gen_bram_ctrl64: if (FULL_DATA_WIDTH=64) generate
		begin
			ADDR(FULL_ADDR_WIDTH-1 downto 3) <= std_logic_vector(to_unsigned(addr_cnt, FULL_ADDR_WIDTH-3));
			ADDR(2 downto 0) <= "000";
		end generate gen_bram_ctrl64;
	end generate gen_bram_ctrl;

	WEN <= (others => write_en);
	EN <= write_en;

	-- internals
	
	process(db_clock_in)
	begin
		if (rising_edge(db_clock_in)) then
			if (rx_reset='1') then
				addr_cnt <= 0;
			elsif (write_en='1') then
				addr_cnt <= addr_cnt + 1; 
			end if;
		end if;
	end process;	

	process(db_clock_in)
	begin
		if (rising_edge(db_clock_in)) then
			if (rx_reset='1') then
				data_bit_cnt <= 0;
			elsif (write_en='1') then -- wraparound; always in the data_valid "gap"
				data_bit_cnt <= 0;
			elsif (rx_data_valid(0)='1') then
				data_bit_cnt <= data_bit_cnt + 1;
			end if;
		end if;
	end process;

	process(db_clock_in)
	begin
		if (rising_edge(db_clock_in)) then
			if (rx_reset='1') then
				write_en <= '0';
			elsif (rx_data_valid(0)='1' and data_bit_cnt=DB_BRAM_DATA_WIDTH-1) then
				write_en <= '1';
			else
				write_en <= '0';
			end if;
		end if;
	end process;	

end RTL;

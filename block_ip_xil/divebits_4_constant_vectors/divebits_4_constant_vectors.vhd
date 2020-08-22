library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity divebits_4_constant_vectors is
	Generic ( DB_ADDRESS : natural range 16#001# to 16#FFE# := 16#001#;
	          DB_TYPE : natural range 1003 to 1003 := 1003; -- must be unique to IP

			  DB_VECTOR_WIDTH: natural range 0 to 64 := 32;
			  DB_DEFAULT_VALUE_ALL: integer := 0;

			  DB_DEFAULT_VALUE_00: integer := 0;
			  DB_DEFAULT_VALUE_01: integer := 0;
			  DB_DEFAULT_VALUE_02: integer := 0;
			  DB_DEFAULT_VALUE_03: integer := 0;
			  
			  DB_DAISY_CHAIN: boolean := true );
	Port  ( -- DiveBits Slave 
			db_clock_in : in STD_LOGIC;
			db_data_in : in STD_LOGIC;
			
			-- DiveBits Master - only required for daisy chaining
			db_clock_out : out STD_LOGIC;
			db_data_out : out STD_LOGIC;
			--
			Vector_00 : out std_logic_vector(DB_VECTOR_WIDTH-1 downto 0);
			Vector_01 : out std_logic_vector(DB_VECTOR_WIDTH-1 downto 0);
			Vector_02 : out std_logic_vector(DB_VECTOR_WIDTH-1 downto 0);
			Vector_03 : out std_logic_vector(DB_VECTOR_WIDTH-1 downto 0)
			);
end divebits_4_constant_vectors;


architecture RTL of divebits_4_constant_vectors is
	
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
	signal rx_data_valid: std_logic_vector(0 to 3);

	-- the use of rx_reset is not required since this will either be properly filled by DiveBits or not all
	-- rx_reset is for two-dimensional storage where the write address needs to be reset on a second try
	signal Data_SR_00: std_logic_vector(DB_VECTOR_WIDTH-1 downto 0) := std_logic_vector(to_unsigned(DB_DEFAULT_VALUE_ALL+DB_DEFAULT_VALUE_00,DB_VECTOR_WIDTH));
	signal Data_SR_01: std_logic_vector(DB_VECTOR_WIDTH-1 downto 0) := std_logic_vector(to_unsigned(DB_DEFAULT_VALUE_ALL+DB_DEFAULT_VALUE_01,DB_VECTOR_WIDTH));
	signal Data_SR_02: std_logic_vector(DB_VECTOR_WIDTH-1 downto 0) := std_logic_vector(to_unsigned(DB_DEFAULT_VALUE_ALL+DB_DEFAULT_VALUE_02,DB_VECTOR_WIDTH));
	signal Data_SR_03: std_logic_vector(DB_VECTOR_WIDTH-1 downto 0) := std_logic_vector(to_unsigned(DB_DEFAULT_VALUE_ALL+DB_DEFAULT_VALUE_03,DB_VECTOR_WIDTH));

begin
	
	rcv:component divebits_receiver
		generic map(
			DB_ADDRESS   => DB_ADDRESS,
			NUM_CHANNELS => 4,
			DAISY_CHAIN  => DB_DAISY_CHAIN
		)
		port map(
			db_clock_in   => db_clock_in,
			db_data_in    => db_data_in,
			db_clock_out  => db_clock_out,
			db_data_out   => db_data_out,
			rx_data       => rx_data,
			rx_data_valid => rx_data_valid,
			rx_reset      => open
		);

	-- Data register
	process(db_clock_in)
	begin
		if (rising_edge(db_clock_in)) then
			if (rx_data_valid(00)='1') then
				Data_SR_00 <= rx_data & Data_SR_00(DB_VECTOR_WIDTH-1 downto 1);
			end if;
			if (rx_data_valid(01)='1') then
				Data_SR_01 <= rx_data & Data_SR_01(DB_VECTOR_WIDTH-1 downto 1);
			end if;
			if (rx_data_valid(02)='1') then
				Data_SR_02 <= rx_data & Data_SR_02(DB_VECTOR_WIDTH-1 downto 1);
			end if;
			if (rx_data_valid(03)='1') then
				Data_SR_03 <= rx_data & Data_SR_03(DB_VECTOR_WIDTH-1 downto 1);
			end if;
		end if;
	end process;
	Vector_00 <= Data_SR_00;
	Vector_01 <= Data_SR_01;
	Vector_02 <= Data_SR_02;
	Vector_03 <= Data_SR_03;

end RTL;

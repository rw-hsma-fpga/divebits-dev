library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity divebits_16_constant_vectors is
	Generic ( DB_ADDRESS : natural range 16#001# to 16#FFE# := 16#001#;

			  VECTOR_WIDTH_ALL: natural range 0 to 64 := 32;
			  DEFAULT_VALUE_ALL: integer := 0;

			  VECTOR_WIDTH_00: natural range 0 to 64 := 0;
			  DEFAULT_VALUE_00: integer := 0;
			  VECTOR_WIDTH_01: natural range 0 to 64 := 0;
			  DEFAULT_VALUE_01: integer := 0;
			  VECTOR_WIDTH_02: natural range 0 to 64 := 0;
			  DEFAULT_VALUE_02: integer := 0;
			  VECTOR_WIDTH_03: natural range 0 to 64 := 0;
			  DEFAULT_VALUE_03: integer := 0;
			  VECTOR_WIDTH_04: natural range 0 to 64 := 0;
			  DEFAULT_VALUE_04: integer := 0;
			  VECTOR_WIDTH_05: natural range 0 to 64 := 0;
			  DEFAULT_VALUE_05: integer := 0;
			  VECTOR_WIDTH_06: natural range 0 to 64 := 0;
			  DEFAULT_VALUE_06: integer := 0;
			  VECTOR_WIDTH_07: natural range 0 to 64 := 0;
			  DEFAULT_VALUE_07: integer := 0;
			  VECTOR_WIDTH_08: natural range 0 to 64 := 0;
			  DEFAULT_VALUE_08: integer := 0;
			  VECTOR_WIDTH_09: natural range 0 to 64 := 0;
			  DEFAULT_VALUE_09: integer := 0;
			  VECTOR_WIDTH_10: natural range 0 to 64 := 0;
			  DEFAULT_VALUE_10: integer := 0;
			  VECTOR_WIDTH_11: natural range 0 to 64 := 0;
			  DEFAULT_VALUE_11: integer := 0;
			  VECTOR_WIDTH_12: natural range 0 to 64 := 0;
			  DEFAULT_VALUE_12: integer := 0;
			  VECTOR_WIDTH_13: natural range 0 to 64 := 0;
			  DEFAULT_VALUE_13: integer := 0;
			  VECTOR_WIDTH_14: natural range 0 to 64 := 0;
			  DEFAULT_VALUE_14: integer := 0;
			  VECTOR_WIDTH_15: natural range 0 to 64 := 0;
			  DEFAULT_VALUE_15: integer := 0;
			  
			  DAISY_CHAIN: boolean := true );
	Port  ( -- DiveBits Slave 
			db_clock_in : in STD_LOGIC;
			db_data_in : in STD_LOGIC;
			
			-- DiveBits Master - only required for daisy chaining
			db_clock_out : out STD_LOGIC;
			db_data_out : out STD_LOGIC;
			--
			Vector_00 : out std_logic_vector(VECTOR_WIDTH_ALL+VECTOR_WIDTH_00-1 downto 0);
			Vector_01 : out std_logic_vector(VECTOR_WIDTH_ALL+VECTOR_WIDTH_01-1 downto 0);
			Vector_02 : out std_logic_vector(VECTOR_WIDTH_ALL+VECTOR_WIDTH_02-1 downto 0);
			Vector_03 : out std_logic_vector(VECTOR_WIDTH_ALL+VECTOR_WIDTH_03-1 downto 0);
			Vector_04 : out std_logic_vector(VECTOR_WIDTH_ALL+VECTOR_WIDTH_04-1 downto 0);
			Vector_05 : out std_logic_vector(VECTOR_WIDTH_ALL+VECTOR_WIDTH_05-1 downto 0);
			Vector_06 : out std_logic_vector(VECTOR_WIDTH_ALL+VECTOR_WIDTH_06-1 downto 0);
			Vector_07 : out std_logic_vector(VECTOR_WIDTH_ALL+VECTOR_WIDTH_07-1 downto 0);
			Vector_08 : out std_logic_vector(VECTOR_WIDTH_ALL+VECTOR_WIDTH_08-1 downto 0);
			Vector_09 : out std_logic_vector(VECTOR_WIDTH_ALL+VECTOR_WIDTH_09-1 downto 0);
			Vector_10 : out std_logic_vector(VECTOR_WIDTH_ALL+VECTOR_WIDTH_10-1 downto 0);
			Vector_11 : out std_logic_vector(VECTOR_WIDTH_ALL+VECTOR_WIDTH_11-1 downto 0);
			Vector_12 : out std_logic_vector(VECTOR_WIDTH_ALL+VECTOR_WIDTH_12-1 downto 0);
			Vector_13 : out std_logic_vector(VECTOR_WIDTH_ALL+VECTOR_WIDTH_13-1 downto 0);
			Vector_14 : out std_logic_vector(VECTOR_WIDTH_ALL+VECTOR_WIDTH_14-1 downto 0);
			Vector_15 : out std_logic_vector(VECTOR_WIDTH_ALL+VECTOR_WIDTH_15-1 downto 0)
			);
end divebits_16_constant_vectors;


architecture RTL of divebits_16_constant_vectors is
	
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
	signal rx_data_valid: std_logic_vector(0 to 15);

	-- the use of rx_reset is not required since this will either be properly filled by DiveBits or not all
	-- rx_reset is for two-dimensional storage where the write address needs to be reset on a second try
	signal Data_SR_00: std_logic_vector(VECTOR_WIDTH_ALL+VECTOR_WIDTH_00-1 downto 0) := std_logic_vector(to_unsigned(DEFAULT_VALUE_ALL+DEFAULT_VALUE_00,VECTOR_WIDTH_ALL+VECTOR_WIDTH_00));
	signal Data_SR_01: std_logic_vector(VECTOR_WIDTH_ALL+VECTOR_WIDTH_01-1 downto 0) := std_logic_vector(to_unsigned(DEFAULT_VALUE_ALL+DEFAULT_VALUE_01,VECTOR_WIDTH_ALL+VECTOR_WIDTH_01));
	signal Data_SR_02: std_logic_vector(VECTOR_WIDTH_ALL+VECTOR_WIDTH_02-1 downto 0) := std_logic_vector(to_unsigned(DEFAULT_VALUE_ALL+DEFAULT_VALUE_02,VECTOR_WIDTH_ALL+VECTOR_WIDTH_02));
	signal Data_SR_03: std_logic_vector(VECTOR_WIDTH_ALL+VECTOR_WIDTH_03-1 downto 0) := std_logic_vector(to_unsigned(DEFAULT_VALUE_ALL+DEFAULT_VALUE_03,VECTOR_WIDTH_ALL+VECTOR_WIDTH_03));
	signal Data_SR_04: std_logic_vector(VECTOR_WIDTH_ALL+VECTOR_WIDTH_04-1 downto 0) := std_logic_vector(to_unsigned(DEFAULT_VALUE_ALL+DEFAULT_VALUE_04,VECTOR_WIDTH_ALL+VECTOR_WIDTH_04));
	signal Data_SR_05: std_logic_vector(VECTOR_WIDTH_ALL+VECTOR_WIDTH_05-1 downto 0) := std_logic_vector(to_unsigned(DEFAULT_VALUE_ALL+DEFAULT_VALUE_05,VECTOR_WIDTH_ALL+VECTOR_WIDTH_05));
	signal Data_SR_06: std_logic_vector(VECTOR_WIDTH_ALL+VECTOR_WIDTH_06-1 downto 0) := std_logic_vector(to_unsigned(DEFAULT_VALUE_ALL+DEFAULT_VALUE_06,VECTOR_WIDTH_ALL+VECTOR_WIDTH_06));
	signal Data_SR_07: std_logic_vector(VECTOR_WIDTH_ALL+VECTOR_WIDTH_07-1 downto 0) := std_logic_vector(to_unsigned(DEFAULT_VALUE_ALL+DEFAULT_VALUE_07,VECTOR_WIDTH_ALL+VECTOR_WIDTH_07));
	signal Data_SR_08: std_logic_vector(VECTOR_WIDTH_ALL+VECTOR_WIDTH_08-1 downto 0) := std_logic_vector(to_unsigned(DEFAULT_VALUE_ALL+DEFAULT_VALUE_08,VECTOR_WIDTH_ALL+VECTOR_WIDTH_08));
	signal Data_SR_09: std_logic_vector(VECTOR_WIDTH_ALL+VECTOR_WIDTH_09-1 downto 0) := std_logic_vector(to_unsigned(DEFAULT_VALUE_ALL+DEFAULT_VALUE_09,VECTOR_WIDTH_ALL+VECTOR_WIDTH_09));
	signal Data_SR_10: std_logic_vector(VECTOR_WIDTH_ALL+VECTOR_WIDTH_10-1 downto 0) := std_logic_vector(to_unsigned(DEFAULT_VALUE_ALL+DEFAULT_VALUE_10,VECTOR_WIDTH_ALL+VECTOR_WIDTH_10));
	signal Data_SR_11: std_logic_vector(VECTOR_WIDTH_ALL+VECTOR_WIDTH_11-1 downto 0) := std_logic_vector(to_unsigned(DEFAULT_VALUE_ALL+DEFAULT_VALUE_11,VECTOR_WIDTH_ALL+VECTOR_WIDTH_11));
	signal Data_SR_12: std_logic_vector(VECTOR_WIDTH_ALL+VECTOR_WIDTH_12-1 downto 0) := std_logic_vector(to_unsigned(DEFAULT_VALUE_ALL+DEFAULT_VALUE_12,VECTOR_WIDTH_ALL+VECTOR_WIDTH_12));
	signal Data_SR_13: std_logic_vector(VECTOR_WIDTH_ALL+VECTOR_WIDTH_13-1 downto 0) := std_logic_vector(to_unsigned(DEFAULT_VALUE_ALL+DEFAULT_VALUE_13,VECTOR_WIDTH_ALL+VECTOR_WIDTH_13));
	signal Data_SR_14: std_logic_vector(VECTOR_WIDTH_ALL+VECTOR_WIDTH_14-1 downto 0) := std_logic_vector(to_unsigned(DEFAULT_VALUE_ALL+DEFAULT_VALUE_14,VECTOR_WIDTH_ALL+VECTOR_WIDTH_14));
	signal Data_SR_15: std_logic_vector(VECTOR_WIDTH_ALL+VECTOR_WIDTH_15-1 downto 0) := std_logic_vector(to_unsigned(DEFAULT_VALUE_ALL+DEFAULT_VALUE_15,VECTOR_WIDTH_ALL+VECTOR_WIDTH_15));

begin
	
	rcv:component divebits_receiver
		generic map(
			DB_ADDRESS   => DB_ADDRESS,
			NUM_CHANNELS => 16,
			DAISY_CHAIN  => DAISY_CHAIN
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
				Data_SR_00 <= rx_data & Data_SR_00(VECTOR_WIDTH_ALL+VECTOR_WIDTH_00-1 downto 1);
			end if;
			if (rx_data_valid(01)='1') then
				Data_SR_01 <= rx_data & Data_SR_01(VECTOR_WIDTH_ALL+VECTOR_WIDTH_01-1 downto 1);
			end if;
			if (rx_data_valid(02)='1') then
				Data_SR_02 <= rx_data & Data_SR_02(VECTOR_WIDTH_ALL+VECTOR_WIDTH_02-1 downto 1);
			end if;
			if (rx_data_valid(03)='1') then
				Data_SR_03 <= rx_data & Data_SR_03(VECTOR_WIDTH_ALL+VECTOR_WIDTH_03-1 downto 1);
			end if;
			if (rx_data_valid(04)='1') then
				Data_SR_04 <= rx_data & Data_SR_04(VECTOR_WIDTH_ALL+VECTOR_WIDTH_04-1 downto 1);
			end if;
			if (rx_data_valid(05)='1') then
				Data_SR_05 <= rx_data & Data_SR_05(VECTOR_WIDTH_ALL+VECTOR_WIDTH_05-1 downto 1);
			end if;
			if (rx_data_valid(06)='1') then
				Data_SR_06 <= rx_data & Data_SR_06(VECTOR_WIDTH_ALL+VECTOR_WIDTH_06-1 downto 1);
			end if;
			if (rx_data_valid(07)='1') then
				Data_SR_07 <= rx_data & Data_SR_07(VECTOR_WIDTH_ALL+VECTOR_WIDTH_07-1 downto 1);
			end if;
			if (rx_data_valid(08)='1') then
				Data_SR_08 <= rx_data & Data_SR_08(VECTOR_WIDTH_ALL+VECTOR_WIDTH_08-1 downto 1);
			end if;
			if (rx_data_valid(09)='1') then
				Data_SR_09 <= rx_data & Data_SR_09(VECTOR_WIDTH_ALL+VECTOR_WIDTH_09-1 downto 1);
			end if;
			if (rx_data_valid(10)='1') then
				Data_SR_10 <= rx_data & Data_SR_10(VECTOR_WIDTH_ALL+VECTOR_WIDTH_10-1 downto 1);
			end if;
			if (rx_data_valid(11)='1') then
				Data_SR_11 <= rx_data & Data_SR_11(VECTOR_WIDTH_ALL+VECTOR_WIDTH_11-1 downto 1);
			end if;
			if (rx_data_valid(12)='1') then
				Data_SR_12 <= rx_data & Data_SR_12(VECTOR_WIDTH_ALL+VECTOR_WIDTH_12-1 downto 1);
			end if;
			if (rx_data_valid(13)='1') then
				Data_SR_13 <= rx_data & Data_SR_13(VECTOR_WIDTH_ALL+VECTOR_WIDTH_13-1 downto 1);
			end if;
			if (rx_data_valid(14)='1') then
				Data_SR_14 <= rx_data & Data_SR_14(VECTOR_WIDTH_ALL+VECTOR_WIDTH_14-1 downto 1);
			end if;
			if (rx_data_valid(15)='1') then
				Data_SR_15 <= rx_data & Data_SR_15(VECTOR_WIDTH_ALL+VECTOR_WIDTH_15-1 downto 1);
			end if;
		end if;
	end process;
	Vector_00 <= Data_SR_00;
	Vector_01 <= Data_SR_01;
	Vector_02 <= Data_SR_02;
	Vector_03 <= Data_SR_03;
	Vector_04 <= Data_SR_04;
	Vector_05 <= Data_SR_05;
	Vector_06 <= Data_SR_06;
	Vector_07 <= Data_SR_07;
	Vector_08 <= Data_SR_08;
	Vector_09 <= Data_SR_09;
	Vector_10 <= Data_SR_10;
	Vector_11 <= Data_SR_11;
	Vector_12 <= Data_SR_12;
	Vector_13 <= Data_SR_13;
	Vector_14 <= Data_SR_14;
	Vector_15 <= Data_SR_15;

end RTL;
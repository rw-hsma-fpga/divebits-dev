library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity divebits_constant_vector is
	Generic ( DB_ADDRESS : natural range 16#001# to 16#FFE# := 16#001#;
			  VECTOR_WIDTH: positive range 1 to 64 := 32;
			  DEFAULT_VALUE: integer := 0;
			  DAISY_CHAIN: boolean := true );
	Port  ( -- DiveBits Slave 
			db_clock_in : in STD_LOGIC;
			db_data_in : in STD_LOGIC;
			
			-- DiveBits Master - only required for daisy chaining
			db_clock_out : out STD_LOGIC;
			db_data_out : out STD_LOGIC;
			--
			Vector_out : out std_logic_vector(VECTOR_WIDTH-1 downto 0)
			);
end divebits_constant_vector;


architecture RTL of divebits_constant_vector is

	attribute MARK_DEBUG : string;
	
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
	signal rx_data_valid: std_logic_vector(0 downto 0);

	-- the use of rx_reset is not required since this will either be properly filled by DiveBits or not all
	-- rx_reset is for two-dimensional storage where the write address needs to be reset on a second try
	signal Data_SR: std_logic_vector(VECTOR_WIDTH-1 downto 0) := std_logic_vector(to_unsigned(DEFAULT_VALUE,VECTOR_WIDTH));
	   attribute MARK_DEBUG of Data_SR : signal is "true";

begin
	
	rcv:component divebits_receiver
		generic map(
			DB_ADDRESS   => DB_ADDRESS,
			NUM_CHANNELS => 1,
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
			if (rx_data_valid="1") then
				Data_SR <= rx_data & Data_SR(VECTOR_WIDTH-1 downto 1);
			end if;
		end if;
	end process;
	Vector_out <= Data_SR;

end RTL;

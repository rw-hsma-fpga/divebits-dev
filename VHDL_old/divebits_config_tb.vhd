----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02.03.2020 11:51:31
-- Design Name: 
-- Module Name: divebits_config_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity divebits_config_tb is
--  Port ( );
end divebits_config_tb;

architecture Behavioral of divebits_config_tb is

    component divebits_config is
		Generic ( RELEASE_HIGH_ACTIVE : boolean := true;
				  INCLUDE_CRC_CHECK   : boolean := false;
				  RELEASE_DELAY_CYCLES: natural range 4 to 259:= 20
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
				db_data_in : in STD_LOGIC   -- feedback input
				);
    end component;
    
    signal clock: std_logic;
    signal release: std_logic;

    signal data: std_logic;
    signal release_out: std_logic;
    
	component divebits_constant_vector is
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
	end component;
	
	component divebits_16_constant_vectors is
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
	end component;

	signal db_clock:  std_logic;
    signal rcv_data_in1:  std_logic;
    signal rcv_data_out1: std_logic;
    signal rcv_data_in2:  std_logic;
    signal rcv_data_out2: std_logic;
    signal Vector_out : std_logic_vector(8-1 downto 0);
    signal Vector_00 : std_logic_vector(16-1 downto 0);
    signal Vector_15 : std_logic_vector(24-1 downto 0);

begin

	process
	begin
		clock <= '1';
		wait for 5 ns;
		clock <= '0';
		wait for 5 ns;
	end process;
	
	process
	begin
		release <= '0';
		wait for 87 ns;
		release <= '1';
		wait;
	end process;
	
	
	dut: divebits_config
	PORT MAP (
			sys_clock_in => clock,
			sys_release_in => release,
			sys_release_out => release_out,
			
			db_clock_out => db_clock,
			db_data_out => data,
			
			db_clock_in => db_clock,
			db_data_in => data
			);
			
	rcv_data_in1 <= data;
	rcv_data_in2 <= data;
	
	
	rcv1: divebits_constant_vector
	GENERIC MAP (
			DB_ADDRESS => 16#100#,
			VECTOR_WIDTH => 8,
			DEFAULT_VALUE => 0,
			DAISY_CHAIN => false
			)
	PORT MAP (
			db_clock_in => db_clock,
			db_data_in  => rcv_data_in1,

			db_clock_out => open,
			db_data_out => rcv_data_out1,

			Vector_out => Vector_out
			);
	
			
	rcv16: divebits_16_constant_vectors
		generic map(
			DB_ADDRESS => 16#747#,
			VECTOR_WIDTH_ALL => 0,
			VECTOR_WIDTH_00 => 16,
			VECTOR_WIDTH_15 => 24,
			DAISY_CHAIN => false
		)
		port map(
			db_clock_in => db_clock,
			db_data_in  => rcv_data_in1,
			db_clock_out => open,
			db_data_out => rcv_data_out1,
			Vector_00 => Vector_00,
			Vector_15 => Vector_15
		);
	

end Behavioral;

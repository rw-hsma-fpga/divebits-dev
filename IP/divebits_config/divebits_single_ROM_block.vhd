library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity divebits_single_ROM_block is
	Generic ( ROM_ID : natural range 0 to 7 );
	Port  ( -- system ports
			clock : in STD_LOGIC;
			ROM_address: in std_logic_vector(14 downto 0);
			dout : out STD_LOGIC
			);
end divebits_single_ROM_block;


architecture RTL of divebits_single_ROM_block is

	type config_rom_type is array(0 to 32767) of std_logic_vector(0 downto 0);
	
	-- just for debugging purposes; ROM will later be initialized by updatemem
	-- NOTE: should not be used in implementation; so BlockRAM is all 0 without updatemem
	constant num_of_init_tuples: natural := 10;
	function config_rom_init return config_rom_type is
		variable init_data: config_rom_type := (others => "0");
		type init_tuples_array is array(0 to 2*num_of_init_tuples-1) of integer;
		constant init_tuples: init_tuples_array := (	-- GLOBAL HEADER
														20,  20 + (16+16+4) + (16+16+4), -- 20 bits of overall payload length 20+8

														-- PACKET 1
														 16,  16#02A0#,    -- 16 bits of address 0x7470
														 16,  4,           -- 16 bits of payload length 16
														  4,  16#8#, -- 16 bits of payload

														-- PACKET 2
														 16,  16#02B0#,    -- 16 bits of address 0x747F
														 16,  4,           -- 16 bits of payload length 24
														  4,  16#1#, -- 24 bits of payload
														others => 0);
		variable adr: integer :=0;
		variable bitcnt: integer;
		variable bitbuffer: std_logic_vector(31 downto 0); 
	begin
		for i in 0 to num_of_init_tuples-1 loop
			bitcnt := init_tuples(i*2); 
			if (bitcnt/=0) then
				bitbuffer := std_logic_vector(to_unsigned(init_tuples(i*2+1),32));
				for j in 0 to bitcnt-1 loop
					init_data(adr) := bitbuffer(j downto j);
					adr := adr + 1;
				end loop;
			end if;		
		end loop;
		return init_data;
	end function config_rom_init;

	
	signal DIVEBITS_CONFIG_ROM: config_rom_type :=  (others => "0");
		-- config_rom_init;
	
	signal dbuf: std_logic;--_vector(0 downto 0);
	signal WE: std_logic := '0';

	function srvec_init return std_logic_vector is--((4+ROM_ID*2)-1 downto 0) is
		variable bitbuffer: std_logic_vector((4+ROM_ID*2)-1 downto 0); 
	begin
		for i in 0 to (4+ROM_ID*2)-1 loop
			if ((i mod 2)=1) then
				bitbuffer(i) := '1';
			else
				bitbuffer(i) := '0';
			end if;
		end loop;
		return bitbuffer;
	end function srvec_init;

	signal srvec: std_logic_vector((4+ROM_ID*2)-1 downto 0) := srvec_init;--( 1 => '1', 3 => '1', others=> '0');
	
begin
	
	-- ROM
	process(clock)
	begin
		if rising_edge(clock) then
			if (WE='1') then
				DIVEBITS_CONFIG_ROM(to_integer(unsigned(ROM_address)))(0) <= dbuf;
			end if;
-- synthesis translate_off
			DIVEBITS_CONFIG_ROM <= config_rom_init;
-- synthesis translate_on
			dbuf <= DIVEBITS_CONFIG_ROM(to_integer(unsigned(ROM_address)))(0);
		end if;
	end process;
	dout <= dbuf;
		
	--dout <= DIVEBITS_CONFIG_ROM(to_integer(unsigned(ROM_address)))(0) when rising_edge(clock);

    -- making fake WE
	srshift: process(clock)
	begin
		if rising_edge(clock) then
		   srvec <= srvec((4+ROM_ID*2)-2 downto 0) & srvec((4+ROM_ID*2)-1); -- looping bits 1010 around
		end if;
	end process;
	--WE <= srvec(3) and srvec(2);
    WE <= '1' when (srvec(3)=srvec(2)) else '0'; -- never actually happening but keeps it a RAM.

end RTL;

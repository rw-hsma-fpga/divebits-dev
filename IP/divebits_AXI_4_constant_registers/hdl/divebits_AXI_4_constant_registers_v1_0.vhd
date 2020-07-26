library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity divebits_AXI_4_constant_registers_v1_0 is
	generic (
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 4;
		
		
        DB_ADDRESS : natural range 16#001# to 16#FFE# := 16#001#;
        DB_TYPE : natural range 2002 to 2002 := 2002; -- must be unique to IP
        
        DB_DEFAULT_VALUE: integer := 0;
        
        DB_DAISY_CHAIN: boolean := true
        );
	port (
	
        -- DiveBits Slave 
        db_clock_in : in STD_LOGIC;
        db_data_in : in STD_LOGIC;
        
        -- DiveBits Master - only required for daisy chaining
        db_clock_out : out STD_LOGIC;
        db_data_out : out STD_LOGIC;
        

		-- Ports of Axi Slave Bus Interface S00_AXI
		s00_axi_aclk	: in std_logic;
		s00_axi_aresetn	: in std_logic;
		s00_axi_awaddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_awprot	: in std_logic_vector(2 downto 0);
		s00_axi_awvalid	: in std_logic;
		s00_axi_awready	: out std_logic;
		s00_axi_wdata	: in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_wstrb	: in std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
		s00_axi_wvalid	: in std_logic;
		s00_axi_wready	: out std_logic;
		s00_axi_bresp	: out std_logic_vector(1 downto 0);
		s00_axi_bvalid	: out std_logic;
		s00_axi_bready	: in std_logic;
		s00_axi_araddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_arprot	: in std_logic_vector(2 downto 0);
		s00_axi_arvalid	: in std_logic;
		s00_axi_arready	: out std_logic;
		s00_axi_rdata	: out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_rresp	: out std_logic_vector(1 downto 0);
		s00_axi_rvalid	: out std_logic;
		s00_axi_rready	: in std_logic
	);
end divebits_AXI_4_constant_registers_v1_0;

architecture arch_imp of divebits_AXI_4_constant_registers_v1_0 is

	component divebits_receiver is
		Generic ( DB_ADDRESS : natural range 16#001# to 16#FFE# := 16#001#;
				  NUM_CHANNELS: positive range 1 to 16 := 4;
				  DAISY_CHAIN: boolean := true
		);
		
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
	signal Register0: std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0) := std_logic_vector(to_unsigned(DB_DEFAULT_VALUE,32));
	signal Register1: std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0) := std_logic_vector(to_unsigned(DB_DEFAULT_VALUE,32));
	signal Register2: std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0) := std_logic_vector(to_unsigned(DB_DEFAULT_VALUE,32));
	signal Register3: std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0) := std_logic_vector(to_unsigned(DB_DEFAULT_VALUE,32));

	---- READ SIGNALS ----
	signal Read_RegAddress : std_logic_vector(1 downto 0);
	signal r_valid : std_logic;


	---- WRITE SIGNALS ----
	signal w_ready : std_logic;
	signal b_valid : std_logic;
	
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
		
	process(db_clock_in)
	begin
		if (rising_edge(db_clock_in)) then
			if (rx_data_valid(00)='1') then
				Register0 <= rx_data & Register0(C_S00_AXI_DATA_WIDTH-1 downto 1);
			end if;
			if (rx_data_valid(01)='1') then
				Register1 <= rx_data & Register1(C_S00_AXI_DATA_WIDTH-1 downto 1);
			end if;
			if (rx_data_valid(02)='1') then
				Register2 <= rx_data & Register2(C_S00_AXI_DATA_WIDTH-1 downto 1);
			end if;
			if (rx_data_valid(03)='1') then
				Register3 <= rx_data & Register3(C_S00_AXI_DATA_WIDTH-1 downto 1);
			end if;
		end if;
	end process;


	---- READ ACCESS (control flow) ----
	s00_axi_rvalid  <= r_valid;
	s00_axi_rresp   <= "00"; -- always OK
	
	s00_axi_arready <= '1';  -- can always accept read address
	
	process(s00_axi_aclk)
	begin
		if (rising_edge(s00_axi_aclk)) then
			if (s00_axi_aresetn='0') then
				Read_RegAddress <= (others => '0');
			elsif (s00_axi_arvalid='1') then
				Read_RegAddress <= s00_axi_araddr(3 downto 2); -- 4 registers; lower two bits are for byte-addressing and not used for 32-bit registers;
			end if;
		end if;
	end process;
	
	process(s00_axi_aclk)
	begin
		if (rising_edge(s00_axi_aclk)) then
			if (s00_axi_aresetn='0') then
				r_valid <= '0';
			elsif (s00_axi_arvalid='1') then -- can offer data one cycle after address transfer
				r_valid <= '1';
			elsif ((s00_axi_rready and r_valid)='1') then
				r_valid <= '0';
			end if;
		end if;
	end process;

	-- Read Multiplexer - picks which register value to return
	with Read_RegAddress select
		s00_axi_rdata <= 	Register0 when "00",
							Register1 when "01",
							Register2 when "10",
							Register3 when others; --"11";



	---- WRITE ACCESS (control flow) ----
	s00_axi_wready  <= w_ready;
	s00_axi_bvalid  <= b_valid;
	s00_axi_bresp   <= "00"; -- always OK
	
	s00_axi_awready <= '1';

	process(s00_axi_aclk)
	begin
		if (rising_edge(s00_axi_aclk)) then
			if (s00_axi_aresetn='0') then
				w_ready <= '0';
			elsif (s00_axi_awvalid='1') then -- can accept data one cycle after address transfer
				w_ready <= '1';
			elsif ((s00_axi_wvalid and w_ready)='1') then
				w_ready <= '0';
			end if;
		end if;
	end process;

	process(s00_axi_aclk)
	begin
		if (rising_edge(s00_axi_aclk)) then
			if (s00_axi_aresetn='0') then
				b_valid <= '0';
			elsif (s00_axi_wvalid='1') then -- can acknowledge right after write transfer
				b_valid <= '1';
			elsif ((s00_axi_bready  and b_valid)='1') then
				b_valid <= '0';
			end if;
		end if;
	end process;
	
	
end arch_imp;

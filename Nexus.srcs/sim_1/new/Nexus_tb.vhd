library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity Nexus_tb is
	--  Port ( );
end Nexus_tb;

architecture Behavioral of Nexus_tb is
    
    component Nexus is
	Port (
		-- Keyboard I/O
		KCLK	: in std_logic;
		KDATA	: in std_logic;

		-- VGA I/O
		VGA_HS	: out std_logic;
		VGA_VS	: out std_logic;
		VGA_R	: out std_logic_vector (3 downto 0);
		VGA_G	: out std_logic_vector (3 downto 0);
		VGA_B	: out std_logic_vector (3 downto 0);

		-- Executor I/O
		LED		: out std_logic_vector (15 downto 0);
		AN		: out std_logic_vector (7 downto 0);
		CA		: out std_logic_vector (7 downto 0);
		CLED0	: out std_logic_vector (2 downto 0);
		CLED1	: out std_logic_vector (2 downto 0);

		-- Shared I/O
		CLOCK	: in std_logic;
		RESET	: in std_logic
	);
    end component;


	-- Vhodni signali, ki UUT povezujejo z generatorjem dra�ljajev
	signal CLOCK, RESET     : std_logic := '0';
	signal KCLK, KDATA  : std_logic := '1';
	signal VGA_HS, VGA_VS : std_logic;
    signal  VGA_R, VGA_G, VGA_B  :std_logic_vector(3 downto 0);

	-- Konstante
	constant CLK_PERIOD : time                          := 10 ns;
	-- Podatki s tipkovnice za simulacijo 
	-- Podatke pisemo v smeri, ki je obratna, kot ce bi jih pisali glede na cas.
	-- STOP PAR B7...... B0 START
	--  1    0  0101 1010     0 "10 01011010 0" 
	type memory_type is array (0 to 17) of std_logic_vector(10 downto 0);
    signal SIM_DATA      : memory_type := (others => (others => '0'));
    

begin

	UUT : Nexus
	port map(
		CLOCK => CLOCK,
		RESET => RESET,
        KCLK => KCLK,
		KDATA => KDATA,
		-- VGA O
		VGA_HS => VGA_HS,
		VGA_VS => VGA_VS,
		VGA_R => VGA_R,
		VGA_G => VGA_G,
		VGA_B => VGA_B,

		-- Executor O
		LED => open,
		AN => open,
		CA => open,
		CLED0 => open,
		CLED1 => open
	);
INIT : process
	begin
		reset <= '1';
		SIM_DATA(0) <= "10010010110"; --L
		SIM_DATA(1) <= "10001001000"; --E
		SIM_DATA(2) <= "10001000110"; --D
		SIM_DATA(3) <= "10001010010"; --Space
		SIM_DATA(4) <= "10000111100"; --1
		SIM_DATA(5) <= "10001010010"; --Space
		SIM_DATA(6) <= "10010001000"; --O
		SIM_DATA(7) <= "10001100010"; --N
		SIM_DATA(8) <= "10010110100"; --Enter
		--New Line
		SIM_DATA(9) <= "10010010110"; --L
		SIM_DATA(10) <= "10001001000"; --E
		SIM_DATA(11) <= "10001000110"; --D
		SIM_DATA(12) <= "10001010010"; --Space
		SIM_DATA(13) <= "10000111100"; --1
		SIM_DATA(14) <= "10001010010"; --Space
		SIM_DATA(15) <= "10010001000"; --O
		SIM_DATA(16) <= "10001100010"; --N
		SIM_DATA(17) <= "10010110100"; --Enter
		wait for CLK_PERIOD*4;
		reset <= '0';
		wait;
	end process;
	-- Ura 
	CLK_STIMULUS : process
	begin
		CLOCK <= not CLOCK;
		wait for CLK_PERIOD/2;
	end process;

	-- Ostali signali 
	OTH_STIMULI : process
	begin


		-- Mirovanje
		KCLK  <= '1';
		KDATA <= '1';
		wait for CLK_PERIOD * 4;


		-- Pritisk tipke 
		for i in 0 to 10 loop
		for j in 0 to 10 loop
			kdata <= SIM_DATA(i)(j);
			wait for CLK_PERIOD  * 50000;
			kclk <= '0';
			wait for CLK_PERIOD  * 50000;
			kclk <= '1';
		end loop;
		end loop;

		-- Mirovanje
		kdata <= '1';
		wait;
	end process;
end Behavioral;
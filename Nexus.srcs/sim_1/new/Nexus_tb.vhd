library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity Nexus_tb is
end entity;

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
		CLED0	: out std_logic_vector (2 downto 0);
		CLED1	: out std_logic_vector (2 downto 0);

		-- Shared I/O
		CLOCK	: in std_logic;
		RESET	: in std_logic
	);
    end component;


	-- Vhodni signali, ki UUT povezujejo z generatorjem drazljajev
	signal CLOCK, RESET     	: std_logic := '0';
	signal KCLK, KDATA  		: std_logic := '1';
	signal VGA_HS, VGA_VS 		: std_logic;
    signal VGA_R, VGA_G, VGA_B  : std_logic_vector(3 downto 0);
	signal LED  				: std_logic_vector (15 downto 0);
	signal CLED0, CLED1 		: std_logic_vector (2 downto 0);

	-- Konstante
	constant CLK_PERIOD : time                          := 10 ns;
	-- Podatki s tipkovnice za simulacijo 
	-- Podatke pisemo v smeri, ki je obratna, kot ce bi jih pisali glede na cas.
	-- STOP PAR B7...... B0 START
	--  1    0  0101 1010     0 "10 01011010 0" 
	type char_arr_type is array (0 to 9) of std_logic_vector(10 downto 0);
	signal char_arr : char_arr_type := (
		"00100101101", -- L
		"00010010001", -- E
		"00010001101", -- D
		"00010100101", -- Space
		"00010100101", -- Space
		"00001011001", -- 1
		"00010100101", -- Space
		"00100010001", -- O
		"00011000101", -- N
		"00101101001"  -- Enter
	);
	
	type char_arr_type2 is array (0 to 9) of std_logic_vector(10 downto 0);
	signal char_arr2 : char_arr_type2 := (
		"00010000101", -- C
		"00100101101", -- L
		"00010010001", -- E
		"00010001101", -- D
		"00010100101", -- Space
		"00100010101", -- 0
		"00010100101", -- Space
		"00010100101", -- Space
		"00100110101", -- P
		"00101101001"  -- Enter
	);
	signal simbol : std_logic_vector(10 downto 0);

begin

	UUT : Nexus
	port map (
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
		LED => LED,
		CLED0 => CLED0,
		CLED1 => CLED1
	);

	-- Ura 
	CLK_STIMULUS : process
	begin
		CLOCK <= not CLOCK;
		wait for CLK_PERIOD/2;
	end process;


     --Ostali signali 
	OTH_STIMULI : process
	begin
		-- Reset
		RESET   <= '0';
		KCLK  <= '1';
		KDATA <= '1';
		wait for CLK_PERIOD * 3;

		-- Mirovanje
		RESET   <= '1';
		KCLK  <= '1';
		KDATA <= '1';
		wait for CLK_PERIOD * 3;

		-- Zamik ure tipkovnice, da (namenoma) ne bo sinhrona z notranjo uro
		wait for CLK_PERIOD/3;

		-- LED 1 ON + Enter
		for i in 0 to char_arr2'length - 1 loop
		  simbol <= char_arr2(i);
		  for j in 0 to 10 loop
			KDATA <= simbol(j);
			wait for CLK_PERIOD * 6;
			KCLK <= '0';
			wait for CLK_PERIOD * 6;
			KCLK <= '1';
		  end loop;
		end loop;

		-- Mirovanje
		KDATA <= '1';
		
		for i in 0 to 5 loop
			wait for CLK_PERIOD * 6;
			KCLK <= '0';
			wait for CLK_PERIOD * 6;
			KCLK <= '1';
		end loop;
		wait;

	end process;

end architecture;
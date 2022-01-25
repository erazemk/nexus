library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity VGA_tb is
--  Port ( );
end VGA_tb;

architecture Behavioral of VGA_tb is

component VGA is

	Port (
		clock	: in std_logic;
		reset	: in std_logic;
		char	: in std_logic_vector (7 downto 0);
		getchar	: out std_logic;
		hsync	: out std_logic;
		vsync	: out std_logic;
		red		: out std_logic_vector (3 downto 0);
		green	: out std_logic_vector (3 downto 0);
		blue	: out std_logic_vector (3 downto 0)
	);

end component;
signal clock    : std_logic := '0';
signal reset    : std_logic;
signal char     : std_logic_vector (7 downto 0) := "00000000";
signal getchar  : std_logic;

signal i        : integer := 0;
type memory_type is array (0 to 479) of std_logic_vector(7 downto 0);
signal memory       : memory_type := (others => (others => '0'));

constant CLK_PERIOD : time := 10 ns;

begin

UUT : VGA
    port map(
            clock   => clock,
			reset	=> reset,
			char	=> char,
			hsync => open,
		    vsync => open,
		    getchar => getchar,
		    red => open,
		    green => open,
            blue => open

	);

INIT : process
	begin
		reset <= '1';
		memory(0) <= "01001011"; --L
		memory(1) <= "00100100"; --E
		memory(2) <= "00100011"; --D
		memory(3) <= "00101001"; --Space
		memory(4) <= "00011110"; --1
		memory(5) <= "00101001"; --Space
		memory(6) <= "01000100"; --O
		memory(7) <= "00110001"; --N
		memory(8) <= "01011010"; --Enter
		--New Line
		memory(16) <= "01001011"; --L
		memory(17) <= "00100100"; --E
		memory(18) <= "00100011"; --D
		memory(19) <= "00101001"; --Space
		memory(20) <= "00011110"; --1
		memory(21) <= "00101001"; --Space
		memory(22) <= "01000100"; --O
		memory(23) <= "00110001"; --N
		memory(24) <= "01011010"; --Enter
		wait for CLK_PERIOD*4;
		reset <= '0';
		wait;
	end process;
		
CLK_STIMULUS : process
	begin
		clock <= not clock;
		wait for CLK_PERIOD/2;
	end process;

RAM_STIMULI : process
	begin
        wait until getchar = '1';
        wait for CLK_PERIOD * 3;
        char <= memory(i);
        i <= (i+1) mod 480;
    end process;

end architecture;

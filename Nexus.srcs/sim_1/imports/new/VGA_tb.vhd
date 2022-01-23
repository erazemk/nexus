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
signal char     : std_logic_vector (7 downto 0) := "01001011";
signal getchar    : std_logic;

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
	
CLK_STIMULUS : process
	begin
	for I in 0 to 100000 loop
		clock <= not clock;
		wait for CLK_PERIOD/2;
    end loop;
	end process;

OTH_STIMULI : process
	begin
		-- Reset
		reset    <= '1';
		wait for CLK_PERIOD * 3;
		reset <= '0';


        wait until getchar = '1';
        wait for CLK_PERIOD * 3;
        char <= "00100100"; --E

        wait until getchar = '1';
        wait for CLK_PERIOD * 3;
        char <= "00100011"; --D
        
        wait until getchar = '1';
        wait for CLK_PERIOD * 3;
        char <= "00101001"; --Space
        
        wait until getchar = '1';
        wait for CLK_PERIOD * 3;
        char <= "00011110"; --1
        
        wait until getchar = '1';
        wait for CLK_PERIOD * 3;
        char <= "00101001"; --Space
        
        wait until getchar = '1';
        wait for CLK_PERIOD * 3;
        char <= "01000100"; --O
        
        wait until getchar = '1';
        wait for CLK_PERIOD * 3;
        char <= "00110001"; --N
        
        wait until getchar = '1';
        wait for CLK_PERIOD * 3;
        char <= "01011010"; --Enter

		--for i in 0 to 2 loop
    end process;

end architecture;

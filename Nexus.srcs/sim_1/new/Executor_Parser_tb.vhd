library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Executor_Parser_tb is
--  Port ( );
end Executor_Parser_tb;

architecture Behavioral of Executor_Parser_tb is
    component Executor_Parser is
	Port ( 
		clock	: in std_logic;
		reset	: in std_logic;
		symbol	: in std_logic_vector(7 downto 0);
		enable	: in std_logic;
		parsed	: inout std_logic;
		command	: inout std_logic_vector(1 downto 0);
		led_id	: out std_logic_vector(3 downto 0);
		cled_id	: out std_logic;
		seg_id	: out std_logic;
		onoff	: out std_logic;
		value	: out std_logic_vector(15 downto 0);
		newchar : out std_logic;
		isready	: in std_logic
	);
end component;

signal clock, reset, enable, parsed, isready : std_logic := '0';
signal symbol : std_logic_vector(7 downto 0) := "00000000";

signal cled_id, seg_id, onoff, newchar: std_logic;
signal value : std_logic_vector(15 downto 0);
signal led_id : std_logic_vector(3 downto 0);
signal command : std_logic_vector(1 downto 0);

constant CLK_PERIOD : time := 10 ns;

begin
    UUT : Executor_Parser
        port map(
            clock   => clock,
			reset	=> reset,
			symbol	=> symbol,
			enable	=> enable,
			parsed	=> parsed,
			command	=> command,
			led_id  => led_id, 
			cled_id	=> cled_id,
			seg_id	=> seg_id,
			onoff	=> onoff,
			value	=> value,
			newchar => newchar,
			isready => isready
		);
	
	CLK_STIMULUS : process
	begin
		clock <= not clock;
		wait for CLK_PERIOD/2;
	end process;
	
	OTH_STIMULI : process
	begin
		-- Reset
		reset    <= '1';
		wait for CLK_PERIOD * 3;
		reset <= '0';

        enable <= '1';
        symbol <= "01001011"; --L
        isready <= '1';
        wait for CLK_PERIOD * 3;
        symbol <= "00100100"; --E
        wait for CLK_PERIOD * 3;
        symbol <= "00100011"; --D
        wait for CLK_PERIOD * 3;
        symbol <= "00101001"; --Space
        wait for CLK_PERIOD * 3;
        symbol <= "00011110"; --1
        wait for CLK_PERIOD * 3;
        symbol <= "00101001"; --Space
        wait for CLK_PERIOD * 3;
        symbol <= "01000100"; --O
        wait for CLK_PERIOD * 3;
        symbol <= "00110001"; --N
        wait for CLK_PERIOD * 3;
        symbol <= "01011010"; --Enter
        wait for CLK_PERIOD * 3;
		--for i in 0 to 2 loop
			
		--end loop;

		wait; -- ?akaj neskon?no dolgo      
	end process;


end Behavioral;

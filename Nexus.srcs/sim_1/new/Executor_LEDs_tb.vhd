library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Executor_LEDs_tb is
--  Port ( );
end entity;

architecture Behavioral of Executor_LEDs_tb is

    component Executor_LEDs is
		Port (
			clock	: in std_logic;
			reset	: in std_logic;
			enable	: in std_logic; -- Signals when to write to an LED
			state	: in std_logic; -- Whether LED should be on (1) or off (0)
			id		: in std_logic_vector (3 downto 0); -- LED to write to
			led		: out std_logic_vector (15 downto 0) -- Array of LEDs
		);
	end component;

    constant CLK_PERIOD : time := 10 ns;

	signal clock, reset, enable, state : std_logic := '0';
	signal id : std_logic_vector (3 downto 0) := "0000";
	signal led : std_logic_vector (15 downto 0);

begin

    UUT : Executor_LEDs
    port map(
		clock => clock,
		reset => reset,
		enable => enable,
		state => state,
		id => id,
		led => led
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

		for i in 0 to 2 loop
			-- Mirovanje 
			enable <= '1';
			wait for CLK_PERIOD;
			state <= '1';
			id <= "0001";

		end loop;

		wait; -- èakaj neskonèno dolgo      
	end process;

end architecture;
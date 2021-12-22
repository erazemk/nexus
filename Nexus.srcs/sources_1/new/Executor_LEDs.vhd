library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Executor_LEDs is

	Port (
		clock	: in std_logic;
		reset	: in std_logic;
		enable	: in std_logic; -- Signals when to write to an LED
		state	: in std_logic; -- Whether LED should be on (1) or off (0)
		id		: in std_logic_vector (3 downto 0); -- LED to write to
		led		: out std_logic_vector (15 downto 0) -- Array of LEDs
	);

end Executor_LEDs;

architecture Behavioral of Executor_LEDs is

begin

	process(reset)
	begin

		if reset = '1' then
			led <= (others => '1');
		end if;

	end process;

	process(clock)
	begin
		-- Write to LED
		if rising_edge(clock) and enable = '1' then
			-- 'not state' because LED == off when state == 1
			led(to_integer(unsigned(id))) <= not state;
		end if;
	
	end process;

end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Executor_RGB_LEDs is

	Port (
		clock	: in std_logic;
		reset	: in std_logic;
		enable	: in std_logic; -- Signals when to write to an LED
		state	: in std_logic; -- Whether LED should be on (1) or off (0)
		id		: in std_logic; -- ID of LED to write to
		color	: in std_logic_vector (1 downto 0); -- Color for the LED, either 0 - White, 1 - Red, 2 - Green or 3 - Blue
		cled0	: out std_logic_vector (2 downto 0); -- RGB LED 0
		cled1	: out std_logic_vector (2 downto 0) -- RGB LED 1
	);

end entity;

architecture Behavioral of Executor_RGB_LEDs is
	
	signal led	: std_logic_vector (2 downto 0); -- Connects the selected LED

begin

	process(clock, enable, reset, state)
	begin
		
		if rising_edge(clock) then
			if reset = '1' then
				cled0 <= (others => '0');
				cled1 <= (others => '0');
			elsif enable = '1' then
				-- Select which LED to address
				if id = '0' then
					cled0 <= led;
				else
					cled1 <= led;
				end if;
			
				if state = '1' then
					case color is
						when "01" => led <= "100";
						when "10" => led <= "010";
						when "11" => led <= "001";
						when others => led <= "111";
					end case;
				else
					led <= "000";
				end if;
			end if;
		end if;
		
	end process;

end architecture;

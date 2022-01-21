library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Anode_Switcher is

	Port (
		clock	: in std_logic;
		reset	: in std_logic;
		enable	: in std_logic;
		state1	: in std_logic;
		state2	: in std_logic;
		anode	: out std_logic_vector (7 downto 0)
	);

end Anode_Switcher;

architecture Behavioral of Anode_Switcher is

	signal count : unsigned (2 downto 0) := (others => '0');

begin

	process(reset, clock, enable)
	begin

		if reset = '1' then
			anode <= "11111111";
			count <= (others => '0');
		end if;

		if rising_edge(clock) and enable = '1' then
			if state1 = '1' or state2 = '1' then
				if (count = 8) then
					count <= (others => '0');
				else
					if (count = 0) then
						anode <= "11111110";
					elsif (count = 1) then
						anode <= "11111101";
					elsif (count = 2) then
						anode <= "11111011";
					elsif (count = 3) then
						anode <= "11110111";
					elsif (count = 4) then
						anode <= "11101111";
					elsif (count = 5) then
						anode <= "11011111";
					elsif (count = 6) then
						anode <= "10111111";
					elsif (count = 7) then
						anode <= "01111111";
					end if;
					
					count <= count + 1;
				end if;
			else
				-- Turn off display
				anode <= "11111111";
				count <= (others => '0');
			end if;
		end if;

	end process;

end Behavioral;

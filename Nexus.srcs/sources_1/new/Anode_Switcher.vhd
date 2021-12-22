library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Anode_Switcher is

	Port (
		clock	: in std_logic;
		reset	: in std_logic;
		enable	: in std_logic;
		state	: in std_logic;
		anode	: out std_logic_vector (3 downto 0)
	);

end Anode_Switcher;

architecture Behavioral of Anode_Switcher is

	signal count : unsigned (1 downto 0) := (others => '0');

begin

	process(reset)
	begin
		
		if reset = '1' then
			anode <= "1111";
			count <= (others => '0');
		end if;
		
	end process;

	process(clock, enable, state)
	begin

		if rising_edge(clock) and enable = '1' then
			if state = '1' then
				if (count = 4) then
					count <= (others => '0');
				else
					if (count = 0) then
						anode <= "1110";
					elsif (count = 1) then
						anode <= "1101";
					elsif (count = 2) then
						anode <= "1011";
					elsif (count = 3) then
						anode <= "0111";
					end if;
					
					count <= count + 1;
				end if;
			else
				-- Turn off display
				anode <= "1111";
				count <= (others => '0');
			end if;
		end if;

	end process;

end Behavioral;

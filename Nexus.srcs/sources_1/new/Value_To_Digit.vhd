library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Value_To_Digit is

	Port (
		value	: in std_logic_vector (31 downto 0);
		anode	: in std_logic_vector (7 downto 0);
		digit	: out std_logic_vector (3 downto 0)
	);

end Value_To_Digit;

architecture Behavioral of Value_To_Digit is

begin

	process (value, anode)
	begin

		case anode is
			when "11111110" => digit <= value(3 downto 0);
			when "11111101" => digit <= value(7 downto 4);
			when "11111011" => digit <= value(11 downto 8);
			when "11110111" => digit <= value(15 downto 12);
			when "11101111" => digit <= value(19 downto 16);
			when "11011111" => digit <= value(23 downto 20);
			when "10111111" => digit <= value(27 downto 24);
			when "01111111" => digit <= value(31 downto 28);
			when others => digit <= "1111";
		end case;

	end process;

end Behavioral;

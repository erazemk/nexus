library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Value_To_Digit is

	Port (
		value	: in std_logic_vector (15 downto 0);
		anode	: in std_logic_vector (3 downto 0);
		digit	: out std_logic_vector (3 downto 0)
	);

end Value_To_Digit;

architecture Behavioral of Value_To_Digit is

begin

	process (value, anode)
	begin

		case anode is
			when "1110" => digit <= value(3 downto 0);
			when "1101" => digit <= value(7 downto 4);
			when "1011" => digit <= value(11 downto 8);
			when "0111" => digit <= value(15 downto 12);
			when others => digit <= "1111";
		end case;

	end process;

end Behavioral;

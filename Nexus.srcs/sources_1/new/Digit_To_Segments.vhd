library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Digit_To_Segments is

	Port (
		digit	: in std_logic_vector (3 downto 0); -- Digit means 0-9 or A-F
		cathode	: out std_logic_vector (7 downto 0)
	);

end entity;

architecture Behavioral of Digit_To_Segments is

begin

	process(digit)
	begin

		case digit is
			when "0000" => cathode <= "11000000";
			when "0001" => cathode <= "11111001";
			when "0010" => cathode <= "10100100";
			when "0011" => cathode <= "10110000";
			when "0100" => cathode <= "10011001";
			when "0101" => cathode <= "10010010";
			when "0110" => cathode <= "10000010";
			when "0111" => cathode <= "11111000";
			when "1000" => cathode <= "10000000";
			when "1001" => cathode <= "10010000";
			when "1010" => cathode <= "10001000";
			when "1011" => cathode <= "10000011";
			when "1100" => cathode <= "11000110";
			when "1101" => cathode <= "10100001";
			when "1110" => cathode <= "10000110";
			when others => cathode <= "10001110";
		end case;

	end process;

end architecture;

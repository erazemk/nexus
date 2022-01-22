library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity VGA_Character_To_Pixel is
    Port (
        chargot     : in std_logic;
        id          : in std_logic_vector (7 downto 0);
        charready   : out std_logic;
        matrix      : out std_logic_vector (16 * 9 - 1 downto 0) := (others => '0')
    );
end entity;

architecture Behavioral of VGA_Character_To_Pixel is
    
begin

    process(chargot, id)
    begin
        case chargot is
            when '0' => 
                charready <= '1';
                case id is 
                    when "00000000" =>
                        matrix <= (others => '0');
                    when others =>
                        matrix(8 downto 0)      <= "000000000";
                        matrix(17 downto 9)     <= "000010000";
                        matrix(26 downto 18)    <= "000111000";
                        matrix(35 downto 27)    <= "000111000";
                        matrix(44 downto 36)    <= "001101100";
                        matrix(53 downto 45)    <= "011000110";
                        matrix(62 downto 54)    <= "011111110";
                        matrix(71 downto 63)    <= "110000011";
                        matrix(80 downto 72)    <= "110000011";
                        matrix(89 downto 81)    <= "000000000";
                        matrix(98 downto 90)    <= "111101000";
                        matrix(107 downto 99)   <= "111101000";
                        matrix(116 downto 108)  <= "111101000";
                        matrix(125 downto 117)  <= "111101000";
                        matrix(134 downto 126)  <= "111101000";
                        matrix(143 downto 135)  <= "111101000";   
                end case;
            when others => 
                charready <= '0';
        end case;
    end process;

end Behavioral;

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
                        matrix <= (others => '1');   
                end case;
            when others => 
                charready <= '0';
                matrix <= matrix;
        end case;
    end process;

end Behavioral;

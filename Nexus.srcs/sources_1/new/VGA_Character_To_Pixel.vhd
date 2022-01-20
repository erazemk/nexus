library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity VGA_Character_To_Pixel is
    Port (
        id: in  std_logic_vector (7 downto 0);
        matrix: out std_logic_vector (16*9-1 downto 0)
    );
end entity;

architecture Behavioral of VGA_Character_To_Pixel is
    
begin

with id select matrix <=

    (others => '0') when "00000000",
    (others => '1') when others;


end Behavioral;


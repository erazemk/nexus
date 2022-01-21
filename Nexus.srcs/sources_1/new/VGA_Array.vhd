library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity VGA_Array is
    Port ( 
        column	: in unsigned (9 downto 0);
		row 	: in unsigned (9 downto 0);
		matrix	: in std_logic_vector (16*9-1 downto 0);
		red		: out std_logic_vector (3 downto 0);
		green	: out std_logic_vector (3 downto 0);
		blue	: out std_logic_vector (3 downto 0)
    );
end VGA_Array;

architecture Behavioral of VGA_Array is
--Višina ene črke je 16px
type memory is array (0 to 15) of std_logic_vector(0 to 639);
    signal RAM : memory; --:= (others => (others => '0'))
begin


end Behavioral;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity VGA is

	Port (
		clock	: in std_logic;
		reset	: in std_logic;
		hsync	: out std_logic;
		vsync	: out std_logic;
		newchar	: out std_logic;
		red		: out std_logic_vector (3 downto 0);
		green	: out std_logic_vector (3 downto 0);
		blue	: out std_logic_vector (3 downto 0)
	);

end VGA;

architecture Behavioral of VGA is

begin


end Behavioral;

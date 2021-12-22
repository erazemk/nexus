library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

entity Keyboard is

	Port (
		clock	: in std_logic;
		reset	: in std_logic;
		kclk	: in  std_logic;
		kdata	: in  std_logic;
		data	: out std_logic_vector (8 downto 0);
		eot		: out std_logic;
		enter	: out std_logic
	);

end Keyboard;

architecture Behavioral of Keyboard is

begin


end Behavioral;

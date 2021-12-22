library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Executor is

	Port (
		clock	: in std_logic;
		reset	: in std_logic;
		enter	: in std_logic;
		data	: in std_logic_vector (7 downto 0);
		enable	: out std_logic;
		led		: out std_logic_vector (15 downto 0);
		an		: out std_logic_vector (7 downto 0);
		ca		: out std_logic_vector (7 downto 0);
		cled0	: out std_logic_vector (2 downto 0);
		cled1	: out std_logic_vector (2 downto 0)
	);

end Executor;

architecture Behavioral of Executor is

begin


end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

entity Executor_7_Segment_Display is

	Port (
		clock	: in std_logic;
		reset	: in std_logic;
		enable	: in std_logic; -- Signals when to write to a display
		state	: in std_logic; -- Whether display should be on (1) or off (0)
		id		: in std_logic; -- Display to write to
		value	: in std_logic_vector (15 downto 0); -- Value to write to display
		cathode	: out std_logic_vector (7 downto 0);
		anode	: out std_logic_vector (7 downto 0)
	);

end Executor_7_Segment_Display;

architecture Behavioral of Executor_7_Segment_Display is

begin


end Behavioral;

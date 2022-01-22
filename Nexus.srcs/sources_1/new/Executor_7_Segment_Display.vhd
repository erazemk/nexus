library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Executor_7_Segment_Display is

	Port (
		clock	: in std_logic;
		reset	: in std_logic;
		enable	: in std_logic; -- Signals when to write to a display
		state1	: in std_logic; -- Whether display should be on (1) or off (0)
		state2	: in std_logic;
		value	: in std_logic_vector (31 downto 0); -- Value to write to display
		cathode	: out std_logic_vector (7 downto 0);
		anode	: out std_logic_vector (7 downto 0)
	);

end entity;

architecture Behavioral of Executor_7_Segment_Display is

	component Prescaler is
		Generic (
			max_value	: integer := 255
		);
		Port (
			clock	: in std_logic;
			reset	: in std_logic;
			enable	: out std_logic
		);
	end component;

	component Anode_Switcher is
		Port (
			clock	: in std_logic;
			reset	: in std_logic;
			enable	: in std_logic;
			state1	: in std_logic;
			state2	: in std_logic;
			anode	: out std_logic_vector (7 downto 0)
		);
	end component;
	
	component Digit_To_Segments is
		Port (
			digit	: in std_logic_vector (3 downto 0); -- Digit means 0-9 or A-F
			cathode	: out std_logic_vector (7 downto 0)
		);
	end component;
	
	component Value_To_Digit is
		Port (
			value	: in std_logic_vector (31 downto 0);
			anode	: in std_logic_vector (7 downto 0);
			digit	: out std_logic_vector (3 downto 0)
		);
	end component;
	
	-- Signals
	signal sig_enable	: std_logic;
	signal sig_digit	: std_logic_vector (3 downto 0);
	signal sig_anode	: std_logic_vector (7 downto 0);

begin

	sig_enable <= enable;
	anode <= sig_anode;

	module_prescaler: Prescaler
	generic map (
		max_value => 255
	)
	port map (
		clock => clock,
		reset => reset,
		enable => sig_enable
	);

	module_anode_switcher: Anode_Switcher
	port map (
		clock => clock,
		reset => reset,
		enable => sig_enable,
		state1 => state1,
		state2 => state2,
		anode => sig_anode
	);

	module_digit_to_segments: Digit_To_Segments
	port map (
		digit => sig_digit,
		cathode => cathode
	);

	module_value_to_digit: Value_To_Digit
	port map (
		value => value,
		anode => sig_anode,
		digit => sig_digit
	);

end architecture;

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
		anode	: out std_logic_vector (7 downto 0);
		cathode	: out std_logic_vector (7 downto 0);
		cled0	: out std_logic_vector (2 downto 0);
		cled1	: out std_logic_vector (2 downto 0)
	);

end Executor;

architecture Behavioral of Executor is

	component Executor_LEDs is
		Port (
			clock	: in std_logic;
			reset	: in std_logic;
			enable	: in std_logic; -- Signals when to write to an LED
			state	: in std_logic; -- Whether LED should be on (1) or off (0)
			id		: in std_logic_vector (3 downto 0); -- LED to write to
			led		: out std_logic_vector (15 downto 0) -- Array of LEDs
		);
	end component;
	
	component Executor_RGB_LEDs is
		Port (
			clock	: in std_logic;
			reset	: in std_logic;
			enable	: in std_logic; -- Signals when to write to an LED
			state	: in std_logic; -- Whether LED should be on (1) or off (0)
			id		: in std_logic; -- ID of LED to write to
			color	: in std_logic_vector (2 downto 0); -- Color for the LED, either 0 - White, 1 - Red, 2 - Green or 3 - Blue
			cled0	: out std_logic_vector (2 downto 0); -- RGB LED 0
			cled1	: out std_logic_vector (2 downto 0) -- RGB LED 1
		);
	end component;
	
	component Executor_7_Segment_Display is
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
	end component;
	
	-- Shared signals
	signal sig_enable		: std_logic;
	signal sig_state		: std_logic;
	
	-- LED signals
	signal sig_led_id		: std_logic_vector (3 downto 0);
	
	-- RGB LED signals
	signal sig_rgb_id		: std_logic;
	signal sig_rgb_color	: std_logic_vector (2 downto 0);

	-- 7-segment display signals
	signal sig_seg_id		: std_logic; -- Display id, either 1 (left display) or 0 (right display)
	signal sig_seg_value	: std_logic_vector (15 downto 0); -- Binary value for one of the displays

begin

	module_led: Executor_LEDs
	port map (
		clock => clock,
		reset => reset,
		enable => sig_enable,
		state => sig_state,
		id => sig_led_id,
		led => led
	);
	
	module_rgb_led: Executor_RGB_LEDs
	port map (
		clock => clock,
		reset => reset,
		enable => sig_enable,
		state => sig_state,
		id => sig_rgb_id,
		color => sig_rgb_color
	);
	
	module_seven_segment_display: Executor_7_Segment_Display
	port map (
		clock => clock,
		reset => reset,
		enable => sig_enable,
		state => sig_state,
		id => sig_seg_id,
		value => sig_seg_value,
		cathode => cathode,
		anode => anode
	);

end Behavioral;

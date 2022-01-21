library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Executor is

	Port (
		clock	: in std_logic;
		reset	: in std_logic;
		enter	: inout std_logic;
		data	: in std_logic_vector (7 downto 0);
		enable	: inout std_logic;
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
			color	: in std_logic_vector (1 downto 0); -- Color for the LED, either 0 - White, 1 - Red, 2 - Green or 3 - Blue
			cled0	: out std_logic_vector (2 downto 0); -- RGB LED 0
			cled1	: out std_logic_vector (2 downto 0) -- RGB LED 1
		);
	end component;
	
	component Executor_7_Segment_Display is
		Port (
			clock	: in std_logic;
			reset	: in std_logic;
			enable	: in std_logic; -- Signals when to write to a display
			state1	: in std_logic; -- Whether display should be on (1) or off (0)
			state2	: in std_logic; -- Whether display should be on (1) or off (0)
			-- id		: in std_logic; -- Display to write to
			value	: in std_logic_vector (31 downto 0); -- Value to write to display
			cathode	: out std_logic_vector (7 downto 0);
			anode	: out std_logic_vector (7 downto 0)
		);
	end component;

	component Executor_Parser is
		Port ( 
			clock	: in std_logic;
			reset	: in std_logic;
			symbol	: in std_logic_vector(7 downto 0);
			enable	: in std_logic;
			parsed	: inout std_logic;
			command	: inout std_logic_vector(1 downto 0);
			led_id	: out std_logic_vector(3 downto 0);
			cled_id	: out std_logic;
			seg_id	: out std_logic;
			onoff	: out std_logic;
			value	: out std_logic_vector(15 downto 0);
			newchar	: inout std_logic
		);
	end component;
	
	-- Shared signals
	signal sig_state		: std_logic;
	signal sig_parsed		: std_logic; -- Enabled when parser has parsed line
	--signal sig_parser_en	: std_logic; -- Signals to the parser to start parsing
	signal sig_command		: std_logic_vector(1 downto 0);
	signal sig_id			: std_logic_vector(3 downto 0);
	signal sig_value		: std_logic_vector(15 downto 0);
	--signal sig_newchar		: std_logic;
	
	-- LED signals
	signal sig_led_enable	: std_logic;
	signal sig_led_id		: std_logic_vector (3 downto 0);
	
	-- RGB LED signals
	signal sig_rgb_enable	: std_logic;
	signal sig_rgb_id		: std_logic;
	signal sig_rgb_color	: std_logic_vector (1 downto 0);

	-- 7-segment display signals
	signal sig_seg_enable	: std_logic;
	signal sig_seg1_state	: std_logic;
	signal sig_seg2_state	: std_logic;
	signal sig_seg_id		: std_logic; -- Display id, either 1 (left display) or 0 (right display)
	signal sig_seg_value	: std_logic_vector (31 downto 0); -- Binary value for one of the displays

	signal sig_prev_enable	: std_logic;

begin

	sig_rgb_color <= sig_value(1 downto 0);

	GET_CHAR : process(clock)
	begin
		if rising_edge(clock) then
			--if sig_newchar = '1' then
			--	enable <= '1';
			--end if;

			-- if enter = '1' then
			-- 	sig_parser_en <= '1';
			-- end if;

			if sig_parsed = '1' then
				enter <= '0';
				sig_parsed <= '0';
			end if;
			
			if enter = '1' then
				case sig_command is
					-- TODO: Poglej kdaj moraš resetirat enable
					when "00" => sig_led_enable <= '1';
					when "01" => sig_rgb_enable <= '1';
					when "10" =>
						if sig_seg_id = '0' then
							sig_seg1_state <= sig_state;
							sig_seg_value(15 downto 0) <= sig_value;
						else
							sig_seg2_state <= sig_state;
							sig_seg_value(31 downto 16) <= sig_value;
						end if;

						sig_seg_enable <= '1';
					when others => sig_led_enable <= '1';
				end case;
			end if;
		end if;

	end process;

	module_led: Executor_LEDs
	port map (
		clock => clock,
		reset => reset,
		enable => sig_led_enable,
		state => sig_state,
		id => sig_led_id,
		led => led
	);
	
	module_rgb_led: Executor_RGB_LEDs
	port map (
		clock => clock,
		reset => reset,
		enable => sig_rgb_enable,
		state => sig_state,
		id => sig_rgb_id,
		color => sig_rgb_color,
		cled0 => cled0,
		cled1 => cled1
	);
	
	module_seven_segment_display: Executor_7_Segment_Display
	port map (
		clock => clock,
		reset => reset,
		enable => sig_seg_enable,
		state1 => sig_seg1_state,
		state2 => sig_seg2_state,
		value => sig_seg_value,
		cathode => cathode,
		anode => anode
	);

	module_parser: Executor_Parser
	port map (
		clock => clock,
		reset => reset,
		symbol => data,
		enable => enter,
		parsed => sig_parsed,
		command => sig_command,
		led_id => sig_led_id,
		cled_id => sig_rgb_id,
		seg_id => sig_seg_id,
		onoff => sig_state,
		value => sig_value,
		newchar => enable --sig_newchar
	);

end Behavioral;

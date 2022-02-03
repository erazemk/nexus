library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Executor is

	Port (
		clock			: in std_logic;
		reset			: in std_logic;
		enter			: in std_logic; -- Signals that a new line has been written
		enter_confirm	: out std_logic := '0';
		data			: in std_logic_vector (7 downto 0); -- Character read from the buffer
		data_index		: out std_logic_vector(8 downto 0);
		enable			: out std_logic; -- Signals that a new character should be sent to data
		isready			: in std_logic;
		led				: out std_logic_vector (15 downto 0); -- LEDs
		cled0			: out std_logic_vector (2 downto 0); -- RGB LED 0
		cled1			: out std_logic_vector (2 downto 0) -- RGB LED 1
	);

end entity;

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
			color	: in std_logic_vector (2 downto 0); -- Color for the LED, either 0 - Red, 1 - Green or 2 - Blue, 3 - White
			cled0	: out std_logic_vector (2 downto 0); -- RGB LED 0
			cled1	: out std_logic_vector (2 downto 0) -- RGB LED 1
		);
	end component;

	component Executor_Parser is
		Port ( 
			clock			: in std_logic;
			reset			: in std_logic;
			char			: in std_logic_vector(7 downto 0);
			start_parsing	: in std_logic;
			parsed_confirm	: in std_logic;
			char_is_ready	: in std_logic;
			parsed			: out std_logic := '0';
			command			: out std_logic := '0';
			value			: out std_logic_vector(2 downto 0) := (others => '0');
			id				: out std_logic_vector(3 downto 0) := (others => '0');
			onoff			: out std_logic := '0';
			wanted_char_at	: out std_logic_vector(8 downto 0) := (others => '0'); 
			want_new_char	: out std_logic
		);
	end component;
	
	-- Shared signals
	signal sig_state		: std_logic := '0'; -- Whether a module is enabled or disabled (e.g. LED = ON/OFF)
	signal sig_parsed		: std_logic := '0'; -- Enabled when parser has parsed line
	signal sig_command		: std_logic := '0'; -- 0 = LED, 1 = RGB LED
	signal sig_id			: std_logic_vector(3 downto 0) := (others => '0'); -- ID of module element (e.g. LED with ID 1)
	signal sig_value		: std_logic_vector(2 downto 0) := (others => '0'); -- Used for RGB LEDs (e.g. CLED 1 R[ed])
	signal parsed_confirm	: std_logic := '0';
	
	-- LED signals
	signal sig_led_enable	: std_logic := '0';
	signal sig_led_id		: std_logic_vector (3 downto 0) := (others => '0');
	
	-- RGB LED signals
	signal sig_rgb_enable	: std_logic := '0';
	signal sig_rgb_id		: std_logic := '0';

begin

	GET_CHAR : process(clock)
	begin
		if rising_edge(clock) then
			-- No need for reset, since it's handled in submodules
			
			-- Reset enter_confirm
			if enter = '0' then
				enter_confirm <= '0';
			end if;
			
			-- Reset parsed confirmation
			if sig_parsed = '0' then
				parsed_confirm <= '0';
				sig_led_enable <= '0';
				sig_rgb_enable <= '0';
			end if;

			if sig_parsed = '1' then
				enter_confirm <= '1';
				parsed_confirm <= '1'; -- Set parsed confirmation

				if sig_command = '0' then -- LED command
					sig_led_enable <= '1';
					sig_led_id <= sig_id;
				else -- CLED command
					sig_rgb_enable <= '1';
					sig_rgb_id <= sig_id(0);
				end if;
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
		color => sig_value,
		cled0 => cled0,
		cled1 => cled1
	);

	module_parser: Executor_Parser
	port map (
		clock => clock,
		reset => reset,
		char => data,
		start_parsing => enter,
		parsed_confirm => parsed_confirm,
		char_is_ready => isready,
		parsed => sig_parsed,
		value => sig_value,
		command => sig_command,
		id => sig_id,
		onoff => sig_state,
		wanted_char_at => data_index,
		want_new_char => enable
	);

end architecture;

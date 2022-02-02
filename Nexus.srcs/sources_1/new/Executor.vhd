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
		anode			: out std_logic_vector (7 downto 0) := (others => '1'); -- 7-seg anode
		cathode			: out std_logic_vector (7 downto 0); -- 7-seg cathode
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
	signal parsed_confirm	: std_logic := '0';
	
	-- LED signals
	signal sig_led_enable	: std_logic := '0';
	signal sig_led_id		: std_logic_vector (3 downto 0) := (others => '0');
	

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
			end if;

			if sig_parsed = '1' then
				enter_confirm <= '1';
				parsed_confirm <= '1'; -- Set parsed confirmation
				sig_led_enable <= '1';
				sig_led_id <= sig_id;
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
	

	module_parser: Executor_Parser
	port map (
		clock => clock,
		reset => reset,
		char => data,
		start_parsing => enter,
		parsed_confirm => parsed_confirm,
		char_is_ready => isready,
		parsed => sig_parsed,
		command => sig_command,
		id => sig_id,
		onoff => sig_state,
		wanted_char_at => data_index,
		want_new_char => enable
	);

end architecture;

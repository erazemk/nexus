library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Nexus is

	Port (
		-- Keyboard I/O
		KCLK	: in std_logic;
		KDATA	: in std_logic;

		-- VGA I/O
		VGA_HS	: out std_logic;
		VGA_VS	: out std_logic;
		VGA_R	: out std_logic_vector (3 downto 0);
		VGA_G	: out std_logic_vector (3 downto 0);
		VGA_B	: out std_logic_vector (3 downto 0);

		-- Executor I/O
		LED		: out std_logic_vector (15 downto 0);
		AN		: inout std_logic_vector (7 downto 0);
		CA		: out std_logic_vector (7 downto 0);
		CLED0	: out std_logic_vector (2 downto 0);
		CLED1	: out std_logic_vector (2 downto 0);

		-- Shared I/O
		CLOCK	: in std_logic;
		RESET	: in std_logic
	);

end Nexus;

architecture Behavioral of Nexus is

	component Executor is
		Port (
			clock	: in std_logic;
			reset	: in std_logic;
			enter	: in std_logic; -- Signals that a new line has been written
			data	: in std_logic_vector (7 downto 0); -- Character read from the buffer
			enable	: out std_logic; -- Signals that a new character should be sent to data
			led		: out std_logic_vector (15 downto 0); -- LEDs
			anode	: out std_logic_vector (7 downto 0); -- 7-seg anode
			cathode	: out std_logic_vector (7 downto 0); -- 7-seg cathode
			cled0	: out std_logic_vector (2 downto 0); -- RGB LED 0
			cled1	: out std_logic_vector (2 downto 0) -- RGB LED 1
		);
	end component;

	component VGA is
		Port (
			clock	: in std_logic;
			reset	: in std_logic;
			hsync	: out std_logic;
			vsync	: out std_logic;
			newchar	: out std_logic; -- Requests a new character from the buffer
			red		: out std_logic_vector (3 downto 0);
			green	: out std_logic_vector (3 downto 0);
			blue	: out std_logic_vector (3 downto 0)
		);
	end component;

	component Keyboard is
		Port (
			clock	: in std_logic;
			reset	: in std_logic;
			kclk	: in std_logic;
			kdata	: in std_logic;
			data	: out std_logic_vector (8 downto 0); -- Character from keyboard
			eot		: out std_logic; -- Signals that a new character was written
			enter	: out std_logic -- Signals that a new line was written
		);
	end component;
	
	-- Inverse of RESET
	signal SIG_RESET			: std_logic;

	-- Buffer (71 8-bit characters * 30 rows = 2130 elements)
	type Buffer_type is array (0 to 2130) of std_logic_vector (7 downto 0);
	signal CODE_BUFFER			: Buffer_type;

	-- VGA signals
	signal SIG_VGA_CHAR			: std_logic_vector (7 downto 0);
	signal SIG_VGA_COUNTER		: unsigned (11 downto 0);
	signal SIG_VGA_NEWCHAR		: std_logic;

	-- Keyboard signals
	signal SIG_KEYBOARD_CHAR	: std_logic_vector (7 downto 0);
	signal SIG_KEYBOARD_COUNTER	: unsigned (11 downto 0);
	signal SIG_KEYBOARD_ENTER	: std_logic;
	signal SIG_KEYBOARD_EOT		: std_logic;

	-- Executor signals
	signal SIG_EXECUTOR_CHAR	: std_logic_vector (7 downto 0);
	signal SIG_EXECUTOR_COUNTER	: unsigned (11 downto 0);
	signal SIG_EXECUTOR_ENABLE	: std_logic;

begin

	SIG_RESET <= not RESET;
	
	-- Reset all counters and clear buffer
	reset_proc: process(SIG_RESET)
	begin
		if SIG_RESET = '1' then
			SIG_VGA_COUNTER <= (others => '0');
			SIG_KEYBOARD_COUNTER <= (others => '0');
			SIG_EXECUTOR_COUNTER <= (others => '0');
			CODE_BUFFER <= (others => (others => '0'));
		end if;
	end process;

	-- Send character to VGA module and increment counter
	vga_proc: process(CLOCK)
	begin
		if (rising_edge(CLOCK) and SIG_VGA_NEWCHAR = '1') then
			SIG_VGA_CHAR <= CODE_BUFFER(to_integer(SIG_VGA_COUNTER));
			SIG_VGA_COUNTER <= SIG_VGA_COUNTER + 1;
		end if;
	end process;
	
	-- Read character from keyboard module and increment counter
	keyboard_proc: process(CLOCK)
	begin
		if rising_edge(CLOCK) and SIG_KEYBOARD_EOT = '1' then
			CODE_BUFFER(to_integer(SIG_KEYBOARD_COUNTER)) <= SIG_KEYBOARD_CHAR;
			SIG_KEYBOARD_COUNTER <= SIG_KEYBOARD_COUNTER + 1;
			
			-- TODO: Shift buffer when it's full
			-- if SIG_KEYBOARD_COUNTER = 2130 then
			--		CODE_BUFFER(0 to 2130) <= CODE_BUFFER(71 to 2130);
			-- end if;
			
		end if;
	end process;
	
	-- Send character to executor module and increment counter
	executor_proc: process(CLOCK)
	begin
		if rising_edge(CLOCK) and SIG_EXECUTOR_ENABLE = '1' then
			SIG_EXECUTOR_CHAR <= CODE_BUFFER(to_integer(SIG_EXECUTOR_COUNTER));
			SIG_EXECUTOR_COUNTER <= SIG_EXECUTOR_COUNTER + 1;
		end if;
	end process;

	module_executor: Executor
	port map (
		clock => CLOCK,
		reset => SIG_RESET,
		enter => SIG_KEYBOARD_ENTER,
		enable => SIG_EXECUTOR_ENABLE,
		data => SIG_EXECUTOR_CHAR,
		led => LED,
		anode => AN,
		cathode => CA,
		cled0 => CLED0,
		cled1 => CLED1
	);

	module_vga: VGA
	port map (
		clock => CLOCK,
		reset => SIG_RESET,
		hsync => VGA_HS,
		vsync => VGA_VS,
		newchar => SIG_VGA_NEWCHAR,
		red => VGA_R,
		green => VGA_G,
		blue => VGA_B
	);

	module_keyboard: Keyboard
	port map (
		clock => CLOCK,
		reset => SIG_RESET,
		kclk => KCLK,
		kdata => KDATA,
		data => SIG_KEYBOARD_CHAR,
		eot => SIG_KEYBOARD_EOT,
		enter => SIG_KEYBOARD_ENTER
	);

end Behavioral;
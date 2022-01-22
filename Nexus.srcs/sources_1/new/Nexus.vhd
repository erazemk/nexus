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
		AN		: out std_logic_vector (7 downto 0);
		CA		: out std_logic_vector (7 downto 0);
		CLED0	: out std_logic_vector (2 downto 0);
		CLED1	: out std_logic_vector (2 downto 0);

		-- Shared I/O
		CLOCK	: in std_logic;
		RESET	: in std_logic
	);

end entity;

architecture Behavioral of Nexus is

	component Executor is
		Port (
			clock	: in std_logic;
			reset	: in std_logic;
			enter	: inout std_logic; -- Signals that a new line has been written
			data	: in std_logic_vector (7 downto 0); -- Character read from the buffer
			enable	: inout std_logic; -- Signals that a new character should be sent to data
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
			char	: in std_logic_vector (7 downto 0);
			chargot : in std_logic;
			getchar	: out std_logic;
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
			data	: out std_logic_vector (7 downto 0); -- Character from keyboard
			eot		: out std_logic -- Signals that a new character was written
		);
	end component;
	
	component Code_Buffer is
		Port (
			clka		: IN STD_LOGIC;
			rsta		: IN STD_LOGIC;
			wea			: IN STD_LOGIC_VECTOR(0 DOWNTO 0);
			addra		: IN STD_LOGIC_VECTOR(8 DOWNTO 0);
			dina		: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			douta		: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			clkb		: IN STD_LOGIC;
			web			: IN STD_LOGIC_VECTOR(0 DOWNTO 0);
			addrb		: IN STD_LOGIC_VECTOR(8 DOWNTO 0);
			dinb		: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			doutb		: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			rsta_busy	: OUT STD_LOGIC;
			rstb_busy	: OUT STD_LOGIC
		);
	end component;
	
	-- Inverse of RESET
	signal SIG_RESET			: std_logic;
	
	-- Code buffer signals
	signal SIG_BUFFER_WE		: std_logic_vector(0 downto 0);
	signal SIG_BUFFER_ADDR_A	: std_logic_vector(8 downto 0);
	signal SIG_BUFFER_ADDR_B	: std_logic_vector(8 downto 0);
	signal SIG_BUFFER_DIN		: std_logic_vector(7 downto 0);
	signal SIG_BUFFER_DATA_A	: std_logic_vector(7 downto 0);
	signal SIG_BUFFER_DATA_B	: std_logic_vector(7 downto 0);
	signal SIG_BUFFER_RESET		: std_logic;
	signal SIG_BUFFER_BUSY_A	: std_logic;

	-- VGA signals
	signal SIG_VGA_CHAR			: std_logic_vector (7 downto 0);
	signal SIG_VGA_COUNTER		: unsigned (8 downto 0) := (others => '0');
	signal SIG_VGA_NEWCHAR		: std_logic;
	signal SIG_VGA_PREVCHAR		: std_logic;
	signal SIG_VGA_GOTCHAR		: std_logic;

	-- Keyboard signals
	signal SIG_KEYBOARD_CHAR	: std_logic_vector (7 downto 0);
	signal SIG_KEYBOARD_COUNTER	: unsigned (8 downto 0) := (others => '0');
	signal SIG_KEYBOARD_ENTER	: std_logic;
	signal SIG_KEYBOARD_EOT		: std_logic;

	-- Executor signals
	signal SIG_EXECUTOR_CHAR	: std_logic_vector (7 downto 0);
	signal SIG_EXECUTOR_COUNTER	: unsigned (8 downto 0) := (others => '0');
	signal SIG_EXECUTOR_ENABLE	: std_logic;

begin

	SIG_RESET <= not RESET;
	
	-- Read character from keyboard module and write it into
	main_proc: process(CLOCK, SIG_RESET, SIG_BUFFER_BUSY_A, SIG_KEYBOARD_EOT, SIG_EXECUTOR_ENABLE)
	begin
		if rising_edge(CLOCK) then
			if SIG_RESET = '1' then
				SIG_KEYBOARD_COUNTER <= (others => '0');
				SIG_EXECUTOR_COUNTER <= (others => '0');
				SIG_BUFFER_RESET <= '1';
			elsif SIG_BUFFER_BUSY_A = '0' then
				if SIG_KEYBOARD_COUNTER = 480 then
					SIG_BUFFER_RESET <= '1';
				elsif SIG_KEYBOARD_EOT = '1' then
					SIG_BUFFER_WE <= "1";
					SIG_BUFFER_ADDR_A <= std_logic_vector(SIG_KEYBOARD_COUNTER);
					SIG_BUFFER_DIN <= SIG_KEYBOARD_CHAR;
					SIG_KEYBOARD_COUNTER <= SIG_KEYBOARD_COUNTER + 1;
				elsif SIG_EXECUTOR_ENABLE = '1' then
					SIG_BUFFER_WE <= "0";
					SIG_BUFFER_ADDR_A <= std_logic_vector(SIG_EXECUTOR_COUNTER);
					SIG_EXECUTOR_CHAR <= SIG_BUFFER_DATA_A;
					SIG_EXECUTOR_COUNTER <= SIG_EXECUTOR_COUNTER + 1;
					SIG_EXECUTOR_ENABLE <= '0';
				else
					SIG_BUFFER_ADDR_A <= std_logic_vector(SIG_KEYBOARD_COUNTER - 1);
					
					if SIG_BUFFER_DATA_A = "01011010" then
						SIG_KEYBOARD_ENTER <= '1';
					end if;
				end if;
			end if;
			
			SIG_BUFFER_RESET <= '0';
		end if;
	end process;
	
	-- Read character from buffer and send it to VGA module
	vga_proc: process(CLOCK, SIG_RESET, SIG_VGA_NEWCHAR)
	begin
		if rising_edge(CLOCK) then
			if SIG_RESET = '1' then
				SIG_VGA_COUNTER <= (others => '0');
			elsif SIG_VGA_NEWCHAR = '0' then
				SIG_VGA_PREVCHAR <= '0';
			-- If a new character has been requested
			elsif SIG_VGA_NEWCHAR = '1' and SIG_VGA_PREVCHAR = '0' then
				-- Start re-reading from code buffer
				if (SIG_VGA_COUNTER = 480) then
					SIG_VGA_COUNTER <= (others => '0');
				end if;
		
				SIG_BUFFER_ADDR_B <= std_logic_vector(SIG_VGA_COUNTER);
				SIG_VGA_CHAR <= SIG_BUFFER_DATA_B;
				SIG_VGA_COUNTER <= SIG_VGA_COUNTER + 1;
				SIG_VGA_PREVCHAR <= '1';
			end if;
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
		char => SIG_VGA_CHAR,
		hsync => VGA_HS,
		vsync => VGA_VS,
		getchar => SIG_VGA_NEWCHAR,
		chargot => SIG_VGA_GOTCHAR,
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
		eot => SIG_KEYBOARD_EOT
	);
	
	module_buffer: Code_Buffer
	port map (
		clka => CLOCK,
		rsta => SIG_BUFFER_RESET,
		wea => SIG_BUFFER_WE,
		addra => SIG_BUFFER_ADDR_A,
		dina => SIG_BUFFER_DIN,
		douta => SIG_BUFFER_DATA_A,
		clkb => CLOCK,
		web => (others => '0'),
		addrb => (others => '0'),
		dinb => (others => '0'),
		doutb => open,
		rsta_busy => SIG_BUFFER_BUSY_A,
		rstb_busy => open
	);

end architecture;

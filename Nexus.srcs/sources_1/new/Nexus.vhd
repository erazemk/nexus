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
		LED		: out std_logic_vector (15 downto 0) := (others => '0');
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
			clock			: in std_logic;
			reset			: in std_logic;
			enter			: in std_logic; -- Signals that a new line has been written
			enter_confirm	: out std_logic;
			data			: in std_logic_vector (7 downto 0); -- Character read from the buffer
			data_index		: out std_logic_vector(8 downto 0);
			enable			: out std_logic; -- Signals that a new character should be sent to data
			isready			: in std_logic;
			led				: out std_logic_vector (15 downto 0); -- LEDs
			cled0			: out std_logic_vector (2 downto 0); -- RGB LED 0
			cled1			: out std_logic_vector (2 downto 0); -- RGB LED 1
			vga_color		: out std_logic_vector(3 downto 0);
		    vga_enable      : out std_logic
		);
	end component;

	component VGA is
		Port (
			clock	: in std_logic;
			reset	: in std_logic;
			hsync	: out std_logic;
			vsync	: out std_logic;
			char	: in std_logic_vector (7 downto 0);
			getchar	: out std_logic;
			red		: out std_logic_vector (3 downto 0);
			green	: out std_logic_vector (3 downto 0);
			blue	: out std_logic_vector (3 downto 0);
			bckgrnd : in std_logic_vector (3 downto 0)
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
			clka	: in std_logic;
			wea		: in std_logic_vector(0 downto 0);
			addra	: in std_logic_vector(8 downto 0);
			dina	: in std_logic_vector(7 downto 0);
			douta	: out std_logic_vector(7 downto 0);
			clkb	: in std_logic;
			web		: in std_logic_vector(0 downto 0);
			addrb	: in std_logic_vector(8 downto 0);
			dinb	: in std_logic_vector(7 downto 0);
			doutb	: out std_logic_vector(7 downto 0)
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

	-- VGA signals
	signal SIG_VGA_CHAR			: std_logic_vector (7 downto 0);
	signal SIG_VGA_COUNTER		: unsigned (8 downto 0) := "000010001";
	signal SIG_VGA_NEWCHAR		: std_logic;
	signal SIG_VGA_PREVCHAR		: std_logic;
	signal SIG_VGA_BCKGRND      : std_logic_vector (3 downto 0):= (others => '0');

	-- Keyboard signals
	signal SIG_KEYBOARD_CHAR	: std_logic_vector (7 downto 0);
	signal SIG_KEYBOARD_COUNTER	: unsigned (8 downto 0) := (others => '0');
	signal SIG_KEYBOARD_ENTER	: std_logic; -- Set by nexus to signal an Enter key was pressed
	signal SIG_KEYBOARD_CONFIRM	: std_logic; -- Confirmation from parser that the line was parsed
	signal SIG_KEYBOARD_EOT		: std_logic;
	signal SIG_KEYBOARD_F0		: std_logic;

	-- Executor signals
	signal SIG_EXECUTOR_CHAR	: std_logic_vector (7 downto 0);
	signal SIG_EXECUTOR_COUNTER	: unsigned (8 downto 0) := (others => '0');
	signal SIG_EXECUTOR_NEWCHAR	: std_logic;
	signal SIG_EXECUTOR_READY	: std_logic := '0';
	signal SIG_EXECUTOR_INDEX	: std_logic_vector(8 downto 0);
	signal SIG_VGA_COLOR        : std_logic_vector (3 downto 0);
	signal SIG_VGA_ENABLE       : std_logic;

	
	
	-- Allowed character array
	type char_array_type is array (0 to 25) of std_logic_vector(7 downto 0);
	signal char_array : char_array_type := (
			"01000101", -- 0
			"00010110", -- 1
			"00011110", -- 2
			"00100110", -- 3
			"00100101", -- 4
			"00101110", -- 5
			"00110110", -- 6
			"00111101", -- 7
			"00111110", -- 8
			"01000110", -- 9
			"00011100", -- A
			"00110010", -- B
			"00100001", -- C
			"00100011", -- D
			"00100100", -- E
			"00101011", -- F
			"00110100", -- G
			"01001011", -- L
			"00110001", -- N
			"01000100", -- O
			"00101101", -- R
			"00011011", -- S
			"00110101", -- Y
			"01001101", -- P
			"00101001", -- Space
			"01011010"  -- Enter
		);

begin

	SIG_RESET <= not RESET;
	
	-- Read character from keyboard module and write it into
	main_proc: process(CLOCK)
	begin
		if rising_edge(CLOCK) then
			if SIG_RESET = '1' then
				SIG_KEYBOARD_COUNTER <= (others => '0');
			else
				-- Keyboard has sent new character
				if SIG_KEYBOARD_EOT = '1' then
					-- Previous character was F0 (key was depressed)
					if SIG_KEYBOARD_F0 = '1' then
						SIG_KEYBOARD_F0 <= '0';
					else
						-- Check if the next char is a depressed previous one
						if SIG_KEYBOARD_CHAR = "11110000" then -- char = 0xF0 (depress signal)
							SIG_KEYBOARD_F0 <= '1';
						else
							-- Check if char is enter
							if SIG_KEYBOARD_CHAR = "01011010" then -- char = Enter

								-- Round up to the nearest next multiple of 16 (to start at a new line)
								SIG_KEYBOARD_COUNTER <= (SIG_KEYBOARD_COUNTER(8 downto 4) + 1) & "0000";
								SIG_KEYBOARD_ENTER <= '1';
							-- Or backspace, only allow deleting last line
							elsif SIG_KEYBOARD_CHAR = "01100110" and SIG_KEYBOARD_COUNTER(3 downto 0) > 0 then -- char = backspace   
								SIG_BUFFER_WE <= "1";
								SIG_BUFFER_ADDR_A <= std_logic_vector(SIG_KEYBOARD_COUNTER - 1);
								SIG_KEYBOARD_COUNTER <= SIG_KEYBOARD_COUNTER - 1;
								SIG_BUFFER_DIN <= (others => '0');
							else
								for i in 0 to char_array'length - 1 loop
									-- Check if character is valid
									if SIG_KEYBOARD_CHAR = char_array(i) then
										SIG_BUFFER_WE <= "1";
										SIG_BUFFER_ADDR_A <= std_logic_vector(SIG_KEYBOARD_COUNTER);
										SIG_BUFFER_DIN <= SIG_KEYBOARD_CHAR;
										SIG_KEYBOARD_COUNTER <= SIG_KEYBOARD_COUNTER + 1;
									end if;
								end loop;
							end if;
						end if;
					end if;
				elsif SIG_EXECUTOR_NEWCHAR = '1' then
					SIG_BUFFER_WE <= "0";
					SIG_BUFFER_ADDR_A <= std_logic_vector(SIG_EXECUTOR_INDEX);
					SIG_EXECUTOR_CHAR <= SIG_BUFFER_DATA_A;
					
					if SIG_EXECUTOR_COUNTER < 3 then
					   SIG_EXECUTOR_COUNTER <= SIG_EXECUTOR_COUNTER + 1;
					else
					   SIG_EXECUTOR_READY <= '1';
					   SIG_EXECUTOR_COUNTER <= (others => '0'); 
					end if;
				else
					SIG_EXECUTOR_READY <= '0';
					SIG_EXECUTOR_COUNTER <= (others => '0');

					if SIG_KEYBOARD_CONFIRM = '1' then
						SIG_KEYBOARD_ENTER <= '0';
					end if;
				end if;
			end if;
		end if;
	end process;
	
	-- Read character from buffer and send it to VGA module
	vga_proc: process(CLOCK)
	begin
		if rising_edge(CLOCK) then
			if SIG_RESET = '1' then
				SIG_VGA_COUNTER <= "000010001";
			-- If a new character has been requested
			elsif SIG_VGA_NEWCHAR = '1' then
				-- Start re-reading from code buffer
				if (SIG_VGA_COUNTER = "111011111") then
					SIG_VGA_COUNTER <= (others => '0');
				else
					SIG_VGA_COUNTER <= SIG_VGA_COUNTER + 1;
				end if;

				SIG_BUFFER_ADDR_B <= std_logic_vector(SIG_VGA_COUNTER);
				SIG_VGA_CHAR <= SIG_BUFFER_DATA_B;
			elsif SIG_VGA_ENABLE = '1' then
			     SIG_VGA_BCKGRND <= SIG_VGA_COLOR;
			end if;
		end if;
	end process;

	module_executor: Executor
	port map (
		clock => CLOCK,
		reset => SIG_RESET,
		enter => SIG_KEYBOARD_ENTER,
		enter_confirm => SIG_KEYBOARD_CONFIRM,
		enable => SIG_EXECUTOR_NEWCHAR,
		isready => SIG_EXECUTOR_READY,
		data => SIG_EXECUTOR_CHAR,
		data_index => SIG_EXECUTOR_INDEX,
		led => LED,
		cled0 => CLED0,
		cled1 => CLED1,
		vga_color => SIG_VGA_COLOR,
		vga_enable => SIG_VGA_ENABLE
	);

	module_vga: VGA
	port map (
		clock => CLOCK,
		reset => SIG_RESET,
		char => SIG_VGA_CHAR,
		hsync => VGA_HS,
		vsync => VGA_VS,
		getchar => SIG_VGA_NEWCHAR,
		red => VGA_R,
		green => VGA_G,
		blue => VGA_B,
		bckgrnd => SIG_VGA_BCKGRND
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
		wea => SIG_BUFFER_WE,
		addra => SIG_BUFFER_ADDR_A,
		dina => SIG_BUFFER_DIN,
		douta => SIG_BUFFER_DATA_A,
		clkb => CLOCK,
		web => (others => '0'),
		addrb => SIG_BUFFER_ADDR_B,
		dinb => (others => '0'),
		doutb => SIG_BUFFER_DATA_B
	);

end architecture;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity VGA is

	Port (
		clock	: in std_logic;
		reset	: in std_logic;
		char	: in std_logic_vector (7 downto 0);
		hsync	: out std_logic;
		vsync	: out std_logic;
		newchar	: out std_logic := '0';
		red		: out std_logic_vector (3 downto 0);
		green	: out std_logic_vector (3 downto 0);
		blue	: out std_logic_vector (3 downto 0)
	);

end VGA;

architecture Behavioral of VGA is

	component VGA_Hsync_Instance is
		Port (
			clk		: in std_logic;
			rst		: in std_logic;
			hsync	: out std_logic;
			ce		: out std_logic;
			display	: out std_logic;
			column	: out unsigned(9 downto 0)
		);
	end component;

	component VGA_Vsync_Instance is
		Port (
			clk		: in std_logic;
			rst		: in std_logic;
			ce		: in std_logic;
			vsync	: out std_logic;
			display	: out std_logic;
			row		: out unsigned(9 downto 0)
		);
	end component;

	component VGA_Character_To_Pixel is
		Port (
			id		: in std_logic_vector (7 downto 0);
			matrix	: out std_logic_vector (16*9-1 downto 0)
		);
	end component;

	component VGA_Array is
		Port (
			column	: in unsigned(9 downto 0);
			row 	: in unsigned(9 downto 0);
			matrix	: in std_logic_vector (16*9-1 downto 0);
			red		: out std_logic_vector (3 downto 0);
			green	: out std_logic_vector (3 downto 0);
			blue	: out std_logic_vector (3 downto 0)
		);
	end component;

---SIGNALI

	signal clock_enable		: std_logic;
	signal h_display		: std_logic;
	signal v_display		: std_logic;
	signal display_both		: std_logic;
	signal column			: unsigned(9 downto 0);
	signal row				: unsigned(9 downto 0);
	signal border_on		: std_logic;
	signal matrix			: std_logic_vector (16*9-1 downto 0);
	signal red0				: std_logic_vector (3 downto 0);
	signal green0			: std_logic_vector (3 downto 0);
	signal blue0			: std_logic_vector (3 downto 0);
	signal red1				: std_logic_vector (3 downto 0);
	signal green1			: std_logic_vector (3 downto 0);
	signal blue1			: std_logic_vector (3 downto 0);
begin

    
	module_hsync: VGA_HSync_Instance
	port map (
		clk => clock,
		rst => reset,
		ce => clock_enable,
		hsync => hsync,
		display => h_display,
		column => column
	);

	module_vsync: VGA_VSync_Instance
	port map (
		clk => clock,
		rst => reset,
		ce => clock_enable,
		vsync => vsync,
		display => v_display,
		row => row
	);

	module_charToPx: VGA_Character_To_Pixel
	port map (
		id => char,
		matrix => matrix
	);

	module_array0: VGA_Array
	port map (
		column => column,
		row => row,
		matrix => matrix,
		red => red0,
		green => green0,
		blue => blue0
	);

	module_array1: VGA_Array
	port map (
		column => column,
		row => row,
		matrix => matrix,
		red => red1,
		green => green1,
		blue => blue1
	);
    display_both <= h_display and v_display;
	-- Primer 3: vodoravni pasovi rdece, modre in zelene 
	red <= "1111" when (display_both = '1' and row >= 0 and row < 160) else "0000";
	green <= "1111" when (display_both = '1' and row >= 160 and row < 320) else "0000";
	blue <= "1111" when (display_both = '1' and row >= 320 and row < 480) else "0000";

end Behavioral;

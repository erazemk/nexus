library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity VGA is

	Port (
		clock	: in std_logic;
		reset	: in std_logic;
		char	: in std_logic_vector (7 downto 0);
		getchar	: out std_logic;
		hsync	: out std_logic;
		vsync	: out std_logic;
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
    
    component VGA_PS2ID_To_ASCII is
		Port (
            ps2id     : in std_logic_vector(7 downto 0);
            ascii     : out std_logic_vector(7 downto 0)
		);
    end component;
        
	component VGA_ASCII_To_Pixel is
		Port (
            clk: in std_logic;
            addr: in std_logic_vector(10 downto 0);
            data: out std_logic_vector(0 to 7)
		);
	end component;

	component VGA_Array is
		Port (
			clock		: in std_logic;
			reset		: in std_logic;
			read		: in std_logic;
			write       : in std_logic;
			debug       : in std_logic;
			column		: in unsigned (9 downto 0);
			row			: in unsigned (9 downto 0);
			data        : in std_logic_vector (0 to 7) := (others => '0');
		    offset      : out std_logic_vector (3 downto 0) := (others => '0');
			getchar		: out std_logic;
			red			: out std_logic_vector (3 downto 0) := (others => '0');
			green		: out std_logic_vector (3 downto 0) := (others => '0');
			blue		: out std_logic_vector (3 downto 0) := (others => '0')
		);
	end component;

---SIGNALI

	signal clock_enable		: std_logic;
	
	signal h_display		: std_logic;
	signal v_display		: std_logic;
	
	signal read0			: std_logic := '0';
	signal read1			: std_logic := '0';
	
	signal column			: unsigned(9 downto 0);
	signal row				: unsigned(9 downto 0);
	signal border_on		: std_logic;
	signal addr			    : std_logic_vector(10 downto 0);
	
    signal ascii			: std_logic_vector(7 downto 0);
    signal offset			: std_logic_vector (3 downto 0);
    signal data			    : std_logic_vector(7 downto 0);
    
    signal offset0			: std_logic_vector (3 downto 0);
	signal getchar0			: std_logic;
	signal red0				: std_logic_vector (3 downto 0);
	signal green0			: std_logic_vector (3 downto 0);
	signal blue0			: std_logic_vector (3 downto 0);
	
	signal offset1			: std_logic_vector (3 downto 0);
	signal getchar1			: std_logic;
	signal red1				: std_logic_vector (3 downto 0);
	signal green1			: std_logic_vector (3 downto 0);
	signal blue1			: std_logic_vector (3 downto 0);
begin

    ---------LOGIKA-----------------
    addr <= ascii(6 downto 0) & offset;
    
	--moramo gledati spremembo podateka row na vsakih 16 vrstic => (row/16) mod 2 ali pa le preberemo 5. bit row(4)
	read0 <= '1' when (h_display = '1' and v_display = '1' and row(4) = '1') else '0';
	--Ko se enega bere se iz drugega piše
	read1 <= '1' when (h_display = '1' and v_display = '1' and row(4) = '0') else '0';
	
	
	
	--ko enden array piše je drugi natavljen na 0, tako z or-om dobimo konstanten stream podatkov
	offset <= offset0 or offset1;
	getchar <= getchar0 or getchar1;
	red <= red0 or red1;
	green <= green0 or green1;
	blue <= blue0 or blue1;
    
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
	
	module_PS2ID_to_ASCII: VGA_PS2ID_To_ASCII
	port map (
        ps2id  => char,
        ascii => ascii
	);

	module_ASCII_to_px: VGA_ASCII_To_Pixel
	port map (
        clk => clock,
        addr  => addr,
        data => data
	);

	module_array0: VGA_Array
	port map (
	    clock => clock,
		reset => reset,
		read => read0,
		write => read1,
		debug => row(4),
		column => column,
		row => row,
		data => data,
		offset => offset0,
		getchar => getchar0,
		red => red0,
		green => green0,
		blue => blue0
	);

	module_array1: VGA_Array
	port map (
		clock => clock,
		reset => reset,
		read => read1,
		write => read0,
		debug => row(4),
		column => column,
		row => row,
		data => data,
		offset => offset1,
		getchar => getchar1,
		red => red1,
		green => green1,
		blue => blue1
	);	

end architecture;

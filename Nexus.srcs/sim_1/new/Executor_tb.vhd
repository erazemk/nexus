library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Executor_tb is
end entity;

architecture Behavioral of Executor_tb is

	component Executor is
		Port (
			clock			: in std_logic;
			reset			: in std_logic;
			enter			: in std_logic; -- Signals that a new line has been written
			data			: in std_logic_vector (7 downto 0); -- Character read from the buffer
			isready			: in std_logic;
			enter_confirm	: out std_logic := '0';
			data_index		: out std_logic_vector(8 downto 0);
			enable			: out std_logic := '0'; -- Signals that a new character should be sent to data
			led				: out std_logic_vector (15 downto 0); -- LEDs
			anode			: out std_logic_vector (7 downto 0) := (others => '1'); -- 7-seg anode
			cathode			: out std_logic_vector (7 downto 0); -- 7-seg cathode
			cled0			: out std_logic_vector (2 downto 0); -- RGB LED 0
			cled1			: out std_logic_vector (2 downto 0) -- RGB LED 1
		);
	end component;
	
	--input signali
	signal clock, reset 	: std_logic := '0';
	signal enter, isready 	: std_logic := '0';
	signal data				: std_logic_vector (7 downto 0) := (others => '0');
	
	--output signali
	signal enter_confirm	: std_logic;
	signal data_index		: std_logic_vector(8 downto 0);
	signal enable			: std_logic;
	signal led				: std_logic_vector (15 downto 0);
	signal cled0,cled1		: std_logic_vector (2 downto 0);

	constant CLK_PERIOD		: time := 10 ns;

	type arr_type is array (0 to 47) of std_logic_vector(7 downto 0);
	signal arr : arr_type := (
		"01001011", -- L
		"00111110", -- 8
		"00110001", -- N
		"00000000", -- Blank
		"00000000", -- Blank
		"00000000", -- Blank
		"00000000", -- Blank
		"00000000", -- Blank
		"00000000", -- Blank
		"00000000", -- Blank
		"00000000", -- Blank
		"00000000", -- Blank
		"00000000", -- Blank
		"00000000", -- Blank
		"00000000", -- Blank
		"00000000", -- Blank
		"01001011", -- L
		"00100101", -- 4
		"00110001", -- N
		"00000000", -- Blank
		"00000000", -- Blank
		"00000000", -- Blank
		"00000000", -- Blank
		"00000000", -- Blank
		"00000000", -- Blank
		"00000000", -- Blank
		"00000000", -- Blank
		"00000000", -- Blank
		"00000000", -- Blank
		"00000000", -- Blank
		"00000000", -- Blank
		"00000000", -- Blank
		"01001011", -- L
		"00111110", -- 8
		"00101011", -- F
		"00000000", -- Blank
		"00000000", -- Blank
		"00000000", -- Blank
		"00000000", -- Blank
		"00000000", -- Blank
		"00000000", -- Blank
		"00000000", -- Blank
		"00000000", -- Blank
		"00000000", -- Blank
		"00000000", -- Blank
		"00000000", -- Blank
		"00000000", -- Blank
		"00000000"  -- Blank
	);

begin

	UUT: Executor
	port map (
		clock => clock,
		reset => reset,
		enter => enter,
		data => data,
		isready => isready,
		enter_confirm => enter_confirm,
		data_index => data_index,
		enable => enable,
		led => led,
		anode => open,
		cathode => open,
		cled0 => cled0,
		cled1 => cled1
	);

	CLK_STIMULUS : process
	begin
		clock <= not clock;
		wait for CLK_PERIOD / 2;
	end process;
	
	OTH_STIMULI : process
	begin
	
		-- 1st command
		enter <= '1';
		isready <= '0';
		
		while enter_confirm /= '1' loop
			if enable = '1' then -- enable == newchar
				data <= arr(to_integer(unsigned(data_index)));
				isready <= '1';
			elsif enable = '0' then
				isready <= '0';
			end if;
			wait for CLK_PERIOD;
		end loop;

		enter <= '0';
		isready <= '0';
		
		wait for CLK_PERIOD * 3;
		
		-- 2nd command
		enter <= '1';
		isready <= '0';
		
		while enter_confirm /= '1' loop
			if enable = '1' then -- enable == newchar
				data <= arr(to_integer(unsigned(data_index)));
				isready <= '1';
			elsif enable = '0' then
				isready <= '0';
			end if;
			wait for CLK_PERIOD;
		end loop;

		enter <= '0';
		isready <= '0';
		
		wait for CLK_PERIOD * 3;
		
		-- 3rd command
		enter <= '1';
		isready <= '0';
		
		while enter_confirm /= '1' loop
			if enable = '1' then -- enable == newchar
				data <= arr(to_integer(unsigned(data_index)));
				isready <= '1';
			elsif enable = '0' then
				isready <= '0';
			end if;
			wait for CLK_PERIOD;
		end loop;

		enter <= '0';
		isready <= '0';
		wait;
	end process;
    
end architecture;

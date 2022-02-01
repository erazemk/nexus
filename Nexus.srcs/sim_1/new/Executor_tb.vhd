library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Executor_tb is
--  Port ( );
end entity;

architecture Behavioral of Executor_tb is

	component Executor is
		Port (
			clock			: in std_logic;
			reset			: in std_logic;
			enter			: in std_logic; -- Signals that a new line has been written
			enter_confirm	: out std_logic;
			data			: in std_logic_vector (7 downto 0); -- Character read from the buffer
			enable			: out std_logic; -- Signals that a new character should be sent to data
			isready			: in std_logic := '0';
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
	signal data				: std_logic_vector (7 downto 0) := "00000000";
	
	--output signali
	signal enter_confirm, enable	: std_logic;
	signal led				: std_logic_vector (15 downto 0);
	signal anode, cathode	: std_logic_vector (7 downto 0);
	signal cled0,cled1		: std_logic_vector (2 downto 0);

	constant CLK_PERIOD		: time := 10 ns;

	type arr_type is array (0 to 8) of std_logic_vector(7 downto 0);
	signal arr : arr_type := (
		"01001011", -- L
		"00100100", -- E
		"00100011", -- D
		"00101001", -- Space
		"00111110", -- 8
		"00101001", -- Space
		"01000100", -- O
		"00110001", -- N
		"01011010"  -- Enter
	);
	
	type arr_type5 is array (0 to 9) of std_logic_vector(7 downto 0);
	signal arr5 : arr_type5 := (
		"01001011", -- L
		"00100100", -- E
		"00100011", -- D
		"00101001", -- Space
		"00111110", -- 8
		"00101001", -- Space
		"01000100", -- O
		"00101011", -- F
		"00101011", -- F
		"01011010"  -- Enter
	);
	
	type arr_type4 is array (0 to 8) of std_logic_vector(7 downto 0);
	signal arr4 : arr_type4 := (
		"01001011", -- L
		"00100100", -- E
		"00100011", -- D
		"00101001", -- Space
		"00010110", -- 1
		"00101001", -- Space
		"01000100", -- O
		"00110001", -- N
		"01011010"  -- Enter
	);

	type arr_type2 is array (0 to 11) of std_logic_vector(7 downto 0);
	signal arr2 : arr_type2 := (
		"00100001", -- C
		"01001011", -- L
		"00100100", -- E
		"00100011", -- D
		"00101001", -- Space
		"00010110", -- 1
		"00101001", -- Space
		"01000100", -- O
		"00110001", -- N
		"00101001", -- Space
		"00101101", -- R
		"01011010"  -- Enter
	);
	
	type arr_type3 is array (0 to 13) of std_logic_vector(7 downto 0);
	signal arr3 : arr_type3 := (
		"00011011", -- S
		"00100100", -- E
		"00110100", -- G
		"00101001", -- Space
		"00010110", -- 1
		"00101001", -- Space
		"01000100", -- O
		"00110001", -- N
		"00101001", -- Space
		"00110010", -- B
		"00100100", -- E
		"00100100", -- E
		"00101011", -- F
		"01011010"  -- Enter
	);

begin

	UUT: Executor
		port map (
			clock => clock,
			reset => reset,
			enter => enter,
			enter_confirm => enter_confirm,
			data => data,
			enable => enable,
			isready => isready,
			led => led,
			anode => anode,
			cathode => cathode,
			cled0 => cled0,
			cled1 => cled1
		);

	CLK_STIMULUS : process
	begin
		clock <= not clock;
		wait for CLK_PERIOD / 2;
	end process;

	reset <= '1', '0' after CLK_PERIOD * 3;
	
	OTH_STIMULI : process
	begin
		wait for CLK_PERIOD * 5;
	
		enter <= '1';

		for i in 0 to 8 loop
			-- enable == newchar in parser
			while (enable /= '1') loop
				wait for CLK_PERIOD;
			end loop;

			data <= arr(i);
			isready <= '1';

			while (enable /= '0') loop
				wait for CLK_PERIOD;
			end loop;

			isready <= '0';
		end loop;

		while (enter_confirm /= '1') loop
			wait for CLK_PERIOD;
		end loop;

		enter <= '0';
		
		wait for CLK_PERIOD * 5;
		
		enter <= '1';
		
				for i in 0 to 8 loop
			-- enable == newchar in parser
			while (enable /= '1') loop
				wait for CLK_PERIOD;
			end loop;

			data <= arr4(i);
			isready <= '1';

			while (enable /= '0') loop
				wait for CLK_PERIOD;
			end loop;

			isready <= '0';
		end loop;
		
		while (enter_confirm /= '1') loop
			wait for CLK_PERIOD;
		end loop;
		
		enter <= '0';
		wait for CLK_PERIOD * 5;
		
		enter <= '1';
		
		for i in 0 to 9 loop
			-- enable == newchar in parser
			while (enable /= '1') loop
				wait for CLK_PERIOD;
			end loop;

			data <= arr5(i); 
			isready <= '1';

			while (enable /= '0') loop
				wait for CLK_PERIOD;
			end loop;

			isready <= '0';
		end loop;
		
		while (enter_confirm /= '1') loop
			wait for CLK_PERIOD;
		end loop;
		
		enter <= '0';
    wait;
    end process;
    
end architecture;

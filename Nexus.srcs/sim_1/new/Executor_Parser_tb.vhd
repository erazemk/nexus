library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Executor_Parser_tb is
--  Port ( );
end Executor_Parser_tb;

architecture Behavioral of Executor_Parser_tb is
    component Executor_Parser is
	Port ( 
		clock	        : in std_logic;
		reset	        : in std_logic;
		symbol	        : in std_logic_vector(7 downto 0);
		enable	        : in std_logic;
		parsed	        : inout std_logic;
		parsed_confirm	: in std_logic;
		command	        : inout std_logic_vector(1 downto 0);
		led_id	        : out std_logic_vector(3 downto 0);
		cled_id	        : out std_logic;
		seg_id	        : out std_logic;
		onoff	        : out std_logic;
		value	        : out std_logic_vector(15 downto 0);
		newchar         : out std_logic;
		isready	        : in std_logic
	);
end component;

signal clock, reset, enable, parsed, isready, parsed_confirm : std_logic := '0';
signal symbol : std_logic_vector(7 downto 0) := "00000000";

signal cled_id, seg_id, onoff, newchar: std_logic;
signal value : std_logic_vector(15 downto 0);
signal led_id : std_logic_vector(3 downto 0);
signal command : std_logic_vector(1 downto 0);

constant CLK_PERIOD : time := 10 ns;

begin
    UUT : Executor_Parser
        port map(
            clock   => clock,
			reset	=> reset,
			symbol	=> symbol,
			enable	=> enable,
			parsed	=> parsed,
			parsed_confirm => parsed_confirm,
			command	=> command,
			led_id  => led_id, 
			cled_id	=> cled_id,
			seg_id	=> seg_id,
			onoff	=> onoff,
			value	=> value,
			newchar => newchar,
			isready => isready
		);
	
	CLK_STIMULUS : process
	begin
		clock <= not clock;
		wait for CLK_PERIOD/2;
	end process;
	
	reset <= '1', '0' after CLK_PERIOD * 3;
	enable <= '0', '1' after CLK_PERIOD * 4;

	
	OTH_STIMULI : process
	variable idx : integer:= 0;
	begin
		-- Reset
		--reset    <= '1';
		while (enable /= '1') loop
		  wait for CLK_PERIOD;
	    end loop;
        
        
        while (enable = '1') loop
            if (newchar = '1') then
                case idx is
                    when 0 =>
                        symbol <= "01001011"; --L
                    when 1 => 
                        symbol <= "00100100"; --E
                    when 2 => 
                        symbol <= "00100011"; --D
                    when 3 => 
                        symbol <= "00101001"; --Space
                    when 4 =>
                        symbol <= "00011110"; --1
                    when 5 => 
                        symbol <= "00101001"; --Space
                    when 6 => 
                        symbol <= "01000100"; --O
                    when 7 => 
                        symbol <= "00110001"; --N
                    when 8 => 
                        symbol <= "01011010"; --Enter
                    when others => symbol <= "00101001"; --Space
                 end case;
                 isready <= '1';
                 
                 idx := idx + 1;
            end if;
            if (newchar = '0') then
                    isready <= '0';
            end if;
            wait for CLK_PERIOD;
        end loop;
        wait;
        
        -- if newchar = '1' then
        --     symbol <= "01001011"; --L
        --     isready <= '1';
        -- end if;
        
        -- wait for CLK_PERIOD * 3;
        -- if newchar = '1' then
        --     symbol <= "00100100"; --E
        --     isready <= '1';
        -- end if;
        
        -- wait for CLK_PERIOD * 3;
        -- symbol <= "00100011"; --D
        -- wait for CLK_PERIOD * 3;
        -- symbol <= "00101001"; --Space
        -- wait for CLK_PERIOD * 3;
        -- symbol <= "00011110"; --1
        -- wait for CLK_PERIOD * 3;
        -- symbol <= "00101001"; --Space
        -- wait for CLK_PERIOD * 3;
        -- symbol <= "01000100"; --O
        -- wait for CLK_PERIOD * 3;
        -- symbol <= "00110001"; --N
        -- wait for CLK_PERIOD * 3;
        -- symbol <= "01011010"; --Enter
        -- wait for CLK_PERIOD * 3;
		--for i in 0 to 2 loop
			
		--end loop;

		--wait; -- ?akaj neskon?no dolgo      
	end process;


end Behavioral;

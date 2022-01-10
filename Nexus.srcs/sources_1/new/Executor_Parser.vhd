library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Executor_Parser is
	Port ( 
		clock	: in std_logic;
		reset	: in std_logic;
		symbol	: in std_logic_vector(7 downto 0);
		enable	: in std_logic;
		parsed	: out std_logic;
		command	: out std_logic_vector(1 downto 0);
		id		: out std_logic_vector(3 downto 0);
		onoff	: out std_logic;
		value	: out std_logic_vector(15 downto 0);
		newchar : out std_logic
	);
end Executor_Parser;

architecture Behavioral of Executor_Parser is

	type states is (S_IDLE, S_SKIP, S_COMMAND, S_ID, S_ONOFF, S_VALUE);
	signal state, next_state	: states;
	signal next_space, first_o	: std_logic;

begin
	
	SYNC_PROC : process (clock)
	begin
		if rising_edge(clock) then
			if reset = '1' then
				state <= S_IDLE;
				parsed <= '0';
				skip <= '0';
				first_o <= '0';
			else
				-- Pomnjenje stanja in izhoda
				state <= next_state;
				--TODO pomni izhod 	pulse <= output;
			end if;
		end if;
	end process;

	NEXT_STATE_DECODE : process (state, next_space, clock)
	begin
		next_state <= state;
		case state is
			when S_IDLE =>
				if enable = '1' then
					next_state <= S_COMMAND;
				end if;
			when S_COMMAND =>
				if next_space = '1' then
					next_state <= S_ID;	
					skip = '0';	
				elsif skip = '1' then
					next_state <= S_SKIP;
				end if; 
			when S_ID =>
				if next_space = '1' then
					next_state <= S_ONOFF;
				end if;
			when S_ONOFF =>
				if next_space = '1' then
					next_state <= S_VALUE;
				end if;
			when S_VALUE =>
				if next_space = '1' then
					next_state <= S_IDLE;
				end if;
			when S_SKIP =>
				if next_space = '1' then
					next_state <= S_ID;
					skip <= '0';
				end if;
			when others =>
				next_state <= S_IDLE;
		end case;
	end process;

	OUTPUT_DECODE : process (state)
	begin
		case state is 
			when S_IDLE =>
				--
			when S_COMMAND =>
				if symbol = "L" then
					command <= "00";
					skip <= '1';
				elsif symbol = "00100001" then -- symbol = C
					command <= "01";
					skip <= '1';
				elsif symbol = "00011011" then --symbol = S
					command <= "10";
					skip <= '1';
				end if;
			
			when S_ID =>
				id <= symbol;
				
			when S_ONOFF =>
				if symbol = "01000100" or first_o then --symbol = O 
					first_o = '1';
					if symbol = "00110001" then --symbol = N
						onoff <= '1';
					elsif symbol = "00101011" then --symbol = F
						onoff <= '0';
					first_o <= '0';
					end if;
				end if;
			
			when S_VALUE =>
				
					 

end Behavioral;

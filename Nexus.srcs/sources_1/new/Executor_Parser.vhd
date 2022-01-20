library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Executor_Parser is
	Port ( 
		clock	: in std_logic;
		reset	: in std_logic;
		symbol	: in std_logic_vector(7 downto 0);
		enable	: in std_logic;
		parsed	: inout std_logic;
		command	: inout std_logic_vector(1 downto 0);
		id		: out std_logic_vector(3 downto 0);
		onoff	: out std_logic;
		value	: out std_logic_vector(15 downto 0);
		newchar : inout std_logic
	);
end Executor_Parser;

architecture Behavioral of Executor_Parser is

	type states is (S_IDLE, S_SKIP, S_COMMAND, S_ID, S_ONOFF, S_VALUE1, S_VALUE2, S_VALUE3, S_VALUE4);
	signal state, next_state	: states;
	signal next_space, first_o, skip	: std_logic;

begin

	process(clock, reset, state, next_space, enable, skip, newchar, symbol, first_o, command)
		variable val : std_logic_vector(3 downto 0);
	begin
		-- Reset
		if reset = '1' then
			state <= S_IDLE;
			parsed <= '0';
			skip <= '0';
			first_o <= '0';
		end if;

		if rising_edge(clock) then

			-- Sync process
			if symbol /= "01011010" then --ni Enter oz konec ukaza
				if symbol = "00101001" then
			    	next_space <= '1';
				else
					next_space <= '0';
				end if;

				-- Pomnjenje stanja in izhoda
			    state <= next_state;
				--TODO pomni izhod 	pulse <= output;
			elsif symbol = "01011010" then --Enter oz konec ukaza
				parsed <= '1';
			end if;

			-- Next state decode
			if newchar = '0' then
				next_state <= state;
				case state is
					when S_IDLE =>
						if enable = '1' then
							next_state <= S_COMMAND;
						end if;
					when S_COMMAND =>
						if next_space = '1' then
							next_state <= S_ID;	
							skip <= '0';	
						elsif skip = '1' then
							next_state <= S_SKIP;
						end if; 
					when S_ID =>
						if next_space = '1' then
							next_state <= S_ONOFF;
						end if;
					when S_ONOFF =>
						if next_space = '1' then
							next_state <= S_VALUE1;
						end if;
					when S_SKIP =>
						if next_space = '1' then
							next_state <= S_ID;
							skip <= '0';
						end if;
					when S_VALUE1 =>
							next_state <= S_VALUE2;
					when S_VALUE2 =>
							next_state <= S_VALUE3;
					when S_VALUE3 =>
							next_state <= S_VALUE4;
					when S_VALUE4 =>
							next_state <= S_IDLE;					
					when others =>
						next_state <= S_IDLE;
				  end case;
				  newchar <= '1';
			end if;

			-- Output decode
			case state is 
				when S_IDLE =>
					--
				when S_SKIP =>
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
					case symbol is 
						when "01000101" => id <= "0000"; -- 0 
						when "00010110" => id <= "0001"; -- 1
						when "00011110" => id <= "0010"; -- 2
						when "00100110" => id <= "0011"; -- 3
						when "00100101" => id <= "0100"; -- 4
						when "00101110" => id <= "0101"; -- 5
						when "00110110" => id <= "0110"; -- 6
						when "00111101" => id <= "0111"; -- 7
						when "00111110" => id <= "1000"; -- 8
						when "01000110" => id <= "1001"; -- 9
						when "00011100" => id <= "1010"; -- A
						when "00110010" => id <= "1011"; -- B
						when "00100001" => id <= "1100"; -- C
						when "00100011" => id <= "1101"; -- D
						when "00100100" => id <= "1110"; -- E
						when "00101011"	=> id <= "1111"; -- F
						when others =>
							id <= "1111";
							onoff <= '1';
							command <= "00";
					end case; 
					
				when S_ONOFF =>
					if symbol = "01000100" or first_o = '1' then --symbol = O 
						first_o <= '1';
						if symbol = "00110001" then --symbol = N
							onoff <= '1';
							first_o <= '0';
						elsif symbol = "00101011" then --symbol = F
							onoff <= '0';
							first_o <= '0';
						end if;
					end if;
				
				when S_VALUE1 =>
					if command = "01" then	--RGB LED
					
						if symbol = "00011101" then -- symbol = W
							value <= (others => '0');
						elsif symbol = "00101101" then --symbol = R
							value <= (0 => '1', others => '0');
						elsif symbol = "00110100" then --symbol = G
							value <= (1 => '1', others => '0');
						elsif symbol = "00110010" then --symbol = B
							value <= (0 => '1', 1 => '1', others => '0');
						end if;
						
					elsif command = "10" then -- 7 segment display 

						--val := value(15 - char_count downto 12 - char_count);

						case symbol is 
							when "01000101" => value(15 downto 12) <= "0000"; -- 0 
							when "00010110" => value(15 downto 12) <= "0001"; -- 1
							when "00011110" => value(15 downto 12) <= "0010"; -- 2
							when "00100110" => value(15 downto 12) <= "0011"; -- 3
							when "00100101" => value(15 downto 12) <= "0100"; -- 4
							when "00101110" => value(15 downto 12) <= "0101"; -- 5
							when "00110110" => value(15 downto 12) <= "0110"; -- 6
							when "00111101" => value(15 downto 12) <= "0111"; -- 7
							when "00111110" => value(15 downto 12) <= "1000"; -- 8
							when "01000110" => value(15 downto 12) <= "1001"; -- 9
							when "00011100" => value(15 downto 12) <= "1010"; -- A
							when "00110010" => value(15 downto 12) <= "1011"; -- B
							when "00100001" => value(15 downto 12) <= "1100"; -- C
							when "00100011" => value(15 downto 12) <= "1101"; -- D
							when "00100100" => value(15 downto 12) <= "1110"; -- E
							when "00101011"	=> value(15 downto 12) <= "1111"; -- F
							when others =>
								id <= "1111";
								onoff <= '1';
								command <= "00";
						end case;

					end if;
				
				when S_VALUE2 =>
					if command = "10" then -- 7 segment display 

						case symbol is 
							when "01000101" => value(11 downto 8) <= "0000"; -- 0 
							when "00010110" => value(11 downto 8) <= "0001"; -- 1
							when "00011110" => value(11 downto 8) <= "0010"; -- 2
							when "00100110" => value(11 downto 8) <= "0011"; -- 3
							when "00100101" => value(11 downto 8) <= "0100"; -- 4
							when "00101110" => value(11 downto 8) <= "0101"; -- 5
							when "00110110" => value(11 downto 8) <= "0110"; -- 6
							when "00111101" => value(11 downto 8) <= "0111"; -- 7
							when "00111110" => value(11 downto 8) <= "1000"; -- 8
							when "01000110" => value(11 downto 8) <= "1001"; -- 9
							when "00011100" => value(11 downto 8) <= "1010"; -- A
							when "00110010" => value(11 downto 8) <= "1011"; -- B
							when "00100001" => value(11 downto 8) <= "1100"; -- C
							when "00100011" => value(11 downto 8) <= "1101"; -- D
							when "00100100" => value(11 downto 8) <= "1110"; -- E
							when "00101011"	=> value(11 downto 8) <= "1111"; -- F
							when others =>
								id <= "1111";
								onoff <= '1';
								command <= "00";
						end case;

					end if;
				
				when S_VALUE3 =>
					if command = "10" then -- 7 segment display 

						case symbol is 
							when "01000101" => value(7 downto 4) <= "0000"; -- 0 
							when "00010110" => value(7 downto 4) <= "0001"; -- 1
							when "00011110" => value(7 downto 4) <= "0010"; -- 2
							when "00100110" => value(7 downto 4) <= "0011"; -- 3
							when "00100101" => value(7 downto 4) <= "0100"; -- 4
							when "00101110" => value(7 downto 4) <= "0101"; -- 5
							when "00110110" => value(7 downto 4) <= "0110"; -- 6
							when "00111101" => value(7 downto 4) <= "0111"; -- 7
							when "00111110" => value(7 downto 4) <= "1000"; -- 8
							when "01000110" => value(7 downto 4) <= "1001"; -- 9
							when "00011100" => value(7 downto 4) <= "1010"; -- A
							when "00110010" => value(7 downto 4) <= "1011"; -- B
							when "00100001" => value(7 downto 4) <= "1100"; -- C
							when "00100011" => value(7 downto 4) <= "1101"; -- D
							when "00100100" => value(7 downto 4) <= "1110"; -- E
							when "00101011"	=> value(7 downto 4) <= "1111"; -- F
							when others =>
								id <= "1111";
								onoff <= '1';
								command <= "00";
						end case;
					end if;

				when S_VALUE4 =>
					if command = "10" then -- 7 segment display 
						case symbol is 
							when "01000101" => value(3 downto 0) <= "0000"; -- 0 
							when "00010110" => value(3 downto 0) <= "0001"; -- 1
							when "00011110" => value(3 downto 0) <= "0010"; -- 2
							when "00100110" => value(3 downto 0) <= "0011"; -- 3
							when "00100101" => value(3 downto 0) <= "0100"; -- 4
							when "00101110" => value(3 downto 0) <= "0101"; -- 5
							when "00110110" => value(3 downto 0) <= "0110"; -- 6
							when "00111101" => value(3 downto 0) <= "0111"; -- 7
							when "00111110" => value(3 downto 0) <= "1000"; -- 8
							when "01000110" => value(3 downto 0) <= "1001"; -- 9
							when "00011100" => value(3 downto 0) <= "1010"; -- A
							when "00110010" => value(3 downto 0) <= "1011"; -- B
							when "00100001" => value(3 downto 0) <= "1100"; -- C
							when "00100011" => value(3 downto 0) <= "1101"; -- D
							when "00100100" => value(3 downto 0) <= "1110"; -- E
							when "00101011"	=> value(3 downto 0) <= "1111"; -- F
							when others =>
								id <= "1111";
								onoff <= '1';
								command <= "00";
						end case;
					end if;
				when others => next_state <= S_IDLE;
			end case;

		end if;

	end process;

end Behavioral;

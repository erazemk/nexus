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
		led_id	: out std_logic_vector(3 downto 0);
		cled_id	: out std_logic;
		seg_id	: out std_logic;
		onoff	: out std_logic;
		value	: out std_logic_vector(15 downto 0);
		newchar : out std_logic;
		isready	: in std_logic
	);
end entity;

architecture Behavioral of Executor_Parser is

	type states is (S_IDLE, S_SKIP, S_COMMAND, S_ID, S_ONOFF, S_VALUE1, S_VALUE2, S_VALUE3, S_VALUE4);
	signal state, next_state			: states;
	signal next_space, first_o, skip	: std_logic;
	signal saved_symbol                 : std_logic_vector(7 downto 0);

begin

	process(clock, reset, state, next_space, enable, skip, isready, symbol, first_o, command)
		variable val : std_logic_vector(3 downto 0);
	begin
	
		if rising_edge(clock) then
		
			if reset = '1' then
				state <= S_IDLE;
				parsed <= '0';
				skip <= '0';
				first_o <= '0';
				newchar <= '1';
			else
			    if isready = '1' then
		          saved_symbol <= symbol;
		          newchar <= '0';
		        end if;
	
				-- Next state decode
                if parsed = '0' then
                    --newchar <= '0';
                
                        -- Sync process
                    if saved_symbol /= "01011010" then --ni Enter oz konec ukaza
                        if saved_symbol = "00101001" then --Space
                            next_space <= '1';
                        else
                            next_space <= '0';
                        end if;
        
                        -- Pomnjenje stanja in izhoda
                        state <= next_state;
                        --TODO pomni izhod 	pulse <= output;
                    elsif saved_symbol = "01011010" then --Enter oz konec ukaza
                        parsed <= '1';
                        next_state <= S_IDLE;
                    end if;
				
				    
					--next_state <= state;
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
				end if;
	
				-- Output decode
				case state is 
					when S_IDLE =>
						--
					when S_SKIP =>
						newchar <= '1';
					when S_COMMAND =>
						if saved_symbol = "01001011" then -- saved_symbol = L
							command <= "00";
							skip <= '1';
						elsif saved_symbol = "00100001" then -- saved_symbol = C
							command <= "01";
							skip <= '1';
						elsif saved_symbol = "00011011" then --saved_symbol = S
							command <= "10";
							skip <= '1';
						end if;
						newchar <= '1';
					
					when S_ID =>
						if command = "00" then
							case saved_symbol is 
								when "01000101" => led_id <= "0000"; -- 0
								when "00010110" => led_id <= "0001"; -- 1
								when "00011110" => led_id <= "0010"; -- 2
								when "00100110" => led_id <= "0011"; -- 3
								when "00100101" => led_id <= "0100"; -- 4
								when "00101110" => led_id <= "0101"; -- 5
								when "00110110" => led_id <= "0110"; -- 6
								when "00111101" => led_id <= "0111"; -- 7
								when "00111110" => led_id <= "1000"; -- 8
								when "01000110" => led_id <= "1001"; -- 9
								when "00011100" => led_id <= "1010"; -- A
								when "00110010" => led_id <= "1011"; -- B
								when "00100001" => led_id <= "1100"; -- C
								when "00100011" => led_id <= "1101"; -- D
								when "00100100" => led_id <= "1110"; -- E
								when "00101011"	=> led_id <= "1111"; -- F
								when others =>
									led_id <= "1111";
									onoff <= '1';
							end case; 
						elsif command = "01" then
							case saved_symbol is 
								when "01000101" => cled_id <= '0'; -- 0
								when "00010110" => cled_id <= '1'; -- 1
								when others =>
									led_id <= "1111";
									onoff <= '1';
									command <= "00";
							end case; 					
						elsif command = "10" then
							case saved_symbol is 
								when "01000101" => seg_id <= '0'; -- 0
								when "00010110" => seg_id <= '1'; -- 1
								when others =>
									led_id <= "1111";
									onoff <= '1';
									command <= "00";
							end case; 
						else
							led_id <= "1111";
							onoff <= '1';
							command <= "00";
						end if;
						newchar <= '1';
						
					when S_ONOFF =>
						if saved_symbol = "01000100" or first_o = '1' then --saved_symbol = O 
							first_o <= '1';
							if saved_symbol = "00110001" then --saved_symbol = N
								onoff <= '1';
								first_o <= '0';
								
							elsif saved_symbol = "00101011" then --saved_symbol = F
								onoff <= '0';
								first_o <= '0';
								
							end if;
						end if;
						newchar <= '1';
					
					when S_VALUE1 =>
						if command = "01" then	--RGB LED
						
							if saved_symbol = "00011101" then -- saved_symbol = W
								value <= (others => '0');
							elsif saved_symbol = "00101101" then --saved_symbol = R
								value <= (0 => '1', others => '0');
							elsif saved_symbol = "00110100" then --saved_symbol = G
								value <= (1 => '1', others => '0');
							elsif saved_symbol = "00110010" then --saved_symbol = B
								value <= (0 => '1', 1 => '1', others => '0');
							end if;
							
						elsif command = "10" then -- 7 segment display 
	
							--val := value(15 - char_count downto 12 - char_count);
	
							case saved_symbol is 
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
									led_id <= "1111";
									onoff <= '1';
									command <= "00";
							end case;
	
						end if;
					
					when S_VALUE2 =>
						if command = "10" then -- 7 segment display 
	
							case saved_symbol is 
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
									led_id <= "1111";
									onoff <= '1';
									command <= "00";
							end case;
	
						end if;
					
					when S_VALUE3 =>
						if command = "10" then -- 7 segment display 
	
							case saved_symbol is 
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
									led_id <= "1111";
									onoff <= '1';
									command <= "00";
							end case;
						end if;
	
					when S_VALUE4 =>
						if command = "10" then -- 7 segment display 
							case saved_symbol is 
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
									led_id <= "1111";
									onoff <= '1';
									command <= "00";
							end case;
						end if;
					when others => next_state <= S_IDLE;
				end case;
	
			end if;
			
			-- TODO: Toggle newchar before requesting a new character
			--newchar <= '1';

		end if;

	end process;

end architecture;

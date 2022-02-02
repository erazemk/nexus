library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Executor_Parser is
	Port ( 
		clock			: in std_logic;
		reset			: in std_logic;
		symbol			: in std_logic_vector(7 downto 0);
		enable			: in std_logic;
		parsed			: inout std_logic;
		parsed_confirm	: in std_logic;
		command			: inout std_logic_vector(1 downto 0) := (others => '1');
		led_id			: out std_logic_vector(3 downto 0) := (others => '0');
		cled_id			: out std_logic;
		seg_id			: out std_logic;
		onoff			: out std_logic := '0';
		value			: out std_logic_vector(15 downto 0);
		newchar 		: out std_logic := '1';
		isready			: in std_logic
	);
end entity;

architecture Behavioral of Executor_Parser is

	type states is (S_IDLE, S_SKIP, S_COMMAND, S_ID, S_ONOFF, S_VALUE1, S_VALUE2, S_VALUE3, S_VALUE4);
	signal state, next_state			: states;
	signal sig_error, first_o, pulse	: std_logic := '0';
	
	-- State confirmation signals
	signal command_is_set				: std_logic := '0';
	signal id_is_set					: std_logic := '0';
	signal onoff_is_set					: std_logic := '0';
	signal skip_is_set					: std_logic := '0';
	signal value1_is_set				: std_logic := '0';
	signal value2_is_set				: std_logic := '0';
	signal value3_is_set				: std_logic := '0';
	signal value4_is_set				: std_logic := '0';

begin

	SYNC_PROC : process(clock)
	begin
		if rising_edge(clock) then
			if reset = '1' then
				state <= S_IDLE;
				parsed <= '0';
				first_o <= '0';
			elsif parsed_confirm = '1' then
			     parsed <= '0';
			     newchar <= '1';
			elsif isready = '1' and enable = '1' then
				--state <= next_state;
				newchar <= '0';
				pulse <= '1';
			elsif enable = '1' and parsed = '0' then
				state <= next_state;

				if symbol /= "01011010" then -- ni Enter
					--state <= next_state;
--					if state = S_COMMAND and command_is_set = '1' then
--						newchar <= '1';
--					elsif state = S_ID and id_is_set = '1' then
--						newchar <= '1';
--					elsif state = S_ONOFF and onoff_is_set = '1' then
--						newchar <= '1';
--					elsif state = S_VALUE1 and value1_is_set = '1' then
--						newchar <= '1';
--					elsif state = S_VALUE2 and value2_is_set = '1' then
--						newchar <= '1';
--					elsif state = S_VALUE3 and value3_is_set = '1' then
--						newchar <= '1';
--					elsif state = S_VALUE4 and value4_is_set = '1' then
--						newchar <= '1';
--					elsif state = S_SKIP then
--						newchar <= '1';
--					end if;

					if (state = S_COMMAND and command_is_set = '1') or
						(state = S_ID and id_is_set = '1') or
						(state = S_ONOFF and onoff_is_set = '1') or
						(state = S_VALUE1 and value1_is_set = '1') or
						(state = S_VALUE2 and value2_is_set = '1') or
						(state = S_VALUE3 and value3_is_set = '1') or
						(state = S_VALUE4 and value4_is_set = '1') or
						(state = S_SKIP) then
							newchar <= '1';
							pulse <= '0';
					end if;
				elsif symbol = "01011010" then -- Enter
					state <= S_IDLE;
					parsed <= '1';
				end if;
			end if;
		end if;
	end process;

	NEXT_STATE_DECODE : process(state, pulse, symbol, enable)
	begin
		case state is
			when S_IDLE =>
				if enable = '1' then
					next_state <= S_COMMAND;
				end if;
			when S_COMMAND =>
				if pulse = '1' and command_is_set = '1' then
					next_state <= S_SKIP;
				end if;
			when S_ID =>
				if pulse = '1' and id_is_set = '1' then
					next_state <= S_ONOFF;
				end if;
			when S_ONOFF =>
				if pulse = '1' and onoff_is_set = '1' then
					if symbol = "00101001" then -- Space
						next_state <= S_VALUE1;
					elsif symbol = "01011010" then -- Enter
						next_state <= S_IDLE;
					end if;
				end if;
			when S_SKIP =>
				if pulse = '1' and skip_is_set = '1' then -- Space
					next_state <= S_ID;
				end if;
			when S_VALUE1 =>
				if pulse = '1' and value1_is_set = '1' then
					next_state <= S_VALUE2;
				end if;
			when S_VALUE2 =>
				if pulse = '1' and value2_is_set = '1' then
					next_state <= S_VALUE3;
				end if;
			when S_VALUE3 =>
				if pulse = '1' and value3_is_set = '1' then
					next_state <= S_VALUE4;
				end if;
			when S_VALUE4 =>
				if pulse = '1' and value4_is_set = '1' then
					next_state <= S_IDLE;
				end if;
			when others => next_state <= S_IDLE;
		end case;
	end process;
	
	OUTPUT : process(state, symbol, pulse, command_is_set, command,enable)
	begin
		case state is 
			when S_IDLE =>
				if enable = '1' then
					command_is_set <= '0';
					id_is_set <= '0';
					skip_is_set <= '0';
					onoff_is_set <= '0';
					value1_is_set <= '0';
					value2_is_set <= '0';
					value3_is_set <= '0';
					value4_is_set <= '0';
				end if;
			when S_SKIP =>
			    if symbol = "00101001" then -- space
			        skip_is_set <= '1';
			    end if;
			when S_COMMAND =>
				if pulse = '1' then
					if command_is_set <= '0' and symbol = "01001011" then -- L
						command <= "00";
					elsif command_is_set <= '0' and symbol = "00100001" then -- C
						command <= "01";
					elsif command_is_set <= '0' and symbol = "00011011" then -- S
						command <= "10";
					end if;
					
					command_is_set <= '1';
				end if;
			when S_ID =>
				if pulse = '1' then
					if command = "00" then
						case symbol is 
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
							when others => sig_error <= '1';
						end case;
					elsif command = "01" then
						case symbol is 
							when "01000101" => cled_id <= '0'; -- 0
							when "00010110" => cled_id <= '1'; -- 1
							when others => sig_error <= '1';
						end case; 					
					elsif command = "10" then
						case symbol is 
							when "01000101" => seg_id <= '0'; -- 0
							when "00010110" => seg_id <= '1'; -- 1
							when others => sig_error <= '1';
						end case;
					end if;
					
					id_is_set <= '1';
				end if;
			when S_ONOFF =>
				if pulse = '1' then
					if symbol = "00110001" then -- N
						onoff <= '1';
						first_o <= '0';
					elsif symbol = "00101011" then -- F
						onoff <= '0';
						first_o <= '0';
					end if;
					
					onoff_is_set <= '1';
				end if;
			when S_VALUE1 =>
				if pulse = '1' then
					if command = "01" then -- RGB LED
						if symbol = "00011101" then -- W
							value <= (others => '0');
						elsif symbol = "00101101" then -- R
							value <= (0 => '1', others => '0');
						elsif symbol = "00110100" then -- G
							value <= (1 => '1', others => '0');
						elsif symbol = "00110010" then -- B
							value <= (0 => '1', 1 => '1', others => '0');
						end if;
					elsif command = "10" then -- 7 segment display
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
							when others => sig_error <= '1';
						end case;
					end if;
					
					value1_is_set <= '1';
				end if;
			when S_VALUE2 =>
				if pulse = '1' and command = "10" then -- Safety check (should only happen with 7-seg display)
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
						when others => sig_error <= '1';
					end case;
					
					value2_is_set <= '1';
				end if;
			when S_VALUE3 =>
				if pulse = '1' and command = "10" then -- Safety check (should only happen with 7-seg display)
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
						when others => sig_error <= '1';
					end case;

					value3_is_set <= '1';
				end if;
			when S_VALUE4 =>
				if pulse = '1' and command = "10" then -- Safety check (should only happen with 7-seg display)
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
						when others => sig_error <= '1';
					end case;

					value4_is_set <= '1';
				end if;
			when others => sig_error <= '1';
		end case;
	end process;

end architecture;

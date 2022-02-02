library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Executor_Parser is
	Port ( 
		clock			: in std_logic;
		reset			: in std_logic;
		char			: in std_logic_vector(7 downto 0);
		start_parsing	: in std_logic;
		parsed_confirm	: in std_logic;
		char_is_ready	: in std_logic;
		parsed			: out std_logic := '0';
		command			: out std_logic := '0';
		id				: out std_logic_vector(3 downto 0) := (others => '0');
		onoff			: out std_logic := '0';
		value			: out std_logic_vector(1 downto 0) := (others => '0');
		wanted_char_at	: out std_logic_vector(8 downto 0) := (others => '0'); 
		want_new_char	: out std_logic := '0'
	);
end entity;

architecture Behavioral of Executor_Parser is
	
	signal sig_command : std_logic := '0';
	signal sig_id : std_logic_vector(3 downto 0) := (others => '0');
	signal sig_onoff : std_logic := '0';
	signal sig_value : std_logic_vector(1 downto 0) := (others => '0');
	signal line_counter : unsigned(4 downto 0) := (others => '0');
	signal argument_counter : unsigned(1 downto 0) := (others => '0');
	signal sig_error : std_logic := '0'; -- Should never be 1

begin

	PARSE : process(clock)
	begin
	
		if rising_edge(clock) then
			if reset = '1' then
				sig_command <= '0';
				sig_id <= (others => '0');
				sig_onoff <= '0';
				line_counter <= (others => '0');
				argument_counter <= (others => '0');
				parsed <= '0';
				command <= '0';
				onoff <= '0';
				wanted_char_at <= (others => '0');
				want_new_char <= '0';
			elsif parsed_confirm = '1' then
				parsed <= '0';
			elsif parsed_confirm = '0' and start_parsing = '1' then
				if char_is_ready = '0' and argument_counter <= 3 then
					-- Command: 0, id: 4, state: 7
					wanted_char_at <= std_logic_vector(unsigned(line_counter & "0000") + argument_counter);
					want_new_char <= '1';
				else
					want_new_char <= '0';
					if argument_counter = 0 then -- Command
						case char is
							when "01001011" => sig_command <= '0'; -- L
							when "00100001" => sig_command <= '1'; -- C
							when others => sig_error <= '1';
						end case;
						argument_counter <= argument_counter + 1;
					elsif argument_counter = 1 then -- Id
						case char is
							when "01000101" => sig_id <= "0000"; -- 0
							when "00010110" => sig_id <= "0001"; -- 1
							when "00011110" => sig_id <= "0010"; -- 2
							when "00100110" => sig_id <= "0011"; -- 3
							when "00100101" => sig_id <= "0100"; -- 4
							when "00101110" => sig_id <= "0101"; -- 5
							when "00110110" => sig_id <= "0110"; -- 6
							when "00111101" => sig_id <= "0111"; -- 7
							when "00111110" => sig_id <= "1000"; -- 8
							when "01000110" => sig_id <= "1001"; -- 9
							when "00011100" => sig_id <= "1010"; -- A
							when "00110010" => sig_id <= "1011"; -- B
							when "00100001" => sig_id <= "1100"; -- C
							when "00100011" => sig_id <= "1101"; -- D
							when "00100100" => sig_id <= "1110"; -- E
							when "00101011"	=> sig_id <= "1111"; -- F
							when "01001011" => sig_id <= "1110"; -- L
							when "00110001" => sig_id <= "1101"; -- N
							when others => sig_id <= "1111";
						end case;
						argument_counter <= argument_counter + 1;
					elsif argument_counter = 2 then  -- State
						case char is
							when "00110001" => sig_onoff <= '1'; -- N
							when "00101011" => sig_onoff <= '0'; -- F
							when others => sig_error <= '1';
						end case;
						argument_counter <= argument_counter + 1;
					elsif sig_command = '1' and argument_counter = 3 then -- Value
						case char is
							when "00000000" => sig_value <= "00"; -- White
							when "00101101" => sig_value <= "01"; -- Red
							when "00110100" => sig_value <= "10"; -- Green
							when "00110010" => sig_value <= "11"; -- Blue
							when others => sig_error <= '1';
						end case;
					else -- Finished parsing
						parsed <= '1';
						line_counter <= line_counter + 1;
						command <= sig_command;
						id <= sig_id;
						onoff <= sig_onoff;
						value <= sig_value;
						sig_command <= '0';
						sig_value <= (others => '0');
						sig_onoff <= '0';
						sig_id <= (others => '0');
						argument_counter <= (others => '0');
					end if;
				end if;
			end if;		
		end if;

	end process;

end architecture;

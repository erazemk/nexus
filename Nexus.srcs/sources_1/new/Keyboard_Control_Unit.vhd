library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity Keyboard_Control_Unit is
    port (
		clk     : in  std_logic;
		rst     : in  std_logic;
		kdata_s : in  std_logic;
		pulse   : in  std_logic;
		we      : out std_logic;
		eot     : out std_logic
	);
end entity;

architecture Behavioral of Keyboard_Control_Unit is
    -- STANJA
	type state_type is (
		S_IDLE, S_START,
		S_B0, S_B1, S_B2, S_B3, S_B4, S_B5, S_B6, S_B7,
		S_PAR
	);
	signal state, next_state     : state_type;

	signal output_we, output_eot : std_logic;
begin
    -- REGISTER STANJA
	SYNC_PROC : process (clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				-- ponastavi stanje 
				state <= S_IDLE;
				we    <= '0';
				eot   <= '0';
			else
				state <= next_state;
				we    <= output_we;
				eot   <= output_eot;
			end if;
		end if;
	end process;

	-- LOGIKA PREHAJANJA STANJ 
	NEXT_STATE_DECODE : process (kdata_s, pulse, state)
	begin
		-- Privzeto ostanemo v istem stanju.
		next_state <= state;
		-- Sedaj pokrijemo samo tiste primere, ko stanje spremenimo.
		case state is
			when S_IDLE =>
				if kdata_s = '0' and pulse = '1' then
					next_state <= S_START;
				end if;

			when S_START =>
				if pulse = '1' then
					next_state <= S_B0;
				end if;
			when S_B0 =>
				if pulse = '1' then
					next_state <= S_B1;
				end if;
			when S_B1 =>
				if pulse = '1' then
					next_state <= S_B2;
				end if;
			when S_B2 =>
				if pulse = '1' then
					next_state <= S_B3;
				end if;
			when S_B3 =>
				if pulse = '1' then
					next_state <= S_B4;
				end if;
			when S_B4 =>
				if pulse = '1' then
					next_state <= S_B5;
				end if;
			when S_B5 =>
				if pulse = '1' then
					next_state <= S_B6;
				end if;
			when S_B6 =>
				if pulse = '1' then
					next_state <= S_B7;
				end if;
			when S_B7 =>
				if pulse = '1' then
					next_state <= S_PAR;
				end if;
			when S_PAR =>
				if pulse = '1' and kdata_s = '1' then
					next_state <= S_IDLE;
				end if;
			when others =>
				-- sem nikoli ne pridemo, mora pa biti,
				-- da sintetizator ne bo delal pomnilnega vezja
				next_state <= S_IDLE;
		end case;
	end process;

	-- LOGIKA IZHODA
	-- Izhoda sta we in eot
	OUTPUT_DECODE : process (kdata_s, pulse, state)
	begin
		-- Privzeta vrednost
		output_we  <= '0';
		output_eot <= '0';

		case state is
			when S_IDLE =>
				-- Tu bi lahko zavoljo konsistence upotevali tudi pulse (if pulse='1')
				output_we  <= '0';
				output_eot <= '0';

			when S_START | S_B0 | S_B1 | S_B2 | S_B3 | S_B4 | S_B5 | S_B6 | S_B7 =>
				if pulse = '1' then
					output_we  <= '1';
					output_eot <= '0';
				end if;

			when S_PAR =>
				if pulse = '1' and kdata_s = '1' then
					output_we  <= '0';
					output_eot <= '1';
				end if;
			when others =>
				-- sem nikoli ne pridemo, mora pa biti,
				-- da sintetizator ne bo delal pomnilnega vezja
				output_we  <= '0';
				output_eot <= '0';
		end case;
	end process;

end architecture;

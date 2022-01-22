library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Keyboard_Pulse_Generator is
    port (
		clk    : in  std_logic;
		rst    : in  std_logic;
		kclk_s : in  std_logic;
		pulse  : out std_logic
	);
end entity;

architecture Behavioral of Keyboard_Pulse_Generator is
    -- STANJA 
	-- Definiramo nov "steven" podatkovni tip (enumerated type).
	-- Orodje za sintezo izbere najbolji naèin kodiranja stanj
	type state_type is (S_IDLE, S_PULSE_ON, S_WAIT);
	signal state, next_state : state_type;
	-- Izhod avtomata
	signal output            : std_logic;
begin
    -- REGISTER STANJA
	-- Pomnilno (sekvenèno vezje), ki vsako urino fronto osveuje 
	-- stanje avtomata, s(t) <= s(t+1), in skrbi tudi za pomnjenje izhoda,
	-- da se prepreèi pojav napetostnih konic (trava, ang. glitches).
	SYNC_PROC : process (clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				-- Ponastavi stanje 
				state <= S_IDLE;
				pulse <= '0';
			else
				-- Pomnjenje stanja in izhoda
				state <= next_state;
				pulse <= output;
			end if;
		end if;
	end process;

	-- LOGIKA PREHAJANJA STANJ
	-- Naslednje stanje je odvisno od trenutnega stanja in vhoda
	NEXT_STATE_DECODE : process (kclk_s, state)
	begin
		-- Privzeto ostanemo v istem stanju.
		-- S tem stavkom se elegantno resimo "else" dela stavkov if spodaj.
		next_state <= state;
		-- Sedaj pokrijemo samo tiste primere, ko stanje spremenimo.
		case state is
			when S_IDLE =>
				if kclk_s = '0' then
					next_state <= S_PULSE_ON;
				end if;
			when S_PULSE_ON =>
				-- Ta prehod se zgodi ne glede na vsebino vhodov,
				-- zgodi pa se cez eno periodo ure.
				--if kclk_s='0' or kclk_s='1' then 
				next_state <= S_WAIT;
				--end if;
			when S_WAIT =>
				if kclk_s = '1' then
					next_state <= S_IDLE;
				end if;
			when others =>

				next_state <= S_IDLE;
		end case;
	end process;

	-- LOGIKA IZHODA 
	-- Izhod je odvisen od trenutnega stanja in vhoda (tip Mealy)
	OUTPUT_DECODE : process (kclk_s, state)
	begin
		-- Privzeta vrednost
		output <= '0';
		case state is
			when S_IDLE =>
				if kclk_s = '0' then
					output <= '1';
				end if;
			when S_PULSE_ON | S_WAIT =>
				output <= '0';
			when others =>
				-- Sem nikoli ne pridemo
				output <= '0';
		end case;
	end process;


end architecture;

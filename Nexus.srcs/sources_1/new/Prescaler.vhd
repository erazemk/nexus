library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity Prescaler is

	Generic (
		max_value	: integer := 255
	);
	
	Port (
		clock	: in std_logic;
		reset	: in std_logic;
		enable	: out std_logic
	);

end Prescaler;

architecture Behavioral of Prescaler is

	constant width : natural := integer(ceil(log2(real(max_value)))); -- Calculates required width based on max_value
	signal count : unsigned(width - 1 downto 0) := (others => '0');

begin

	process(reset)
	begin
	
		if reset = '1' then
			count <= (others => '0');
			enable <= '0';
		end if;
	
	end process;
	
	process(clock)
	begin

		if rising_edge(clock) then
			if count >= max_value - 1 then
				count <= (others => '0');
				enable <= '1';
			else
				count <= count + 1;
				enable <= '0';
			end if;
		end if;

	end process;

end Behavioral;

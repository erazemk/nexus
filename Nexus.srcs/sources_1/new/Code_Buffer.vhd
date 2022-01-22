library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- 30 lines x 16 characters
entity Code_Buffer is
	Port (
		clock	: in std_logic;
		we		: in std_logic;
		addrIn	: in std_logic_vector(4 downto 0);
		addrOut	: in std_logic_vector(4 downto 0);
		dataIn	: in std_logic_vector(0 to 15);
		dataOut	: out std_logic_vector(0 to 15)
	);
end entity;

architecture Behavioral of Code_Buffer is
	
	-- Array of lines of code (e.g. 'LED 0 ON')
	type RAM_type is array (0 to 31) of std_logic_vector(0 to 15);
	signal buf : RAM_type := (others => (others => '0'));

begin

	-- Async reading
	dataOut <= buf(to_integer(unsigned(addrOut)));
	
	-- Sync writing
	sync_writing: process(clock)
	begin
		
		if rising_edge(clock) then
			if we = '1' then
				buf(to_integer(unsigned(addrIn))) <= dataIn;
			end if;
		end if;
		
	end process;
	
end architecture;

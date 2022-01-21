library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity VGA_Array is
    Port (
        clock		: in std_logic;
		reset	    : in std_logic;
        read        : in std_logic;
        charready   : in std_logic;
        column	    : in unsigned (9 downto 0);
		row 	    : in unsigned (9 downto 0);
		matrix    	: in std_logic_vector (16*9-1 downto 0);
		getchar	    : out std_logic := '0';
		red	      	: out std_logic_vector (3 downto 0) := (others => '0');
		green     	: out std_logic_vector (3 downto 0) := (others => '0');
		blue      	: out std_logic_vector (3 downto 0) := (others => '0')
    );
end VGA_Array;

architecture Behavioral of VGA_Array is
--Višina ene črke je 16px, dolžina pa je celotni zaslon z 640px
type memory_type is array (0 to 15) of std_logic_vector(0 to 639);
    signal memory : memory_type := (others => (others => '0'));
signal write_column: integer := 0;   
begin

process(clock)
    begin
        if rising_edge(clock) then
            if reset='1'  then
                write_column <= 0;
                red <= (others => '0');
                green <= (others => '0');
                blue <= (others => '0');
                memory <= (others => (others => '0'));
            else
                if read='1' then
                    case memory(to_integer(row) mod 16)(to_integer(column)) is
                        when '1' =>
                            red <= "1111";
                            green <= "1111";
                            blue <= "1111";
                        when others =>
                            red <= "0000";
                            green <= "0000";
                            blue <= "0000";
                        end case;    
                    write_column <= 0;
                elsif charready='1' and write_column < 639 then
                    getchar <= '1';
                       
                    memory(0)(write_column + 8 downto write_column) <= matrix(8 downto 0);
                    memory(1)(write_column + 8 downto write_column) <= matrix(17 downto 9);
                    memory(2)(write_column + 8 downto write_column) <= matrix(26 downto 18);
                    memory(3)(write_column + 8 downto write_column) <= matrix(35 downto 27);
                    memory(4)(write_column + 8 downto write_column) <= matrix(44 downto 36);
                    memory(5)(write_column + 8 downto write_column) <= matrix(53 downto 45);
                    memory(6)(write_column + 8 downto write_column) <= matrix(62 downto 54);
                    memory(7)(write_column + 8 downto write_column) <= matrix(71 downto 63);
                    memory(8)(write_column + 8 downto write_column) <= matrix(80 downto 72);
                    memory(9)(write_column + 8 downto write_column) <= matrix(89 downto 81);
                    memory(10)(write_column + 8 downto write_column) <= matrix(98 downto 90);
                    memory(11)(write_column + 8 downto write_column) <= matrix(107 downto 99);
                    memory(12)(write_column + 8 downto write_column) <= matrix(116 downto 108);
                    memory(13)(write_column + 8 downto write_column) <= matrix(125 downto 117);
                    memory(14)(write_column + 8 downto write_column) <= matrix(134 downto 126);
                    memory(15)(write_column + 8 downto write_column) <= matrix(143 downto 135);

                    write_column <= write_column + 9;
                    
                else 
                    getchar <= '0';
                    red <= "0000";
                    green <= "0000";
                    blue <= "0000";
                end if;
            end if;
        end if;
    end process;

end Behavioral;
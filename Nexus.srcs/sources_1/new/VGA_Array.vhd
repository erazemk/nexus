library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity VGA_Array is
    Port (
        clock		: in std_logic;
		reset	    : in std_logic;
        read        : in std_logic;
        write       : in std_logic;
        column	    : in unsigned (9 downto 0);
		row 	    : in unsigned (9 downto 0);
		data        : in std_logic_vector (0 to 7) := (others => '0');
		offset      : out std_logic_vector (3 downto 0) := (others => '0');
		getchar	    : out std_logic := '0';
		red	      	: out std_logic_vector (3 downto 0) := (others => '0');
		green     	: out std_logic_vector (3 downto 0) := (others => '0');
		blue      	: out std_logic_vector (3 downto 0) := (others => '0');
	    RGB_bck     : in std_logic_vector (11 downto 0) := (others => '0')
    );
end VGA_Array;

architecture Behavioral of VGA_Array is
--Visina ene crke je 16px, dolzina pa je celotni zaslon z 640px

type memory_type is array (0 to 15) of std_logic_vector(0 to 639);
    signal memory       : memory_type := (others => (others => '0'));
    
    signal write_column : integer := 0;
    signal i            :  std_logic_vector(4 downto 0) := "10001";

begin
process(clock)
    begin
        if rising_edge(clock) then
            if reset='1'  then
                write_column <= 0;
                i <= "10001";
                offset <= (others => '0');
                red <= (others => '0');
                green <= (others => '0');
                blue <= (others => '0');
                memory <= (others => (others => '0'));
            else
                if read='1' then
                    if memory(to_integer(row(3 downto 0)))(to_integer(column)) = '1' then
                        red <= "1111";
                        green <= "1111";
                        blue <= "1111";
                    else    
                        red <= RGB_bck(3 downto 0);
                        green <= RGB_bck(7 downto 4);
                        blue <= RGB_bck(11 downto 8);
                    end if;    
                    write_column <= 0;
                elsif write = '1' and  write_column < 128 then  
                    if  i(4) = '0' then
                        memory(to_integer(unsigned(i)))(write_column to write_column + 7) <= data;
                        i <= std_logic_vector(unsigned(i) + 1); 
                        offset <= std_logic_vector(i(3 downto 0));            
                    elsif i= "10000" then
                        write_column <= write_column + 8;
                        i <= std_logic_vector(unsigned(i) + 1); 
                        offset <= (others => '0'); 
                    --Pravi zacetek
                    elsif i= "10001" then
                        getchar <= '1';
                        i <= std_logic_vector(unsigned(i) + 1); 
                    elsif i(2) = '0' then
                        getchar <= '0';
                        i <= std_logic_vector(unsigned(i) + 1); 
                    else
                        i <= "00000";
                    end if;
                else 
                    red <= (others => '0');
                    green <= (others => '0');
                    blue <= (others => '0');
                end if;
            end if;
        end if;
    end process;

end architecture;
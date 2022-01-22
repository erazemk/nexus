----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 22.01.2022 12:44:50
-- Design Name: 
-- Module Name: VGA_PS2ID_To_ASCII - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity VGA_PS2ID_To_ASCII is
    Port (
      clk       : in std_logic;
      ps2id     : in std_logic_vector(7 downto 0);
      ascii     : out std_logic_vector(7 downto 0)
    );
end entity;

architecture Behavioral of VGA_PS2ID_To_ASCII is

begin
  process(clk)
  begin
    case ps2id IS
                WHEN x"1E" => ascii <= x"00"; --^@  NUL
                WHEN x"1C" => ascii <= x"01"; --^A  SOH
                WHEN x"32" => ascii <= x"02"; --^B  STX
                WHEN x"21" => ascii <= x"03"; --^C  ETX
                WHEN x"23" => ascii <= x"04"; --^D  EOT
                WHEN x"24" => ascii <= x"05"; --^E  ENQ
                WHEN x"2B" => ascii <= x"06"; --^F  ACK
                WHEN x"34" => ascii <= x"07"; --^G  BEL
                WHEN x"33" => ascii <= x"08"; --^H  BS
                WHEN x"43" => ascii <= x"09"; --^I  HT
                WHEN x"3B" => ascii <= x"0A"; --^J  LF
                WHEN x"42" => ascii <= x"0B"; --^K  VT
                WHEN x"4B" => ascii <= x"0C"; --^L  FF
                WHEN x"3A" => ascii <= x"0D"; --^M  CR
                WHEN x"31" => ascii <= x"0E"; --^N  SO
                WHEN x"44" => ascii <= x"0F"; --^O  SI
                WHEN x"4D" => ascii <= x"10"; --^P  DLE
                WHEN x"15" => ascii <= x"11"; --^Q  DC1
                WHEN x"2D" => ascii <= x"12"; --^R  DC2
                WHEN x"1B" => ascii <= x"13"; --^S  DC3
                WHEN x"2C" => ascii <= x"14"; --^T  DC4
                WHEN x"3C" => ascii <= x"15"; --^U  NAK
                WHEN x"2A" => ascii <= x"16"; --^V  SYN
                WHEN x"1D" => ascii <= x"17"; --^W  ETB
                WHEN x"22" => ascii <= x"18"; --^X  CAN
                WHEN x"35" => ascii <= x"19"; --^Y  EM
                WHEN x"1A" => ascii <= x"1A"; --^Z  SUB
                WHEN x"54" => ascii <= x"1B"; --^[  ESC
                WHEN x"5D" => ascii <= x"1C"; --^\  FS
                WHEN x"5B" => ascii <= x"1D"; --^]  GS
                WHEN x"36" => ascii <= x"1E"; --^^  RS
                WHEN x"4E" => ascii <= x"1F"; --^_  US
                WHEN x"4A" => ascii <= x"7F"; --^?  DEL
                
                WHEN x"29" => ascii <= x"20"; --space
                WHEN x"66" => ascii <= x"08"; --backspace (BS control code)
                WHEN x"0D" => ascii <= x"09"; --tab (HT control code)
                WHEN x"5A" => ascii <= x"0D"; --enter (CR control code)
                WHEN x"76" => ascii <= x"1B"; --escape (ESC control code)
                
                WHEN x"1C" => ascii <= x"41"; --A
                WHEN x"32" => ascii <= x"42"; --B
                WHEN x"21" => ascii <= x"43"; --C
                WHEN x"23" => ascii <= x"44"; --D
                WHEN x"24" => ascii <= x"45"; --E
                WHEN x"2B" => ascii <= x"46"; --F
                WHEN x"34" => ascii <= x"47"; --G
                WHEN x"33" => ascii <= x"48"; --H
                WHEN x"43" => ascii <= x"49"; --I
                WHEN x"3B" => ascii <= x"4A"; --J
                WHEN x"42" => ascii <= x"4B"; --K
                WHEN x"4B" => ascii <= x"4C"; --L
                WHEN x"3A" => ascii <= x"4D"; --M
                WHEN x"31" => ascii <= x"4E"; --N
                WHEN x"44" => ascii <= x"4F"; --O
                WHEN x"4D" => ascii <= x"50"; --P
                WHEN x"15" => ascii <= x"51"; --Q
                WHEN x"2D" => ascii <= x"52"; --R
                WHEN x"1B" => ascii <= x"53"; --S
                WHEN x"2C" => ascii <= x"54"; --T
                WHEN x"3C" => ascii <= x"55"; --U
                WHEN x"2A" => ascii <= x"56"; --V
                WHEN x"1D" => ascii <= x"57"; --W
                WHEN x"22" => ascii <= x"58"; --X
                WHEN x"35" => ascii <= x"59"; --Y
                WHEN x"1A" => ascii <= x"5A"; --Z
                
                WHEN x"45" => ascii <= x"30"; --0
                WHEN x"16" => ascii <= x"31"; --1
                WHEN x"1E" => ascii <= x"32"; --2
                WHEN x"26" => ascii <= x"33"; --3
                WHEN x"25" => ascii <= x"34"; --4
                WHEN x"2E" => ascii <= x"35"; --5
                WHEN x"36" => ascii <= x"36"; --6
                WHEN x"3D" => ascii <= x"37"; --7
                WHEN x"3E" => ascii <= x"38"; --8
                WHEN x"46" => ascii <= x"39"; --9
                WHEN x"52" => ascii <= x"27"; --'
                WHEN x"41" => ascii <= x"2C"; --,
                WHEN x"4E" => ascii <= x"2D"; ---
                WHEN x"49" => ascii <= x"2E"; --.
                WHEN x"4A" => ascii <= x"2F"; --/
                WHEN x"4C" => ascii <= x"3B"; --;
                WHEN x"55" => ascii <= x"3D"; --=
                WHEN x"54" => ascii <= x"5B"; --[
                WHEN x"5D" => ascii <= x"5C"; --\
                WHEN x"5B" => ascii <= x"5D"; --]
                WHEN x"0E" => ascii <= x"60"; --`
                
                WHEN others => ascii <= x"00"; --
                                              
        end case;
    end process;
end architecture;

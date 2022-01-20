----------------------------------------------------------------------------------
-- Projekt: Krmilnik VGA
-- Verzija: 3. 11. 2021
-- Modul za vodoravno sinhronizacijo
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity VGA_HSync_Instance is
    Port (
        clk:     in  std_logic;            -- ura (globalna)
        rst:     in  std_logic;            -- ponastavitev vezja
        hsync:   out std_logic;            -- vodoravni sinhronizacijski signal
        ce:      out std_logic;            -- "clock enable", ki naznani konec vrstice
        display: out std_logic;            -- ali smo v vidnem delu zaslona
        column:  out unsigned(9 downto 0)  -- trenutni odmik piksla v vidnem delu zaslona
    );
end entity;

architecture Behavioral of VGA_HSync_Instance is
    -----------------------------------------------------------
    -- SIGNALI
    -----------------------------------------------------------
    -- Stevec steje do 4*T-1, torej mora biti vsaj 12 biten
    signal count:     unsigned(11 downto 0);
    signal column_i:  unsigned(11 downto 0);
    signal sync_on:   std_logic;
    signal sync_off:  std_logic;
    signal q:         std_logic;
    signal display_i: std_logic;
    -----------------------------------------------------------
    -- KONSTANTE 
    -----------------------------------------------------------
    -- Na predavanjih smo casovne konstante standarda VGA 
    -- pomnozili s 4, ker imamo 100 MHz sistemsko uro,
    -- dolocili pa smo jih pri predpostavki 25 MHz ure.
    constant SP:       integer := 96*4;  -- sync pulse (96*40 ns)
    constant T:        integer := 800*4; -- cas periode (32 us)
    constant BP:       integer := 48*4;  -- back porch
    constant FP:       integer := 16*4;  -- front porch
    
begin
    -----------------------------------------------------------
    -- VZPOREDNI STAVKI - odlocitveno vezje
    -----------------------------------------------------------
    -- Prirejanje V/I 
    hsync <= q;
    ce <= sync_off;
    display <= display_i;

    -- Primerjalnik za SP 
    sync_on <= '1' when count=(SP-1) else '0';

    -- Primerjalnik za T
    sync_off <= '1' when count=T-1 else '0';
    
    -- Kdaj smo v obmocju prikaza slike (display area), ko 
    -- lahko delujejo elektronski topovi. 
    display_i <= '1' when count >= (SP+BP) and count < (T-FP) else '0';

    -- Preslikava prestetih urinih ciklov na stolpce v vidnem delu zaslona.
    column_i <= (count-SP-BP)/4 when display_i='1' else (others=> '0');
    column <= column_i(9 downto 0); 
    
    -----------------------------------------------------------
    -- PROCESI
    -----------------------------------------------------------
    stevec: process(clk)
    begin
        -- Reagiramo na pozitivno fronto ure 
        if rising_edge(clk) then
            if rst='1' or sync_off='1' then
                -- Ponastavitev stevca 
                count <= (others => '0');
            else
                -- Stevec povecamo za ena
                count <= count + 1;                
            end if;
        end if;

    end process;

    -- Pomnilna celica JK 
    JK_FF: process(clk)
    begin
        if rising_edge(clk) then
            if rst='1' then
                q <= '0';
            elsif sync_on='1' and sync_off='0' then
                q <= '1';
            elsif sync_off='1' and sync_on='0' then
                q <= '0';
            elsif sync_off='1' and sync_on='1' then
                -- Ta del ni potreben, ker se v nasi aplikacji 
                -- ne more zgoditi, da bi bila oba vhoda hkrati 1.
                q <= not q;
            else
                -- Eksplicitno nakazano pomnjenje;
                -- navadno tega ne pisemo
                q <= q;
            end if;
        end if;
    end process;
end Behavioral;
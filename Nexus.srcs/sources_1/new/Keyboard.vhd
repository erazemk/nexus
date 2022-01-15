library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Keyboard is

	Port (
		clock	: in std_logic;
		reset	: in std_logic;
		kclk	: in  std_logic;
		kdata	: in  std_logic;
		data	: out std_logic_vector (7 downto 0);
		eot		: out std_logic
		--enter	: out std_logic
	);

end Keyboard;

architecture Behavioral of Keyboard is
    
    -- KOMPONENTE
    component Keyboard_Pulse_Generator is
        port (
            clk    : in  std_logic;
            rst    : in  std_logic;
            kclk_s : in  std_logic;
            pulse  : out std_logic);
    end component;

    component Keyboard_Control_Unit is
        port (
            clk     : in  std_logic;
            rst     : in  std_logic;
            kdata_s : in  std_logic;
            pulse   : in  std_logic;
            we      : out std_logic;
            eot     : out std_logic
        );
    end component;

    -- NOTRANJI SIGNALI
    signal pulse                            : std_logic;
    signal kdata_1, kdata_s, kclk_1, kclk_s : std_logic;
    signal we                               : std_logic;
    signal SIPO                             : std_logic_vector(8 downto 0);
    
begin

    -- Prirejanje vhoda/izhoda
    data <= SIPO(7 downto 0);

    -- Instanciranje 
    pulseGen_inst : Keyboard_Pulse_Generator
        port map(
            clk    => clock,
            rst    => reset,
            kclk_s => kclk_s,
            pulse  => pulse
        );

    controlUnit_inst : Keyboard_Control_Unit
        port map(
            clk     => clock,
            pulse   => pulse,
            rst     => reset,
            kdata_s => kdata_s,
            we      => we,
            eot     => eot
        );

    -- Sinhronizacija vhodnih signalov kclk in kdata: 
    -- peljemo ju skozi dve pomnilni celici 
    SYNC_INPUTS : process (clock)
    begin
        if rising_edge(clock) then
            if reset = '1' then
                kclk_1  <= '1';
                kclk_s  <= '1';
                kdata_1 <= '1';
                kdata_s <= '1';
            else
                kclk_1  <= kclk;
                kclk_s  <= kclk_1;
                kdata_1 <= kdata;
                kdata_s <= kdata_1;
            end if;
        end if;
    end process;

    -- Pomikalni register, ki ob we=1 pomakne vsebino
    -- v desno in v levi bit vpi�e bit s tipkovnice.
    -- kdata_s ---> [PAR | B7 | ... | B1 | B0]
    -- SIPO = Serial-In-Parallel-Out
    SIPO_REG : process (clock)
    begin
        if rising_edge(clock) then
            if reset = '1' then
                SIPO <= (others => '0');
            else
                if we = '1' then
                    -- operator konkatenacije je &
                    SIPO <= kdata_s & SIPO(8 downto 1);
                end if;
            end if;
        end if;
    end process;


end Behavioral;

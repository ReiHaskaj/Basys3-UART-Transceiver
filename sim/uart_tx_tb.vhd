library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_tx_tb is
end uart_tx_tb;

architecture Behavioral of uart_tx_tb is

    component uart_tx is
        Port(
            clk           : in  std_logic;
            reset         : in  std_logic;
            tx_start      : in  std_logic;
            tx_din        : in  std_logic_vector(7 downto 0);
            tx            : out std_logic;
            tx_done_tick  : out std_logic
        );
    end component;

    signal clk          : std_logic := '0';
    signal reset        : std_logic := '0';
    signal tx_start     : std_logic := '0';
    signal tx_din       : std_logic_vector(7 downto 0) := (others => '0');
    signal tx           : std_logic;
    signal tx_done_tick : std_logic;

    constant CLK_PERIOD : time := 10 ns;         -- 100 MHz
    constant BIT_PERIOD : time := 104166 ns;     -- ~9600 baud

    -- procedure to send a byte
    procedure send_byte(
        signal start_sig : out std_logic;
        signal data_sig  : out std_logic_vector(7 downto 0);
        constant d       : in  std_logic_vector(7 downto 0)
    ) is
    begin
        data_sig  <= d;
        start_sig <= '1';
        wait for CLK_PERIOD;
        start_sig <= '0';
    end procedure;

begin

    -- DUT
    uut : uart_tx
        port map (
            clk          => clk,
            reset        => reset,
            tx_start     => tx_start,
            tx_din       => tx_din,
            tx           => tx,
            tx_done_tick => tx_done_tick
        );

    -- Clock generation
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    -- Stimulus
    stim_proc : process
    begin
        -- Reset
        reset <= '1';
        wait for 100 ns;
        reset <= '0';
        wait for 200 ns;

        -- Send 0x55
        send_byte(tx_start, tx_din, x"55");
        wait for 12 * BIT_PERIOD;

        -- Send 0xA3
        send_byte(tx_start, tx_din, x"A3");
        wait for 12 * BIT_PERIOD;

        -- Send 0xF0
        send_byte(tx_start, tx_din, x"F0");
        wait for 12 * BIT_PERIOD;

        wait;
    end process;

end Behavioral;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_rx_tb is
end uart_rx_tb;

architecture Behavioral of uart_rx_tb is

    component uart_rx is
        Port (
            clk        : in  std_logic;
            restart    : in  std_logic;
            rx         : in  std_logic;
            data_out   : out std_logic_vector(7 downto 0);
            data_valid : out std_logic
        );
    end component;

    signal clk        : std_logic := '0';
    signal restart    : std_logic := '0';
    signal rx         : std_logic := '1';  -- idle line is high
    signal data_out   : std_logic_vector(7 downto 0);
    signal data_valid : std_logic;

    constant CLK_PERIOD : time := 10 ns;               -- 100 MHz
    constant BIT_PERIOD : time := 104166 ns;           -- ~1/9600 s

begin

    uut : uart_rx
        port map (
            clk        => clk,
            restart    => restart,
            rx         => rx,
            data_out   => data_out,
            data_valid => data_valid
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
        -- initial reset
        restart <= '1';
        rx <= '1';
        wait for 100 ns;

        restart <= '0';
        wait for 200 ns;

        -- ==========================
        -- Send UART frame for 0x55
        -- start bit
        -- data bits LSB first
        -- stop bit
        -- ==========================

        -- start bit
        rx <= '0';
        wait for BIT_PERIOD;

        -- data bit 0 = 1
        rx <= '1';
        wait for BIT_PERIOD;

        -- data bit 1 = 0
        rx <= '0';
        wait for BIT_PERIOD;

        -- data bit 2 = 1
        rx <= '1';
        wait for BIT_PERIOD;

        -- data bit 3 = 0
        rx <= '0';
        wait for BIT_PERIOD;

        -- data bit 4 = 1
        rx <= '1';
        wait for BIT_PERIOD;

        -- data bit 5 = 0
        rx <= '0';
        wait for BIT_PERIOD;

        -- data bit 6 = 1
        rx <= '1';
        wait for BIT_PERIOD;

        -- data bit 7 = 0
        rx <= '0';
        wait for BIT_PERIOD;

        -- stop bit
        rx <= '1';
        wait for BIT_PERIOD;

        -- wait some extra time
        wait for 2 * BIT_PERIOD;

        -- second frame example: 0xA3
        -- 0xA3 = 10100011
        -- LSB first -> 1 1 0 0 0 1 0 1

        -- start bit
        rx <= '0';
        wait for BIT_PERIOD;

        rx <= '1'; wait for BIT_PERIOD; -- bit 0
        rx <= '1'; wait for BIT_PERIOD; -- bit 1
        rx <= '0'; wait for BIT_PERIOD; -- bit 2
        rx <= '0'; wait for BIT_PERIOD; -- bit 3
        rx <= '0'; wait for BIT_PERIOD; -- bit 4
        rx <= '1'; wait for BIT_PERIOD; -- bit 5
        rx <= '0'; wait for BIT_PERIOD; -- bit 6
        rx <= '1'; wait for BIT_PERIOD; -- bit 7

        -- stop bit
        rx <= '1';
        wait for BIT_PERIOD;

        wait for 3 * BIT_PERIOD;

        wait;
    end process;

end Behavioral;
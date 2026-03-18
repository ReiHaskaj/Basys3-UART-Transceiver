library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_uart_tb is
end top_uart_tb;

architecture Behavioral of top_uart_tb is

    component top_uart is
      Port (
          clk          : in  std_logic;
          rst          : in  std_logic;
          tx_start     : in  std_logic;
          rx           : in  std_logic;
          tx_din       : in  std_logic_vector(7 downto 0);
          tx_done_tick : out std_logic;
          data_out     : out std_logic_vector(7 downto 0);
          data_valid   : out std_logic;
          tx           : out  std_logic
      );
    end component;

    signal clk          : std_logic := '0';
    signal rst          : std_logic := '0';
    signal tx_start     : std_logic := '0';
    signal tx_din       : std_logic_vector(7 downto 0) := (others => '0');
    signal tx_done_tick : std_logic;
    signal data_out     : std_logic_vector(7 downto 0);
    signal data_valid   : std_logic;
    
    signal rx           : std_logic := '1';
    signal tx           : std_logic;        

    constant CLK_PERIOD : time := 10 ns;
    constant BIT_PERIOD : time := 104166 ns;

begin

    uut : top_uart
        port map (
            clk          => clk,
            rst          => rst,
            tx_start     => tx_start,
            rx           => rx,
            tx_din       => tx_din,
            tx_done_tick => tx_done_tick,
            data_out     => data_out,
            data_valid   => data_valid,
            tx           => tx
        );

    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for CLK_PERIOD/2;
            clk <= '1';
            wait for CLK_PERIOD/2;
        end loop;
    end process;

    stim_proc : process
    begin
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        wait for 100 ns;

        -- Test TX
        tx_din <= x"55";
        tx_start <= '1';
        wait for CLK_PERIOD;
        tx_start <= '0';

        wait for 2 ms;

        -- Test RX with byte x"A3"
        -- start bit
        rx <= '0';
        wait for BIT_PERIOD;

        -- data bits LSB first for x"A3" = 10100011
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

        wait for 2 ms;

        wait;
    end process;
    

end Behavioral;
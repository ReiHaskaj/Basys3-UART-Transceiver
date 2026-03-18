library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_uart is
  Port ( clk, rst, tx_start, rx : IN std_logic;
         tx_din : IN std_logic_vector(7 downto 0);
         tx, tx_done_tick : OUT std_logic;
         data_out : OUT std_logic_vector(7 downto 0);
         data_valid : OUT std_logic);
end top_uart;

architecture Structural of top_uart is

component uart_rx is
  Port ( clk, restart, rx : IN std_logic;
         data_out : OUT std_logic_vector(7 downto 0);
         data_valid : OUT std_logic );
end component;

component uart_tx is
    Port( clk, reset, tx_start : IN std_logic;
          tx_din : IN std_logic_vector(7 downto 0);
          tx : OUT std_logic;
          tx_done_tick : OUT std_logic);
end component;

signal tx_wire : std_logic;

begin

                            

transmitter : uart_tx PORT MAP( clk => clk,
                                reset => rst,
                                tx_start => tx_start,
                                tx_din => tx_din,
                                tx => tx, --was tx_wire
                                tx_done_tick => tx_done_tick);
                                
receiver : uart_rx PORT MAP (   clk => clk,
                                restart => rst,
                                rx => rx,  --Loopback, was tx_wire
                                data_out => data_out,
                                data_valid => data_valid);                                


end Structural;
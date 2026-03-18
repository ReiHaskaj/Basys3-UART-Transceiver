library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_tx is
    Port( clk, reset, tx_start : IN std_logic;
          tx_din : IN std_logic_vector(7 downto 0);
          tx : OUT std_logic;
          tx_done_tick : OUT std_logic);
end uart_tx;

architecture Behavioral of uart_tx is

type states is (idle, start, data, stop);
signal current_state, next_state : states;

component baud_rate_generator is
    Port ( clk : IN std_logic;
           --start : IN std_logic;
           output_prescaler : OUT std_logic_vector(9 downto 0);
           output_bit_counter : OUT std_logic );
end component;

signal pe : std_logic_vector(9 downto 0);
signal tick : std_logic;

signal tick_counter : std_logic_vector(3 downto 0);
signal reg_tick_counter : std_logic_vector(3 downto 0);

signal txx : std_logic;

signal b : std_logic_vector(7 downto 0);
signal reg_b : std_logic_vector(7 downto 0);

signal n_counter : std_logic_vector(3 downto 0);
signal reg_n_counter : std_logic_vector(3 downto 0);

signal valid : std_logic;

begin

--Component instatiation. Use the generator to get the ticks.
generator : baud_rate_generator PORT MAP ( clk => clk,
                                           output_prescaler => pe,
                                           output_bit_counter => tick);


--StateMem
StateMem : process(clk)
begin

if(rising_edge(clk)) then
    if(reset = '1') then
        current_state <= idle;
        reg_tick_counter <= "0000";
        reg_b <= "00000000";
        reg_n_counter <= "0000";
    else
        current_state <= next_state;
        reg_tick_counter <= tick_counter;
        reg_b <= b;
        reg_n_counter <= n_counter;
    end if;
end if;

end process StateMem;



--NextStateLogic
NextStateLogic : process(tx_start, tx_din, current_state, tick, reg_tick_counter, reg_b, reg_n_counter)
begin

--Default
next_state <= current_state;
tick_counter <= reg_tick_counter;
b <= reg_b;
n_counter <= reg_n_counter;
valid <= '0';

case (current_state) is

    when idle => if(tx_start /= '1') then
                    next_state <= idle;
                 else
                    tick_counter <= "0000";
                    b <= tx_din;
                    next_state <= start;
                 end if;
                 
    when start => if(tick /= '1') then
                    next_state <= start;
                  else
                    if(reg_tick_counter /= "1111") then
                        tick_counter <= std_logic_vector(unsigned(reg_tick_counter) + 1);
                    else
                        tick_counter <= "0000";
                        n_counter <= "0000";
                        next_state <= data;
                    end if;
                  end if;
                  
    when data => if(tick /= '1') then
                    next_state <= data;
                 else
                    if(reg_tick_counter /= "1111") then
                        tick_counter <= std_logic_vector(unsigned(reg_tick_counter) + 1);
                        next_state <= data;
                    else
                        tick_counter <= "0000";
                        b <= '0' & reg_b(7 downto 1);
                        if(reg_n_counter = "0111") then
                            next_state <= stop;
                        else
                            n_counter <= std_logic_vector(unsigned(reg_n_counter) + 1);
                            next_state <= data;
                        end if;
                    end if;
                 end if;
                 
    when stop => if(tick /= '1') then
                    next_state <= stop;
                 else
                    if(reg_tick_counter /= "1111") then
                        tick_counter <= std_logic_vector(unsigned(reg_tick_counter) + 1);
                        next_state <= stop;
                    else
                        valid <= '1';
                        next_state <= idle;
                    end if;
                 end if;
end case;

end process NextStateLogic;


--Output Logic

tx_done_tick <= valid;

OutputLogic : process(current_state, reg_b)
begin

case (current_state) is

    when idle => tx <= '1';
    when start => tx <= '0';
    when data => tx <= reg_b(0);
    when stop => tx <= '1';

end case;


end process OutputLogic;
end Behavioral;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.All;

entity uart_rx is
  Port ( clk, restart, rx : IN std_logic;
         data_out : OUT std_logic_vector(7 downto 0);
         data_valid : OUT std_logic );
end uart_rx;

architecture Behavioral of uart_rx is

type states is (idle, start, data, stop);
signal current_state, next_state : states;


component baud_rate_generator is
    Port ( clk : IN std_logic;
           --start : IN std_logic;
           output_prescaler : OUT std_logic_vector(9 downto 0);
           output_bit_counter : OUT std_logic );
end component;

--signal start_gen : std_logic := '1';

signal op : std_logic_vector(9 downto 0);
signal tick : std_logic;

signal reg_tick_counter, tick_counter : std_logic_vector(3 downto 0);
signal reg_n_counter, n_counter : std_logic_vector(3 downto 0);
signal reg_b, b : std_logic_vector(7 downto 0); --shifted bits
signal reg_data_v, data_v : std_logic;

begin

--start_gen <= '0' after 60 ns;

generator : baud_rate_generator PORT MAP ( clk => clk,
                                           --start => start_gen,
                                           output_prescaler => op,
                                           output_bit_counter => tick);


StateMem : process(clk)
begin
    if(rising_edge(clk)) then
        if(restart = '1') then
            current_state <= idle;
            reg_tick_counter <= "0000";
            reg_n_counter <= "0000";
            reg_b <= "00000000";
            reg_data_v <= '0';
        else
            current_state <= next_state;
            reg_tick_counter <= tick_counter;
            reg_n_counter <= n_counter;
            reg_b <= b;
            reg_data_v <= data_v;
        end if;
    end if;
end process StateMem;




NextStateLogic : process(rx, tick, reg_data_v, reg_n_counter, reg_b, reg_tick_counter, current_state)
begin

next_state   <= current_state;
tick_counter <= reg_tick_counter;
n_counter    <= reg_n_counter;
b            <= reg_b;
data_v       <= '0'; --Different default, the others are mostly registers.

case (current_state) is 

    when idle => if(rx = '1') then --we should wait until it goes to 0 normally.
                    next_state <= idle;
                 else
                    tick_counter <= "0000";
                    next_state <= start;
                 end if;
                 
    when start => if(tick /= '1') then
                    next_state <= start;
                  else
                    if(reg_tick_counter /= "0111") then
                        tick_counter <= std_logic_vector(unsigned(reg_tick_counter) + 1);
                        next_state <= start;
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
                        b <= rx & reg_b(7 downto 1);
                        --b <= reg_b(6 downto 0) & rx;
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
                        data_v <= '1';
                        next_state <= idle;
                     end if;
                   end if;
                
end case;
end process NextStateLogic;


--Output Logic
data_out <= reg_b;
data_valid <= reg_data_v;


end Behavioral;
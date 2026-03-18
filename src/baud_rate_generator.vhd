library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.All;

entity baud_rate_generator is
    Port ( clk : IN std_logic;
           --start : IN std_logic;
           output_prescaler : OUT std_logic_vector(9 downto 0);
           output_bit_counter : OUT std_logic );
end baud_rate_generator;

architecture Behavioral of baud_rate_generator is

signal prescaler_val_intern : std_logic_vector(9 downto 0) := (others => '0');
signal bit_counter_intern : std_logic := '0';

begin

--Process 1 (P1) : Prescaler : Counts to 651, Bit_Counter : Counts to 16 when prescaler reaches the value 651.

--The value 651 comes as a result of the calculation: 
--Basys3 onboard clock: 100 MHz. 
--Baud rate: 9600 bits / second. Agreed upon between sender and receiver beforehand.

--How many clock cycles are needed to send 1 single bit?
--9600 bits / second * 1 / (100 * 10^6 * second^(-1)) = 9600 bits / second * 10^(-8) * second = 9600 * 10^(-8) bits = 0,000096 bits
--1 clock cycle -> 0,000096 bits
--x clock cycles -> 1 bit(s).
--x = 1 clock cycle * 1 bit(s) / 0,000096 bits = 10416,666... clock cycles.
--Result : At least 10416 clock cycles are needed to send 1 single bit.

--Sampling: The timer/generator needs to tick 16 times in the process of sending a single bit
--10416 clock cycles / 16 ticks = 651 clock cycles / tick.

P1 : process(clk)
begin

    if(rising_edge(clk)) then
            prescaler_val_intern <= std_logic_vector(unsigned(prescaler_val_intern) + 1);
            bit_counter_intern <= '0';  
                  
                if(prescaler_val_intern = "1010001010") then  --Counting from 0000000000 (0) to 1010001010 (650) => 651.              
                    prescaler_val_intern <= (others => '0');
                    bit_counter_intern <= '1';                                                    
                end if;  
         
    end if;

end process P1;

output_prescaler <= prescaler_val_intern;
output_bit_counter <= bit_counter_intern;

end Behavioral;
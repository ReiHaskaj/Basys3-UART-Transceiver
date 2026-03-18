library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_baud_rate_generator is

end tb_baud_rate_generator;

architecture Behavioral of tb_baud_rate_generator is

component baud_rate_generator is
    Port ( clk : IN std_logic;
           --start : IN std_logic;
           output_prescaler : OUT std_logic_vector(9 downto 0);
           output_bit_counter : OUT std_logic );
end component;

--signals
signal clk : std_logic := '1';
--signal start : std_logic := '1';

signal op : std_logic_vector(9 downto 0);
signal bc : std_logic;

begin

dut : baud_rate_generator PORT MAP (clk => clk, 
                                    output_prescaler => op, 
                                    output_bit_counter => bc);

P1 : process
begin
	wait for 20 ns;
	clk <= NOT clk;
end process P1;

end Behavioral;
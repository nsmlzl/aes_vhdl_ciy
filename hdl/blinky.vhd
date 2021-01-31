library ieee;
use ieee.std_logic_1164.all;

entity blinky is
	port (
		CLK : in std_logic; -- 16 MHz
		LED : out std_logic
	);
end entity;


architecture blinky_arch of blinky is
	signal s_counter : integer range 0 to 16000000 := 0;
	signal s_led : std_logic := '0';
begin
	led <= s_led;

	counter_proc : process(clk) is
	begin
		if rising_edge(clk) then
			if s_counter < 16000000 then
				s_counter <= s_counter + 1;
			else
				s_counter <= 0;
				s_led <= not s_led;
			end if;
		end if;
	end process;
end architecture;

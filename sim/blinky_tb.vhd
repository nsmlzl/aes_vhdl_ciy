library ieee;
use ieee.std_logic_1164.all;

entity blinky_tb is
end entity;


architecture blinky_tb_arch of blinky_tb is
	signal clk : std_logic := '0';
	signal led : std_logic := '0';

	component blinky is
		port (
			clk : in std_logic;
			led : out std_logic
		);
	end component;
begin
	blinky1: blinky port map(clk, led);

	clk_proc: process is
	begin
		clk <= '0';
		wait for 30 ns;
		clk <= '1';
		wait for 30 ns;
	end process;

	check_proc: process is
	begin
		wait for 50 us;
		assert led = '0' report "LED should be turned off" severity failure;
		wait for 1000 ms;
		assert led = '1' report "LED should be turned on" severity failure;

		report "Simulation succesfull!" severity note;
		wait;
	end process;

end architecture;

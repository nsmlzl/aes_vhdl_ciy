library ieee;
use ieee.std_logic_1164.all;

entity xtime_tb is
end entity;


architecture xtime_tb_arch of xtime_tb is
	signal clk : std_logic := '0';
	signal input, output : std_logic_vector(7 downto 0) := (others => '0');
	component xtime is
		port (
			clk : in std_logic;
			input: in std_logic_vector(7 downto 0);
			output: out std_logic_vector(7 downto 0)
		);
	end component;
begin
	clk <= not clk after 31 ns;
	xtime1: xtime port map(clk, input, output);

	stim_proc : process
	begin
		wait until falling_edge(clk);
		input <= x"7F";

		wait until falling_edge(clk);
		input <= x"FF";

		wait;
	end process;

	check_proc : process
	begin
		wait until falling_edge(clk);
		wait until falling_edge(clk);

		assert output = x"FE"
			report "xtime [1] processed wrong output" severity failure;

		wait until falling_edge(clk);
		assert output = x"E5"
			report "xtime [2] processed wrong output" severity failure;

		report "xtime testbench succesfull!" severity note;
		wait;
	end process;
end architecture;

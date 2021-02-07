library ieee;
use ieee.std_logic_1164.all;


entity subbyte_tb is
end entity;


architecture tb of subbyte_tb is
	constant clk_period	: time := 13 us;
	signal clk		: std_logic;

	signal s_input	: std_logic_vector(7 downto 0);
	signal s_output	: std_logic_vector(7 downto 0);

	component subbyte is
		port (
			clk		: in  std_logic;
			input	: in  std_logic_vector(7 downto 0);
			output	: out std_logic_vector(7 downto 0)
		);
	end component;

begin

	process
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process;

	subbyte1: subbyte
	port map (
		clk		=> clk,
		input	=> s_input,
		output	=> s_output
	);

	stim_proc: process
	begin
		wait until rising_edge(clk);
		s_input <= x"00";

		wait until rising_edge(clk);
		s_input <= x"FB";

		wait until rising_edge(clk);
		s_input <= x"FF";

		wait;
	end process;

	check_proc: process
	begin
		wait until s_input = x"00";
		wait until rising_edge(clk);
		wait until falling_edge(clk);
		assert s_output = x"63" report "subbytes calculated wrong result" severity failure;

		wait until falling_edge(clk);
		assert s_output = x"0F" report "subbytes calculated wrong result" severity failure;

		wait until falling_edge(clk);
		assert s_output = x"16" report "subbytes calculated wrong result" severity failure;

		report "subbytes testbench succesful!";
		wait;
	end process;

end architecture;

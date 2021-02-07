library ieee;
use ieee.std_logic_1164.all;

entity add_round_key_tb is
end entity;


architecture add_round_key_tb_arch of add_round_key_tb is
	signal clk : std_logic := '0';
	signal input, key, output : std_logic_vector(127 downto 0) := (others => '0');

	component add_round_key is
		port (
			clk : in std_logic;
			input: in std_logic_vector(127 downto 0);
			key: in std_logic_vector(127 downto 0);
			output: out std_logic_vector(127 downto 0)
		);
	end component;
begin
	clk <= not clk after 31 ns;
	ark1: add_round_key port map(clk, input, key, output);

	stim_proc: process is
	begin
		for i in 0 to 5 loop
			wait until rising_edge(clk);
		end loop;

		input <= x"3004ACA810E2E5932EB03DAF80925732";
		key <= x"9CE8858087E30478C6041D1FF05656A2";

		wait until rising_edge(clk);
		input <= x"6ACB38A3CF39A11A45BEF6C6F4224610";
		key <= x"2F59BF0CA8BABB746EBEA66B9EE8F0C9";

		wait;
	end process;

	check_proc: process is
	begin
		for i in 0 to 7 loop
			wait until rising_edge(clk);
		end loop;

		assert output = x"ACEC29289701E1EBE8B420B070C40190"
			report "add_round_key [1] module processed wrong output" severity failure;

		wait until rising_edge(clk);
		assert output = x"459287AF67831A6E2B0050AD6ACAB6D9"
			report "add_round_key [2] module processed wrong output" severity failure;

		report "success!" severity note;
		wait;
	end process;
end architecture;

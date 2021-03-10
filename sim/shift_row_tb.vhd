library ieee;
use ieee.std_logic_1164.all;

entity shift_row_tb is
end entity;


architecture shift_row_tb_arch of shift_row_tb is
	signal clk: std_logic := '0';
	signal input, output: std_logic_vector(127 downto 0) := (others => '0');
	component shift_row is
		port (
			clk : in std_logic;
			input : in std_logic_vector(127 downto 0);
			output : out std_logic_vector(127 downto 0)
		);
	end component;
begin
	clk <= not clk after 1 us;
	shift_row1: shift_row port map(clk, input, output);

	stim_proc: process is
	begin
		wait until rising_edge(clk);
		input <= x"00112233445566778899AABBCCDDEEFF";

		wait until rising_edge(clk);
		input <= x"112233445566778899AABBCCDDEEFF11";

		wait until rising_edge(clk);
		input <= (others => '1');

		wait;
	end process;

	check_proc: process is
	begin
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until falling_edge(clk);
		assert output = x"0055AAFF4499EE3388DD2277CC1166BB"
			report "shift_row[1] processed wrong output" severity failure;

		wait until falling_edge(clk);
		assert output = x"1166BB1155AAFF4499EE3388DD2277CC"
			report "shift_row[1] processed wrong output" severity failure;

		wait until falling_edge(clk);
		assert output = x"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF"
			report "shift_row[2] processed wrong output" severity failure;

		report "success!" severity note;
		wait;
	end process;

end architecture;

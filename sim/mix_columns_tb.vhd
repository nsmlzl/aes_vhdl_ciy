library ieee;
use ieee.std_logic_1164.all;

entity mix_columns_tb is
end entity;


architecture mix_columns_tb_arch of mix_columns_tb is
	signal clk : std_logic := '0';
	signal new_data, valid : std_logic := '0';
	signal input, output : std_logic_vector(127 downto 0) := (others => '0');
	component mix_columns is
		port (
			clk : in std_logic;
			new_data : in std_logic;
			input : in std_logic_vector(127 downto 0);
			valid : out std_logic;
			output: out std_logic_vector(127 downto 0)
		);
	end component;
begin
	clk <= not clk after 31 ns;
	mcs1 : mix_columns port map(clk, new_data, input, valid, output);

	stim_proc : process is
	begin
		for i in 0 to 5 loop
			wait until rising_edge(clk);
		end loop;

		new_data <= '1';
		input <= x"DB135345F20A225C01010101C6C6C6C6";
		wait until rising_edge(clk);
		new_data <= '0';

		loop
			wait until rising_edge(clk);
			if valid = '1' then
				exit;
			end if;
		end loop;

		wait until rising_edge(clk);
		wait until rising_edge(clk);
		new_data <= '1';
		input <= x"F20A225C01010101C6C6C6C6DB135345";
		wait until rising_edge(clk);
		new_data <= '0';

		wait;
	end process;

	check_proc : process is
	begin
		loop
			wait until rising_edge(clk);
			if valid = '1' then
				exit;
			end if;
		end loop;
		assert output = x"8E4DA1BC9FDC589D01010101C6C6C6C6"
			report "mix_columns processed wrong value [1]" severity failure;

		loop
			wait until rising_edge(clk);
			if valid = '0' then
				exit;
			end if;
		end loop;
		loop
			wait until rising_edge(clk);
			if valid = '1' then
				exit;
			end if;
		end loop;
		assert output = x"9FDC589D01010101C6C6C6C68E4DA1BC"
			report "mix_columns processed wrong value [2]" severity failure;
		report "success!" severity note;

		wait;
	end process;

end architecture;

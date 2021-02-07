library ieee;
use ieee.std_logic_1164.all;

entity mix_column_tb is
end entity;


architecture mix_column_tb_arch of mix_column_tb is
	signal clk : std_logic := '0';
	signal new_data, valid : std_logic := '0';
	signal i_column, o_column : std_logic_vector(31 downto 0) := (others => '0');
	component mix_column is
		port (
			clk : in std_logic;
			new_data : in std_logic;
			i_column : in std_logic_vector(31 downto 0);
			valid : out std_logic;
			o_column : out std_logic_vector(31 downto 0)
		);
	end component;
begin
	clk <= not clk after 31 ns;

	mix_column0 : mix_column port map(clk, new_data, i_column, valid, o_column);

	stim_proc: process
	begin
		for i in 0 to 5 loop
			wait until rising_edge(clk);
		end loop;

		i_column <= x"DB135345";
		new_data <= '1';
		wait until rising_edge(clk);
		new_data <= '0';
		wait until rising_edge(clk);

		loop
			wait until rising_edge(clk);
			if valid = '1' then
				exit;
			end if;
		end loop;
		wait until rising_edge(clk);
		wait until rising_edge(clk);

		i_column <= x"F20A225C";
		new_data <= '1';
		wait until rising_edge(clk);
		new_data <= '0';
		wait until rising_edge(clk);

		loop
			wait until rising_edge(clk);
			if valid = '1' then
				exit;
			end if;
		end loop;
		wait until rising_edge(clk);
		wait until rising_edge(clk);

		i_column <= x"2D26314C";
		new_data <= '1';
		wait until rising_edge(clk);
		new_data <= '0';
		wait until rising_edge(clk);
		wait;
	end process;

	check_proc: process is
	begin
		loop
			wait until rising_edge(clk);
			if valid = '1' then
				exit;
			end if;
		end loop;

		assert o_column = x"8E4DA1BC"
			report "mix_column processed wrong output [0]" severity failure;

		loop wait until rising_edge(clk);
			if valid = '0' then
				exit;
			end if;
		end loop;
		loop wait until rising_edge(clk);
			if valid = '1' then
				exit;
			end if;
		end loop;
		assert o_column = x"9FDC589D"
			report "mix_column processed wrong output [1]" severity failure;

		loop wait until rising_edge(clk);
			if valid = '0' then
				exit;
			end if;
		end loop;
		loop wait until rising_edge(clk);
			if valid = '1' then
				exit;
			end if;
		end loop;
		assert o_column = x"4D7EBDF8"
			report "mix_column processed wrong output [1]" severity failure;

		report "success!" severity note;
		wait;
	end process;

end architecture;

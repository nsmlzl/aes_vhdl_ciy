library ieee;
use ieee.std_logic_1164.all;

entity subbytes_tb is
end entity;


architecture subbytes_tb_arch of subbytes_tb is
	signal clk : std_logic := '0';
	signal new_data, valid : std_logic := '0';
	signal input, output : std_logic_vector(127 downto 0) := (others => '0');
	component subbytes is
		port (
			clk : in std_logic;
			new_data : in std_logic;
			input: in std_logic_vector(127 downto 0);
			valid : out std_logic;
			output: out std_logic_vector(127 downto 0)
		);
	end component;
begin
	clk <= not clk after 31 ns;
	sbs1 : subbytes port map (clk, new_data, input, valid, output);

	stim_proc : process is
	begin
		for i in 0 to 5 loop
			wait until rising_edge(clk);
		end loop;

		input <= x"04040404040404041111111111111111";
		new_data <= '1';
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
		wait until rising_edge(clk);
		wait until rising_edge(clk);

		input <= x"030303031a1a1a1a0000000020202020";
		new_data <= '1';
		wait until rising_edge(clk);
		new_data <= '0';

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

		assert output = x"f2f2f2f2f2f2f2f28282828282828282"
			report "subbytes [1] module processed wrong output" severity failure;

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

		assert output = x"7B7B7B7BA2A2A2A263636363B7B7B7B7"
			report "subbytes [2] module processed wrong output" severity failure;

		report "success!" severity note;
		wait;
	end process;

end architecture;

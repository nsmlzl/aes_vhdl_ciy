library ieee;
use ieee.std_logic_1164.all;


entity key_schedule_func_tb is
end entity;


architecture key_schedule_func_tb_arch of key_schedule_func_tb is
	constant clk_period : time := 1 us;

	component key_schedule_func is
		port (
			 clk: in std_logic;
			 input: in std_logic_vector(31 downto 0);
			 output: out std_logic_vector(31 downto 0);
			 round: in integer range 0 to 10;
			 new_data: in std_logic;
			 valid: out std_logic
		);
	end component;
	signal clk : std_logic := '0';
	signal s_input : std_logic_vector(31 downto 0) := (others => '0');
	signal s_output : std_logic_vector(31 downto 0) := (others => '0');
	signal s_round : integer range 0 to 10 := 1;
	signal s_new_data: std_logic := '0';
	signal s_valid : std_logic := '0';
begin
	ksf1: key_schedule_func
	port map (
		clk => clk,
		input => s_input,
		output => s_output,
		round => s_round,
		new_data => s_new_data,
		valid => s_valid
	);

	clk_proc: process is
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process;

	stim_proc: process is
	begin
		wait until rising_edge(clk);
		s_round <= 1;
		s_input <= x"12345678";
		s_new_data <= '1';
		wait until rising_edge(clk);
		s_new_data <= '0';

		loop
			wait until rising_edge(clk);
			if s_valid = '1' then
				exit;
			end if;
		end loop;
		wait until rising_edge(clk);
		s_round <= 9;
		s_new_data <= '1';
		wait until rising_edge(clk);
		s_new_data <= '0';

		wait;
	end process;

	check_proc: process is
	begin
		loop
			wait until rising_edge(clk);
			if s_valid = '1' then
				exit;
			end if;
		end loop;
		assert s_output = x"19B1BCC9" report "Wrong result calculated by key_schedule_func" severity failure;

		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		loop
			wait until rising_edge(clk);
			if s_valid = '1' then
				exit;
			end if;
		end loop;
		assert s_output = x"03B1BCC9" report "Wrong result calculated by key_schedule_func" severity failure;

		report "key_schedule_func_tb succesful!" severity note;
		wait;
	end process;

end architecture;

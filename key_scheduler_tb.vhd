library ieee;
use ieee.std_logic_1164.all;


entity key_scheduler_tb is
end entity;


architecture key_scheduler_tb_arch of key_scheduler_tb is
	constant clk_period: time := 1 us;

	signal clk: std_logic := '0';
	signal s_new_data : std_logic := '0';
	signal s_input : std_logic_vector(127 downto 0) := (others => '0');
	signal s_output : std_logic_vector(127 downto 0) := (others => '0');
	signal s_valid : std_logic := '0';
	signal s_round : integer range 1 to 10 := 1;

	component key_scheduler is
	port (
		clk: in std_logic;
		new_data: in std_logic;
		input: in std_logic_vector(127 downto 0);
		output: out std_logic_vector(127 downto 0);
		valid : out std_logic;
		round: in integer range 1 to 10
	);
	end component;
begin
	clk_proc: process is
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process;

	ks1 : key_scheduler
	port map(
		clk => clk,
		new_data => s_new_data,
		input => s_input,
		output => s_output,
		valid => s_valid,
		round => s_round
	);

	stim_proc: process is
	begin
		s_input <= x"9D5BFF851B0B81F841E7196736524BBD";
		s_round <= 1;
		s_new_data <= '0';
		wait until rising_edge(clk);

		for i in 1 to 10 loop
			wait until rising_edge(clk);
			s_round <= i;
			s_new_data <= '1';

			wait until rising_edge(clk);
			s_new_data <= '0';

			wait until rising_edge(clk);
			wait until rising_edge(clk);
			inner_loop: loop
				wait until rising_edge(clk);
				if s_valid = '1' then
					exit inner_loop;
				end if;
			end loop;

			s_input <= s_output;
			for a in 1 to 5 loop
				wait until rising_edge(clk);
			end loop;
		end loop;

		wait;
	end process;

	check_proc: process is
	begin
		for i in 1 to 10 loop
			loop
				wait until rising_edge(clk);
				if s_valid = '1' then
					exit;
				end if;
			end loop;

			if i = 1 then
				assert s_output = x"9CE8858087E30478C6041D1FF05656A2" report "Wrong key processed for round 1!"
				severity failure;
			elsif i = 10 then
				assert s_output = x"FCB198AA2C908E487C544F7953DCEA78" report "Wrong key processed for round 10!"
				severity failure;
			end if;

			loop
				wait until rising_edge(clk);
				if s_valid = '0' or i = 10 then
					exit;
				end if;
			end loop;
		end loop;
		report "Key expansion testbench succesful!" severity note;

		wait;
	end process;
end architecture;

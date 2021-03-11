library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity uart_tb is
end entity;


architecture tb of uart_tb is
	constant clk_period	: time := 6.5 us;
	signal clk		: std_logic := '0';

	component uart is
		port (
			clk			: in  std_logic;
			tx			: out std_logic;
			rx			: in  std_logic;
			tbyte		: in  std_logic_vector(7 downto 0);
			tbyte_flag	: in  std_logic;
			rbyte		: out std_logic_vector(7 downto 0);
			rbyte_flag	: out std_logic
		);
	end component;
	signal tx		: std_logic := '0';
	signal rx		: std_logic := '1';
	signal tbyte	: std_logic_vector(7 downto 0) := (others => '0');
	signal tbyte_f	: std_logic := '0';
	signal rbyte	: std_logic_vector(7 downto 0) := (others => '0');
	signal rbyte_f	: std_logic := '0';

	signal s_rdata	: std_logic_vector(9 downto 0) := (others => '0');

begin
	clk <= not clk after clk_period/2;
	uart1: uart port map (clk, tx, rx, tbyte, tbyte_f, rbyte, rbyte_f);

	-- tx testbench
	stim_tx_proc : process is
	begin
		tbyte_f <= '0';
		tbyte <= (others => '0');

		for i in 0 to 6 loop
			wait until rising_edge(clk);
		end loop;

		tbyte <= std_logic_vector(to_unsigned(42, 8));
		wait until rising_edge(clk);

		tbyte_f <= '1';
		wait until rising_edge(clk);

		tbyte_f <= '0';
		wait until rising_edge(clk);

		for i in 0 to 100 loop
			wait until rising_edge(clk);
		end loop;

		wait;
	end process;

	check_tx_proc : process is
	begin
		wait until falling_edge(tx);
		wait until rising_edge(clk);
		wait until rising_edge(clk);

		assert tx = '0' report "TX testbench: Expected start-bit to be '0'" severity failure;

		for i in 0 to 7 loop
			for w in 0 to 7 loop
				wait until rising_edge(clk);
			end loop;
			assert tx = tbyte(i) report "TX testbench: Expected bit at position " & integer'image(i) & " to be " & std_logic'image(tbyte(i)) severity failure;
		end loop;

		for w in 0 to 7 loop
			wait until rising_edge(clk);
		end loop;
		assert tx = '1' report "TX testbench: Expected stop-bit to be '1'" severity failure;

		wait for 20*clk_period;
		assert tx = '1' report "TX testbench: Expected tx line to be '1'" severity failure;

		report "TX testbench: success!" severity note;
		wait;
	end process;


	-- rx testbench
	stim_rx_proc : process is
	begin
		s_rdata <= '1' & std_logic_vector(to_unsigned(42, 8)) & '0';
		for i in 0 to 9 loop
			wait until rising_edge(clk);
		end loop;
		
		for i in 0 to 9 loop
			rx <= s_rdata(i);
			for w in 0 to 7 loop
				wait until rising_edge(clk);
			end loop;
		end loop;

		wait;
	end process;

	check_rx_proc : process is
		variable timeout : integer := 100;
	begin
		for i in 0 to timeout+1 loop
			wait until rising_edge(clk);
			if rbyte_f = '1' then
				exit;
			elsif i = timeout then
				report "RX testbench: Timeout" severity failure;
			end if;
		end loop;

		assert rbyte = std_logic_vector(to_unsigned(42, 8)) report "RX testbench: Wrong output" severity failure;
		report "RX testbench: success!" severity note;
		wait;
	end process;

end architecture;

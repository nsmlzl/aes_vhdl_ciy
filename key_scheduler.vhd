library ieee;
use ieee.std_logic_1164.all;


entity key_scheduler is
	port (
		clk: in std_logic;
		new_data: in std_logic;
		input: in std_logic_vector(127 downto 0);
		output: out std_logic_vector(127 downto 0);
		valid : out std_logic;
		round: in integer range 1 to 10
	);
end entity;


architecture key_scheduler_arch of key_scheduler is
	type ks_states is (INIT_S, FUNC_S, FUNC_WAIT_S, FUNC_WAIT2_S, FUNC_WAIT3_S,
		XOR1_S, XOR2_S, XOR3_S, XOR4_S, VALID_S);
	signal state : ks_states := INIT_S;

	signal s_output : std_logic_vector(127 downto 0) := (others => '0');

	component key_schedule_func is
		port (
			clk: in std_logic;
			input: in std_logic_vector(31 downto 0);
			output: out std_logic_vector(31 downto 0);
			round: in integer range 1 to 10;
			new_data: in std_logic;
			valid: out std_logic
		);
	end component;
	signal s_ksf_input : std_logic_vector(31 downto 0) := (others => '0');
	signal s_ksf_output : std_logic_vector(31 downto 0) := (others => '0');
	signal s_ksf_new_data : std_logic := '0';
	signal s_ksf_valid : std_logic := '0';
begin
	ks_fsm_proc: process(clk) is
	begin
		if rising_edge(clk) then
			case state is
				when INIT_S =>
					valid <= '0';
					output <= (others => '0');
					s_output <= (others => '0');
					s_ksf_input <= (others => '0');
					s_ksf_new_data <= '0';
					if new_data = '1' then
						state <= FUNC_S;
					end if;
				when FUNC_S =>
					valid <= '0';
					s_ksf_input <= input(31 downto 0);
					s_ksf_new_data <= '1';
					state <= FUNC_WAIT_S;
				when FUNC_WAIT_S =>
					s_ksf_new_data <= '0';
					state <= FUNC_WAIT2_S;
				when FUNC_WAIT2_S =>
					-- key_schedule_func module needs some extra time to reset valid
					state <= FUNC_WAIT3_S;
				when FUNC_WAIT3_S =>
					if s_ksf_valid = '1' then
						state <= XOR1_S;
					end if;
				when XOR1_S =>
					s_output(127 downto 96) <= s_ksf_output xor input(127 downto 96);
					state <= XOR2_S;
				when XOR2_S =>
					s_output(95 downto 64) <= s_output(127 downto 96) xor input(95 downto 64);
					state <= XOR3_S;
				when XOR3_S =>
					s_output(63 downto 32) <= s_output(95 downto 64) xor input(63 downto 32);
					state <= XOR4_S;
				when XOR4_S =>
					s_output(31 downto 0) <= s_output(63 downto 32) xor input(31 downto 0);
					state <= VALID_S;
				when VALID_S =>
					output <= s_output;
					valid <= '1';
					if new_data = '1' then
						state <= FUNC_S;
					end if;
			end case;
		end if;
	end process;

	ksf1: key_schedule_func
	port map (
		clk => clk,
		input => s_ksf_input,
		output => s_ksf_output,
		round => round,
		new_data => s_ksf_new_data,
		valid => s_ksf_valid
	);
end architecture;

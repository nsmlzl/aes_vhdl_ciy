library ieee;
use ieee.std_logic_1164.all;


entity key_schedule_func is
	port (
		clk: in std_logic;
		input: in std_logic_vector(31 downto 0);
		output: out std_logic_vector(31 downto 0);
		round: in integer range 1 to 10;
		new_data: in std_logic;
		valid: out std_logic
	);
end entity;


architecture key_schedule_func_arch of key_schedule_func is
	type ksf_states is (INIT_S, ROTATE_S, SB1_S, SB2_S, SB3_S, SB4_S, SB_WAIT_S, VALID_S);
	signal state     : ksf_states := INIT_S;

	signal s_rotated : std_logic_vector(31 downto 0) := (others => '0');
	signal s_substituted : std_logic_vector(31 downto 0) := (others => '0');

	signal s_round_coef : std_logic_vector(7 downto 0) := (others => '0');

	component subbytes is
		port (
			clk		: in  std_logic;
			input	: in  std_logic_vector(7 downto 0);
			output	: out std_logic_vector(7 downto 0)
		);
	end component;
	signal s_sb_input, s_sb_output: std_logic_vector(7 downto 0);

begin
	sb1: subbytes
	port map (
		clk => clk,
		input => s_sb_input,
		output => s_sb_output
	);

	ksf_fsm_proc: process(clk) is
	begin
		if rising_edge(clk) then
			case state is
				when INIT_S =>
					s_rotated <= (others => '0');
					s_substituted <= (others => '0');

					if new_data = '1' then
						state <= ROTATE_S;
					end if;
				when ROTATE_S =>
					valid <= '0';
					s_rotated <= input(23 downto 0) & input(31 downto 24);
					state <= SB1_S;
				when SB1_S =>
					s_sb_input <= s_rotated(7 downto 0);
					state <= SB2_S;
				when SB2_S =>
					s_sb_input <= s_rotated(15 downto 8);
					state <= SB3_S;
				when SB3_S =>
					-- subbytes module needs one extra cycle for computation
					s_substituted(7 downto 0) <= s_sb_output;
					s_sb_input <= s_rotated(23 downto 16);
					state <= SB4_S;
				when SB4_S =>
					s_substituted(15 downto 8) <= s_sb_output;
					s_sb_input <= s_rotated(31 downto 24);
					state <= SB_WAIT_S;
				when SB_WAIT_S =>
					s_substituted(23 downto 16) <= s_sb_output;
					state <= VALID_S;
				when VALID_S =>
					output(23 downto 0) <= s_substituted(23 downto 0);
					output(31 downto 24) <= s_sb_output xor s_round_coef;
					valid <= '1';
					if new_data = '1' then
						state <= ROTATE_S;
					end if;
			end case;
		end if;
	end process;

	round_coef_proc: process(clk) is
	begin
		if rising_edge(clk) then
			case round is
				when 1 => s_round_coef <= x"01";
				when 2 => s_round_coef <= x"02";
				when 3 => s_round_coef <= x"04";
				when 4 => s_round_coef <= x"08";
				when 5 => s_round_coef <= x"10";
				when 6 => s_round_coef <= x"20";
				when 7 => s_round_coef <= x"40";
				when 8 => s_round_coef <= x"80";
				when 9 => s_round_coef <= x"1B";
				when 10 => s_round_coef <= x"36";
			end case;
		end if;
	end process;
end architecture;

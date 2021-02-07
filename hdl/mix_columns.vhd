library ieee;
use ieee.std_logic_1164.all;

entity mix_columns is
	port (
		clk : in std_logic;
		new_data : in std_logic;
		input : in std_logic_vector(127 downto 0);
		valid : out std_logic;
		output: out std_logic_vector(127 downto 0)
	);
end entity;


architecture mix_columns_arch of mix_columns is
	type mcs_t is (INIT, READY, C1, C1W, C1WW, C1WWW, C2, C2W, C2WW, C2WWW, C3, C3W, C3WW, C3WWW, C4, C4W, C4WW, C4WWW, WRITE);
	signal state : mcs_t := INIT;

	signal s_mc_new_data, s_mc_valid : std_logic := '0';
	signal s_mc_i, s_mc_o : std_logic_vector(31 downto 0) := (others => '0');
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
	mc1 : mix_column port map (clk, s_mc_new_data, s_mc_i, s_mc_valid, s_mc_o);

	fsm_proc: process (clk) is
	begin
		if rising_edge(clk) then
			case state is
				when INIT =>
					valid <= '0';
					output <= (others => '0');
					s_mc_new_data <= '0';
					s_mc_i <= (others => '0');
					state <= READY;
				when READY =>
					if new_data = '1' then
						state <= C1;
					end if;
				when C1 =>
					valid <= '0';
					s_mc_new_data <= '1';
					s_mc_i <= input(127 downto 96);
					state <= C1W;
				when C1W =>
					s_mc_new_data <= '0';
					state <= C1WW;
				when C1WW =>
					s_mc_new_data <= '0';
					state <= C1WWW;
				when C1WWW =>
					if s_mc_valid = '1' then
						state <= C2;
					end if;
				when C2 =>
					output(127 downto 96) <= s_mc_o;
					s_mc_new_data <= '1';
					s_mc_i <= input(95 downto 64);
					state <= C2W;
				when C2W =>
					s_mc_new_data <= '0';
					state <= C2WW;
				when C2WW =>
					s_mc_new_data <= '0';
					state <= C2WWW;
				when C2WWW =>
					if s_mc_valid = '1' then
						state <= C3;
					end if;
				when C3 =>
					output(95 downto 64) <= s_mc_o;
					s_mc_new_data <= '1';
					s_mc_i <= input(63 downto 32);
					state <= C3W;
				when C3W =>
					s_mc_new_data <= '0';
					state <= C3WW;
				when C3WW =>
					s_mc_new_data <= '0';
					state <= C3WWW;
				when C3WWW =>
					if s_mc_valid = '1' then
						state <= C4;
					end if;
				when C4 =>
					output(63 downto 32) <= s_mc_o;
					s_mc_new_data <= '1';
					s_mc_i <= input(31 downto 0);
					state <= C4W;
				when C4W =>
					s_mc_new_data <= '0';
					state <= C4WW;
				when C4WW =>
					s_mc_new_data <= '0';
					state <= C4WWW;
				when C4WWW =>
					if s_mc_valid = '1' then
						state <= WRITE;
					end if;
				when WRITE =>
					output(31 downto 0) <= s_mc_o;
					valid <= '1';
					state <= READY;
			end case;
		end if;
	end process;

end architecture;

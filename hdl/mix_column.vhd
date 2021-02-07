library ieee;
use ieee.std_logic_1164.all;

entity mix_column is
	port (
		clk : in std_logic;
		new_data : in std_logic;
		i_column : in std_logic_vector(31 downto 0);
		valid : out std_logic;
		o_column : out std_logic_vector(31 downto 0)
	);
end entity;


architecture mix_column_arch of mix_column is
	type state_mx_t is (INIT, WAITD, STORE, S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, WRITE);
	signal state : state_mx_t := INIT;

	signal s_i0, s_i1, s_i2, s_i3 : std_logic_vector(7 downto 0) := (others => '0');
	signal s_o0, s_o1, s_o2, s_o3 : std_logic_vector(7 downto 0) := (others => '0');

	component xtime is
		port (
			clk : in std_logic;
			input: in std_logic_vector(7 downto 0);
			output: out std_logic_vector(7 downto 0)
		);
	end component;
	signal s_xi, s_xo : std_logic_vector(7 downto 0) := (others => '0');
begin

	o_column <= s_o0 & s_o1 & s_o2 & s_o3;

	xtime0 : xtime port map(clk, s_xi, s_xo);

	fsm_proc : process (clk) is
	begin
		if rising_edge(clk) then
			case state is
				when INIT => 
					s_i0 <= (others => '0');
					s_i1 <= (others => '0');
					s_i2 <= (others => '0');
					s_i3 <= (others => '0');
					s_o0 <= (others => '0');
					s_o1 <= (others => '0');
					s_o2 <= (others => '0');
					s_o3 <= (others => '0');
					valid <= '0';
					s_xi <= (others => '0');
					state <= WAITD;
				when WAITD =>
					if new_data = '1' then
						state <= STORE;
					end if;
				when STORE =>
					s_i0 <= i_column(31 downto 24);
					s_i1 <= i_column(23 downto 16);
					s_i2 <= i_column(15 downto 8);
					s_i3 <= i_column(7  downto 0);
					valid <= '0';
					state <= S0;
				when S0 =>
					s_xi <= s_i0;
					s_o0 <= s_i1 xor s_i2;
					state <= S1;
				when S1 =>
					s_o1 <= s_i0 xor s_i3;
					state <= S2;
				when S2 =>
					s_xi <= s_i2;
					s_o0 <= s_o0 xor s_xo;
					state <= S3;
				when S3 =>
					s_o3 <= s_o0;
					s_o0 <= s_o0 xor s_i3;
					state <= S4;
				when S4 =>
					s_xi <= s_i1;
					s_o1 <= s_o1 xor s_xo;
					state <= S5;
				when S5 =>
					s_o2 <= s_o1;
					s_o1 <= s_o1 xor s_i2;
					state <= S6;
				when S6 =>
					s_xi <= s_i3;
					s_o0 <= s_o0 xor s_xo;
					state <= S7;
				when S7 =>
					s_o1 <= s_o1 xor s_xo;
					state <= S8;
				when S8 =>
					s_o2 <= s_o2 xor s_xo;
					state <= S9;
				when S9 =>
					s_o3 <= s_o3 xor s_xo;
					state <= S10;
				when S10 =>
					s_o2 <= s_o2 xor s_i1;
					state <= S11;
				when S11 =>
					s_o3 <= s_o3 xor s_i0;
					state <= WRITE;
				when WRITE =>
					valid <= '1';
					state <= WAITD;
			end case;
		end if;
	end process;
end architecture;

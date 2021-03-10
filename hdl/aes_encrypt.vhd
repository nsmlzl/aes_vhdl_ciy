library ieee;
use ieee.std_logic_1164.all;

entity aes_encrypt is
	port (
		clk : in std_logic;
		new_data : in std_logic;
		plaintext : in std_logic_vector(127 downto 0);
		key : in std_logic_vector(127 downto 0);
		valid : out std_logic;
		ciphertext : out std_logic_vector(127 downto 0)
	);
end entity;


architecture aes_encrypt_arch of aes_encrypt is
	type ecrpt_state is (IDLE, SB, SB_W1, SB_W2, SB_W3, SR, SR_W, MC, MC_W1, MC_W2, MC_W3, KS_W, ARK, ARK_W, SND);
	signal s_state : ecrpt_state := IDLE;
	signal s_round : integer range 0 to 10 := 0;

	signal s_cp_data : std_logic_vector(127 downto 0) := (others => '0');
	signal s_cp_key : std_logic_vector(127 downto 0) := (others => '0');

	component subbytes is
		port (
			clk : in std_logic;
			new_data : in std_logic;
			input: in std_logic_vector(127 downto 0);
			valid : out std_logic;
			output: out std_logic_vector(127 downto 0)
		);
	end component;
	signal s_sb_nd, s_sb_vd : std_logic := '0';
	signal s_sb_in, s_sb_out : std_logic_vector(127 downto 0) := (others => '0');

	component shift_row is
		port (
			clk : in std_logic;
			input : in std_logic_vector(127 downto 0);
			output : out std_logic_vector(127 downto 0)
		);
	end component;
	signal s_sr_in, s_sr_out : std_logic_vector(127 downto 0) := (others => '0');

	component mix_columns is
		port (
			clk : in std_logic;
			new_data : in std_logic;
			input : in std_logic_vector(127 downto 0);
			valid : out std_logic;
			output: out std_logic_vector(127 downto 0)
		);
	end component;
	signal s_mc_nd, s_mc_vd : std_logic := '0';
	signal s_mc_in, s_mc_out : std_logic_vector(127 downto 0) := (others => '0');

	component add_round_key is
		port (
			clk: in std_logic;
			input: in std_logic_vector(127 downto 0);
			key: in std_logic_vector(127 downto 0);
			output: out std_logic_vector(127 downto 0)
		);
	end component;
	signal s_ark_in, s_ark_key, s_ark_out : std_logic_vector(127 downto 0);

	component key_scheduler is
		port (
			clk: in std_logic;
			new_data: in std_logic;
			input: in std_logic_vector(127 downto 0);
			output: out std_logic_vector(127 downto 0);
			valid : out std_logic;
			round: in integer range 0 to 10
		);
	end component;
	signal s_ks_nd, s_ks_vd : std_logic := '0';
	signal s_ks_in, s_ks_out : std_logic_vector(127 downto 0) := (others => '0');
begin
	sb_m : subbytes port map(clk, s_sb_nd, s_sb_in, s_sb_vd, s_sb_out);
	sr_m : shift_row port map(clk, s_sr_in, s_sr_out);
	mc_m : mix_columns port map(clk, s_mc_nd, s_mc_in, s_mc_vd, s_mc_out);
	ark_m : add_round_key port map(clk, s_ark_in, s_ark_key, s_ark_out);
	ks_m : key_scheduler port map(clk, s_ks_nd, s_ks_in, s_ks_out, s_ks_vd, s_round);

	nstate_proc : process (clk) is
	begin
		if rising_edge (clk) then
			case s_state is
				when IDLE =>
					s_round <= 0;
					if new_data = '1' then
						s_state <= ARK;
					end if;
				when SB =>
					s_state <= SB_W1;
				when SB_W1 =>
					s_state <= SB_W2;
				when SB_W2 =>
					s_state <= SB_W3;
				when SB_W3 =>
					if s_sb_vd = '1' then
						s_state <= SR;
					end if;
				when SR =>
					s_state <= SR_W;
				when SR_W =>
					if s_round < 10 then
						s_state <= MC;
					else
						s_state <= KS_W;
					end if;
				when MC =>
					s_state <= MC_W1;
				when MC_W1 =>
					s_state <= MC_W2;
				when MC_W2 =>
					s_state <= MC_W3;
				when MC_W3 =>
					if s_mc_vd = '1' then
						s_state <= KS_W;
					end if;
				when KS_W =>
					if s_ks_vd = '1' then
						s_state <= ARK;
					end if;
				when ARK =>
					s_state <= ARK_W;
				when ARK_W =>
					if s_round < 10 then
						s_round <= s_round + 1;
						s_state <= SB;
					else
						s_state <= SND;
					end if;
				when SND =>
					s_state <= IDLE;
				when others =>
					s_state <= IDLE;
			end case;
		end if;
	end process;

	out_proc : process (clk) is
	begin
		if rising_edge(clk) then
			case s_state is
				when IDLE =>
					s_cp_data <= plaintext;
					s_cp_key <= key;
				when SB =>
					s_sb_nd <= '1';
					s_sb_in <= s_ark_out;
					-- encryption
					s_ks_nd <= '1';
					if s_round = 1 then
						s_ks_in <= s_cp_key;
					else
						s_ks_in <= s_ks_out;
					end if;
				when SB_W1 =>
					s_sb_nd <= '0';
					s_ks_nd <= '0';
				when SR =>
					s_sr_in <= s_sb_out;
				when MC =>
					s_mc_in <= s_sr_out;
					s_mc_nd <= '1';
				when MC_W1 =>
					s_mc_nd <= '0';
				when ARK =>
					valid <= '0';
					case s_round is
						when 0 =>
							s_ark_in <= s_cp_data;
							s_ark_key <= s_cp_key;
						when 10 =>
							s_ark_in <= s_sr_out;
							s_ark_key <= s_ks_out;
						when others =>
							s_ark_in <= s_mc_out;
							s_ark_key <= s_ks_out;
					end case;
				when SND =>
					ciphertext <= s_ark_out;
					valid <= '1';
				when others =>
			end case;
		end if;
	end process;
end architecture;

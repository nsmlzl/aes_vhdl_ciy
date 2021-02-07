library ieee;
use ieee.std_logic_1164.all;

entity subbytes is
	port (
		clk : in std_logic;
		new_data : in std_logic;
		input: in std_logic_vector(127 downto 0);
		valid : out std_logic;
		output: out std_logic_vector(127 downto 0)
	);
end entity;


architecture subbytes_arch of subbytes is
	type sbs_t is (INIT, READY, STORE, SET_SB, WAIT_SB, GET_SB, WRITE);
	signal state : sbs_t := INIT;

	signal s_counter : integer range 0 to 16 := 0;
	signal s_input : std_logic_vector(127 downto 0) := (others => '0');

	signal s_sb_in : std_logic_vector(7 downto 0) := (others => '0');
	signal s_sb_out : std_logic_vector(7 downto 0) := (others => '0');
	component subbyte is
		port (
			clk : in std_logic;
			input : in std_logic_vector(7 downto 0);
			output : out std_logic_vector(7 downto 0)
		);
	end component;
begin
	sb1 : subbyte port map (clk, s_sb_in, s_sb_out);

	fsm_proc : process (clk) is
	begin
		if rising_edge(clk) then
			case state is
				when INIT =>
					valid <= '0';
					output <= (others => '0');
					s_counter <= 0;
					s_input <= (others => '0');
					s_sb_in <= (others => '0');
					state <= READY;
				when READY =>
					s_counter <= 0;
					if new_data = '1' then
						state <= STORE;
					end if;
				when STORE =>
					valid <= '0';
					s_input <= input;
					state <= SET_SB;
				when SET_SB =>
					s_sb_in <= s_input(s_counter*8 + 7 downto s_counter*8);
					state <= WAIT_SB;
				when WAIT_SB =>
					state <= GET_SB;
				when GET_SB =>
					output(s_counter*8 + 7 downto s_counter*8) <= s_sb_out;
					s_counter <= s_counter + 1;
					if s_counter < 15 then
						state <= SET_SB;
					else
						state <= WRITE;
					end if;
				when WRITE =>
					valid <= '1';
					state <= READY;
			end case;
		end if;
	end process;
end architecture;

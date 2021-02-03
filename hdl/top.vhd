library ieee;
use ieee.std_logic_1164.all;

entity top is
	port (
		CLK : in std_logic
	);
end entity;


architecture top_arch of top is
	component key_scheduler is
		port (
			clk: in std_logic;
			new_data: in std_logic;
			input: in std_logic_vector(127 downto 0);
			output: out std_logic_vector(127 downto 0);
			valid: out std_logic;
			round : in integer range 1 to 10
		);
	end component;
	signal s_new_data : std_logic := '0';
	signal s_input, s_output: std_logic_vector(127 downto 0) := (others => '0');
	signal s_valid : std_logic := '0';
	signal s_round : integer range 1 to 10 := 1;
begin
	key_scheduler1: key_scheduler port map(clk, s_new_data, s_input, s_output, s_valid, s_round);

end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity add_round_key is
	port (
		clk : in std_logic;
		input: in std_logic_vector(127 downto 0);
		key: in std_logic_vector(127 downto 0);
		output: out std_logic_vector(127 downto 0)
	);
end entity;


architecture add_round_key_arch of add_round_key is
begin
	xor_proc: process (clk) is
	begin
		if rising_edge(clk) then
			output <= input xor key;
		end if;
	end process;
end architecture;

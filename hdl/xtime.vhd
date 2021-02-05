library ieee;
use ieee.std_logic_1164.all;

entity xtime is
	port (
		clk : in std_logic;
		input: in std_logic_vector(7 downto 0);
		output: out std_logic_vector(7 downto 0)
	);
end entity;


architecture xtime_arch of xtime is
begin
	xtime_proc : process(clk) is
		variable v_out : std_logic_vector(7 downto 0) := (others => '0');
	begin
		if rising_edge(clk) then
			v_out := input sll 1;
			if input(7) = '1' then
				v_out := v_out xor x"1B";
			end if;
			output <= v_out;
		end if;
	end process;
end architecture;

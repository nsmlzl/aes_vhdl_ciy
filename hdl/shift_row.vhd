library ieee;
use ieee.std_logic_1164.all;
use work.aes_package.all;

entity shift_row is
	port (
		clk : in std_logic;
		input : in std_logic_vector(127 downto 0);
		output : out std_logic_vector(127 downto 0)
	);
end entity;


architecture shift_row_arch of shift_row is
	signal s_input, s_output : AES_T := (others => x"00");

begin
	s_input <= vec_to_aest(input);
	output <= aest_to_vec(s_output);

	sr_proc: process (clk) is
	begin
		if rising_edge(clk) then
			s_output(0)  <= s_input(0);
			s_output(1)  <= s_input(5);
			s_output(2)  <= s_input(10);
			s_output(3)  <= s_input(15);
			s_output(4)  <= s_input(4);
			s_output(5)  <= s_input(9);
			s_output(6)  <= s_input(14);
			s_output(7)  <= s_input(3);
			s_output(8)  <= s_input(8);
			s_output(9)  <= s_input(13);
			s_output(10) <= s_input(2);
			s_output(11) <= s_input(7);
			s_output(12) <= s_input(12);
			s_output(13) <= s_input(1);
			s_output(14) <= s_input(6);
			s_output(15) <= s_input(11);
		end if;
	end process;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use work.aes_package.all;

entity aes_package_tb is
end entity;


architecture aes_package_tb_arch of aes_package_tb is
	signal input_vec : std_logic_vector(127 downto 0) := (others => '0');
	signal out_arr: AES_T := (x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
								x"00", x"00", x"00", x"00"); 

	signal input_arr: AES_T := (x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
								x"00", x"00", x"00", x"00", x"00"); 
	signal out_vec : std_logic_vector(127 downto 0) := (others => '0');
begin
	out_arr <= vec_to_aest(input_vec);
	out_vec <= aest_to_vec(input_arr);

	stim_proc: process is
	begin
		wait for 1 us;

		input_vec <= x"00112233445566778899AABBCCDDEEFF";
		wait for 1 us;

		input_vec <= (others => '0');
		wait for 1 us;

		input_arr <= (x"FF", x"EE", x"DD", x"CC", x"BB", x"AA", x"99", x"88", x"77", x"66", x"55", x"44", x"33",
					 x"22", x"11", x"00");
		wait for 1 us;

		input_arr <= (x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01",
					 x"01", x"01", x"01");
		wait;
	end process;

	check_proc: process is
	begin
		wait for 1.5 us;
		assert out_arr = (x"00", x"11", x"22", x"33", x"44", x"55", x"66", x"77", x"88", x"99", x"AA", x"BB",
			x"CC", x"DD", x"EE", x"FF")
			report "vec_to_aest conversion 1 processed wrong value" severity failure;

		wait for 1 us;
		assert out_arr = (x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
			x"00", x"00", x"00", x"00")
			report "vec_to_aest conversion 2 processed wrong value" severity failure;

		wait for 1 us;
		assert out_vec = x"FFEEDDCCBBAA99887766554433221100"
			report "aest_to_vec conversion 1 processed wrong value" severity failure;

		wait for 1 us;
		assert out_vec = x"01010101010101010101010101010101"
			report "aest_to_vec conversion 2 processed wrong value" severity failure;


		report "success!";
		wait;
	end process;
end architecture;

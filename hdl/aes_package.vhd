library ieee;
use ieee.std_logic_1164.all;

package aes_package is
	type AES_T is array (0 to 15) of std_logic_vector(7 downto 0);

	function vec_to_aest (
		signal vec : in std_logic_vector(127 downto 0)
	)
	return AES_T;

	function aest_to_vec (
		signal aest : in AES_T
	)
	return std_logic_vector;

end package;


package body aes_package is
	function vec_to_aest (
		signal vec : in std_logic_vector(127 downto 0)
	)
	return AES_T is
		variable arr : AES_T;
	begin
		arr(0)  := vec(127 downto 120);
		arr(1)  := vec(119 downto 112);
		arr(2)  := vec(111 downto 104);
		arr(3)  := vec(103 downto 96);
		arr(4)  := vec(95  downto 88);
		arr(5)  := vec(87  downto 80);
		arr(6)  := vec(79  downto 72);
		arr(7)  := vec(71  downto 64);
		arr(8)  := vec(63  downto 56);
		arr(9)  := vec(55  downto 48);
		arr(10) := vec(47  downto 40);
		arr(11) := vec(39  downto 32);
		arr(12) := vec(31  downto 24);
		arr(13) := vec(23  downto 16);
		arr(14) := vec(15  downto 8);
		arr(15) := vec(7   downto 0);
		return arr;
	end function;

	function aest_to_vec (
		signal aest : in AES_T
	)
	return std_logic_vector is
		variable vec : std_logic_vector(127 downto 0);
	begin
		vec := aest(0) & aest(1) & aest(2) & aest(3) & aest(4) & aest(5) & aest(6) & aest(7) & aest(8) & aest(9) & aest(10) & aest(11) & aest(12) & aest(13) & aest(14) & aest(15);
		return vec;
	end function;

end package body;

library ieee;
use ieee.std_logic_1164.all;


entity aes_encrypt_tb is
end entity;


architecture tb of aes_encrypt_tb is
	constant clk_period : time := 62 ns;
	signal clk : std_logic := '0';

	constant timeout : integer := 1500;

	signal new_data, valid : std_logic := '0';
	signal plaintext, key, ciphertext : std_logic_vector(127 downto 0) := (others => '0');

	component aes_encrypt is
		port (
			clk : in std_logic;
			new_data : in std_logic;
			plaintext : in std_logic_vector(127 downto 0);
			key : in std_logic_vector(127 downto 0);
			valid : out std_logic;
			ciphertext : out std_logic_vector(127 downto 0)
		);
	end component;
begin
	clk <= not clk after clk_period / 2;

	aes_encrypt_1 : aes_encrypt port map(clk, new_data, plaintext, key, valid, ciphertext);

	stim_proc : process is
	begin
		for i in 0 to 9 loop
			wait until rising_edge(clk);
		end loop;
		
		plaintext <= x"4F816B7C87A0563D0D84BDE984A33D03";
		key <= x"9D5BFF851B0B81F841E7196736524BBD";
		new_data <= '1';

		wait until rising_edge(clk);
		new_data <= '0';

		for i in 0 to timeout loop
			wait until rising_edge(clk);
			if valid = '1' then
				exit;
			end if;
		end loop;
		

		-- next encryption
		for i in 0 to 19 loop
			wait until rising_edge(clk);
		end loop;

		plaintext <= x"83851FAB6041CDF54A416CDAF012C2D4";
		key <= x"F3541FA34B339C0D80237AF97C21D73B";
		new_data <= '1';

		wait until rising_edge(clk);
		new_data <= '0';

		wait;
	end process;

	check_proc : process is
	begin
		for i in 0 to timeout loop
			wait until rising_edge(clk);
			if valid = '1' then
				exit;
			end if;
			if i = timeout then
				report "Timeout during ciphertext processing!" severity failure;
			end if;
		end loop;

		assert ciphertext = x"BACF80FA05DF776E90CBF0E7D13335B4" report "Wrong ciphertext computed! [1]" severity failure;


		-- next encryption
		for i in 0 to 40 loop
			wait until rising_edge(clk);
		end loop;

		for i in 0 to timeout loop
			wait until rising_edge(clk);
			if valid = '1' then
				exit;
			end if;
			if i = timeout then
				report "Timeout during ciphertext processing!" severity failure;
			end if;
		end loop;

		assert ciphertext = x"29E5F495D404FD12D9CB8C2C9B2327C8" report "Wrong ciphertext computed! [2]" severity failure;
		report "success!" severity note;

		wait;
	end process;

end architecture;

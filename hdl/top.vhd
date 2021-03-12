library ieee;
use ieee.std_logic_1164.all;

entity top is
	port (
		CLK : in std_logic;
		LED : out std_logic;
		PIN_1 : in std_logic;
		PIN_2 : out std_logic
	);
end entity;


architecture top_arch of top is
	type top_state is (INIT, RESET, CNT, ENCPT, ENCPT_W1, ENCPT_W2, ENCPT_W3, TRGLED);
	signal state : top_state := INIT;

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
	signal new_data, valid : std_logic := '0';
	signal plaintext, key, ciphertext : std_logic_vector(127 downto 0) := (others => '0');

	signal s_led : std_logic := '0';

	signal counter : integer range 0 to 16000001 := 0;


	constant clk_divider : integer := 104;
	signal uart_clk_cnt : integer range 0 to 250 := 0;

	component uart is
		port (
			clk : in  std_logic;
			tx : out std_logic;
			rx : in  std_logic;
			tbyte : in  std_logic_vector(7 downto 0);
			tbyte_flag : in  std_logic;
			rbyte : out std_logic_vector(7 downto 0);
			rbyte_flag : out std_logic
		);
	end component;
	signal uart_clk : std_logic := '0';
	signal tx, rx : std_logic := '1';
	signal tbyte, rbyte : std_logic_vector(7 downto 0) := (others => '0');
	signal tbyte_f, rbyte_f : std_logic := '0';

begin
	-- generate from 16 MHz clk 19200*8 Hz clk
	clk_dvd_proc : process (clk) is
	begin
		if rising_edge(clk) then
			uart_clk_cnt <= uart_clk_cnt + 1;
			if uart_clk_cnt = clk_divider - 1 then
				uart_clk_cnt <= 0;
			end if;
			if uart_clk_cnt < clk_divider/2 then
				uart_clk <= '0';
			else
				uart_clk <= '1';
			end if;
		end if;
	end process;
	rx <= PIN_1;
	PIN_2 <= tx;
	tbyte_f <= rbyte_f;
	tbyte <= rbyte;
	uart1 : uart port map (uart_clk, tx, rx, tbyte, tbyte_f, rbyte, rbyte_f);


	LED <= s_led;
	aes_encrypt_1 : aes_encrypt port map (CLK, new_data, plaintext, key, valid, ciphertext);

	nstate_proc : process (CLK) is
	begin
		if rising_edge(CLK) then
			case state is
				when INIT =>
					state <= RESET;
				when RESET =>
					state <= CNT;
				when CNT =>
					if counter = 16000000 then
						state <= ENCPT;
					end if;
				when ENCPT =>
					state <= ENCPT_W1;
				when ENCPT_W1 =>
					state <= ENCPT_W2;
				when ENCPT_W2 =>
					state <= ENCPT_W3;
				when ENCPT_W3 =>
					if valid = '1' then
						state <= TRGLED;
					end if;
				when TRGLED =>
					state <= RESET;
			end case;
		end if;
	end process;

	out_proc : process (CLK) is
	begin
		if rising_edge(CLK) then
			case state is
				when INIT =>
					s_led <= '0';
					new_data <= '0';
					plaintext <= (others => '0');
					key <= (others => '0');
				when RESET =>
					counter <= 0;
				when CNT =>
					counter <= counter + 1;
				when ENCPT =>
					plaintext <= x"4F816B7C87A0563D0D84BDE984A33D03";
					key <= x"9D5BFF851B0B81F841E7196736524BBD";
					new_data <= '1';
				when ENCPT_W1 =>
					new_data <= '0';
				when TRGLED =>
					if ciphertext = x"BACF80FA05DF776E90CBF0E7D13335B4" then
						s_led <= not s_led;
					end if;
				when others =>
			end case;
		end if;
	end process;
end architecture;

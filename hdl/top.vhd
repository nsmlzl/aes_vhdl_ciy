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
	signal new_data, valid, valid_d, valid_w : std_logic := '0';
	signal plaintext, key, ciphertext : std_logic_vector(127 downto 0) := (others => '0');

	signal s_led : std_logic := '0';


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

	signal input_buf : std_logic_vector(287 downto 0) := (others => '0');
	signal eot, eot_d : std_logic := '0';

	type tx_state_t is (IDLE, TX_WRT, TX_W);
	signal tx_state : tx_state_t := IDLE;
	signal tx_byte_cnt : integer := 0;
	signal tx_wait_cnt : integer range 0 to 100 := 0;

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
	LED <= s_led;

	uart1 : uart port map (uart_clk, tx, rx, tbyte, tbyte_f, rbyte, rbyte_f);
	aes_encrypt_1 : aes_encrypt port map (CLK, new_data, plaintext, key, valid, ciphertext);


	led_proc : process (clk) is
	begin
		if rising_edge(clk) then
			valid_d <= valid;
			if valid_d = '0' and valid = '1' then
				s_led <= not s_led;
			end if;
		end if;
	end process;


	buf_proc : process (uart_clk) is
	begin
		if rising_edge(uart_clk) then
			if rbyte_f = '1' then
				input_buf <= input_buf(279 downto 0) & rbyte;
			end if;
		end if;
	end process;

	eot_proc : process(clk) is
	begin
		if rising_edge(clk) then
			eot_d <= eot;
			if input_buf(31 downto 0) = x"000000FF" then
				eot <= '1';
			else
				eot <= '0';
			end if;
		end if;
	end process;

	trg_encpt_proc : process(clk) is
	begin
		if rising_edge(clk) then
			new_data <= '0';
			if eot_d = '0' and eot = '1' then
				new_data <= '1';
				plaintext <= input_buf(287 downto 160);
				key <= input_buf(159 downto 32);
			end if;
		end if;
	end process;

	valid_w_proc : process (clk) is
	begin
		if rising_edge(clk) then
			if valid_d = '0' and valid = '1' then
				valid_w <= '1';
			elsif tx = '0' then
				valid_w <= '0';
			end if;
		end if;
	end process;

	nstate_tx_proc : process (uart_clk) is
	begin
		if rising_edge(uart_clk) then
			case tx_state is
				when IDLE =>
					if valid_w = '1' then
						tx_state <= TX_WRT;
					end if;
				when TX_WRT =>
					tx_state <= TX_W;
				when TX_W =>
					if tx_wait_cnt = 82 then
						tx_state <= TX_WRT;
						if tx_byte_cnt = 16 then
							tx_state <= IDLE;
						end if;
					end if;
			end case;
		end if;
	end process;

	out_tx_proc : process (uart_clk) is
		variable bit_pos : integer := 0;
	begin
		if rising_edge(uart_clk) then
			case tx_state is
				when IDLE =>
					tx_byte_cnt <= 0;
				when TX_WRT =>
					tx_byte_cnt <= tx_byte_cnt + 1;
					tx_wait_cnt <= 0;
					for i in 0 to 7 loop
						bit_pos := i + 120 - 8 * tx_byte_cnt;
						tbyte(i) <= ciphertext(bit_pos);
					end loop;
					tbyte_f <= '1';
				when TX_W =>
					tx_wait_cnt <= tx_wait_cnt + 1;
					tbyte_f <= '0';
			end case;
		end if;
	end process;

end architecture;

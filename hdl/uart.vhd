library IEEE;
use IEEE.std_logic_1164.all;


entity uart is
	port (
		clk			: in  std_logic;
		tx			: out std_logic;
		rx			: in  std_logic;
		tbyte		: in  std_logic_vector(7 downto 0);
		tbyte_flag	: in  std_logic;
		rbyte		: out std_logic_vector(7 downto 0);
		rbyte_flag	: out std_logic
	);
end entity;

architecture uart_arch of uart is
	type tx_state_t is (IDLE, SET, COUNT);
	signal tx_state : tx_state_t := IDLE;

	signal s_tdata	: std_logic_vector(9 downto 0);


	type rx_state_t is (IDLE, WAITING, STORE, FINISH);
	signal rx_state	: rx_state_t := IDLE;

	signal s_rdata	: std_logic_vector(9 downto 0);
	signal s_rx		: std_logic;


begin

	tx_fsm: process(clk)
		constant c_clk		: integer := 8;
		variable v_cnt_bit	: integer := 0;
		variable v_cnt_clk	: integer := 0;

	begin
		if rising_edge(clk) then
			case tx_state is
				-- wait for new byte to transfer
				when IDLE =>
					tx <= '1';
					v_cnt_bit := 0;
					-- store data and add startbit and endbit
					s_tdata <= '1' & tbyte & '0';
					if tbyte_flag = '1' then
						tx_state <= SET;
					end if;

				-- set tx for corresponding bit
				when SET =>
					v_cnt_clk := 0;
					tx <= s_tdata(v_cnt_bit);
					v_cnt_bit := v_cnt_bit + 1;
					tx_state <= COUNT;

				-- wait to transfer next bit
				when COUNT =>
					v_cnt_clk := v_cnt_clk + 1;
					if v_cnt_clk = c_clk - 1 then
						if v_cnt_bit = 10 then
							tx_state <= IDLE;
						else
							tx_state <= SET;
						end if;
					end if;
			end case;
		end if;
	end process;

	rx_fsm: process(clk)
		variable v_cnt_bit	: integer := 0;
		variable v_cnt_clk	: integer := 0;
	begin
		if rising_edge(clk) then
			case rx_state is
				when IDLE =>
					v_cnt_bit := 0;
					v_cnt_clk := 3;
					s_rdata <= (others => '0');
					rbyte_flag <= '0';
					-- detect falling edge
					s_rx <= rx;
					if s_rx = '1' and rx = '0' then
						rx_state <= WAITING;
					end if;

				-- wait till next store
				when WAITING =>
					v_cnt_clk := v_cnt_clk - 1;
					if v_cnt_clk = 0 then
						rx_state <= STORE;
					end if;

				-- store corresponding bit
				when STORE =>
					s_rdata(v_cnt_bit) <= rx;
					v_cnt_clk := 7;
					v_cnt_bit := v_cnt_bit + 1;
					if v_cnt_bit = 10 then
						rx_state <= FINISH;
					else
						rx_state <= WAITING;
					end if;

				-- output received data
				when FINISH =>
					rbyte <= s_rdata(8 downto 1);
					rbyte_flag <= '1';
					rx_state <= IDLE;
			end case;
		end if;
	end process;

end architecture;

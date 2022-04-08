-- uart.vhd: UART controller - receiving part
-- Author(s): Tadeas Vintrlik <xvintr04>
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

-------------------------------------------------
entity UART_RX is
port(	
	CLK: 	    in std_logic;
	RST: 	    in std_logic;
	DIN: 	    in std_logic;
	DOUT: 	    out std_logic_vector(7 downto 0);
	DOUT_VLD: 	out std_logic
);
end UART_RX;  

-------------------------------------------------
architecture behavioral of UART_RX is
  signal MOD16CLK : std_logic := '0';
  signal DATA_START : std_logic := '0';
  signal DATA_END : std_logic := '0';
  signal DATA_VALID : std_logic := '0';
  signal READ_EN : std_logic := '0';
begin
	fsm : entity work.UART_FSM
	port map (
		CLK => CLK,
		RST => RST,
		MOD16CLK => MOD16CLK,
		DATA_START => DATA_START,
		DIN => DIN,
		DATA_END => DATA_END,
		DATA_VALID => DATA_VALID,
		READ_EN => READ_EN
		);
		
		-- Reads byte of data
		cnt8: process (MOD16CLK, DATA_START)
		  variable cnt8 : std_logic_vector (2 downto 0) := "000";
		begin
			if DATA_START = '1' then
				cnt8 := "000";
		   elsif rising_edge(MOD16CLK) and READ_EN = '1' then
		     DOUT(conv_integer(cnt8)) <= DIN;
		     cnt8 := cnt8 + 1;
				if cnt8 = "111" then
				  DATA_END <= '1';
				else
				  DATA_END <= '0';
				end if;
		   end if;

		end process;
		
		DOUT_VLD <= DATA_VALID;
  
end behavioral;

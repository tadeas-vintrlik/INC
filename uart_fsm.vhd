-- uart_fsm.vhd: UART controller - finite state machine
-- Author(s): Tadeas Vintrlik <xvintr04>
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-------------------------------------------------
entity UART_FSM is
port(
   CLK : in std_logic;
   RST : in std_logic;
   DIN : in std_logic;
   MOD16CLK : out std_logic;
   DATA_START : out std_logic;
   DATA_END : in std_logic;
   DATA_VALID : out std_logic;
   READ_EN : out std_logic
   );
end 
entity UART_FSM;

-------------------------------------------------

architecture behavioral of UART_FSM is
  type state is (SInit, SData, SEndData, SValid);
  signal cstate : state := SInit;
  signal LOCAL_CLK : std_logic := '0';
begin
  
  -- Divides CLK by 16
  cnt16: process(CLK, RST)
    variable LOCAL : std_logic_vector (3 downto 0) := "0000";
  begin
      if RST = '1' then
        LOCAL := "0000";
      elsif rising_edge(CLK) then
        LOCAL := LOCAL + 1;
        if LOCAL = "1000" then
          LOCAL_CLK <= '1';
        else
          LOCAL_CLK <= '0';
        end if;
      end if;
  end process;
  
  -- Handles state logic of FSM
  statelogic: process(CLK, LOCAL_CLK)
  begin
    if rising_edge(CLK) then
      DATA_START <= '0';
	    DATA_VALID <= '0';
	    if LOCAL_CLK = '1' then
        if cstate = SInit then
          -- startbit
          READ_EN <= '1';
          if DIN = '0' then
            cstate <= SData;
          		DATA_START <= '1';
          end if;
      		elsif cstate = SData and DATA_END = '1' then
          cstate <= SEndData;
        elsif cstate = SEndData then
          cstate <= SValid;
          READ_EN <= '0';
        elsif cstate = SValid then
          cstate <= SInit;
          DATA_VALID <= '1';
          READ_EN <= '0';
        end if;
      end if;
    end if;
  end process;
  
  MOD16CLK <= LOCAL_CLK;

  
end behavioral;

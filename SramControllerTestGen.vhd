library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.Types.all;

entity SramControllerTestGen is
	generic (
		AddrW : positive := 18;
		DataW : positive := 16
	);
	port (
	Clk : in bit1;
	RstN : in bit1;
	--
	Button0 : in bit1;
	Button1 : in bit1;
	--
	Addr : out word(AddrW-1 downto 0);
	Data : out word(DataW-1 downto 0);
	We   : out bit1;
	Re   : out bit1
	);
end entity;

architecture rtl of SramControllerTestGen is
	constant noWords : positive := 262144;
	constant noWordsW : positive := bits(NoWords);

	signal SeqCnt_N, SeqCnt_D : word(NoWordsW downto 0);
	--
	signal Btn0State_N, Btn0State_D : bit1;
	signal Btn1State_N, Btn1State_D : bit1;
	signal Addr_N, Addr_D : word(AddrW-1 downto 0);
	
	signal Button0Stable : bit1;
	signal Button1Stable : bit1;
	
	constant Delay : positive := 1;
	constant DelayW : positive := bits(Delay);
	signal WaitCnt_N, WaitCnt_D : word(DelayW-1 downto 0);
	
	constant NumbersPerSec : positive := 20;
	constant ClkFreq : positive := 50000000;
	constant ClksPerNbr : positive := ClkFreq / NumbersPerSec;
	constant ClksPerNbrW : positive := bits(ClksPerNbr);
	signal ToggleCnt_N, ToggleCnt_D : word(ClksPerNbrW-1 downto 0);
	
begin
	Button0Debounce : entity work.Debounce
	port map (
		Clk => Clk,
		x => Button0,
		DBx => Button0Stable
	);
	
	Button1Debounce : entity work.Debounce
	port map (
		Clk => Clk,
		x => Button1,
		DBx => Button1Stable
	);

	SyncProcRst : process (Clk, RstN)
	begin
		if RstN = '0' then
			Btn0State_D <= '1';
			Btn1State_D <= '1';
			Addr_D <= (others => '0');
			SeqCnt_D <= (others => '0');
			WaitCnt_d <= (others => '0');
			ToggleCnt_D <= (others => '0');
		elsif rising_edge(Clk) then
			Btn0State_D <= Btn0State_N;
			Btn1State_D <= Btn1State_N;
			Addr_D <= Addr_N;
			SeqCnt_D <= SeqCnt_N;
			WaitCnt_D <= WaitCnt_N;
			ToggleCnt_D <= ToggleCnt_N;
		end if;
	end process;
	
	AsyncProc : process (Btn0State_D, Btn1State_D, Addr_D, Button0Stable, Button1Stable, SeqCnt_D, WaitCnt_D, ToggleCnt_D)
	begin
		We <= '0';
		Re <= '0';
		Data <= (others => '0');
		Btn0State_N <= Button0Stable;
		Btn1State_N <= Button1Stable;
		Addr_N <= Addr_D;
		SeqCnt_N <= SeqCnt_D;
		ToggleCnt_N <= ToggleCnt_D + 1;
		
		WaitCnt_N <= WaitCnt_D;
		if (WaitCnt_D > 0) then
			WaitCnt_N <= WaitCnt_D - 1;
--		elsif SeqCnt_D < noWords then
--			SeqCnt_N <= SeqCnt_D + 1;
--			Addr_N <= SeqCnt_D(Addr_N'range);
--			We <= '1';
--			Data <= SeqCnt_D(Data'range);
--			WaitCnt_N <= conv_word(Delay, WaitCnt_N'length);
		elsif Button0Stable = '0' and Btn0State_D = '1' then
			Addr_N <= Addr_D - 1;
			Re <= '1';
			WaitCnt_N <= conv_word(Delay, WaitCnt_N'length);
		elsif Button1Stable = '0' and Btn1State_D = '1' then
			Addr_N <= Addr_D + 1;
			Re <= '1';
			WaitCnt_N <= conv_word(Delay, WaitCnt_N'length);
		elsif ToggleCnt_D = ClksPerNbr-3 then
			Addr_N <= Addr_D + 2;
			We <= '1';
			WaitCnt_N <= conv_word(Delay, WaitCnt_N'length);
			SeqCnt_N <= SeqCnt_D + 1;
			Data <= SeqCnt_D(Data'range);
		elsif ToggleCnt_D = ClksPerNbr-1 then
			Addr_N <= Addr_D - 1;
			Re <= '1';
			WaitCnt_N <= conv_word(Delay, WaitCnt_N'length);
			ToggleCnt_N <= (others => '0');
		end if;
	end process;
	Addr <= Addr_N;

end architecture;
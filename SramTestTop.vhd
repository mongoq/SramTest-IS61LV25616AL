library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.Types.all;
use work.BcdPack.all;

entity SramTestTop is
	generic (
	Displays : positive := 8;
	AddrW : positive := 18;
	DataW : positive := 16
	);
	port (
	Clk      : in bit1;
	Button3  : in bit1;
	--
	Segments : out word(BcdSegs-1 downto 0);
	Display  : out word(Displays-1 downto 0);
	--
	D       : inout word(DataW-1 downto 0);
	AddrOut : out word(AddrW-1 downto 0);
	CeN     : out bit1;
	OeN     : out bit1;
	WeN     : out bit1;
	UbN     : out bit1;
	LbN     : out bit1
	--
	);
end entity;

architecture rtl of SramTestTop is

	constant Freq : positive := 50000000;
	--
	signal Data : word(bits(10**Displays)-1 downto 0);
	
	signal Addr : word(AddrW-1 downto 0);
	signal SramWrData : word(DataW-1 downto 0);
	signal SramRdData : word(DataW-1 downto 0);
	signal SramWe : bit1;
	signal SramRe : bit1;

begin
	Data <= conv_word(12345678, Data'length);
	Addr <= (others => '0');
	SramWrData <= (others => '0');
	SramWe <= '0';
	SramRe <= '0';

	BCDDisplay : entity work.BcdDisp
	generic map (
		Freq => Freq,
		Displays => Displays
	)
	port map (
		Clk	=> Clk,
		--
		Data => Data,
		--
		Segments => Segments,
		Display  => Display
	);
	
	SramCont : entity work.SramController
	port map (
		Clk  => Clk,
		RstN => Button3,
		--
		AddrIn => Addr,
		WrData => SramWrData,
		RdData => SramRdData,
		We     => SramWe,
		Re     => SramRe,
		--
		D      => D,
		AddrOut => AddrOut,
		CeN    => CeN,
		OeN    => OeN,
		WeN    => WeN,
		UbN    => UbN,
		LbN    => LbN
	);
	
	
	
end architecture rtl;
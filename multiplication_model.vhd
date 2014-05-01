library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiplier is
	generic(M,N: positive := 4);
	port(
		a: in unsigned(M-1 downto 0); -- M-bit number_1 parallel input
		b: in unsigned(N-1 downto 0); -- N-bit number_2 parallel input
		p: out unsigned(M+N-1 downto 0); -- (M+N-1)-bit number_3 parallel output
		clock, reset: in std_logic;
		start: in std_logic;
		ready: out std_logic);
end multiplier;

architecture arch1 of multiplier is
	-- signals
	shared variable num1: unsigned(M-1 downto 0);
	shared variable num2: unsigned(N-1 downto 0);
	signal num3: unsigned(M+N-1 downto 0);
	shared variable temp: unsigned (M+N-1 downto 0);
	shared variable CNT: integer;
	signal enable: std_logic;
	signal finished: std_logic;
begin
	-- processes
	process(clock, reset, start)
	begin
		if (rising_edge(reset)) then
			num1 := (others=>'0');
			num2 := (others=>'0');
			num3 <= (others=>'0');
			temp := (others=>'0');
			enable <= '0';
			finished <='0';
			CNT := 0;
		elsif (rising_edge(start)) then
			num1 := a;
			num2 := b;
			num3 <= (others=>'0');
			enable <= '1';
			finished <= '0';
			CNT := 0;
		elsif ((finished = '1') and (enable = '1') and rising_edge(clock)) then
			enable <= '0';
			finished <= '0';
		elsif ((finished = '0') and (enable = '1') and rising_edge(clock)) then
			if (CNT = N) then
				finished <= '1';
			else
				if (num2(CNT) = '1') then
					temp := (others=>'0');
					temp(CNT+(N-1) downto CNT) := num1;
					num3 <= num3 + temp;
					CNT := CNT + 1;
				else
					CNT := CNT + 1;
				end if;
			end if;
		end if;
	end process;

	p <= num3;
	ready <= finished;
end arch1;

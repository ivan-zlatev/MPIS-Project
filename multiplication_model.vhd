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
	shared variable num1: unsigned(M-1 downto 0); -- variable for the first number
	shared variable num2: unsigned(N-1 downto 0); -- variable for the second number
	signal num3: unsigned(M+N-1 downto 0); -- variable for the result
	shared variable temp: unsigned (M+N-1 downto 0); -- variable for shifting num1
	shared variable CNT: integer; -- variable for shift counter
	signal enable: std_logic;
	signal finished: std_logic;
begin
	process(clock, reset, start)
	begin
		if (rising_edge(reset)) then -- if there is a reset signal -> reset all
			num1 := (others=>'0');
			num2 := (others=>'0');
			num3 <= (others=>'0');
			temp := (others=>'0');
			enable <= '0';
			finished <='0';
			CNT := 0;
		elsif (rising_edge(start) and reset = '0') then -- if there is a start signal and reset is at zero -> init all
			num1 := a;
			num2 := b;
			num3 <= (others=>'0');
			enable <= '1';
			finished <= '0';
			CNT := 0;
		elsif ((finished = '1') and (enable = '1') and rising_edge(clock)) then -- finished signal duration is one clock period
			enable <= '0';
			finished <= '0';
		elsif ((finished = '0') and (enable = '1') and rising_edge(clock)) then -- if finished is unset and enable is set -> start multiplication
			if (CNT = N) then -- if multiplication is over -> set finished
				finished <= '1';
			else -- if multiplication is not over -> do the next step
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

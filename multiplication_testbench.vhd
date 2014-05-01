library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiplier_test is
end multiplier_test;

architecture Behavioral of multiplier_test is

	type int_array is array( natural range<>) of integer;

	-- constants
	constant M,N: positive := 4;
	constant CLOCK_PERIOD : time := 1 us;

	-- signals
	signal num1: unsigned(M-1 downto 0);
	signal num2: unsigned(N-1 downto 0);
	signal res: unsigned(M+N-1 downto 0);
	signal clock, reset, start, ready: std_logic;
	signal clock_run : boolean := true;
	
	-- variables
	shared variable expected: integer;
	shared variable X_value: int_array(9 downto 0) := (1,2,3,4,5,6,7,8,9,10); -- array for the first number
	shared variable Y_value: int_array(9 downto 0) := (10,9,8,7,6,5,4,3,2,1); -- array for the second number

begin

	uut: entity work.multiplier port map(num1, num2, res, clock, reset, start, ready);

	clock_process :process
	begin
		if clock_run then
			clock <= '0';
			wait for CLOCK_PERIOD/2;
			clock <= '1';
			wait for CLOCK_PERIOD/2;
		else
			wait;
		end if;
	end process;

	testing_process: process
	begin
		-- reset testing
		reset <= '0';
		wait until falling_edge(clock);
		reset <= '1';
		start <= '0';
		wait until falling_edge(clock);
		reset <= '0';
	 
		-- multiplication testing using X and Y array values
		for i in X_value'length-1 downto 0 loop
			wait until falling_edge(clock);
			num1 <= to_unsigned(X_value(i),M);
			num2 <= to_unsigned(Y_value(i),N);
			expected := X_value(i)*Y_value(i);
			wait until falling_edge(clock);
			start <= '1';
			wait until falling_edge(clock);
			start <= '0';
			wait until rising_edge(ready);
			wait until falling_edge(clock);
			assert res = expected report "Expected: " & integer'image(expected) & ", actual: " & integer'image(to_integer(res));
		end loop;

		clock_run <= false;
		wait;
	end process;
end;

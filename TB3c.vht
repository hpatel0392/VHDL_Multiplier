LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.std_logic_arith.all;
LIBRARY work;
USE work.ALL;

entity testbench is
	generic(N :integer := 8);
end entity;

architecture addTest of testbench is
	
	signal cin, cout : std_logic := '0';
	signal A, B, S: std_logic_vector(N-1 DOWNTO 0) := "00000000"; 
	
begin
	
	dut : entity n_adder
		port map(A => A, 
					B => B,
					S => S, 
					Cin => cin,
					Cout => cout);
		
	-- test cases
	process
	begin
		A <= "00000001";
		B <= "00000001";
		wait for 10 ns;
		Cin <= '1';
		wait for 10 ns;
		A <= "00000010";
		B <= "10100000";
		wait;
	end process;
end architecture;
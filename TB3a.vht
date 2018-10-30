LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
LIBRARY work;
USE work.ALL;

entity testbench is
	generic(N :integer := 8);
end entity;

architecture regTest of testbench is
	
	signal clk : std_logic := '0';
	signal shift : std_logic := '0';
	signal P : std_logic_vector(N-1 DOWNTO 0) := (others => '0');
	signal S : std_logic := '1';
	signal load : std_logic := '0';
	signal Q : std_logic_vector(N-1 DOWNTO 0);
	
begin
	
	dut : entity shiftReg
		port map(P_in => P, 
					S_in => S,
					clk => clk, 
					load => load,
					shift => shift,
					Q => Q);
		
	-- clock
	process
	begin
		clk <= not(clk);
		wait for 5 ns;
	end process;
	
	-- test cases
	process
	begin
		wait until(rising_edge(clk));
		load <= '1';
		wait until(rising_edge(clk));
		load <= '0';
		shift <= '1';
		wait for 40 ns;
		S <= '0';
		wait for 40 ns;
		load <= '1';
		wait;
	end process;
end architecture;
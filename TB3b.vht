LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.std_logic_arith.all;
LIBRARY work;
USE work.ALL;

entity testbench is
	generic(N :integer := 8);
end entity;

architecture conTest of testbench is
	
	signal clk : std_logic := '0';
	signal start, busy : std_logic := '0';
	signal cycle : std_logic_vector(N-1 DOWNTO 0) := "00000100";
	signal multbits, addselect : std_logic_vector(2 DOWNTO 0) := "000"; 
	signal loadreg, addreg, count, shiftreg: std_logic := '0';
	
begin
	
	dut : entity control
		port map(start => start, 
					busy => busy,
					clk => clk, 
					cycle => cycle,
					multbits => multbits,
					addselect => addselect,
					loadreg => loadreg,
					addreg => addreg,
					count => count,
					shiftreg => shiftreg);
		
	-- clock
	process
	begin
		clk <= not(clk);
		wait for 5 ns;
	end process;
	
	-- count
	process(clk, count)
		variable temp : std_logic_vector(N-1 DOWNTO 0);
	begin
		if(rising_edge(clk)) then
			if(count = '1') then
				temp := cycle - 1;
				cycle <= temp;
			end if;
		end if;
	end process;
	
	-- test cases
	process
	begin
		start <= '1';
		wait for 20 ns;
		multbits <= "010";
		wait for 20 ns;
		multbits <= "111";
		wait;
	end process;
end architecture;
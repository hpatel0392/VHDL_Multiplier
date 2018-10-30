LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;
LIBRARY work;
USE work.ALL;

entity testbench is
	generic(N :integer := 16);
end entity;

architecture multTest of testbench is
	
	signal clk : std_logic := '0';
	signal stopClk : std_logic := '0';
	
	signal ivalid : std_logic := '0';
	signal done : std_logic := '0';
	signal multiplicand : std_logic_vector(N-1 DOWNTO 0);
	signal multiplier : std_logic_vector(N-1 DOWNTO 0);
	signal data : std_logic_vector((N*2)-1 DOWNTO 0);
	signal result : std_logic_vector((N*2)-1 DOWNTO 0) := (others => '0');
begin
	
	dut : entity bitpair generic map(N => N)
		port map(datain => data, 
					ivalid => ivalid,
					done => done,
					clock => clk,  
					dataout => result);
		
	-- clock
	process
	begin
		clk <= not(clk);
		if(stopClk = '1') then -- so the simulation stops when the result is obtained
			wait;
		else 
			wait for 5 ns;
		end if;
	end process;
	
	-- test cases
	process
		variable A, B : integer;
	begin
		A := 128;
		B := 127;
		multiplicand <= std_logic_vector(to_signed(A, multiplicand'length));
		multiplier <= std_logic_vector(to_signed(B, multiplier'length));
		wait for 10 ns;
		data <= multiplicand & multiplier;
		wait until(falling_edge(clk));
		ivalid <= '1';
		wait until(rising_edge(done));
		stopClk <= '1';
	end process;
end architecture;
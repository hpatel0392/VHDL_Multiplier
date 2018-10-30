library ieee;
use ieee.std_logic_1164.all;

entity shiftReg is 
	generic(N : integer := 8);
	port( P_in : IN std_logic_vector(N-1 DOWNTO 0); 
		   S_in : IN std_logic;
			load, shift, clk : IN std_logic;
		   Q : BUFFER std_logic_vector((N-1) DOWNTO 0));
end shiftReg;
		
architecture behavior of shiftReg is
begin
	process(clk)
		variable s : std_logic := S_in;
		variable temp : std_logic_vector(N-1 DOWNTO 0) := Q;
	begin
		s := S_in;
		if(rising_edge(clk)) then
			if(load = '1') then
				Q <= P_in;
			elsif(shift = '1') then
				temp := s & Q(N-1 DOWNTO 1);
				Q <= temp;
			end if;
		end if;
	end process;
end behavior;


library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE ieee.std_logic_arith.all;

entity countReg is 
	generic(N : integer := 8);
	port( P_in : IN std_logic_vector(N-1 DOWNTO 0); 
			load, dec, clk : IN std_logic;
		   Q : BUFFER std_logic_vector((N-1) DOWNTO 0));
end countReg;
		
architecture behavior of countReg is
begin
	process(clk)
		variable temp : std_logic_vector(N-1 DOWNTO 0) := Q;
	begin
		if(rising_edge(clk)) then
			if(load = '1') then
				Q <= P_in;
			elsif(dec = '1') then
				temp := Q - 1;
				Q <= temp;
			end if;
		end if;
	end process;
end behavior;


LIBRARY ieee;
use ieee.std_logic_1164.all;

ENTITY full_adder IS PORT(
	a, b, ci :  IN std_logic;
	sum, co :		OUT std_logic);
end full_adder;

architecture behavior of full_adder is
begin
	add : process(a, b, ci)
	variable ch : std_logic;
	begin
		if((a XOR b) = '0') then
			ch := b;
		elsif ((a XOR b) = '1') then
			ch := ci;
		else
			ch := '0';
		end if;
		sum <= (a XOR b) XOR ci;
		co <= ch;
	end process;
end behavior;
			
LIBRARY ieee;
use ieee.std_logic_1164.all;

entity n_adder is
	generic(N : integer := 8);
	port( A, B : IN std_logic_vector(N-1 DOWNTO 0);
		   Cin : IN std_logic; 
			S : OUT std_logic_vector(N-1 DOWNTO 0); 
			Cout : OUT std_logic);
end n_adder;

architecture structure of n_adder is
	component full_adder
		port( a, b, ci : IN std_logic;
			   sum, co : OUT std_logic);
	end component;
	
	signal carry : std_logic_vector(N DOWNTO 0);
begin
   carry(0) <= Cin;
	gen_adder : 
	for i in 0 to N-1 generate
		addn : full_adder
			port map(A(i), B(i), carry(i), S(i), carry(i+1));
	end generate gen_adder;
	Cout <= carry(N);
end structure;	



library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity control is
	generic(N : integer := 8);
	port( start, clk : IN std_logic;
		   cycle : IN std_logic_vector(N-1 DOWNTO 0);
			multbits : IN std_logic_vector(2 DOWNTO 0);
			addselect : OUT std_logic_vector(2 DOWNTO 0) := "000";
			loadreg, addreg, count, shiftreg: OUT std_logic := '0';
			busy : OUT std_logic := '0');
end control;

architecture state_machine of control is
	type states is (READY, LOAD, MULT,
						 SHIFT1, SHIFT2, DONE);
	signal y_pres, y_next : states := READY;
begin
	addselect <= multbits;
	
	process(y_pres, clk)
	begin
		if(falling_edge(clk)) then
		case y_pres is
			when READY =>
				if start = '1' then
					y_next <= LOAD;
				else
					y_next <= READY;
				end if;
				busy <= '0';
				
			when LOAD =>
				y_next <= MULT;
				loadreg <= '1';
				busy <= '1';
				
			when MULT =>
				if(cycle /= 0) then
					y_next <= SHIFT1;
					addreg <= '1';
				else
					y_next <= DONE;
					addreg <= '0';
				end if;
				loadreg <= '0';
				shiftreg <= '0';
				count <= '0';
				
			when SHIFT1 =>
				y_next <= SHIFT2;
				addreg <= '0';
				shiftreg <= '1';
				
			when SHIFT2 =>
				y_next <= MULT;
				count <= '1';
				
			when DONE =>
				y_next <= READY;
				busy <= '0';
				addreg <= '0';
				loadreg <= '0';
				shiftreg <= '0';
				count <= '0';
		end case;
		end if;
	end process;
	
	process(clk)
	begin
	   if(rising_edge(clk)) then
			y_pres <= y_next;
		end if;
	end process;
end state_machine;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity bitpair is 
	generic(N : integer := 8);
	port( datain: IN std_logic_vector((N*2)-1 DOWNTO 0);
			ivalid, clock: IN std_logic;
			done : OUT std_logic;
	      dataout : OUT std_logic_vector((N*2)-1 DOWNTO 0));
end bitpair;

architecture structure of bitpair is
	component shiftReg
		generic(N : integer := 8);
		port( P_in : IN std_logic_vector(N-1 DOWNTO 0); 
				S_in : IN std_logic;
				load, shift, clk : IN std_logic;
				Q : BUFFER std_logic_vector((N-1) DOWNTO 0));
	end component;
	component countReg
		generic(N : integer := 8);
		port( P_in : IN std_logic_vector(N-1 DOWNTO 0); 
				load, dec, clk : IN std_logic;
				Q : BUFFER std_logic_vector((N-1) DOWNTO 0));
	end component;
	component n_adder
		generic(N : integer := 8);
		port( A, B : IN std_logic_vector(N-1 DOWNTO 0);
				Cin : IN std_logic; 
				S : OUT std_logic_vector(N-1 DOWNTO 0); 
				Cout : OUT std_logic);
	end component;
	component control
	generic(N : integer := 8);
	port( start, clk : IN std_logic;
		   cycle : IN std_logic_vector(N-1 DOWNTO 0);
			multbits : IN std_logic_vector(2 DOWNTO 0);
			addselect : OUT std_logic_vector(2 DOWNTO 0);
			loadreg, addreg, count, shiftreg: OUT std_logic;
			busy : OUT std_logic);
	end component;
	
	signal H : std_logic;
	signal L : std_logic;
	signal A_to_mux : std_logic_vector(N DOWNTO 0) := (others => '0'); 
	signal mux_to_add : std_logic_vector(N DOWNTO 0) := (others => '0');
	signal resultB : std_logic_vector(N DOWNTO 0) := (others => '0');
	signal adder_to_mux : std_logic_vector(N DOWNTO 0) := (others => '0');
	signal multiplicand : std_logic_vector(N DOWNTO 0) := L & datain((N*2)-1 DOWNTO N); 
	signal multiplier : std_logic_vector(N DOWNTO 0) := datain(N-1 DOWNTO 0)& L;
	signal mux_to_B : std_logic_vector(N DOWNTO 0) := (others => '0');
	signal resultC: std_logic_vector(N DOWNTO 0) := (others => '0');
	
	signal count_to_ctrl : std_logic_vector(7 DOWNTO 0) := (others => '0');
	signal bitframe : std_logic_vector(2 DOWNTO 0) := (others => '0'); 
	signal addselect : std_logic_vector(2 DOWNTO 0) := (others => '0');
	
	signal shiftinB : std_logic := '0';
	signal shiftinC : std_logic := '0';
	signal carryOut : std_logic;
	signal loadreg : std_logic := '0'; 
	signal shift : std_logic := '0';
	signal addreg : std_logic := '0';
	signal count : std_logic := '0';
	
	signal sigBusy : std_logic := '0';
	
	signal cycles : std_logic_vector(7 DOWNTO 0) := (others=> '0');
	signal loadB : std_logic := '0';
begin

	-- Set up signal values
	done <= not(sigBusy);
	H <= '1'; L <= '0';
	with datain((N*2)-1) select
		multiplicand <= L & datain((N*2)-1 DOWNTO N) when '0',
							 H & datain((N*2)-1 DOWNTO N) when others;
	
	multiplier <= datain(N-1 DOWNTO 0)& L;
	cycles <= std_logic_vector(to_unsigned(N/2, cycles'length));
	bitframe <= resultC(2 DOWNTO 0);
	loadB <= loadreg OR addreg;
	shiftinC <= resultB(0);
	shiftinB <= resultB(N) when loadB = '1';
	with addselect select
		mux_to_add <= (others => '0') when "000" | "111",
			       A_to_mux when "001" | "010",
			       A_to_mux(N-1 DOWNTO 0) & L when "011",
			       not(A_to_mux(N-1 DOWNTO 0) & L) + 1 when "100",
			       not(A_to_mux) + 1 when others;
						
	mux_to_B <= (others => '0') when loadreg = '1' else
					 adder_to_mux;
	
	-- Register A - Multiplicand
	regA : shiftReg generic map(N => N+1)
		port map (multiplicand, L, loadreg, 
		          L, clock, A_to_mux);
	
	-- Control block
	con : control 
		port map (ivalid, clock, count_to_ctrl, bitframe,
	             addselect, loadreg, addreg,
					 count, shift, sigBusy);
	
	-- Adder
	add : n_adder generic map(N => N+1)
		port map (mux_to_add, resultB, L,
		          adder_to_mux, carryOut);
					 
	-- Register B - addition result upper 8 bits results
	regB : shiftReg generic map(N => N+1)
		port map (mux_to_B, shiftinB, loadB, 
		          shift, clock, resultB);
	
	-- Register C - result lower 8 bits and multiplier
	regC : shiftReg generic map(N => N+1)
		port map (multiplier, shiftinC,
		          loadreg, shift, clock, resultC);
					 
	-- Register D - count
	regD : countReg
		port map (cycles, loadreg, count, clock, count_to_ctrl);
	
	-- get results
	process(sigBusy)
		variable temp : std_logic_vector((N*2)-1 DOWNTO 0);
	begin
		if(falling_edge(sigBusy)) then
			temp := resultB(N-1 DOWNTO 0) & resultC(N DOWNTO 1);
			dataout <= temp;
		end if;
	end process;
			
end structure;
	

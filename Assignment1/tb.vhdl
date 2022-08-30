library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TB is
end entity;

architecture TB_arch of TB is
   component ShiftAndSubtractDivider is
      port (
              reset, clk: in std_logic;
              start: in std_logic;
              numerator, denominator: in std_logic_vector(7 downto 0);
              done: out std_logic;
              quotient, remain: out std_logic_vector(7 downto 0)
           );
   end component;

  signal reset : std_logic := '1';
  signal clk : std_logic := '0';

  signal start: std_logic;
  signal numerator, denominator: std_logic_vector(7 downto 0);
  signal done: std_logic;
  signal quotient, remain: std_logic_vector(7 downto 0);
begin

	clk <= not clk after 5 ns;
	process
	begin
		start <= '0';
		wait until clk = '1';
		reset <= '0';

		for I in 1 to 255 loop
			numerator <= std_logic_vector(to_unsigned(I,8));
			for J in 1 to 255 loop
				denominator <= std_logic_vector(to_unsigned(J,8));
				start <= '1';
				wait until clk = '1';
				while true loop
				    wait until clk = '1';
				    -- start is asserted for only one cycle.
				    start <= '0';
				    if  (done = '1') then
					exit;
				    end if;
				end loop;
				assert (to_integer(unsigned(quotient)) = (I/J) and
				 to_integer(unsigned(remain)) = (I mod J)) report
					"Mismatch!" severity error;
			end loop;
		end loop;
		assert false report "Test completed." severity note;

		wait;
	end process;

	dut: ShiftAndSubtractDivider
		port map (reset => reset, clk => clk,
				start => start, numerator => numerator,
				denominator => denominator, 
				done => done, quotient => quotient, remain => remain);
end TB_arch;



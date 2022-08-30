library ieee;
use ieee.std_logic_1164.all;
package RtlFsmTypes is
    type StateSymbol is (rst, loop_state, done_state);
end package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.RtlFsmTypes.all;
entity ShiftAndSubtractDivider is
    port (
        reset, clk: in std_logic;
        start: in std_logic;
        numerator, denominator: in std_logic_vector(7 downto 0);
        done: out std_logic;
        quotient, remain: out std_logic_vector(7 downto 0)
     );
end entity;

architecture Obvious of ShiftAndSubtractDivider is
    signal Q: StateSymbol;
    signal tr: std_logic_vector(8 downto 0);
    signal tq: std_logic_vector(7 downto 0);
    signal counter: unsigned(3 downto 0);
begin
    process(clk, reset, start, Q, tr, tq, counter)
        variable nextQ : StateSymbol;
        variable done_var:   std_logic;
        variable next_tr: std_logic_vector(8 downto 0);
        variable next_tq: std_logic_vector(7 downto 0);
        variable next_counter: unsigned(3 downto 0);
        variable remain_var: std_logic_vector(7 downto 0);
        variable quotient_var: std_logic_vector(7 downto 0);
    begin
        nextQ := Q;
        next_tr := tr;
        next_tq := tq;
        next_counter := counter;
        done_var := '0';
        remain_var := (others => '0');
        quotient_var := (others => '0');

        case Q is 
            when rst =>
                if(start = '1') then
                    next_tr := (others => '0');
                    next_tq := numerator;
                    next_counter := (others => '0');
                    nextQ := loop_state;
                end if;
            
            when loop_state =>
                if(tr(7 downto 0) >= denominator) then
                    next_tr(8 downto 1) := std_logic_vector(unsigned(tr(7 downto 0)) - unsigned(denominator));
                    next_tq := (tq(6 downto 0) & '1');
                else
                    next_tr(8 downto 1) := tr(7 downto 0);
                    next_tq := (tq(6 downto 0) & '0');
                end if;
                next_tr(0) := tq(7);

                if(counter = 8) then
                    nextQ := done_state;
                 else 
                    next_counter := (counter + 1);
                 end if;

            when done_state =>
                done_var := '1';
                remain_var := tr(8 downto 1);
                quotient_var := tq(7 downto 0);
                if(start = '1') then
                    next_tr := (others => '0');
                    next_tq := numerator;
                    next_counter := (others => '0');
                    nextQ := loop_state;
                end if;
        end case;
        
        done <= done_var;
        quotient <= quotient_var;
        remain <= remain_var;

        if (clk'event and (clk = '1')) then
            if (reset = '1') then
               -- Note: reset state is imposed here.
                   Q <= rst;
            else
                   Q <= nextQ;
                   tr <= next_tr;
                   tq <= next_tq;
                   counter <= next_counter;
            end if;
        end if;
    end process;
  end Obvious;

-- Shift and add multiplier.
-- Uses a single 8-bit subtractor.
--
-- Does an 8-bit divide in
-- 1+8 clock cycles.
--
-- input start, numerator[7:0], denominator[7:0]
-- output done, remainder[7:0], quotient[7:0]
--
-- register tr[8:0]
-- register tq[7:0]
-- registers counter[3:0]
--
-- Default outs:
--
done=0, remainder, quotient= 0
rst:
if start then
tr[8:0] := 0
counter := 0
tq := numerator
goto loop
else
goto rst
endif
loop:
if(tr[7:0] >= denominator) then
-- 8-bit subtractor.
tr[8:1] := tr[7:0] - denominator;
-- shift left and concat 1.
tq := (tq[6:0] & '1');
else
-- shift left.
tr[8:1] := tr[7:0];
--shift left and concat 0.
tq := (tq[6:0] & '0');
endif
-- left shift the numerator into the remainder.
tr[0] := tq[7]
if (counter == 8) then
goto done_state
else
counter := (counter + 1)
goto loop
endif
done_state:
done = 1
-- tr is visible at remainder and tq is visible at quotient
remainder = tr[8:1]
quotient = tq[7:0]
if start then
tr[8:0] := 0
counter := 0
tq := numerator
goto loop
else
goto done_state
endif

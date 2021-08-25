library IEEE;
use IEEE.STD_LOGIC_1164.all;

--! @title Clock
--! This clock simply switches between '1' and '0' with the given time period.
--! Internally, it uses the transport delay feature of VHDL.
--! The default time period is set to 10 ns.
--! If enable != '1' then the output is set to high impedence.
--! Note: Even when enable != '1' the clock continues to tick.
--! { "signal" : [
--! { "name": "clk", "wave": "p....."},
--! { "name": "output", "wave": "p.z.0p"},
--! {"name": "enable", "wave": "0.1.0."}] }

entity clock is
  generic (
    --! Time period of the clock.
    time_period : time := 10 ns
  );
  port (
    --! If set to anything other than '1', then O/P is high impedence.
    signal enable : in std_logic;
    --! Either '1' or '0' depending on the clock signal.
    signal output : out std_logic
  );
end entity;

architecture arc of clock is
  --! This signal is used internally to generate the clock.
  signal internal_clock : std_logic := '0';
begin
  clock_tick : process (enable, internal_clock)
  begin
    -- Route to O/P.
    if enable = '1' then
      output <= internal_clock;
    else
      output <= 'Z';
    end if;
    -- Tick internal clock.
    internal_clock <= transport not internal_clock after time_period/2;
  end process;
end architecture;
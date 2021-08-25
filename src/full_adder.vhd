library IEEE;
use IEEE.STD_LOGIC_1164.all;

--! @title Full Adder
--! This is full adder combinational circuit.
--! If enable != '1' then the output is set to high impedence.
entity full_adder is
  port (
    --! Input bit A.
    A : in std_logic;
    --! Input bit B.
    B : in std_logic;
    --! Input bit Carry.
    C_in : in std_logic;
    --! Output bit Sum.
    S : out std_logic;
    --! Output bit Carry.
    C_out : out std_logic;
    --! If not = '1', output is high impedence and internal state is frozen.
    enable : in std_logic
  );
end entity;

architecture arc of full_adder is
  --! Common signal A xor B.
  signal I : std_logic;
begin
  I     <= A xor B;
  S     <= C_in xor I when enable = '1' else 'Z';
  C_out <= (C_in and I) or (A and B) when enable = '1' else 'Z';
end architecture;
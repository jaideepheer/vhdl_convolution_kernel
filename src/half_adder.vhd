library IEEE;
use IEEE.STD_LOGIC_1164.all;

--! @title Half Adder
--! This is half adder combinational circuit.
--! If enable != '1' then the output is set to high impedence.
entity half_adder is
  port (
    --! Input bit A.
    A : in std_logic;
    --! Input bit B.
    B : in std_logic;
    --! Output bit Sum.
    S : out std_logic;
    --! Output bit Carry.
    C_out : out std_logic;
    --! If not = '1', output is high impedence and internal state is frozen.
    enable : in std_logic
  );
end entity;

architecture arc of half_adder is
begin
  S     <= A and B when enable = '1' else 'Z';
  C_out <= A xor B when enable = '1' else 'Z';
end architecture;
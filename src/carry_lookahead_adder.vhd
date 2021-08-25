library IEEE;
use IEEE.STD_LOGIC_1164.all;

--! @title Carry Look-ahead Adder
--! A N-bit adder using carry look-ahead.
--! This is combinational circuit.
--! If enable != '1' then the output is set to high impedence.
entity carry_lookahead_adder is
  generic (
    --! The bit wifth of input integers.
    bit_width : integer := 4
  );
  port (
    --! Input integer A.
    A : in std_logic_vector(bit_width - 1 downto 0);
    --! Input integer B.
    B : in std_logic_vector(bit_width - 1 downto 0);
    --! Output Sum=A+B.
    S : out std_logic_vector(bit_width - 1 downto 0);
    --! Output Carry.
    C_out : out std_logic;
    --! If not = '1', output is high impedence.
    enable : in std_logic
  );
end carry_lookahead_adder;

architecture arc of carry_lookahead_adder is
  --! 1-bit Full Adder
  component full_adder is
    port (
      --! Input A.
      A : in std_logic;
      --! Input B.
      B : in std_logic;
      --! Input Carry.
      C_in : in std_logic;
      --! Output Sum.
      S : out std_logic;
      --! Output Carry.
      C_out : out std_logic;
      --! If not = '1', output is high impedence and internal state is frozen.
      enable : in std_logic
    );
  end component;

  --! Generate signals
  signal G : std_logic_vector(bit_width - 1 downto 0);
  --! Propagate signals
  signal P : std_logic_vector(bit_width - 1 downto 0);
  --! Carry buffer
  signal C : std_logic_vector(bit_width downto 0);

begin
  --! No carry for first FA
  C(0) <= '0';
  --! Create the Generate (Gi=Ai*Bi), Propagate (Pi=Ai+Bi) and Carry terms
  GENERATE_GPC : for j in 0 to bit_width - 1 generate
    G(j)     <= A(j) and B(j);
    P(j)     <= A(j) or B(j);
    C(j + 1) <= G(j) or (P(j) and C(j));
  end generate GENERATE_GPC;

  --! Create the Full Adders and connect them to GPC
  GENERATE_FULL_ADDERS : for i in 0 to bit_width - 1 generate
    FULL_ADDER_INST : full_adder
    port map(
      A      => A(i),
      B      => B(i),
      C_in   => C(i),
      S      => S(i),
      C_out  => open,
      enable => enable
    );
  end generate GENERATE_FULL_ADDERS;

  --! Output results
  C_out <= C(bit_width) when enable = '1' else 'Z';

end architecture;
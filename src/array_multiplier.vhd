library IEEE;
use IEEE.STD_LOGIC_1164.all;

--! @title Array Multiplier
--! A N-bit multiplier using add-shift.
--! **Note:** The output has double the bit width of the input.
--! This is combinational circuit.
--! If enable != '1' then the output is set to high impedence.
--! Reference: https://faculty.weber.edu/fonbrown/ee3610/arraymult.txt
entity array_multiplier is
  generic (
    --! The bit wifth of input integers.
    bit_width : integer := 8
  );
  port (
    --! Input integer A.
    A : in std_logic_vector(bit_width - 1 downto 0);
    --! Input integer B.
    B : in std_logic_vector(bit_width - 1 downto 0);
    --! Output result A*B.
    P : out std_logic_vector(2 * bit_width - 1 downto 0);
    --! If not = '1', output is high impedence.
    enable : in std_logic
  );
end entity;

architecture arc of array_multiplier is
  -- 1-bit Full Adder
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

  --! Type for 2D array of std_logic.
  type Array_T is array (natural range <>, natural range <>) of std_logic;
  --! Used to store bit multiplications A(i) and B(i).
  signal M : Array_T(bit_width downto 0, bit_width - 1 downto 0);
  --! Used to store intermediate sums.
  signal S : Array_T(bit_width - 1 downto 0, bit_width - 1 downto 0);
  --! Used to store intermediate carry.
  signal C : Array_T(bit_width - 1 downto 0, bit_width - 2 downto 0);

begin

  --! Array of N * (N-1) full adders:
  gen_i : for i in 0 to bit_width - 1 generate -- along rows
    gen_j : for j in 0 to bit_width - 1 generate -- along columns
      M(i, j) <= A(i) and B(j);
      fen_FA : if i /= bit_width - 1 and j /= bit_width - 1 generate
        fij : full_adder port map(
          C_in   => C(i, j),
          A      => S(i, j + 1),
          B      => M(i + 1, j),
          S      => S(i + 1, j),
          C_out  => C(i + 1, j),
          enable => '1'
        );
      end generate;
      fb : if i = 0 generate
        S(i, j) <= M(i, j);
      end generate;
    end generate;
  end generate;

  M(bit_width, 0) <= '0';
  gen_lj : for j in 0 to bit_width - 2 generate
    C(0, j)                 <= '0';
    S(j + 1, bit_width - 1) <= M(j + 1, bit_width - 1); -- Column 3 (from rows 1 to N-1)
    P(j + 1)                <= S(j + 1, 0);
    flj : full_adder port map(
      C_in   => C(bit_width - 1, j),
      A      => S(bit_width - 1, j + 1),
      B      => M(bit_width, j),
      S      => P(bit_width + j),
      C_out  => M(bit_width, j + 1),
      enable => '1'
    );
  end generate;

  P(0)         <= M(0, 0);
  P(2 * bit_width - 1) <= M(bit_width, bit_width - 1);

end architecture;
library IEEE;
use work.types.all;
use IEEE.STD_LOGIC_1164.all;

--! @title Vector Dot Product Unit 
--! A N-bit 2^T length vector multiplier (dot product) using array multipliers and carry lookahead adders.
--! It requires 2^T as it uses logrithmic parallel addition by dividing the addition into T stages of carry look-ahead adders.
--! **Note:** The output has double the bit width of the input.
--! This ignores (discards carry) any integer overflows during accumulation of the dot product.
--! **NOTE:** To compile this file please set modelsim to use VHDL 2008 for all files. See: https://forums.xilinx.com/t5/Synthesis/Array-of-Unconstrained-Array/td-p/681253
--! This is combinational circuit.
--! If enable != '1' then the output is set to high impedence.
entity vector_multiplier is
  generic (
    --! Bit width for input integers.
    bit_width : integer := 8;
    --! The length 2^T of input vectors.
    vector_size_pow_of_2 : integer := 2
  );
  port (
    --! Input vector A.
    A : in vector_T(2 ** vector_size_pow_of_2 - 1 downto 0)(bit_width - 1 downto 0);
    --! Input vector B.
    B : in vector_T(2 ** vector_size_pow_of_2 - 1 downto 0)(bit_width - 1 downto 0);
    --! Output number A.B (dot product). Has integrs with 2*bit_width bits.
    D : out std_logic_vector(2 * bit_width - 1 downto 0);
    --! If not = '1', output is high impedence and internal state is frozen.
    enable : in std_logic
  );
end entity;

architecture arc of vector_multiplier is
  -- N-bit Adder
  component carry_lookahead_adder is
    generic (
      bit_width : integer
    );
    port (
      --! Input A.
      A : in std_logic_vector(bit_width - 1 downto 0);
      --! Input A.
      B : in std_logic_vector(bit_width - 1 downto 0);
      --! Output Sum.
      S : out std_logic_vector(bit_width - 1 downto 0);
      --! Output Carry.
      C_out : out std_logic;
      --! If not = '1', output is high impedence and internal state is frozen.
      enable : in std_logic
    );
  end component;

  component array_multiplier is
    generic (
      bit_width : integer
    );
    port (
      --! Input A.
      A : in std_logic_vector(bit_width - 1 downto 0);
      --! Input B.
      B : in std_logic_vector(bit_width - 1 downto 0);
      --! Output result.
      P : out std_logic_vector(2 * bit_width - 1 downto 0);
      --! If not = '1', output is high impedence and internal state is frozen.
      enable : in std_logic
    );
  end component;
  --! Type for 2D array of std_logic.
  type Array_T is array (natural range <>, natural range <>) of std_logic_vector;
  --! Stores addition stages
  signal AddBuffer : Array_T(vector_size_pow_of_2 downto 0, 2 ** vector_size_pow_of_2 - 1 downto 0)(2 * bit_width - 1 downto 0);
begin

  --! Array of 2^vector_size_pow_of_2 multipliers to multiply vector elements
  GenMultipliers : for i in 0 to 2 ** vector_size_pow_of_2 - 1 generate -- along rows
    AM : array_multiplier
    generic map(
      bit_width => bit_width
    )
    port map(
      A      => A(i),
      B      => B(i),
      P      => AddBuffer(vector_size_pow_of_2, i),
      enable => '1'
    );
  end generate;

  --! vector_size_pow_of_2 stages of adders to add for final result
  GenAdders : for i in 0 to vector_size_pow_of_2 - 1 generate
    GenAdderStage : for j in 0 to 2 ** i - 1 generate
      CLA : carry_lookahead_adder
      generic map(
        bit_width => 2 * bit_width
      )
      port map(
        A      => AddBuffer(i + 1, 2 * j),
        B      => AddBuffer(i + 1, 2 * j + 1),
        S      => AddBuffer(i, j),
        C_out  => open,
        enable => '1'
      );
    end generate;
  end generate;

  --! Output
  D <= AddBuffer(0, 0) when enable = '1' else (others => 'Z');

end architecture;
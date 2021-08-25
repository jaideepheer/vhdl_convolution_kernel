library IEEE;
use work.types.all;
use IEEE.STD_LOGIC_1164.all;

--! @title Convolution Kernel
--! A N-bit K x K convolution kernel processor for a M x M input matrix.
--! Uses a stride of 1 since with 1-stride output any other stride output can be extracted.
--! Uses array multipliers and carry lookahead adders via Vector Dot Product Units.
--! **Note:** The output has double the bit width of the input.
--! **NOTE:** To compile this file please set modelsim to use VHDL 2008 for all files. See: https://forums.xilinx.com/t5/Synthesis/Array-of-Unconstrained-Array/td-p/681253
--! This is combinational circuit.
--! If enable != '1' then the output is set to high impedence.
entity convolution_kernel is
  generic (
    --! Bit width for every integer.
    bit_width : integer := 4;
    --! The matrix dimension M x M.
    input_matrix_size : integer := 7; -- MxM
    --! The kernel dimension 2^K x 2^K. This is powered by 2 to use logrithmic addition in Vector Dot Product Unit. 
    kernel_size_pow_of_2 : integer := 2 -- 2^K x 2^K
  );
  port (
    --! Input Kernel to use. Must be of dimension 2^K x 2^K.
    Kernel : in matrix_T(2 ** kernel_size_pow_of_2 - 1 downto 0)(2 ** kernel_size_pow_of_2 - 1 downto 0)(bit_width - 1 downto 0);
    --! Input matrix to apply kernel on. Must have dimension of M x M.
    Matrix : in matrix_T(input_matrix_size - 1 downto 0)(input_matrix_size - 1 downto 0)(bit_width - 1 downto 0);
    --! Output result A.B (dot product). Dimension is square matrix of size M - 2^K + 1. Output also has 2*bit_width for all integers.
    D : out matrix_T(input_matrix_size - 2 ** kernel_size_pow_of_2 downto 0)(input_matrix_size - 2 ** kernel_size_pow_of_2 downto 0)(2 * bit_width - 1 downto 0);
    --! If not = '1', output is high impedence.
    enable : in std_logic
  );
end entity;

architecture arc of convolution_kernel is
  -- Vector dot product
  component vector_multiplier is
    generic (
      bit_width            : integer;
      vector_size_pow_of_2 : integer
    );
    port (
      --! Input A.
      A : in vector_T(2 ** vector_size_pow_of_2 - 1 downto 0)(bit_width - 1 downto 0);
      --! Input B.
      B : in vector_T(2 ** vector_size_pow_of_2 - 1 downto 0)(bit_width - 1 downto 0);
      --! Output result A.B (dot product).
      D : out std_logic_vector(2 * bit_width - 1 downto 0);
      --! If not = '1', output is high impedence and internal state is frozen.
      enable : in std_logic
    );
  end component;

  --! Stores flattned kernel
  signal FlatKernel : vector_T(2 ** (2 * kernel_size_pow_of_2) - 1 downto 0)(bit_width - 1 downto 0);
  --! Stores flattned matrix peices
  signal FlatMatrixPieces : matrix_T((input_matrix_size - 2 ** kernel_size_pow_of_2 + 1) ** 2 - 1 downto 0)(2 ** (2 * kernel_size_pow_of_2) - 1 downto 0)(bit_width - 1 downto 0);
begin

  --! Flatten kernel
  FlattenKernel : process (Kernel)
    variable n : integer;
  begin
    n := 0;
    for i in 0 to 2 ** kernel_size_pow_of_2 - 1 loop
      for j in 0 to 2 ** kernel_size_pow_of_2 - 1 loop
        FlatKernel(n) <= Kernel(i)(j);
        n := n + 1;
      end loop;
    end loop;
  end process;

  --! Generate Vector dot product units
  VectorProduct : for i in 0 to input_matrix_size - 2 ** kernel_size_pow_of_2 generate
    gen : for j in 0 to input_matrix_size - 2 ** kernel_size_pow_of_2 generate
      --! Flatten matrix piece
      FlatMatrixP : process (all)
        variable n : integer;
      begin
        n := 0;
        for v_i in 0 to 2 ** kernel_size_pow_of_2 - 1 loop
          for v_j in 0 to 2 ** kernel_size_pow_of_2 - 1 loop
            FlatMatrixPieces(i * (input_matrix_size - 2 ** kernel_size_pow_of_2 + 1) + j)(n) <= Matrix(i + v_i)(j + v_j);
            n := n + 1;
          end loop;
        end loop;
      end process;
      --! Bind vector dot product units
      VectorProductInst : vector_multiplier
      generic map(
        bit_width            => bit_width,
        vector_size_pow_of_2 => 2 * kernel_size_pow_of_2
      )
      port map(
        enable => enable,
        A      => FlatKernel,
        B      => FlatMatrixPieces(i * (input_matrix_size - 2 ** kernel_size_pow_of_2 + 1) + j),
        D      => D(i)(j)
      );
    end generate;
  end generate;

end architecture;
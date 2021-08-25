library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use work.types.all;

entity convolution_kernel_tb is
end entity;

--! **NOTE:** To compile this file please set your file to use VHDL 2008. See: https://forums.xilinx.com/t5/Synthesis/Array-of-Unconstrained-Array/td-p/681253
architecture test of convolution_kernel_tb is
  signal tb_clk, tb_enable, tb_reset : std_logic;
  signal tb_image                    : matrix_T(6 downto 0)(6 downto 0)(3 downto 0);
  signal tb_kernel                   : matrix_T(3 downto 0)(3 downto 0)(3 downto 0);
  signal tb_output                   : matrix_T(3 downto 0)(3 downto 0)(7 downto 0);

  -- Using buffer
  component convolution_kernel is
    generic (
      bit_width            : integer;
      input_matrix_size    : integer; -- MxM
      kernel_size_pow_of_2 : integer -- 2^K x 2^K
    );
    port (
      --! Input Kernel to use. Must be of dimension 2^K x 2^K.
      Kernel : in matrix_T(2 ** kernel_size_pow_of_2 - 1 downto 0)(2 ** kernel_size_pow_of_2 - 1 downto 0)(bit_width - 1 downto 0);
      --! Input matrix to apply kernel on.
      Matrix : in matrix_T(input_matrix_size - 1 downto 0)(input_matrix_size - 1 downto 0)(bit_width - 1 downto 0);
      --! Output result A.B (dot product).
      D : out matrix_T(input_matrix_size - 2 ** kernel_size_pow_of_2 downto 0)(input_matrix_size - 2 ** kernel_size_pow_of_2 downto 0)(2 * bit_width - 1 downto 0);
      --! If not = '1', output is high impedence and internal state is frozen.
      enable : in std_logic
    );
  end component;
  -- Using clock
  component clock is
    port (
      enable : in std_logic;
      output : inout std_logic
    );
  end component;
begin
  -- Instantiate buffer
  inst : convolution_kernel
  generic map(
    bit_width            => 4,
    input_matrix_size    => 7,
    kernel_size_pow_of_2 => 2
  )
  port map(
    enable => tb_enable,
    Kernel => tb_kernel,
    Matrix => tb_image,
    D      => tb_output
  );
  --   Instantiate clock
  clock_inst : clock
  port map(
    enable => '1',
    output => tb_clk
  );
  -- Testing process
  process
  begin
    -- Only run tests when testbench is enabled.
    if tb_enable = 'U' then
      -- Enable everything
      tb_enable <= '1';
    end if;
    if tb_enable = '1' then
      -- Test features
      -- Reset everything
      tb_reset <= '1';
      wait until falling_edge(tb_clk);
      tb_reset <= '0';
      -- Wait for 2 clock cycles
      tb_kernel <= (
        0 => (0 => "0010", 1 => "0000", 2 => "0000", 3 => "0000"),
        1 => (0 => "0000", 1 => "0010", 2 => "0000", 3 => "0000"),
        2 => (0 => "0000", 1 => "0000", 2 => "0010", 3 => "0000"),
        3 => (0 => "0000", 1 => "0000", 2 => "0000", 3 => "0010")
        );
      tb_image <= (
        0 => (0 => "0010", 1 => "0000", 2 => "0010", 3 => "0100", 4 => "0000", 5 => "0000", 6 => "0000"),
        1 => (0 => "0010", 1 => "0001", 2 => "0010", 3 => "0100", 4 => "0000", 5 => "0000", 6 => "0100"),
        2 => (0 => "0000", 1 => "0101", 2 => "1000", 3 => "0000", 4 => "0000", 5 => "0100", 6 => "0001"),
        3 => (0 => "0010", 1 => "0001", 2 => "0100", 3 => "0000", 4 => "0010", 5 => "0000", 6 => "0000"),
        4 => (0 => "0000", 1 => "0011", 2 => "0010", 3 => "0000", 4 => "0000", 5 => "0000", 6 => "0000"),
        5 => (0 => "0010", 1 => "0000", 2 => "0000", 3 => "0100", 4 => "1000", 5 => "0010", 6 => "0001"),
        6 => (0 => "0010", 1 => "0000", 2 => "0100", 3 => "0000", 4 => "0000", 5 => "0000", 6 => "0000")
        );
      for i in 1 to 2 loop
        wait until rising_edge(tb_clk);
      end loop;
      -- Wait for 2 clock cycles
      tb_kernel <= (others => (others => "1111"));
      tb_image  <= (others => (others => "0000"));
      for i in 1 to 2 loop
        wait until rising_edge(tb_clk);
      end loop;
      tb_kernel <= (others => (others => "0000"));
      tb_image  <= (others => (others => "0000"));
      -- Disable circuit
      tb_enable <= '0';
      -- Wait for 2 clock cycles
      for i in 1 to 2 loop
        wait until rising_edge(tb_clk);
      end loop;
      -- Enable circuit
      tb_enable <= '1';
      -- Wait for 2 clock cycles
      for i in 1 to 2 loop
        wait until rising_edge(tb_clk);
      end loop;
      -- Testing done, disable everything
      tb_enable <= 'Z';
      wait until rising_edge(tb_clk);
    else
      wait on tb_enable;
    end if;
  end process;
end architecture;
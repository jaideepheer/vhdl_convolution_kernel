library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use work.types.all;

entity vector_multiplier_tb is
end entity;

--! **NOTE:** To compile this file please set your file to use VHDL 2008. See: https://forums.xilinx.com/t5/Synthesis/Array-of-Unconstrained-Array/td-p/681253
architecture test of vector_multiplier_tb is
  signal tb_clk, tb_enable, tb_reset, tb_input : std_logic;
  signal tb_output                             : std_logic_vector(7 downto 0);
  signal tb_A, tb_B                            : vector_T(3 downto 0)(3 downto 0);
  -- Using buffer
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
  -- Using clock
  component clock is
    port (
      enable : in std_logic;
      output : inout std_logic
    );
  end component;
begin
  -- Instantiate buffer
  inst : vector_multiplier
  generic map(
    bit_width            => 4,
    vector_size_pow_of_2 => 2
  )
  port map(
    enable => tb_enable,
    A      => tb_A,
    B      => tb_B,
    D      => tb_output
  );
  -- Instantiate clock
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
      tb_A <= (0 => "0010", 1 => "0001", 2 => "0010", 3 => "0000");
      tb_B <= (0 => "0010", 1 => "0001", 2 => "0010", 3 => "0000");
      for i in 1 to 2 loop
        wait until rising_edge(tb_clk);
      end loop;
      -- Wait for 2 clock cycles
      tb_A <= (0 => "0110", 1 => "1001", 2 => "0010", 3 => "0100");
      tb_B <= (0 => "0001", 1 => "0001", 2 => "1010", 3 => "0010");
      for i in 1 to 2 loop
        wait until rising_edge(tb_clk);
      end loop;
      -- Wait for 2 clock cycles
      tb_A <= (others => "1111");
      tb_B <= (others => "1111");
      for i in 1 to 2 loop
        wait until rising_edge(tb_clk);
      end loop;
      tb_A <= (others => "0000");
      tb_B <= (others => "0000");
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
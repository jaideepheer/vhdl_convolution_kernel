library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity array_multiplier_tb is
end entity;

architecture test of array_multiplier_tb is
  signal tb_clk, tb_enable, tb_reset, tb_input : std_logic;
  signal tb_output                             : std_logic_vector(5 downto 0);
  signal tb_A, tb_B                            : std_logic_vector(2 downto 0);
  -- Using buffer
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
  -- Using clock
  component clock is
    port (
      enable : in std_logic;
      output : inout std_logic
    );
  end component;
begin
  -- Instantiate buffer
  inst : array_multiplier
  generic map(
    bit_width => 3
  )
  port map(
    enable => tb_enable,
    A  => tb_A,
    B  => tb_B,
    P => tb_output
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
      tb_A <= "011";
      tb_B <= "011";
      for i in 1 to 2 loop
        wait until rising_edge(tb_clk);
      end loop;
      tb_A <= "000";
      tb_B <= "000";
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
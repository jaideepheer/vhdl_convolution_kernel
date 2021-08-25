library IEEE;
use IEEE.STD_LOGIC_1164.all;

package types is
  type vector_T is array(natural range <>) of std_logic_vector;
  type matrix_T is array(natural range <>) of vector_T;
end package types;
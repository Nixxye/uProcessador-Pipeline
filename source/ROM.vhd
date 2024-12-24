library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ROM is
    port (
        clk : in std_logic;
        address : in unsigned(15 downto 0);
        data : out unsigned(18 downto 0) -- Instruções de 19 bits
    );
end entity;

architecture a_ROM of ROM is
    type mem is array (0 to 127) of unsigned(18 downto 0);
    constant romContent : mem := (
        0 => B"0011_001_010_000000000",   -- ld r2, 0
        1 => B"0011_001_011_000000000",   -- ld r3, 0
        2 => B"0010_000_011_010_000000",  -- add r3, r2 
        3 => B"0011_000_010_000000001",   -- addi r2, 1
        4 => B"0011_001_100_000011110",   -- ld r4, 30
        5 => B"0100_000_010_100_111110",  -- ble r2, r4, -2
        6 => B"0010_010_100_011_000000",  -- mov r4, r3
        others => (others => '0')
    );
begin
    process(clk)
    begin
        if rising_edge(clk) then
            data <= romContent(to_integer(unsigned(address)));
        end if;
    end process;
end architecture;
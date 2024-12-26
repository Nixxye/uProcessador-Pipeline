library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ROM is
    port (
        clk, rst : in std_logic;
        address : in unsigned(15 downto 0);
        data : out unsigned(18 downto 0) -- Instruções de 19 bits
    );
end entity;

architecture a_ROM of ROM is
    type mem is array (0 to 127) of unsigned(18 downto 0);
    constant romContent : mem := (
        0 => B"000000101_010_001_0011",   -- ld r2, 5
        1 => B"000001000_011_001_0011",   -- ld r3, 8
        2 => B"000000_010_100_010_0010",  -- mov r4, r2
        3 => B"000000_011_100_000_0010",  -- add r4, r3
        4 => B"000000001_001_001_0011",   -- ld r1, 1
        5 => B"000000_001_100_001_0010",  -- sub r4, r1
        6 => B"000000010100_000_0001",    -- jump 20
        7 => B"000001111_001_001_0011",   -- ld r1, 15
        20 => B"000000_100_010_010_0010", -- mov r2, r4
        21 => B"000000000011_000_0001",   -- jump 3
        22 => B"000000000_011_001_0011",  -- ld r3, 0
        others => (others => '0')
    );
begin
    process(clk)
    begin
        if rst = '1' then
            data <= (others => '0');
        elsif rising_edge(clk) then
            data <= romContent(to_integer(unsigned(address)));
        end if;
    end process;
end architecture;
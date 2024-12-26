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
        1 => B"000000111_001_001_0011",   -- ld r1, 7
        2 => B"000000001_011_001_0011",   -- ld r3, 1
        3 => B"000000010_100_001_0011",   -- ld r4, 2
        4 => B"000000_010_001_010_0010",  -- mov r1, r2
        5 => B"0000000000000000000",      -- nop
        6 => B"0000000000000000000",      -- nop
        7 => B"0000000000000000000",      -- nop
        8 => B"000000_011_010_001_0010",  -- sub r2, r3
        9 => B"000000010_001_000_0011",   -- addi r1, 2
        10 => B"000000000000_000_0001",    -- jmp 0
        11 => B"000001111_010_001_0011",   -- ld r2, 15
        12 => B"000000_011_010_001_0010",  -- sub r2, r3
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
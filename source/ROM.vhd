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
        0 => B"000000010_001_001_0011",   -- ld r1, 2
        1 => B"000100000_010_001_0011",   -- ld r2, 32
        -- nop só para n ter q mudar os branches
        3 => B"000000_001_001_101_0010",  -- sw r1, r1
        4 => B"000000001_001_000_0011",   -- inc r1
        5 => B"000000_010_001_011_0010",  -- cmp r1, r2
        6 => B"111111111100_000_0100",    -- ble -4

        7 => B"000000_000_001_010_0010",  -- mov r1, r0 (8400 ns)

        -- 8 => B"000000010_001_001_0011",   -- ld r1, 2
        -- 9 => B"000100000_010_001_0011",   -- ld r2, 32
        -- -- nop só para n ter q mudar os branches
        -- 10 => B"000000_001_011_100_0010",  -- lw r3, r1
        -- 11 => B"000000001_001_000_0011",   -- inc r1
        -- 12 => B"000000_010_001_011_0010",  -- cmp r1, r2
        -- 13 => B"111111111100_000_0100",    -- ble -4


        8 => B"000000010_010_001_0011",   -- ld r2, 2
        9 => B"000000_010_011_100_0010",  -- lw r3, r2
        10 => B"000000_000_011_011_0010", -- cmp r3, r0
        11 => B"000000001000_000_0100",   -- ble 8

        12 => B"000000_010_100_010_0010", -- mov r4, r2
        13 => B"000000_010_100_000_0010", -- add r4, r2
        14 => B"000100000_011_001_0011",   -- ld r3, 32
        16 => B"000000_100_011_011_0010", -- cmp r3, r4
        17 => B"000000000010_001_0100",   -- blt 2

        18 => B"000000_100_000_101_0010", -- sw r0, r4
        19 => B"000000001101_000_0001",   -- jmp 13
        20 => B"000000001_010_000_0011",  -- inc r2
        21 => B"000000110_010_010_0011",  -- cmpi r2, 6
        22 => B"111111110010_000_0100",   -- ble -14

        23 => B"111111111_001_001_0011",  -- ld r1, FFFF (28100 ns)
        24 => B"000000_000_001_010_0010", -- mov r1, r0
        25 => B"000000_000_010_010_0010", -- mov r2, r0
        26 => B"000000_000_011_010_0010", -- mov r3, r0
        27 => B"000000_000_100_010_0010", -- mov r4, r0
        28 => B"000000010_001_001_0011",  -- ld r1, 2
        29 => B"000100000_010_001_0011",   -- ld r2, 32

        31 => B"000000_001_011_100_0010", -- lw r3, r1
        32 => B"000000_000_011_011_0010", -- cmp r3, r0
        33 => B"000000000001_000_0100",   -- ble 1

        34 => B"000000_011_100_010_0010", -- mov r4, r3
        35 => B"000000001_001_000_0011",  -- inc r1
        36 => B"000000_010_001_011_0010", -- cmp r1, r2
        37 => B"111111111001_000_0100",  -- ble -7
        others => (others => '0')
    );
begin
    process(clk)
    begin
        if rst = '1' then
            data <= (others => '0');
        elsif address > 127 then -- apenas para testes:
            data <= (others => '0');
        elsif rising_edge(clk) then
            data <= romContent(to_integer(unsigned(address)));
        end if;
    end process;
end architecture;
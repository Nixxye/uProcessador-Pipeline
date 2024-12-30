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
        0 => B"000000000_010_001_0011",   -- ld r2, 0
        1 => B"000000000_011_001_0011",   -- ld r3, 0
        2 => B"000000_010_011_000_0010",  -- add r3, r2 
        3 => B"000000001_010_000_0011",   -- addi r2, 1
        4 => B"000000001_001_000_0011",   -- addi r1, 1
        --5 => B"000000001_100_000_0011",   -- addi r4, 1
        6 => B"000011101_010_010_0011",   -- cmpi r2, 29
        7 => B"111111111010_000_0100",    -- ble -6
        8 => B"000000_011_100_010_0010",  -- mov r4, r3
        others => (others => '0')
    );
begin
    process(clk)
    begin
        if rst = '1' then
            data <= (others => '0');
        -- elsif address > 127 then -- APENAS PARA TESTES -> RETIRAR NA APRESENTAÇÃO
        --     data <= (others => '0');
        elsif rising_edge(clk) then
            data <= romContent(to_integer(unsigned(address)));
        end if;
    end process;
end architecture;
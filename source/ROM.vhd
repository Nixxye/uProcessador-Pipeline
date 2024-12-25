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
        2 => B"000000_011_001_010_0010",  -- mov r3, r1
        3 => B"000000_010_001_000_0010",  -- add r2, r1
        4 => B"000000010_001_000_0011",   -- addi r1, 2
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
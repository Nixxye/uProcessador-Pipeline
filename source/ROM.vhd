library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ROM is
    port (
        clk, rst : in std_logic;
        address : in unsigned(6 downto 0);
        data : out unsigned(18 downto 0) -- Instruções de 19 bits
    );
end entity;

architecture a_ROM of ROM is
    type mem is array (0 to 127) of unsigned(18 downto 0);
    constant romContent : mem := (
        -- Crivo de Eratóstenes até 1843:
        -- INICIALIZA NA MEMÓRIA 2 ATÉ 1843
        0 => B"000000010_001_001_0011",   -- ld r1, 2          inicialização
        1 => B"000000111_010_011_0011",   -- lui r2, 3
        2 => B"000110011_010_000_0011",   -- addi r2, 307
        3 => B"000000_001_001_101_0010",  -- sw r1, r1         armazena o índice na RAM
        4 => B"000000000_001_000_0101",   -- inc r1
        5 => B"000000_010_001_011_0010",  -- cmp r1, r2        enquanto r1 <= 1843
        6 => B"111111111101_000_0100",    -- ble -3
        -- ENCONTRAR O PRÓXIMO PRIMO
        7 => B"000000_000_001_010_0010",  -- mov r1, r0 
        8 => B"000000010_010_001_0011",   -- ld r2, 2          inicialização
        9 => B"000000_010_011_100_0010",  -- lw r3, r2         carrega o possível primo da RAM
        10 => B"000000_000_011_011_0010", -- cmp r3, r0        verifica se r3 é zero (já marcado como não primo)
        11 => B"000000001000_000_0100",   -- ble 8
        -- REMOVER TODOS OS MÚLTIPLOS DELE
        12 => B"000000_010_100_010_0010", -- mov r4, r2        inicialização
        13 => B"000000111_011_011_0011",  -- lui r3, 3
        14 => B"000110011_011_000_0011",  -- addi r3, 307
        15 => B"000000_010_100_000_0010", -- add r4, r2        vai para o próximo múltiplo de r2
        16 => B"000000_100_011_011_0010", -- cmp r3, r4        enquanto r3 < 1843
        17 => B"000000000011_001_0100",   -- blt 3
        
        18 => B"000000_100_000_101_0010", -- sw r0, r4         marca r4 como não primo
        19 => B"000000001111_000_0001",   -- jmp 15
        20 => B"000000000_010_000_0101",  -- inc r2            vai para o próximo número
        21 => B"000101010_010_010_0011",  -- cmpi r2, 42       verifica todos os números até 42 (raiz de 1843)
        22 => B"111111110011_000_0100",   -- ble -13
        -- MARCA O FIM DO CRIVO
        23 => B"111111111_001_001_0011",  -- ld r1, FFFF
        24 => B"000000_000_001_010_0010", -- mov r1, r0
        25 => B"000000_000_010_010_0010", -- mov r2, r0
        26 => B"000000_000_011_010_0010", -- mov r3, r0
        27 => B"000000_000_100_010_0010", -- mov r4, r0
        -- ITERA PELOS PRIMOS MOSTRANDO ELES EM R4
        28 => B"000000010_001_001_0011",  -- ld r1, 2
        29 => B"000000111_010_011_0011",  -- lui r2, 3
        30 => B"000110011_010_000_0011",  -- addi r2, 307
        
        31 => B"000000_001_011_100_0010", -- lw r3, r1
        32 => B"000000_000_011_011_0010", -- cmp r3, r0        se o valor é diferente de zero, é primo e coloca ele em r4
        33 => B"000000000010_000_0100",   -- ble 2
        
        34 => B"000000_011_100_010_0010", -- mov r4, r3
        35 => B"000000000_001_000_0101",  -- inc r1
        36 => B"000000_010_001_011_0010", -- cmp r1, r2
        37 => B"111111111010_000_0100",  -- ble -6
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
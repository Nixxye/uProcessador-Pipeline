library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- 5 REGISTRADORES NO BANCO
entity registerFile is 
    port(
        clk, rst, wrEn : in std_logic;
        wrAddress, r0Address, r1Address : in unsigned(2 downto 0);
        wrData: in unsigned(15 downto 0);
        r0Data, r1Data : out unsigned(15 downto 0)
    );
end entity;

architecture a_registerFile of registerFile is
    component reg16 is
        port(
            clk, rst, wrEn : in std_logic;
            dataIn : in unsigned(15 downto 0);
            dataOut : out unsigned(15 downto 0)
        );
    end component;
    signal rs0, rs1, rs2, rs3, rs4 : unsigned(15 downto 0);
    signal wrEn1, wrEn2, wrEn3, wrEn4 : std_logic;
begin
    -- Resetar no início ou colocar um valor default apenas para o r0?
    r0 : reg16 port map(
        clk => clk, 
        rst => rst, 
        wrEn => '0', 
        dataIn => wrData,
        dataOut => rs0
    );
    r1 : reg16 port map(
        clk => clk, 
        rst => rst, 
        wrEn => wrEn1, 
        dataIn => wrData,
        dataOut => rs1
    );
    r2 : reg16 port map(
        clk => clk, 
        rst => rst, 
        wrEn => wrEn2, 
        dataIn => wrData,
        dataOut => rs2
    );
    r3 : reg16 port map(
        clk => clk, 
        rst => rst, 
        wrEn => wrEn3, 
        dataIn => wrData,
        dataOut => rs3
    );
    r4 : reg16 port map(
        clk => clk, 
        rst => rst, 
        wrEn => wrEn4, 
        dataIn => wrData,
        dataOut => rs4
    );
    r0Data <= rs0 when r0Address = "000" else
            rs1 when r0Address = "001" else
            rs2 when r0Address = "010" else
            rs3 when r0Address = "011" else
            rs4 when r0Address = "100" else
            (others => '0');

    r1Data <= rs0 when r1Address = "000" else
            rs1 when r1Address = "001" else
            rs2 when r1Address = "010" else
            rs3 when r1Address = "011" else
            rs4 when r1Address = "100" else
            (others => '0');

    wrEn1 <= wrEn when wrAddress = "001" else '0';
    wrEn2 <= wrEn when wrAddress = "010" else '0';
    wrEn3 <= wrEn when wrAddress = "011" else '0';
    wrEn4 <= wrEn when wrAddress = "100" else '0';
end architecture;
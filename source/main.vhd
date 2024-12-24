library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity main is 
    port(
        clk, rst : in std_logic
    );
end entity;

architecture a_main of main is
    component ULA is
        port (
            dataInA, dataInB : in unsigned(15 downto 0);
            opSelect : in unsigned(3 downto 0);
            dataOut : out unsigned(15 downto 0);
            z, n, v : out std_logic
        );
    end component;

    component registerFile is 
        port(
            clk, rst, wrEn : in std_logic;
            wrAddress, r0Address, r1Address : in unsigned(2 downto 0);
            wrData: in unsigned(15 downto 0);
            r0Data, r1Data : out unsigned(15 downto 0)
        );
    end component;

    component reg16 is
        port(
            clk, rst, wrEn : in std_logic;
            dataIn : in unsigned(15 downto 0);
            dataOut : out unsigned(15 downto 0)
        );
    end component;

    component reg19 is
        port(
            clk, rst, wrEn : in std_logic;
            dataIn : in unsigned(18 downto 0);
            dataOut : out unsigned(18 downto 0)
        );
    end component;

    component reg71 is
        port(
            clk, rst, wrEn : in std_logic;
            dataIn : in unsigned(70 downto 0);
            dataOut : out unsigned(70 downto 0)
        );
    end component;

    component ROM is
    port (
        clk : in std_logic;
        address : in unsigned(15 downto 0);
        data : out unsigned(18 downto 0) -- Instruções de 19 bits
    );
    end component;

    component controlUnit is
        port (
            clk, rst, z, n, v : in std_logic;
            instruction : in unsigned(6 downto 0); -- OPCODE (4 bits) + FUNCTION (3 bits)
            pcWrtEn, pcWrtCnd, ulaSrcA, pcSource, opException, zeroReg, memtoReg, regWrt, irWrt: out std_logic;
            ulaOp : out unsigned(3 downto 0); 
            ulaSrcB : out unsigned(2 downto 0);
            lorD : out unsigned(1 downto 0)
        );
    end component;
    signal imm, ulaA, ulaB, r0, r1, r0Ula, r1Ula, wrtData, ulaOut, ulaResult, romIn, pcIn, pcOut, romAddr: unsigned(15 downto 0);
    signal instrB, instrJ, instrI, pcWrtEn, pcWrtCnd, pcWrt, sUlaA, jmp, excp, pcSource, zeroReg, memtoReg, regWrt, rstPc, irWrt, z, n, v : std_logic;
    signal lorD : unsigned(1 downto 0);
    signal ulaOp : unsigned(3 downto 0);
    signal sUlaB, r0Address, wrAddress : unsigned(2 downto 0);
    signal romOut : unsigned(18 downto 0);
    signal IFinst, IDinst, IDinstIn, EXinst, EXinstIN, MEMinst, MEMinstIn, WBinst : unsigned(70 downto 0);
begin
    ulat : ULA port map(
        dataInA => ulaA,
        dataInB => ulaB,
        opSelect => ulaOp,
        dataOut => ulaOut,
        z => z,
        n => n,
        v => v
    );
    regFile : registerFile port map(
        clk => clk,
        rst => rst,
        wrEn => regWrt,
        wrData => wrtData,
        wrAddress => wrAddress,
        r0Address => r0Address,
        r1Address => IFinst(8 downto 6),
        r0Data => r0,
        r1Data => r1
    );
    romMem : ROM port map(
        clk => clk,
        address => romAddr,
        data => romOut
    );
    -- kk
    cU : controlUnit port map(
        clk => clk,
        rst => rst,
        instruction => IFinst(18 downto 12),
        pcWrtEn => pcWrtEn,
        pcWrtCnd => pcWrtCnd,
        pcSource => pcSource,
        ulaSrcA => sUlaA,
        ulaSrcB => sUlaB,
        ulaOp => ulaOp,
        opException => excp,
        zeroReg => zeroReg,
        memtoReg => memtoReg,
        regWrt => regWrt,
        irWrt => irWrt,
        lorD => lorD,
        z => z,
        n => n,
        v => v
    );
    pcReg : reg16 port map(
        clk => clk,
        rst => rst,
        wrEn => pcWrt,
        dataIn => pcIn,
        dataOut => pcOut
    );
    -- Registradores
    IF_ID : reg71 port map(
        clk => clk,
        rst => rst,
        wrEn => '1',
        dataIn => IDinstIn,
        dataOut => IDinst
    );
    IDinstIn <= "000000000000000000000000000000000000" & pcOut & romOut;
    ID_EX : reg71 port map(
        clk => clk,
        rst => rst,
        wrEn => '1',
        dataIn => EXinstIn,
        dataOut => EXinst
    );
    EXinstIn <= r1 & r0 & imm & IDinst (34 downto 19) & IDinst(6 downto 0);
    EX_MEM : reg71 port map(
        clk => clk,
        rst => rst,
        wrEn => '1',
        dataIn => MEMinstIn,
        dataOut => MEMinst
    );
    MEMinstIn <= "00000000000000000000000000000" & (IDinst(22 downto 7) + IDinst(38 downto 23)) & v & n & z & ulaOut & EXinst(6 downto 0);
    wrAddress <= IFinst(11 downto 9);
    -- MUX
    romAddr <= pcOut;

    ulaA <= pcOut when sUlaA = '0' else
            r0Ula when sUlaA = '1' else
            (others => '0');

    ulaB <= r1Ula when sUlaB = "000" else
        "0000000000000001" when sUlaB = "001" else
        (others => '0');

    pcIn <= pcOut + 1 when pcSource = '0' else
            ulaOut when pcSource = '1' else
            (others => '0');
            
    r0Address <= "000" when zeroReg = '1' else
            IDinst(11 downto 9);

    wrtData <= ulaOut when memtoReg = '0' else
        (others => '0');
    -- and not excp:
    pcWrt <= (pcWrtEn or pcWrtCnd);
    -- IMM GEN
    -- dps ver se vai colocar o decode na cu
    -- define qual é o tamanho da constante a ser extraída da instrução
    instrJ <= '1' when romOut(3 downto 0) = "0001" else '0';
    instrB <= '1' when romOut(3 downto 0) = "0100" else '0';
    instrI <= '1' when romOut(3 downto 0) = "0011" else '0';
    -- extensão de sinal
    imm <= "0000" & IDinst(18 downto 7) when IDinst(18) = '0' and (instrJ = '1' or instrB = '1') else
       "1111" & IDinst(18 downto 7) when IDinst(18) = '1' and (instrJ = '1' or instrB = '1') else
       "0000000" & IDinst(18 downto 10) when IDinst(18) = '0' and instrI = '1' else
       "1111111" & IDinst(18 downto 10) when IDinst(18) = '1' and instrI = '1' else
       (others => '0');
end architecture;
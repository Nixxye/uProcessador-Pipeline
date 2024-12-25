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

    component reg74 is
        port(
            clk, rst, wrEn : in std_logic;
            dataIn : in unsigned(73 downto 0);
            dataOut : out unsigned(73 downto 0)
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
    signal instrB, instrJ, instrI, pcWrtEn, pcWrtCnd, pcWrt, sUlaA, jmp, excp, pcSource, zeroReg, regWrt, rstPc, irWrt, z, n, v : std_logic;
    signal lorD, memtoReg : unsigned(1 downto 0);
    signal ulaOp : unsigned(3 downto 0);
    signal sUlaB, r0Address, wrAddress : unsigned(2 downto 0);
    signal romOut : unsigned(18 downto 0);
    signal IDinst, IDinstIn, EXinst, EXinstIN, MEMinst, WBinstIN, MEMinstIn, WBinst : unsigned(73 downto 0);
    -- opcodes de cada estado
    signal opcodeID, opcodeEX, opcodeMEM : unsigned (3 downto 0);
    signal functID, functEX, functMEM : unsigned (2 downto 0);
begin
    -- CONTROLE DOS ESTADOS:
    opcodeID <= IDinst(3 downto 0);
    functID <= IDinst(6 downto 4);
    opcodeEX <= EXinst(3 downto 0);
    functEX <= EXinst(6 downto 4);
    opcodeMEM <= MEMinst(3 downto 0);
    functMEM <= MEMinst(6 downto 4);
    -- INSTRUCTION FETCH
    pcReg : reg16 port map(
        clk => clk,
        rst => rst,
        wrEn => pcWrt,
        dataIn => pcIn,
        dataOut => pcOut
    );
    romMem : ROM port map(
        clk => clk,
        address => pcOut,
        data => romOut
    );
    pcIn <= pcOut + 1 when pcSource = '0' else
        (others => '0');
    -- romAddr <= pcOut;
    pcWrt <= not excp;
    -------------------------
    IF_ID : reg74 port map(
        clk => clk,
        rst => rst,
        wrEn => '1',
        dataIn => IDinstIn,
        dataOut => IDinst
    );
    IDinstIn <= "000000000000000000000000000000000000000" & pcOut & romOut;
    -- INSTRUCTION DECODE
    regFile : registerFile port map(
        clk => clk,
        rst => rst,
        wrEn => regWrt,
        wrData => wrtData,
        wrAddress => wrAddress,
        r0Address => IDinst(9 downto 7),
        r1Address => IDinst(12 downto 10),
        r0Data => r0,
        r1Data => r1
    );
    wrtData <= WBinst(22 downto 7) when memtoReg = "00" else --  saída da ula
        WBinst(57 downto 42) when memtoReg = "01" else -- constante imediata
        WBinst(38 downto 23) when memtoReg = "10" else -- registrador r0
        -- add saída da RAM aqui
        (others => '0');
    wrAddress <= IDinst(12 downto 10);
    excp <= '0' when opcodeID = "0000" and functID = "000" else --nop
        '0' when opcodeID = "0001" and functID = "000" else -- jmp
        '0' when opcodeID = "0000" and functID = "000" else -- add
        '0' when opcodeID = "0000" and functID = "001" else -- sub
        '0' when opcodeID = "0000" and functID = "010" else -- move
        '0' when opcodeID = "0011" and functID = "000" else -- addi
        '0' when opcodeID = "0011" and functID = "001" else -- ld
        '0' when opcodeID = "0100" and functID = "000" else -- ble
        '0' when opcodeID = "0100" and functID = "001" else -- blt
        '1';
    -- imm gen
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
    -------------------------
    ID_EX : reg74 port map(
            clk => clk,
            rst => rst,
            wrEn => '1',
            dataIn => EXinstIn,
            dataOut => EXinst
        );
    EXinstIn <= "000" & r1 & r0 & imm & IDinst (34 downto 19) & IDinst(6 downto 0);      
    -- EXECUTE
    ulat : ULA port map(
        dataInA => ulaA,
        dataInB => ulaB,
        opSelect => ulaOp,
        dataOut => ulaOut,
        z => z,
        n => n,
        v => v
    );
    -- r0 sempre
    ulaA <= EXinst(54 downto 39);
    -- r1 ou imm
    ulaB <= EXinst(70 downto 55) when opcodeEX = "0010" else --r1 para instruções do tipo R
        EXinst(38 downto 23) when opcodeEX = "0011" or opcodeEX = "0100" else -- imm para instruções do tipo I e B
        (others => '0');
    -- 0000 = add, 0001 = sub, 0010 = and, 0011 = or, 0101 = passa a entrada B para a saída
    ulaOP <= "0000" when opcodeEX = "0000" and functEX = "000" else -- add
        "0001" when opcodeEX = "0000" and functEX = "001" else -- sub
        -- "0101" when opcodeEX = "0000" and functEX = "010" else -- move (n passa pela ula)
        "0001" when opcodeEX = "0011" and functEX = "000" else -- addi
        -- "0100" when opcodeEX = "0011" and functEX = "001" else -- ld (n passa pela ula)
        -- "0101" when opcodeEX = "0100" and functEX = "000" else -- ble (n passa pela ula)
        -- "0110" when opcodeEX = "0100" and functEX = "001" else -- blt (n passa pela ula)
        (others => '0');
    -------------------------
    EX_MEM : reg74 port map(
        clk => clk,
        rst => rst,
        wrEn => '1',
        dataIn => MEMinstIn,
        dataOut => MEMinst
    );
    MEMinstIn <= (EXinst(22 downto 7) + EXinst(38 downto 23)) & EXinst(38 downto 23) & v & n & z & EXinst(38 downto 23) & ulaOut & EXinst(6 downto 0);
    -- MEMORY  
    pcSource <= '0'; 
    -------------------------
    MEM_WB : reg74 port map(
        clk => clk,
        rst => rst,
        wrEn => '1',
        dataIn => WBinstIN,
        dataOut => WBinst
    );
    WBinstIN <= MEMinst; -- por enquanto não existe RAM
    -- WRITE BACK     
    memtoReg <= "00";
    regWrt <= '1' when opcodeMEM = "0010" and functMEM = "000" else -- add
        '1' when opcodeMEM = "0010" and functMEM = "001" else -- sub
        '1' when opcodeMEM = "0010" and functMEM = "010" else -- move
        '1' when opcodeMEM = "0011" and functMEM = "000" else -- addi
        '1' when opcodeMEM = "0011" and functMEM = "001" else -- ld
        '0';
end architecture;
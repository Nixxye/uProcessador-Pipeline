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

    component reg77 is
        port(
            clk, rst, wrEn : in std_logic;
            dataIn : in unsigned(76 downto 0);
            dataOut : out unsigned(76 downto 0)
        );
    end component;

    component ROM is
    port (
        clk, rst : in std_logic;
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
    signal imm, ulaA, ulaB, r0, r1, r0Fwd, r1Fwd, r0Ula, r1Ula, wrtData, ulaOut, ulaResult, romIn, pcIn, pcOut, romAddr, pcMem: unsigned(15 downto 0);
    signal rstIF_ID, stall, instrB, instrJ, instrI, pcWrtEn, pcWrtCnd, pcWrt, sUlaA, jmpGuess, jmpReal, excp, zeroReg, regWrt, rstPc, irWrt, z, n, v, flush, flushAux : std_logic;
    signal lorD, memtoReg : unsigned(1 downto 0);
    signal ulaOp : unsigned(3 downto 0);
    signal sUlaB, r0Address, wrAddress, pcSource : unsigned(2 downto 0);
    signal romOut : unsigned(18 downto 0);
    signal IDinst, IDinstIn, EXinst, EXinstIN, MEMinst, WBinstIN, MEMinstIn, WBinst : unsigned(76 downto 0);
    -- opcodes de cada estado
    signal opcodeID, opcodeEX, opcodeMEM, opcodeWB : unsigned (3 downto 0);
    signal functID, functEX, functMEM, functWB : unsigned (2 downto 0);
begin
    -- CONTROLE DOS ESTADOS:
    opcodeID <= IDinst(3 downto 0);
    functID <= IDinst(6 downto 4);
    opcodeEX <= EXinst(3 downto 0);
    functEX <= EXinst(6 downto 4);
    opcodeMEM <= MEMinst(3 downto 0);
    functMEM <= MEMinst(6 downto 4);
    opcodeWB <= WBinst(3 downto 0);
    functWB <= WBinst(6 downto 4);
    -- INSTRUCTION FETCH
    pcReg : reg16 port map(
        clk => clk,
        rst => rst,
        wrEn => pcWrt,
        dataIn => pcIn,
        dataOut => pcOut
    );
    -- Guarda o valor do pc anterior (para enviar junto com a instrução) <- ROM precisa de clock
    pcMemReg : reg16 port map(
        clk => clk,
        rst => rst,
        wrEn => '1',
        dataIn => pcOut,
        dataOut => pcMem
    );
    romMem : ROM port map(
        clk => clk,
        rst => rst,
        address => pcOut,
        data => romOut
    );
    pcIn <= pcOut + 1 when pcSource = "000" else
        "0000" & romOut(18 downto 7) when pcSource = "001" and romOut(18) = '0' else -- imm (jmp)
        EXinst(22 downto 7) + EXinst(38 downto 23) when pcSource = "010" else -- pcAntigo + delta (ble e blt)
        EXinst(22 downto 7) + x"0001" when pcSource = "011" else -- pcAntigo + 1 (ble e blt)
        pcOut + ("0000" & romOut(18 downto 7)) when pcSource = "100" and romOut(18) = '0' else -- pc + delta
        pcOut + ("1111" & romOut(18 downto 7)) when pcSource = "100" and romOut(18) = '1' else -- pc + delta
        (others => '0');
    -- Chute do branch:
    jmpGuess <= '1';
    -- Adianta o pulo:
    pcSource <= "010" when flush = '1' and jmpReal = '1' else -- errou e tem que pular (pcAntigo + delta)
        "011" when flush = '1' and jmpReal = '0' else -- errou e não tem que pular (pcAntigo + 1)
        "001" when romOut(3 downto 0) = "0001" and romOut(6 downto 4) = "000" else -- jmp
        "100" when romOut(3 downto 0) = "0100" and jmpGuess = '1' else -- branch (chute)
        "000"; 
    pcWrt <= not excp;
    -------------------------
    IF_ID : reg77 port map(
        clk => clk,
        rst => rstIF_ID,
        wrEn => '1',
        dataIn => IDinstIn,
        dataOut => IDinst
    );
    IDinstIn <= "00000000000000000000000000000000000000000" & jmpGuess & pcMem & romOut;
    rstIF_ID <= rst or stall or flush or flushAux;
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
    wrAddress <= WBinst(76 downto 74);
    excp <= '0' when romOut(3 downto 0) = "0000" and romOut(6 downto 4) = "000" else --nop
        '0' when romOut(3 downto 0) = "0001" and romOut(6 downto 4) = "000" else -- jmp
        '0' when romOut(3 downto 0) = "0010" and romOut(6 downto 4) = "000" else -- add
        '0' when romOut(3 downto 0) = "0010" and romOut(6 downto 4) = "001" else -- sub
        '0' when romOut(3 downto 0) = "0010" and romOut(6 downto 4) = "011" else -- cmp
        '0' when romOut(3 downto 0) = "0010" and romOut(6 downto 4) = "010" else -- move
        '0' when romOut(3 downto 0) = "0011" and romOut(6 downto 4) = "000" else -- addi
        '0' when romOut(3 downto 0) = "0011" and romOut(6 downto 4) = "001" else -- ld
        '0' when romOut(3 downto 0) = "0011" and romOut(6 downto 4) = "010" else -- cmpi
        '0' when romOut(3 downto 0) = "0100" and romOut(6 downto 4) = "000" else -- ble
        '0' when romOut(3 downto 0) = "0100" and romOut(6 downto 4) = "001" else -- blt
        '1';
    -- imm gen
    -- define qual é o tamanho da constante a ser extraída da instrução
    instrJ <= '1' when opcodeID = "0001" else '0';
    instrB <= '1' when opcodeID = "0100" else '0';
    instrI <= '1' when opcodeID = "0011" else '0';
    -- extensão de sinal
    imm <= "0000" & IDinst(18 downto 7) when IDinst(18) = '0' and (instrJ = '1' or instrB = '1') else
        "1111" & IDinst(18 downto 7) when IDinst(18) = '1' and (instrJ = '1' or instrB = '1') else
        "0000000" & IDinst(18 downto 10) when IDinst(18) = '0' and instrI = '1' else
        "1111111" & IDinst(18 downto 10) when IDinst(18) = '1' and instrI = '1' else
        (others => '0');

    -- STALLS (reset do registrador depende de clock)
    stall <= '1' when opcodeID = "0001" and functID = "000" else -- jump
        '1' when opcodeID = "0100" and IDinst(35) = '1' else -- branch e chutou que pula
        '0';
    -- FORWARDING
    r1Fwd <= ulaOut when EXinst(73 downto 71) = IDinst(12 downto 10) else -- Estado EXECUTE
        MEMinst(22 downto 7) when MEMinst(76 downto 74) = IDinst(12 downto 10) else -- Estado MEMORY
        r1;
    r0Fwd <= ulaOut when EXinst(73 downto 71) = IDinst(9 downto 7) else -- Estado EXECUTE
        MEMinst(22 downto 7) when MEMinst(76 downto 74) = IDinst(9 downto 7) else -- Estado MEMORY
        r0;
    -------------------------
    ID_EX : reg77 port map(
            clk => clk,
            rst => flush,
            wrEn => '1',
            dataIn => EXinstIn,
            dataOut => EXinst
        );
    EXinstIn <= "00" & IDinst(35) & IDinst(9 downto 7) & r1Fwd & r0Fwd & imm & IDinst (34 downto 19) & IDinst(6 downto 0);      
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
    ulaOP <= "0000" when opcodeEX = "0010" and functEX = "000" else -- add
        "0000" when opcodeEX = "0011" and functEX = "000" else -- addi
        "0001" when opcodeEX = "0010" and functEX = "001" else -- sub
        "0001" when opcodeEX = "0010" and functEX = "011" else -- cmp
        "0001" when opcodeEX = "0011" and functEX = "010" else -- cmpi
        (others => '0');
    -- Verifica se o chute de branch foi correto:
    jmpReal <= '1' when opcodeEX = "0100" and functEX = "000" and ((MEMinst(40) /= MEMinst(41)) or (MEMinst(39) = '1')) else -- n != v or z = '1' <= ble
        '1' when opcodeEX = "0100" and functEX = "001" and MEMinst(40) /= MEMinst(41) else -- n != v <= blt
        '0';
    
    flush <= '1' when EXinst(74) = '1' and opcodeEX = "0100" and jmpReal /= EXinst(74) else -- pulou e não deveria pular ou não pulou e deveria pular
        '0';
    -------------------------
    EX_MEM : reg77 port map(
        clk => clk,
        rst => rst,
        wrEn => '1',
        dataIn => MEMinstIn,
        dataOut => MEMinst
    );
    -- Não altera as flags para instruções que não são de ULA: ld, jump, mov, bne e ble
    MEMinstIn <= EXinst(73 downto 71) & (EXinst(22 downto 7) + EXinst(38 downto 23)) & EXinst(38 downto 23) & MEMinst(41 downto 39) & EXinst(70 downto 55) & ulaOut & EXinst(6 downto 0) when opcodeEX = "0001" or (opcodeEX = "0010" and functEX = "010") or (opcodeEX = "0011" and functEX = "001") or opcodeEX = "0100" else
        EXinst(73 downto 71) & (EXinst(22 downto 7) + EXinst(38 downto 23)) & EXinst(38 downto 23) & v & n & z & EXinst(70 downto 55) & ulaOut & EXinst(6 downto 0);
    -- MEMORY  
    -------------------------
    MEM_WB : reg77 port map(
        clk => clk,
        rst => rst,
        wrEn => '1',
        dataIn => WBinstIN,
        dataOut => WBinst
    );
    WBinstIN <= MEMinst; -- por enquanto não existe RAM
    -- WRITE BACK     
    memtoReg <= "00" when opcodeWB = "0010" and functWB = "000" else -- add
        "00" when opcodeWB = "0010" and functWB = "001" else -- sub
        "00" when opcodeWB = "0011" and functWB = "000" else -- addi
        "10" when opcodeWB = "0010" and functWB = "010" else -- move
        "01" when opcodeWB = "0011" and functWB = "001" else -- ld
        "00";
    regWrt <= '1' when opcodeWB = "0010" and functWB = "000" else -- add
        '1' when opcodeWB = "0010" and functWB = "001" else -- sub
        '1' when opcodeWB = "0010" and functWB = "010" else -- move
        '1' when opcodeWB = "0011" and functWB = "000" else -- addi
        '1' when opcodeWB = "0011" and functWB = "001" else -- ld
        '0';
    -- Utilizado para dar mais um flush no primeiro registrador, já que o primeiro estado possui 2 clocks:
    process (clk)
    begin
        if rising_edge(clk) then
            flushAux <= flush;
        end if;
    end process;
end architecture;
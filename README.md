# uProcessador-Pipeline

Projeto de um microprocessador desenvolvido por Jean Carlos do Nascimento Cunha para a disciplina de **Arquitetura e Organização de Computadores** sob a orientação do Professor **Juliano Mourão Vieira**.
## Referência
[Notion](https://resisted-timimus-fe1.notion.site/Pipeline-1662a778c47f80c79239ec9372a47a6a?pvs=4)
## Requisitos

Para executar o projeto, você precisará de:

- **GHDL** - Compilador para VHDL.
- **GTKWave** - Visualizador de waveform para análise de sinais.
- **Make** - Utilitário para automação de compilação.

## Como Usar

Para compilar e simular o microprocessador, basta abrir o terminal no diretório do projeto e digitar `make`. 

## Descrição das Instruções:
O microprocessador implementa três tipos principais de instruções: Tipo N (NOP), Tipo J (Jump), Tipo R (Registro), Tipo I (Imediato) e Tipo B (Branch). Abaixo, a descrição de cada tipo de instrução e seus campos:
### Instruções de Tipo N
| Instruções (N) | 18 downto 0 |
| --- | --- |
| Nop | 0 |

### Instruções de Tipo J
As instruções do tipo Jump (J) são utilizadas para controlar o fluxo de execução do programa, realizando saltos para outros endereços de memória.
| Instruções (J) | Endereço ROM (18 downto 7) | FUNCT (6 downto 4) | Opcode (3 downto 0) |
| --- | --- | --- | --- |
| Jump |  | 000 | 0001 |
* Opcode: Código da operação (4 bits).
* FUNCT: Função associada ao opcode (3 bits).
* Endereço ROM: Endereço de memória de destino para a operação de salto (12 bits).
### Instruções de Tipo R
As instruções do tipo R envolvem operações aritméticas ou lógicas entre registradores. Elas utilizam os campos R0 e R1 para armazenar os operandos e resultados.
#### Instruções de Memória:
As instruções de memória também são classificadas como do tipo R. Elas são usadas para transferir dados entre registradores e endereços de memória:
* lw r0,$(r1) — Carrega o dado localizado no endereço apontado por r1 para o registrador r0.
* sw r0,$(r1) — Armazena o dado do registrador r0 no endereço apontado por r1.

| Instruções (R) | R1 (12 downto 10) | R0 (9 downto 7) | FUNCT (6 downto 4) | Opcode (3 downto 0) |
| --- | --- | --- | --- | --- |
| ADD |  |  | 000 | 0010 |
| SUB |  |  | 001 | 0010 |
| MOV |  |  | 010 | 0010 |
| CMP |  |  | 011 | 0010 |
| LW | | | 100 | 0010 |
| SW | | | 101 | 0010 |
* Opcode: Código da operação (4 bits).
* FUNCT: Função específica da operação (3 bits).
* R0 e R1: Registradores envolvidos na operação (3 bits cada).
* CMP: Apenas para comparações, não altera nenhum registrador.
* A ordem dos operandos é r0 operação r1.
### Instruções de Tipo I
As instruções do tipo I são usadas para operações que envolvem imediatos, como adições com valores constantes ou carregamento de dados.
O comando LUI insere os 8 bits menos significativos (LSB) da constante (CTE) diretamente nos 8 bits mais significativos (MSB) do registrador R0. Já o comando LD adiciona os seus 9 bits aos 9 bits menos significativos do registrador R0.
| Instruções (I) | CTE (18 downto 10) | R0 (9 downto 7) | FUNCT (6 downto 4) | Opcode (3 downto 0) |
| --- | --- | --- | --- | --- |
| ADDI |  |  | 000 | 0011 |
| LD |  |  | 001 | 0011 |
| CMPI |  |  | 010 | 0011 |
| LUI |  |  | 011 | 0011 |
* Opcode: Código da operação (4 bits).
* FUNCT: Função associada à operação (3 bits).
* R0: Registrador envolvido na operação (3 bits).
* CTE: Valor constante a ser utilizado na operação (9 bits).
* CMPI: Apenas para comparações, não altera nenhum registrador.
### Instruções de Tipo B
As instruções do tipo B são usadas para saltos condicionais, baseados em comparações entre valores. Elas alteram o fluxo do programa se a condição especificada for verdadeira.
| Instruções (B) | CTE JMP RELATIVA (18 downto 7) | FUNCT (6 downto 4) | Opcode (3 downto 0) |
| --- | --- | --- | --- |
| BLE |  | 000 | 0100 |
| BLT |  | 001 | 0100 | 
* Opcode: Código da operação (4 bits).
* FUNCT: Função associada à operação (3 bits).
* DELTA: Deslocamento para o endereço de destino (9 bits).
* BLE: Salta se o valor de primeiro operando for menor ou igual ao de segundo na última comparação.
* BLT: Salta se o valor de primeiro operando for menor do que o segundo na última comparação.
### Instruções de Tipo B
As instruções do tipo P são utilizadas para operações auxiliares e simples, que envolvem apenas um único registrador como fonte e destino. Estas instruções são projetadas para facilitar manipulações rápidas e isoladas, como incrementos, sem a necessidade de operandos adicionais.
| Instruções (P) | R0 (9 downto 7) | FUNCT (6 downto 4) | Opcode (3 downto 0) |
| --- | --- | --- | --- |
| INC |   | 000 | 0101 |
* Opcode: Código da operação (4 bits).
* FUNCT: Função associada à operação (3 bits).
* R0: Registrador envolvido na operação (3 bits).
## Composição dos Registradores

### IF/ID

| DEFINIÇÃO | BITS |
| --- | --- |
| pulou? (chute do branch) | 35 |
| pc | 34 downto 19 |
| instrução | 18 downto 0 |

### ID/EX

| DEFINIÇÃO | BITS |
| --- | --- |
| pulou? (chute do branch) | 74 |
| endereço r0 | 73 downto 71 |
| registrador 1 | 70 downto 55 |
| registrador 0 | 54 downto 39 |
| constante imediata | 38 downto 23 |
| pc | 22 downto 7 |
| funct | 6 downto 4 |
| opcode | 3 downto 0 |

### EX/MEM

| DEFINIÇÃO | BITS |
| --- | --- |
| endereço r0 | 76 downto 74 |
| soma pc (branch) | 73 downto 58 |
| constante imediata / registrador 0 (apenas para sw) | 57 downto 42 |
| flag v | 41 |
| flag n | 40 |
| flag z | 39 |
| registrador 1 | 38 downto 23 |
| resultado da ula | 22 downto 7 |
| funct | 6 downto 4 |
| opcode | 3 downto 0 |

### MEM/WB

| DEFINIÇÃO | BITS |
| --- | --- |
| endereço r0 | 76 downto 74 |
| soma pc (branch) | 73 downto 58 |
| constante imediata / registrador 0 (apenas para sw) | 57 downto 42 |
| flag v | 41 |
| flag n | 40 |
| flag z | 39 |
| registrador 1 | 38 downto 23 |
| resultado da ula / saída da RAM (apenas para lw) | 22 downto 7 |
| funct | 6 downto 4 |
| opcode | 3 downto 0 |

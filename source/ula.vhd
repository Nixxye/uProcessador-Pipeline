library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ULA is
    port (
        dataInA, dataInB : in unsigned(15 downto 0);
        opSelect : in unsigned(3 downto 0); -- Modificar tamanho
        dataOut : out unsigned(15 downto 0);
        z, n, v : out std_logic -- Flags
    );
end entity;
architecture a_ULA of ULA is
    signal opResult : unsigned(15 downto 0);
begin
    dataOut <= opResult;
    opResult <= dataInA + dataInB when opSelect = "000" else
        datainA - dataInB when opSelect = "001" else
        datainA and datainB when opSelect = "010" else
        datainA or datainB when opSelect = "100" else
        datainB when opSelect = "101" else -- retirar no futuro
        (others => '0');
    -- FLAGS
    z <= '1' when opResult = 0 else '0';
    n <= opResult(15);
    v <= (dataInA(15) and dataInB(15) and not opResult(15))
     or (not dataInA(15) and not dataInB(15) and opResult(15));
end architecture;
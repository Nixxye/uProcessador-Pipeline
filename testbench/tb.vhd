library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- a entidade tem o mesmo nome do arquivo
entity tb is
end;

architecture a_tb of tb is
   component main 
   port(
        clk, rst, wrEn : in std_logic;
        opSelect : in unsigned(3 downto 0);
        r0, r1, wrAddress, wrData : in unsigned(15 downto 0);
        z, n, v : out std_logic;
        result : out unsigned(15 downto 0)
   );
   end component;
   signal wrAddress, wrData, r0, r1, out_a: unsigned (15 downto 0);
   signal inOp : unsigned (3 downto 0);
   signal z, n, v, clk, rst, wrEn : std_logic;

   constant periodTime : time := 50 ns;
   signal finished : std_logic := '0';
begin
   uut: main port map( 
        clk => clk,
        rst => rst,
        wrEn => wrEn,
        opSelect => inOp,
        r0 => r0,
        r1 => r1,
        wrData => wrData,
        wrAddress => wrAddress,
        z => z,
        n => n,
        v => v,
        result => out_a
    );
    resetGlobal : process
    begin
        rst <= '1';
        wait for periodTime * 2;
        rst <= '0';
        wait;
    end process;

    simTimeProc : process
    begin
        wait for 10 us;
        finished <= '1';
        wait;
    end process simTimeProc;

    clkProc : process
    begin
        while finished /= '1' loop
            clk <= '0';
            wait for periodTime / 2;
            clk <= '1';
            wait for periodTime / 2;
        end loop;
        wait;
    end process clkProc;

    process 
    begin
        wait for periodTime * 2;
        wrEn <= '1';
        wrAddress <= "0000000000000001";
        wrData <= "0000000010010001";
        wait for periodTime;
        wrAddress <= "0000000000000010";
        wrData <= "0000000010010001";
        wait for periodTime;
        wrEn <= '0';
        inOp <= "0000";
        r0 <= "0000000000000001";
        r1 <= "0000000000000010";
        wait for periodTime;
        inOp <= "0001";
        wait for periodTime;
        wait;
    end process;
end architecture;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg71 is 
    port(
        clk : in std_logic;
        rst : in std_logic;
        wrEn : in std_logic;
        dataIn : in unsigned(70 downto 0);
        dataOut : out unsigned(70 downto 0)
    );
end entity;

architecture a_reg71 of reg71 is
    signal reg : unsigned(70 downto 0);
begin
    process(clk, rst, wrEn)
    begin
        if rst = '1' then
            reg <= (others => '0');
        elsif wrEn = '1' then
            if rising_edge(clk) then
                reg <= dataIn;
            end if;
        end if;
    end process;
    dataOut <= reg;
end architecture;
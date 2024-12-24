library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity stateMachine is
    port (
        clk, rst : in std_logic;
        state : out unsigned(2 downto 0)
    );
end entity;
architecture a_stateMachine of stateMachine is
    signal s : unsigned(2 downto 0);
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                s <= "000";
            elsif s = "100" then -- Maior estado é 4 (LW OU SW)
                s <= "000";
            else
                s <= s + 1;
            end if;
        end if;
    end process;
    state <= s;
end architecture;
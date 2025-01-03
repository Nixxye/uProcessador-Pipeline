library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity predictor is 
    port(
        clk : in std_logic;
        rst : in std_logic;
        jumped : in std_logic;
        prediction : out std_logic
    );
end entity;

architecture a_predictor of predictor is
    signal guess : unsigned(1 downto 0);
begin
    process(clk, rst) -- Pode fazer isso?
    begin
        if rst = '1' then
            guess <= "10";
        elsif rising_edge(clk) then
            if jumped = '1' and guess /= "11" then
                guess <= guess + 1;
            elsif jumped = '0' and guess /= "00" then
                guess <= guess - 1;
            end if;
        end if;
    end process;
    prediction <= guess(1);
end architecture;
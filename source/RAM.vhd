library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
------------------------------------------------------------------------
entity RAM is
   port( 
         clk      : in std_logic;
         address : in unsigned(6 downto 0);
         wrEn    : in std_logic;
         dataIn  : in unsigned(15 downto 0);
         dataOut : out unsigned(15 downto 0) 
   );
end entity;
------------------------------------------------------------------------
architecture a_RAM of RAM is
   type mem is array (0 to 127) of unsigned(15 downto 0);
   signal conteudo_RAM : mem;
begin
   process(clk,wrEn)
   begin
      if rising_edge(clk) then
        if wrEn='1' then
            conteudo_RAM(to_integer(address)) <= dataIn;
        end if;
      end if;
   end process;
   dataOut <= conteudo_RAM(to_integer(address));
end architecture;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Hazard_Unit is
    port (
        ID_EX_MemRead : in std_logic;
        ID_EX_Rd : in std_logic_vector(4 downto 0);
        IF_ID_Rs1 : in std_logic_vector(4 downto 0);
        IF_ID_Rs2 : in std_logic_vector(4 downto 0);
        PCWrite : out std_logic;
        IFIDWrite : out std_logic;
        stall : out std_logic
    );
end entity Hazard_Unit;

architecture RTL of Hazard_Unit is
begin
    process(ID_EX_MemRead, ID_EX_Rd, IF_ID_Rs1, IF_ID_Rs2)
    begin
        if (ID_EX_MemRead = '1' and ID_EX_Rd /= "00000" and
        (ID_EX_Rd = IF_ID_Rs1 or ID_EX_Rd = IF_ID_Rs2)) then
        PCWrite <= '0';
        IFIDWrite <= '0';
        stall <= '1';
        else
        PCWrite <= '1';
        IFIDWrite <= '1';
        stall <= '0';
        end if;
    end process;

end architecture RTL;

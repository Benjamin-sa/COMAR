library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Forwarding_Unit is
    port (
        rs1_ex       : in std_logic_vector(4 downto 0);
        rs2_ex       : in std_logic_vector(4 downto 0);
        rd_mem       : in std_logic_vector(4 downto 0);
        rd_wb        : in std_logic_vector(4 downto 0);
        WriteReg_mem : in std_logic;
        WriteReg_wb  : in std_logic;
        
        -- NIEUW: Check of MEM instructie een load is
        MemRead_mem  : in std_logic;
        
        FW_A_sel     : out std_logic_vector(1 downto 0);
        FW_B_sel     : out std_logic_vector(1 downto 0)
    );
end entity;

architecture RTL of Forwarding_Unit is
begin
    process(rs1_ex, rs2_ex, rd_mem, rd_wb, WriteReg_mem, WriteReg_wb, MemRead_mem)
    begin
        FW_A_sel <= "00";
        FW_B_sel <= "00";

        -- A (rs1)
        -- Prioriteit: WB (Altijd veilig)
        if (WriteReg_wb = '1' and rd_wb /= "00000" and rd_wb = rs1_ex) then
             FW_A_sel <= "10";
        end if;
        -- MEM forwarding mag WB overschrijven, MAAR NIET ALS HET EEN LOAD IS
        if (WriteReg_mem = '1' and rd_mem /= "00000" and rd_mem = rs1_ex and MemRead_mem = '0') then
             FW_A_sel <= "01";
        end if;

        -- B (rs2) - Zelfde logica
        if (WriteReg_wb = '1' and rd_wb /= "00000" and rd_wb = rs2_ex) then
             FW_B_sel <= "10";
        end if;
        if (WriteReg_mem = '1' and rd_mem /= "00000" and rd_mem = rs2_ex and MemRead_mem = '0') then
             FW_B_sel <= "01";
        end if;
    end process;
end architecture RTL;
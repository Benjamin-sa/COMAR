
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Forwarding_Unit is
    port (
        rs1_ex : in std_logic_vector(4 downto 0); -- rs1 in EX
        rs2_ex : in std_logic_vector(4 downto 0); -- rs2 in EX
        rd_mem          : in  std_logic_vector(4 downto 0);  -- inst_rd_mem
        rd_wb           : in  std_logic_vector(4 downto 0);  -- inst_rd_wb
    
        WriteReg_mem    : in  std_logic;   -- Write enable in MEM
        WriteReg_wb     : in  std_logic;   -- Write enable in WB
    
        FW_A_sel        : out std_logic_vector(1 downto 0);  -- select voor mux FW_A
        FW_B_sel        : out std_logic_vector(1 downto 0)   -- select voor mux FW_B
    );
end entity;

architecture Behavioral of Forwarding_Unit is
begin
    process(rs1_ex, rs2_ex, rd_mem, rd_wb, WriteReg_mem, WriteReg_wb)
    begin
        -- standaard: geen forwarding
        FW_A_sel <= "00";
        FW_B_sel <= "00";
        -- A: rs1
        if WriteReg_mem = '1' and rd_mem /= "00000" and rd_mem = rs1_ex then
            FW_A_sel <= "01";                         -- van MEM
        elsif WriteReg_wb = '1' and rd_wb /= "00000" and rd_wb = rs1_ex then
            FW_A_sel <= "10";                         -- van WB
        end if;
    
        -- B: rs2
        if WriteReg_mem = '1' and rd_mem /= "00000" and rd_mem = rs2_ex then
            FW_B_sel <= "01";
        elsif WriteReg_wb = '1' and rd_wb /= "00000" and rd_wb = rs2_ex then
            FW_B_sel <= "10";
        end if;
    end process;
    
end Behavioral;

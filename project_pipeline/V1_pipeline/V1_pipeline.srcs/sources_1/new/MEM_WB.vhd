
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mem_wb is
    Port (
        clk : in std_logic;
        rst : in std_logic;
        enable : in std_logic;
        -- data inputs from MEM  
        ALU_result_mem_in  : in std_logic_vector(31 downto 0);  
        dataOut_mem_in     : in std_logic_vector(31 downto 0);  
        PC_mem_in          : in std_logic_vector(31 downto 0);  
        PCOutPlus_mem_in   : in std_logic_vector(31 downto 0);  
        multResult_mem_in  : in std_logic_vector(63 downto 0);  
        inst_rd_mem_in     : in std_logic_vector(4 downto 0);  
    
        -- control inputs from MEM  
        WriteReg_mem_in    : in std_logic;  
        ToRegister_mem_in  : in std_logic_vector(2 downto 0);  
    
        -- data outputs to WB  
        ALU_result_wb_out  : out std_logic_vector(31 downto 0);  
        dataOut_wb_out     : out std_logic_vector(31 downto 0);  
        PC_wb_out          : out std_logic_vector(31 downto 0);  
        PCOutPlus_wb_out   : out std_logic_vector(31 downto 0);  
        multResult_wb_out  : out std_logic_vector(63 downto 0);  
        inst_rd_wb_out     : out std_logic_vector(4 downto 0);  
    
        -- control outputs to WB  
        WriteReg_wb_out    : out std_logic;  
        ToRegister_wb_out  : out std_logic_vector(2 downto 0)  
    );  
end mem_wb;

architecture Behavioral of MEM_WB is

begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                ALU_result_wb_out <= (others => '0');
                dataOut_wb_out <= (others => '0');
                PC_wb_out <= (others => '0');
                PCOutPlus_wb_out <= (others => '0');
                multResult_wb_out <= (others => '0');
                inst_rd_wb_out <= (others => '0');
                WriteReg_wb_out   <= '0';  
                ToRegister_wb_out <= (others => '0');  
    
            elsif enable = '1' then  
                ALU_result_wb_out <= ALU_result_mem_in;  
                dataOut_wb_out    <= dataOut_mem_in;  
                PC_wb_out         <= PC_mem_in;  
                PCOutPlus_wb_out  <= PCOutPlus_mem_in;  
                multResult_wb_out <= multResult_mem_in;  
                inst_rd_wb_out    <= inst_rd_mem_in;  
    
                WriteReg_wb_out   <= WriteReg_mem_in;  
                ToRegister_wb_out <= ToRegister_mem_in;  
                end if;  
            end if;  
    end process;  


end Behavioral;

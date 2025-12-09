library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--to do : Memread meegeven 

entity id_ex is
    port(
        clk         : in  std_logic;
        rst         : in  std_logic;
        enable      : in  std_logic;
        
        -- inputs from ID stage
        PC_id_in            : in  std_logic_vector(31 downto 0);
        inst_rd_id_in       : in  std_logic_vector(4 downto 0);
        PCOutPlus_id_in     : in  std_logic_vector(31 downto 0);
        instruction_id_in   : in std_logic_vector(31 downto 0);
        
        
        regData1_id_in           : in  std_logic_vector(31 downto 0);
        regData2_id_in           : in  std_logic_vector(31 downto 0);
        imm_id_in           : in  std_logic_vector(31 downto 0);
        
        -- control
        jump_id_in       : in  std_logic;
        memWrite_id_in   : in  std_logic;
        StoreSel_id_in   : in  std_logic;
        ALUSrc_id_in     : in  std_logic;
        Branch_id_in     : in  std_logic_vector(2 downto 0);
        ALUOp_id_in      : in  std_logic_vector(2 downto 0);
        WriteReg_id_in   : in  std_logic;
        ToRegister_id_in : in  std_logic_vector(2 downto 0);
        
        -- outputs to EX stage
        PC_ex_out           : out std_logic_vector(31 downto 0);
        inst_rd_ex_out  : out std_logic_vector(31 downto 0);
        PCOutPlus_ex_out     : out  std_logic_vector(31 downto 0);
        regData1_ex_out      : out  std_logic_vector(31 downto 0);
        regData2_ex_out      : out  std_logic_vector(31 downto 0);
        imm_ex_out           : out  std_logic_vector(31 downto 0);
        
        --control
        jump_ex_out      : out std_logic;
        memWrite_ex_out  : out std_logic;
        StoreSel_ex_out  : out std_logic;
        ALUSrc_ex_out    : out std_logic;
        Branch_ex_out    : out std_logic_vector(2 downto 0);
        ALUOp_ex_out     : out std_logic_vector(2 downto 0);
        WriteReg_ex_out   : out std_logic;
        ToRegister_ex_out : out std_logic_vector(2 downto 0)
    );
end entity id_ex;

architecture RTL of id_ex is
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                PC_ex_out    <= (others => '0');
                inst_rd_ex_out <= (others => '0');
                PCOutPlus_ex_out <= (others => '0');
                regData1_ex_out <= (others => '0');
                regData2_ex_out <= (others => '0');
                imm_ex_out <= (others => '0');
                
                jump_ex_out      <= '0';
                memWrite_ex_out  <= '0';
                StoreSel_ex_out  <= '0';
                ALUSrc_ex_out    <= '0';
                Branch_ex_out    <= (others => '0');
                ALUOp_ex_out     <= (others => '0');
                WriteReg_ex_out   <= '0';
                ToRegister_ex_out <= (others => '0');
    
            elsif enable = '1' then
                PC_ex_out    <= PC_id_in;
                inst_rd_ex_out <= instruction_id_in;
                PCOutPlus_ex_out <= PCOutPlus_id_in;
                regData1_ex_out <=  regData1_id_in;
                regData2_ex_out <=  regData2_id_in;
                imm_ex_out <=  imm_id_in;
                
                jump_ex_out      <= jump_id_in;
                memWrite_ex_out  <= memWrite_id_in;
                StoreSel_ex_out  <= StoreSel_id_in;
                ALUSrc_ex_out    <= ALUSrc_id_in;
                Branch_ex_out    <= Branch_id_in;
                ALUOp_ex_out     <= ALUOp_id_in;
                WriteReg_ex_out   <= WriteReg_id_in;
                ToRegister_ex_out <= ToRegister_id_in;
            end if;
        end if;
    end process;

end RTL;

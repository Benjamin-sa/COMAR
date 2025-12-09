library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ex_mem is
    port(
        clk         : in  std_logic;
        rst         : in  std_logic;
        enable      : in  std_logic;
        
        -- Data inputs from EX stage
        ALU_result_ex_in    : in  std_logic_vector(31 downto 0);
        regData2_ex_in      : in  std_logic_vector(31 downto 0);  -- for store instructions
        PC_ex_in            : in  std_logic_vector(31 downto 0);
        PCOutPlus_ex_in     : in  std_logic_vector(31 downto 0);
        inst_rd_ex_in       : in  std_logic_vector(4 downto 0);   -- destination register
        multResult_ex_in    : in  std_logic_vector(63 downto 0);  -- multiplier result
        newAddress_ex_in    : in  std_logic_vector(31 downto 0);  -- branch/jump target
        zero_ex_in          : in  std_logic;
        signo_ex_in         : in  std_logic;
        
        -- Control inputs from EX stage
        memWrite_ex_in      : in  std_logic;
        Branch_ex_in        : in  std_logic_vector(2 downto 0);
        WriteReg_ex_in      : in  std_logic;
        ToRegister_ex_in    : in  std_logic_vector(2 downto 0);
        jump_ex_in          : in  std_logic;
        
        -- Data outputs to MEM stage
        ALU_result_mem_out  : out std_logic_vector(31 downto 0);
        regData2_mem_out    : out std_logic_vector(31 downto 0);
        PC_mem_out          : out std_logic_vector(31 downto 0);
        PCOutPlus_mem_out   : out std_logic_vector(31 downto 0);
        inst_rd_mem_out     : out std_logic_vector(4 downto 0);
        multResult_mem_out  : out std_logic_vector(63 downto 0);
        newAddress_mem_out  : out std_logic_vector(31 downto 0);
        zero_mem_out        : out std_logic;
        signo_mem_out       : out std_logic;
        
        -- Control outputs to MEM stage
        memWrite_mem_out    : out std_logic;
        Branch_mem_out      : out std_logic_vector(2 downto 0);
        WriteReg_mem_out    : out std_logic;
        ToRegister_mem_out  : out std_logic_vector(2 downto 0);
        jump_mem_out        : out std_logic
    );
end entity ex_mem;

architecture RTL of ex_mem is
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                -- Reset data signals
                ALU_result_mem_out  <= (others => '0');
                regData2_mem_out    <= (others => '0');
                PC_mem_out          <= (others => '0');
                PCOutPlus_mem_out   <= (others => '0');
                inst_rd_mem_out     <= (others => '0');
                multResult_mem_out  <= (others => '0');
                newAddress_mem_out  <= (others => '0');
                zero_mem_out        <= '0';
                signo_mem_out       <= '0';
                
                -- Reset control signals
                memWrite_mem_out    <= '0';
                Branch_mem_out      <= (others => '0');
                WriteReg_mem_out    <= '0';
                ToRegister_mem_out  <= (others => '0');
                jump_mem_out        <= '0';
                
            elsif enable = '1' then
                -- Latch data signals
                ALU_result_mem_out  <= ALU_result_ex_in;
                regData2_mem_out    <= regData2_ex_in;
                PC_mem_out          <= PC_ex_in;
                PCOutPlus_mem_out   <= PCOutPlus_ex_in;
                inst_rd_mem_out     <= inst_rd_ex_in;
                multResult_mem_out  <= multResult_ex_in;
                newAddress_mem_out  <= newAddress_ex_in;
                zero_mem_out        <= zero_ex_in;
                signo_mem_out       <= signo_ex_in;
                
                -- Latch control signals
                memWrite_mem_out    <= memWrite_ex_in;
                Branch_mem_out      <= Branch_ex_in;
                WriteReg_mem_out    <= WriteReg_ex_in;
                ToRegister_mem_out  <= ToRegister_ex_in;
                jump_mem_out        <= jump_ex_in;
            end if;
        end if;
    end process;
end architecture RTL;

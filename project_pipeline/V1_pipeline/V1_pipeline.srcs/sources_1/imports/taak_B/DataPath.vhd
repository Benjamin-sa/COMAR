library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity DataPath is
    port (
        clk         : in std_logic;
        rst         : in std_logic; --reset is button, must be debounced
        ALU_result  : out std_logic_vector(31 downto 0)
    );
end entity DataPath;

architecture arch_DataPath of DataPath is

    component PC
        port (
            PCIn    : in std_logic_vector(31 downto 0);
            clk     : in std_logic;
            rst     : in std_logic;                                                     
            PCOut   : out std_logic_vector(31 downto 0)
        );
    end component;

    component Instruction_Mem
        port (
            Address     :in std_logic_vector(15 downto 0);
            instruction :out std_logic_vector(31 downto 0)
        );
    end component;

    component Reg_File
        port (
            clk         :in std_logic;
            writeReg    :in std_logic;                          --signal for write in register
            sourceReg1  :in std_logic_vector(4 downto 0);       --address of rs1
            sourceReg2  :in std_logic_vector(4 downto 0);       --address of rs2
            destinyReg  :in std_logic_vector(4 downto 0);       --address of rd
            data        :in std_logic_vector(31 downto 0);      --Data to be written
            readData1   :out std_logic_vector(31 downto 0);     --data in rs1
            readData2   :out std_logic_vector(31 downto 0)      --data in rs2    
        );
    end component;

    component Mux
        port (
            muxIn0      :in std_logic_vector(31 downto 0);
            muxIn1      :in std_logic_vector(31 downto 0);
            selector    :in std_logic;
            muxOut      :out std_logic_vector(31 downto 0)    
    );
    end component;

    component ALU_RV32
        port (
            operator1   :in std_logic_vector(31 downto 0);
            operator2   :in std_logic_vector(31 downto 0);
            ALUOp       :in std_logic_vector(2 downto 0);
            result      :out std_logic_vector(31 downto 0);
            zero        :out std_logic;
            carryOut    :out std_logic;
            signo  		:out std_logic
        );
    end component;

    component Data_Mem
        port (
            clk     :in std_logic;
            writeEn :in std_logic;
            Address :in std_logic_vector(7 downto 0);
            dataIn  :in std_logic_vector(31 downto 0);
            dataOut :out std_logic_vector(31 downto 0)
        );
    end component;

    component Immediate_Generator
        port (
            instruction     : in std_logic_vector(31 downto 0);
            immediate       : out std_logic_vector(31 downto 0)
        );
    end component;

    component Mux_Store
        port (
            muxIn0      :in std_logic_vector(31 downto 0);  --SB
            muxIn1      :in std_logic_vector(31 downto 0);  --SW
            selector    :in std_logic;
            muxOut      :out std_logic_vector(31 downto 0)
    );
    end component;

    component multiplier
        generic(size: INTEGER := 32);
        port (
            operator1   : in std_logic_vector(size-1 downto 0);
            operator2   : in std_logic_vector(size-1 downto 0);
            product     : out std_logic_vector(2*size-1 downto 0)
        );
    end component;

    component Branch_Control
        port (
            branch      : in std_logic_vector(2 downto 0);
            signo       : in std_logic;
            zero        : in std_logic;
            PCSrc       : out std_logic
        );
    end component;

    component Mux_ToRegFile
        generic (
            busWidth    :integer := 32
            --selWidth    :integer := 3
        );
        port (
            muxIn0     :in std_logic_vector(busWidth-1 downto 0);       --register
            muxIn1     :in std_logic_vector(busWidth-1 downto 0);       --LB
            muxIn2     :in std_logic_vector(busWidth-1 downto 0);       --LW
            muxIn3     :in std_logic_vector(busWidth-1 downto 0);       --PC
            muxIn4     :in std_logic_vector(busWidth-1 downto 0);       --zeros
            muxIn5     :in std_logic_vector(busWidth-1 downto 0);       --PC+4
            muxIn6     :in std_logic_vector(busWidth-1 downto 0);       --mul
            muxIn7     :in std_logic_vector(busWidth-1 downto 0);       --mulh
            selector   :in std_logic_vector(2 downto 0);       --ToRegister
            muxOut     :out std_logic_vector(busWidth-1 downto 0)
        );
    end component;

    component Control
        port (
            opcode      : in std_logic_vector(6 downto 0);
            funct3      : in std_logic_vector(2 downto 0);
            funct7      : in std_logic_vector(6 downto 0);
            jump        : out std_logic;
            ToRegister  : out std_logic_vector(2 downto 0);
            MemWrite    : out std_logic;
            Branch      : out std_logic_vector(2 downto 0);
            ALUOp       : out std_logic_vector(2 downto 0);
            StoreSel    : out std_logic;
            ALUSrc      : out std_logic;
            WriteReg    : out std_logic;
            
            --toevoeging voor registers
            Memread     : out std_logic
        );
    end component;

    component if_id
        port (
            instruction_if_in : in std_logic_vector(31 downto 0);
            PC_if_in : in std_logic_vector(31 downto 0);
            PCOutPlus_if_in : in std_logic_vector(31 downto 0);
            clk : in std_logic;
            rst : in std_logic;
            enable : in std_logic;
            instruction_id_out : out std_logic_vector(31 downto 0);
            PC_id_out : out std_logic_vector(31 downto 0);
            PCOutPlus_id_out : out std_logic_vector(31 downto 0)
        );
    end component;
    
    component id_ex
    port (
        clk      : in  std_logic;
        rst      : in  std_logic;
        enable   : in  std_logic;
        
        PC_id_in         : in  std_logic_vector(31 downto 0);
        inst_rd_id_in : in  std_logic_vector(4 downto 0);
        PCOutPlus_id_in  : in  std_logic_vector(31 downto 0);
        instruction_id_in   : in std_logic_vector(31 downto 0);
        
        regData1_id_in   : in  std_logic_vector(31 downto 0);
        regData2_id_in   : in  std_logic_vector(31 downto 0);
        imm_id_in        : in  std_logic_vector(31 downto 0);
        
        jump_id_in       : in  std_logic;
        memWrite_id_in   : in  std_logic;
        StoreSel_id_in   : in  std_logic;
        ALUSrc_id_in     : in  std_logic;
        Branch_id_in     : in  std_logic_vector(2 downto 0);
        ALUOp_id_in      : in  std_logic_vector(2 downto 0);
        WriteReg_id_in   : in  std_logic;
        ToRegister_id_in : in  std_logic_vector(2 downto 0);
        MemRead_id_in   : in  std_logic;
        
         -- outputs to EX stage
        PC_ex_out            : out std_logic_vector(31 downto 0);
        inst_rd_ex_out       : out std_logic_vector(4 downto 0);
        PCOutPlus_ex_out     : out  std_logic_vector(31 downto 0);
        instruction_ex_out   : out  std_logic_vector(31 downto 0);
        
        regData1_ex_out           : out  std_logic_vector(31 downto 0);
        regData2_ex_out           : out  std_logic_vector(31 downto 0);
        imm_ex_out           : out  std_logic_vector(31 downto 0);
        
        --control
        jump_ex_out      : out std_logic;
        memWrite_ex_out  : out std_logic;
        StoreSel_ex_out  : out std_logic;
        ALUSrc_ex_out    : out std_logic;
        Branch_ex_out    : out std_logic_vector(2 downto 0);
        ALUOp_ex_out     : out std_logic_vector(2 downto 0);
        WriteReg_ex_out   : out std_logic;
        ToRegister_ex_out : out std_logic_vector(2 downto 0);
        MemRead_ex_out   : out  std_logic  
    );
    end component;
    
    component ex_mem
    port (
        clk                 : in  std_logic;
        rst                 : in  std_logic;
        enable              : in  std_logic;
        -- Data inputs from EX stage
        ALU_result_ex_in    : in  std_logic_vector(31 downto 0);
        regData2_ex_in      : in  std_logic_vector(31 downto 0);
        PC_ex_in            : in  std_logic_vector(31 downto 0);
        PCOutPlus_ex_in     : in  std_logic_vector(31 downto 0);
        inst_rd_ex_in       : in  std_logic_vector(4 downto 0);
        multResult_ex_in    : in  std_logic_vector(63 downto 0);
        newAddress_ex_in    : in  std_logic_vector(31 downto 0);
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
    end component;
    
    component mem_wb
    port (
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
    end component;
    
    component Forwarding_Unit
    port (
        rs1_ex : in std_logic_vector(4 downto 0);
        rs2_ex : in std_logic_vector(4 downto 0);
        rd_mem : in std_logic_vector(4 downto 0);
        rd_wb : in std_logic_vector(4 downto 0);
        WriteReg_mem : in std_logic;
        WriteReg_wb : in std_logic;
        FW_A_sel : out std_logic_vector(1 downto 0);
        FW_B_sel : out std_logic_vector(1 downto 0)
        );
    end component;
    
    component Hazard_Unit is
    port (
        ID_EX_MemRead : in  std_logic;
        ID_EX_Rd      : in  std_logic_vector(4 downto 0);
        IF_ID_Rs1     : in  std_logic_vector(4 downto 0);
        IF_ID_Rs2     : in  std_logic_vector(4 downto 0);
        PCWrite       : out std_logic;
        IFIDWrite     : out std_logic;
        stall         : out std_logic
    );
    end component;

    -- SIGNALS
    signal PCOut, PCOutPlus    : std_logic_vector(31 downto 0);    --data out from PC register
    signal instruction          : std_logic_vector(31 downto 0);    --instruction from ROM mem
    signal PCIn                 : std_logic_vector(31 downto 0);    --PC updated
    signal regData1,regData2    : std_logic_vector(31 downto 0);    --data readed from register file
    signal signo, zero, carry   : std_logic;
    signal result, dataIn       : std_logic_vector(31 downto 0);    --alu result and data in to memory
    signal immediate            : std_logic_vector(31 downto 0);    --immediate generated
    signal dataOut              : std_logic_vector(31 downto 0);    --data from memory
    signal jump, memWrite       : std_logic;
    signal StoreSel, ALUSrc     : std_logic;
    signal writeReg, PCSrc      : std_logic;
    signal toRegister, Branch, ALUOp : std_logic_vector(2 downto 0);
    signal dataForReg           : std_logic_vector(31 downto 0);    --data to be written in register File
    signal op2                  : std_logic_vector(31 downto 0);    --operator for ALU(output from mux)
    signal offset               : std_logic_vector(31 downto 0);    --PC+immediate after shift or result(jal)
    signal regData2Anded        : std_logic_vector(31 downto 0);
    signal newAddress           : std_logic_vector(31 downto 0);
    signal shifted              : std_logic_vector(31 downto 0);
    signal multResult           : std_logic_vector(63 downto 0);
    
    --if_id signals
    signal PC_id                : std_logic_vector(31 downto 0);
    signal instruction_id       : std_logic_vector(31 downto 0);
    signal if_id_enable         : std_logic;
    signal PCOutPlus_id         : std_logic_vector(31 downto 0);
    
    --id_ex signals
    signal PC_ex, PCOutPlus_ex     : std_logic_vector(31 downto 0);
    signal regData1_ex, regData2_ex: std_logic_vector(31 downto 0);
    signal imm_ex                  : std_logic_vector(31 downto 0);
    
    signal jump_ex, memWrite_ex    : std_logic;
    signal StoreSel_ex, ALUSrc_ex  : std_logic;
    signal Branch_ex, ALUOp_ex     : std_logic_vector(2 downto 0);
    signal id_ex_enable            : std_logic;
    signal inst_rd_ex              : std_logic_vector(4 downto 0);
    signal instruction_ex          : std_logic_vector(31 downto 0);
    signal WriteReg_ex             : std_logic;
    signal ToRegister_ex           : std_logic_vector(2 downto 0);
    signal mux1_out                : std_logic_vector(31 downto 0);
    
    --ex_mem signals
    signal ex_mem_enable           : std_logic;
    signal ALU_result_mem          : std_logic_vector(31 downto 0);
    signal regData2_mem            : std_logic_vector(31 downto 0);
    signal PC_mem                  : std_logic_vector(31 downto 0);
    signal PCOutPlus_mem           : std_logic_vector(31 downto 0);
    signal inst_rd_mem             : std_logic_vector(4 downto 0);
    signal multResult_mem          : std_logic_vector(63 downto 0);
    signal newAddress_mem          : std_logic_vector(31 downto 0);
    signal zero_mem                : std_logic;
    signal signo_mem               : std_logic;
    signal memWrite_mem            : std_logic;
    signal Branch_mem              : std_logic_vector(2 downto 0);
    signal WriteReg_mem            : std_logic;
    signal ToRegister_mem          : std_logic_vector(2 downto 0);
    signal jump_mem                : std_logic;
    
    --signaal voor RAM 
    signal Memread : std_logic;
    -- signaal voor hazard unit
    signal MemRead_ex : std_logic;
    
    -- mem_wb signals
    signal mem_wb_enable            : std_logic;
    signal ALU_result_wb            : std_logic_vector(31 downto 0);
    signal dataOut_wb               : std_logic_vector(31 downto 0);
    signal PC_wb                    : std_logic_vector(31 downto 0);
    signal PCOutPlus_wb             : std_logic_vector(31 downto 0);
    signal multResult_wb            : std_logic_vector(63 downto 0);
    signal inst_rd_wb               : std_logic_vector(4 downto 0);
    signal WriteReg_wb              : std_logic;
    signal ToRegister_wb            : std_logic_vector(2 downto 0);
    
    -- FW signals
    signal FW_A_sel : std_logic_vector(1 downto 0);
    signal FW_B_sel : std_logic_vector(1 downto 0);
    signal FW_A_out : std_logic_vector(31 downto 0);
    signal FW_B_out : std_logic_vector(31 downto 0);
    
    signal rs1_ex : std_logic_vector(4 downto 0);
    signal rs2_ex : std_logic_vector(4 downto 0);
    
    --HZ Detection signals
    signal stall : std_logic;
    signal IFIDWrite : std_logic;
    signal PCWrite : std_logic;
    signal PCNext : std_logic_vector(31 downto 0);
    
    signal jump_ctrl        : std_logic;
    signal MemWrite_ctrl    : std_logic;
    signal StoreSel_ctrl    : std_logic;
    signal ALUSrc_ctrl      : std_logic;
    signal Branch_ctrl      : std_logic_vector(2 downto 0);
    signal ALUOp_ctrl       : std_logic_vector(2 downto 0);
    signal WriteReg_ctrl    : std_logic;
    signal ToRegister_ctrl  : std_logic_vector(2 downto 0);
    signal MemRead_ctrl     : std_logic;
    
begin
    if_id_enable <= IFIDWrite;  --IF_ID register bevriezen voor hazard detection
    id_ex_enable <= '1'; --TIJDELIJK
    ex_mem_enable <= '1'; --TIJDELIJK
    mem_wb_enable <= '1'; -- TIJDELIJK
    PCount: PC port map (clk => clk, rst => rst, PCIn => PCIn, PCOut => PCOut);

    ROM: Instruction_Mem port map (Address => PCOut(15 downto 0), instruction => instruction);
    
    PCOutPlus <= PCOut + 4;

    IFID_reg: if_id
        port map (
            instruction_if_in => instruction, -- uit instruction memory
            PC_if_in => PCOut, -- PC van IF stage
            PCOutPlus_if_in => PCOutPlus,
            clk => clk,
            rst => rst,
            enable => if_id_enable,
            instruction_id_out => instruction_id,
            PC_id_out => PC_id,
            PCOutPlus_id_out => PCOutPlus_id
        );
    -- ID-stage gebruikt nu *_id signalen
    RFILE : reg_file port map (clk => clk, writeReg => writeReg_wb, sourceReg1 => instruction_id(19 downto 15),
    sourceReg2 => instruction_id(24 downto 20), destinyReg => inst_rd_wb, data => dataForReg,
    readData1 => regData1, readData2 => regData2);

    Imm: Immediate_Generator port map (instruction => instruction_id, immediate => immediate);

    Ctrl: Control port map (opcode => instruction_id(6 downto 0), funct3 => instruction_id(14 downto 12), funct7 => instruction_id(31 downto 25),
    jump => jump_ctrl, MemWrite => memWrite_ctrl, Branch => Branch_ctrl, ALUOp => ALUOp_ctrl, StoreSel => StoreSel_ctrl, ALUSrc => ALUSrc_ctrl, 
    WriteReg => WriteReg_ctrl, ToRegister => toRegister_ctrl, Memread => Memread_ctrl);
    
    Hazard: Hazard_Unit
    port map (
        ID_EX_MemRead => MemRead_ex,
        ID_EX_Rd      => inst_rd_ex,
        IF_ID_Rs1     => instruction_id(19 downto 15),
        IF_ID_Rs2     => instruction_id(24 downto 20),
        PCWrite       => PCWrite,
        IFIDWrite     => IFIDWrite,
        stall         => stall
    );
    
    -- mux_ctrl    
    jump      <= '0'                 when stall = '1' else jump_ctrl;
    MemWrite  <= '0'                 when stall = '1' else MemWrite_ctrl;
    StoreSel  <= '0'                 when stall = '1' else StoreSel_ctrl;
    ALUSrc    <= '0'                 when stall = '1' else ALUSrc_ctrl;
    Branch    <= (others => '0')     when stall = '1' else Branch_ctrl;
    ALUOp     <= (others => '0')     when stall = '1' else ALUOp_ctrl;
    WriteReg  <= '0'                 when stall = '1' else WriteReg_ctrl;
    ToRegister<= (others => '0')     when stall = '1' else ToRegister_ctrl;
    MemRead   <= '0'                 when stall = '1' else MemRead_ctrl;    
        
    IDEX_reg: id_ex
    port map (
        clk              => clk,
        rst              => rst,
        enable           => id_ex_enable,

        -- data uit ID
        regData1_id_in   => regData1,
        regData2_id_in   => regData2,
        imm_id_in  => immediate,
        PC_id_in         => PC_id,
        PCOutPlus_id_in  => PCOutPlus_id, 
        inst_rd_id_in => instruction_id(11 downto 7),
        instruction_id_in => instruction_id,

        -- control uit ID (rechtstreeks uit control)
        ALUOp_id_in       => ALUOp,
        ALUSrc_id_in      => ALUSrc,
        Branch_id_in      => Branch,
        jump_id_in        => jump,
        memWrite_id_in    => MemWrite,
        StoreSel_id_in    => StoreSel,
        WriteReg_id_in    => WriteReg,
        ToRegister_id_in  => toRegister,
        MemRead_id_in     => Memread,

        -- data naar EX
        regData1_ex_out   => regData1_ex,
        regData2_ex_out   => regData2_ex,
        imm_ex_out  => imm_ex,
        PC_ex_out         => PC_ex,
        PCOutPlus_ex_out  => PCOutPlus_ex,
        instruction_ex_out => instruction_ex,
        inst_rd_ex_out=> inst_rd_ex,

        -- control naar EX
        ALUOp_ex_out      => ALUOp_ex,
        ALUSrc_ex_out     => ALUSrc_ex,
        Branch_ex_out     => Branch_ex,
        jump_ex_out       => jump_ex,
        MemWrite_ex_out   => MemWrite_ex,
        StoreSel_ex_out   => StoreSel_ex,
        WriteReg_ex_out   => WriteReg_ex,
        ToRegister_ex_out => ToRegister_ex,
        MemRead_ex_out    => MemRead_ex
    );
    
    --EX stage

    Mux0: Mux port map (muxIn0 => imm_ex, muxIn1 => FW_B_out, selector => ALUSrc_ex, muxOut => op2);
    
    ALU: ALU_RV32 port map (operator1 => FW_A_out, operator2 => op2, ALUOp => ALUOp_ex, 
    result => result, zero => zero, carryOut => carry, signo => signo);
    
    ALU_result <= result;

    Mult: multiplier port map (operator1 => FW_A_out, operator2 => FW_B_out, product => multResult);

    regData2Anded <= FW_B_out and X"000000FF";

    Mux1: Mux port map (muxIn0 => FW_B_out, muxIn1 => regData2Anded, selector => StoreSel_ex, muxOut => mux1_out);

    Mux2: Mux port map (muxIn0 => imm_ex, muxIn1 => result, selector => jump_ex, muxOut => offset);

    shifted <= offset(30 downto 0) & '0';
    newAddress <= PC_ex + shifted;

    FW_Unit: Forwarding_Unit
    port map (
        rs1_ex => instruction_ex(19 downto 15),
        rs2_ex => instruction_ex(24 downto 20),
        rd_mem => inst_rd_mem,
        rd_wb => inst_rd_wb,
        WriteReg_mem => WriteReg_mem,
        WriteReg_wb => WriteReg_wb,
        FW_A_sel => FW_A_sel,
        FW_B_sel => FW_B_sel
    );
    
    FW_A_mux: process(FW_A_sel, regData1_ex, ALU_result_mem, dataForReg)
        begin
            case FW_A_sel is
            when "00" => FW_A_out <= regData1_ex; -- geen forwarding
            when "01" => FW_A_out <= ALU_result_mem; -- van EX/MEM
            when "10" => FW_A_out <= dataForReg; -- van WB
            when others => FW_A_out <= regData1_ex;
            end case;
        end process;
        
    FW_B_mux: process(FW_B_sel, regData2_ex, ALU_result_mem, dataForReg)
        begin
            case FW_B_sel is
            when "00" => FW_B_out <= regData2_ex;
            when "01" => FW_B_out <= ALU_result_mem;
            when "10" => FW_B_out <= dataForReg;
            when others => FW_B_out <= regData2_ex;
            end case;
        end process;

    -- EX/MEM pipeline register
    EXMEM_reg: ex_mem
    port map (
        clk                 => clk,
        rst                 => rst,
        enable              => ex_mem_enable,
        
        -- Data inputs from EX stage
        ALU_result_ex_in    => result,
        regData2_ex_in      => mux1_out,
        PC_ex_in            => PC_ex,
        PCOutPlus_ex_in     => PCOutPlus_ex,
        inst_rd_ex_in       => inst_rd_ex,
        multResult_ex_in    => multResult,
        newAddress_ex_in    => newAddress,
        zero_ex_in          => zero,
        signo_ex_in         => signo,
        
        -- Control inputs from EX stage
        memWrite_ex_in      => memWrite_ex,
        Branch_ex_in        => Branch_ex,
        WriteReg_ex_in      => WriteReg_ex,
        ToRegister_ex_in    => ToRegister_ex,
        jump_ex_in          => jump_ex,
        
        -- Data outputs to MEM stage
        ALU_result_mem_out  => ALU_result_mem,
        regData2_mem_out    => regData2_mem,
        PC_mem_out          => PC_mem,
        PCOutPlus_mem_out   => PCOutPlus_mem,
        inst_rd_mem_out     => inst_rd_mem,
        multResult_mem_out  => multResult_mem,
        newAddress_mem_out  => newAddress_mem,
        zero_mem_out        => zero_mem,
        signo_mem_out       => signo_mem,
        
        -- Control outputs to MEM stage
        memWrite_mem_out    => memWrite_mem,
        Branch_mem_out      => Branch_mem,
        WriteReg_mem_out    => WriteReg_mem,
        ToRegister_mem_out  => ToRegister_mem,
        jump_mem_out        => jump_mem
    );

    -- MEM stage: now uses *_mem signals

    BRControl: Branch_Control port map (branch => Branch_mem, signo => signo_mem, zero => zero_mem, PCSrc => PCSrc);

    RAM: Data_Mem port map (clk => clk, writeEn => memWrite_mem, Address => ALU_result_mem(7 downto 0), dataIn => regData2_mem, dataOut => dataOut);

    Mux3: Mux port map (muxIn0 => PCOutPlus, muxIn1 => newAddress_mem, selector => PCSrc, muxOut => PCNext);
    
    -- Mux_PC_stall
    PCIn <= PCNext when PCWrite = '1' else PCOut;

    -- MEM/WB pipeline register
    MEMWB_reg: mem_wb
    port map (
        clk => clk,
        rst => rst,
        enable => mem_wb_enable,
        
        -- Data inputs from MEM stage
        ALU_result_mem_in => ALU_result_mem,  
        dataOut_mem_in    => dataOut,  
        PC_mem_in         => PC_mem,  
        PCOutPlus_mem_in  => PCOutPlus_mem,  
        multResult_mem_in => multResult_mem,  
        inst_rd_mem_in    => inst_rd_mem,  
        
        -- Control inputs from MEM stage
        WriteReg_mem_in   => WriteReg_mem,  
        ToRegister_mem_in => ToRegister_mem,  
        
        -- Data outputs to MEM stage
        ALU_result_wb_out => ALU_result_wb,  
        dataOut_wb_out    => dataOut_wb,  
        PC_wb_out         => PC_wb,  
        PCOutPlus_wb_out  => PCOutPlus_wb,  
        multResult_wb_out => multResult_wb,  
        inst_rd_wb_out    => inst_rd_wb,  
        
        -- Control outputs to MEM stage
        WriteReg_wb_out   => WriteReg_wb,  
        ToRegister_wb_out => ToRegister_wb  
        );

    MuxReg: Mux_ToRegFile port map (muxIn0 => ALU_result_wb, muxIn1 => dataOut_wb, muxIn2 => dataOut_wb, muxIn3 => PC_wb,
    muxIn4 => (others => '0'), muxIn5 => PCOutPlus_wb, muxIn6 => multResult_wb(31 downto 0), muxIn7 => multResult_wb(63 downto 32), selector => ToRegister_wb, muxOut => dataForReg);

end architecture arch_DataPath;

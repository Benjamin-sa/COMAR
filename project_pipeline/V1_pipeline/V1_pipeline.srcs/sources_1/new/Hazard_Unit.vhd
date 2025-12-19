library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Hazard_Unit is
    port (
        -- Inputs
        ID_EX_MemRead   : in std_logic;
        ID_EX_Rd        : in std_logic_vector(4 downto 0);
        IF_ID_Rs1       : in std_logic_vector(4 downto 0);
        IF_ID_Rs2       : in std_logic_vector(4 downto 0);
        
        
        -- Inputs voor Flush (uit je DataPath port map)
        PCSrc_mem       : in std_logic;
        jump_mem        : in std_logic;
        
        -- Ongebruikte inputs (moeten er staan voor compatibiliteit met je DataPath)
        rd_mem          : in std_logic_vector(4 downto 0);
        rs1_ex          : in std_logic_vector(4 downto 0);
        EX_MEM_selector : in std_logic_vector(2 downto 0);
        EX_MEM_regwrite : in std_logic;
        
        -- Outputs
        PCWrite    : out std_logic;
        IFIDWrite  : out std_logic;
        IDEXWrite  : out std_logic;
        EXMEMWrite : out std_logic;
        stall      : out std_logic;
        FlushIDEX      : out std_logic;
        FlushIFID  : out std_logic
    );
end entity Hazard_Unit;

architecture RTL of Hazard_Unit is
  --signal Flush_ID_EX : std_logic;
begin
    --FlushIFID <= '1' when (PCSrc_mem = '1' or jump_mem = '1') else '0';
    --FlushIDEX <= '1' when (PCSrc_mem = '1' or jump_mem = '1') else '0';

    process(ID_EX_MemRead, ID_EX_Rd, IF_ID_Rs1, IF_ID_Rs2, PCSrc_mem, jump_mem)
    begin
        -- Defaults
        PCWrite    <= '1';
        IFIDWrite  <= '1';
        IDEXWrite  <= '1'; -- Altijd 1, zodat NOP erin kan!
        EXMEMWrite <= '1';
        stall      <= '0';
        FlushIDEX  <= '0';
        FlushIFID  <= '0';
        
        
        if (PCSrc_mem = '1' or jump_mem = '1') then
            -- Flush logica
            FlushIDEX <= '1';
            FlushIFID <= '1';
            
        elsif (ID_EX_MemRead = '1' and ID_EX_Rd /= "00000" and
              (ID_EX_Rd = IF_ID_Rs1 or ID_EX_Rd = IF_ID_Rs2)) then
            -- LOAD-USE STALL
            PCWrite   <= '0';
            IFIDWrite <= '0';
            stall     <= '1'; -- Dit activeert NOP in DataPath
        end if;
    end process;
end architecture RTL;
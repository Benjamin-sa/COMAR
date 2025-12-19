library ieee;
use IEEE.STD_LOGIC_1164.ALL;

entity if_id is
    port (
        clk         : in  std_logic;
        rst         : in  std_logic;
        enable      : in  std_logic;
        
        -- inputs from IF stage
        PC_if_in            : in  std_logic_vector(31 downto 0);
        instruction_if_in   : in  std_logic_vector(31 downto 0);
        PCOutPlus_if_in     : in  std_logic_vector(31 downto 0);
        writeReg_if_in      : in std_logic;
        pipeline_flush      : in std_logic;
        

        -- outputs to ID stage
        PC_id_out           : out std_logic_vector(31 downto 0);
        instruction_id_out  : out std_logic_vector(31 downto 0);
        PCOutPlus_id_out     : out  std_logic_vector(31 downto 0);
        writeReg_id_out     : out std_logic
    );
end entity if_id;

architecture RTL of if_id is
begin
    process(clk)
    begin
        if rising_edge(clk) then
            -- 1. Harde Reset (Asynchroon of synchroon, hier synchroon op de klok)
            if rst = '0' then
                PC_id_out          <= (others => '0');
                instruction_id_out <= X"00000013"; -- Reset naar NOP
                PCOutPlus_id_out   <= (others => '0');
                writeReg_id_out    <= '0';

            -- 2. Pipeline Flush (Bij een Jump of Branch)
            elsif pipeline_flush = '1' then
                -- Belangrijk: Bij een flush wissen we de instructie naar een NOP, 
                -- maar de PC waarden maken meestal minder uit.
                instruction_id_out <= X"00000013"; -- addi x0, x0, 0
                writeReg_id_out    <= '0';         -- Zorg dat er niets geschreven wordt

            -- 3. Normale werking met Enable (voor Stalls)
            elsif enable = '1' then
                PC_id_out          <= PC_if_in;
                instruction_id_out <= instruction_if_in;
                PCOutPlus_id_out   <= PCOutPlus_if_in;
                writeReg_id_out    <= writeReg_if_in;
            end if;
        end if;
    end process;
end architecture RTL;

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

        -- outputs to ID stage
        PC_id_out           : out std_logic_vector(31 downto 0);
        instruction_id_out  : out std_logic_vector(31 downto 0);
        PCOutPlus_id_out     : out  std_logic_vector(31 downto 0)
    );
end entity if_id;

architecture RTL of if_id is
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '0' then
                PC_id_out    <= (others => '0');
                instruction_id_out <= (others => '0');
                PCOutPlus_id_out <= (others => '0');
    
            elsif enable = '1' then
                PC_id_out    <= PC_if_in;
                instruction_id_out <= instruction_if_in;
                PCOutPlus_id_out <= PCOutPlus_if_in;
            end if;
        end if;
    end process;
end architecture RTL;

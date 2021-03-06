library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity FSM is
	Port (tframe : in std_logic; --señal vsinc del vga, está a 0 un clk al refrescar terminar una pantalla	
	mov : in  STD_LOGIC_VECTOR (1 downto 0); --movimiento procedente del teclado
--       	FSM_Plotter : out  STD_LOGIC_VECTOR (1 downto 0); --información que se enviará al plotter y a la musica
       	bdir : out  STD_LOGIC_VECTOR (7 downto 0);
       	bdata : in  STD_LOGIC_VECTOR (4 downto 0));
end FSM;

architecture Behavioral of FSM is
    type mi_estado is (Inicio, Reposo, Up, Down, Izq, Der,  Analisis, KO, Avanza, Sumar, OK); --estados
    signal estado,p_estado: mi_estado;
    signal cuenta, pcuenta: unsigned; --contador
    signal flag: std_logic; --para evitar que cuente de más
    signal Dserp,p_Dserp,Dcola,p_Dcola : unsigned(7 downto 0); --registros de direcciones
    signal p_casilla : std_logic_vector (3 downto 0); --registro para analizar las casillas
    signal RS :std_logic_vector (4 downto 0); --bms bit de inicio, 3o y 2o mov cola, 1o y 0 mov cabeza
begin
    contcomb: process (tframe, cuenta)
   	 begin
   		 if (tframe='0' and flag='0') then
   			 flag<='1';
   			 p_cuenta<=cuenta+1;
   		 elsif (tframe='0' and flag='1') then
   			 flag<='1';
   			 p_cuenta<=cuenta;
   		 else
   			 flag<='0';
   			 p_cuenta<=cuenta;
   		 end if;
   	 end process;
    
    estadosync: process (clk, reset)
   	 begin
   		 if (reset='1')then
   			 estado<=Inicio;
   			 cuenta<=(others=>'0');
   		 elsif (rising_edge(clk) and reset='0') then
   			 estado<=p_estado;
   			 cuenta<=p_cuenta;
   		 end if;
   	 end process;
    
    comb: process(estado)
   	 begin
   		 case estado is
   			 when inicio =>
			 when reposo=>
   			 if(mov = "00") then --Arriba - Up
   				 p_estado <= Up;
   			 elsif (mov = "11") then --Abajo - Down
   				 p_estado <= Down;
   			 elsif (mov = "01") then --Izquierda - Izq
   				 p_estado <= Izq;
   			 elsif (mov = "10") then --Derecha - Der
   				 p_estado <= Der;
   			 else
   				 p_estado <= estado;
   			 end if;
   			 when Up=>
   				 RS (1 downto 0) <= "00"; --Se salva en el RS el mov
   				 if (tframe = CNT) then
   					 p_estado <= analisis;
   				 else
   					 p_estado <= estado;
   				 end if;
   			 when Down =>
   				 RS (1 downto 0) <= "11"; --Se salva en el RS el mov
   				 if (tframe = CNT) then
   					 p_estado <= analisis;
   				 else
   					 p_estado <= estado;
   				 end if;
   			 when Izq =>
   				 RS (1 downto 0) <= "01"; --Se salva en el RS el mov
   				 if (tframe = CNT) then
   					 p_estado <= analisis;
   				 else
   					 p_estado <= estado;
   				 end if;
   			 When Der =>
   				 RS (1 downto 0) <= "10"; --Se salva en el RS el mov
   				 if (tframe = CNT) then
   					 p_estado <= analisis;
   				 else
   					 p_estado <= estado;
   				 end if;
   			 when analisis=>
				 case RS(1 downto 0) is
					 when "00" =>
						 p_Dserp <= Dserp - 16;
					 when "01" =>
						 p_Dserp <= Dserp + 1;		
					 when "10" =>
						 p_Dserp <= Dserp - 1;
					 when "11" =>
						 p_Dserp <= Dserp + 16;
	    				 when others =>
	    					 p_Dserp <= Dserp;
   				 end case;
   			 when avanza=>
   			 when sumar=>
   			 when OK=>
   			 when KO=>
   				 p_estado <= reposo;
   		 end case;
   	 end process;

end Behavioral;

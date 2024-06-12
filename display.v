module display(output reg [6:0] digito0, // digito da direita
  output reg [6:0] digito1,
  output reg [6:0] digito2,
  input [9:0] valor
);
reg [20:0] temp_val = 42'b0;
reg [9:0] copia_valor;
reg [11:0] bcd_val;

integer i;
integer j;

always@(valor) begin
		copia_valor = valor;
		temp_val = 21'b0;
      bcd_val = 12'b0;

    // duplo dab
    for(i = 0; i < 10; i = i +1)begin
      if (bcd_val[3:0] > 4) begin 
        bcd_val[3:0] = bcd_val[3:0] + 3;
      end
      if (bcd_val[7:4] > 4) begin 
        bcd_val[7:4] = bcd_val[7:4] + 3;
      end
      if (bcd_val[11:8] > 4) begin 
        bcd_val[11:8] = bcd_val[11:8] + 3;
      end
      

      bcd_val = bcd_val << 1;
      bcd_val[0] = copia_valor[9];
      copia_valor = copia_valor << 1;
    end

    for(j = 0; j < 3; j = j + 1) begin
      temp_val = temp_val << 7; 
      case(bcd_val[3: 0])
        0: temp_val[6:0] = 'b1000000;
        1: temp_val[6:0] = 'b1111001;
        2: temp_val[6:0] = 'b0100100;
        3: temp_val[6:0] = 'b0110000;
        4: temp_val[6:0] = 'b0011001;
        5: temp_val[6:0] = 'b0010010;
        6: temp_val[6:0] = 'b0000010;
        7: temp_val[6:0] = 'b1111000;
        8: temp_val[6:0] = 'b0000000; 
        9: temp_val[6:0] = 'b0010000;
		  
		  default:
			  temp_val[6:0] = -1;
      endcase 
		bcd_val = bcd_val >> 4;

    end
		  
		  if (temp_val[6:0] == 'b1000000) begin
				temp_val[6:0] = -1;
				if(temp_val[13:7] == 'b1000000) begin
					temp_val[13:7] = -1;
				end
		  end
		
        digito0 = temp_val[20:14]; 
        digito1 = temp_val[13:7];
        digito2 = temp_val[6:0];
end
endmodule
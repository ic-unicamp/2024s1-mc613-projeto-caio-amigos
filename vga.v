module vga(
  input clk,
  input [7:0]red,
  input [7:0]green,
  input [7:0]blue,

  output reg [7:0] VGA_R,
  output reg [7:0] VGA_G,
  output reg [7:0] VGA_B,
  output VGA_CLK,
  output VGA_SYNC_N,
  output VGA_BLANK_N,
  output reg VGA_HS,
  output reg VGA_VS
  
);

  reg [1:0] h_state = 0;
  reg [1:0] v_state;
  integer HTA = 96;
  integer HTB = 48;
  integer HTC = 640;
  integer HTD = 16;

  integer VTA = 2;
  integer VTB = 33;
  integer VTC = 480;
  integer VTD = 10;

  reg h_enable = 0;
  reg [9:0] h_contador = -10'b1;
  reg [9:0] v_contador = 10'b0;


  frequency_divider fdiv(
    .clk(clk),
    .reset(reset),
	 .div(1'd2),
    .new_clk(VGA_CLK)
  );

  initial begin
    h_state = 0;
    v_state = 0;
  end

  assign VGA_SYNC_N = 0,
    VGA_BLANK_N = 1;
	
  always @(posedge VGA_CLK) begin
      VGA_R = 0;
      VGA_G = 0;
      VGA_B = 0;
      VGA_HS = 1;
      VGA_VS = 1;
      h_contador = h_contador + 1;
		
      case(v_state) // movimento vertical
        0: begin
          VGA_VS = 0;
          if (v_contador == VTA)
            v_state = 1;
          end

        1:begin
          if (v_contador == VTA + VTB)
            v_state = 2;
          end
     
        2:begin
          h_enable = 1;
          if (v_contador == VTA + VTB + VTC)
            v_state = 3;
          end

        3:begin
          h_enable = 0;
          if (v_contador == VTA + VTB+ VTC + VTD) begin
            v_state = 0;
            v_contador = 0;
          end
          end
			
			default:
				v_state = 0;
        endcase

        case(h_state) // movimento horizontal
        0: begin
          VGA_HS = 0;
          if (h_contador == HTA)
            h_state = 1;
          end

        1:begin
          if (h_contador == HTA + HTB)
            h_state = 2;
          end

        2:begin
          if(h_enable) begin
            VGA_R = red;
            VGA_G = green;
            VGA_B = blue;
          end
          if (h_contador == HTA + HTB + HTC)
            h_state = 3;
          end

        3:begin
          if (h_contador == HTA + HTB+ HTC + HTD) begin
            h_state = 0;
            h_contador = -10'b1;
            v_contador = v_contador + 1;
          end
          end
			 
			default:
				h_state = 0;
      endcase
	
end

endmodule
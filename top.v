module pacman(
input clk,
input reset,
output [7:0] VGA_R,
output [7:0] VGA_G,
output [7:0] VGA_B,
output VGA_CLK, 
output VGA_SYNC_N,
output VGA_BLANK_N,
output VGA_HS,
output VGA_VS
);


wire game_clk;
frequency_divider fd(
  .clk(clk),
  .reset(reset),
  .div(26'd500000),
  .new_clk(game_clk)
);


vga driver(.clk(clk),
.reset(reset),
.red(red),
.green(green),
.blue(blue),

.VGA_R(VGA_R),
.VGA_G(VGA_G),
.VGA_B(VGA_B),
.VGA_CLK(VGA_CLK),
.VGA_SYNC_N(VGA_SYNC_N),
.VGA_BLANK_N(VGA_BLANK_N),
.VGA_HS(VGA_HS),
.VGA_VS(VGA_VS)
);
//
//
//frame_buffer fb(
//.clk(VGA_CLK),
//.w_enable(w_enable),
//.data_in(data),
//.addr0(w_address),
//.addr1(r_address),
//.out(out)
//);
//
//
//
//wire [2:0] out;
//reg [14:0] w_address = 0;
//reg w_enable = 0;


reg [14:0] r_address = 0;
reg [2:0] mem [0:19199];	

initial $readmemb("/home/ec2022/ra260469/MC613/projeto/labiritno.mem", mem);

reg [14:0] pos_labirinto = 0;
reg [3:0] pos_square =0;
reg [9:0] linha_ativa= 0;
reg [7:0] cor;
reg [9:0] coluna = 0;
reg [9:0] linha = 0;
reg [2:0] lab_state = 0;
reg [7:0] red = 0;
reg [7:0] green = 0;
reg [7:0] blue = 0;

always @(posedge VGA_CLK) begin
    if (coluna == 800) begin
        coluna = 0;
		  linha = linha + 1;
		  if (linha == 525) linha = 0;
    end else begin
    coluna = coluna + 1;
    end
end	

reg [1:0] line_count = -1;
reg [1:0] pixel_count = -1;
//reg [10:0] pos;
//wire [10:0] pos = ((linha - 36) >> 4) * 40;//((linha - 36) >> 4) << 5 + ((linha - 36) >> 4) << 3;

always @(posedge VGA_CLK) begin
	blue = 0; red = 0; green = 0;
//	pos = ((coluna - 145) >> 4) + (((linha - 36) >> 4) * 40);
	if (coluna > 144 && coluna <= 784 && linha <= 515 && linha > 35) begin
		case(mini_mapa[(((linha - 36) >> 4) * 40) + ((coluna - 145) >> 4)])
			0: blue = mem[r_address] == 3'b001 ? 250 : 0;
			1: begin red = 250; green = 250; end
			default: blue = mem[r_address] == 3'b001 ? 250 : 0;
		endcase
		

		pixel_count = pixel_count + 1;
		if(pixel_count == 3) begin 
			r_address = r_address + 1; pixel_count = -1;
			if(r_address % 160 == 0) begin 
				line_count = line_count + 1;
				if(line_count == 3) line_count = -1;
				else r_address = r_address - 160; 
			end 
		end 
	end 
	
	
	if (r_address >= 19200)
		r_address = 0; 
end

//
reg [5:0] pac_x = 20;
reg [4:0] pac_y = 15;
reg [2:0] mini_mapa [0:1199];
integer i;
initial begin
	for(i = 0; i < 1200; i = i + 1)
		mini_mapa[i] = 3'b000;
	mini_mapa[620] = 1;
end

//
//reg [14:0] prev_pac_x = 0;
//reg [14:0] prev_pac_y = 0;
//wire posicao_prev;
//assign posicao_prev = (prev_pac_y*160) + prev_pac_x + (iterador % 6) + ((iterador / 6)*160);
//integer iterador = 0;

//// gerenciar objetos
always @(posedge VGA_CLK) begin
//		P <= mem[80];
////	for (iterador = 0; iterador < 36; iterador = iterador + 1) begin
//		data <= 3'b001;
//		
////	end
	
	
end




endmodule
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

reg [15:0] w_address = 0;
reg w_enable = 0;
reg [15:0] r_address = 0;


//memory mm (
//.data(data),
//.rdaddress(r_address),
//.rdclock(VGA_CLK),
//.wraddress(w_address),
//.wrclock(VGA_CLK),
//.wren(w_enable),
//.q(out1)
//);

reg [2:0] mem [0:19199];


//reg labirinto [0:18560];
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

always @(posedge VGA_CLK) begin
	blue = mem[r_address] == 3'b001 ? 250 : 0;
	if (coluna > 144 && coluna <= 784 && linha <= 515 && linha > 35) begin
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


endmodule
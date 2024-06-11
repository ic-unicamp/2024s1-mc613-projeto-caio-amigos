module pacman(
	input clk,
	input reset,
	input direita,
	input esquerda, 
	input cima,
	input baixo,
	
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
  .div(26'd5000000),
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
reg [3:0] mini_mapa [0:1199];

initial $readmemb("/home/ec2022/ra260469/MC613/projeto/labiritno.mem", mem);
initial $readmemb("/home/ec2022/ra260469/MC613/projeto/mini_mapa.mem", mini_mapa);

reg [7:0] cor;
reg [9:0] coluna = 0;
reg [9:0] linha = 0;
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

//---------------------------- sprites ---------------------------------
//reg [15:0] bola = {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0};
//reg [15:0] super_bola = {1'b0, 1'b1, 1'b1, 1'b0, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b0, 1'b1, 1'b1, 1'b0};
reg [15:0] bola = {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0};
reg [15:0] super_bola = {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0};

reg [1:0] fantasma [0:15];
initial begin 
	fantasma[0] = 2'b00; fantasma[1] = 2'b01; fantasma[2] = 2'b01; fantasma[3] = 2'b00;
	fantasma[4] = 2'b01; fantasma[5] = 2'b01; fantasma[6] = 2'b01; fantasma[7] = 2'b01;
	fantasma[8] = 2'b10; fantasma[9] = 2'b01; fantasma[10] = 2'b01; fantasma[11] = 2'b10;
	fantasma[12] = 2'b01; fantasma[13] = 2'b00; fantasma[14] = 2'b00; fantasma[15] = 2'b01;
end

reg [15:0] pac_man;
reg [15:0] pac_man_idl = {1'b0, 1'b1, 1'b1, 1'b0, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b0, 1'b1, 1'b1, 1'b0};
reg [15:0] pac_man_esq = {1'b0, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b0, 1'b1, 1'b1, 1'b1, 1'b0, 1'b0, 1'b1, 1'b1, 1'b1};
reg [15:0] pac_man_dir = {1'b1, 1'b1, 1'b1, 1'b0, 1'b0, 1'b1, 1'b1, 1'b1, 1'b0, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b0};
reg [15:0] pac_man_cim = {1'b1, 1'b0, 1'b0, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b0, 1'b1, 1'b1, 1'b0};
reg [15:0] pac_man_bai = {1'b0, 1'b1, 1'b1, 1'b0, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b0, 1'b0, 1'b1};

reg[1:0] sprite_coluna = 0;
reg[1:0] sprite_linha = 0;
wire [3:0] sprite_pos = sprite_coluna + (sprite_linha << 2);


// ----------------------- impressao na tela -----------------------------
always @(posedge VGA_CLK) begin
	blue = 0; red = 0; green = 0;
	if (coluna > 144 && coluna <= 784 && linha <= 515 && linha > 35) begin
		case(mini_mapa[(((linha - 36) >> 4) * 40) + ((coluna - 145) >> 4)])
			0: blue = mem[r_address] == 3'b001 ? 250 : 0;
			1: blue = mem[r_address] == 3'b001 ? 250 : 0;
			2: begin
				blue = bola[sprite_pos] == 1 ? -1 : 0;
				green = bola[sprite_pos] == 1 ? -1 : 0; 
				red = bola[sprite_pos] == 1 ? -1 : 0;
				end
			3: begin
				blue = super_bola[sprite_pos] == 1 ? -1 : 0;
				green = super_bola[sprite_pos] == 1 ? -1 : 0; 
				red = super_bola[sprite_pos] == 1 ? -1 : 0;
				end
			4: begin
				green = pac_man[sprite_pos] == 1 ? -1 : 0; 
				red = pac_man[sprite_pos] == 1 ? -1 : 0;
				end
			5: begin
				red = fantasma[sprite_pos] == 1 ? -1 : 0; 
				green = fantasma[sprite_pos] == 1 ? 128 : 0;
				
				blue = fantasma[sprite_pos] == 2 ? -1 : blue;
				green = fantasma[sprite_pos] == 2 ? -1 : green; 
				red = fantasma[sprite_pos] == 2 ? -1 : red;
				end
			6: begin
				blue = fantasma[sprite_pos] == 1 ? -1 : 0; 
				green = fantasma[sprite_pos] == 1 ? -1 : 0;
				
				blue = fantasma[sprite_pos] == 2 ? -1 : blue;
				green = fantasma[sprite_pos] == 2 ? -1 : green; 
				red = fantasma[sprite_pos] == 2 ? -1 : red;
				end
			7: begin
				red = fantasma[sprite_pos] == 1 ? -1 : 0; 
				
				blue = fantasma[sprite_pos] == 2 ? -1 : blue;
				green = fantasma[sprite_pos] == 2 ? -1 : green; 
				red = fantasma[sprite_pos] == 2 ? -1 : red;
				end
			8: begin
				red = fantasma[sprite_pos] == 1 ? -1 : 0;
				green = fantasma[sprite_pos] == 1 ? 190 : 0; 
				blue = fantasma[sprite_pos] == 1 ? 200 : 0;
				
				blue = fantasma[sprite_pos] == 2 ? -1 : blue;
				green = fantasma[sprite_pos] == 2 ? -1 : green; 
				red = fantasma[sprite_pos] == 2 ? -1 : red;
				end
				
			default: blue = mem[r_address] == 3'b001 ? 250 : 0;
		endcase
		

		pixel_count = pixel_count + 1;
		if(pixel_count == 3) begin 
			sprite_coluna = sprite_coluna + 1;
			r_address = r_address + 1; pixel_count = -1;
			if(r_address % 160 == 0) begin
				line_count = line_count + 1;
				if(line_count == 3) begin
					line_count = -1;
					sprite_linha = sprite_linha + 1;
				end
				else r_address = r_address - 160; 
			end 
		end 
	end 
	
	
	if (r_address >= 19200)
		r_address = 0; 
end


// ------------------------ mover os fantasmas ---------------------
//function [6:0] distance (input [11:0] x_f, y_f, x_p, y_p);
////	wire [5:0] x_d = (x_p - x_f) > 0 ? (x_p - x_f) : (x_f - x_p);
////	wire [5:0] y_d = (y_p - y_f) > 0 ? (y_p - y_f) : (y_f - y_p);
//	begin
//	distance = ((x_p - x_f) > 0 ? (x_p - x_f) : (x_f - x_p)) + ((y_p - y_f) > 0 ? (y_p - y_f) : (y_f - y_p));
//	end
//endfunction

reg signed [11:0] red_x = 20;
reg signed [9:0] red_y = 12;
reg signed [1:0] rvx = 0, rvy = 0;
wire d_av = mini_mapa[red_x + 1 + (red_y * 40)] != 1;
wire e_av = mini_mapa[red_x - 1 + (red_y * 40)] != 1;
wire c_av = mini_mapa[red_x + ((red_y - 1) * 40)] != 1;
wire b_av = mini_mapa[red_x + ((red_y + 1) * 40)] != 1;
//wire [5:0] x_dist = (pac_x - red_x) > 0 ? (pac_x - red_x) : (red_x - pac_x);
//wire [4:0] y_dist = (pac_y - red_y) > 0 ? (pac_y - red_y) : (red_y - pac_y);
//reg [6:0] dist;

always @(posedge game_clk) begin
//	dist = distance(red_x, red_y, pac_x, pac_y);
//	if(d_av && (distance(red_x + 1, red_y, pac_x, pac_y) < dist)) begin
//		dist = distance(red_x + 1, red_y, pac_x, pac_y);
//		rvx = 1; rvy = 0;
//	end
//	else if(e_av && (distance(red_x - 1, red_y, pac_x, pac_y) < dist)) begin
//		dist = distance(red_x - 1, red_y, pac_x, pac_y);
//		rvx = -1; rvy = 0;
//	end if(c_av && (distance(red_x, red_y - 1, pac_x, pac_y) < dist)) begin
//		dist = distance(red_x, red_y - 1, pac_x, pac_y);
//		rvx = 0; rvy = -1;
//	end if(b_av && (distance(red_x, red_y + 1, pac_x, pac_y) < dist)) begin
//		dist = distance(red_x, red_y + 1, pac_x, pac_y);
//		rvx = 0; rvy = 1;
//	end
	if(c_av && (pac_y > red_y)) begin
		rvx = 0; rvy = -1;
	end else if(e_av && (pac_x < red_x)) begin
		rvx = -1; rvy = 0;
	end else if(b_av && (pac_x < red_x)) begin
		rvx = 0; rvy = 1;
	end else if(d_av && (pac_x > red_x)) begin
		rvx = 1; rvy = 0;
	end
	
//	mini_mapa[red_x + (red_y * 40)] = 0;
//	red_x = red_x + rvx; red_y = red_y + rvy;
//	mini_mapa[red_x + (red_y * 40)] = 7;
end



// ------------------------- mover o pacman ------------------------
reg signed [11:0] pac_x = 20;
reg signed [9:0] pac_y = 17;
reg signed [1:0] vx = 0, fvx = 0;
reg signed [1:0] vy = 0, fvy = 0;
reg [3:0] state = 0;
reg waka = 0;

always @(posedge game_clk) begin
	mini_mapa[red_x + (red_y * 40)] = 0;
	red_x = red_x + rvx; red_y = red_y + rvy;
	mini_mapa[red_x + (red_y * 40)] = 7;
	


	waka = ~waka;
	if(waka) pac_man = pac_man_idl;
	else begin 
		if(vx == 1) pac_man = pac_man_dir;
		else if(vx == -1) pac_man = pac_man_esq;
		else if(vy == 1) pac_man = pac_man_cim;
		else if(vy == -1) pac_man = pac_man_bai;
	end
	
	if(mini_mapa[pac_x + vx + ((pac_y + vy) * 40)] != 1) begin
		mini_mapa[pac_x + (pac_y * 40)] = 0;
		pac_x = pac_x + vx;
		pac_y = pac_y + vy;
		mini_mapa[pac_x + (pac_y * 40)] = 4;
	end
	vx = fvx; vy = fvy;
		
	case (state)
	0: begin
		if(~direita) begin state = 1; end
		else if(~esquerda) begin state = 2; end
		else if(~baixo) begin state = 3; end
		else if(~cima) begin state = 4; end
		end

	1: begin 
		if(mini_mapa[pac_x + 1 + ((pac_y) * 40)] != 1) begin
			vx = 1; vy = 0;
			fvx = 1; fvy = 0;
		end else if(mini_mapa[pac_x + vx + 1 + ((pac_y + vy) * 40)] != 1) begin
			fvx = 1; vy = 0;
		end
		state = 0;
		end
	
	2: begin 
		if(mini_mapa[pac_x - 1 + ((pac_y) * 40)] != 1) begin
			vx = -1; vy = 0;
			fvx = -1; fvy = 0;
		end else if(mini_mapa[pac_x + vx - 1 + ((pac_y + vy) * 40)] != 1) begin
			fvx = -1; fvy = 0;
		end
		state = 0;
		end
		
	3: begin 
		if(mini_mapa[pac_x + ((pac_y + 1) * 40)] != 1) begin
			vx = 0; vy = 1;
			fvx = 0; fvy = 1;
		end else if(mini_mapa[pac_x + vx + ((pac_y + vy + 1) * 40)] != 1) begin
			fvx = 0; fvy = 1;
		end
		state = 0;
		end
		
	4: begin 
		if(mini_mapa[pac_x + ((pac_y - 1) * 40)] != 1) begin
			vx = 0; vy = -1;
			fvx = 0; fvy = -1;
		end else if(mini_mapa[pac_x + vx + ((pac_y + vy - 1) * 40)] != 1) begin
			fvx = 0; fvy = -1;
		end
		state = 0;
		end
		
endcase
end



endmodule
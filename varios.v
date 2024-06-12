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
	output VGA_VS,
	
	output [6:0] HEX0,
	output [6:0] HEX1,
	output [6:0] HEX2,
	output [6:0] HEX3,
	output [6:0] HEX4,
	output [6:0] HEX5
);


wire game_clk;
frequency_divider fd(
  .clk(clk),
  .reset(reset),
  .div(26'd5000000),
  .new_clk(game_clk)
);

wire ghost_clk;
frequency_divider fd2(
  .clk(clk),
  .reset(reset),
  .div(26'd500000),
  .new_clk(ghost_clk)
);


vga driver(.clk(clk),
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


display display_atual (.digito0(HEX0),
                .digito1(HEX1),
                .digito2(HEX2),
                .valor(placar_atual) 
);

display display_maximo (.digito0(HEX3), 
                .digito1(HEX4),
                .digito2(HEX5),
                .valor(maximo) 
);

reg [9:0] maximo = 0;
reg [9:0] placar_atual = 0;
reg [7:0] comidas = 0;

reg [14:0] r_address = 0;
reg [2:0] mem [0:19199];	
reg [3:0] mini_mapa [0:1199];
reg [3:0] mini_mapa_og [0:1199];
reg morreu = 1;

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
integer i;
initial begin 
	$readmemb("/home/ec2022/ra260469/MC613/projeto/labiritno.mem", mem);
	$readmemb("/home/ec2022/ra260469/MC613/projeto/mini_mapa.mem", mini_mapa_og);
	
	fantasma[0] = 2'b00; fantasma[1] = 2'b01; fantasma[2] = 2'b01; fantasma[3] = 2'b00;
	fantasma[4] = 2'b01; fantasma[5] = 2'b01; fantasma[6] = 2'b01; fantasma[7] = 2'b01;
	fantasma[8] = 2'b10; fantasma[9] = 2'b01; fantasma[10] = 2'b01; fantasma[11] = 2'b10;
	fantasma[12] = 2'b01; fantasma[13] = 2'b00; fantasma[14] = 2'b00; fantasma[15] = 2'b01;
	for(i = 0; i < 1200; i = i + 1) begin
		mini_mapa[i] <= mini_mapa_og[i];
	end
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

wire [1:0] fant_pos = fantasma[sprite_pos];
wire [2:0] print_pos = mem[r_address];

// ----------------------- impressao na tela -----------------------------
always @(posedge VGA_CLK) begin
	blue = 0; red = 0; green = 0;
	if (coluna > 144 && coluna <= 784 && linha <= 515 && linha > 35) begin
		case(mini_mapa[(((linha - 36) >> 4) * 40) + ((coluna - 145) >> 4)])
			0: blue = print_pos == 3'b001 ? 250 : 0;
			1: blue = print_pos == 3'b001 ? 250 : 0;
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
				red = fant_pos == 1 ? -1 : 0; 
				green = fant_pos == 1 ? 128 : 0;
				
				blue = fant_pos == 2 ? -1 : blue;
				green = fant_pos == 2 ? -1 : green; 
				red = fant_pos == 2 ? -1 : red;
				end
			6: begin
				blue = fant_pos == 1 ? -1 : 0; 
				green = fant_pos == 1 ? -1 : 0;
				
				blue = fant_pos == 2 ? -1 : blue;
				green = fant_pos == 2 ? -1 : green; 
				red = fant_pos == 2 ? -1 : red;
				end
			7: begin
				red = fant_pos == 1 ? -1 : 0; 
				
				blue = fant_pos == 2 ? -1 : blue;
				green = fant_pos == 2 ? -1 : green; 
				red = fant_pos == 2 ? -1 : red;
				end
			8: begin
				red = fant_pos == 1 ? -1 : 0;
				green = fant_pos == 1 ? 190 : 0; 
				blue = fant_pos == 1 ? 200 : 0;
				
				blue = fant_pos == 2 ? -1 : blue;
				green = fant_pos == 2 ? -1 : green; 
				red = fant_pos == 2 ? -1 : red;
				end
				
			default: blue = print_pos == 3'b001 ? 250 : 0;
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
reg signed [11:0] red_x = 20;
reg signed [9:0] red_y = 11;
reg signed [1:0] rvx = 0, rvy = 0;
wire rd_av = mini_mapa[red_x + 1 + ((red_y << 5) + (red_y << 3))] != 4'b0001;
wire re_av = mini_mapa[red_x - 1 + ((red_y << 5) + (red_y << 3))] != 4'b0001;
wire rc_av = mini_mapa[red_x + ((red_y - 1) * 40)] != 4'b0001;
wire rb_av = mini_mapa[red_x + ((red_y + 1) * 40)] != 4'b0001;
reg [3:0] antes_r = 4'b0000;


reg signed [11:0] pink_x = 20;
reg signed [9:0] pink_y = 12;
reg signed [1:0] pvx = 0, pvy = 0;
reg [3:0] antes_p = 4'b0000;

wire pd_av = mini_mapa[pink_x + 1 + ((pink_y << 5) + (pink_y << 3))] != 4'b0001;
wire pe_av = mini_mapa[pink_x - 1 + ((pink_y << 5) + (pink_y << 3))] != 4'b0001;
wire pc_av = mini_mapa[pink_x + ((pink_y - 1) * 40)] != 4'b0001;
wire pb_av = mini_mapa[pink_x + ((pink_y + 1) * 40)] != 4'b0001;
wire p_target_x = vx != 0 ? pac_x + (4 * vx) : pac_x;
wire p_target_y = vy != 0 ? pac_y + (4 * vy) : pac_y;


// ------------------------- mover o pacman ------------------------
reg signed [11:0] pac_x = 15;
reg signed [9:0] pac_y = 17;
reg signed [1:0] vx = 0, fvx = 0;
reg signed [1:0] vy = 0, fvy = 0;
reg [3:0] state = 0;
reg waka = 0;

wire [3:0] next_el = mini_mapa[(pac_x + vx) + ((pac_y + vy) * 40)];

always @(negedge game_clk) begin
	if(!reset || !morreu) begin
		vx = 0; vy = 0; fvx = 0; fvy = 0;
		pac_man = pac_man_idl;
		pac_x = 15; pac_y = 17; 
		placar_atual = 0; comidas = 0;
	end else begin
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
			fvx = 1; fvy = 0;
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
	
	waka = ~waka;
	if(waka) pac_man = pac_man_idl;
	else begin 
		if(vx == 1) pac_man = pac_man_dir;
		else if(vx == -1) pac_man = pac_man_esq;
		else if(vy == 1) pac_man = pac_man_cim;
		else if(vy == -1) pac_man = pac_man_bai;
	end
	
	if(next_el == 2) begin
		placar_atual = placar_atual + 2; comidas = comidas + 1;
	end else if(next_el == 3) begin
		placar_atual = placar_atual + 40; comidas = comidas + 1;
	end
	maximo = placar_atual > maximo ? placar_atual : maximo;
	
	if(next_el != 1) begin
		if (pac_x + vx + ((pac_y + vy) * 40) == 594 && (vx == 1)) pac_x = 5;
		if (pac_x + vx + ((pac_y + vy) * 40) == 565 && (vx == -1)) pac_x = 34;

		pac_x = pac_x + vx;
		pac_y = pac_y + vy;
	end
	end
end


//---------------------------------always do vermelho ---------------------------------------
always @(negedge game_clk) begin
	if(!reset || !morreu) begin
		rvx <= 0; rvy <= 0;
		red_x <= 20; red_y <= 11;
		antes_r <= 4'b0000;
		
		pvx <= 0; pvy <= 0;
		pink_x <= 20; pink_y <= 11;
		antes_p <= 4'b0000;
	end else begin
		if(vx == 0 && vy == 0) begin
		rvx <= 0; rvy <= 0;
	end else if((rvy != 1) && rc_av && (pac_y < red_y)) begin
		rvx <= 0; rvy <= -1;
	end else if((rvx != 1) && re_av && (pac_x < red_x)) begin
		rvx <= -1; rvy <= 0;
	end else if((rvy != -1) && rb_av && (pac_y > red_y)) begin
		rvx <= 0; rvy <= 1;
	end else if((rvx != -1) && rd_av && (pac_x > red_x)) begin
		rvx <= 1; rvy <= 0;
	end
	else begin
		if ((rvy != 1) && rc_av) begin rvx <= 0; rvy <= -1;end
		else if ((rvx != 1) && re_av) begin rvx <= -1; rvy <= 0;end
		else if ((rvy != -1) && rb_av) begin rvx <= 0; rvy <= 1;end
		else if ((rvx != -1) && rd_av) begin rvx <= 1; rvy <= 0;end
	end
	
	
	if ((red_x + (red_y * 40) == 593) && (rvx != -1)) begin
		red_x <= 5 + rvx; 
	end else if ((red_x + (red_y * 40) == 566) && (rvx != 1)) begin
		red_x <= 34 + rvx;
	end else begin
		red_x = red_x + rvx; red_y = red_y + rvy;
		if (mini_mapa[red_x + (red_y * 40)] == 4'b0010) antes_r <= 4'b0010;
		else if (mini_mapa[red_x + (red_y * 40)] == 4'b0011) antes_r <= 4'b0011;
		else antes_r <= 4'b0000;
	end
	
	if(placar_atual <= 50) begin
		pvx <= 0; pvy <= 0;
	end else
	if((pvy != 1) && pc_av && (p_target_y < pink_y)) begin
		pvx <= 0; pvy <= -1;
	end else if((pvx != 1) && pe_av && (p_target_x < pink_x)) begin
		pvx <= -1; pvy <= 0;
	end else if((pvy != -1) && pb_av && (p_target_y > pink_y)) begin
		pvx <= 0; pvy <= 1;
	end else if((pvx != -1) && pd_av && (p_target_x > pink_x)) begin
		pvx <= 1; pvy <= 0;
	end
	else begin
		if ((pvy != 1) && pc_av) begin pvx <= 0; pvy <= -1;end
		else if ((pvx != 1) && pe_av) begin pvx <= -1; pvy <= 0;end
		else if ((pvy != -1) && pb_av) begin pvx <= 0; pvy <= 1;end
		else if ((pvx != -1) && pd_av) begin pvx <= 1; pvy <= 0;end
	end
	
	if ((pink_x + (pink_y * 40) == 594) && (pvx != -1)) begin
		pink_x <= 5 + pvx;
	end else if ((pink_x + (pink_y * 40) == 566) && (pvx != 1)) begin
		pink_x <= 34 + pvx;
	end else begin
		pink_x = pink_x + pvx; pink_y = pink_y + pvy;
		if (mini_mapa[pink_x + (pink_y * 40)] == 4'b0010) antes_p <= 4'b0010;
		else if (mini_mapa[pink_x + (pink_y * 40)] == 4'b0011) antes_p <= 4'b0011;
		else antes_p <= 4'b0000;
	end
	end
end




//---------------------------------always do rosa---------------------------------------------
//always @(negedge game_clk) begin
//	if(!reset || !morreu) begin
//		pvx <= 0; pvy <= 0;
//		pink_x <= 20; pink_y <= 11;
//		antes_p <= 4'b0000;
//	end else begin
//	if(placar_atual <= 50) begin
//		pvx <= 0; pvy <= 0;
//	end else
//	if((pvy != 1) && pc_av && (p_target_y < pink_y)) begin
//		pvx <= 0; pvy <= -1;
//	end else if((pvx != 1) && pe_av && (p_target_x < pink_x)) begin
//		pvx <= -1; pvy <= 0;
//	end else if((pvy != -1) && pb_av && (p_target_y > pink_y)) begin
//		pvx <= 0; pvy <= 1;
//	end else if((pvx != -1) && pd_av && (p_target_x > pink_x)) begin
//		pvx <= 1; pvy <= 0;
//	end
//	else begin
//		if ((pvy != 1) && pc_av) begin pvx <= 0; pvy <= -1;end
//		else if ((pvx != 1) && pe_av) begin pvx <= -1; pvy <= 0;end
//		else if ((pvy != -1) && pb_av) begin pvx <= 0; pvy <= 1;end
//		else if ((pvx != -1) && pd_av) begin pvx <= 1; pvy <= 0;end
//	end
//	
//	if ((pink_x + (pink_y * 40) == 594) && (pvx != -1)) begin
//		pink_x <= 5 + pvx;
//	end else if ((pink_x + (pink_y * 40) == 566) && (pvx != 1)) begin
//		pink_x <= 34 + pvx;
//	end else begin
//		pink_x = pink_x + pvx; pink_y = pink_y + pvy;
//		if (mini_mapa[pink_x + (pink_y * 40)] == 4'b0010) antes_p <= 4'b0010;
//		else if (mini_mapa[pink_x + (pink_y * 40)] == 4'b0011) antes_p <= 4'b0011;
//		else antes_p <= 4'b0000;
//	end
//	end
//end



 
// ---------------------------- passar os elementos moveis pro minimapa ----------------------------
always @(posedge game_clk) begin
	if(!reset || !morreu) begin
		morreu = 1;
		for(i = 0; i < 1200; i = i + 1) begin
			mini_mapa[i] <= mini_mapa_og[i];
		end
	end 
else begin
	mini_mapa[(red_x - rvx) + ((red_y - rvy) * 40)] = antes_r;
	mini_mapa[red_x + (red_y * 40)] = 4'b0111;
	if(pac_x == red_x && pac_y == red_y) begin
		morreu = 0;
	end 
	
	
	mini_mapa[(pink_x - pvx) + ((pink_y - pvy) * 40)] = antes_p;
	mini_mapa[pink_x + (pink_y * 40)] = 4'b0111;
	if(pac_x == pink_x && pac_y == pink_y) begin
		morreu = 0;
	end 
	
//-------------- parte do pacman -----------------------------------------------
	mini_mapa[(pac_x - vx) + ((pac_y - vy) * 40)] = 0;
	mini_mapa[pac_x + (pac_y * 40)] = 4;
	
	if(comidas == 222) begin
		morreu = 0;
	end else if(pac_x == red_x && pac_y == red_y) begin
		morreu = 0;
	end 
end
end



endmodule
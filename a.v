reg signed [11:0] pink_x = 20;
reg signed [9:0] pink_y = 11;
reg signed [1:0] pvx = 0, pvy = 0;
reg [3:0] antes_p = 4'b0000;

wire pd_av = mini_mapa[pink_x + 1 + (pink_y * 40)] != 4'b0001 ? 1:0;
wire pe_av = mini_mapa[pink_x - 1 + (pink_y * 40)] != 4'b0001 ? 1:0;
wire pc_av = mini_mapa[pink_x + ((pink_y - 1) * 40)] != 4'b0001 ? 1:0;
wire pb_av = mini_mapa[pink_x + ((pink_y + 1) * 40)] != 4'b0001 ? 1:0;
wire p_target_x = vx != 0 ? pac_x + (4 * vx) : pac_x
wire p_target_y = vy != 0 ? pac_y + (4 * vy) : pac_y

if((pvy != 1) && pc_av && (p_target_y < pink_y)) begin
		pvx = 0; pvy = -1;
	end else if((pvx != 1) && pe_av && (p_target_x < pink_x)) begin
		pvx = -1; pvy = 0;
	end else if((pvy != -1) && pb_av && (p_target_y > pink_y)) begin
		pvx = 0; pvy = 1;
	end else if((pvx != -1) && pd_av && (p_target_x > pink_x)) begin
		pvx = 1; pvy = 0;
	end
	else begin
		if ((pvy != 1) && pc_av) begin pvx = 0; pvy = -1;end
		else if ((pvx != 1) && pe_av) begin pvx = -1; pvy = 0;end
		else if ((pvy != -1) && pb_av) begin pvx = 0; pvy = 1;end
		else if ((pvx != -1) && pd_av) begin pvx = 1; pvy = 0;end
	end
	
	
	mini_mapa[pink_x + (pink_y * 40)] = antes_p;
	if ((pink_x + (pink_y * 40) == 594) && (pvx != -1)) begin
		pink_x = 5;
		pink_x = pink_x + pvx; pink_y = pink_y + pvy;
	end else if ((pink_x + (pink_y * 40) == 566) && (pvx != 1)) begin
		pink_x = 34;
		pink_x = pink_x + pvx; pink_y = pink_y + pvy;
	end else begin
		pink_x = pink_x + pvx; pink_y = pink_y + pvy;
		if (mini_mapa[pink_x + (pink_y * 40)] == 4'b0010) antes_p = 4'b0010;
		else if (mini_mapa[pink_x + (pink_y * 40)] == 4'b0011) antes_p = 4'b0011;
		else antes_p = 4'b0000;
	end
	mini_mapa[pink_x + (pink_y * 40)] = 4'b0111;
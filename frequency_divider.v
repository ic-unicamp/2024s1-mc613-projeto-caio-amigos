module frequency_divider(
  input clk,
  input reset,
  input [25:0] div,
  output reg new_clk
);
reg [25:0] count;
initial begin
	new_clk = 0;
    count = 0;
end

always @(posedge clk) begin
  if(count == div) begin 
    count <= 0; 
    new_clk <= ~new_clk; 
    end
  else begin 
    count <= count + 1; 
    end
end
endmodule
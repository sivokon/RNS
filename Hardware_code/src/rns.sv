`include "common.sv"

module convertor_int_to_rns
(
    input  [31:0]  int_number,
    output [31:0]  rns
);

assign rns[7:0] =   (int_number[31] == 1 ? int_number[31:0] - `INT_RNS_DELTA : int_number[31:0]) % `B0;
assign rns[15:8] =  (int_number[31] == 1 ? int_number[31:0] - `INT_RNS_DELTA : int_number[31:0]) % `B1;
assign rns[23:16] = (int_number[31] == 1 ? int_number[31:0] - `INT_RNS_DELTA : int_number[31:0]) % `B2;
assign rns[31:24] = (int_number[31] == 1 ? int_number[31:0] - `INT_RNS_DELTA : int_number[31:0]) % `B3;
    
endmodule



module convertor_rns_to_int
(
    input  [31:0]  rns,
    output [31:0]  int_number
);

reg [45:0] aa0 = 32'd3021585941;
reg [45:0] aa1 = 32'd1099363434;
reg [45:0] aa2 = 32'd1663315003;
reg [45:0] aa3 = 32'd952860257;
reg [45:0] s = 32'd3368562317;
wire [31:0] temp;

assign temp = (aa0*{1'b0,rns[7:0]} + aa1*{1'b0,rns[15:8]} + aa2*{1'b0,rns[23:16]} + aa3*{1'b0,rns[31:24]}) % (s);
assign int_number = temp >= `RNS_MIDDLE_POINT ? temp + `INT_RNS_DELTA : temp;
    
endmodule
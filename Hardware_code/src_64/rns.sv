`include "common.sv"

module convertor_int_to_rns_64
(
    input  [63:0]  int_number,
    output [64:0]  rns
);

assign rns[ 0:0 ] = (int_number[63] == 1 ? int_number[63:0] - 64'd`INT_RNS_DELTA_64 : int_number[63:0]) % `B0;
assign rns[ 8:1 ] = (int_number[63] == 1 ? int_number[63:0] - 64'd`INT_RNS_DELTA_64 : int_number[63:0]) % `B1;
assign rns[16:9 ] = (int_number[63] == 1 ? int_number[63:0] - 64'd`INT_RNS_DELTA_64 : int_number[63:0]) % `B2;
assign rns[24:17] = (int_number[63] == 1 ? int_number[63:0] - 64'd`INT_RNS_DELTA_64 : int_number[63:0]) % `B3;
assign rns[32:25] = (int_number[63] == 1 ? int_number[63:0] - 64'd`INT_RNS_DELTA_64 : int_number[63:0]) % `B4;
assign rns[40:33] = (int_number[63] == 1 ? int_number[63:0] - 64'd`INT_RNS_DELTA_64 : int_number[63:0]) % `B5;
assign rns[48:41] = (int_number[63] == 1 ? int_number[63:0] - 64'd`INT_RNS_DELTA_64 : int_number[63:0]) % `B6;
assign rns[56:49] = (int_number[63] == 1 ? int_number[63:0] - 64'd`INT_RNS_DELTA_64 : int_number[63:0]) % `B7;
assign rns[64:57] = (int_number[63] == 1 ? int_number[63:0] - 64'd`INT_RNS_DELTA_64 : int_number[63:0]) % `B8;
    
endmodule



module convertor_rns_to_int_64
(
    input  [64:0]  rns,
    output [63:0]  int_number
);

reg [76:0] aa0 = 64'd`A0;
reg [76:0] aa1 = 64'd`A1;
reg [76:0] aa2 = 64'd`A2;
reg [76:0] aa3 = 64'd`A3;
reg [76:0] aa4 = 64'd`A4;
reg [76:0] aa5 = 64'd`A5;
reg [76:0] aa6 = 64'd`A6;
reg [76:0] aa7 = 64'd`A7;
reg [76:0] aa8 = 64'd`A8;
reg [76:0] s = 64'd`MAX_NUM_64;
wire [63:0] temp;

assign temp = (aa0*{1'b0,rns[ 0:0 ]} +
               aa1*{1'b0,rns[ 8:1 ]} +
               aa2*{1'b0,rns[16:9 ]} +
               aa3*{1'b0,rns[24:17]} +
               aa4*{1'b0,rns[32:25]} +
               aa5*{1'b0,rns[40:33]} +
               aa6*{1'b0,rns[48:41]} +
               aa7*{1'b0,rns[56:49]} +
               aa8*{1'b0,rns[64:57]}) % (s);
assign int_number = temp >= 64'd`RNS_MIDDLE_POINT_64 ? temp + 64'd`INT_RNS_DELTA_64 : temp;
    
endmodule
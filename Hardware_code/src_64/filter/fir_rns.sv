`include "common.sv"

module fir_rns_64 #(n=100,signalLength=1000) (clk, reset, addr, x_rns, operation, y_rns, done);
  input             clk;
  input             reset;
  input      [31:0] addr;
  input      [64:0] x_rns;
  input      [ 1:0] operation;
  output reg [64:0] y_rns;
  output reg        done;
  
  logic      [64:0] coefsLut_rns [n-1:0];
  reg        [64:0] inputs  [signalLength-1+n-1:0];
  reg        [64:0] outputs [signalLength-1:0];
  reg        [31:0] i; //calulationCounter;
  reg        [31:0] j; //signalCounter;
  reg        [64:0] acc;
  reg        [31:0] phazeCounter;
  
  reg [64:0] add_x1;
  reg [64:0] add_x2;
  reg [64:0] add_z;
  add_rns add_rns(add_x1, add_x2, add_z);

  reg [64:0] mul_x1;
  reg [64:0] mul_x2;
  reg [64:0] mul_z;
  mul_rns mul_rns(mul_x1, mul_x2, mul_z);
  
  initial $readmemb("outputCoefficients_RNS_64.txt", coefsLut_rns);
  
  integer k;
  always @(posedge clk)
  begin
    if (reset == 1) begin
        i <= 0;
        j <= 0;
        acc <= 0;
        done <= 0;
        phazeCounter <= 0;
        for (k=0; k<signalLength+n-1; k=k+1)
            inputs[k] <= 0;
        for (k=0; k<signalLength; k=k+1)
            outputs[k] <= 0;
    end
    if (operation == 2'b01)
        inputs[addr+n-1] <= x_rns;
        
    else if (operation == 2'b10 && !done) begin
        if (j == signalLength)
            done <= 1;
        else if (i == n) begin
            outputs[j] <= acc;
            acc <= 0;
            j <= j+1;
            i <= 0;
        end 
        else begin
            if (phazeCounter == 0) begin
                mul_x1 <= coefsLut_rns[n-i-1];
                mul_x2 <= inputs[i+j];
                phazeCounter <= 1;
            end
            if (phazeCounter == 1) begin
                add_x1 <= acc;
                add_x2 <= mul_z;
                phazeCounter <= 2;
            end
            if (phazeCounter == 2) begin
                acc <= add_z;
                phazeCounter <= 3;
            end
            if (phazeCounter == 3) begin
                i <= i + 1;
                phazeCounter <= 0;
            end
        end
    end
    
    else if (operation == 2'b11)
        y_rns <= outputs[addr];
  end

endmodule



module add_rns (x1, x2, z);
  input  [64:0] x1;
  input  [64:0] x2;
  output [64:0] z;

  assign z = {8'((x1[64:57] + x2[64:57]) % `B8),
              8'((x1[56:49] + x2[56:49]) % `B7),
              8'((x1[48:41] + x2[48:41]) % `B6),
              8'((x1[40:33] + x2[40:33]) % `B5),
              8'((x1[32:25] + x2[32:25]) % `B4),
              8'((x1[24:17] + x2[24:17]) % `B3),
              8'((x1[16:9 ] + x2[16:9 ]) % `B2),
              8'((x1[ 8:1 ] + x2[ 8:1 ]) % `B1),
              1'((x1[ 0:0 ] + x2[ 0:0 ]) % `B0)};
endmodule



module mul_rns (x1, x2, z);
  input  [64:0] x1;
  input  [64:0] x2;
  output [64:0] z;

  assign z = {8'((x1[64:57] * x2[64:57]) % `B8),
              8'((x1[56:49] * x2[56:49]) % `B7),
              8'((x1[48:41] * x2[48:41]) % `B6),
              8'((x1[40:33] * x2[40:33]) % `B5),
              8'((x1[32:25] * x2[32:25]) % `B4),
              8'((x1[24:17] * x2[24:17]) % `B3),
              8'((x1[16:9 ] * x2[16:9 ]) % `B2),
              8'((x1[ 8:1 ] * x2[ 8:1 ]) % `B1),
              1'((x1[ 0:0 ] * x2[ 0:0 ]) % `B0)};
endmodule
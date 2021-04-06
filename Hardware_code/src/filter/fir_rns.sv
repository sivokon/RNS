`include "common.sv"

module fir_rns #(n=100,signalLength=1000) (clk, reset, addr, x_rns, operation, y_rns, done);
  input             clk;
  input             reset;
  input      [31:0] addr;
  input      [31:0] x_rns;
  input      [1:0]  operation;
  output reg [31:0] y_rns;
  output reg        done;
  
  logic      [31:0] coefsLut_rns [n-1:0];
  reg        [31:0] inputs  [signalLength-1+n-1:0];
  reg        [31:0] outputs [signalLength-1:0];
  reg        [31:0] i; //calulationCounter;
  reg        [31:0] j; //signalCounter;
  reg        [31:0] acc;
  reg        [31:0] phazeCounter;
  
  reg [31:0] add_x1;
  reg [31:0] add_x2;
  reg [31:0] add_z;
  add_rns add_rns(add_x1, add_x2, add_z);

  reg [31:0] mul_x1;
  reg [31:0] mul_x2;
  reg [31:0] mul_z;
  mul_rns mul_rns(mul_x1, mul_x2, mul_z);
  
  initial $readmemb("outputCoefficients_RNS_32.txt", coefsLut_rns);
  
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
  input  [31:0] x1;
  input  [31:0] x2;
  output [31:0] z;

  assign z = {8'((x1[31:24] + x2[31:24]) % `B3),
              8'((x1[23:16] + x2[23:16]) % `B2),
              8'((x1[15:8 ] + x2[15:8 ]) % `B1),
              8'((x1[ 7:0 ] + x2[ 7:0 ]) % `B0)};
endmodule



module mul_rns (x1, x2, z);
  input  [31:0] x1;
  input  [31:0] x2;
  output [31:0] z;

  assign z = {8'((x1[31:24] * x2[31:24]) % `B3),
              8'((x1[23:16] * x2[23:16]) % `B2),
              8'((x1[15:8 ] * x2[15:8 ]) % `B1),
              8'((x1[ 7:0 ] * x2[ 7:0 ]) % `B0)};
endmodule
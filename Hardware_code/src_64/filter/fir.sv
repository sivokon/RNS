`include "common.sv"

module fir_64 #(coefsLength=100,signalLength=1000) (clk, reset, addr, x, operation, y, done);
  input             clk;
  input             reset;
  input      [31:0] addr;
  input      [63:0] x;
  input      [ 1:0]  operation;
  output reg [63:0] y;
  output reg        done;
  logic      [63:0] coefsLut [coefsLength-1:0];
  reg        [63:0] inputs  [signalLength-1+coefsLength-1:0];
  reg        [63:0] outputs [signalLength-1:0];
  reg        [31:0] i; //calulationCounter;
  reg        [31:0] j; //signalCounter;
  reg        [63:0] acc;
  reg        [31:0] phazeCounter;
  
  reg [63:0] add_x1;
  reg [63:0] add_x2;
  reg [63:0] add_z;
  add add(add_x1, add_x2, add_z);

  reg [63:0] mul_x1;
  reg [63:0] mul_x2;
  reg [63:0] mul_z;
  mul mul(mul_x1, mul_x2, mul_z);

  initial $readmemb("outputCoefficients_64.txt", coefsLut);
  
  integer k;
  always @(posedge clk)
  begin
    if (reset == 1) begin
        i <= 0;
        j <= 0;
        acc <= 0;
        done <= 0;
        phazeCounter <= 0;
        for (k=0; k<signalLength+coefsLength-1; k=k+1)
            inputs[k] <= 0;
        for (k=0; k<signalLength; k=k+1)
            outputs[k] <= 0;
    end
    if (operation == 2'b01)
        inputs[addr+coefsLength-1] <= x;
        
    else if (operation == 2'b10 && !done) begin
        if (j == signalLength)
            done <= 1;
        else if (i == coefsLength) begin
            outputs[j] <= acc;
            acc <= 0;
            j <= j+1;
            i <= 0;
        end 
        else begin
            if (phazeCounter == 0) begin
                mul_x1 <= coefsLut[coefsLength-i-1];
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
        y <= outputs[addr];
  end

endmodule



module add (x1, x2, z);
  input  [63:0] x1;
  input  [63:0] x2;
  output [63:0] z;

  assign z = x1 + x2;
endmodule



module mul (x1, x2, z);
  input  [63:0] x1;
  input  [63:0] x2;
  output [63:0] z;

  assign z = x1 * x2;
endmodule
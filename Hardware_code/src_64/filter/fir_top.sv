`include "common.sv"

module fir_top_64(clk, reset, regAddr, regData, done);
    input         clk;
    input         reset;
    input  [31:0] regAddr;
    output [31:0] regData;
    output        done;
    
    parameter signalCount = 10;
    parameter coefsCount = 10;
  
    reg   [63:0]  signal[0:9];  
    logic [63:0]  x;
    logic [63:0]  y;
    logic [31:0]  addr;
    logic [ 1:0]  operation;
    
    logic [64:0]  x_rns;
    logic [64:0]  y_rns;
	 
    assign regData = y;

    // fir_rns_64 #(coefsCount,signalCount) fir_rns_64
    // (
    //     .clk       ( clk       ),
    //     .reset     ( reset     ),
    //     .operation ( operation ),
    //     .addr      ( addr      ),
    //     .x_rns     ( x_rns     ),
    //     .y_rns     ( y_rns     ),
    //     .done      ( done      )
    // );
	// convertor_int_to_rns_64 convertor_int_to_rns_64(x, x_rns);
    // convertor_rns_to_int_64 convertor_rns_to_int_64(y_rns, y);

    fir_64 #(coefsCount,signalCount) fir_64
    (
        .clk       ( clk     ),
        .reset     ( reset   ),
        .addr      ( addr    ),
        .x         ( x       ),
        .operation (operation),
        .y         ( y       ),
        .done      ( done    )
    );
	
    initial $readmemb("outputSignal_64.txt", signal);
        
    always @(posedge clk)
        begin
            if (reset == 1) begin
                addr <= 0;
                operation <= 0;
                x <= 0;
            end
            else if (reset == 0 && !done && operation == 2'b00) begin 
                operation <= 2'b01;
                addr <= 0;
                x <= signal[0];
            end
            else if (reset == 0 && operation == 2'b01 && addr != signalCount) begin
                x <= signal[addr+1];
                addr <= addr+1;
            end
            else if (reset == 0 && operation == 2'b01 && addr == signalCount)
                operation <= 2'b10;
            else if (reset == 0 && done && operation == 2'b10) begin
                operation <= 2'b11;
                addr <= 0;
            end
            if (reset == 0 && done && operation == 2'b11)
                addr <= regAddr;
        end
endmodule
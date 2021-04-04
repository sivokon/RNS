module board_top(
    input             CLOCK_50,    //    Clock 50 MHz
    input    [ 1:0 ]  KEY,         //    Pushbutton[2:0]
    input    [ 16:0]  SW,          //    Toggle Switch[9:0]
	output   [ 17:0]  LEDR
);

    // wires & inputs
    parameter signalCount = 10;
    parameter n = 10;
    wire          clk;
    wire          clkIn     =  CLOCK_50;
    wire          rst_n     =  ~KEY[0];
    wire          clkEnable =  SW [0];
    wire [  3:0 ] clkDevide =  4'b0110;
    wire [  4:0 ] regAddr   =  SW [16:1];
    wire [ 17:0 ] regData;
    
    fir_top fir_top (
        .clk     ( clkIn         ),
        .reset   ( rst_n         ),
        .regAddr ( regAddr       ),
        .regData ( regData[17:1] ),
        .done    ( regData[0]    )
    );   
    
	assign LEDR[17:0] = regData[17:0];
              
endmodule
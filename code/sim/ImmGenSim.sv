module ImmGenSim ();

reg [31:0] in;
wire [31:0] out;
ImmGen u1(in, out);

initial begin
    in = 32'b0000000_11011_10001_001_11111_0000011;
    #10 in = 32'b000000011011_10001_001_11111_0000111;
    #10 in = 32'b1000000_11011_10001_001_11011_0001111;
    #10 in = 32'b1001100_11011_10001_001_11011_0001011;
    #10 in = 32'b00110001101110001001_11011_0011011;
    #10 in = 32'b10000001101110001001_11011_0011111;
    #80 $finish;
end
    
endmodule
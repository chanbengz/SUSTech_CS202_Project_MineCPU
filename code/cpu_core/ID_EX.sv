module ID_EX (
    input               clk, rst,
    input [31:0]        pc_in, data1_in, data2_in, imm_in,
    input [3:0]         inst_piece1_in,     // inst[30,14-12]
    input [4:0]         inst_piece2_in,     // inst[11-7]
    output [31:0]       pc_out, data1_out, data2_out, imm_out,
    output [3:0]        inst_piece1_out,    // inst[30,14-12]
    output [4:0]        inst_piece2_out     // inst[11-7]
);

    reg [31:0] pc = 0;
    reg [31:0] data1 = 0;
    reg [31:0] data2 = 0;
    reg [31:0] imm = 0;
    reg [4:0] inst_piece1 = 0;
    reg [3:0] inst_piece2 = 0;
    assign pc_out = pc;
    assign data1_out = data1;
    assign data2_out = data2;
    assign imm_out = imm;
    assign inst_piece1_out = inst_piece1;
    assign inst_piece2_out = inst_piece2;

    always @(posedge clk) begin
        pc <= pc_in;
        data1 <= data1_in;
        data2 <= data2_in;
        imm <= imm_in;
        inst_piece1 <= inst_piece1_in;
        inst_piece2 <= inst_piece2_in;
    end
    
endmodule
module PC (
    input              clk, rst,  // toDo: implement reset
    input              PC_Write,  // stall, 1 yes, 0 no
    input  [`DATA_WID] pc_in,
    output [`DATA_WID] pc_out
);

    reg [31:0] pc = 0;
    assign pc_out = pc;

    always @(posedge clk) begin
        pc <= (PC_Write == 1'b0) ? pc_in : pc;
    end
    
endmodule
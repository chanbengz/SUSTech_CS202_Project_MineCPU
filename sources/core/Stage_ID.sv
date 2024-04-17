`include "Const.svh"

module Stage_ID (
    input                        clk, rst,
    // signal from IF stage
    input  logic [`DATA_WID    ] pc_in,
    input  logic [`DATA_WID    ] inst,
    // signal from EX stage
    input  logic [`REGS_WID    ] ID_EX_rd, MEM_WB_rd,
    input  logic                 old_predict, old_branch, branch_result,
    input  logic [`DATA_WID    ] old_pc, old_branch_pc,
    input  logic                 ID_EX_MemRead,
    // signal from WB stage
    input  logic [`DATA_WID    ] data_WB,
    input  logic                 RegWrite,
    // signal to ID_EX reg
    output logic [`EX_CTRL_WID ] EX_ctrl,
    output logic [`MEM_CTRL_WID] MEM_ctrl,
    output logic [`WB_CTRL_WID ] WB_ctrl,
    output logic [`REGS_WID    ] rs1_out, rs2_out, rd_out,
    output logic [`DATA_WID    ] reg_data1, reg_data2, imm_out, pc_out,
    output logic                 IF_ID_Write, PC_Write,
    output logic                 predict_result,
    output logic                 predict_fail,
    // signal to IF stage
    output logic [`DATA_WID    ] new_pc,
    // signal to Memory
    output logic [`DATA_WID    ] SEPC
);

    logic [`REGS_WID] rs1, rs2, rd;
    logic stall, branch, predict, ujtype, excp;
    logic [`CTRL_WID] total_ctrl, ctrl_out;
    logic [`DATA_WID] rs1_data, rs2_data, imm;

    assign rs1 = ujtype ? 0 : inst[19:15];
    assign rs2 = inst[24:20];
    assign rd = inst[11:7];
    assign rs1_out = rs1;
    assign rs2_out = rs2;
    assign rd_out  = rd;
    assign pc_out = pc_in;
    assign ctrl_out = (stall == 1'b0) ? total_ctrl : 0;
    assign EX_ctrl  = ctrl_out[15:7];
    assign MEM_ctrl = ctrl_out[6:2];
    assign WB_ctrl  = ctrl_out[1:0];
    assign reg_data1 = rs1_data;
    assign reg_data2 = rs2_data;
    assign imm_out = imm;
    
    ImmGen immgen_inst (
        .inst,
        .imm
    );

    RegisterFile reg_inst (
        .clk,
        .rst,
        .read_reg_1(rs1),
        .read_reg_2(rs2),
        .write_reg(MEM_WB_rd),
        .write_data(data_WB),
        .RegWrite,
        .read_data_1(rs1_data),
        .read_data_2(rs2_data)
    );

    Hazard hazard_inst (
        .IF_ID_rs1(rs1),
        .IF_ID_rs2(rs2),
        .ID_EX_rd,
        .ID_EX_MemRead,
        .stall,
        .IF_ID_Write,
        .PC_Write
    );

    Control ctrl_unit (
        .inst,
        .total_ctrl,
        .branch,
        .predict,
        .ujtype,
        .excp
    );

    Branch_Predictor bp_inst (
        .clk,
        .rst,
        .branch,
        .predict,
        .rs1_data,
        .ujtype,
        .excp,
        .pc(pc_in),
        .imm,
        .old_pc,
        .old_predict,
        .old_actual(branch_result),
        .old_branch,
        .old_branch_pc,
        .target_pc(new_pc),
        .predict_result,
        .predict_fail,
        .SEPC
    );

endmodule

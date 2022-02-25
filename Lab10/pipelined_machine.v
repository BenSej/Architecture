module pipelined_machine(clk, reset);
    input        clk, reset;

    wire [31:0]  PC;
    wire [31:2]  next_PC, PC_plus4, PC_target, pc_adder_out;
    wire [31:0]  inst, memory_out;

    wire [31:0]  imm = {{ 16{inst[15]} }, inst[15:0] };  // sign-extended immediate
    wire [4:0]   rs = inst[25:21];
    wire [4:0]   rt = inst[20:16];
    wire [4:0]   rd = inst[15:11];
    wire [5:0]   opcode = inst[31:26];
    wire [5:0]   funct = inst[5:0];

    wire [4:0]   wr_regnum, wr_regnum_MW;
    wire [2:0]   ALUOp, ALUOp_MW;

    wire         RegWrite, RegWrite_MW, BEQ, BEQ_MW, ALUSrc, ALUSrc_MW, MemRead, MemRead_MW, MemWrite, MemWrite_MW, MemToReg, MemToReg_MW, RegDst, RegDst_MW;
    wire         PCSrc, zero;
    wire [31:0]  rd1_data, rd2_data, B_data, alu_out_data, alu_out, load_data, wr_data;

    wire stall = ((wr_regnum_MW == rs && rs != 0) || (wr_regnum_MW == rt && rt != 0)) && (MemRead_MW);
    wire forwardB = (rt == wr_regnum_MW) & RegWrite_MW & (wr_regnum_MW != 0);
    wire forwardA = (rs == wr_regnum_MW) & RegWrite_MW & (wr_regnum_MW != 0);
    wire [31:0] forwardB_mux_out, dataPipe_out, forwardA_mux_out;

    // DO NOT comment out or rename this module
    // or the test bench will break
    register #(30, 30'h100000) PC_reg(PC[31:2], next_PC[31:2], clk, ~stall, reset);

    assign PC[1:0] = 2'b0;  // bottom bits hard coded to 00
    adder30 next_PC_adder(pc_adder_out, PC[31:2], 30'h1);
    adder30 target_PC_adder(PC_target, PC_plus4, imm[29:0]);
    mux2v #(30) branch_mux(next_PC, PC_plus4, PC_target, PCSrc);
    assign PCSrc = BEQ & zero;

    // DO NOT comment out or rename this module
    // or the test bench will break
    instruction_memory imem(memory_out, PC[31:2]);

    mips_decode decode(ALUOp, RegWrite, BEQ, ALUSrc, MemRead, MemWrite, MemToReg, RegDst,
                      opcode, funct);

    // DO NOT comment out or rename this module
    // or the test bench will break
    regfile rf (rd1_data, rd2_data,
               rs, rt, wr_regnum_MW, wr_data,
               RegWrite_MW, clk, reset);

    mux2v #(32) imm_mux(B_data, forwardB_mux_out, imm, ALUSrc_MW);
    alu32 alu(alu_out_data, zero, ALUOp_MW, forwardA_mux_out, B_data);

    // DO NOT comment out or rename this module
    // or the test bench will break
    data_mem data_memory(load_data, alu_out, dataPipe_out, MemRead_MW, MemWrite_MW, clk, reset);

    mux2v #(32) wb_mux(wr_data, alu_out, load_data, MemToReg_MW);
    mux2v #(5) rd_mux(wr_regnum, rt, rd, RegDst);

    mux2v forwardB_mux(forwardB_mux_out, rd2_data, alu_out, forwardB);
    mux2v forwardA_mux(forwardA_mux_out, rd1_data, alu_out, forwardA);

    register instructionPipeline(inst, memory_out, clk, 1'b1, reset);
    register #(30) pcPipeline(PC_plus4, pc_adder_out, clk, 1'b1, reset);

    register #(5) regnumPipeline(wr_regnum_MW, wr_regnum, clk, 1'b1, reset);
    register writeDataPipeline(dataPipe_out, forwardB_mux_out, clk, 1'b1, reset);
    register aluDataPipeline(alu_out, alu_out_data, clk, 1'b1, reset);
    register # (3) aluOpPipeline(ALUOp_MW, ALUOp, clk, 1'b1, reset);
    register # (1) regWritePipeline(RegWrite_MW, RegWrite, clk, 1'b1, reset);
    register # (1) beqPipeline(BEQ_MW, BEQ, clk, 1'b1, reset);
    register # (1) ALUSrcPipeline(ALUSrc_MW, ALUSrc, clk, 1'b1, reset);
    register # (1) memReadPipeline(MemRead_MW, MemRead, clk, 1'b1, reset);
    register # (1) memWritePipeline(MemWrite_MW, MemWrite, clk, 1'b1, reset);
    register # (1) memToRegPipeline(MemToReg_MW, MemToReg, clk, 1'b1, reset);
    register # (1) regDstPipeline(RegDst_MW, RegDst, clk, 1'b1, reset);


endmodule // pipelined_machine
// full_machine: execute a series of MIPS instructions from an instruction cache
//
// except (output) - set to 1 when an unrecognized instruction is to be executed.
// clock   (input) - the clock signal
// reset   (input) - set to 1 to set all registers to zero, set to 0 for normal execution.

module full_machine(except, clock, reset);
    output      except;
    input       clock, reset;

    wire [31:0] inst, PC, nextPC, A, B, rtData, reg_alu_out, data_out, PC_alu_out, branch_alu_out, addmMux2_out, byte_load_out, slt_out, lui_out, mem_read_out, addm_alu_out, addm_out;
    wire [31:0] signExtender = {{16{msb}}, inst[15:0]};
    wire [31:0] zeroExtender = {{16'b0}, inst[15:0]};
    wire [4:0] W_addr;
    wire [2:0] alu_op;
    wire [1:0] control_type, alu_src2;
    wire rd_src, write_enable, overflow, zero, negative, lui, mem_read, slt, word_we, byte_we, byte_load, addm;
    wire msb = inst[15];
    wire [31:0] branch_offset = {signExtender[29:0], 2'b0};
    wire [7:0] byte_mux_out;


    register PC_reg(PC, nextPC, clock, 1'b1, reset);

    instruction_memory im(inst, PC[31:2]);

    regfile rf (A, rtData, inst[25:21], inst[20:16], W_addr, lui_out, write_enable, clock, reset);

    mips_decode decoder(alu_op, write_enable, rd_src, alu_src2, except, control_type,
                   mem_read, word_we, byte_we, byte_load, slt, lui, addm,
                   inst[31:26], inst[5:0], zero);

    data_mem dataMemory(data_out, reg_alu_out, rtData, word_we, byte_we, clock, reset);

    alu32 REG_alu(reg_alu_out, overflow, zero, negative, A, addmMux2_out, alu_op);

    alu32 PC_alu(PC_alu_out, , , , PC, 32'd4, 3'b010);

    alu32 branch_alu(branch_alu_out, , , , PC_alu_out, branch_offset, 3'b010);

    alu32 addm_alu(addm_alu_out, , , , A, byte_load_out, 3'b010);

    mux2v #(5) inMux(W_addr, inst[15:11], inst[20:16], rd_src);

    mux2v byteLoadMux(byte_load_out, data_out[31:0], {24'b0, byte_mux_out[7:0]}, byte_load);

    mux2v addmMux2(addmMux2_out, B, 32'b0, addm);

    mux2v luiMux(lui_out, mem_read_out, {inst[15:0], 16'b0}, lui);

    mux2v sltMux(slt_out, reg_alu_out, {31'b0, negative}, slt);

    mux2v addmMux(addm_out, byte_load_out, addm_alu_out, addm);

    mux2v mem_readMux(mem_read_out, slt_out, addm_out, mem_read);

    mux3v outMux(B, rtData, signExtender, zeroExtender, alu_src2);

    mux4v controlMux(nextPC, PC_alu_out, branch_alu_out, {PC_alu_out[31:28], inst[25:0], 2'b0}, A, control_type);

    mux4v #(8) byteMux(byte_mux_out, data_out[7:0], data_out[15:8], data_out[23:16], data_out[31:24], reg_alu_out[1:0]);

endmodule // full_machine

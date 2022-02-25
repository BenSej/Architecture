// mips_decode: a decoder for MIPS arithmetic instructions
//
// alu_op       (output) - control signal to be sent to the ALU
// writeenable  (output) - should a new value be captured by the register file
// rd_src       (output) - should the destination register be rd (0) or rt (1)
// alu_src2     (output) - should the 2nd ALU source be a register (0) or an immediate (1)
// except       (output) - set to 1 when we don't recognize an opdcode & funct combination
// control_type (output) - 00 = fallthrough, 01 = branch_target, 10 = jump_target, 11 = jump_register 
// mem_read     (output) - the register value written is coming from the memory
// word_we      (output) - we're writing a word's worth of data
// byte_we      (output) - we're only writing a byte's worth of data
// byte_load    (output) - we're doing a byte load
// slt          (output) - the instruction is an slt
// lui          (output) - the instruction is a lui
// addm         (output) - the instruction is an addm
// opcode        (input) - the opcode field from the instruction
// funct         (input) - the function field from the instruction
// zero          (input) - from the ALU
//

module mips_decode(alu_op, writeenable, rd_src, alu_src2, except, control_type,
                   mem_read, word_we, byte_we, byte_load, slt, lui, addm,
                   opcode, funct, zero);
    output [2:0] alu_op;
    output [1:0] alu_src2;
    output       writeenable, rd_src, except;
    output [1:0] control_type;
    output       mem_read, word_we, byte_we, byte_load, slt, lui, addm;
    input  [5:0] opcode, funct;
    input        zero;


    assign except = ~(add | sub | andWire | orWire | norWire | xorWire | addi | andi | ori | xori | bne | beq | j | jr | lui | slt | lw | lbu | sw | sb | addm);

    assign writeenable = add | sub | andWire | orWire | norWire | xorWire | addi | andi | ori | xori | lui | lw | lbu | addmWire | slt;

    assign rd_src = ~(opcode == 6'b000000);

    assign alu_src2[0] = addi | lw | lbu | sw | sb;
    assign alu_src2[1] = andi | ori | xori | addmWire;

    assign alu_op[0] = sub | orWire | xorWire | ori | xori | slt | beq | bne;
    assign alu_op[1] = add | sub | norWire | xorWire | addi | xori | slt | lw | lbu | sw | sb | addmWire | beq | bne;
    assign alu_op[2] = andWire | orWire | norWire | xorWire | andi | ori | xori;

    assign control_type[0] = (beq & zero) | (bne & ~zero) | jr;
    assign control_type[1] = j | jr;

    assign mem_read = lw | lbu | addmWire;

    assign word_we = sw;
    
    assign byte_we = sb;

    assign byte_load = lbu;

    assign slt = sltWire;

    assign lui = luiWire;

    assign addm = addmWire;

    wire addmWire = opcode == 6'b000000 & (funct == 6'h2c);

    wire add = opcode == 6'b000000 & (funct == 6'b100000);
    wire sub = opcode == 6'b000000 & (funct == 6'b100010);
    wire andWire = opcode == 6'b000000 & (funct == 6'b100100);
    wire orWire = opcode == 6'b000000 & (funct == 6'b100101);
    wire norWire = opcode == 6'b000000 & (funct == 6'b100111);
    wire xorWire = opcode == 6'b000000 & (funct == 6'b100110);
    wire addi = opcode == 6'b001000;
    wire andi = opcode == 6'b001100;
    wire ori = opcode == 6'b001101;
    wire xori = opcode == 6'b001110;

    wire beq = opcode == 6'b000100;
    wire bne = opcode == 6'b000101;
    wire j = opcode == 6'b000010;
    wire jr = opcode == 6'b000000 & (funct == 6'b001000);
    wire luiWire = opcode == 6'b001111;
    wire sltWire = opcode == 6'b000000 & (funct == 6'b101010);
    wire lw = opcode == 6'b100011;
    wire lbu = opcode == 6'b100100;
    wire sw = opcode == 6'b101011;
    wire sb = opcode == 6'b101000;

endmodule // mips_decode

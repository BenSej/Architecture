`define STATUS_REGISTER 5'd12
`define CAUSE_REGISTER  5'd13
`define EPC_REGISTER    5'd14

module cp0(rd_data, EPC, TakenInterrupt,
           wr_data, regnum, next_pc,
           MTC0, ERET, TimerInterrupt, clock, reset);
    output [31:0] rd_data;
    output [29:0] EPC;
    output        TakenInterrupt;
    input  [31:0] wr_data;
    input   [4:0] regnum;
    input  [29:0] next_pc;
    input         MTC0, ERET, TimerInterrupt, clock, reset;

    // your Verilog for coprocessor 0 goes here
    
    wire [31:0] user_status;
    wire exception_level;
    wire [29:0] epc_data;
    wire [31:0] status_register = {16'b0, user_status[15:8], 6'b0, exception_level, user_status[0]};
    wire [31:0] cause_reg = {16'b0, TimerInterrupt, 15'b0};
    wire [31:0] decoder_out;

    wire cause15_and_status15 = cause_reg[15] & status_register[15];
    wire notstatus1_and_status0 = ~status_register[1] & status_register[0];
    assign TakenInterrupt = cause15_and_status15 & notstatus1_and_status0;

    decoder32 decoder(decoder_out, regnum, MTC0);

    register #(32) status(user_status, wr_data, clock, decoder_out[12], reset);
    dffe exception(exception_level, 1'b1, clock, TakenInterrupt, (reset | ERET));
    register #(30) epc_reg(EPC, epc_data, clock, TakenInterrupt | decoder_out[14], reset);

    mux2v #(30) epc_mux(epc_data, wr_data[31:2], next_pc, TakenInterrupt);
    mux32v #(32) epc_out_mux(rd_data, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, status_register, cause_reg, {EPC, 2'b0}, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, regnum);

endmodule

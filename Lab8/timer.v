module timer(TimerInterrupt, cycle, TimerAddress,
             data, address, MemRead, MemWrite, clock, reset);
    output        TimerInterrupt;
    output [31:0] cycle;
    output        TimerAddress;
    input  [31:0] data, address;
    input         MemRead, MemWrite, clock, reset;

    wire [31:0] interruptCycle_out, cycleCounter_out, cycleCounter_ALU_out;
    wire addressEQ1 = (32'hffff001c == address);
    wire addressEQ2 = (32'hffff006c == address);
    wire acknowledge = MemWrite & addressEQ2;
    wire timerWrite = MemWrite & addressEQ1;
    wire timerRead = MemRead & addressEQ1;
    wire TimerAddress = addressEQ1 | addressEQ2;
    wire interruptLine_reset = acknowledge | reset;
    wire interruptLine_enable = (interruptCycle_out == cycleCounter_out);

    tristate timerRead_tri(cycle, cycleCounter_out, timerRead);

    register #(32, 32'hffffffff) interruptCycle(interruptCycle_out, data, clock, timerWrite, reset);
    register #(1) interruptLine(TimerInterrupt, 1'b1, clock, interruptLine_enable, interruptLine_reset);
    register cycleCounter(cycleCounter_out, cycleCounter_ALU_out, clock, 1'b1, reset);
    alu32 cycleCounter_ALU(cycleCounter_ALU_out, , , `ALU_ADD, cycleCounter_out, 32'd1);
endmodule

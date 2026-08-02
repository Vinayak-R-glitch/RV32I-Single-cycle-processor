module instrmem(
    input logic[31:0] instad,
    output logic[31:0] INSTR
);
logic [31:0] mem1 [0:255];
always_comb begin
    INSTR=mem1[instad[31:2]];
end
endmodule
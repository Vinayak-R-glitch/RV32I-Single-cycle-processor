module instrmem(
    input logic[31:0] IADR,
    output logic[31:0] INST
);
logic [31:0] mem1 [0:255];
always_comb begin
    INST=mem1[IADR[31:2]];
end
endmodule
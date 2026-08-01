module extend(
    input logic [31:0] INSTR,
    input logic [2:0] IMMCTRL,
    output logic[31:0] IMM
);
always_comb begin
    unique case(IMMCTRL)
        3'b000: IMM={ {20{INSTR[31]}}, INSTR[31:20] }; //i type arithmetic
        3'b001: IMM={ {20{INSTR[31]}}, INSTR[31:25], INSTR[11:7] }; //s type
        3'b010: IMM={ {19{INSTR[31]}}, INSTR[31], INSTR[7], INSTR[30:25], INSTR[11:8], 1'b0 };  //B TYPE
        3'b011: IMM={ INSTR[31:12], 12'b0 }; //u type
        3'b100: IMM={ {11{INSTR[31]}}, INSTR[31], INSTR[19:12], INSTR[20], INSTR[30:21], 1'b0 }; //j type
        3'b101: IMM=32'b0; // rtype
        3'b110: IMM={ {20{INSTR[31]}}, INSTR[31:20] };//load type
    endcase
end
endmodule
module ALU(
    input logic[3:0] ALUCTRL,
    input logic [31:0] rs1,rs2,
    output logic zero,overflow,rs1neg,rs2neg,resneg,
    output logic [31:0] res
);
logic [32:0] y;
logic [31:0] subres,addres;
logic addoverflow,suboverflow;
assign rs1neg=rs1[31];
assign rs2neg=rs2[31];
always_comb begin
    subres = rs1-rs2;
    suboverflow = (~(rs1[31])&rs2[31]&subres[31])|(rs1[31]&~(rs2[31])&~(subres[31]));
    addres= rs1+rs2;
    addoverflow = (~(rs1[31])&~(rs2[31])&addres[31])|(rs1[31]&rs2[31]&~addres[31]);
    unique case(ALUCTRL)
        4'b0000: res= rs1+rs2;
        4'b0001: res=subres;
        4'b0010: res=rs1&rs2;
        4'b0011: res=rs1|rs2;
        4'b0100: res=rs1^rs2;
        4'b0101: res=rs1<<rs2[4:0]; //shift cant exceed a five bit number so last five bits are used
        4'b0110: res=rs1>>rs2[4:0];
        4'b0111: res=rs1>>>rs2[4:0];
        4'b1000: y={1'b0,rs1}-{1'b0,rs2};
                 res={31'b0,y[32]};
        4'b1001: res={31'b0,((subres[31])^(suboverflow))};
    endcase
end
assign zero= (res==0);
assign resneg=res[31];
assign overflow= ((ALUCTRL==4'b000)&addoverflow)|((ALUCTRL==4'b0001)&suboverflow);
endmodule

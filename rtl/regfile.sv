  module regfile(
    input logic clk,WER,jump,
    input logic [1:0] upperim,
    input logic [31:0] INST,instad,
    input logic [31:0] WD3,
    output logic [31:0] RD1,RD2
 );
 logic [31:0] x [0:31];
 logic [4:0] A1,A2,A3;
 assign A1= INST[19:15]; assign A2=INST[24:20]; assign A3=INST[11:7];
 assign WD3=RESULTSRC?writeback:res;
 always_ff@(posedge clk) begin
    if(WER==1'b1 && A3!=5'b00000) begin
        if(A3==5'b0001) begin
            if(jump) x[1]<=instad+32'd4;
            else x[1]<=WD3;
        end
        else x[A3]<=WD3;
    end
end
always_comb begin
    unique case(upperim)
        2'b00: RD1=(A1==0)?(32'b0):(x[A1]);
        2'b01: RD1=32'b0;
        2'b10: RD1=instad;
        default: RD1=(A1==0)?(32'b0):(x[A1]);
    endcase
end
assign RD2=(A2==0)?(32'b0):(x[A2]);
endmodule
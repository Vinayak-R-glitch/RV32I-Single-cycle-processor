module datamem_outhandler(
    input[31:0] RDM, DADR,
    input[2:0] funct3,
    input clk,
    input [31:0] INSTR,
    output[31:0] writeback,
    output pcstall,misalign_seq
);
logic [31:0] buffer;
logic[31:0] package_out,bufferin,dataword;
always_comb begin
    if(misalign_seq=1'b0) dataword=RDM;
    else bufferin=RDM;
end
always_ff@(posedge clk) begin
     misalign_seq<=misalign_comb;
end
assign pcstall=misalign_comb;
assign misalign_comb=(!misalign_seq)&((!(INSTR[5])&(((funct3==3'b001)&(DADR[1:0]==2'b11))|((funct3==3'b010)&(DADR[1:0]!=2'b00))|((funct3==3'b101)&(DADR[1:0]==2'b11))))|((INSTR[5])&(((funct3==3'b001)&(DADR[1:0]==2'b11))|((funct3==3'b010)&(DADR[1:0]!=2'b00)))));
assign writeback= misalign_seq?(package_out:dataword);
always@(posedge clk) begin
    if (misalign_comb) begin
        buffer<=bufferin;
    end
end
always_comb begin
    unique case(funct3) 
        3'b001: package_out= {{16{dataword[7]}},dataword[7:0],buffer[31:24]};
        3'b010: begin
            unique case(DADR[1:0]) 
                2'b01:package_out={dataword[7:0],buffer[31:8]};
                2'b10:package_out={dataword[15:0],buffer[31:16]};
                2'b11:package_out={dataword[23:0],buffer[31:24]};
            endcase
        end
        3'b101: package_out={{16{1'b0}},dataword[7:0],buffer[31:24]};
    endcase
end
endmodule
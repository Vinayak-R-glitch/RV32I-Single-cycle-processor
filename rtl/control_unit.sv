module ctrlunit(
    input logic [31:0] INSTR, 
    input logic overflow,zero,rs1neg,rs2neg,resneg,
    output logic[2:0] IMMCTRL,
    output logic[3:0] ALUCTRL,
    output logic WER,WED,ALUSRC,RESULTSRC,jump,
    output logic[1:0] pcsrc,upperim

);
logic [6:0] op,funct7;
logic [2:0] funct3;
always_comb begin
    unique case(op)
        7'b0110111: upperim=2'b01;
        7'b0010111: upperim=2'b10;
        default: upperim=2'b00;
    endcase
end
assign op=INSTR[6:0]; assign funct7=INSTR[31:25]; assign funct3=INSTR[14:12];
logic memread, memwrite;
assign jump=(op==7'b1101111|op==7'b1100111);
assign memread=(op==7'b0000011);
assign memwrite=(op==7'b0100011);
always_comb begin
    unique case(op)
        7'b0110011: begin
            IMMCTRL=3'b101; ALUSRC=0; RESULTSRC=0; WER=1; WED=0;
            unique case(funct3)
                3'b000:ALUCTRL=funct7[5]?4'b0001:4'b0000;
                3'b001:ALUCTRL=4'b0101;
                3'b010:ALUCTRL=4'b1001;
                3'b011:ALUCTRL=4'b1000;
                3'b100:ALUCTRL=4'b0100;
                3'b101:ALUCTRL=funct7[5]?4'b0111:4'b0110;
                3'b110:ALUCTRL=4'b0011;
                3'b111:ALUCTRL=4'b0010;
            endcase
        end
        7'b0010011:begin
            IMMCTRL=3'b000; ALUSRC=1; RESULTSRC=0; WER=1; WED=0;
            unique case(funct3)
                3'b000: ALUCTRL=4'b0000;
                3'b001: ALUCTRL=4'b0101;
                3'b010: ALUCTRL=4'b1001;
                3'b011: ALUCTRL=4'b1000;
                3'b100: ALUCTRL=4'b0100;
                3'b101: ALUCTRL=funct7[5]?4'b0111:4'b0110;
                3'b110: ALUCTRL=4'b0011;
                3'b111: ALUCTRL=4'b0010;
            endcase
        end
        7'b0000011: begin
            IMMCTRL=3'b000; ALUSRC=1; ALUCTRL=4'b0000; RESULTSRC=1; WER=1; WED=0;
        end
        7'b0100011:begin
            IMMCTRL=3'b001; ALUSRC=1; ALUCTRL=4'b0000; RESULTSRC=1'bx; WER=0; WED=1;
        end
        7'b1100011: begin
            IMMCTRL=3'b010; ALUSRC=1'bx; RESULTSRC=1'bx; WER=0; WED=0;
            unique case(funct3)
                3'b000:begin
                    ALUCTRL=4'b0001;
                    if (zero) pcsrc=2'b01;
                    else pcsrc=2'b00;
                end
                3'b001: begin
                    ALUCTRL=4'b0001;
                    if(!zero) pcsrc=2'b01;
                    else pcsrc=2'b00;
                end
                3'b100: begin
                    ALUCTRL=4'b0001;
                    if((rs1neg&(!rs2neg))|((!rs1neg)&(!rs2neg)&(resneg))|((rs1neg)&(rs2neg)&(resneg))) pcsrc=2'b01;
                    else pcsrc=2'b00;
                end
                3'b101: begin
                    ALUCTRL=4'b0001;
                    if((zero)|((!rs1neg)&(!rs2neg)&(!resneg))|((rs1neg)&(rs2neg)&(!resneg))) pcsrc=2'b01;
                    else pcsrc=2'b00;
                end
                3'b110: begin
                    ALUCTRL=4'b0001;
                    if(((!rs1neg)&rs2neg)|((!rs1neg)&(!rs2neg)&(resneg))|((rs1neg)&(rs2neg)&(resneg))) pcsrc=2'b01;
                    else pcsrc= 2'b00;
                end
                3'b111: begin
                    ALUCTRL=4'b0001;
                    if(!(((!rs1neg)&rs2neg)|((!rs1neg)&(!rs2neg)&(resneg))|((rs1neg)&(rs2neg)&(resneg)))) pcsrc=2'b01;
                    else pcsrc=2'b00;
                end
            endcase
        end
        7'b1101111:begin
            ALUCTRL=4'b0000; IMMCTRL=3'b100; pcsrc=2'b01; ALUSRC=1'bx; RESULTSRC=1'bx; WER=1'b1; WED=1'b0;
        end
        7'b1100111: begin
            ALUCTRL=4'b0000; IMMCTRL=3'b100; pcsrc=2'b10; ALUSRC=1'b1; RESULTSRC=1'bx; WER=1'b1; WED=1'b0;
        end
        7'b0110111: begin
            ALUCTRL=4'b0000; IMMCTRL=3'b011; ALUSRC=1'b1; RESULTSRC=1'b0; WER=1'b1; WED=1'b0;
        end
        7'b0010111: begin
            ALUCTRL=4'b0000; IMMCTRL=3'b011; ALUSRC=1'b1; RESULTSRC=1'b0; WER=1'b1; WED=1'b0;
        end
    endcase
end
endmodule

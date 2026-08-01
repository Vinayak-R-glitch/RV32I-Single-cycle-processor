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

module instrmem(
    input logic[31:0] IADR,
    output logic[31:0] INST
);
logic [31:0] mem1 [0:255];
always_comb begin
    INST=mem1[IADR[31:2]];
end
endmodule

module datamem(  
    input logic clk,WED,memread,memwrite,misalign_seq,
    input logic[2:0] funct3,
    input logic[31:0] res, //alu result
    input logic[31:0] WD,
    output logic [31:0]RDM
);
logic [31:0] mem2 [0:255];
logic [31:0] DADR;
assign DADR=misalign_seq((res+32'b4):(res));
always_comb begin
    if(memread) begin
        unique case(funct3)
            3'b000:begin
                case(DADR[1:0])
                    2'b00:RDM={{24{mem2[DADR[31:2]][7]}},mem2[DADR[31:2]][7:0]};
                    2'b01:RDM={{24{mem2[DADR[31:2]][15]}},mem2[DADR[31:2]][15:8]};
                    2'b10:RDM={{24{mem2[DADR[31:2]][23]}},mem2[DADR[31:2]][23:16]};
                    2'b11:RDM={{24{mem2[DADR[31:2]][31]}},mem2[DADR[31:2]][31:24]};
                endcase
            end
            3'b001: begin
                case(DADR[1:0])
                    2'b00:RDM={{16{mem2[DADR[31:2]][15]}},mem2[DADR[31:2]][15:0]};
                    2'b01:RDM={{16{mem2[DADR[31:2]][23]}},mem2[DADR[31:2]][23:8]};
                    2'b10:RDM={{16{mem2[DADR[31:2]][31]}},mem2[DADR[31:2]][31:16]};
                    2'b11:RDM=mem2[DADR[31:2]];
            endcase
            end
            3'b010:begin
                unique case(DADR[1:0])
                    2'b00:RDM=mem2[DADR[31:2]];
                    2'b01:RDM=mem2[DADR[31:2]];
                    2'b10:RDM=mem2[DADR[31:2]];
                    2'b11:RDM=mem2[DADR[31:2]];
                endcase
            end
            3'b100:begin
                case(DADR[1:0])
                    2'b00:RDM={{24{1'b0}},mem2[DADR[31:2]][7:0]};
                    2'b01:RDM={{24{1'b0}},mem2[DADR[31:2]][15:8]};
                    2'b10:RDM={{24{1'b0}},mem2[DADR[31:2]][23:16]};
                    2'b11:RDM={{24{1'b0}},mem2[DADR[31:2]][31:24]};
                endcase
            end
            3'b101:begin
                case(DADR[1:0])
                    2'b00:RDM={{16{1'b0}},mem2[DADR[31:2]][15:0]};
                    2'b01:RDM={{16{1'b0}},mem2[DADR[31:2]][23:8]};
                    2'b10:RDM={{16{1'b0}},mem2[DADR[31:2]][31:16]};
                    2'b11:RDM=mem2[DADR[31:2]];
                endcase
            end
        endcase
    end
end

always_ff@(posedge clk) begin
    if (memwrite&WED) begin
        unique case(funct3)
            3'b000: begin
                case(DADR[1:0])
                    2'b00:mem2[DADR[31:2]][7:0]<=WD[7:0];
                    2'b01:mem2[DADR[31:2]][15:8]<=WD[7:0];
                    2'b10:mem2[DADR[31:2]][23:16]<=WD[7:0];
                    2'b11:mem2[DADR[31:2]][31:24]<=WD[7:0];
                endcase
            end
            3'b001: begin
                case(DADR[1:0])
                    2'b00:mem2[DADR[31:2]][15:0]<=WD[15:0];
                    2'b01:mem2[DADR[31:2]][23:8]<=WD[15:0];
                    2'b10:mem2[DADR[31:2]][31:16]<=WD[15:0];
                    2'b11:begin
                        if(!misalign_seq)mem2[DADR[31:2]][31:24]<=WD[7:0];
                        else mem2[DADR[31:2]][7:0]<=WD[15:8];
                    end
                endcase
            end
            3'b010: begin
                case(DADR[1:0])
                    2'b00:mem2[DADR[31:2]]<=WD;
                    2'b01:begin
                        if(!misalign_seq) mem2[DADR[31:2]][31:8]<=WD[23:0];
                        else mem2[DADR[31:2]][7:0]<=WD[31:24];
                    end
                    2'b10:begin
                        if(!misalign_seq) mem2[DADR[31:2]][31:16]<=WD[15:0];
                        else mem2[DADR[31:2]][15:0]<=WD[31:0];
                    end
                    2'b11:begin
                        if(!misalign_seq) mem2[DADR[31:2]][31:24]<=WD[7:0];
                        else mem2[DADR[31:2]][23:0]<=WD[31:8];
                    end
                endcase
            end
        endcase
    end
end
endmodule

                        

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

module pc(
    input logic clk,pcstall,rst,
    input logic [1:0] pcsrc,
    input logic[31:0] jumpval,res,
    output logic [31:0] instad
);
always_ff@(posedge clk,posedge rst) begin
    if(rst) instad<=32'b0;
    else begin
        if(pcstall) begin
         instad<=instad;
        end
        else begin
            unique case(pcsrc)
                2'b00: instad<=instad+32'd4;
                2'b01: instad<=instad+jumpval;
                2'b10: instad<=instad+res;
                default: instad<=instad+32'd4;
            endcase
        end
    end
end
endmodule

module ALU(
    input logic[3:0] ALUCTRL,
    input logic [31:0] rs1,rs2,
    output logic zero,overflow,rs1neg,rs2neg,resneg,
    output logic [31:0] res
);
logic [32:0] y;
logic [31:0] subres,addres;
logic addoverflow,suboverflow;
assign rs1neg=rs1neg[31];
assign rs2neg=rs2neg[31];
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
assign zero= (res==0);
assign resneg=res[31];
assign overflow= ((ALUCTRL==4'b000)&addoverflow)|((ALUCTRL==4'b0001)&suboverflow);
end
endmodule

module ctrlunit(
    input logic [31:0] INSTR; 
    input logic overflow,zero,rs1neg,rs2neg,resneg,
    output logic[2:0] IMMCTRL;
    output logic[3:0] ALUCTRL;
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
always_combff begin
    unique case(op)
        7'b0110011: begin
            IMMCTRL=3'b101; ALUSRC=0; RESULTSRC=0; WER=1; WED=0;
            unique case(funct3)
                3'b000:ALUCTRL=funct7[5]?(4'b0001:4'b0000);
                3'b001:ALUCTRL=4'b0101;
                3'b010:ALUCTRL=4'b1001;
                3'b011:ALUCTRL=4'b1000;
                3'b100:ALUCTRL=4'b0100;
                3'b101:ALUCTRL=funct7[5]?(4'b0111:4'b0110);
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
                3'b101: ALUCTRL=funct7[5]?(4'b0111:4'b0110);
                3'b110: ALUCTRL=4'b0011;
                3'b111: ALUCTRL=4'b0010;
            endcase
        end
        7'b0000011: begin
            IMMCTRL=3'b000; ALUSRC=1; ALUCTRL=4'b0000; RESULTSRC=1; WER=1; WED=0;
        end
        7'b0100011:begin
            IMMCTRL=3'b001; ALUSRC=1; ALUCTRL=4'b0000; RESULTSRC=1'bx; WER=0; WED=1;
        end'
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
                    ALUCTRL=4'b001;
                    if!(((!rs1neg)&rs2neg)|((!rs1neg)&(!rs2neg)&(resneg))|((rs1neg)&(rs2neg)&(resneg))) pcsrc=2'b01;
                    else pcsrc=2'b00;
                end
            endcase
        end
        7'b1101111:begin
            ALUCTRL=4'b0000; IMMCTRL=3'b100; pcsrc=2'b01; ALUSRC=1'bx; RESULTSRC=1'bx; WER=1'b1; WED=1'b0;
        end
        7'b1100111: begin
            ALUCTRL=4'b0000; IMMCTRL=3'b100; pcsrc=2'b10; ALUSRC=1'b1; RESULTSRC=1'bx; WER=1'b0; WED=1'b0;
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

    




        

                 

        
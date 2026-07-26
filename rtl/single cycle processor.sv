 module regfile(
    input logic clk,WER,
    input logic [4:0] A1,A2,A3,
    input logic [31:0] WD3,
    output logic [31:0] RD1,RD2
 );
 logic [31:0] x [0:31];
 always_ff@(posedge clk) begin
    if(WER==1'b1 && A3!=5'b00000) begin
        x[A3]<=WD3;
    end
end
assign RD1=(A1==0)?(32'B0):(x[A1]);
assign RD2=(A2==0)?(32'B0):(x[A2]);
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
    input logic clk,WED,memread,memwrite,
    input logic[2:0] funct3,
    input logic[31:0] DADR,
    input logic[31:0] WD,
    output logic [31:0]RDM
);
logic [31:0] mem2 [0:255];
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
                case(DADR[1])
                    1'b0:RDM={{16{mem2[DADR[31:2]][15]}},mem2[DADR[31:2]][15:0]};
                    1'b1:RDM={{16{mem2[DADR[31:2]][31]}},mem2[DADR[31:2]][31:16]};
                endcase
            end
            3'b010: RDM=mem2[DADR[31:2]];
            3'b100:begin
                case(DADR[1:0])
                    2'b00:RDM={{24{1'b0}},mem2[DADR[31:2]][7:0]};
                    2'b01:RDM={{24{1'b0}},mem2[DADR[31:2]][15:8]};
                    2'b10:RDM={{24{1'b0}},mem2[DADR[31:2]][23:16]};
                    2'b11:RDM={{24{1'b0}},mem2[DADR[31:2]][31:24]};
                endcase
            end
            3'b101:begin
                case(DADR[1])
                    1'b0:RDM={{16{1'b0}},mem2[DADR[31:2]][15:0]};
                    1'b1:RDM={{16{1'b0}},mem2[DADR[31:2]][31:16]};
                endcase
            end
        endcase
    end
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

module ALU(
    input logic[3:0] ALUCTRL,
    input logic [31:0] rs1,rs2,
    output logic zero,overflow,
    output logic [31:0] res
);
logic [32:0] y;
logic [31:0] subres,addres;
logic addoverflow,suboverflow;
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
assign overflow= ((ALUCTRL==4'b000)&addoverflow)|((ALUCTRL==4'b0001)&suboverflow);
end
endmodule

module ctrlunit(
    input logic [31:0] INSTR; 
    output logic[2:0] IMMCTRL;
    output logic[3:0] ALUCTRL;
    output logic WER,WED,ALUSRC,RESULTSRC

);
logic [6:0] op,funct7;
logic [2:0] funct3;
assign op=INSTR[6:0]; assign funct7=INSTR[31:25]; assign funct3=INSTR[14:12];
logic memread, memwrite;
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


        

                 

        
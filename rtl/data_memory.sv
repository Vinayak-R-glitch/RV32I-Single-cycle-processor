module datamem(  
    input logic clk,WED,memread,memwrite,misalign_seq,
    input logic[2:0] funct3,
    input logic[31:0] res, //alu result
    input logic[31:0] WD,
    output logic [31:0]RDM
);
logic [31:0] mem2 [0:255];
logic [31:0] DADR;
assign DADR=misalign_seq?(res+32'b4):(res);
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
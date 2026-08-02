module pc(
    input logic clk,pcstall,rst,
    input logic [1:0] pcsrc,
    input logic[31:0] IMM,res,
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
                2'b01: instad<=instad+IMM;
                2'b10: instad<=instad+res;
                default: instad<=instad+32'd4;
            endcase
        end
    end
end
endmodule

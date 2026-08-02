module top(
    input clk,rst
);

pc pc1(
    .clk(clk),.rst(rst),
    .pcstall(pcstall),.IMM(IMM),
    .res(res),.instad(instad),
    .pcsrc(pcsrc)
);

instrmem in(
    .instad(instad),.INST(INSTR)
);

datamem da(
    .clk(clk),.WED(WED),.memread(memread),.memwrite(memwrite),
    .misalign_seq(misalign_seq),.INSTR(INSTR),
    .res(res),.WD(WD),.RDM(RDM)
);

extend_unit ex(
    .INSTR(INSTR),.IMMCTRL(IMMCTRL),.IMM(IMM)
);


alu alu(
    .ALUCTRL(ALUCTRL),.rs1(rs1),.rs2(rs2),.zero(zero),
    .overflow(overflow),.rs1neg(rs1neg),.rs2neg(rs2neg),
    .resneg(resneg),.res(res)
);

regfile reg(
    .clk(clk),.WER(WER),.jump(jump),.rst(rst),.upperim(upperim),
    ..INSTR(INSTR),.instad(instad),.WD3(WD3),.RD1(rs1),.RD2(rs2)
);

misalign_handler mis(
    .clk(clk),.RDM(RDM),.DADR(DADR),.INSTR(INSTR),.writeback(writeback),
    .pcstall(pcstall),.misalign_seq(misalign_seq)
);

ctrlunit ctrl(
    .INSTR(INSTR),.overflow(overflow),.zero(zero),.rs1(rs1neg),
    .rs2neg(rs2neg),.resneg(resneg),.IMMCTRL(IMMCTRL),.ALUCTRL(ALUCTRL),
    .WER(WER),.WED(WED),.ALUSRC(ALUSRC),.RESULTSRC(RESULTSRC),.jump(jump),
    .pcsrc(pcsrc),.upperim(upperim)
);

logic pcstall; logic [1:0] pcsrc; logic[31:0] IMM , res;
logic [31:0] instad; 
logic[31:0] INSTR; logic WED,memread,memwrite,misalign_seq;
logic [31:0] WD,RDM;
logic [2:0] IMMCTRL; logic[31:0] rs1,rs2;
logic rs1neg,rs2neg,resneg,zero,overflow; logic[3:0] ALUCTRL;
logic WER,jump; logic [1:0] upperim;


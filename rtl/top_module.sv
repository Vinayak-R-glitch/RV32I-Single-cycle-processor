module top(
    input clk,rst
);
logic pcstall;
logic [1:0] pcsrc;
logic[31:0] jumpval,res;
logic [31:0] instad;
pc pc1(
    .clk(clk)
    .rst(rst)
    .pcstall(pcstall)
    .jumpval(jumpval)
    .res(res)
    .instad(instad)
    .pcsrc(pcsrc)
);

instrmem in(

)
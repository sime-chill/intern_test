`timescale 1ns / 1ps
module tb
  #(
    parameter DATA_WD      = 32,
    parameter DATA_BYTE_WD = DATA_WD / 8
  )
  (
  );

  reg                        valid_in, last_in, ready_out, valid_insert;
  reg [DATA_WD - 1 : 0]      data_in, header_insert;
  reg [DATA_BYTE_WD - 1 : 0] keep_in, keep_insert;

  reg                        clk, rst_n;
  initial begin
    clk       = 0;
    rst_n     = 0;
    ready_out = 1;
    #20 rst_n = 1;
  end

  always #5 clk = !clk;


//ex1: 1st beat of data is as fast as header
//  initial begin
//    valid_in      <= 0;
//    last_in       <= 0;
//    keep_in       <= 4'b0;
//    data_in       <= 32'h0;
//    ready_out     <= 1; //todo: consider random ready_out
//    valid_insert  <= 0;
//    header_insert <= 32'h0;
//    keep_insert   <= 4'b0000;
//    #105;
//    valid_in      <= 1;
//    valid_insert  <= 1;
//    keep_in       <= 4'b1111;
//    header_insert <= 32'hFFEE_DDCC;
//    data_in       <= 32'hAABB_CCDD;
//    keep_insert   <= 4'b0111;
//    #10;
//    valid_in      <= 1;
//    valid_insert  <= 0;
//    header_insert <= 32'h0;
//    data_in       <= 32'hEEFF_0011;
//    keep_insert   <= 4'b0;
//    #10;
//    valid_insert  <= 0;
//    data_in       <= 32'h2233_4455;
//    #10;
//    valid_insert  <= 0;
//    data_in       <= 32'h6677_8899;
//    #10;
//    data_in       <= 32'h00AA_BBCC;
//    last_in       <= 1;
//    keep_in       <= 4'b1100;
//    #10;
//    keep_in       <= 4'b0000;
//    valid_in      <= 0;
//    last_in       <= 0;
//    #20 $finish;
//  end

//ex2: 1st beat of data is faster than header
//  initial begin
//    valid_in      <= 0;
//    last_in       <= 0;
//    keep_in       <= 4'b0;
//    data_in       <= 32'h0;
//    ready_out     <= 1;
//    valid_insert  <= 0;
//    header_insert <= 32'h0;
//    keep_insert   <= 4'b0000;
//    #105;
//    valid_in      <= 1;
//    keep_in       <= 4'b1111;
//    valid_insert  <= 0;
//    header_insert <= 32'h0;
//    data_in       <= 32'hAABB_CCDD;
//    keep_insert   <= 4'b0;
//    #10;
//    valid_in      <= 1;
//    valid_insert  <= 0;
//    header_insert <= 32'h0;
//    data_in       <= 32'hAABB_CCDD;
//    keep_insert   <= 4'b0;
//    #10;
//    valid_in      <= 1;
//    valid_insert  <= 1;
//    header_insert <= 32'hFFEE_DDCC;
//    data_in       <= 32'hAABB_CCDD;
//    keep_insert   <= 4'b0001;
//    #10;
//    valid_in      <= 1;
//    valid_insert  <= 0;
//    header_insert <= 32'h0;
//    data_in       <= 32'hEEFF_0011;
//    keep_insert   <= 4'b0;
//    #10;
//    valid_insert  <= 0;
//    data_in       <= 32'h2233_4455;
//    #10;
//    valid_insert  <= 0;
//    data_in       <= 32'h6677_8899;
//    #10;
//    data_in       <= 32'h00AA_BBCC;
//    last_in       <= 1;
//    keep_in       <= 4'b1100;
//    #10;
//    keep_in       <= 4'b0000;
//    valid_in      <= 0;
//    last_in       <= 0;
//    #20 $finish;
//  end

//ex3: 1st beat of data is slower than header
  initial begin
    valid_in      <= 0;
    last_in       <= 0;
    keep_in       <= 4'b0;
    data_in       <= 32'h0;
    ready_out     <= 1;
    valid_insert  <= 0;
    header_insert <= 32'h0;
    keep_insert   <= 4'b0000;
    #105;
    valid_in      <= 0;
    keep_in       <= 4'b0;
    valid_insert  <= 1;
    header_insert <= 32'hFFEE_DDCC;
    data_in       <= 32'h0;
    keep_insert   <= 4'b0111;
    #10;
    valid_in      <= 0;
    valid_insert  <= 1;
    header_insert <= 32'hFFEE_DDCC;
    data_in       <= 32'h0;
    keep_insert   <= 4'b0111;
    #10;
    valid_in      <= 1;
    keep_in       <= 4'b1111;
    valid_insert  <= 1;
    header_insert <= 32'hFFEE_DDCC;
    data_in       <= 32'hAABB_CCDD;
    keep_insert   <= 4'b0111;
    #10;
    valid_in      <= 1;
    valid_insert  <= 0;
    header_insert <= 32'h0;
    data_in       <= 32'hEEFF_0011;
    keep_insert   <= 4'b0;
    #10;
    valid_insert  <= 0;
    data_in       <= 32'h2233_4455;
    #10;
    valid_insert  <= 0;
    data_in       <= 32'h6677_8899;
    #10;
    data_in       <= 32'h00AA_BBCC;
    last_in       <= 1;
    keep_in       <= 4'b1100;
    #10;
    keep_in       <= 4'b0000;
    valid_in      <= 0;
    last_in       <= 0;
    #20 $finish;
  end

//  reg [9 : 0]                counter;
//  always @(posedge clk) begin
//    if(!rst_n) counter <= 0;
//    else counter       <= counter + 1;
//  end
//
//  reg [7 : 0]                burst_length;
//  always @(posedge clk) begin
//    if(!rst_n) burst_length <= 0;
//    else burst_length       <= burst_length + 1;
//  end
//
//
//
//  data_master M_Data(
//    .counter(counter),
//    .burst_length(burst_length),
//    .valid_in(valid_in),
//    .last_in(last_in),
//    .keep_in(keep_in),
//    .data_in(data_in)
//  );
//
//  header_master M_Header(
//    .counter(counter),
//    .valid_insert(valid_insert),
//    .keep_insert(keep_insert),
//    .header_insert(header_insert)
//  );



  axi_stream_insert_header DUT(
    .clk(clk),
    .rst_n(rst_n),
    .valid_in(valid_in),
    .data_in(data_in),
    .keep_in(keep_in),
    .last_in(last_in),
    .ready_in(),
    .valid_out(),
    .data_out(),
    .keep_out(),
    .last_out(),
    .ready_out(ready_out),
    .valid_insert(valid_insert),
    .header_insert(header_insert),
    .keep_insert(keep_insert),
    .ready_insert()
  );



endmodule

`timescale 1ns / 1ps
module header_master
  (
    input      [9 : 0]  counter,
    output reg          valid_insert,
    output reg [3 : 0]  keep_insert,
    output reg [31 : 0] header_insert
  );

  reg [3 : 0] keep_random;
  always @(*) begin
    case (($random(counter)%5))
      4 : keep_random = 4'b1111;
      3 : keep_random = 4'b0111;
      2 : keep_random = 4'b0011;
      1 : keep_random = 4'b0001;
      0 : keep_random = 4'b0000;
      default : ;
    endcase
  end

  initial begin
    valid_insert  <= 0;
    keep_insert   <= 0;
    header_insert <= 32'b0;
  end

  always begin
    #10;
    #(counter * 10ns); //1st beat
    valid_insert  <= 1;
    keep_insert   <= keep_random;
    header_insert <= $random(counter);
    #10;
    valid_insert  <= 0;
    keep_insert   <= 4'b0000;
    header_insert <= 32'b0;
  end

endmodule

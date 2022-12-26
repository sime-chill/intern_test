`timescale 1ns / 1ps
module data_master
  (
    input      [9 : 0]  counter,
    input      [7 : 0]  burst_length,
    output reg          valid_in,
    output reg          last_in,
    output reg [3 : 0]  keep_in,
    output reg [31 : 0] data_in
  );

  reg [3 : 0] keep_random;
  always @(*) begin
    case (($random(counter)%4))
      3 : keep_random = 4'b1111;
      2 : keep_random = 4'b1110;
      1 : keep_random = 4'b1100;
      0 : keep_random = 4'b1000;
      default : ;
    endcase
  end

  initial begin
    valid_in <= 0;
    last_in  <= 0;
    keep_in  <= 4'b0;
    data_in  <= 32'b0;
  end

  always begin
    #10;
    #(counter * 10ns); //1st beat
    valid_in <= 1;
    last_in  <= 0;
    keep_in  <= 4'b1111;
    data_in  <= $random(counter);
    repeat (burst_length) begin //the middle beat number is random
      #10;
      valid_in <= 1;
      last_in  <= 0;
      keep_in  <= 4'b1111;
      data_in  <= $random(counter + 1);
    end
    #10;               //last beat
    valid_in <= 1;
    last_in  <= 1;
    keep_in  <= keep_random;
    data_in  <= $random(counter);
    #10;
    valid_in <= 0;
    last_in  <= 0;
    keep_in  <= 4'b0000;
    data_in  <= 32'b0;
  end

endmodule

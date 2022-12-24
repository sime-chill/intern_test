module axi_stream_insert_header
  #(
    parameter DATA_WD      = 32,
    parameter DATA_BYTE_WD = DATA_WD / 8
  )
  (
    input                             clk,
    input                             rst_n,
// AXI Stream input original data
    input                             valid_in,
    input      [DATA_WD - 1 : 0]      data_in,
    input      [DATA_BYTE_WD - 1 : 0] keep_in,
    input                             last_in,
    output reg                        ready_in,
// AXI Stream output with header inserted
    output                            valid_out,
    output reg [DATA_WD - 1 : 0]      data_out,
    output reg [DATA_BYTE_WD - 1 : 0] keep_out,
    output                            last_out,
    input                             ready_out,
// The header to be inserted to AXI Stream input
    input                             valid_insert,
    input      [DATA_WD - 1 : 0]      header_insert,
    input      [DATA_BYTE_WD - 1 : 0] keep_insert,
    output reg                        ready_insert
  );

  always @(posedge clk) begin
    if(!rst_n) begin
      ready_in     <= 1;
      ready_insert <= 1;
    end
    else begin
    end
  end

  wire [7 : 0]                data_b3, data_b2, data_b1, data_b0; //these slices can be reduced
  assign {data_b3, data_b2, data_b1, data_b0}         = data_in;

  reg  [DATA_WD - 1 : 0]      data_reg;
  always @(posedge clk) begin
    if(!rst_n) data_reg <= 0;
    else data_reg       <= data_in;
  end

  reg  [DATA_BYTE_WD - 1 : 0] keep_reg;
  always @(posedge clk) begin
    if(!rst_n) keep_reg <= 0;
    else keep_reg       <= keep_in;
  end

  wire [7 : 0]                header_b3, header_b2, header_b1, header_b0;
  assign {header_b3, header_b2, header_b1, header_b0} = header_insert;

  wire                        header_succ;
  assign header_succ                                  = ready_insert & valid_insert;
  wire                        data_in_succ;
  assign data_in_succ                                 = ready_in & valid_in & ready_out; //only the data can move out, new data come in
  assign valid_out                                    = data_in_succ | last_out; //the cycle after the last_in should have valid_out

  reg  [2 : 0]                count;                                     //the number of exchange bytes
  reg                         last_next;

  always @(posedge clk) begin //when exchange header byte, set the count and reset the count when exchange next time
    if(!rst_n) count <= 0;
    else if(header_succ & data_in_succ) begin
      case (keep_insert)
        4'b1111 : begin
          count = 4;
        end
        4'b0111 : begin
          count = 3;
        end
        4'b0011 : begin
          count = 2;
        end
        4'b0001 : begin
          count = 1;
        end
        4'b0000 : begin
          count = 0;
        end
        default : begin
          count = 0;
        end
      endcase
    end
  end

  reg                         last_reg;

  always @(*) begin
    if(header_succ & data_in_succ) begin            //exchange header
      keep_out  = 4'b1111;
      last_next = 0;
      case (keep_insert)
        4'b1111 : begin
          data_out = {header_b3, header_b2, header_b1, header_b0};
        end
        4'b0111 : begin
          data_out = {header_b2, header_b1, header_b0, data_b3};
        end
        4'b0011 : begin
          data_out = {header_b1, header_b0, data_b3, data_b2};
        end
        4'b0001 : begin
          data_out = {header_b0, data_b3, data_b2, data_b1};
        end
        4'b0000 : begin
          data_out = {data_b3, data_b2, data_b1, data_b0};
        end
        default : begin
          data_out = data_out;
        end
      endcase
    end

    else if(data_in_succ & last_in & ~|count) begin //header no exchange
      data_out  = data_in;
      keep_out  = keep_in;
      last_next = 0;
    end

    else if(data_in_succ & last_in & |count) begin  //last_in is high, decide data_out this cycle, so what about next cycle?
      if(count == 3'd4) begin
        data_out  = data_reg;
        keep_out  = 4'b1111;
        last_next = 1;
      end
      else if(count == 3'd3) begin
        data_out  = {data_reg[23 : 0], data_in[31 : 24]};
        keep_out  = 4'b1111;
        last_next = 1;
      end
      else if(count == 3'd2) begin
        case (keep_in)
          4'b1111 : begin
            data_out  = {data_reg[15 : 0], data_in[31 : 16]};
            last_next = 1;
            keep_out  = 4'b1111;
          end
          4'b0111 : begin
            data_out  = {data_reg[15 : 0], data_in[23 : 8]};
            last_next = 1;
            keep_out  = 4'b1111;
          end
          4'b0011 : begin
            data_out  = {data_reg[15 : 0], data_in[15 : 0]};
            last_next = 1;
            keep_out  = 4'b1111;
          end
          4'b0001 : begin
            data_out  = {data_reg[15 : 0], data_in[7 : 0], 8'b0};
            last_next = 0;
            keep_out  = 4'b1110;
          end
          default : begin
            data_out  = data_out;
            last_next = 0;
            keep_out  = 4'b0000;
          end
        endcase
      end
      else if(count == 3'd1) begin
        case (keep_in)
          4'b1111 : begin
            data_out  = {data_reg[7 : 0], data_in[31 : 8]};
            keep_out  = 4'b1111;
            last_next = 1;
          end
          4'b0111 : begin
            data_out  = {data_reg[7 : 0], data_in[23 : 0]};
            keep_out  = 4'b1111;
            last_next = 1;
          end
          4'b0011 : begin
            data_out  = {data_reg[7 : 0], data_in[15 : 0], 8'b0};
            keep_out  = 4'b1110;
            last_next = 0;
          end
          4'b0001 : begin
            data_out  = {data_reg[7 : 0], data_in[7 : 0], 16'b0};
            keep_out  = 4'b1100;
            last_next = 0;
          end
          default : begin
            data_out  = data_out;
            keep_out  = 4'b0000;
            last_next = 0;
          end
        endcase
      end
      else begin
        data_out  = data_out;
        keep_out  = 4'b0000;
        last_next = 0;
      end
    end

    else if(last_reg) begin                         //last_in is high, this branch is next cycle
      last_next = 1;
      if(count == 3'd4) begin
        data_out  = data_reg;
        keep_out  = keep_reg;
      end
      else if(count == 3'd3) begin
        case (keep_reg)
          4'b1111 : begin
            data_out = {data_reg[23 : 0], 8'b0};
            keep_out = 4'b1110;
          end
          4'b1110 : begin
            data_out = {data_reg[23 : 8], 16'b0};
            keep_out = 4'b1100;
          end
          4'b1100 : begin
            data_out = {data_reg[23 : 16], 24'b0};
            keep_out = 4'b1000;
          end
          default : begin
            data_out = 32'b0;
            keep_out = 4'b0000;
          end
        endcase
      end
      else if(count == 3'd2) begin
        case (keep_reg)
          4'b1111 : begin
            data_out = {data_reg[15 : 0], 16'b0};
            keep_out = 4'b1100;
          end
          4'b1110 : begin
            data_out = {data_reg[15 : 8], 24'b0};
            keep_out = 4'b1000;
          end
          default : begin
            data_out = 32'b0;
            keep_out = 4'b0000;
          end
        endcase
      end
      else if(count == 3'd1) begin
        case (keep_reg)
          4'b1111 : begin
            data_out = {data_reg[7 : 0], 24'b0};
            keep_out = 4'b1000;
          end
          default : begin
            data_out = 32'b0;
            keep_out = 4'b0000;
          end
        endcase
      end
      else begin
        data_out  = 32'b0;
        keep_out  = 4'b0000;
      end
    end

    else if(data_in_succ) begin                     //exchange the middle bytes
      keep_out  = 4'b1111;
      last_next = 0;
      case (count)
        3'd4 : data_out    = data_reg;
        3'd3 : data_out    = {data_reg[23 : 0], data_in[31 : 24]};
        3'd2 : data_out    = {data_reg[15 : 0], data_in[31 : 16]};
        3'd1 : data_out    = {data_reg[7 : 0], data_in[31 : 8]};
        3'd0 : data_out    = data_in;
        default : data_out = data_in;
      endcase
    end

    else begin                                      //for other circumstances, reset all outputs
      data_out  = 32'b0;
      keep_out  = 4'b0;
      last_next = 0;
    end
  end

  always @(posedge clk) begin
    if(!rst_n) last_reg                   <= 0;
    else if(last_in & last_next) last_reg <= last_in;
    else last_reg                         <= 0;
  end
  assign last_out                                     = last_next ? last_reg : last_in;


endmodule

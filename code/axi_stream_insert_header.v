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
    output reg                        valid_out,
    output     [DATA_WD - 1 : 0]      data_out,
    output reg [DATA_BYTE_WD - 1 : 0] keep_out,
    output                            last_out,
    input                             ready_out,
// The header to be inserted to AXI Stream input
    input                             valid_insert,
    input      [DATA_WD - 1 : 0]      header_insert,
    input      [DATA_BYTE_WD - 1 : 0] keep_insert,
    output reg                        ready_insert
  );

  localparam                       KEEP_WD           = $clog2(DATA_BYTE_WD);

//handshake
  wire                             header_fire;
  assign header_fire = ready_insert && valid_insert;
  wire                             data_fire;
  assign data_fire   = ready_in && valid_in;                                          //fire only decides on valid and ready


  reg                              last_reg;
  always @(posedge clk) last_reg <= (!rst_n) ? 0 : last_in;

  reg                              valid_insert_reg;                        //this signal will keep high from valid_insert is high to valid_out is low
  always @(posedge clk) begin
    if(!rst_n) valid_insert_reg            <= 0;
    else if(valid_insert) valid_insert_reg <= 1;
    else if(last_out) valid_insert_reg     <= 0;
  end

  reg                              insert_shake_once;                       //to confirm that insert_ready is high only 1 cycle
  always @(posedge clk) begin
    if(!rst_n) insert_shake_once           <= 0;
    else if(header_fire) insert_shake_once <= 1;
    else if(last_out) insert_shake_once    <= 0;
  end

  always @(*) begin //assert ready_insert
    if(!valid_in || insert_shake_once) ready_insert = 0;
    else if(last_reg) ready_insert                  = 0;
    else ready_insert                               = 1;
  end

  always @(*) begin //assert ready_in
    if(!ready_out) ready_in                               = 0; //TODO: how to use ready_out?
    else if(!(valid_insert || valid_insert_reg)) ready_in = 0;
    else if(last_reg) ready_in                            = 0;
    else ready_in                                         = 1;
  end

  reg        [KEEP_WD : 0]         data_count;
  reg        [KEEP_WD : 0]         data_count_reg;
  reg        [KEEP_WD : 0]         header_count_reg;                        //the number of exchange bytes
  reg        [KEEP_WD : 0]         header_count;
  reg                              last_next;

  integer                          i, j;                                    //implement a priority encoder with for
  always @(*) begin
    data_count = 0;
    for(i = DATA_BYTE_WD - 1; i >= 0; i = i - 1) begin
      if(keep_in[i]) data_count = DATA_BYTE_WD - i;
    end
  end
  always @(posedge clk) data_count_reg <= (!rst_n) ? 0 : data_count;

  always @(*) begin
    header_count = 0;
    for(j = 0; j < DATA_BYTE_WD; j = j + 1) begin
      if(keep_insert[j]) header_count = j + 1;
    end
  end

  always @(posedge clk) begin
    if(!rst_n) header_count_reg           <= 0;
    else if(header_fire) header_count_reg <= header_count;
    else if(last_out) header_count_reg    <= 0;
  end

  always @(posedge clk) begin
    if(!rst_n) last_next       <= 0;
    else if(last_in) last_next <= header_count_reg + data_count > DATA_BYTE_WD ? 1 : 0;
    else last_next             <= 0;
  end
  reg                              last_next_1;                             //delay 1 beat
  always @(posedge clk) last_next_1 <= (!rst_n) ? 0 : last_next;
  assign last_out    = last_reg && !last_next ? last_reg : last_next_1;

  always @(posedge clk) begin
    if(!rst_n) keep_out         <= 0;
    else if(last_in) keep_out   <= (header_count_reg + data_count >= DATA_BYTE_WD) ? {DATA_BYTE_WD{1'b1}} : {$signed(keep_in) >>> header_count_reg};
    else if(data_fire) keep_out <= {DATA_BYTE_WD{1'b1}};
    else if(last_next) keep_out <= 4'sb1000 >>> (header_count_reg + data_count_reg - DATA_BYTE_WD - 1); //data_out is 1 beat longer
    else keep_out               <= 0;
  end

  always @(posedge clk) begin
    if(!rst_n) valid_out         <= 0;
    else if(data_fire) valid_out <= 1;
    else if(last_next) valid_out <= 1;
    else if(last_out) valid_out  <= 0;
  end

  reg        [2 * DATA_WD - 1 : 0] shift_reg;
  always @(posedge clk) begin
    if(!rst_n) shift_reg                      <= 0;
    else if(header_fire) shift_reg            <= {header_insert, data_in};
    else if(data_fire || last_next) shift_reg <= {shift_reg[DATA_WD - 1 : 0], data_in};
    else shift_reg                            <= 0;
  end

  wire       [2 * DATA_WD - 1 : 0] shift_res;
  assign shift_res   = shift_reg << ({3'b0, (DATA_BYTE_WD - header_count_reg)} << 3); //add 3 bits width to shift
  assign data_out    = shift_res[2 * DATA_WD - 1 : DATA_WD];

endmodule

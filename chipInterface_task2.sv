`default_nettype none
module chipInterface
  (input logic [3:0] KEY,
   input logic [17:0] SW,
   output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7, HEX8, HEX9,
   output logic [10:0] LEDG, 
	output logic [17:0] LEDR,
   input logic CLOCK_50);

  logic [3:0] tens;
  logic [3:0] ones;
  logic [3:0] round_number;
  logic [2:0] feedback0, feedback1, feedback2, feedback3;
  logic [11:0] guess;
  
  assign guess = {SW[5:0], SW[17:15], SW[14:12]};
  assign HEX4 = 7'b111_1111;
  assign HEX5 = 7'b111_1111;
  assign HEX6 = 7'b111_1111;
  assign HEX7 = 7'b111_1111;

  Task2 t (.start_game(~KEY[1]), .grade_it(~KEY[0]), .guess(guess),
           .feedback0(feedback0), .feedback1(feedback1), .feedback2(feedback2), 
           .feedback3(feedback3), .round_number(round_number), .reset(~KEY[3]),
           .clock(CLOCK_50), .won(LEDG[0]), .lost(LEDR[0]));
  
  always_comb begin
    if (round_number >= 4'd10) begin
      tens = 4'd1;
      ones = round_number - 4'd10;
	 end
    else begin
      tens = 4'd0;
      ones = round_number;
	 end
  end
  
  BCDtoSevenSegment b0 (.bcd({1'b0, feedback0}), .segment(HEX0));
  BCDtoSevenSegment b1 (.bcd({1'b0, feedback1}), .segment(HEX1));
  BCDtoSevenSegment b2 (.bcd({1'b0, feedback2}), .segment(HEX2));
  BCDtoSevenSegment b3 (.bcd({1'b0, feedback3}), .segment(HEX3));
  BCDtoSevenSegment b4 (.bcd(ones), .segment(HEX8));
  BCDtoSevenSegment b5 (.bcd(tens), .segment(HEX9));

endmodule: chipInterface
  
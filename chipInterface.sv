`default_nettype none

module chipInterface
    (input logic [3:0] KEY,
    input logic [17:0] SW,
    output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7, HEX8, HEX9,
    output logic [10:0] LEDG,
    output logic [17:0] LEDR,
    input logic CLOCK_50,
    output logic NEO_DATA);

    logic [3:0] tens;
    logic [3:0] ones;
    logic [3:0] round_number;
	 logic [11:0] guess;

    Task3 DUT(.start_game(~KEY[1]), .grade_it(~KEY[0]), .load_color(~KEY[2]),
    .color_to_load(SW[9:7]), .color_location({SW[10], SW[11]}), .guess(guess),
    .neopixel_data(NEO_DATA), .won(LEDG[0]), .lost(LEDR[0]),
    .round_number(round_number),  .clock(CLOCK_50), .reset(~KEY[3]));

    assign guess = {SW[5:0], SW[12], SW[13], SW[14], SW[15], SW[16], SW[17]};
    assign HEX0 = 7'b111_1111;
    assign HEX1 = 7'b111_1111;
    assign HEX2 = 7'b111_1111;
    assign HEX3 = 7'b111_1111;
    assign HEX4 = 7'b111_1111;
    assign HEX5 = 7'b111_1111;
    assign HEX6 = 7'b111_1111;
    assign HEX7 = 7'b111_1111;

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

    BCDtoSevenSegment b4 (.bcd(ones), .segment(HEX8));
    BCDtoSevenSegment b5 (.bcd(tens), .segment(HEX9));

endmodule: chipInterface
`default_nettype none

module Feedback
    (input logic [2:0] red, white,
    output logic [2:0] feedback0, feedback1, feedback2, feedback3,
    output logic won);

    always_comb begin
        won = 1'b0;
        case (red)
            3'd4: begin
                feedback0 = 3'b111;
                feedback1 = 3'b111;
                feedback2 = 3'b111;
                feedback3 = 3'b111;
                won = 1'b1;
            end
            3'd3: begin
                feedback0 = 3'b111;
                feedback1 = 3'b111;
                feedback2 = 3'b111;
                if (white == 3'd1) feedback3 = 3'b001;
                else feedback3 = 3'b000;
            end
            3'd2: begin
                feedback0 = 3'b111;
                feedback1 = 3'b111;
                if (white == 3'd2) begin
                    feedback2 = 3'b001;
                    feedback3 = 3'b001;
                end
                else if (white == 3'd1) begin
                    feedback2 = 3'b001;
                    feedback3 = 3'b000;
                end
                else begin
                    feedback2 = 3'b000;
                    feedback3 = 3'b000;
                end
            end
            3'd1: begin
                feedback0 = 3'b111;
                if (white == 3'd3) begin
                    feedback1 = 3'b001;
                    feedback2 = 3'b001;
                    feedback3 = 3'b001;
                end
                else if (white == 3'd2) begin
                    feedback1 = 3'b001;
                    feedback2 = 3'b001;
                    feedback3 = 3'b000;
                end
                else if (white == 3'd1) begin
                    feedback1 = 3'b001;
                    feedback2 = 3'b000;
                    feedback3 = 3'b000;
                end
                else begin
                    feedback1 = 3'b000;
                    feedback2 = 3'b000;
                    feedback3 = 3'b000;
                end
            end
            3'd0: begin
                if (white == 3'd4) begin
                    feedback0 = 3'b001;
                    feedback1 = 3'b001;
                    feedback2 = 3'b001;
                    feedback3 = 3'b001;
                end
                else if (white == 3'd3) begin
                    feedback0 = 3'b001;
                    feedback1 = 3'b001;
                    feedback2 = 3'b001;
                    feedback3 = 3'b000;
                end
                else if (white == 3'd2) begin
                    feedback0 = 3'b001;
                    feedback1 = 3'b001;
                    feedback2 = 3'b000;
                    feedback3 = 3'b000;
                end
                else if (white == 3'd1) begin
                    feedback0 = 3'b001;
                    feedback1 = 3'b000;
                    feedback2 = 3'b000;
                    feedback3 = 3'b000;
                end
                else begin
                    feedback0 = 3'b000;
                    feedback1 = 3'b000;
                    feedback2 = 3'b000;
                    feedback3 = 3'b000;
                end
            end
            default begin
                feedback0 = 3'b000;
                feedback1 = 3'b000;
                feedback2 = 3'b000;
                feedback3 = 3'b000;
            end
        endcase
    end

endmodule: Feedback


module Feedback_test;
    logic [2:0] red, white;
    logic [2:0] feedback0, feedback1, feedback2, feedback3;

    Feedback dut (.*);

    initial begin
        $monitor($time,, "Red:%d, White:%d, f0:%b f1:%b f2:%b f3:%b", 
        red, white, feedback0, feedback1, feedback2, feedback3);

        red = 3'd4;
        white = 3'd0;
        #10;
        red = 3'd3;
        white = 3'd1;
        #10;
        white = 3'd0;
        #10;
        red = 3'd2;
        white = 3'd2;
        #10;
        white = 3'd1;
        #10;
        white = 3'd0;
        #10;
        red = 3'd1;
        white = 3'd3;
        #10;
        white = 3'd2;
        #10;
        white = 3'd1;
        #10;
        white = 3'd0;
        #10;
        red = 3'd0;
        white = 3'd4;
        #10;
        white = 3'd3;
        #10;
        white = 3'd2;
        #10;
        white = 3'd1;
        #10;
        white = 3'd0;
        #10;
        #10 $finish;
    end

endmodule: Feedback_test
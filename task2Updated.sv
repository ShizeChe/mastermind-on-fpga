`default_nettype none
 
module Task2
   (input logic start_game, grade_it,
   input logic [11:0] guess,
   output logic [2:0] feedback0, feedback1, feedback2, feedback3,
   output logic [3:0] round_number, //HEX
   output logic won, lost,
   input logic clock, reset);
 
   logic f_load, f_clear, c_en, c_clear;
   logic [11:0] pattern;
   logic [2:0] red, white;
   logic round_10;
   logic [3:0] round;
 
   assign pattern = 12'b010_100_010_101;
   assign round_number = round + 4'd1;
   logic [2:0] f0, f1, f2, f3;
 
   Register #(3) r0(.D(f0), .en(f_load), .clear(f_clear), .Q(feedback0),
                   .clock(clock));
   Register #(3) r1(.D(f1), .en(f_load), .clear(f_clear), .Q(feedback1),
                   .clock(clock));
   Register #(3) r2(.D(f2), .en(f_load), .clear(f_clear), .Q(feedback2),
                   .clock(clock));
   Register #(3) r3(.D(f3), .en(f_load), .clear(f_clear), .Q(feedback3),
                   .clock(clock));
   Grader g(.red(red), .white(white), .guess0(guess[11:9]),.guess1(guess[8:6]),
           .guess2(guess[5:3]), .guess3(guess[2:0]), .pattern0(pattern[11:9]),
           .pattern1(pattern[8:6]), .pattern2(pattern[5:3]),
           .pattern3(pattern[2:0]));
   Feedback f(.feedback0(f0), .feedback1(f1), .feedback2(f2), .feedback3(f3),
               .red(red), .white(white));
   Counter #(4) ct(.Q(round), .up(1'b1), .load(1'b0),
                   .clear(c_clear), .enable(c_en), .clock(clock));
   MagComp #(4) mc (.A(round), .B(4'd10), .AeqB(round_10));
   fsm m(.*);
	assign won = (feedback0==3'b111 & feedback1==3'b111 & feedback2==3'b111 &
	               feedback3==3'b111);
   assign lost = round_10 & ~won;
 
endmodule: Task2


module Grader
  (input  logic[2:0] guess0, guess1, guess2, guess3,
   input  logic[2:0] pattern0, pattern1, pattern2, pattern3,
   output logic[2:0] red, white);
  
  logic red0, red1, red2, red3;
  logic white0, white1, white2, white3;
  logic p0used, p1used, p2used, p3used;

  /*MagComp mc1 (.A(guess0), .B(pattern0), .AeqB(red0));
  MagComp mc2 (.A(guess1), .B(pattern1), .AeqB(red0));
  MagComp mc3 (.A(guess2), .B(pattern0), .AeqB(red0));
  MagComp mc4 (.A(guess3), .B(pattern0), .AeqB(red0));*/

  assign red0 = (guess0 == pattern0);
  assign red1 = (guess1 == pattern1);
  assign red2 = (guess2 == pattern2);
  assign red3 = (guess3 == pattern3);

  assign red = red0 + red1 + red2 + red3;

  always_comb begin
    white0 = 1'b0; 
    white1 = 1'b0; 
    white2 = 1'b0; 
    white3 = 1'b0;
    p0used = 1'b0; 
    p1used = 1'b0; 
    p2used = 1'b0; 
    p3used = 1'b0;
    if (~red0) begin
      if (guess0 == pattern1 & ~red1 & ~p1used) begin
        white0 = 1'b1;
        p1used = 1'b1;
      end
      else if (guess0 == pattern2 & ~red2 & ~p2used)begin
        white0 = 1'b1;
        p2used = 1'b1;
      end
      else if (guess0 == pattern3 & ~red3 & ~p3used) begin
        white0 = 1'b1;
        p3used = 1'b1;
      end
    end

    if (~red1) begin
      if (guess1 == pattern0 & ~red0 & ~p0used) begin
        white1 = 1'b1;
        p0used = 1'b1;
      end
      else if (guess1 == pattern2 & ~red2 & ~p2used) begin
        white1 = 1'b1;
        p2used = 1'b1;
      end
      else if (guess1 == pattern3 & ~red3 & ~p3used) begin
        white1 = 1'b1;
        p3used = 1'b1;
      end
    end

    if (~red2) begin
      if (guess2 == pattern0 & ~red0 & ~p0used) begin
        white2 = 1'b1;
        p0used = 1'b1;
      end
      else if (guess2 == pattern1 & ~red1 & ~p1used) begin
        white2 = 1'b1;
        p1used = 1'b1;
      end
      else if (guess2 == pattern3 & ~red3 & ~p3used) begin
        white2 = 1'b1;
        p3used = 1'b1;
      end
    end

    if (~red3) begin
      if (guess3 == pattern0 & ~red0 & ~p0used) begin
        white3 = 1'b1;
        p0used = 1'b1;
      end
      else if (guess3 == pattern1 & ~red1 & ~p1used) begin
        white3 = 1'b1;
        p1used = 1'b1;
      end
      else if (guess3 == pattern2 & ~red2 & ~p2used) begin
        white3 = 1'b1;
        p2used = 1'b1;
      end
  end
  end
  
  assign white = white0 + white1 + white2 + white3;


endmodule: Grader

module Feedback
   (input logic [2:0] red, white,
   output logic [2:0] feedback0, feedback1, feedback2, feedback3);
 
   always_comb begin
       case (red)
           3'd4: begin
               feedback0 = 3'b111;
               feedback1 = 3'b111;
               feedback2 = 3'b111;
               feedback3 = 3'b111;
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

module fsm
 (input  logic start_game, grade_it, won, lost,
  input  logic clock, reset,
  output logic c_clear, c_en, f_clear, f_load);
  enum logic [1:0] {Waiting=2'b00, Guessing=2'b01, Holding=2'b10,
             Grading=2'b11} currState, nextState;
 
 always_comb begin
   unique case (currState)
     Waiting: begin
              nextState = (start_game) ? Guessing : Waiting;
              c_clear = (start_game) ? 1'b1 : 1'b0;
              //revisit this (c_en), no specified value for transition w to g
              c_en = 1'b0;
              f_load = 1'b0;
              f_clear = (start_game) ? 1'b1 : 1'b0;
              end
     Guessing: begin
               nextState = (grade_it) ? Holding : Guessing;
               c_clear = 1'b0; //revisit
               c_en = 1'b0;
               f_load = 1'b0;
               f_clear = 1'b0; //revisit
               end
	  Holding: begin
	           nextState = (grade_it) ? Holding : Grading;
				  c_clear = 1'b0; //revisit
              c_en = (grade_it) ? 1'b0 : 1'b1;
              f_load = (grade_it) ? 1'b0 : 1'b1;
              f_clear = 1'b0; //revisit
 	           end
     Grading: begin
              nextState = (won | lost) ? Waiting : Guessing;
              c_clear = 1'b0;
              c_en = 1'b0;
              f_load = 1'b0; //revisit
              f_clear = 1'b0;
              end
   endcase
 end
 
 always_ff @(posedge clock) begin
   if (reset)
     currState <= Waiting;
   else
     currState <= nextState;
 end
 
endmodule: fsm

/*module Task2_test;
   logic start_game, grade_it;
   logic [11:0] guess;
   logic [2:0] feedback0, feedback1, feedback2, feedback3;
   logic [3:0] round_number; //HEX
   logic won, lost;
   logic clock, reset;
 
   Task2 dut (.*);
 
   initial begin
       $monitor($time, "Start:%b Grading:%b Round:%d guess:%b \
f0:%b f1:%b f2:%b f3:%b won:%b lost:%b cclear:%b cen:%b", start_game, grade_it,
       round_number,
       guess, feedback0, feedback1, feedback2, feedback3, won, lost,
       fsm.c_clear, fsm.c_en);
       clock = 1'b0;
       forever #10 clock = ~clock;
   end
 
   initial begin
       reset<=1'b1;
       @(posedge clock);
       reset<=1'b0;
       guess <= 12'b101_010_101_010;
       start_game <= 1'b0;
       grade_it <= 1'b0;
       @(posedge clock);
       start_game <= 1'b1;
       @(posedge clock);
       guess <= 12'b101_010_101_010;
       @(posedge clock);
       guess <= 12'b111_011_101_010;
       grade_it <=1'b1;
       @(posedge clock);
       guess <= 12'b111_011_111_011;
       grade_it <=1'b0;
       @(posedge clock);
       //win
       guess <= 12'b010_100_010_101;
       grade_it <=1'b1;
       @(posedge clock);
       @(posedge clock);
       guess <= 12'b111_100_010_101;
       grade_it <=1'b0;
       @(posedge clock);
       guess <= 12'b111_100_010_101;
       grade_it <=1'b1;
       @(posedge clock);
       reset<=1'b1;
       @(posedge clock);
       reset<=1'b0;
       @(posedge clock);
       @(posedge clock);
       @(posedge clock);
       #10 $finish;
 
   end
endmodule: Task2_test*/
`default_nettype none

module Grader
  (input  logic[2:0] guess0, guess1, guess2, guess3,
   input  logic[2:0] pattern0, pattern1, pattern2, pattern3,
   output logic[2:0] red, white);
  
  logic red0, red1, red2, red3;
  logic white0, white1, white2, white3;
  logic p0used, p1used, p2used, p3used;

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

module Grader_test;
  
  logic[2:0] guess0, guess1, guess2, guess3;
  logic[2:0] pattern0, pattern1, pattern2, pattern3;
  logic[2:0] red, white; 

  Grader dut (.*);

  initial begin
    $monitor("red=%b, white=%b", red, white);
    guess0 = 3'b001; guess1 = 3'b001; guess2 = 3'b001; guess3 = 3'b001;
    pattern0 = 3'b000; pattern1 = 3'b000; pattern2 = 3'b000; pattern3 = 3'b000;
    //red = 000 white = 000
    #10 
    guess0 = 3'b001; guess1 = 3'b001; guess2 = 3'b001; guess3 = 3'b001;
    pattern0 = 3'b001; pattern1 = 3'b001; pattern2 = 3'b001; pattern3 = 3'b001;
    //red = 100 white = 000
    #10 
    guess0 = 3'b100; guess1 = 3'b001; guess2 = 3'b001; guess3 = 3'b001;
    pattern0 = 3'b010; pattern1 = 3'b100; pattern2 = 3'b100; pattern3 = 3'b100;
    //red = 000 white = 001
    #10 
    guess0 = 3'b100; guess1 = 3'b001; guess2 = 3'b010; guess3 = 3'b011;
    pattern0 = 3'b010; pattern1 = 3'b100; pattern2 = 3'b011; pattern3 = 3'b001;
    //red = 000 white = 100
    #10 $finish;
  end
endmodule: Grader_test
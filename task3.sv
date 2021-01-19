`default_nettype none
module Task3
 (input  logic start_game, grade_it, load_color,
  input  logic [2:0] color_to_load,
  input  logic [1:0] color_location,
  input  logic [11:0] guess,
  output logic        neopixel_data,
  output logic [3:0] round_number, //HEX 
  output logic won, lost,
  input  logic clock, reset);
 
 logic [23:0] colorIn;
 logic [2:0] pixel;
 logic color_valid, location_valid;
 logic f_load, f_clear, c_en, c_clear, p0_clear, p1_clear,
       p2_clear, p3_clear, p0_en, p1_en, p2_en, p3_en,
       n_reset, n_load, n_go, ready, round_10, bms_clear, bms_en;
 logic [1:0] smSel;
 logic [2:0] red, white, f0, f1, f2, f3, feedback0, feedback1,
             feedback2, feedback3, pattern0, pattern1, pattern2,
             pattern3, bmOut, smOut, not_loaded;
 logic [3:0] bmSel, round;
 
 assign round_number = round + 4'd1;
 assign won = (feedback0==3'b011 & feedback1==3'b011 & feedback2==3'b011 &
             feedback3==3'b011);
 assign lost = round_10 & ~won;
 
 PatternReg pr0 (.D(color_to_load), .Q(pattern0), .clock(clock),
                 .clear(p0_clear), .en(p0_en));
 PatternReg pr1 (.D(color_to_load), .Q(pattern1), .clock(clock),
                 .clear(p1_clear), .en(p1_en));
 PatternReg pr2 (.D(color_to_load), .Q(pattern2), .clock(clock),
                 .clear(p2_clear), .en(p2_en));
 PatternReg pr3 (.D(color_to_load), .Q(pattern3), .clock(clock),
                 .clear(p3_clear), .en(p3_en));
 not_loaded nl (.pattern0(pattern0), .pattern1(pattern1), .pattern2(pattern2),
                .pattern3(pattern3), .not_loaded(not_loaded));
 Grader g(.red(red), .white(white), .guess0(guess[2:0]),.guess1(guess[5:3]),
          .guess2(guess[8:6]), .guess3(guess[11:9]), .pattern0(pattern0),
          .pattern1(pattern1), .pattern2(pattern2), .pattern3(pattern3));
 Feedback f(.feedback0(f0), .feedback1(f1), .feedback2(f2), .feedback3(f3),
              .red(red), .white(white));
 Register #(3) r0(.D(f0), .en(f_load), .clear(f_clear), .Q(feedback0),
                  .clock(clock));
 Register #(3) r1(.D(f1), .en(f_load), .clear(f_clear), .Q(feedback1),
                  .clock(clock));
 Register #(3) r2(.D(f2), .en(f_load), .clear(f_clear), .Q(feedback2),
                  .clock(clock));
 Register #(3) r3(.D(f3), .en(f_load), .clear(f_clear), .Q(feedback3),
                  .clock(clock));
 Counter #(4) ldct(.Q(bmSel), .up(1'b1), .load(1'b0),
                   .clear(bms_clear), .enable(bms_en), .clock(clock));
 Mux8to1 bm (.I0(guess[2:0]),  .I1(guess[5:3]), .I2(guess[8:6]),
             .I3(guess[11:9]), .I4(feedback0),  .I5(feedback1),
             .I6(feedback2),   .I7(feedback3),  .Y(bmOut), .sel(bmSel));
 Mux4to1 sm (.I0(color_to_load), .I1(bmOut), .I2(3'b000), .I3(3'b111),
             .Y(smOut), .sel(smSel));
 getRgb rgb (.color(smOut), .rgb(colorIn));
 NeopixelController npc (.red(colorIn[23:16]), .green(colorIn[15:8]),
                        .blue(colorIn[7:0]), .pixel(pixel), .CLOCK_50(clock),
                        .reset(n_reset), .load(n_load), .go(n_go),
                        .neopixel_data(neopixel_data), .ready(ready));
 checkColor cc (.color(color_to_load), .color_valid(color_valid));
 checkLocation cl (.pattern0(pattern0), .pattern1(pattern1),
                   .pattern2(pattern2), .pattern3(pattern3),
                   .location(color_location), .location_valid(location_valid));
 Counter #(4) ct (.Q(round), .up(1'b1), .load(1'b0),
                  .clear(c_clear), .enable(c_en), .clock(clock));
 MagComp #(4) mc (.A(round), .B(4'd10), .AeqB(round_10));
 fsm m (.*);
endmodule: Task3
 
module fsm
 (input  logic color_valid, location_valid, load_color, start_game, grade_it,
               ready, won, lost,
  input  logic clock, reset,
  input  logic [1:0] color_location,
  input  logic [2:0] not_loaded,
  output logic c_clear, c_en, f_clear, f_load, p0_clear, p0_en, p1_clear,
               p1_en, p2_clear, p2_en, p3_clear, p3_en, n_reset, n_load, n_go,
               bms_clear, bms_en,
  output logic [1:0] smSel,
  output logic [2:0] pixel,
  input  logic [3:0] bmSel);
 
 enum {Ld_pattern0, Ld_pattern1, Ld_pattern2, Ld_pattern3, Loading, White, Wait_color, 
       Load_blank0, Load_blank1, Load_blank2, Load_blank3, Load_blank4, Load_blank5, Load_blank6, Load_blank7,
		 Wait_reset, Guessing, Holding, Ld_guefee, Wait_guefee, Grading, ResetNeo, WaitNeo} currState, nextState;
 
 always_comb begin
        n_reset = 1'b0; n_load = 1'b0; n_go = 1'b0;
        p0_en = 1'b0; p0_clear = 1'b0;
        p1_en = 1'b0; p1_clear = 1'b0;
        p2_en = 1'b0; p2_clear = 1'b0;
        p3_en = 1'b0; p3_clear = 1'b0;
        c_en = 1'b0; c_clear = 1'b0;
        f_load = 1'b0; f_clear = 1'b0;
        pixel = 3'b000;
        bms_clear = 1'b0; bms_en = 1'b0;
        smSel = 2'b0;
   unique case (currState)
     Ld_pattern0: begin
       if (~color_valid | ~location_valid | ~load_color) begin
         nextState = Ld_pattern0;
         p0_clear = 1'b1; 
         p1_clear = 1'b1; 
         p2_clear = 1'b1;
         p3_clear = 1'b1;
         bms_clear = 1'b1;
       end
       else begin
         nextState = Loading;
         c_clear = 1'b1;
			n_load = 1'b1;
			f_clear = 1'b1;
         if (color_location==2'b00) begin
           pixel = 3'b111;
           p0_en = 1'b1;
         end
         else if (color_location==2'b01) begin
           pixel = 3'b110;
           p1_en = 1'b1;
         end
         else if (color_location==2'b10) begin
           pixel = 3'b101;
           p2_en = 1'b1;
         end
         else begin
           pixel = 3'b100;
           p3_en = 1'b1;
         end
       end
     end
     Loading: begin
       nextState = White;
       n_load = 1'b1;
       smSel = 2'b10;
       if (color_location==2'b00)
         pixel = 3'b011;
       else if (color_location==2'b01)
         pixel = 3'b010;
       else if (color_location==2'b10)
         pixel = 3'b001;
       else
         pixel = 3'b000;
     end
	  White: begin
		   nextState = Wait_color;
			n_go = 1'b1;
	  end
     Wait_color: begin
       if (ready) begin
         if (not_loaded==3'b011) begin
           nextState = Ld_pattern1;
         end
         else if (not_loaded==3'b010) begin
           nextState = Ld_pattern2;
         end
         else if (not_loaded==3'b001) begin
           nextState = Ld_pattern3;
         end
         else begin
           nextState = (start_game) ? Load_blank0 : Wait_color;
			  pixel = 3'b000;
			  n_load = (start_game) ? 1'b1 : 1'b0;
			  smSel = 2'b11;
         end
       end
       else begin
         nextState = Wait_color;
       end
     end
     Load_blank0: begin
	    nextState = Load_blank1;
		 pixel = 3'b001;
		 n_load = 1'b1;
		 smSel = 2'b11;
	  end
	  Load_blank1: begin
	    nextState = Load_blank2;
		 pixel = 3'b010;
		 n_load = 1'b1;
		 smSel = 2'b11;
	  end
	  Load_blank2: begin
	    nextState = Load_blank3;
		 pixel = 3'b011;
		 n_load = 1'b1;
		 smSel = 2'b11;
	  end
	  Load_blank3: begin
	    nextState = Load_blank4;
		 pixel = 3'b100;
		 n_load = 1'b1;
		 smSel = 2'b11;
	  end
	  Load_blank4: begin
	    nextState = Load_blank5;
		 pixel = 3'b101;
		 n_load = 1'b1;
		 smSel = 2'b11;
	  end
	  Load_blank5: begin
	    nextState = Load_blank6;
		 pixel = 3'b110;
		 n_load = 1'b1;
		 smSel = 2'b11;
	  end
	  Load_blank6: begin
	    nextState = Load_blank7;
		 pixel = 3'b111;
		 n_load = 1'b1;
		 smSel = 2'b11;
	  end
	  Load_blank7: begin
	    nextState = Wait_reset;
		 n_go = 1'b1;
	  end
     Wait_reset: begin
       if (ready)
         nextState = Guessing;
       else
         nextState = Wait_reset;
     end
     Ld_pattern1: begin
       if (~color_valid | ~location_valid | ~load_color) begin
         nextState = Ld_pattern1;
       end
       else begin
         nextState = Loading;
			n_load = 1'b1;
         if (color_location==2'b00) begin
           pixel = 3'b111;
           p0_en = 1'b1;
         end
         else if (color_location==2'b01) begin
           pixel = 3'b110;
           p1_en = 1'b1;
         end
         else if (color_location==2'b10) begin
           pixel = 3'b101;
           p2_en = 1'b1;
         end
         else begin
           pixel = 3'b100;
           p3_en = 1'b1;
         end
       end
     end
     Ld_pattern2: begin
       if (~color_valid | ~location_valid | ~load_color) begin
         nextState = Ld_pattern2;
       end
       else begin
         nextState = Loading;
			n_load = 1'b1;
         if (color_location==2'b00) begin
           pixel = 3'b111;
           p0_en = 1'b1;
         end
         else if (color_location==2'b01) begin
           pixel = 3'b110;
           p1_en = 1'b1;
         end
         else if (color_location==2'b10) begin
           pixel = 3'b101;
           p2_en = 1'b1;
         end
         else begin
           pixel = 3'b100;
           p3_en = 1'b1;
         end
       end
     end
     Ld_pattern3: begin
       if (~color_valid | ~location_valid | ~load_color) begin
         nextState = Ld_pattern3;
       end
       else begin
         nextState = Loading;
			n_load = 1'b1;
         if (color_location==2'b00) begin
           pixel = 3'b111;
           p0_en = 1'b1;
         end
         else if (color_location==2'b01) begin
           pixel = 3'b110;
           p1_en = 1'b1;
         end
         else if (color_location==2'b10) begin
           pixel = 3'b101;
           p2_en = 1'b1;
         end
         else begin
           pixel = 3'b100;
           p3_en = 1'b1;
         end
       end
     end
     Guessing: begin
       nextState = (grade_it) ? Holding : Guessing;
     end
     Holding: begin
        nextState = (grade_it) ? Holding : Ld_guefee;
        c_en = (grade_it) ? 1'b0 : 1'b1;
        f_load = (grade_it) ? 1'b0 : 1'b1;
		  bms_clear = 1'b1;
     end
     Ld_guefee: begin
       if (ready) begin
         smSel = 2'b01;
         if (bmSel == 4'b0000) begin
			  nextState = Ld_guefee;
           pixel = 3'b111; bms_en = 1'b1; n_load = 1'b1;
         end
         else if (bmSel == 4'b0001) begin
			  nextState = Ld_guefee;
           pixel = 3'b110; bms_en = 1'b1; n_load = 1'b1;
         end
         else if (bmSel == 4'b0010) begin
           nextState = Ld_guefee;
           pixel = 3'b101; bms_en = 1'b1; n_load = 1'b1;
         end
         else if (bmSel == 4'b0011) begin
           nextState = Ld_guefee;
           pixel = 3'b100; bms_en = 1'b1; n_load = 1'b1;
         end
         else if (bmSel == 4'b0100) begin
           nextState = Ld_guefee;
           pixel = 3'b011; bms_en = 1'b1; n_load = 1'b1;
         end
         else if (bmSel == 4'b0101) begin
           nextState = Ld_guefee;
           pixel = 3'b010; bms_en = 1'b1; n_load = 1'b1;
         end
         else if (bmSel == 4'b0110) begin
           nextState = Ld_guefee;
           pixel = 3'b001; bms_en = 1'b1; n_load = 1'b1;
         end
         else if (bmSel == 4'b0111) begin
           nextState = Ld_guefee;
           pixel = 3'b000; bms_en = 1'b1; n_load = 1'b1;
         end
			else begin
			  nextState = Wait_guefee;
			  n_go = 1'b1;
			end
       end
		 else
		   nextState = Ld_guefee;
		end
      Wait_guefee: begin
        if (ready)
          nextState = Grading;
        else
          nextState = Wait_guefee;
      end
      Grading: begin
        nextState = (won | lost) ? ResetNeo : Guessing;
        p0_clear = (won | lost) ? 1'b1 : 1'b0;
        p1_clear = (won | lost) ? 1'b1 : 1'b0;
        p2_clear = (won | lost) ? 1'b1 : 1'b0;
        p3_clear = (won | lost) ? 1'b1 : 1'b0;
      end
      /*default: begin
        nextState = Wait_white;
        p0_en = 1'b0; p1_en = 1'b0; p2_en = 1'b0; p3_en = 1'b0;
        p0_clear = 1'b0;
        p1_clear = 1'b0;
        p2_clear = 1'b0;
        p3_clear = 1'b0;
        n_load = 1'b0; n_go = 1'b0; n_reset = 1'b0;
        smSel = 2'b00;
        bms_clear = 1'b0; bms_en = 1'b0;
        c_en = 1'b0; c_clear = 1'b0;
        f_load = 1'b0; f_clear = 1'b0;
      end*/
		ResetNeo: begin
		  nextState = WaitNeo;
		  n_reset = 1'b1;
		end
		WaitNeo: begin
		  if (ready)
		    nextState = Ld_pattern0;
		  else
		    nextState = WaitNeo;
		end
      endcase
  end
  always_ff @(posedge clock) begin
    if (reset)
      currState <= ResetNeo;
    else
      currState <= nextState;
  end
endmodule: fsm
 
module Mux8to1
 (input  logic [2:0] I0, I1, I2, I3, I4, I5, I6, I7,
  input  logic [3:0] sel,
  output logic [2:0] Y);
  always_comb begin
   unique case (sel)
     4'b0000: Y = I0;
     4'b0001: Y = I1;
     4'b0010: Y = I2;
     4'b0011: Y = I3;
     4'b0100: Y = I4;
     4'b0101: Y = I5;
     4'b0110: Y = I6;
     4'b0111: Y = I7;
     default: Y = I0;
   endcase
 end
 
endmodule: Mux8to1
 
module Mux4to1
 (input  logic [3:0] I0, I1, I2, I3,
  input  logic [1:0] sel,
  output logic [3:0] Y);
 
 always_comb begin
   unique case (sel)
     2'b00: Y = I0;
     2'b01: Y = I1;
     2'b10: Y = I2;
     2'b11: Y = I3;
     default: Y = I0;
   endcase
 end
 
endmodule: Mux4to1
 
module PatternReg
 (input logic [2:0] D,
  input logic clock, clear, en,
  output logic [2:0] Q);
  always_ff @(posedge clock) begin
   if (en)
     Q <= D;
   else if (~en & clear) //clear only functions when en = 0
     Q <= 3'b111;
 end
 
endmodule: PatternReg
 
module checkColor
 (input logic [2:0] color,
 output logic color_valid);
 
 assign color_valid = (color==3'b000) | (color==3'b001) | (color==3'b010)
                    | (color==3'b011) | (color==3'b100) | (color==3'b101);
 
endmodule: checkColor
 
module checkLocation
 (input  logic [1:0] location,
  input  logic [2:0] pattern0, pattern1, pattern2, pattern3,
  output logic location_valid);
 
 always_comb begin
   unique case (location)
     2'b00: begin
            location_valid = (pattern0==3'b111) ? 1'b1 : 1'b0;
            end
     2'b01: begin
            location_valid = (pattern1==3'b111) ? 1'b1 : 1'b0;
            end
     2'b10: begin
            location_valid = (pattern2==3'b111) ? 1'b1 : 1'b0;
            end
     2'b11: begin
            location_valid = (pattern3==3'b111) ? 1'b1 : 1'b0;
            end
     default: begin
       location_valid = 1'b0;
     end 
   endcase
 end
 
endmodule: checkLocation
 
module getRgb
 (input  logic [2:0] color,
  output logic [23:0] rgb);
  always_comb begin
   unique case (color)
     3'b000: rgb = 24'b0001_0000_0001_0000_0001_0000;
     3'b001: rgb = 24'b0000_0000_0001_0000_0000_0000;
     3'b010: rgb = 24'b0001_0000_0001_0000_0000_0000;
     3'b011: rgb = 24'b0001_0000_0000_0000_0000_0000;
     3'b100: rgb = 24'b0000_0000_0000_0000_0001_0000;
     3'b101: rgb = 24'b0000_0000_0000_0000_0000_0000;
     default: rgb = 24'b0000_0000_0000_0000_0000_0000;
   endcase
 end
 
endmodule: getRgb
 
module Feedback
 (input logic [2:0] red, white,
 output logic [2:0] feedback0, feedback1, feedback2, feedback3);
 always_comb begin
     case (red)
         3'd4: begin
             feedback0 = 3'b011;
             feedback1 = 3'b011;
             feedback2 = 3'b011;
             feedback3 = 3'b011;
         end
         3'd3: begin
             feedback0 = 3'b011;
             feedback1 = 3'b011;
             feedback2 = 3'b011;
             if (white == 3'd1) feedback3 = 3'b000;
             else feedback3 = 3'b101;
         end
         3'd2: begin
             feedback0 = 3'b011;
             feedback1 = 3'b011;
             if (white == 3'd2) begin
                 feedback2 = 3'b000;
                 feedback3 = 3'b000;
             end
             else if (white == 3'd1) begin
                 feedback2 = 3'b000;
                 feedback3 = 3'b101;
             end
             else begin
                 feedback2 = 3'b101;
                 feedback3 = 3'b101;
             end
         end
         3'd1: begin
             feedback0 = 3'b011;
             if (white == 3'd3) begin
                 feedback1 = 3'b000;
                 feedback2 = 3'b000;
                 feedback3 = 3'b000;
             end
             else if (white == 3'd2) begin
                 feedback1 = 3'b000;
                 feedback2 = 3'b000;
                 feedback3 = 3'b101;
             end
             else if (white == 3'd1) begin
                 feedback1 = 3'b000;
                 feedback2 = 3'b101;
                 feedback3 = 3'b101;
             end
             else begin
                 feedback1 = 3'b101;
                 feedback2 = 3'b101;
                 feedback3 = 3'b101;
             end
         end
         3'd0: begin
             if (white == 3'd4) begin
                 feedback0 = 3'b000;
                 feedback1 = 3'b000;
                 feedback2 = 3'b000;
                 feedback3 = 3'b000;
             end
             else if (white == 3'd3) begin
                 feedback0 = 3'b000;
                 feedback1 = 3'b000;
                 feedback2 = 3'b000;
                 feedback3 = 3'b101;
             end
             else if (white == 3'd2) begin
                 feedback0 = 3'b000;
                 feedback1 = 3'b000;
                 feedback2 = 3'b101;
                 feedback3 = 3'b101;
             end
             else if (white == 3'd1) begin
                 feedback0 = 3'b000;
                 feedback1 = 3'b101;
                 feedback2 = 3'b101;
                 feedback3 = 3'b101;
             end
             else begin
                 feedback0 = 3'b101;
                 feedback1 = 3'b101;
                 feedback2 = 3'b101;
                 feedback3 = 3'b101;
             end
         end
         default begin
             feedback0 = 3'b101;
             feedback1 = 3'b101;
             feedback2 = 3'b101;
             feedback3 = 3'b101;
         end
     endcase
 end
endmodule: Feedback
 
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
 
module not_loaded
  (input logic [2:0] pattern0, pattern1, pattern2, pattern3,
  output logic [2:0] not_loaded);
  assign not_loaded = (pattern0 == 3'b111) + (pattern1 == 3'b111) +
                      (pattern2 == 3'b111) + (pattern3 == 3'b111);
endmodule: not_loaded

/*module Task3_test;
  logic start_game, grade_it, load_color;
  logic [2:0] color_to_load;
  logic [1:0] color_location;
  logic [11:0] guess;
  logic        neopixel_data;
  logic [3:0] round_number; //HEX 
  logic won, lost;
  logic clock, reset;

  Task3 dut(.*);

  initial begin
    $monitor($time,, "state:%s color:%b pixel:%b", dut.m.currState, dut.colorIn,
             dut.pixel);
    clock = 1'b0;
    forever #2 clock = ~clock;
  end

  initial begin
    reset <= 1'b1;
    @(posedge clock);
    reset <= 1'b0;
    color_to_load <= 3'b011;
    color_location <= 2'b00;
    load_color <= 1'b1;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    wait(dut.ready);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    wait(dut.ready);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    #10 $finish;
  end

endmodule: Task3_test*/
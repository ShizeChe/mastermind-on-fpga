module fsm
  (input  logic start_game, grade_it, won, lost,
   input  logic clock, reset,
   output logic c_clear, c_en, f_clear, f_load);
  
  enum [1:0] {Waiting=2'b00, Guessing=2'b01, 
              Grading=2'b10} currState, nextState;

  always_comb begin
    unique case (currState)
      Waiting: begin
               nextState = (start_game) ? Guessing : Waiting;
               c_clear = (start_game) ? 1'b1 : 1'b0;
               //revisit this (c_en), no specified value for transition w to g
               c_en = 1'b0; 
               f_load = 1'b0;
               f_clear = 1'b0;
               end
      Guessing: begin
                nextState = (grade_it) ? Grading : Guessing;
                c_clear = 1'b0; //revisit
                c_en = (grade_it) ? 1'b1 : 1'b0;
                f_load = (grade_it) ? 1'b1 : 1'b0;
                f_clear = 1'b0; //revisit
                end
      Grading: begin
               nextState = (won | lost) ? Waiting : Grading;
               c_clear = 1'b0;
               c_en = 1'b0;
               f_load = 1'b0; //revisit
               f_clear = (won | lost) ? 1'b1 : 1'b0;
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

module fsm_test;
  logic start_game, grade_it, won, lost;
  logic clock, reset;
  logic c_clear, c_en, f_clear, f_load;

  initial begin
    clock = 1'b0;
    forever #2 clock = ~clock;
  end

  fsm dut (.*);

  initial begin
    $monitor($time,, "c_clear=%b c_en=%b f_clear=%b f_load=%b",
              c_clear, c_en, f_clear, f_load);
    #1 reset <= 1'b1; //0
    @(posedge clock) //2
    #1 reset <= 1'b0; start_game <= 1'b0; //3
    @(posedge clock) //6
    #1 start_game <= 1'b1; //7
    @(posedge clock) //10
    #1 grade_it <= 1'b0; //11
    @(posedge clock) //14
    #1 grade_it <= 1'b1; //15
    @(posedge clock) //18
    #1 won <= 1'b0; lost <= 1'b0; //19
    @(posedge clock) //22
    #1 grade_it <= 1'b1; //23
    @(posedge clock) //26
    #1 won <= 1'b1; //27
    @(posedge clock) //30
    @(posedge clock) //34
    @(posedge clock) //38
    $finish;
  end

endmodule: fsm_test
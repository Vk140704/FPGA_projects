module door_lock(
  input clk,
  input [15:0]sw,
  input [4:0]pw,
  output reg [15:0]led,
  output reg  buzzer);
  
  wire rst = pw[0];
  wire enter = pw[4];
  
  wire [3:0]digit0 = sw[3:0];
  wire [3:0]digit1 = sw[7:4];
  wire [3:0]digit2 = sw[11:8];
  wire [3:0]digit3 = sw[15:12];
  
  localparam [3:0]pass0 = 4'd1;
  localparam [3:0]pass1 = 4'd4;
  localparam [3:0]pass2 = 4'd1;
  localparam [3:0]pass3 = 4'd4;
  
  
  localparam open_duration = 28'd250_000_000;
  
  localparam idle =2'd0;
  localparam matched = 2'd1;
  localparam unmatched = 2'd2;
  
  reg [1:0]state;
  reg [27:0]dur;
  reg enter_pre;
  
  wire ent_rising =  enter & ~enter_pre ;
  
  wire key_match = (digit0 == pass0)&&(digit1 == pass1)&&(digit2 == pass2)&&(digit3 == pass3);
  
  always@(posedge clk or posedge rst)begin
    if(rst)begin
      state <= idle;
      enter_pre <= 1'b0;
      dur <= 28'b0;
      led <= 16'b0;
      buzzer <= 0;
    end
  else begin
    enter_pre <=enter;
    
    case(state)
  
      idle : begin
        led <= 16'd0;
        dur <= 28'd0;
      if (ent_rising)state<= key_match ? matched : unmatched;
      end
      
      matched :  begin
        led[0] <= 1'b1;
        led[15] <= 1'b0;
        led[14:1] <= {14{dur[24]}};
        if(dur >= open_duration -1)begin
          dur <= 28'd0;
          state <= idle;
          buzzer <= 0;
        end
        else
          dur <= dur+1'b1;
      end
      
      unmatched : begin
        led[0] <= 1'b0;
        led[15] <= 1'b1;
        led[14:1] <= {14{dur[23]}};
        if(dur >= open_duration -1)begin
          dur <= 28'd0;
          state <=idle ;
          buzzer <=1;
        end
        else 
          dur <= dur+ 1'b1;
      end
      default : state<= idle;
    endcase
  end 
  end
endmodule 

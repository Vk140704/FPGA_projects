module alu #(
    parameter WIDTH = 4  
)(
    input  [WIDTH-1:0] a,b,
    input  [3:0] op,
    output reg [7:0] y,
    output reg carry,
    output reg overflow,
    output reg borrow,
    output reg zero,
    output reg negative
);

localparam  ADD = 4'b0000; 
localparam  SUB = 4'b0001; 
localparam  MUL = 4'b0010; 
localparam  DIV = 4'b0011; 
localparam  INC = 4'b0100; 
localparam  DEC = 4'b0101; 
localparam  CMP = 4'b0110; 
localparam LSHL = 4'b0111; 
localparam LSHR = 4'b1000; 
localparam  AND = 4'b1001; 
localparam  OR  = 4'b1010; 
localparam  NOT = 4'b1011; 
localparam  XOR = 4'b1100; 
localparam XNOR = 4'b1101; 
localparam ASHR = 4'b1110; 
localparam ASHL = 4'b1111; 

reg [WIDTH:0] temp;            
reg [(2*WIDTH)-1:0] mul_temp;
reg [WIDTH-1:0] rem_temp;
reg gt,lt,eq;

always@(*)begin
    y = 0;
    carry = 0;
    overflow = 0;
    borrow = 0;
    zero = 0;
    negative = 0;
    temp = 0;
    mul_temp = 0;
    rem_temp = 0;

    case(op)

    ADD : begin
        temp = {1'b0,a}+{1'b0,b};
        y = temp[WIDTH-1:0];
        carry = temp[WIDTH];
        overflow = (a[WIDTH-1]==b[WIDTH-1])&&(y[WIDTH-1]!=a[WIDTH-1]);
    end

    SUB : begin
        temp = {1'b1,a}-{1'b0,b};
        y = temp[WIDTH-1:0];
        borrow = ~temp[WIDTH];
//        borrow = ~carry;
        overflow = (a[WIDTH-1]!=b[WIDTH-1])&&(y[WIDTH-1]!=a[WIDTH-1]);
        negative = borrow;
    end

    MUL : begin 
        mul_temp = a*b;
        y = mul_temp[WIDTH-1:0];
        carry = mul_temp[(2*WIDTH)-1:WIDTH];
        overflow = carry;
    end

    INC : begin
        temp = {1'b0,a}+1;
        y = temp[WIDTH-1:0];
        carry = temp[WIDTH];
        overflow = (a[WIDTH-1] && !y[WIDTH-1]);
    end 

    DEC : begin
        temp = {1'b0,a}-1;
        y = temp[WIDTH-1:0];
        carry = temp[WIDTH];
        overflow = (!a[WIDTH-1] && y[WIDTH-1]);
    end

    DIV  : begin
        if(b!=0) begin
            y = a/b;
            rem_temp = a%b;
        end
        carry = (rem_temp!=0);
        overflow=(b==0); 
    end

    CMP : begin
        if(a>b)      begin gt=1;lt=0;eq=0; end
        else if(a<b) begin gt=0;lt=1;eq=0; end
        else         begin gt=0;lt=0;eq=1; end

        carry = gt;
        borrow = lt;
        zero = eq;
        
    end

    LSHL : begin
        y = a << b;
        carry = a[WIDTH-1];
    end

    LSHR : begin
        y = {1'b0,a[WIDTH-1:1]};
        carry = a[0];
    end

    ASHR : begin
        y ={a[WIDTH-1],a[WIDTH-1:1]};
        carry = a[0];
    end

    ASHL : begin
        y = {a[WIDTH-2:0],1'b0};
       
    end

    AND : begin
        y = a & b;
    end

    OR : begin
        y = a | b;
    end

    NOT : begin
        y = ~a;
    end

    XOR : begin
        y = a ^ b;
    end

    XNOR : begin
        y = ~(a ^ b);
    end

    default : y = 0;

    endcase
end

endmodule

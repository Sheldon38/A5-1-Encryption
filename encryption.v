module encryption(
input clk,
input [7:0] inbyte,
input hkey,
output reg [7:0] outbyte,
output reg ready=0,
output reg read=0
);

reg [18:0] reg1=0;
reg [21:0] reg2=0;
reg [22:0] reg3=0;
reg [63:0] hardware_key=0;
reg max;
reg xor1,xor2,xor3,encryptedkey;
reg [7:0] temporary_outbyte;
integer count;
integer bitshift=0;

task maximum_ABC(
output d,
input a,
input b,
input c
);
begin
    d=(a&c)|(a&b)|(b&c);
end
endtask

initial
begin
        repeat(7) @(posedge clk);
        for(count=0;count<64;count=count+1)
        begin
            @(posedge clk)
            begin
            hardware_key[count]=hkey;
            end
        end
        hardware_key=hardware_key>>1;
        hardware_key[63]=hkey;
        $display("Hardware Key : %b",hardware_key[63:40]);
        
        reg1=hardware_key[18:0];
        reg2=hardware_key[40:18];
        reg3=hardware_key[62:39];
        
        $display("%b : %b : %b",reg1,reg2,reg3);
        
        //initialise loop here
        for(count=0;count<524288;count=count+1)
        begin
            @(posedge clk)
            begin
            read=1'b1;
            maximum_ABC(max,reg1[10],reg2[11],reg3[12]);
            xor1=reg1[5]^reg1[2]^reg1[1]^reg1[0];
            xor2=reg2[1]^reg2[0];
            xor3=reg3[15]^reg3[2]^reg3[1]^reg3[20];
            if(max==reg1[10])
            begin
                reg1=reg1>>1;
                reg1[18]=xor1;
            end
            
            if(max==reg2[11])
            begin
                reg2=reg2>>1;
                reg2[21]=xor2;
            end
            
            if(max==reg3[12])
            begin
                reg3=reg3>>1;
                reg3[22]=xor3;
            end
            encryptedkey=reg1[0]^reg2[0]^reg3[0];
            
            // $display("%b",encryptedkey);
            temporary_outbyte[bitshift]=encryptedkey^inbyte[bitshift];
            bitshift=bitshift+1;
            if(bitshift==8)
            begin
                bitshift=0;
                outbyte=temporary_outbyte;
                ready=1'b1;
            end
            else
            ready=1'b0;
            end
        end
        //end loop here
end
endmodule

//--------------------------------------------------Test bench Module--------------------------------------------------------------------------------------------//

module tbencryption;
reg clk,hkey;
reg [7:0] inbyte;
wire [7:0] outbyte;
wire read,ready;

encryption e1(
.clk (clk),
.hkey (hkey),
.read (read),
.ready (ready),
.inbyte (inbyte),
.outbyte (outbyte)
);

reg [63:0] hardware="hardware";
reg [7:0] IMAGE [0:65535];
reg [7:0] IMAGEOUT [0:65535];
integer count1=0;

initial
    $readmemh("E:/clg work/Sem 4/Project 2/imtotxt.txt",IMAGE);

initial
begin
    clk=1'b0;
    forever #10 clk=~clk;
end

initial
begin
    repeat(7) @(posedge clk);
    for(count1=0;count1<64;count1=count1+1)
    begin
        
        @(posedge clk)
        begin
        hkey=hardware[count1];
        end
    end
    
    count1=0;
    if(read)
    begin
        while(count1<=65535)
        begin
        inbyte=IMAGE[count1];
            if(ready)
            begin
            IMAGEOUT[count1]=outbyte;
            count1=count1+1;
            end
        end
    end

end
endmodule

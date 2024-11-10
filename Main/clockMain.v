module clockMain( 
    RESETN, CLK, KEY,
    SEG_COM, 
    SEG_DATA, LED, PIEZO
); 

input RESETN, CLK;
input [3:0] KEY;
output reg [3:0] SEG_COM;
output reg [2:0] LED;
output SEG_DATA;
output PIEZO;
reg [6:0] MIN, SEC; //integer MIN, SEC;
reg [6:0] Alarm;
reg [3:0] NUM;
reg SEG_DOT;
reg key_pressed;
reg setAlarm;
reg setTime;
reg isAlarm;

reg BUFF;

integer CNT_SOUND, INDEX, CNT;
integer LIMIT [0:30];

wire [6:0] time_sec, time_min;
wire [6:0] alarm_min, alarm_sec;
wire [7:0] SEG_DATA; 
wire [3:0] M10, M1, S10, S1; 
wire [3:0] A_M10, A_M1, A_S10, A_S1;
wire [3:0] T_M10, T_M1, T_S10, T_S1;
wire key_changed; // In alarmMode, define key changed
wire PIEZO;

integer CNT_PIEZO; 
integer CNT_SCAN, CNT_ALARM, CNT_Time;
integer CNT_pressed;

always @(LIMIT)
begin
    LIMIT[0] = 1516; // Me
    LIMIT[1] = 1701; // Re
    LIMIT[2] = 1910; // Do
    LIMIT[3] = 1701; // Re
    LIMIT[4] = 1516; // Me
    LIMIT[5] = 955; // High DO 
    LIMIT[6] = 955; // High DO 
    LIMIT[7] = 1135; // RA
    LIMIT[8] = 1275; // Sol
    LIMIT[9] = 1516; // Me
    LIMIT[10] = 1910; // Do
    LIMIT[11] = 1701; // Re
    LIMIT[12] = 1516; // Me
    LIMIT[13] = 1275; // Sol
    LIMIT[14] = 1516; // Me
    LIMIT[15] = 1701; // Re
    LIMIT[16] = 1516; // Me
    LIMIT[17] = 1701; // Re
    LIMIT[18] = 1910; // Do
    LIMIT[19] = 1701; // Re
    LIMIT[20] = 1516; // Me
    LIMIT[21] = 955; // High DO
    LIMIT[22] = 955; // High DO
    LIMIT[23] = 1135; // RA
    LIMIT[24] = 1275; // Sol
    LIMIT[25] = 1135; // RA
    LIMIT[26] = 1910; // Do
    LIMIT[27] = 1701; // Re
    LIMIT[28] = 1516; // Me
    LIMIT[29] = 1701; // Re
    LIMIT[30] = 1910; // Do
end

always @(posedge CLK or negedge RESETN) begin
    if (~RESETN) begin
        CNT_pressed <= 0;
        setAlarm <= 0;
        key_pressed <= 0;
        setTime <= 0;
    end else begin            
        if (key_pressed) begin 
            if (CNT_pressed < 1000000) CNT_pressed <= CNT_pressed + 1; 
            else begin
                if (KEY == 4'b0010 && !setTime) begin
                    setAlarm <= ~setAlarm;
                    CNT_pressed <= 0;
                end else if (KEY == 4'b0001 && !setAlarm) begin
                    setTime <= ~setTime;
                    CNT_pressed <= 0;
                end
            end
        end else begin
            CNT_pressed <= 0;
        end

        case (KEY)
            4'b1000: begin
            end
            
            4'b0100: begin
            end
            
            4'b0010: begin
                key_pressed <= 1;
            end
            
            4'b0001: begin
                key_pressed <= 1;
            end
            
            default: begin
                key_pressed <= 0;
            end
        endcase
    end
end

always @(posedge CLK)
begin
	if(~RESETN)
		isAlarm <= 0;
	else
	begin
		if(SEC == alarm_sec && MIN == alarm_min && key_changed)
			isAlarm <= 1;
		else if(KEY == 4'b1000)
			isAlarm <= 0;
	end
end

always @(posedge CLK or negedge RESETN) begin
    if (~RESETN) begin
        LED <= 3'b000; 
    end else begin
        if (setAlarm)
            LED <= 3'b100;
        else if (setTime)
            LED <= 3'b010;
        else if (key_changed)
            LED <= 3'b001;
        else
            LED <= 3'b000;
    end
end

always @(posedge CLK) begin 
    if (~RESETN) 
        CNT <= 0; 
    else if (CNT >= 999999) 
        CNT <= 0; 
    else 
        CNT <= CNT + 1; 
end

always @(posedge CLK) begin 
    if (~RESETN)
        SEC <= 0;
		  
	 else if(setTime)
		SEC <= time_sec;
		
    else if (CNT == 999999)
        if (SEC >= 59) 
            SEC <= 0; 
        else 
            SEC <= SEC + 1; 
end 

always @(posedge CLK) begin 
    if (~RESETN) 
        MIN <= 0;
		  
	 else if(setTime)
		 MIN <= time_min;
		 
    else if ((CNT == 999999) && (SEC == 59)) 
        if (MIN >= 59) 
            MIN <= 0; 
        else 
            MIN <= MIN + 1; 
end 

always @(posedge CLK) begin 
    if (~RESETN) begin 
        SEG_DOT <= 1'b0; 
        SEG_COM <= 4'b0000; 
        NUM <= 0;
        CNT_SCAN <= 0;
        CNT_ALARM <= 0;
        CNT_Time <= 0;
    end else if (!setAlarm && !setTime && !key_pressed) begin 
        if (CNT_SCAN >= 3) 
            CNT_SCAN <= 0; 
        else 
            CNT_SCAN <= CNT_SCAN + 1; 
 
        case (CNT_SCAN) 
            0 : begin 
                NUM <= M10; 
                SEG_DOT <= 1'b0; 
                SEG_COM <= 4'b0111; 
            end
            1 : begin 
                NUM <= M1; 
                SEG_DOT <= 1'b1; 
                SEG_COM <= 4'b1011; 
            end 
            2 : begin 
                NUM <= S10; 
                SEG_DOT <= 1'b0; 
                SEG_COM <= 4'b1101; 
            end 
            3 : begin 
                NUM <= S1; 
                SEG_DOT <= 1'b1; 
                SEG_COM <= 4'b1110; 
            end
            default : begin 
                NUM <= 0; 
                SEG_DOT <= 1'b0; 
                SEG_COM <= 4'b1111; 
            end 
        endcase 
    end else if (setAlarm) begin
        if (CNT_SCAN >= 3) 
            CNT_SCAN <= 0; 
        else 
            CNT_SCAN <= CNT_SCAN + 1;
            
        if (CNT_ALARM >= 999999) 
            CNT_ALARM <= 0; 
        else 
            CNT_ALARM <= CNT_ALARM + 1; 
 
        case (CNT_SCAN) 
            0 : begin
                NUM <= A_M10; 
                SEG_COM <= 4'b0111;
                if (CNT_ALARM < 500000) 
                    SEG_DOT <= 1'b0;
                else  
                    SEG_DOT <= 1'b1;
            end
            1 : begin 
                NUM <= A_M1; 
                SEG_COM <= 4'b1011;
                if (CNT_ALARM < 500000) 
                    SEG_DOT <= 1'b0;
                else  
                    SEG_DOT <= 1'b1;
            end 
            2 : begin 
                NUM <= A_S10; 
                SEG_COM <= 4'b1101;
                if (CNT_ALARM < 500000) 
                    SEG_DOT <= 1'b0;
                else  
                    SEG_DOT <= 1'b1;
            end 
            3 : begin 
                NUM <= A_S1;
                SEG_COM <= 4'b1110;
                if (CNT_ALARM < 500000) 
                    SEG_DOT <= 1'b0;
                else  
                    SEG_DOT <= 1'b1;
            end
            default : begin 
                NUM <= 0; 
                SEG_DOT <= 1'b0; 
                SEG_COM <= 4'b1111; 
            end 
        endcase
    end else if (setTime) begin
        if (CNT_SCAN >= 3) 
            CNT_SCAN <= 0; 
        else 
            CNT_SCAN <= CNT_SCAN + 1;
            
        if (CNT_Time >= 999999) 
            CNT_Time <= 0; 
        else 
            CNT_Time <= CNT_Time + 1; 
 
        case (CNT_SCAN) 
            0 : begin
                NUM <= T_M10; 
                SEG_COM <= 4'b0111;
                if (CNT_Time < 500000) 
                    SEG_DOT <= 1'b0;
                else  
                    SEG_DOT <= 1'b1;
            end
            1 : begin 
                NUM <= T_M1; 
                SEG_COM <= 4'b1011;
                if (CNT_Time < 500000) 
                    SEG_DOT <= 1'b0;
                else  
                    SEG_DOT <= 1'b1;
            end 
            2 : begin 
                NUM <= T_S10; 
                SEG_COM <= 4'b1101;
                if (CNT_Time < 500000) 
                    SEG_DOT <= 1'b0;
                else  
                    SEG_DOT <= 1'b1;
            end 
            3 : begin 
                NUM <= T_S1;
                SEG_COM <= 4'b1110;
                if (CNT_Time < 500000) 
                    SEG_DOT <= 1'b0;
                else  
                    SEG_DOT <= 1'b1;
            end
            default : begin 
                NUM <= 0; 
                SEG_DOT <= 1'b0; 
                SEG_COM <= 4'b1111; 
            end 
        endcase
    end else if (key_pressed) begin
        if (CNT_SCAN >= 3) 
            CNT_SCAN <= 0; 
        else 
            CNT_SCAN <= CNT_SCAN + 1; 
 
        case (CNT_SCAN) 
            0 : begin 
                NUM <= 4'b0000; 
                SEG_DOT <= 1'b0; 
                SEG_COM <= 4'b1111; 
            end
            1 : begin 
                NUM <= 4'b0000; 
                SEG_DOT <= 1'b1; 
                SEG_COM <= 4'b1111; 
            end 
            2 : begin 
                NUM <= 4'b0000; 
                SEG_DOT <= 1'b0; 
                SEG_COM <= 4'b1111; 
            end 
            3 : begin 
                NUM <= 4'b0000; 
                SEG_DOT <= 1'b1; 
                SEG_COM <= 4'b1111; 
            end
            default : begin 
                NUM <= 0; 
                SEG_DOT <= 1'b0; 
                SEG_COM <= 4'b1111; 
            end 
        endcase
    end
end

always @(posedge CLK) begin
    if (~RESETN) begin
        BUFF = 1'b0;
        CNT_SOUND = 0;
        INDEX = 0;
        CNT_PIEZO = 0;
    end 
	 else if(isAlarm)
	 begin
        if ((CNT_SOUND > LIMIT[INDEX])) begin
            CNT_SOUND = 0;
            BUFF = ~BUFF;
        end else begin
            CNT_SOUND = CNT_SOUND + 1;
				CNT_PIEZO = CNT_PIEZO + 1;
        end
        
        if (CNT_PIEZO > 500000) begin
            INDEX = INDEX + 1;
            if (INDEX > 31)
                INDEX = 0;
            CNT_PIEZO = 0;
        end
    end
end

assign PIEZO = BUFF;

setNumber S_SEP(SEC, S10, S1); 
setNumber M_SEP(MIN, M10, M1);
setNumber AlarmNum_s(alarm_sec, A_S10, A_S1);
setNumber AlarmNum_m(alarm_min, A_M10, A_M1);
setNumber TimeNum_s(time_sec, T_S10, T_S1);
setNumber TimeNum_m(time_min, T_M10, T_M1);

DECODER S_DECODE(NUM, SEG_DOT, SEG_DATA);

setAlarm alarm(
    .CLK(CLK),
    .RESETN(RESETN),
    .KEY(KEY),
    .setAlarm(setAlarm),
    .number_min(alarm_min),
    .number_sec(alarm_sec),
    .key_changed(key_changed)
);

setTime sTime(
    .CLK(CLK),
    .RESETN(RESETN),
    .KEY(KEY),
    .setTime(setTime),
    .number_min(time_min),
    .number_sec(time_sec)
);

endmodule

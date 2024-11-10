//module setAlarm

module setAlarm(
	CLK, RESETN, KEY, setAlarm,
	number_min, number_sec, key_changed
);

input CLK, RESETN;
input [3:0]KEY;
input setAlarm;

output reg [6:0] number_min;
output reg [6:0] number_sec;
output reg key_changed;

reg increment_enable;
reg decrement_enable;
reg key_pressed;
reg divide_minsec;

integer CNT;

/*Define KEY*/
always @(posedge CLK or negedge RESETN)
begin
/*If RESET : RESET ALL*/
	if (~RESETN)
	begin
		number_sec <= 0;
		number_min <= 0;
		key_pressed <= 0;
		divide_minsec <= 0;
		CNT <= 0;
		increment_enable <= 0;
		decrement_enable <= 0;
		key_changed <= 0;
	end 
/*If not RESET : Performing a specific action*/
	else
	begin
		if (setAlarm)
		begin
	/*If key_pressed*/
			if (key_pressed) 
			begin
				if (CNT < 1000000) 
				begin
					CNT <= CNT + 1;
				end
				else
				begin
					CNT <= 0;
					if (KEY == 4'b1000)
						increment_enable <= 1;
					else if (KEY == 4'b0100)
						decrement_enable <= 1;
					else if (KEY == 4'b0010)
					begin
						divide_minsec <= ~divide_minsec;
					end
					else if (KEY == 4'b0001)
						divide_minsec <= ~divide_minsec;
				end
			end
	/*If not pressed_key : RESET CNT, increment_enable, decrement_enable*/
			else
			begin
				CNT <= 0;
				increment_enable <= 0;
				decrement_enable <= 0;
			end

	/*If increment_enable*/
			if (increment_enable)
			begin
	/*If CNT >= 100 */
				if (CNT >= 200000) //Increase the value every 0.1 seconds
				begin
					CNT <= 0;
					increment_enable <= 1;
					if (divide_minsec == 1)
					begin
						if (number_sec == 59)
							number_sec <= 0;
						else
							number_sec <= number_sec + 1;
					end

					else
					begin
						if (number_min == 59)
							number_min <= 0;
						else
							number_min <= number_min + 1;
					end
				end
	/*If CNT < 100 : Increase CNT*/
				else
				begin
					CNT <= CNT + 1;
				end
			end
			
	/*If decrement_enable*/
			if (decrement_enable)
			begin
	/*If CNT >= 100 */
				if (CNT >= 200000)//Increase the value every 0.1 seconds
				begin
					CNT <= 0;
					decrement_enable <= 1;
					if (divide_minsec == 1)
					begin
						if (number_sec == 0)
							number_sec <= 59;
						else
							number_sec <= number_sec - 1;
					end
					
					else
					begin
						if (number_min == 0)
							number_min <= 59;
						else
							number_min <= number_min - 1;
						end
					end
	/*If CNT < 100 : Increase CNT*/
				else
				begin
					CNT <= CNT + 1;
				end
			end

	/*Chang in KEY*/
			case (KEY)
				4'b1000:
				begin
					if (!key_pressed) // If KEY is not pressed
					begin
						key_pressed <= 1; // Notify KEY is pressed
						key_changed <= 1;
	/*If divide_minsec is Zero*/
						if (divide_minsec == 1)
						begin
							if (number_sec == 59)
								number_sec <= 0;
							else
								number_sec <= number_sec + 1;
						end
	/*If divide_minsec is not Zero*/
						else
						begin
							if (number_min == 59)
								number_min <= 0;
							else
								number_min <= number_min + 1;
						end
					end
				end

				4'b0100:
				begin
					if (!key_pressed) // If KEY is not pressed
					begin
						key_pressed <= 1; // Notify KEY is pressed
						key_changed <= 1;
	/*If divide_minsec is Zero*/
						if (divide_minsec == 1)
						begin
							if (number_sec == 0)
								number_sec <= 59;
							else
								number_sec <= number_sec - 1;
						end
	/*If divide_minsec is not Zero*/
						else
						begin
							if (number_min == 0)
								number_min <= 59;
							else
								number_min <= number_min - 1;
						end
					end
				end

				4'b0010:
				begin
					if (!key_pressed) // If KEY is not pressed
					begin
						key_pressed <= 1;	// Notify KEY is pressed
						divide_minsec <= ~divide_minsec; // Reverse the Value
					end
				end
				
				4'b0001:
				begin
					if (!key_pressed)
					begin
						key_pressed <= 1;
						key_changed <= 0;
						divide_minsec <= ~divide_minsec;
					end
				end

				default:	// Default action
				begin
					key_pressed <= 0; // KEY is not pressed
				end
			endcase
		end
	end
end

endmodule

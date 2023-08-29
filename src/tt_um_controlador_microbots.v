`timescale 1ns / 1ps

module tt_um_controlador_microbots (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);
    wire reset;
    wire f_sensor, l_sensor, r_sensor;
    wire [4:0] data_in;
    reg [3:0] flags;
    reg [3:0] motors;
    assign uio_out = 8'b1111_1111; //todos output
    assign uio_oe = 8'b1111_1111; //todos output
    assign data_in = 5'b0_0000;
    assign {data_in, f_sensor, l_sensor, r_sensor} = ui_in;

    reg [1:0] state, next_state;

    assign flags = 4'b0000;
    assign uo_out = { flags, motors}; //los motores se reparten de la siguiente manera, los espacios 3 y 2 son 
    //el motor A hacia la derecha e izquierda respectivamente, a su vez, los espacios 1 y 0 son la derecha e izquierda del motor B.
    assign reset = ~rst_n;

    parameter Standby = 2'b00;
    parameter goforward = 2'b01;
    parameter goright = 2'b10;
    parameter goleft = 2'b11;

    always @(posedge clk) begin
        if (reset)
            state <= Standby;
        else
            state <= next_state;
    end

    always @* begin
        next_state = Standby;
        case (state)
            Standby: 
                if (f_sensor == 0)
                begin
                    next_state = goforward;
                end
                else if (l_sensor == 1 && r_sensor == 0)
                begin
                    next_state = goright;
                end
                else if (f_sensor == 1 && r_sensor == 0)
                begin
                    next_state = goright;
                end
                else if (l_sensor == 0 && r_sensor == 1)
                begin
                    next_state = goleft;
                end
                else if (f_sensor == 1 && l_sensor == 1 && r_sensor == 1)
                begin
                    next_state = goright;
                end
            goforward: 
                if (f_sensor == 0)
                begin
                    next_state = state;
                end
            goright: 
                if (l_sensor == 1 && r_sensor == 0)
                begin
                    next_state = state;
                end
            goleft: 
                if (l_sensor == 0 && r_sensor == 1)
                begin
                    next_state = state;
                end
        endcase
    end

    always @* begin //se definen las polarizaciones de los motores, donde 0 es no polarizar y 1 es polarizar en dicha dirección
        case (state)
            Standby : begin
                motors[0] = 0;
                motors[1] = 0;
                motors[2] = 0;
                motors[3] = 0;
            end
            goforward: begin
                motors[0] = 0;
                motors[1] = 1;
                motors[2] = 0;
                motors[3] = 1;
            end
            goright: begin
                motors[0] = 1;
                motors[1] = 0;
                motors[2] = 0;
                motors[3]= 1;
            end
            goleft: begin
                motors[0] = 0;
                motors[1] = 1;
                motors[2] = 1;
                motors[3] = 0;
            end
        endcase
    end
endmodule

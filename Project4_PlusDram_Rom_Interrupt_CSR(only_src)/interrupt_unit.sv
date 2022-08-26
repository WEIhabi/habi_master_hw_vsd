module interrupt_unit(
    input clk,
    input rst,
    input stall,
    input WFI,
    input MEIE,
    input interrupt,
    output logic interrupt_pulse
    );
    
    logic interrupt_enable;
    
    always_ff @ (posedge clk or posedge rst) begin
        if (rst) interrupt_enable <= 1'b0;
        else begin
            if (interrupt_enable)
                interrupt_enable <= (interrupt && ~stall)? 1'b0 : interrupt_enable;
            else
                interrupt_enable <= (WFI)? 1'b1 : interrupt_enable;
        end
    end
    
    assign interrupt_pulse = interrupt & interrupt_enable & MEIE;
    
    endmodule
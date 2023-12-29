module hazard_unit (
    input  logic         rf_en_mw,
    input  logic         br_taken,   
    input  logic [4:0]   rs1,
    input  logic [4:0]   rs2,
    input  logic [4:0]   rd_mw,
    input  logic [1:0]   sel_wb_mw,
    output logic         stall_if,
    output logic         stall_dx,
    output logic         flush_dx,
    output logic         forward_a,
    output logic         forward_b

);
    
logic stall_lw;

    always_comb 
    begin
        if (((rs1 == rd_mw) & rf_en_mw) & (rs1 != 0))
        begin
            forward_a = 1'b1;
        end   
        else
        begin
            forward_a = 1'b0;
        end 
    end

    
    always_comb 
    begin
        if (((rs2 == rd_mw) & rf_en_mw) & (rs2 != 0))
        begin
            forward_b = 1'b1;
        end   
        else
        begin
            forward_b = 1'b0;
        end 
    end


    always_comb 
    begin
        if ((sel_wb_mw == 2'b01) & ((rs1 == rd_mw) | (rs2 == rd_mw)))
        begin
            stall_lw = 1'b1;
        end   
        else
        begin
            stall_lw = 1'b0;
        end 
    end

assign stall_if     = stall_lw;
assign stall_dx     = stall_lw;
assign flush_dx     = (br_taken | stall_lw);


endmodule
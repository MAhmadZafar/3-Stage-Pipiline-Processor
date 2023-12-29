module Processor (
    input logic clk,
    input logic rst
);
    //control signals
    logic        rf_en_dx;
    logic        rf_en_mw;
    logic        en;
    logic        sel_opr_a;
    logic        sel_opr_b;
    logic        forward_a;
    logic        forward_b;
    logic [ 1:0] sel_wb_dx;
    logic [ 1:0] sel_wb_mw;
    logic [ 2:0] imm_type;


    //operation signals
    logic [31:0] pc_out_if;
    logic [31:0] pc_out_dx;
    logic [31:0] pc_out_mw;
    logic [31:0] inst_if;
    logic [31:0] inst_dx;
    logic [31:0] inst_mw;
    logic        stall_if;
    logic        stall_dx;
    logic        flush_dx;
    logic [ 4:0] rs2;
    logic [ 4:0] rs1;
    logic [ 4:0] rd_dx;
    logic [ 4:0] rd_mw;
    logic [ 6:0] opcode;
    logic [ 2:0] func3;
    logic [ 6:0] func7;
    logic [31:0] addr;
    logic [31:0] wdata;
    logic [31:0] rdata;
    logic [31:0] rdata1;
    logic [31:0] rdata2_dx;
    logic [31:0] rdata2_mw;
    logic [ 3:0] aluop;
    logic [31:0] imm;
    logic [31:0] opr_res_dx;
    logic [31:0] opr_res_mw;

   //pc control signal
    logic [31:0] mux_out_pc;
    logic [31:0] mux_out_opr_a;
    logic [31:0] mux_out_opr_b;
    logic [31:0] mux_out_forward_a;
    logic [31:0] mux_out_forward_b;
    logic [ 2:0] br_type;
    logic        br_taken;
    logic        rd_en_dx;
    logic        rd_en_mw;
    logic        wr_en_dx;
    logic        wr_en_mw;
    logic [ 2:0] mem_type_dx;
    logic [ 2:0] mem_type_mw;

    //csr
    logic        timer_interupt;
    logic        csr_rd_dx;
    logic        csr_rd_mw;
    logic        csr_wr_dx;
    logic        csr_wr_mw;
    logic [31:0] csr_rdata;
    logic [31:0] epc;
    logic        is_mret_dx;
    logic        is_mret_mw;
    logic        epc_taken;





// ----------------------------------------------Fetch----------------------------------------------------------------

    // pc selection mux
    always_comb 
    begin 
    if (epc_taken)
        begin
            mux_out_pc= epc;
        end
    else
        begin
            mux_out_pc = br_taken ? opr_res_dx : (pc_out_if + 32'd4);
        end
    
    end



    PC PC_i
    (
        .clk    ( clk            ),
        .rst    ( rst            ),
        .en     ( ~stall_if      ),
        .pc_in  ( mux_out_pc     ),
        .pc_out ( pc_out_if      )
    );

    inst_mem inst_mem_i
    (
        .addr   ( pc_out_if       ),
        .data   ( inst_if         )
    );

    always_ff @(posedge clk)
    begin
        if (rst)
        begin
            inst_dx <= 0;
            pc_out_dx <= 0;
        end
        else if (flush_dx)
        begin
            inst_dx <= 32'h00000033;
            pc_out_dx <= 1'b0;
        end
        else if (~stall_dx)
        begin
            inst_dx <= inst_if;
            pc_out_dx <= pc_out_if;
        end
    end

    //---------------------------------------------Decode Execute-------------------------------------------------------------
    



    //Instruction Decode
    inst_decode inst_decode_i
    (
        .inst   ( inst_dx         ),
        .rd     ( rd_dx           ),
        .rs1    ( rs1             ),
        .rs2    ( rs2             ),
        .opcode ( opcode          ),
        .func3  ( func3           ),
        .func7  ( func7           )
    );

    //General Purpose Register File

    reg_file reg_file_i
    (
        .clk    ( clk             ),
        .rs2    ( rs2             ),
        .rs1    ( rs1             ),
        .rd     ( rd_mw           ),
        .wdata  ( wdata           ),
        .rdata1 ( rdata1          ),
        .rdata2 ( rdata2_dx       ),
        .rf_en  ( rf_en_mw        )

    );

     // controller
    controller controller_i
    (
        .opcode    ( opcode         ),
        .func7     ( func7          ),
        .func3     ( func3          ),
        .rf_en     ( rf_en_dx       ),
        .sel_opr_a ( sel_opr_a      ),
        .sel_opr_b ( sel_opr_b      ),
        .sel_wb    ( sel_wb_dx      ),
        .imm_type  ( imm_type       ),
        .aluop     ( aluop          ),
        .br_type   ( br_type        ),
        .rd_en     ( rd_en_dx       ),
        .wr_en     ( wr_en_dx       ),
        .mem_type  ( mem_type_dx    ),
        .csr_rd    ( csr_rd_dx      ),
        .csr_wr    ( csr_wr_dx      ),
        .is_mret   ( is_mret_dx     )
    );


    // immediate generator
    imm_gen imm_gen_i
    (
        .inst      ( inst_dx        ),
        .imm_type  ( imm_type       ),
        .imm       ( imm            )
    );

    
    // operand a selection mux
    assign mux_out_opr_a = sel_opr_a ? pc_out_dx : mux_out_forward_a;

    // operand b selection mux
    assign mux_out_opr_b = sel_opr_b ? imm    : mux_out_forward_b;

    assign mux_out_forward_a = forward_a ? opr_res_mw : rdata1;

    assign mux_out_forward_b = forward_b ? opr_res_mw : rdata2_dx;


     alu alu_i
    (
        .aluop    ( aluop          ),
        .opr_a    ( mux_out_opr_a  ),
        .opr_b    ( mux_out_opr_b  ),
        .opr_res  ( opr_res_dx     )
    );

    Branch_comp Branch_comp_i
    (
        .br_type   ( br_type        ),
        .opr_a     ( mux_out_forward_a),
        .opr_b     ( mux_out_forward_b),
        .br_taken  ( br_taken       )
    );

    hazard_unit hazard_unit_i
    (
        .rf_en_mw   ( rf_en_mw      ),
        .rs1        ( rs1           ),
        .rs2        ( rs2           ),
        .rd_mw      ( rd_mw         ),
        .sel_wb_mw  ( sel_wb_mw     ),
        .stall_if   ( stall_if      ),
        .stall_dx   ( stall_dx      ),
        .flush_dx   ( flush_dx      ),
        .forward_a  ( forward_a     ),
        .forward_b  ( forward_b     ),
        .br_taken   ( br_taken      )
    );


    always_ff @( posedge clk ) 
    begin
        if (rst | flush_dx)
        begin
            pc_out_mw <= 0;
            opr_res_mw <= 0;
            rdata2_mw <= 0;
            inst_mw <= 0;
            rd_mw <= 0;

            //Ctrl Signals
            rf_en_mw    <= 0;
            rd_en_mw    <= 0;
            wr_en_mw    <= 0;
            csr_rd_mw   <= 0;
            csr_wr_mw   <= 0;
            mem_type_mw <= 0;
            sel_wb_mw   <= 0;
            is_mret_mw  <= 0;  
            
        end        
        else
        begin
            pc_out_mw <= pc_out_dx;
            opr_res_mw <= opr_res_dx;
            rdata2_mw <= rdata2_dx;
            inst_mw <= inst_dx;
            rd_mw <= rd_dx;

            //Ctrl Signals
            rf_en_mw    <= rf_en_dx;    
            rd_en_mw    <= rd_en_dx;   
            wr_en_mw    <= wr_en_dx;   
            csr_rd_mw   <= csr_rd_dx;   
            csr_wr_mw   <= csr_wr_dx;  
            mem_type_mw <= mem_type_dx; 
            sel_wb_mw   <= sel_wb_dx;
            is_mret_mw  <= is_mret_dx;  
        end
    end

    // -----------------------------------------------Memory WriteBack----------------------------------------------------------
    data_mem data_mem_i
    (
        .clk       ( clk            ),
        .rd_en     ( rd_en_mw       ),
        .wr_en     ( wr_en_mw       ),
        .mem_type  ( mem_type_mw    ),
        .addr      ( opr_res_mw     ),
        .wdata     ( rdata2_mw      ),
        .rdata     ( rdata          )
    );

     // csr 
    csr_reg csr_reg_i
    (
        .clk       ( clk             ),
        .rst       ( rst             ),
        .addr      ( opr_res_mw      ),
        .wdata     ( rdata1          ),
        .pc        ( pc_out_mw       ),
        .trap_handle( timer_interupt ),
        .csr_rd    ( csr_rd_mw       ),
        .csr_wr    ( csr_wr_mw       ),
        .is_mret   ( is_mret_mw      ),
        .inst      ( inst_mw        ),
        .rdata     ( csr_rdata       ),
        .epc       ( epc             ),
        .epc_taken ( epc_taken       )
    );

    timer timer_i(
        .clk                     (clk),
        .rst                     (rst),
        .timer_interupt(timer_interupt)
    );




    always_comb
    begin
        case(sel_wb_mw)
            2'b00: wdata = opr_res_mw;
            2'b01: wdata = rdata;
            2'b10: wdata = pc_out_mw + 32'd4;
            2'b11: wdata = csr_rdata;
            default:
            begin
                wdata = 32'b0;
            end
        endcase
    end

endmodule
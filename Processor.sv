module Processor (
    input logic clk,
    input logic rst
);
    //control signals
    logic            rf_en;
    logic           sel_pc;
    logic        sel_opr_a;
    logic        sel_opr_b;
    logic            sel_m;
    logic  [ 1:0]   sel_wb;
    logic  [ 2:0] imm_type;


    //operation signals
    logic [31:0] pc_out;
    logic [31:0] inst;
    logic [ 4:0] rs2;
    logic [ 4:0] rs1;
    logic [ 4:0] rd;
    logic [ 6:0] opcode;
    logic [ 2:0] func3;
    logic [ 6:0] func7;
    logic [31:0] wdata;
    logic [31:0] rdata1;
    logic [31:0] rdata2;
    logic [ 3:0] aluop;
    logic [31:0] imm;
    logic [31:0] opr_res;

    logic [31:0] mux_out_pc;
    logic [31:0] mux_out_opr_a;
    logic [31:0] mux_out_opr_b;

    // pc selection mux
    assign mux_out_pc = sel_pc ? wdata : (pc_out + 32'd4);



    PC PC_i
    (
        .clk    ( clk            ),
        .rst    ( rst            ),
        .pc_in  ( pc_out + 32'd4 ),
        .pc_out ( pc_out         )
    );

    inst_mem inst_mem_i
    (
        .addr   ( pc_out          ),
        .data   ( inst            )
    );
    
    inst_decode inst_decode_i
    (
        .inst   ( inst            ),
        .rd     ( rd              ),
        .rs1    ( rs1             ),
        .rs2    ( rs2             ),
        .opcode ( opcode          ),
        .func3  ( func3           ),
        .func7  ( func7           )
    );

    reg_file reg_file_i
    (
        .clk    ( clk             ),
        .rs2    ( rs2             ),
        .rs1    ( rs1             ),
        .rd     ( rd              ),
        .wdata  ( wdata           ),
        .rdata1 ( rdata1          ),
        .rdata2 ( rdata2          ),
        .rf_en  ( rf_en           )

    );

     // controller
    controller controller_i
    (
        .opcode    ( opcode         ),
        .func7    ( func7           ),
        .func3    ( func3           ),
        .rf_en     ( rf_en          ),
        .sel_opr_a ( sel_opr_a      ),
        .sel_opr_b ( sel_opr_b      ),
        .sel_pc    ( sel_pc         ),
        .sel_wb    ( sel_wb         ),
        .imm_type  ( imm_type       ),
        .aluop     ( aluop          )
    );

     alu alu_i
    (
        .aluop   ( aluop          ),
        .opr_a   ( mux_out_opr_a  ),
        .opr_b   ( mux_out_opr_b  ),
        .opr_res ( opr_res        )
    );


    // immediate generator
    imm_gen imm_gen_i
    (
        .inst      ( inst           ),
        .imm_type  ( imm_type       ),
        .imm       ( imm            )
    );

    // operand a selection mux
    assign mux_out_opr_a = sel_opr_a ? pc_out : rdata1;

    // operand b selection mux
    assign mux_out_opr_b = sel_opr_b ? imm    : rdata2;

    always_comb
    begin
        case(sel_wb)
            2'b00: wdata = opr_res;
            2'b10: wdata = pc_out + 32'd4;
            2'b11: wdata = 32'd0;
        endcase
    end

endmodule
module tb_processor ();
    
    logic clk;
    logic rst;
     
    Processor dut
    (
        .clk(clk),
        .rst(rst)
    );

    initial 
    begin
        clk = 0;
        forever 
        begin
            #5 clk =~ clk;     
        end    
    end

    initial 
    begin
        rst = 1;
        #10;
        rst = 0;
        #10000;
        $finish;    
    end

    // add x3, x4, x2
    initial
    begin
        $readmemb("inst.mem", dut.inst_mem_i.mem);
        $readmemb("rf.mem", dut.reg_file_i.reg_mem);   
        $readmemb("csr_reg.mem", dut.csr_reg_i.csr_mem); 
    end

    initial 
    begin
        $dumpfile("processor.vcd");
        $dumpvars(0,dut);    
    end

    final
    begin
        $writememh("rf_out.mem", dut.reg_file_i.reg_mem); 
        $writememh("d_m.mem", dut.data_mem_i.data_mem); 
        $writememh("csr_reg_out.mem", dut.csr_reg_i.csr_mem);
    end

endmodule
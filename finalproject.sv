`timescale 1ns/1ps

// =============================================================
// Interface (VCS SAFE)
// =============================================================
interface reg_if ();
    logic clk;
    logic rstn;
    logic [7:0]   addr;
    logic [23:0]  wdata;
    logic [23:0]  rdata;
    logic         wr;
    logic         sel;
    logic         acc;
    logic         func;
    logic         ready;
endinterface

// =============================================================
// Transaction
// =============================================================
class reg_item;
    rand bit [7:0]  addr;
    rand bit [23:0] wdata;
    rand bit        wr;
    rand bit        acc;
    rand bit        func;
         bit [23:0] rdata;

    // Bias addr to hit cp1 quickly
    constraint c_addr {
        addr dist {
            8'h00:=8, 8'hFF:=8, 8'hFE:=6,
            8'h55:=6, 8'hAA:=6,
            8'h7E:=6, 8'h7F:=6, 8'h80:=6, 8'h81:=6,
            8'h01:=6,8'h02:=6,8'h04:=6,8'h08:=6,
            8'h10:=6,8'h20:=6,8'h40:=6,8'h80:=6,
            [0:255]:=1
        };
    }

    constraint c_wr   { wr dist {1:=4, 0:=1}; }
    constraint c_acc  { acc dist {0:=2, 1:=1}; }
    constraint c_func { func dist {0:=1, 1:=1}; }

    // Bias wdata to hit cp3 quickly
    constraint c_wdata {
        if (wr) {
            wdata dist {
                24'h0000FF:=10, 24'h00FF00:=10, 24'hFF0000:=10,
                24'h555555:=8,  24'hAAAAAA:=8,
                24'h000000:=6,  24'hFFFFFF:=6,
                [0:24'hFFFFFF]:=1
            };
        }
    }

    function void print(string tag);
        $display("[%-5s] addr=%0h wr=%0d acc=%0d func=%0d wdata=%0h rdata=%0h",
                  tag, addr, wr, acc, func, wdata, rdata);
    endfunction
endclass

// =============================================================
// Covergroup (NO auto bins)
// =============================================================
covergroup reg_cg_t with function sample(reg_item tr);
    option.per_instance = 1;

    cp1_addr : coverpoint tr.addr {
        bins onehot[] = {1,2,4,8,16,32,64,128};
        bins min   = {8'h00};
        bins max   = {8'hFF};
        bins max_m1= {8'hFE};
        bins alt1  = {8'h55};
        bins alt2  = {8'hAA};
        bins mid[] = {8'h7E,8'h7F,8'h80,8'h81};
        bins other = default;
    }

    cp2_wr : coverpoint tr.wr { bins rd={0}; bins wr={1}; }

    cp3_wdata : coverpoint tr.wdata iff (tr.wr) {
        bins byte0 = {24'h0000FF};
        bins byte1 = {24'h00FF00};
        bins byte2 = {24'hFF0000};
        bins alt1  = {24'h555555};
        bins alt2  = {24'hAAAAAA};
        bins min   = {24'h000000};
        bins max   = {24'hFFFFFF};
        bins other = default;
    }

    cp4_acc  : coverpoint tr.acc  { bins off={0}; bins on={1}; }
    cp5_func : coverpoint tr.func { bins add={0}; bins mul={1}; }

    cp6_rdata : coverpoint tr.rdata iff (!tr.wr) { bins any = default; }

    cp7_cross : cross cp2_wr, cp4_acc, cp5_func {
        bins write_no_acc =
            binsof(cp2_wr.wr) &&
            binsof(cp4_acc.off);

        bins write_acc_add =
            binsof(cp2_wr.wr) &&
            binsof(cp4_acc.on) &&
            binsof(cp5_func.add);

        bins write_acc_mul =
            binsof(cp2_wr.wr) &&
            binsof(cp4_acc.on) &&
            binsof(cp5_func.mul);
    }
endgroup

// =============================================================
// Coverage Component + Debug + Closure 
// =============================================================
class coverage;
    mailbox mbx;
    reg_cg_t cg;
    int samples;

    function new(mailbox m);
        mbx = m;
        cg = new();
        samples = 0;
    endfunction

    task run();
        forever begin
            reg_item tr;
            mbx.get(tr);
            cg.sample(tr);
            samples++;
        end
    endtask

    function real get_cov();
        return cg.get_coverage();
    endfunction

  
    task report(string tag="");
        $display("[COV] %s TOTAL=%0.2f%%  samples=%0d  @T=%0t",
                 tag, cg.get_coverage(), samples, $time);
        $display("      cp1_addr=%0.2f  cp2_wr=%0.2f  cp3_wdata=%0.2f  cp4_acc=%0.2f  cp5_func=%0.2f  cp6_rdata=%0.2f  cp7_cross=%0.2f",
                 cg.cp1_addr.get_coverage(),
                 cg.cp2_wr.get_coverage(),
                 cg.cp3_wdata.get_coverage(),
                 cg.cp4_acc.get_coverage(),
                 cg.cp5_func.get_coverage(),
                 cg.cp6_rdata.get_coverage(),
                 cg.cp7_cross.get_coverage()
        );
    endtask

    task close_holes();
        reg_item tr;

        tr = new;
        assert(tr.randomize() with { wr==0; });
        cg.sample(tr);

        tr = new; assert(tr.randomize() with { wr==1; wdata==24'h0000FF; }); cg.sample(tr);
        tr = new; assert(tr.randomize() with { wr==1; wdata==24'h00FF00; }); cg.sample(tr);
        tr = new; assert(tr.randomize() with { wr==1; wdata==24'hFF0000; }); cg.sample(tr);
        tr = new; assert(tr.randomize() with { wr==1; wdata==24'h555555; }); cg.sample(tr);
        tr = new; assert(tr.randomize() with { wr==1; wdata==24'hAAAAAA; }); cg.sample(tr);
        tr = new; assert(tr.randomize() with { wr==1; wdata==24'h000000; }); cg.sample(tr);
        tr = new; assert(tr.randomize() with { wr==1; wdata==24'hFFFFFF; }); cg.sample(tr);

        tr = new; assert(tr.randomize() with { addr==8'h00; wr==0; }); cg.sample(tr);
        tr = new; assert(tr.randomize() with { addr==8'hFF; wr==0; }); cg.sample(tr);
        tr = new; assert(tr.randomize() with { addr==8'hFE; wr==0; }); cg.sample(tr);
        tr = new; assert(tr.randomize() with { addr==8'h55; wr==0; }); cg.sample(tr);
        tr = new; assert(tr.randomize() with { addr==8'hAA; wr==0; }); cg.sample(tr);
        tr = new; assert(tr.randomize() with { addr==8'h7E; wr==0; }); cg.sample(tr);
        tr = new; assert(tr.randomize() with { addr==8'h7F; wr==0; }); cg.sample(tr);
        tr = new; assert(tr.randomize() with { addr==8'h80; wr==0; }); cg.sample(tr);
        tr = new; assert(tr.randomize() with { addr==8'h81; wr==0; }); cg.sample(tr);

        tr = new; assert(tr.randomize() with { wr==1; acc==0; func==0; }); cg.sample(tr); // write_no_acc
        tr = new; assert(tr.randomize() with { wr==1; acc==1; func==0; }); cg.sample(tr); // write_acc_add
        tr = new; assert(tr.randomize() with { wr==1; acc==1; func==1; }); cg.sample(tr); // write_acc_mul
    endtask
endclass

// =============================================================
// Driver
// =============================================================
class driver;
    virtual reg_if vif;
    mailbox mbx;

    task run();
        forever begin
            reg_item tr;
            mbx.get(tr);

            vif.sel   <= 1;
            vif.addr  <= tr.addr;
            vif.wr    <= tr.wr;
            vif.acc   <= tr.acc;
            vif.func  <= tr.func;
            vif.wdata <= tr.wdata;

            @(posedge vif.clk);
            while (!vif.ready) @(posedge vif.clk);

            vif.sel <= 0;
        end
    endtask
endclass

// =============================================================
// Monitor (prints transfers + sends to coverage)
// =============================================================
class monitor;
    virtual reg_if vif;
    mailbox cov_mbx;

    localparam RESET_VAL = 24'h123456; 

    task run();
        forever begin
            @(posedge vif.clk);
            if (vif.sel && vif.ready) begin
                reg_item tr = new;
                tr.addr  = vif.addr;
                tr.wr    = vif.wr;
                tr.acc   = vif.acc;
                tr.func  = vif.func;
                tr.wdata = vif.wdata;

                if (!tr.wr) @(posedge vif.clk);
                tr.rdata = vif.rdata;

                tr.print(tr.wr ? "WR" : "RD");

                if (!tr.wr) begin
                    if (tr.rdata === RESET_VAL) begin
                        $display("       >>> RESULT: PASS (expected=%0h)",
                                 RESET_VAL);
                    end
                    else begin
                        $display("       >>> RESULT: FAIL (expected=%0h got=%0h)",
                                 RESET_VAL, tr.rdata);
                    end
                end

                cov_mbx.put(tr);
            end
        end
    endtask
endclass


// =============================================================
// Generator – THREE PHASES (REQUIRED)
// =============================================================
class generator;
    mailbox drv_mbx;

    function new(mailbox d);
        drv_mbx = d;
    endfunction

    task run();
        int i;

        $display("[GEN] Phase A: After reset reads");
        for (i=0;i<250;i++) begin
            reg_item tr = new;
            assert(tr.randomize() with { wr==0; });
            drv_mbx.put(tr);
        end

        $display("[GEN] Phase B: Main randomized");
        for (i=0;i<2500;i++) begin
            reg_item tr = new;
            assert(tr.randomize());
            drv_mbx.put(tr);
        end

        $display("[GEN] Phase C: Final reads");
        for (i=0;i<250;i++) begin
            reg_item tr = new;
            assert(tr.randomize() with { wr==0; });
            drv_mbx.put(tr);
        end
    endtask
endclass

// =============================================================
// ENV
// =============================================================
class env;
    virtual reg_if vif;

    mailbox drv_mbx = new();
    mailbox cov_mbx = new();

    driver    d = new();
    monitor   m = new();
    coverage  c = new(cov_mbx);
    generator g = new(drv_mbx);

    task run();
        d.vif = vif;
        m.vif = vif;
        d.mbx = drv_mbx;
        m.cov_mbx = cov_mbx;

        fork
            d.run();
            m.run();
            c.run();
            g.run();
        join_none
    endtask
endclass

// =============================================================
// TOP
// =============================================================
module tb;
    bit clk = 0;
    always #5 clk = ~clk;

    reg_if _if ();
    assign _if.clk = clk;

    // ready X-check (prints FAIL but does not stop)
    always @(posedge clk) begin
        if (_if.rstn) begin
            if (^_if.ready === 1'bX) $display("[FAIL] READY is X @T=%0t", $time);
        end
    end

    // Black-box DUT
    reg_ctrl dut (
        .clk   (clk),
        .rstn  (_if.rstn),
        .addr  (_if.addr),
        .sel   (_if.sel),
        .wr    (_if.wr),
        .acc   (_if.acc),
        .func  (_if.func),
        .wdata (_if.wdata),
        .rdata (_if.rdata),
        .ready (_if.ready)
    );

    env e;

    initial begin
        _if.rstn = 0;
        _if.sel  = 0;
        _if.wr   = 0;
        _if.acc  = 0;
        _if.func = 0;

        #20 _if.rstn = 1;

        e = new();
        e.vif = _if;
        e.run();

        // Periodic coverage report
        fork
            begin
                forever begin
                    #5000;
                    e.c.report("PERIODIC");
                end
            end
        join_none

        #200000;

        e.c.report("BEFORE_CLOSE");

        e.c.close_holes();

        e.c.report("AFTER_CLOSE");
        $display("[COV] FINAL = %0.2f%%", e.c.get_cov());
        $finish;
    end
endmodule

/************************************************************************
Author: Mirafra Technologies Pvt Limited
        By Meenal Pannase/Priya Ananthakrishnan
Filename:	Scoreborad.sv  
Date:   	27th May 2024
Version:	1.0
Description: Concept of scoreboard writing in UVM 
***************************************************************************/
//write scoreboard check for apb protocol, consider single master and single slave .

class scoreboard extends uvm_scoreboard;
  //factory registration
  `uvm_component_utils(scoreboard)
  apb_trans master_tx;
  apb_trans salve_tx;

  apb_trans exp_queue[$];

  //declaration of ports from monitor/refrennce model
  uvm_tlm_analysis_fifo#(apb_trans)mas_port;
  uvm_tlm_analysis_fifo#(apb_trans)slave_port;
 // bit[31:0]mem[256];

  //constructor
  function new(string name="scoreboard",uvm_component parent = null);
    super.new(name,parent);
  endfunction

  //build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    master_tx=apb_trans::type_id::create("master_tx");
    slave_tx=apb_trans::type_id::create("slave_tx");
    mon_export=new("mon_export",this);
  endfunction

  //write function of tlm
  function void write(apb_trans tx);
    exp_queue.push_back(tx);
  endfunction

   //run phase
   virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);

    forever begin
      mas_port.get(master_tx);
      slave_port.get(slave_tx);
      check(master_tx,slave_tx);
    end
  endtask

  function void check(apb_trans master_tx,apb_trans slave_tx);
      //....................data check............................//
      if(apb_master_tx_h.pwdata == apb_slave_tx_h.pwdata) begin
        `uvm_info(get_type_name(),$sformatf("apb_pwdata from master and slave is equal"),UVM_HIGH);
        `uvm_info("SB_PWDATA_MATCHED", $sformatf("Master PWDATA = 'h%0x and Slave PWDATA = 'h%0x",apb_master_tx_h.pwdata,apb_slave_tx_h.pwdata), UVM_HIGH);             
      end
      else begin
        `uvm_info(get_type_name(),$sformatf("apb_pwdata from master and slave is not equal"),UVM_HIGH);
        `uvm_error("ERROR_SC_PWDATA_MISMATCH", $sformatf("Master PWDATA = 'h%0x and Slave PWDATA = 'h%0x",apb_master_tx_h.pwdata,apb_slave_tx_h.pwdata));
      end

      // ....................addr check.........................// 
      if(apb_master_tx_h.paddr == apb_slave_tx_h.paddr) begin
        `uvm_info(get_type_name(),$sformatf("apb_paddr from master and slave is equal"),UVM_HIGH);
        `uvm_info("SB_PADDR_MATCH", $sformatf("Master PADDR = 'h%0x and Slave PADDR = 'h%0x",apb_master_tx_h.pwdata,apb_slave_tx_h.pwdata), UVM_HIGH);             
      end
      else begin
        `uvm_info(get_type_name(),$sformatf("apb_paddr from master and slave is not equal"),UVM_HIGH);
        `uvm_error("ERROR_SC_PADDR_MISMATCH", $sformatf("Master PADDR = 'h%0x and Slave PADDR = 'h%0x",apb_master_tx_h.paddr,apb_slave_tx_h.paddr));
      end
 
      //......................pwrite...........................// 
      if(apb_master_tx_h.pwrite == apb_slave_tx_h.pwrite) begin
        `uvm_info(get_type_name(),$sformatf("apb_pwrite from master and slave is equal"),UVM_HIGH);
        `uvm_info("SB_PWRITE_MATCH", $sformatf("Master PWRITE = 'h%0x and Slave PWRITE = 'h%0x",apb_master_tx_h.pwrite,apb_slave_tx_h.pwrite), UVM_HIGH);
      end
      else begin
        `uvm_info(get_type_name(),$sformatf("apb_pwrite from master and slave is not equal"),UVM_HIGH);
        `uvm_error("ERROR_SC_PWRITE_MISMATCH", $sformatf("Master PWRITE = 'h%0x and Slave PWRITE = 'h%0x",apb_master_tx_h.pwrite,apb_slave_tx_h.pwrite));
      end
 
      // Data comparision for slave
  
      //-------------------------------------------------------
      //.....................prdata..........................// 
      //-------------------------------------------------------
      if(apb_slave_tx_h.prdata == apb_master_tx_h.prdata) begin
        `uvm_info(get_type_name(),$sformatf("apb_prdata from master and slave is equal"),UVM_HIGH);
        `uvm_info("SB_PRDATA_MATCHED", $sformatf("Master PRDATA = 'h%0x and Slave PRDATA = 'h%0x",apb_master_tx_h.prdata,apb_slave_tx_h.prdata), UVM_HIGH);
      end
      else begin
        `uvm_info(get_type_name(),$sformatf("apb_prdata from master and slave is not equal"),UVM_HIGH);
        `uvm_error("ERROR_SC_PRDATA_MISMATCH", $sformatf("Master PRDATA = 'h%0x and Slave PRDATA = 'h%0x",apb_master_tx_h.prdata,apb_slave_tx_h.prdata));
      end
 
      //.....................pprot..........................// 
      if(apb_slave_tx_h.pprot == apb_master_tx_h.pprot) begin
        `uvm_info(get_type_name(),$sformatf("apb_prdata from master and slave is equal"),UVM_HIGH);
        `uvm_info("SB_PPROT_MATCHED", $sformatf("Master PPROT = 'h%0x and Slave PPROT = 'h%0x",apb_master_tx_h.pprot,apb_slave_tx_h.pprot), UVM_HIGH);
      end
      else begin
        `uvm_info(get_type_name(),$sformatf("apb_prdata from master and slave is not equal"),UVM_HIGH);
        `uvm_error("ERROR_SC_PRDATA_MISMATCH", $sformatf("Master PPROT = %s and Slave PPROT = %s",apb_master_tx_h.pprot.name(),apb_slave_tx_h.pprot.name()));
      end
 
      `uvm_info(get_type_name(),$sformatf("--\n-----------------END OF SCOREBOARD COMPARISIONS---------------------------------------"),UVM_HIGH) 
 
    endfunction
endclass

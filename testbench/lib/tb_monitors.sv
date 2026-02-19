`ifndef TB_MONITORS_SV
`define TB_MONITORS_SV

import uvm_pkg::*;
`include "uvm_macros.svh"

import tb_cfg_pkg::*;

`include "tb_transactions.sv"
`include "tb_spi_monitor.sv"
`include "tb_spi_if.sv"

//==============================================================================
// SPI MONITOR
//==============================================================================

class spi_monitor extends uvm_monitor;
  `uvm_component_utils(spi_monitor)

  uvm_analysis_port #(spi_transaction) ap;
  uvm_tlm_analysis_fifo #(spi_transaction) intent_fifo;

  tb_spi_monitor spi_mon;
  spi_cfg        cfg;
  virtual tb_spi_if spi_if;

  byte collected_data[$];

  function new(string name="SPI_MON", uvm_component parent);
    super.new(name,parent);
    ap          = new("ap", this);
    intent_fifo = new("intent_fifo", this);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(virtual tb_spi_if)::get(
          this,"","spi_if",spi_if))
      `uvm_fatal("SPI_MON","SPI IF not found")

    spi_mon = new(spi_if);

    if (!uvm_config_db#(spi_cfg)::get(this, "", "spi_cfg", cfg))
      `uvm_fatal("SPI_CFG", "spi_cfg not found")

    spi_mon.apply_cfg(cfg);
  endfunction

  virtual task run_phase(uvm_phase phase);

    spi_transaction tr;

    forever begin
      intent_fifo.get(tr);

      spi_mon.receive_transaction(collected_data);

      if (!tr.is_write && collected_data.size() >= 3)
        tr.data = collected_data[2];

      ap.write(tr);
    end
  endtask

endclass


//==============================================================================
// GPIO MONITOR
//==============================================================================

class gpio_monitor extends uvm_monitor;
  `uvm_component_utils(gpio_monitor)

  uvm_analysis_port #(gpio_transaction) ap;
  uvm_tlm_analysis_fifo #(gpio_transaction) intent_fifo;

  function new(string name="GPIO_MON", uvm_component parent);
    super.new(name,parent);
    ap          = new("ap", this);
    intent_fifo = new("intent_fifo", this);
  endfunction

  virtual task run_phase(uvm_phase phase);

    gpio_transaction tr;

    forever begin
      intent_fifo.get(tr);
      ap.write(tr);
    end
  endtask

endclass

`endif

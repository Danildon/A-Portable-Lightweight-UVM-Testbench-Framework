//--------------------------------------------------------------------------------
// Date        : 02/01/2025
// Author      : Danilo D'Onofrio
// Description : Agents (single SPI + GPIO, UVM-correct)
//--------------------------------------------------------------------------------

`ifndef TB_AGENTS_SV
`define TB_AGENTS_SV

import uvm_pkg::*;
`include "uvm_macros.svh"

`include "tb_drivers.sv"
`include "tb_monitors.sv"


//==============================================================================
// SPI AGENT
//==============================================================================

class spi_agent extends uvm_agent;
  `uvm_component_utils(spi_agent)

  spi_txn_driver                   spi_d;
  spi_monitor                      spi_m;
  uvm_sequencer #(spi_transaction) spi_seqr;

  function new(string name="SPI_AGENT", uvm_component parent);
    super.new(name, parent);
  endfunction


  // ------------------------------------------------------------
  // Build
  // ------------------------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    spi_d    = spi_txn_driver::type_id::create("SPI_DRV",  this);
    spi_m    = spi_monitor   ::type_id::create("SPI_MON",  this);
    spi_seqr = uvm_sequencer#(spi_transaction)
                 ::type_id::create("SPI_SEQR", this);
  endfunction


  // ------------------------------------------------------------
  // Connect
  // ------------------------------------------------------------
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // Driver <-> Sequencer
    spi_d.seq_item_port.connect(
      spi_seqr.seq_item_export);

    // Driver intent → Monitor
    spi_d.ap.connect(
      spi_m.intent_fifo.analysis_export);
  endfunction

endclass



//==============================================================================
// GPIO AGENT
//==============================================================================

class gpio_agent extends uvm_agent;
  `uvm_component_utils(gpio_agent)

  gpio_driver                        gpio_d;
  gpio_monitor                       gpio_m;
  uvm_sequencer #(gpio_transaction)  gpio_seqr;

  function new(string name="GPIO_AGENT", uvm_component parent);
    super.new(name, parent);
  endfunction


  // ------------------------------------------------------------
  // Build
  // ------------------------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    gpio_d    = gpio_driver::type_id::create("GPIO_DRV", this);
    gpio_m    = gpio_monitor::type_id::create("GPIO_MON", this);
    gpio_seqr = uvm_sequencer#(gpio_transaction)
                  ::type_id::create("GPIO_SEQR", this);
  endfunction


  // ------------------------------------------------------------
  // Connect
  // ------------------------------------------------------------
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // Driver <-> Sequencer
    gpio_d.seq_item_port.connect(
      gpio_seqr.seq_item_export);

    // Driver intent → Monitor
    gpio_d.ap.connect(
      gpio_m.intent_fifo.analysis_export);
  endfunction

endclass


`endif

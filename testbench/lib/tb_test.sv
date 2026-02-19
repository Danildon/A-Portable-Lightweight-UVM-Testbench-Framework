`ifndef TB_TEST_SV
`define TB_TEST_SV

import uvm_pkg::*;
`include "uvm_macros.svh"

import tb_cfg_pkg::*;

`include "tb_env.sv"
`include "tb_generators.sv"

//==============================================================================
// TEST: stim_test
//==============================================================================

class stim_test extends uvm_test;

  `uvm_component_utils(stim_test)

  // --------------------------------------------------------------------------
  // Configuration objects
  // --------------------------------------------------------------------------
  spi_cfg spi_cfg_h;

  // --------------------------------------------------------------------------
  // Environment & stimulus
  // --------------------------------------------------------------------------
  env             e;
  fstim_generator fs;

  // --------------------------------------------------------------------------
  // Runtime parameters
  // --------------------------------------------------------------------------
  string stim_file;

  // --------------------------------------------------------------------------
  // Constructor
  // --------------------------------------------------------------------------
  function new(string name="STIM_TEST", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  // --------------------------------------------------------------------------
  // Build phase
  // --------------------------------------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // ------------------------------------------------------
    // SPI configuration (single-CS SPI slave)
    // ------------------------------------------------------
    spi_cfg_h = spi_cfg::type_id::create("spi_cfg_h");

    spi_cfg_h.spi_mode            = 0;      // Mode 0 (CPOL=0, CPHA=0)
    spi_cfg_h.bits_per_word       = 8;
    spi_cfg_h.clk_period          = 40.0;   // ns
    spi_cfg_h.clk_inactive_period = 100.0;
    spi_cfg_h.cs_inactive_period  = 100.0;

    // Make SPI config visible to ENV / drivers / monitors
    uvm_config_db#(spi_cfg)::set(
      this,
      "ENV.*",
      "spi_cfg",
      spi_cfg_h
    );

    // ------------------------------------------------------
    // Stimulus file
    // ------------------------------------------------------
    if (!$value$plusargs("STIMULI_FILE=%s", stim_file))
      `uvm_fatal("STIM_TEST", "STIMULI_FILE plusarg not provided")

    `uvm_info("STIM_TEST",
              $sformatf("STIMULI_FILE = %s", stim_file),
              UVM_LOW)

    // Publish stimulus file globally (used by FILE_SEQ)
    uvm_config_db#(string)::set(
      null,
      "*",
      "stimuli_file",
      stim_file
    );

    // ------------------------------------------------------
    // Create environment and generator
    // ------------------------------------------------------
    e  = env             ::type_id::create("ENV", this);
    fs = fstim_generator ::type_id::create("FILE_SEQ");

  endfunction

  // --------------------------------------------------------------------------
  // Run phase
  // --------------------------------------------------------------------------
  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);

    // Single execution path:
    //  - generator parses file
    //  - dispatches to SPI / GPIO sequencers
    fs.start(null);

    phase.drop_objection(this);
  endtask

endclass

`endif // TB_TEST_SV

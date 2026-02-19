//--------------------------------------------------------------------------------
// Date        : 02/01/2025
// Author      : Danilo D'Onofrio
// Description : UVM environment (single SPI + GPIO, UVM-correct)
//--------------------------------------------------------------------------------

`ifndef TB_ENV_SV
`define TB_ENV_SV

import uvm_pkg::*;
`include "uvm_macros.svh"

`include "tb_agents.sv"
`include "tb_scoreboards.sv"

//==============================================================================
// ENV
//==============================================================================

class env extends uvm_env;

  `uvm_component_utils(env)

  // ---------------------------------------------------------------------------
  // Agents
  // ---------------------------------------------------------------------------
  spi_agent   spi_agt;
  gpio_agent  gpio_agt;

  // ---------------------------------------------------------------------------
  // Scoreboards
  // ---------------------------------------------------------------------------
  spi_scoreboard   spi_scor;
  gpio_scoreboard  gpio_scor;

  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------
  function new(string name="ENV", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  // ---------------------------------------------------------------------------
  // Build phase
  // ---------------------------------------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    spi_agt  = spi_agent  ::type_id::create("SPI_AGENT",  this);
    gpio_agt = gpio_agent ::type_id::create("GPIO_AGENT", this);

    spi_scor  = spi_scoreboard  ::type_id::create("SPI_SCOR",  this);
    gpio_scor = gpio_scoreboard ::type_id::create("GPIO_SCOR", this);
  endfunction

  // ---------------------------------------------------------------------------
  // Connect phase
  // ---------------------------------------------------------------------------
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // ==========================================================
    // MONITOR → SCOREBOARD
    // ==========================================================
    spi_agt.spi_m.ap.connect(spi_scor.recv);
    gpio_agt.gpio_m.ap.connect(gpio_scor.recv);

    // ==========================================================
    // Publish sequencers for FILE_SEQ
    // ==========================================================
    uvm_config_db#(uvm_sequencer #(spi_transaction))::set(
      null, "*", "SPI_SEQR", spi_agt.spi_seqr
    );

    uvm_config_db#(uvm_sequencer #(gpio_transaction))::set(
      null, "*", "GPIO_SEQR", gpio_agt.gpio_seqr
    );

    `uvm_info("ENV",
      "SPI and GPIO sequencers published for FILE_SEQ",
      UVM_LOW)
  endfunction

endclass

`endif // TB_ENV_SV

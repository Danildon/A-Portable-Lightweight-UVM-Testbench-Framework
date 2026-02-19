//--------------------------------------------------------------------------------
// Date        : 02/01/2025
// Author      : Danilo D'Onofrio
// Description : Single-CS SPI interface for testbench ↔ DUT communication
//--------------------------------------------------------------------------------

`ifndef TB_SPI_IF_SV
`define TB_SPI_IF_SV

import uvm_pkg::*;
`include "uvm_macros.svh"

interface tb_spi_if;

  // ------------------------------------------------------------
  // SPI signals
  // ------------------------------------------------------------
  logic mosi = 1'b0;
  logic sclk = 1'b0;
  logic cs   = 1'b1;      // Active-low
  tri   logic miso;

  // ------------------------------------------------------------
  // Access helpers (used by low-level SPI driver)
  // ------------------------------------------------------------

  function logic get_mosi();
    return mosi;
  endfunction

  task set_mosi(input logic val);
    mosi <= val;
  endtask

  function logic get_sclk();
    return sclk;
  endfunction

  task set_sclk(input logic val);
    sclk <= val;
  endtask

  function logic get_cs();
    return cs;
  endfunction

  task set_cs(input logic val);
    cs <= val;
  endtask

  function logic get_miso();
    return miso;
  endfunction

endinterface

`endif // TB_SPI_IF_SV

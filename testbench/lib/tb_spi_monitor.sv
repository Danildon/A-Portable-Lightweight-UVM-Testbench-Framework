//------------------------------------------------------------------------------
// Date        : 02/01/2025
// Author      : Danilo D'Onofrio
// Description : LOW-LEVEL SPI Monitor (single-CS)
//------------------------------------------------------------------------------

`ifndef TB_SPI_MONITOR_SV
`define TB_SPI_MONITOR_SV

import uvm_pkg::*;
import tb_cfg_pkg::*;
`include "uvm_macros.svh"

`include "tb_spi_if.sv"

class tb_spi_monitor;

  virtual tb_spi_if vif_m;

  int  spi_mode          = 0;
  int  spi_bits_per_word = 8;
  
  byte received_byte;
  byte received_data[];

  function new(virtual tb_spi_if vif_m);
    this.vif_m = vif_m;
  endfunction

  function void apply_cfg(spi_cfg cfg);
    spi_mode          = cfg.spi_mode;
    spi_bits_per_word = cfg.bits_per_word;
  endfunction
  
  // ------------------------------------------------------------
  // Receive a single byte
  // ------------------------------------------------------------
    task automatic receive_byte(output byte received_byte);
        received_byte = 0; // Initialize received byte

        for (int i = 7; i >= 0; i--) begin
            // Adjust clock/Data Phase based on CPHA
            if (spi_mode == 0 || spi_mode == 2) begin
                @(negedge vif_m.sclk); // Rising edge
                received_byte[i] = vif_m.miso; // Sample MISO on rising edge
            end else begin
                @(posedge vif_m.sclk); // Rising edge
                received_byte[i] = vif_m.miso; // Sample MISO on rising edge
            end
        end
    endtask

  // ------------------------------------------------------------
  // Capture full SPI transaction (CS low window)
  // ------------------------------------------------------------
  task automatic receive_transaction(output byte received_data[$]);
    received_data = {}; // Initialize the dynamic array

        // Wait for chip-select to become active (assumed active low)
        wait(vif_m.cs == 0);

        // Continue receiving bytes while CS remains low.
        // Each call to receive_byte captures one byte.
        while (vif_m.cs == 0) begin
            receive_byte(received_byte);
            received_data.push_back(received_byte);
            if (spi_mode == 0 || spi_mode == 2) begin
                wait (vif_m.sclk == 1 || vif_m.cs == 1);
            end else begin
                wait (vif_m.sclk == 0 || vif_m.cs == 1);
            end
        end

  endtask

endclass

`endif

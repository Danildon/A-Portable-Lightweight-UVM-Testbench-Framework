//--------------------------------------------------------------------------------
// Date        : 02/01/2025
// Author      : Danilo D'Onofrio
// Description : Scoreboards (Single-CS SPI + GPIO)
//--------------------------------------------------------------------------------

`ifndef TB_SCOREBOARDS_SV
`define TB_SCOREBOARDS_SV

import uvm_pkg::*;
`include "uvm_macros.svh"

`include "tb_transactions.sv"


//==============================================================================
// SPI SCOREBOARD
//==============================================================================

class spi_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(spi_scoreboard)

  uvm_analysis_imp#(spi_transaction, spi_scoreboard) recv;

  function new(string name="SPI_SCO", uvm_component parent=null);
    super.new(name, parent);
    recv = new("recv", this);
  endfunction


  virtual function void write(spi_transaction trans);

    `uvm_info("SPI_SCO",
      $sformatf("Received SPI transaction ID=%0d", 
        trans.transaction_id),
      UVM_LOW)

    if (!trans.is_write) begin

      if (!trans.compare_data) begin
        `uvm_info("SPI_SCO",
          $sformatf("Read (no compare): Addr=0x%02h Data=0x%02h",
            trans.addr, trans.data),
          UVM_LOW)
        return;
      end

      if (trans.data === trans.expected_data) begin
        `uvm_info("SPI_SCO",
          $sformatf("Read OK: Addr=0x%02h Data=0x%02h",
            trans.addr, trans.data),
          UVM_LOW)
      end
      else begin
        `uvm_error("SPI_SCO",
          $sformatf("Read MISMATCH: Addr=0x%02h Data=0x%02h Expected=0x%02h",
            trans.addr, trans.data, trans.expected_data))
      end

    end
    else begin
      `uvm_info("SPI_SCO",
        $sformatf("Write: Addr=0x%02h Data=0x%02h",
          trans.addr, trans.data),
        UVM_LOW)
    end

  endfunction

endclass



//==============================================================================
// GPIO SCOREBOARD
//==============================================================================

class gpio_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(gpio_scoreboard)

  uvm_analysis_imp#(gpio_transaction, gpio_scoreboard) recv;

  function new(string name="GPIO_SCO", uvm_component parent=null);
    super.new(name, parent);
    recv = new("recv", this);
  endfunction


  virtual function void write(gpio_transaction trans);

    `uvm_info("GPIO_SCO",
      $sformatf("Received GPIO transaction ID=%0d",
        trans.transaction_id),
      UVM_LOW)

    if (trans.compare_value) begin

      if (trans.value === trans.expected_value) begin
        `uvm_info("GPIO_SCO",
          $sformatf("GPIO[%0d] OK: value=%0b",
            trans.gpio_offset, trans.value),
          UVM_LOW)
      end
      else begin
        `uvm_error("GPIO_SCO",
          $sformatf("GPIO[%0d] MISMATCH: value=%0b expected=%0b",
            trans.gpio_offset,
            trans.value,
            trans.expected_value))
      end

    end

  endfunction

endclass


`endif

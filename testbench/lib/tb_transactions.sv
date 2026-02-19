//------------------------------------------------------------------------------
// Date        : 02/01/2025
// Author      : Danilo D'Onofrio
// Description : Clean transaction layer for
//               Single-CS SPI + GPIO Register-Mapped DUT
//------------------------------------------------------------------------------

`ifndef TB_TRANSACTIONS_SV
`define TB_TRANSACTIONS_SV

import uvm_pkg::*;
`include "uvm_macros.svh"

//==============================================================================
// BASE TRANSACTION
//==============================================================================

class tb_base_transaction extends uvm_sequence_item;

  int unsigned transaction_id;

  function new(string name="TB_BASE_TRANS");
    super.new(name);
  endfunction

  `uvm_object_utils(tb_base_transaction)

endclass


//==============================================================================
// SPI REGISTER TRANSACTION
//==============================================================================
// 3-byte protocol:
//   byte0 = {7'b0, is_write}
//   byte1 = addr
//   byte2 = data (write) or dummy (read)
//==============================================================================

class spi_transaction extends tb_base_transaction;

  rand bit        is_write;        // 1 = WRITE, 0 = READ
  rand bit [7:0]  addr;
  rand bit [7:0]  data;            // Write data or read result

  bit             compare_data;    // Scoreboard enable
  bit [7:0]       expected_data;

  // Constraints
  constraint addr_c { addr inside {[0:255]}; }

  function new(string name="SPI_TRANS");
    super.new(name);
  endfunction

  `uvm_object_utils_begin(spi_transaction)
    `uvm_field_int(transaction_id, UVM_DEFAULT)
    `uvm_field_int(is_write,       UVM_DEFAULT)
    `uvm_field_int(addr,           UVM_DEFAULT)
    `uvm_field_int(data,           UVM_DEFAULT)
    `uvm_field_int(compare_data,   UVM_DEFAULT)
    `uvm_field_int(expected_data,  UVM_DEFAULT)
  `uvm_object_utils_end

  function void copy(spi_transaction rhs);
    if (rhs == null)
      `uvm_fatal("SPI_TRANS", "Null copy handle")

    this.transaction_id = rhs.transaction_id;
    this.is_write       = rhs.is_write;
    this.addr           = rhs.addr;
    this.data           = rhs.data;
    this.compare_data   = rhs.compare_data;
    this.expected_data  = rhs.expected_data;
  endfunction

endclass


//==============================================================================
// GPIO TRANSACTION
//==============================================================================
// Supports 8 GPIO input + 8 GPIO output
//==============================================================================

class gpio_transaction extends tb_base_transaction;

  rand bit        is_write;        // 1 = SET (output), 0 = GET (input)
  rand bit [2:0]  gpio_offset;     // 0..7
  rand bit        value;
  
  string		  sig_name;

  bit             compare_value;
  bit             expected_value;

  constraint idx_c { gpio_offset inside {[0:7]}; }

  function new(string name="GPIO_TRANS");
    super.new(name);
  endfunction

  `uvm_object_utils_begin(gpio_transaction)
    `uvm_field_int(transaction_id, UVM_DEFAULT)
    `uvm_field_int(is_write,       UVM_DEFAULT)
    `uvm_field_int(gpio_offset,     UVM_DEFAULT)
    `uvm_field_int(value,          UVM_DEFAULT)
    `uvm_field_int(compare_value,  UVM_DEFAULT)
    `uvm_field_int(expected_value, UVM_DEFAULT)
  `uvm_object_utils_end

  function void copy(gpio_transaction rhs);
    if (rhs == null)
      `uvm_fatal("GPIO_TRANS", "Null copy handle")

    this.transaction_id = rhs.transaction_id;
    this.is_write       = rhs.is_write;
    this.gpio_offset    = rhs.gpio_offset;
    this.value          = rhs.value;
    this.compare_value  = rhs.compare_value;
    this.expected_value = rhs.expected_value;
  endfunction

endclass

`endif // TB_TRANSACTIONS_SV

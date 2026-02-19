`ifndef TB_DRIVERS_SV
`define TB_DRIVERS_SV

import uvm_pkg::*;
`include "uvm_macros.svh"

`include "tb_transactions.sv"
`include "tb_spi_if.sv"
`include "tb_gpio_if.sv"
`include "tb_spi_driver.sv"

//==============================================================================
// SPI TRANSACTION DRIVER
//==============================================================================

class spi_txn_driver extends uvm_driver #(spi_transaction);
  `uvm_component_utils(spi_txn_driver)

  virtual tb_spi_if spi_vif;
  tb_spi_driver     ll_driver;
  
  spi_cfg      	cfg;

  // Publish intent to monitor
  uvm_analysis_port #(spi_transaction) ap;

  function new(string name="SPI_TXN_DRV", uvm_component parent=null);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(virtual tb_spi_if)::get(
          this, "", "spi_if", spi_vif))
      `uvm_fatal("SPI_TXN_DRV", "spi_if not found")

    ll_driver = new(spi_vif);
	
	if (!uvm_config_db#(spi_cfg)::get(this, "", "spi_cfg", cfg))
			`uvm_fatal("SPI_CFG", "spi_cfg not found");
		
	// apply SPI configuration
	ll_driver.apply_cfg(cfg);
  endfunction

  virtual task run_phase(uvm_phase phase);

    spi_transaction tr;
    byte tx_bytes[$];

    forever begin
      seq_item_port.get_next_item(tr);

      tx_bytes = {};

      tx_bytes.push_back(tr.is_write ? 8'h01 : 8'h00);
      tx_bytes.push_back(tr.addr);
      tx_bytes.push_back(tr.data);

      ap.write(tr); // publish intent BEFORE driving bus

      ll_driver.send_multi_byte(tx_bytes);

      seq_item_port.item_done();
    end
  endtask

endclass


//==============================================================================
// GPIO DRIVER
//==============================================================================

class gpio_driver extends uvm_driver #(gpio_transaction);
  `uvm_component_utils(gpio_driver)

  virtual tb_gpio_if gpio_vif;
  uvm_analysis_port #(gpio_transaction) ap;

  function new(string name="GPIO_DRV", uvm_component parent=null);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(virtual tb_gpio_if)::get(
          this, "", "gpio_vif", gpio_vif))
      `uvm_fatal("GPIO_DRV", "gpio_vif not found")
  endfunction

  virtual task run_phase(uvm_phase phase);

    gpio_transaction tr;

    forever begin
      seq_item_port.get_next_item(tr);

      if (tr.is_write)
        gpio_vif.set_gpio(tr.sig_name, tr.gpio_offset, tr.value);
      else
        tr.value = gpio_vif.get_gpio(tr.sig_name, tr.gpio_offset);

      ap.write(tr);

      seq_item_port.item_done();
    end
  endtask

endclass

`endif

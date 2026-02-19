// -----------------------------------------------------------------------------
// Open-source SPI + GPIO reference TB (tb_utils aligned)
// -----------------------------------------------------------------------------

`timescale 1ns / 1ps

import uvm_pkg::*;
`include "uvm_macros.svh"

`include "../lib/tb_utils.sv"
`include "../lib/tb_spi_if.sv"
`include "../lib/tb_gpio_if.sv"
`include "../lib/tb_test.sv"

module tb_top #(
  parameter real  CLK_PERIOD         = 5.0,
  parameter real  RST_ASSERT_TIME    = 80.0,
  parameter real  RST_DEASSERT_TIME  = 120.0,
  parameter logic RST_ACTIVE_LOW     = 0
);

  // ---------------------------------------------------------------------------
  // Clock / Reset
  // ---------------------------------------------------------------------------
  logic tb_clk;
  logic tb_rst;

  // ---------------------------------------------------------------------------
  // Interfaces
  // ---------------------------------------------------------------------------
  tb_spi_if  spi_if();
  tb_gpio_if gpio_if();

  // ---------------------------------------------------------------------------
  // DUT
  // ---------------------------------------------------------------------------
  spi_slave_gpio_regmap DUT (
    .clk      (tb_clk),
    .rst_n    (tb_rst),

    .cs       (spi_if.cs),
    .sclk     (spi_if.sclk),
    .mosi     (spi_if.mosi),
    .miso     (spi_if.miso),

    .gpio_in  (gpio_if.gpio_in),
    .gpio_out (gpio_if.gpio_out)
  );

  // ---------------------------------------------------------------------------
  // Clock & Reset generation
  // ---------------------------------------------------------------------------
  initial begin
    fork
      tb_utils::generate_clk(tb_clk, CLK_PERIOD);
      tb_utils::generate_reset(tb_rst,
                               RST_ASSERT_TIME,
                               RST_DEASSERT_TIME,
                               RST_ACTIVE_LOW);
    join_none
  end

  // ---------------------------------------------------------------------------
  // UVM configuration + test start
  // ---------------------------------------------------------------------------
  initial begin
    uvm_config_db#(virtual tb_spi_if)::set(
      null, "*", "spi_if", spi_if
    );

    uvm_config_db#(virtual tb_gpio_if)::set(
      null, "*", "gpio_vif", gpio_if
    );

    run_test();
  end

endmodule

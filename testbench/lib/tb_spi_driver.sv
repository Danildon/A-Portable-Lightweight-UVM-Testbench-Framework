//------------------------------------------------------------------------------
// Date        : 02/01/2025
// Author      : Danilo D'Onofrio
// Description : SPI driver (LOW-LEVEL, NON-UVM, SINGLE-CS)
//------------------------------------------------------------------------------

`ifndef TB_SPI_DRIVER_SV
`define TB_SPI_DRIVER_SV

import tb_cfg_pkg::*;

`include "tb_spi_if.sv"

class tb_spi_driver;

  // ------------------------------------------------------------
  // Virtual interface
  // ------------------------------------------------------------
  virtual tb_spi_if vif_d;

  // ------------------------------------------------------------
  // SPI configuration
  // ------------------------------------------------------------
  int  spi_mode                = 0;     // 0..3
  int  spi_bits_per_word       = 8;
  real spi_clk_period          = 10.0;  // ns
  real spi_clk_inactive_period = 100.0;  // ns
  real spi_cs_inactive_period  = 100.0;  // ns

  // ------------------------------------------------------------
  // Constructor
  // ------------------------------------------------------------
  function new(virtual tb_spi_if vif_d);
    this.vif_d = vif_d;
  endfunction

  // ------------------------------------------------------------
  // Configure
  // ------------------------------------------------------------
  function void configure(
    input int  mode,
    input int  bits_per_word,
    input real clk_period,
    input real clk_inactive_period,
    input real cs_inactive_period
  );

    if (mode < 0 || mode > 3)
      $fatal(1, "Invalid SPI mode: %0d", mode);

    if (bits_per_word <= 0)
      $fatal(1, "bits_per_word must be > 0");

    if (clk_period <= 0.0)
      $fatal(1, "clk_period must be > 0");

    if (clk_inactive_period <= 0.0)
      $fatal(1, "clk_inactive_period must be > 0");

    if (cs_inactive_period <= 0.0)
      $fatal(1, "cs_inactive_period must be > 0");

    this.spi_mode                = mode;
    this.spi_bits_per_word       = bits_per_word;
    this.spi_clk_period          = clk_period;
    this.spi_clk_inactive_period = clk_inactive_period;
    this.spi_cs_inactive_period  = cs_inactive_period;
  endfunction
  
  // ------------------------------------------------------------
  // configure from spi_cfg object
  // ------------------------------------------------------------
  function void apply_cfg(spi_cfg cfg);
    configure(
      cfg.spi_mode,
      cfg.bits_per_word,
      cfg.clk_period,
      cfg.clk_inactive_period,
      cfg.cs_inactive_period
    );
  endfunction


  // ------------------------------------------------------------
  // Initialize SPI clock (CPOL handling)
  // ------------------------------------------------------------
  task automatic init_spi_clock();
    case (spi_mode)
      0,1: vif_d.set_sclk(1'b0); // CPOL = 0
      2,3: vif_d.set_sclk(1'b1); // CPOL = 1
    endcase
    #(spi_clk_period);
  endtask


  // ------------------------------------------------------------
  // Chip select control (active-low)
  // ------------------------------------------------------------
  task automatic toggle_cs(input logic val);
    vif_d.set_cs(val);
  endtask


  // ------------------------------------------------------------
  // Send one byte (mode 0/1/2/3 compliant)
  // ------------------------------------------------------------
  task automatic send_byte(input byte data);
    int i;
    bit cpol = (spi_mode >= 2);
    bit cpha = (spi_mode % 2);

    for (i = spi_bits_per_word-1; i >= 0; i--) begin

      if (cpha == 0) begin
        // Data valid before leading edge
        vif_d.set_mosi(data[i]);

        #(spi_clk_period/2);
        vif_d.set_sclk(~vif_d.get_sclk());  // Leading edge

        #(spi_clk_period/2);
        vif_d.set_sclk(~vif_d.get_sclk());  // Trailing edge

      end else begin
        // Data valid after leading edge
        #(spi_clk_period/2);
        vif_d.set_sclk(~vif_d.get_sclk());  // Leading edge

        vif_d.set_mosi(data[i]);

        #(spi_clk_period/2);
        vif_d.set_sclk(~vif_d.get_sclk());  // Trailing edge
      end
    end
  endtask


  // ------------------------------------------------------------
  // Send multiple bytes (single CS window)
  // ------------------------------------------------------------
  task automatic send_multi_byte(input byte data[]);

    init_spi_clock();

    toggle_cs(1'b0);                 // Assert CS
    #(spi_cs_inactive_period);

    foreach (data[i]) begin
      send_byte(data[i]);
      #(spi_clk_inactive_period);
    end

    #(spi_cs_inactive_period);
    toggle_cs(1'b1);                 // Deassert CS
  endtask

endclass

`endif // TB_SPI_DRIVER_SV

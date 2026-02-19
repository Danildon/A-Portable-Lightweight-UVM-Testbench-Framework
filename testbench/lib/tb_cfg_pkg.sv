//--------------------------------------------------------------------------------
//Date        : 02/01/2025
//Design      : --
//By          : Danilo D'Onofrio
//--------------------------------------------------------------------------------

`ifndef TB_CFG_PKG
`define TB_CFG_PKG
package tb_cfg_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class spi_cfg extends uvm_object;
    `uvm_object_utils(spi_cfg)

    int  spi_mode;
    int  bits_per_word;
    real clk_period;
    real clk_inactive_period;
    real cs_inactive_period;

    function new(string name="spi_cfg");
      super.new(name);
    endfunction
  endclass

endpackage

`endif // TB_CFG_PKG

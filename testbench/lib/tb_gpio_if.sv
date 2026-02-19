//--------------------------------------------------------------------------------
// Date        : 02/01/2025
// Author      : Danilo D'Onofrio
// Description : Generic GPIO interface (8 IN / 8 OUT)
//--------------------------------------------------------------------------------

`ifndef TB_GPIO_IF_SV
`define TB_GPIO_IF_SV

import uvm_pkg::*;
`include "uvm_macros.svh"

interface tb_gpio_if;

  // ------------------------------------------------------------
  // GPIO vectors
  // ------------------------------------------------------------
  logic [7:0] gpio_in;   // Driven by TB → DUT
  logic [7:0] gpio_out;  // Driven by DUT → TB

  // ------------------------------------------------------------
  // Access helpers (used by driver)
  // ------------------------------------------------------------

  // Task to set GPIO value
  task set_gpio(input string sig_name, input int offset, input logic value);
    case (sig_name)
      // 
      "gpio_in"       	: gpio_in[offset]	= value;
      "gpio_out"       	: gpio_out[offset]	= value;
      default: begin
        `uvm_error("GPIO_IF", $sformatf("Unknown GPIO signal: %s", sig_name));
      end
    endcase
  endtask


  // Function to get GPIO value
  function logic get_gpio(input string sig_name, input int offset);
    case (sig_name)
      // 
      "gpio_in"       	: return gpio_in[offset];
      "gpio_out"       	: return gpio_out[offset];
      default: begin
        `uvm_error("GPIO_IF", $sformatf("Unknown GPIO signal: %s", sig_name));
        return 1'bx;
      end
    endcase
  endfunction

endinterface

`endif // TB_GPIO_IF_SV

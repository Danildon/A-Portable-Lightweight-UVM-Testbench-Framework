//--------------------------------------------------------------------------------
// Date        : 02/01/2025
// Author      : Danilo D'Onofrio
// Description : File Stimuli Generator (Single SPI + 8x GPIO)
//--------------------------------------------------------------------------------

`ifndef TB_GENERATORS_SV
`define TB_GENERATORS_SV

import uvm_pkg::*;
`include "uvm_macros.svh"

`include "tb_transactions.sv"
`include "tb_utils.sv"

class fstim_generator extends uvm_sequence #(uvm_sequence_item);
  `uvm_object_utils(fstim_generator)

  string stimuli_file;

  uvm_sequencer #(spi_transaction)  spi_seqr;
  uvm_sequencer #(gpio_transaction) gpio_seqr;

  function new(string name="FILE_SEQ");
    super.new(name);
  endfunction

  //--------------------------------------------------------------------------
  // BODY
  //--------------------------------------------------------------------------
  virtual task body();

    int fd;
    string line;
	
	int		n;
    int    	stim_f_ln_num = 0;
	
	// Raw tokens (ALL STRINGS)
    string 	t0, t1, t2, t3, t4, t5, t6;
	
	// ----------------------------------------------------------
    // Get stimulus file
    // ----------------------------------------------------------
	
	if (!uvm_config_db#(string)::get(null,"","stimuli_file",stimuli_file))
      `uvm_fatal("FILE_SEQ","stimuli_file not found")

    // ----------------------------------------------------------
    // Get sequencers
    // ----------------------------------------------------------
	
    if (!uvm_config_db#(uvm_sequencer #(spi_transaction))::get(
          null,"*","SPI_SEQR",spi_seqr))
      `uvm_fatal("FILE_SEQ","SPI_SEQR not found")

    if (!uvm_config_db#(uvm_sequencer #(gpio_transaction))::get(
          null,"*","GPIO_SEQR",gpio_seqr))
      `uvm_fatal("FILE_SEQ","GPIO_SEQR not found")
	  
	// ----------------------------------------------------------
    // Parse file
    // ----------------------------------------------------------
	
	`uvm_info("FILE_SEQ",
              $sformatf("Opening stimuli file: %s", stimuli_file),
              UVM_LOW)

    fd = $fopen(stimuli_file,"r");
    if (!fd)
		`uvm_fatal("FILE_SEQ",$sformatf("Cannot open file %s",stimuli_file))

	while (!$feof(fd)) begin

		stim_f_ln_num++;
		void'($fgets(line, fd));

		if (line.len() == 0) continue;

		if (line.len() >= 3 && line.substr(0,2) == "###") continue;
		
		// --------------------------------------------------------
		// Tokenize line (up to 7 string tokens)
		// --------------------------------------------------------
		n = $sscanf(line, "%s %s %s %s %s %s %s",
					  t0, t1, t2, t3, t4, t5, t6);

		// --------------------------------------------------------
		// PAUSE
		// --------------------------------------------------------
		if (t0 == "PAUSE") begin
			if (t1 == "NS") #(t2.atoi() * 1ns);
			else if (t1 == "US") #(t2.atoi() * 1us);
			else if (t1 == "MS") #(t2.atoi() * 1ms);
			else
			  `uvm_error("FILE_SEQ", $sformatf("Invalid PAUSE unit at line %0d", stim_f_ln_num))
			continue;
		end

		if (n < 3) begin
			`uvm_error("FILE_SEQ",
			  $sformatf("Malformed line %0d: %s", stim_f_ln_num, line))
			continue;
		end

		//==============================================================
		// SPI
		// Format:
		// SPI 	RD 			0		0xA5				SB_VERIFY
		//==============================================================
		if (t0 == "SPI") begin

			spi_transaction tr;
			tr = spi_transaction::type_id::create("spi_tr");

			tr.transaction_id = stim_f_ln_num;
			
			tr.is_write = (t1 == "WR");
			
			if (!tr.is_write) begin // RD
			  tr.addr = t2.atoi();
			  tr.expected_data = t3.atohex();
			  tr.compare_data  = (t4 == "SB_VERIFY");
			end
			else if (tr.is_write) begin
			  tr.addr = t2.atoi();
			  tr.expected_data = 0;
			  tr.data = t3.atohex();
			  tr.compare_data  = 1'b0;
			end
			else begin
			  `uvm_error("FILE_SEQ", $sformatf("Invalid SPI operation at line %0d", stim_f_ln_num))
			  continue;
			end

			this.set_sequencer(spi_seqr);
			start_item(tr);
			finish_item(tr);

			continue;
		end

		//==============================================================
		// GPIO
		// Format:
		// GPIO	gpio_in		0		SET		0			SB_BYPASS
		//==============================================================
		if (t0 == "GPIO") begin

			gpio_transaction gtr;
			gtr = gpio_transaction::type_id::create("gpio_tr");

			gtr.transaction_id 	= stim_f_ln_num;
			gtr.sig_name			= t1;
			gtr.gpio_offset 		= t2.atoi();
			gtr.is_write   		= (t3 == "SET");

			gtr.value 			= t4.atoi();

			if (!gtr.is_write) begin //RD
				gtr.expected_value = t4.atoi();
				gtr.compare_value  = (t5 == "SB_VERIFY");
			end
			else if (gtr.is_write) begin //WR
			  gtr.expected_value = 0;
			  gtr.compare_value  = 0;
			end
			else begin
			  `uvm_error("FILE_SEQ", $sformatf("Invalid GPIO op at line %0d", stim_f_ln_num))
			  continue;
			end

			  this.set_sequencer(gpio_seqr);
			  start_item(gtr);
			  finish_item(gtr);

			  continue;
		end
	end

    $fclose(fd);

  endtask

endclass

`endif

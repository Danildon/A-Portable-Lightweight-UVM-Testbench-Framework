//--------------------------------------------------------------------------------
//Date        : 02/01/2025
//Design      : --
//By          : Danilo D'Onofrio
//--------------------------------------------------------------------------------

`ifndef TB_UTILS
`define TB_UTILS

class tb_utils;

  // Clock generation
  static task automatic generate_clk(ref logic clk, input real clk_period);
  begin
    clk = 0;
    forever begin
      #(clk_period / 2) clk = ~clk; // Toggle clock
    end
  end
endtask

  // Reset generation
  static task automatic generate_reset(ref logic rst, input real rst_assert_time, input real rst_deassert_time, input logic active_low);
    begin
      if (!active_low) begin // Active low reset
        rst = 1; // Initial value (deasserted)
        #rst_assert_time;
        rst = 0; // Assert
        #rst_deassert_time;
        rst = 1; // Deassert
      end else begin // Active high reset
        rst = 0; // Initial value (deasserted)
        #rst_assert_time;
        rst = 1; // Assert
        #rst_deassert_time;
        rst = 0; // Deassert
      end
    end
  endtask

  // Delay in ns
  static task automatic delay_ns(input real time_ns);
    #(time_ns); // Delay for the specified time in ns
  endtask
  
  // Delay in us
  static task automatic delay_us(input real time_us);
    #(1_000*time_us); // Delay for the specified time in ns
  endtask
  
  // Delay in ms
  static task automatic delay_ms(input real time_ms);
    #(1_000_000*time_ms); // Delay for the specified time in ns
  endtask
  
  // Delay in s
  static task automatic delay_s(input real time_s);
    #(1_000_000_000*time_s); // Delay for the specified time in s
  endtask

  // Display message with timestamp
  static function automatic void display_msg(input string message);
    $display("%0t: %s", $time/1000, message); // Print timestamp with the message
  endfunction

  // Random integer generation (within a range)
  static function automatic int get_random_int(input int min, input int max);
    return $urandom_range(min, max); // Return a random integer in the specified range
  endfunction

  // Random real number generation (between 0 and 1)
  static function automatic real get_random_real();
    real max_int = 2147483647.0; // Maximum value for a 32-bit signed integer
    return $random / max_int; // Generate a random real number between 0 and 1
  endfunction

  // Convert real to string with precision
  static function automatic string real_to_string(input real value, input int precision);
    string fmt;
    string s;
    // Step 1: Create the format string, e.g., "%0.3g" if precision is 3
    fmt = $sformatf("%%0.%0dg", precision); 
    // Step 2: Apply the format to the value
    $sformat(s, fmt, value);
    return s;
  endfunction

  // Convert integer to string
  static function automatic string int_to_string(input int value);
    string s;
    $sformat(s, "%0d", value); // Format integer as string
    return s;
  endfunction

  // String concatenation
  static function automatic string concat_strings(input string str1, input string str2);
    return {str1, str2}; // Concatenate strings
  endfunction

  // Check if a signal is high/low
  static function automatic bit is_high(input logic signal);
    return signal === 1'b1; // Check if signal is high
  endfunction

  static function automatic bit is_low(input logic signal);
    return signal === 1'b0; // Check if signal is low
  endfunction

  // Array initialization
  static function automatic void init_array(output int array[], input int size, input int value);
    for (int i = 0; i < size; i++) begin
      array[i] = value; // Initialize all elements to the specified value
    end
  endfunction

  // Print an array
  static function automatic void print_array(input int array[], input int size, input string array_name);
    $display("%s:", array_name); // Display array name
    for (int i = 0; i < size; i++) begin
      $write("%d ", array[i]); // Display array elements
    end
    $display(); // New line after printing the array
  endfunction

  // Assert a condition (with a message)
  static task automatic assert_cond(input bit condition, input string message);
    if (!condition) begin
      $error("%0t: Assertion failed: %s", $time, message); // Print error if condition fails
      $finish; // End simulation (or use $stop if you prefer to pause)
    end else begin
      $info("%0t: Assertion passed: %s", $time, message); // Print info if condition passes
    end
  endtask

  // Wait for a condition to become true (with timeout)
  static task automatic wait_for_cond(input bit condition, input string message, input real timeout_ns);
    real start_time = $time;
    while (!condition) begin
      #(1); // Wait for 1 time unit (adjust if needed)
      if (($time - start_time) >= timeout_ns) begin
        $error("%0t: Timeout waiting for condition: %s", $time, message); // Print error on timeout
        $finish; // End simulation (or use $stop if you prefer to pause)
        return; // Exit task
      end
    end
    $info("%0t: Condition met: %s", $time, message); // Print info when condition is met
  endtask

endclass

`endif // TB_UTILS

// ------------------------------------------------------------
// Fully Synchronous SPI Slave (Mode 0)
// - ALL logic synchronous to clk
// - sclk/cs/mosi synchronized internally
// ------------------------------------------------------------

module spi_slave_gpio_regmap (
  input  logic       clk,
  input  logic       rst_n,

  // SPI
  input  logic       cs,       // active low
  input  logic       sclk,
  input  logic       mosi,
  output logic       miso,

  // GPIO
  input  logic [7:0] gpio_in,
  output logic [7:0] gpio_out
);

  // ==========================================================
  // Register Map
  // ==========================================================
  localparam byte ADDR_ID        = 8'h00;
  localparam byte ADDR_GPIO_IN   = 8'h01;
  localparam byte ADDR_GPIO_OUT  = 8'h02;

  localparam byte ID_VALUE       = 8'hA5;

  logic [7:0] regfile [0:255];
  assign gpio_out = regfile[ADDR_GPIO_OUT];

  // ==========================================================
  // Synchronizers (2-flop)
  // ==========================================================
  logic sclk_d1, sclk_d2;
  logic cs_d1,   cs_d2;
  logic mosi_d1, mosi_d2;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      sclk_d1 <= 0; sclk_d2 <= 0;
      cs_d1   <= 1; cs_d2   <= 1;
      mosi_d1 <= 0; mosi_d2 <= 0;
    end else begin
      sclk_d1 <= sclk;
      sclk_d2 <= sclk_d1;

      cs_d1   <= cs;
      cs_d2   <= cs_d1;

      mosi_d1 <= mosi;
      mosi_d2 <= mosi_d1;
    end
  end

  wire sclk_rise =  sclk_d1 & ~sclk_d2;
  wire sclk_fall = ~sclk_d1 &  sclk_d2;
  wire cs_active = ~cs_d2;

  // ==========================================================
  // SPI State
  // ==========================================================
  logic [2:0] bit_cnt;
  logic [1:0] byte_cnt;

  logic [7:0] shift_in;
  logic [7:0] shift_out;

  logic       rw;
  logic [7:0] addr;

  // ==========================================================
  // Register Read
  // ==========================================================
  function automatic logic [7:0] read_reg(input logic [7:0] a);
    case (a)
      ADDR_ID       : return ID_VALUE;
      ADDR_GPIO_IN  : return gpio_in;
      default       : return regfile[a];
    endcase
  endfunction

  // ==========================================================
  // MAIN SPI LOGIC (clk domain)
  // ==========================================================
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      bit_cnt   <= 0;
      byte_cnt  <= 0;
      shift_in  <= 0;
      shift_out <= 0;
      rw        <= 0;
      addr      <= 0;
      miso      <= 0;
	  // Initialize entire register file
      for (int i = 0; i < 256; i++) begin
        regfile[i] <= 8'h00;
      end
    end
    else begin

      // Reset transaction when CS goes high
      if (!cs_active) begin
        bit_cnt  <= 0;
        byte_cnt <= 0;
      end

      // ------------------------------------------------------
      // Sample MOSI on SCLK rising edge (Mode 0)
      // ------------------------------------------------------
      if (cs_active && sclk_rise) begin

        shift_in <= {shift_in[6:0], mosi_d2};

        if (bit_cnt == 3'd7) begin
          logic [7:0] full_byte;
          full_byte = {shift_in[6:0], mosi_d2};

          case (byte_cnt)

            2'd0: begin
              rw <= full_byte[0];
            end

            2'd1: begin
              addr <= full_byte;

              if (!rw)
                shift_out <= read_reg(full_byte);
            end

            2'd2: begin
              if (rw) begin
                if (addr != ADDR_ID && addr != ADDR_GPIO_IN)
                  regfile[addr] <= full_byte;
              end
            end

          endcase

          byte_cnt <= byte_cnt + 1;
          bit_cnt  <= 0;
        end
        else begin
          bit_cnt <= bit_cnt + 1;
        end
      end

      // ------------------------------------------------------
      // Shift out on SCLK falling edge
      // ------------------------------------------------------
      if (cs_active && sclk_fall) begin
        miso      <= shift_out[7];
        shift_out <= {shift_out[6:0], 1'b0};
      end

    end
  end

endmodule

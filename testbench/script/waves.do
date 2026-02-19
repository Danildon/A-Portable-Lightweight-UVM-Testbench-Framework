# ============================================================
# Clean Wave Window (ModelSim Lattice Compatible)
# ============================================================

quietly delete wave *

# ============================================================
# Add Top-Level TB Signals
# ============================================================

add wave -divider "=== TB CLOCK / RESET ==="
add wave sim:/tb_top/tb_clk
add wave sim:/tb_top/tb_rst

# ============================================================
# SPI Interface Signals
# ============================================================

add wave -divider "=== SPI IF ==="
add wave sim:/tb_top/spi_if/mosi
add wave sim:/tb_top/spi_if/miso
add wave sim:/tb_top/spi_if/sclk
add wave sim:/tb_top/spi_if/cs

# ============================================================
# GPIO Interface Signals
# ============================================================

add wave -divider "=== GPIO IF ==="
add wave sim:/tb_top/gpio_if/gpio_in
add wave sim:/tb_top/gpio_if/gpio_out

# ============================================================
# DUT Internal Signals (Optional but Useful)
# ============================================================

add wave -divider "=== DUT CORE ==="
add wave sim:/tb_top/DUT/shift_in
add wave sim:/tb_top/DUT/shift_out
add wave sim:/tb_top/DUT/bit_cnt
add wave sim:/tb_top/DUT/byte_cnt
add wave sim:/tb_top/DUT/rw
add wave sim:/tb_top/DUT/addr

# ============================================================
# Format Settings
# ============================================================

configure wave -signalnamewidth 1
configure wave -timelineunits ns

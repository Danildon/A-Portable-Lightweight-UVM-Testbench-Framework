# ============================================================
# ASSUMPTION:
#   Run from project root:
#       vsim> do testbench/script/compile.do
# ============================================================

echo "===================================================="
echo " Starting compilation..."
echo "===================================================="

# ============================================================
# CLEAN PREVIOUS BUILD
# ============================================================

if {[file exists work]} {
    vdel -lib work -all
}

if {[file exists uvm_pkg]} {
    vdel -lib uvm_pkg -all
}

vlib work
vlib uvm_pkg

vmap work work
vmap uvm_pkg uvm_pkg

# ============================================================
# UVM LOCATION (UPDATED PATH)
# ============================================================

set UVM_HOME "testbench/lib/1800.2-2020.3.1"
set GLOBAL_INCDIRS "+incdir+$UVM_HOME/src"

# ============================================================
# COMPILE OFFICIAL ACCELLERA UVM (NO DPI)
# ============================================================

vlog -sv \
    +define+UVM_NO_DPI \
    +define+UVM_NO_DEPRECATED \
    +define+UVM_HDL_NO_DPI \
    +define+UVM_OBJECT_DO_NOT_NEED_CONSTRUCTOR \
    $GLOBAL_INCDIRS \
    -work uvm_pkg \
    $UVM_HOME/src/uvm_pkg.sv

# ============================================================
# COMMON VLOG COMMANDS
# ============================================================

set VLOG_RTL "vlog -work work"
set VLOG_UVM "vlog -sv \
    +define+UVM_NO_DPI \
    +define+UVM_NO_DEPRECATED \
    +define+UVM_HDL_NO_DPI \
    +define+UVM_OBJECT_DO_NOT_NEED_CONSTRUCTOR \
    $GLOBAL_INCDIRS \
    -L uvm_pkg \
    -work work"

# ============================================================
# DUT
# ============================================================

eval $VLOG_RTL source/spi_slave_gpio_regmap.sv

# ============================================================
# TESTBENCH LIB FILES
# ============================================================

eval $VLOG_UVM testbench/lib/tb_cfg_pkg.sv
eval $VLOG_UVM testbench/lib/tb_utils.sv
eval $VLOG_UVM testbench/lib/tb_transactions.sv

# Interfaces
eval $VLOG_UVM testbench/lib/tb_spi_if.sv
eval $VLOG_UVM testbench/lib/tb_gpio_if.sv

# Low-level SPI driver / monitor
eval $VLOG_UVM testbench/lib/tb_spi_driver.sv
eval $VLOG_UVM testbench/lib/tb_spi_monitor.sv

# UVM components
eval $VLOG_UVM testbench/lib/tb_drivers.sv
eval $VLOG_UVM testbench/lib/tb_monitors.sv
eval $VLOG_UVM testbench/lib/tb_agents.sv
eval $VLOG_UVM testbench/lib/tb_scoreboards.sv
eval $VLOG_UVM testbench/lib/tb_env.sv
eval $VLOG_UVM testbench/lib/tb_generators.sv
eval $VLOG_UVM testbench/lib/tb_test.sv

# ============================================================
# TOP
# ============================================================

eval $VLOG_UVM testbench/top/tb_top.sv

echo "===================================================="
echo " Compilation completed successfully"
echo "===================================================="

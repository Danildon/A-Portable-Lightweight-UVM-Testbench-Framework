# ============================================================
# ASSUMPTION:
#   - Run from project root (above testbench/)
#   - compile.do has already been executed
# ============================================================

# ============================================================
# USER-CONFIGURABLE OPTIONS
# ============================================================
set TOP_MODULE      work.tb_top
set LIBS 			[list -L ovi_machxo3l -L ovi_ec -L ovi_ecp5u]
set UVM_TEST        stim_test
set STIM_FILE       "testbench/stimuli_files/_stimuli.txt"

# ============================================================
# OPTIONAL: CLEAR OLD SIM
# ============================================================
quit -sim

# ============================================================
# LAUNCH SIMULATION
# ============================================================
vsim -gui \
     {*}$LIBS \
     $TOP_MODULE \
     +UVM_TESTNAME=$UVM_TEST \
     +STIMULI_FILE=$STIM_FILE

# ============================================================
# BASIC UVM RUNTIME SETTINGS
# ============================================================
set NoQuitOnFinish 1
set StdArithNoWarnings 1
set NumericStdNoWarnings 1

# ============================================================
# LOGGING
# ============================================================
transcript on
log -r /*

# ============================================================
# OPTIONAL WAVES
# ============================================================
if {[file exists testbench/script/waves.do]} {
    do testbench/script/waves.do
} else {
    add wave -r /*
}

# ============================================================
# RUN
# ============================================================
run -all

echo "===================================================="
echo "  Simulation finished"
echo "===================================================="

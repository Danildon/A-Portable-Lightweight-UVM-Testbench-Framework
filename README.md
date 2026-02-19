# A-Portable-Lightweight-UVM-Testbench-Framework
This repository demonstrates a clean, lightweight, and portable UVM testbench architecture designed to run on free simulators such as ModelSim Lattice Edition. The goal is to show how to build a structured, scalable UVM environment without unnecessary complexity, DPI dependencies, or simulator-specific features.

This project demonstrates how to build a professional-grade UVM testbench that:

Avoids DPI dependencies
Uses the open-source UVM 1800.2-2020.3.1 library
Runs on free tools
Maintains strict separation of concerns
Supports file-driven stimulus
Remains scalable without unnecessary complexity
UVM Library

This project is based on:

Accellera UVM 1800.2-2020.3.1 - This is the official open-source implementation aligned with the IEEE 1800.2-2020 standard.

The environment is compiled with +define+UVM_NO_DPI This ensures compatibility with free simulators that do not support DPI-based UVM debug features.

No proprietary extensions are used.

Core Philosophy

1. UVM Should Be Practical

UVM is often perceived as heavy and overly abstract.

This project demonstrates that a UVM environment can be structured, readable, and lightweight without sacrificing correctness.

Every component exists for a reason.

2. Clean Layered Architecture

The environment enforces strict separation of responsibilities:

Layer	Responsibility
Sequence	Generates high-level intent
Driver	Converts transactions to pin behavior
Monitor	Observes real bus activity
Scoreboard	Validates observed behavior
Environment	Connects components and publishes config

There are no cross-layer shortcuts and no driver-dependent checking.

3. SPI Monitoring

The SPI monitor:

Observes real SPI pins
Reconstructs transactions from bus activity
This enforces verification independence and avoids race conditions.

4. File-Driven Stimulus Engine

The testbench includes a text-based stimulus format.

Example:
PAUSE US 10
SPI RD 0 0x00 SB_VERIFY
SPI WR 2 0xAA
GPIO gpio_in 0 SET 1 SB_BYPASS


Benefits:

No recompilation for new tests
Human-readable stimulus
Easy regression generation
CI-friendly
Extensible command format

5. Designed for Free Simulators

This project was intentionally developed and tested using ModelSim Lattice Edition and Open UVM 1800.2-2020.3.1

It avoids:

Questa-specific features
DPI-based debug infrastructure
Vendor-only libraries
The goal is full reproducibility without commercial tools.

6. Example DUT

The included SPI slave:

Is fully synchronous to clk
Uses 2-flop synchronizers for SPI inputs
Implements a 256-byte register map
Demonstrates clean reset initialization
It exists purely to demonstrate verification architecture.

Project Structure
rtl/
  spi_slave_gpio_regmap.sv

testbench/
  lib/
    tb_spi_if.sv
    tb_gpio_if.sv
    tb_transactions.sv
    tb_spi_driver.sv
    tb_spi_monitor.sv
    tb_drivers.sv
    tb_monitors.sv
    tb_agents.sv
    tb_env.sv
    tb_scoreboards.sv
    tb_generators.sv
    tb_cfg_pkg.sv
    tb_utils.sv
  top/
    tb_top.sv
  script/
    compile.do
    simulate.do
    waves.do

Simulation Flow

From project root:
do testbench/script/compile.do
do testbench/script/simulate.do

Design Goals:

Deterministic behavior
No hidden dependencies
Portable UVM usage
Minimal simulator assumptions
Clean debug visibility
Industry-relevant architecture
What This Project Demonstrates
Clean UVM agent structure
Proper monitoring
Portable open-source UVM usage
File-driven regression strategy
Scalable architecture without unnecessary abstraction
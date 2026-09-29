export SHELL=/bin/bash

# -----------------------------------------------------------------------------
# UVM adder testbench - Vivado xsim (same style as the team Makefile)
#
#   make run                      -> compile (first time) + run default test
#   make run TN=corner            -> factory-override corner test
#   make run TR=5                 -> run the sequence 5 times
#   make all TN=rand TR=3         -> clean + build + run
#   make all WIDTH=16             -> rebuild DUT + TB with 16-bit inputs
#   make clean
#
# NOTE: the snapshot is built only once. After editing any .sv/.svh file
#       (or changing WIDTH) use "make all" or "make clean" first.
# -----------------------------------------------------------------------------

TOP := add_uvm_tb

BUILD_DIR := $(CURDIR)/build
LOG_DIR := $(CURDIR)/log

WIDTH ?= 8

FILELIST += -d ADD_WIDTH=$(WIDTH)
FILELIST += -i $(CURDIR)/include
FILELIST += -i $(CURDIR)/package
FILELIST += -i $(CURDIR)/testbench
FILELIST += -i $(CURDIR)/deprecated
FILELIST += $(shell find $(CURDIR)/interface -mindepth 1 -maxdepth 1 -name "*.sv")
FILELIST += $(shell find $(CURDIR)/source    -mindepth 1 -maxdepth 1 -name "*.sv")
TB_FILES := $(shell find $(CURDIR)/testbench -mindepth 1 -maxdepth 1 -name "*.sv")
FILELIST += $(TB_FILES)

EW_O := | grep -iE "Error:|Warning:" --color=auto || true
EWHL := | grep -iE "Error:|Warning:|" --color=auto

$(BUILD_DIR) $(LOG_DIR):
	@echo -e "\033[1;33m>\033[0m Creating $@ directory..."
	@mkdir -p $@
	@echo "*" > $@/.gitignore

XVLOG ?= xvlog
XELAB ?= xelab
XSIM  ?= xsim

TN := default
TR := 1

$(BUILD_DIR)/snap_$(TOP):
	@make -s $(BUILD_DIR)
	@make -s $(LOG_DIR)
	@echo -e "\033[1;33m>\033[0m Compiling $(TOP) (WIDTH=$(WIDTH))..."
	@cd $(BUILD_DIR) && $(XVLOG) -sv $(FILELIST) -L uvm -log $(LOG_DIR)/xvlog_$(shell date +%Y%m%d_%H%M%S).log $(EW_O)
	@cd $(BUILD_DIR) && $(XELAB) $(TOP) -L uvm --timescale 1ns/1ps -s snap_$(TOP) -debug all -log $(LOG_DIR)/xelab_$(TOP)_$(shell date +%Y%m%d_%H%M%S).log $(EW_O)
	@echo "" > $(BUILD_DIR)/snap_$(TOP)

.PHONY: run
run:
	@make -s $(BUILD_DIR)/snap_$(TOP) WIDTH=$(WIDTH)
	@echo -e "\033[1;33m>\033[0m Running $(TOP)..."
	@echo "--testplusarg CLI_TEST_NAME=$(TN)" > $(BUILD_DIR)/xsim_args
	@echo "--testplusarg CLI_TEST_REPEATS=$(TR)" >> $(BUILD_DIR)/xsim_args
	@cd $(BUILD_DIR) && $(XSIM) snap_$(TOP) -f xsim_args -runall -log $(LOG_DIR)/xsim_$(TOP)_$(shell date +%Y%m%d_%H%M%S).log $(EWHL)

.PHONY: all
all:
	@make -s clean
	@make -s run TOP=$(TOP) TN=$(TN) TR=$(TR) WIDTH=$(WIDTH)

.PHONY: clean
clean:
	@echo -e "\033[1;33m>\033[0m Cleaning $(BUILD_DIR) and $(LOG_DIR) directories."
	@rm -rf $(BUILD_DIR) $(LOG_DIR)

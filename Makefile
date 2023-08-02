# See LICENSE.txt for license details.
CXX=$(CUSTOM_CC)

CXX_FLAGS += -std=c++11 -O2 -Wall -fno-inline -fxray-instrument
PAR_FLAG = -fopenmp=libomp

ifneq (,$(findstring icpc,$(CXX)))
	PAR_FLAG = -openmp
endif

ifneq (,$(findstring sunCC,$(CXX)))
	CXX_FLAGS = -std=c++11 -xO3 -m64 -xtarget=native
	PAR_FLAG = -xopenmp
endif

ifneq ($(SERIAL), 1)
	CXX_FLAGS += $(PAR_FLAG)
endif

KERNELS = bc bfs cc cc_sv pr pr_spmv sssp tc
SUITE = $(KERNELS) converter

.PHONY: all
all: $(SUITE)

% : src/%_linked.ll
	cd $*; $(CXX) -L/usr/lib/llvm-15/lib/ $(CXX_FLAGS) ../$< -o $@

src/%_linked.ll : src/%_optimized.ll $(ZRAY_BIN_PATH)/tool_dyn.ll
	$(CUSTOM_LINK) $^ -S -o $@

src/%_optimized.ll : src/%.ll
	mkdir $*
	cd $*; $(CUSTOM_OPT) -enable-new-pm=0 -O2 -mem2reg -load $(ZRAY_BIN_PATH)/tool.so -tool_pass ../$< -o ../$@

src/%.ll : src/%.cc src/*.h
	$(CXX) $(CXX_FLAGS) -S -emit-llvm $< -o $@

# Testing
include test/test.mk

# Benchmark Automation
include benchmark/bench.mk


.PHONY: clean
clean:
	rm -rf $(SUITE) test/out/* src/*.ll

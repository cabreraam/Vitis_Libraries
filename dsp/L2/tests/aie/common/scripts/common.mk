###############################################################################
#  Common Makefile used for AIE DSPLIB fir functions compilation, simulation and QoR harvest.
# Function-specific parameters and rules are overriden in tests/<func>/proj/Makefile
###############################################################################

#TODO: Add error handling/messages when we don't find files or environment variables aren't set.

# UUT
UUT_KERNEL         = default
UUT_GRAPH          = $(UUT_KERNEL)_graph
# Test parameters
DATA_TYPE          = cint16
COEFF_TYPE         = int16
FIR_LEN            = 81
SHIFT              = 16
ROUND_MODE         = 0
INPUT_WINDOW_VSIZE = 512
CASC_LEN           = 1
DUAL_IP            = 0
USE_COEFF_RELOAD   = 0
SYMMETRY_FACTOR    = 1
INTERPOLATE_FACTOR = 1
DECIMATE_FACTOR    = 1
NUM_OUTPUTS        = 1
DIFF_TOLERANCE     = 0.0025
INPUT_FILE         = data/input.txt
COEFF_FILE         = data/coeff.txt
UUT_TARGET=hw

REPO_TYPE 		   = SRC
# specify where DSPLIB is coming from (output of tarball or direct source)
ifeq ($(REPO_TYPE), SRC)
	DSPLIB_REPO 	  := $(DSPLIB_ROOT)
else ifeq ($(REPO_TYPE), CUSTOMER)
	DSPLIB_REPO 	  := $(DSPLIB_ROOT)/output/customer
else ifeq ($(REPO_TYPE), INTERNAL)
	DSPLIB_REPO 	  := $(DSPLIB_ROOT)/output/internal
else ifeq ($(REPO_TYPE), PATH)
	DSPLIB_REPO 	  := $(DSPLIB_REPO_PATH)
else
	DSPLIB_REPO 	  := $(DSPLIB_ROOT)
endif
# by default we won't create a new tarball and will assume output dir exists
MAKE_ARCHIVE = false
# by default we generate input stimulus. Set to false to use user specific.
GEN_INPUT_DATA = true
# by default we generate coeff stimulus. Set to false to use user specific.
GEN_COEFF_DATA = true

# def seed
DATA_SEED           = 1
DATA_STIM_TYPE      = 0
#  INCONES   = 5;#  ALLONES   = 4;#  IMPULSE   = 3;#  FROM_FILE = 1;  RANDOM    = 0;
STIM_TYPE           = 0
ifeq ($(GEN_COEFF_DATA), true)
	COEFF_STIM_TYPE 	= $(STIM_TYPE)
else
	COEFF_STIM_TYPE 	= 1
endif

# Test config
KERNEL_HDR         := $(DSPLIB_REPO)/L1/include/hw
KERNEL_SRC         := $(DSPLIB_REPO)/L1/src/hw
TEST_HDR           := $(DSPLIB_REPO)/L1/tests/inc
TEST_SRC           := $(DSPLIB_REPO)/L1/tests/src
GRAPH_SRC          := $(DSPLIB_REPO)/L2/include/hw
GRAPH_TEST_SRC     := $(DSPLIB_REPO)/L2/tests/inc
AIE_APIE_SRC       := ./
# AIE_APIE_SRC       := $(DSPLIB_REPO)/L1/include/aie_api/include
NUM_SEC            := 1
USING_UUT_YES      := 1

NITER 			   = 16
NITER_UUT          = $(NITER)
NITER_REF          = $$(( $(NITER_UUT) / 2))


LOCK_FILE          = .lock
# Local files, read at simulation. Copy of user passed input file or randomly generated data.
LOC_INPUT_FILE     = data/input.txt
LOC_COEFF_FILE     = data/coeff.txt

REF_KERNEL         = $(UUT_KERNEL)_ref
REF_GRAPH          = $(REF_KERNEL)_graph
REF_INPUT_WINDOW_VSIZE   = $$(( $(INPUT_WINDOW_VSIZE) * $(NITER_UUT) / $(NITER_REF)))

# Set to 1 to enable AIE API aka High Level Intrinsics
USE_AIE_API	   = 1

USE_CHAIN	   = 0

# Parameters that are passed to UUT/REF as PREPROC_ARGS
UUT_PARAM_LIST = \
    DATA_TYPE \
    COEFF_TYPE \
    FIR_LEN \
    SHIFT \
    ROUND_MODE \
    INTERPOLATE_FACTOR \
    DECIMATE_FACTOR \
    INPUT_WINDOW_VSIZE \
    CASC_LEN \
    DUAL_IP \
    USE_COEFF_RELOAD \
    NUM_OUTPUTS \
    USE_AIE_API

# These are params that aren't passed to the UUT, but we do want to have a unique test folder dir for.
MAKE_PARAM_LIST = \
    UUT_TARGET \
    DATA_STIM_TYPE \
    COEFF_STIM_TYPE \
    USE_CHAIN \
    REPO_TYPE

# UUT_PARAMS_CONCAT =
# $(foreach param, $(UUT_PARAM_LIST), $(eval UUT_PARAMS_CONCAT = $(UUT_PARAMS_CONCAT)_$($(param))))
# PREPROC_ARGS =
# $(foreach param, $(UUT_PARAM_LIST), $(eval PREPROC_ARGS = $(PREPROC_ARGS)-D$(param)=$($(param)) ))
# # Actual args don't match the makefile names
# $(eval PREPROC_ARGS := $(PREPROC_ARGS)-DSTIM_TYPE=$(COEFF_STIM_TYPE) )
# PREPROC_ARGS += -DSTIM_TYPE=$(COEFF_STIM_TYPE)
# PREPROC_ARGS += -DINPUT_FILE=$(LOC_INPUT_FILE)
# PREPROC_ARGS += -DCOEFF_FILE=$(LOC_COEFF_FILE)
# MAKE_PARAMS_CONCAT =
# $(foreach param, $(MAKE_PARAM_LIST), $(eval MAKE_PARAMS_CONCAT = $(MAKE_PARAMS_CONCAT)_$($(param))))

UUT_PARAMS_CONCAT  =$(DATA_TYPE)_$(COEFF_TYPE)_$(FIR_LEN)_$(SHIFT)_$(ROUND_MODE)_$(INTERPOLATE_FACTOR)_$(DECIMATE_FACTOR)_$(INPUT_WINDOW_VSIZE)_$(CASC_LEN)_$(DUAL_IP)_$(USE_COEFF_RELOAD)_$(NUM_OUTPUTS)_$(USE_AIE_API)

MAKE_PARAMS_CONCAT  =$(UUT_TARGET)_$(DATA_STIM_TYPE)_$(COEFF_STIM_TYPE)_$(USE_CHAIN)_$(REPO_TYPE)

PREPROC_ARGS =
PREPROC_ARGS += -DDATA_TYPE=$(DATA_TYPE)
PREPROC_ARGS += -DCOEFF_TYPE=$(COEFF_TYPE)
PREPROC_ARGS += -DFIR_LEN=$(FIR_LEN)
PREPROC_ARGS += -DSHIFT=$(SHIFT)
PREPROC_ARGS += -DROUND_MODE=$(ROUND_MODE)
PREPROC_ARGS += -DINTERPOLATE_FACTOR=$(INTERPOLATE_FACTOR)
PREPROC_ARGS += -DDECIMATE_FACTOR=$(DECIMATE_FACTOR)
PREPROC_ARGS += -DCASC_LEN=$(CASC_LEN)
PREPROC_ARGS += -DDUAL_IP=$(DUAL_IP)
PREPROC_ARGS += -DUSE_COEFF_RELOAD=$(USE_COEFF_RELOAD)
PREPROC_ARGS += -DNUM_OUTPUTS=$(NUM_OUTPUTS)
PREPROC_ARGS += -DUSE_AIE_A=$(USE_AIE_API)
PREPROC_ARGS += -DSTIM_TYPE=$(COEFF_STIM_TYPE)
PREPROC_ARGS += -DINPUT_FILE=$(LOC_INPUT_FILE)
PREPROC_ARGS += -DCOEFF_FILE=$(LOC_COEFF_FILE)

TEST_PARAMS_CONCAT  = $(UUT_PARAMS_CONCAT)_$(MAKE_PARAMS_CONCAT)
UUT_FILE_SUFFIX     = $(UUT_GRAPH)_$(TEST_PARAMS_CONCAT)
REF_FILE_SUFFIX     = $(REF_GRAPH)_$(TEST_PARAMS_CONCAT)

REF_PREPROC_ARGS   = "-DUUT_GRAPH=$(REF_GRAPH) -DOUTPUT_FILE=$(REF_SIM_FILE) -DOUTPUT_FILE2=$(REF_SIM_FILE2) $(PREPROC_ARGS)  -DINPUT_WINDOW_VSIZE=$(REF_INPUT_WINDOW_VSIZE) -DNITER=$(NITER_REF)"
UUT_PREPROC_ARGS   = "-DUUT_GRAPH=$(UUT_GRAPH) -DOUTPUT_FILE=$(UUT_SIM_FILE) -DOUTPUT_FILE2=$(UUT_SIM_FILE2) $(PREPROC_ARGS)  -DINPUT_WINDOW_VSIZE=$(INPUT_WINDOW_VSIZE) -DNITER=$(NITER_UUT) -DUSING_UUT=$(USING_UUT_YES)"

ifeq ($(COEFF_TYPE), cint32)
	COEFF_SIZE 	  := 8
else ifeq ($(COEFF_TYPE), cfloat)
	COEFF_SIZE 	  := 8
else ifeq ($(COEFF_TYPE), cint16)
	COEFF_SIZE 	  := 4
else ifeq ($(COEFF_TYPE), int32)
	COEFF_SIZE 	  := 4
else ifeq ($(COEFF_TYPE), float)
	COEFF_SIZE 	  := 4
else
	COEFF_SIZE 	  := 2
endif

HEAPSIZE_VAL       = $$(( $(INTERPOLATE_FACTOR) * $(FIR_LEN) * $(COEFF_SIZE) * 2  +  1536))
STACKSIZE_VAL      = $$(( $(INTERPOLATE_FACTOR) * $(FIR_LEN) * $(COEFF_SIZE) + 1536))

# Env config
STATUS_LOG_FILE    = ./logs/status_$(UUT_FILE_SUFFIX).txt
# redundant
STATUS_FILE        = $(STATUS_LOG_FILE)
DIFF_OUT_FILE      = diff_output.txt
UUT_DATA_FILE      = ./data/uut_out_$(UUT_FILE_SUFFIX).txt
REF_DATA_FILE      = ./data/ref_out_$(REF_FILE_SUFFIX).txt
TMP_UUT_FILE       = tmp_uut.txt
TMP_REF_FILE       = tmp_ref.txt
UUT_OUT_DIR        = ./aiesimulator_output
REF_OUT_DIR        = ./aiesimulator_ref_output
REF_OUT_DIR_X86    = ./x86simulator_ref_output
UUT_SIM_FILE       = data/uut_output.txt
REF_SIM_FILE       = data/ref_output.txt
UUT_OUT_FILE       = $(UUT_OUT_DIR)/$(UUT_SIM_FILE)
REF_OUT_FILE       = $(REF_OUT_DIR_X86)/$(REF_SIM_FILE)

REF_OUT_FILE2      = $(REF_OUT_DIR_X86)/$(REF_SIM_FILE2)
UUT_DATA_FILE2     = ./data/uut_out_$(UUT_FILE_SUFFIX)_2.txt
REF_DATA_FILE2     = ./data/ref_out_$(REF_FILE_SUFFIX)_2.txt
UUT_SIM_FILE2      = data/uut_output_2.txt
REF_SIM_FILE2       = data/ref_output_2.txt
UUT_OUT_FILE2      = $(UUT_OUT_DIR)/$(UUT_SIM_FILE2)

# TODO: Make this smarter
ifeq ($(CASC_LEN), 1)
	DEVICE_FILE    = 4x4
else
	DEVICE_FILE    = VC1902
endif

TEST_BENCH         = test.cpp
WORK_DIR           = Work
REF_WORK_DIR       = Work_ref
LOG_FILE           = ./logs/log_$(UUT_FILE_SUFFIX).txt
REF_LOG_FILE       = ./logs/ref_log_$(REF_FILE_SUFFIX).txt
PSLINKER_ARGS      = "-L xxx"
OTHER_OPTS         = --pl-freq=1000
SIM_OPTS           = --profile
SIM_OPTS_X86       =
PHRASE_1           = 'COMPILE.*_SUCCESS'
PHRASE_2           = 'SIM.*_SUCCESS'
PHRASE_3           = identical

GET_STATS 	:= false
# remove _FOR_RELEASE_ for the release
#ifdef _DUMMY_PREPROC_DIRECTIVE_FOR_SCRIPT_STRIPPING_DE_FOR_RELEASE_BUG_
GET_STATS 	:= true

DUMP_VCD	   = 0
ifeq ($(DUMP_VCD), 1)
	SIM_OPTS += --dump-vcd $(UUT_KERNEL)_sim
endif

DEBUG_ADL	   = 0
ifeq ($(DEBUG_ADL), 1)
	PREPROC_ARGS += -D_DSPLIB_FIR_DEBUG_ADL_=1
endif

# If debug_coeff_seed is passed, overwrite the default.
ifneq ($(DEBUG_COEFF_SEED),)
	PREPROC_ARGS += -DCOEFF_SEED=$(DEBUG_COEFF_SEED)
endif

# Use aie api (aka HLI - High Level Intrinsic)
ifeq ($(USE_AIE_API), 0)
	PREPROC_ARGS += -D_DSPLIB_FIR_AIE_LLI_API_DEBUG_=1
endif

#endif //_DUMMY_PREPROC_DIRECTIVE_FOR_SCRIPT_STRIPPING_DE_FOR_RELEASE_BUG_

ifeq ($(USE_CHAIN), 1)
	PREPROC_ARGS += -DUSE_CHAIN=1
endif

PRGMEM_AWK_POS    := 1
ifeq ($(CASC_LEN), 1)
	PRGMEM_AWK_POS    := 1
else
	PRGMEM_AWK_POS    := 2
endif

# Target specific compile args
ifeq ($(UUT_TARGET), hw)
	UUT_TARGET_COMPILE_ARGS:=  -stacksize=$(STACKSIZE_VAL) -Xchess=llvm.xargs="-std=c++2a" -Xchess=main:backend.mist2.xargs="+NOdra" --xlopt=1 -Xchess=main:noodle.optim.olbb=20 -Xchess=main:backend.mist2.pnll="off"
	SIM_EXEC=aiesimulator
else ifeq ($(UUT_TARGET), x86sim)
	UUT_TARGET_COMPILE_ARGS:= -Xchess=main:llvm.xargs=-g
	SIM_EXEC=x86simulator
	SIM_OPTS= -o=$(UUT_OUT_DIR)
	GET_STATS 	:= false
endif


PATHTOSCRIPTS     := $(DSPLIB_ROOT)/../../test/
#test is <workspace>/CARDANO_ROOT/test. TODO: figure out where this will be for release (internal release).

#This allows a completely seperate run directory. This location can be overridden from command-line.
# /proj/ipeng_scratch/user
RESULTS_PATH = ./results
# Unique results dir for each test
RESULTS_DIR = $(RESULTS_PATH)/results_$(UUT_FILE_SUFFIX)
RESULTS_BACKUP_DIR = $(RESULTS_DIR)
# File size analysis shows that chesswork/* and sim.out are biggest contributors to results size.
# We also don't want to copy current results, for obvious reasons.
EXCLUDE_COPY = '*chesswork*' '*sim.out' './*results*' '.Xil' '*.pch'
INCLUDE_COPY =
# This gets put in-line with the find command followed by -prune -o <other args> -print
# Essentially, this is the find args to find files that we DON'T want to include in the main find.
# We use it to not include other batch test config results.
PRUNE_COPY = -ipath '*$(UUT_GRAPH)*' -not -ipath '*$(TEST_PARAMS_CONCAT)*'

# Legacy
all_c        : create compile_ref sim_ref create_input compile slp sim check_op_ref get_status_ref summary
# Ref run & UUT run
all 		 : create_r recurse

ref 		 : create_r recurse_ref
uut   		 : create_r recurse_uut
all_r        : clean create create_input compile_ref sim_ref compile slp sim check_op_ref get_status_ref clean_result summary

ref_r        : clean create create_input compile_ref sim_ref
uut_r        : clean create create_input compile sim
# Deb
all_deb      : clean create create_input

# This passes current environment (including args from commands line) to sub-make
recurse :
	@echo starting make in $(RESULTS_DIR) at `date "+%s"`
	$(MAKE) -C $(RESULTS_DIR) all_r
	@echo finished make in $(RESULTS_DIR) at `date "+%s"`

recurse_ref :
	@echo starting make in $(RESULTS_DIR) at `date "+%s"`
	$(MAKE) -C $(RESULTS_DIR) ref_r
	@echo finished make in $(RESULTS_DIR) at `date "+%s"`

recurse_uut :
	@echo starting make in $(RESULTS_DIR) at `date "+%s"`
	$(MAKE) -C $(RESULTS_DIR) uut_r
	@echo finished make in $(RESULTS_DIR) at `date "+%s"`

## cp_result is now deprecated because testcases are now ran inside results directory
#https://unix.stackexchange.com/a/311983/346866
# TODO: rsync -armR --include="*/" --include="*.csv" --exclude="*" /full/path/to/source/file(s) destination/
# TODO: tee into logs
# TODO: deal with overwrite appropriately (have a force overwrite argument)
# TODO: Add gunzip to results dir (that can be disabled with param)
# TODO: utilise clean step to remove a pre-existing RESULTS_BACKUP_DIR (possibly with force overwrite)
cp_result:
	$(info $(shell mkdir -p $(RESULTS_BACKUP_DIR)))
	$(shell find . \
	$(PRUNE_COPY) -prune -o \
	$(foreach exclusion, $(EXCLUDE_COPY), -not -ipath $(exclusion) ) \
	$(foreach inclusion, $(INCLUDE_COPY), -ipath $(inclusion) ) \
	-print \
	| xargs cp --parents -t ./$(RESULTS_BACKUP_DIR))
	@echo 'done copying'

# remove the sorts of files that we previously excluded from results copy due to disk usage bloat
# we don't need to do any fancy pruning because each testcase shouldn't have any other testcases in there.
#  the word words stuff is just to add an extra -ipath to the end so that we can use the -o notation to apply multiple filters
clean_result:
	$(info $(shell find . \
	\( $(foreach exclusion, $(EXCLUDE_COPY), -ipath $(exclusion) -o ) -ipath $(word $(words $(EXCLUDE_COPY)),$(EXCLUDE_COPY)) \) \
	-print -exec rm -rf {} + ))
	@echo 'done cleaning'

# TODO: Just foreach loop across test param list

create_r:
	@rm -rf $(RESULTS_DIR)
	@mkdir -p $(RESULTS_DIR)/logs $(RESULTS_DIR)/data $(RESULTS_DIR)/data
	@cp -f $(TEST_BENCH) $(RESULTS_DIR)
	@cp -f test.hpp $(RESULTS_DIR)
	@cp -f uut_config.h $(RESULTS_DIR)
	@cp -f Makefile $(RESULTS_DIR)
	@if [ $(GEN_INPUT_DATA) = false ]; then \
		cp -f $(INPUT_FILE) $(RESULTS_DIR)/$(LOC_INPUT_FILE) ;\
	fi
	@if [ $(COEFF_STIM_TYPE) = 1 ]; then \
		cp -f $(COEFF_FILE) $(RESULTS_DIR)/$(LOC_COEFF_FILE) ;\
	fi

create:
	@echo Start testing|& tee $(LOG_FILE);\
	 echo Input args are: |& tee -a $(LOG_FILE);\
	 echo $(MAKEFLAGS) |& tee -a $(LOG_FILE);\
	 echo $(CURDIR) |& tee -a $(LOG_FILE);\
	 echo diff result > $(DIFF_OUT_FILE);\
	 echo "Configuration:"                                   > $(STATUS_FILE); \
	 echo "    UUT_KERNEL: " $(UUT_KERNEL)         >> $(STATUS_FILE); \
	 printf " $(foreach param, $(UUT_PARAM_LIST), \
		$(shell echo "  $(param): $($(param)) \\n"))" >> $(STATUS_FILE); \
	 echo "Results:"                                         >> $(STATUS_FILE)

create_input:
	@if [ $(GEN_INPUT_DATA) = true ]; then \
		tclsh $(DSPLIB_REPO)/L2/scripts/gen_input.tcl $(LOC_INPUT_FILE) $(INPUT_WINDOW_VSIZE) $(NITER_UUT) $(DATA_SEED) $(DATA_STIM_TYPE);\
	fi
	@echo Input ready;\
	rm -f $(LOCK_FILE)
	@if [ $(MAKE_ARCHIVE) = true ]; then \
		echo Creating DSPLIB archive |& tee -a $(LOG_FILE) ;\
		$(DSPLIB_ROOT)/internal/scripts/create_dsplib_zip.pl |& tee -a $(LOG_FILE) ;\
	fi

compile_ref:
	@echo COMPILE_REF_START |& tee -a $(REF_LOG_FILE);\
	date +%s |& tee -a $(REF_LOG_FILE);\
	date |& tee -a $(REF_LOG_FILE)
	@set -o pipefail; \
	aiecompiler --target x86sim --dataflow -v --use-phy-shim=false -include=$(KERNEL_HDR) -include=$(KERNEL_SRC) -include=$(TEST_HDR) -include=$(TEST_SRC) -include=$(GRAPH_SRC) -include=$(GRAPH_TEST_SRC) $(TEST_BENCH) $(OTHER_OPTS) --device=$(DEVICE_FILE) --test-iterations=$(NITER_REF) -workdir=$(REF_WORK_DIR) -Xpreproc=$(REF_PREPROC_ARGS)|& tee -a $(REF_LOG_FILE);\
	echo $$? > compile_ref_exit; \
	if [ `cat compile_ref_exit` -ne 0 ]; then \
		echo COMPILE_REF_FAILED. ERR_CODE: `cat compile_ref_exit` |& tee -a $(REF_LOG_FILE); \
	else \
		echo COMPILE_REF_SUCCESS |& tee -a $(REF_LOG_FILE); \
	fi ;\
	echo COMPILE_REF_END |& tee -a $(REF_LOG_FILE);\
	date +%s |& tee -a $(REF_LOG_FILE)

sim_ref:
	@echo REF_SIM_START |& tee -a $(REF_LOG_FILE);\
	date +%s |& tee -a $(REF_LOG_FILE);\
	if [ `cat compile_ref_exit` -ne 0 ]; then \
		echo SKIPPING REF_SIMULATION DUE TO COMPILE_REF FAILURE |& tee -a $(LOG_FILE); \
	else \
		set -o pipefail; \
		x86simulator --pkg-dir=$(REF_WORK_DIR) -o=$(REF_OUT_DIR_X86) $(SIM_OPTS_X86) |& tee -a $(REF_LOG_FILE);\
		echo $$? > sim_ref_exit; \
		if [ `cat sim_ref_exit` -ne 0 ]; then \
			echo SIM_REF_FAILED. ERR_CODE: `cat sim_ref_exit` |& tee -a $(REF_LOG_FILE); \
		else \
			echo SIM_REF_SUCCESS |& tee -a $(REF_LOG_FILE); \
		fi ;\
	fi
	@echo REF_SIM_END |& tee -a $(REF_LOG_FILE);\
	date +%s |& tee -a $(REF_LOG_FILE)

#set -o pipefail allows us to catch the error signal from any piped error command
# usually you would use set +o pipefail to reverse this for subsequent commmands,
# but Makefile has every distinct command in a new shell, so it doesn't matter.
compile:
	@echo COMPILE_START |& tee -a $(LOG_FILE);\
	date +%s |& tee -a $(LOG_FILE);\
	date |& tee -a $(LOG_FILE);\
	set -o pipefail; \
	aiecompiler --target $(UUT_TARGET) $(UUT_TARGET_COMPILE_ARGS) --dataflow -v --use-phy-shim=false -include=$(KERNEL_HDR) -include=$(KERNEL_SRC) -include=$(TEST_HDR) -include=$(TEST_SRC) -include=$(GRAPH_SRC) -include=$(GRAPH_TEST_SRC) -include=$(AIE_APIE_SRC) $(TEST_BENCH) $(OTHER_OPTS) --device=$(DEVICE_FILE) --test-iterations=$(NITER_UUT) -workdir=$(WORK_DIR) -Xpreproc=$(UUT_PREPROC_ARGS)|& tee -a $(LOG_FILE);\
	echo $$? > compile_exit; \
	if [ `cat compile_exit` -ne 0 ]; then \
		echo COMPILE_FAILED. ERR_CODE: `cat compile_exit`  |& tee -a $(LOG_FILE); \
	else \
		echo COMPILE_SUCCESS |& tee -a $(LOG_FILE); \
	fi
	@echo COMPILE_END |& tee -a $(LOG_FILE);\
	date +%s |& tee -a $(LOG_FILE)


sim:
	@echo SIM_START |& tee -a $(LOG_FILE);\
	date +%s |& tee -a $(LOG_FILE);\
	if [ `cat compile_exit` -ne 0 ]; then \
		echo SKIPPING SIMULATION DUE TO COMPILE FAILURE `cat compile_exit` |& tee -a $(LOG_FILE); \
	else \
		set -o pipefail; \
		$(SIM_EXEC) --pkg-dir=$(WORK_DIR) $(SIM_OPTS) |& tee -a $(LOG_FILE);\
		echo $$? > sim_exit; \
		if [ `cat sim_exit` -ne 0 ]; then \
			echo SIM_FAILED. ERR_CODE: `cat sim_exit` |& tee -a $(LOG_FILE); \
		else \
			echo SIM_SUCCESS |& tee -a $(LOG_FILE); \
		fi ;\
	fi
	@echo SIM_END |& tee -a $(LOG_FILE);\
	date +%s |& tee -a $(LOG_FILE)
slp:
	@echo sleep for $(NUM_SEC) |& tee -a $(LOG_FILE);\
	sleep $(NUM_SEC)

check_op_ref:
	@grep -ve '[XT]' $(UUT_OUT_FILE) > $(UUT_DATA_FILE);\
	grep -ve '[XT]' $(REF_OUT_FILE) > $(REF_DATA_FILE);\
	echo "DIFF_START" >> $(LOG_FILE)
	tclsh $(DSPLIB_REPO)/L2/scripts/diff.tcl $(UUT_DATA_FILE) $(REF_DATA_FILE) $(DIFF_OUT_FILE)  $(DIFF_TOLERANCE) >> $(LOG_FILE)
	echo "DIFF_END" >> $(LOG_FILE)
ifeq ($(NUM_OUTPUTS), 2)
	@grep -ve '[XT]' $(UUT_OUT_FILE2) > $(UUT_DATA_FILE2);\
	grep -ve '[XT]' $(REF_OUT_FILE2) > $(REF_DATA_FILE2);\
	echo "DIFF_START" >> $(LOG_FILE)
	tclsh $(DSPLIB_REPO)/L2/scripts/diff.tcl $(UUT_DATA_FILE2) $(REF_DATA_FILE2) $(DIFF_OUT_FILE)  $(DIFF_TOLERANCE) >> $(LOG_FILE)
	echo "DIFF_END" >> $(LOG_FILE)
endif

get_status_ref:
	@grepres1=`grep  $(PHRASE_1) -c $(LOG_FILE)`;\
	 echo "    COMPILE:" $$grepres1 >>$(STATUS_FILE)
	@grepres2=`grep  $(PHRASE_2) -c $(LOG_FILE)`;\
	 echo "    SIM:" $$grepres2 >>$(STATUS_FILE)
	@grepres3=`grep  $(PHRASE_1) -c $(REF_LOG_FILE)`;\
	 echo "    COMPILE_REF:" $$grepres3 >>$(STATUS_FILE)
	@grepres4=`grep  $(PHRASE_2) -c $(REF_LOG_FILE)`;\
	 echo "    SIM_REF:" $$grepres4 >>$(STATUS_FILE)
	@grepres5=`grep  $(PHRASE_3) -c $(DIFF_OUT_FILE)`;\
	 echo "    FUNC:" $$grepres5 >>$(STATUS_FILE);\
	nl=`wc -l '$(REF_DATA_FILE)' | grep -Eo '[0-9]+' |head -1`;\
	echo "    NUM_REF_OUTPUTS:" $$nl >>$(STATUS_FILE);\
	nl=`wc -l '$(UUT_DATA_FILE)' | grep -Eo '[0-9]+' |head -1`;\
	echo "    NUM_UUT_OUTPUTS:" $$nl >>$(STATUS_FILE);\
	t0=`grep COMPILE_REF_START -A 1 $(REF_LOG_FILE)|tail -n 1`;\
	t1=`grep COMPILE_REF_END -A 1 $(REF_LOG_FILE)|tail -n 1`;\
	td=`echo $$t1 - $$t0 |bc`;\
	echo "    COMPILE_REF_TIME:" $$td >>$(STATUS_FILE);\
	t0=`grep REF_SIM_START -A 1 $(REF_LOG_FILE)|tail -n 1`;\
	t1=`grep REF_SIM_END -A 1 $(REF_LOG_FILE)|tail -n 1`;\
	td=`echo $$t1 - $$t0 |bc`;\
	echo "    REF_SIM_TIME:" $$td >>$(STATUS_FILE);\
	t0=`grep COMPILE_START -A 1 $(LOG_FILE)|tail -n 1`;\
	t1=`grep COMPILE_END -A 1 $(LOG_FILE)|tail -n 1`;\
	td=`echo $$t1 - $$t0 |bc`;\
	echo "    COMPILE_TIME:" $$td >>$(STATUS_FILE);\
	t0=`grep SIM_START -A 1 $(LOG_FILE)|tail -n 1`;\
	t1=`grep SIM_END -A 1 $(LOG_FILE)|tail -n 1`;\
	td=`echo $$t1 - $$t0 |bc`;\
	echo "    SIM_TIME:" $$td >>$(STATUS_FILE);\
	archs=`grep ARCHS $(LOG_FILE)| tail -n 1`;\
	echo "   " $$archs >> $(STATUS_FILE);\
	if [ $(GET_STATS) = true -a `cat compile_exit` -eq 0 ] ; then \
		tclsh $(DSPLIB_REPO)/L2/scripts/get_stats.tcl $(DATA_TYPE) $(COEFF_TYPE) $(FIR_LEN) $(INPUT_WINDOW_VSIZE) $(CASC_LEN) $(INTERPOLATE_FACTOR) $(DECIMATE_FACTOR) $(SYMMETRY_FACTOR) $(DUAL_IP) $(USE_COEFF_RELOAD) $(NUM_OUTPUTS) $(STATUS_FILE) $(UUT_OUT_DIR) "filter" $(NITER_UUT);\
		echo -n "    NUM_BANKS: "                                       >> $(STATUS_FILE);\
		$(PATHTOSCRIPTS)/get_num_banks.sh $(WORK_DIR) dummy             >> $(STATUS_FILE) ;\
		echo -n "    NUM_ME: "                                          >> $(STATUS_FILE);\
		$(PATHTOSCRIPTS)/get_num_me.sh $(WORK_DIR) 1                    >> $(STATUS_FILE) ;\
		echo -n "    DATA_MEMORY: "                                     >> $(STATUS_FILE);\
		$(PATHTOSCRIPTS)/get_data_memory.sh $(WORK_DIR) dummy           >> $(STATUS_FILE);\
		echo -n "    PROGRAM_MEMORY: "                                  >> $(STATUS_FILE);\
		max_prgmem=`ls $(WORK_DIR)/aie/*_*/Release/*_*.map|xargs grep -A 10 "Section summary for memory 'PM':"|grep "Total"| awk '{print $$($(PRGMEM_AWK_POS))}'`;\
		echo $$max_prgmem                                               >> $(STATUS_FILE);\
	fi
	cp $(STATUS_FILE) $(STATUS_LOG_FILE)  ;\
	echo test_complete > $(LOCK_FILE)


summary:
	cat $(STATUS_FILE)

.PHONY: clean
clean:
	@rm -rf aiesimulator_output ;\
	rm -rf .Xil;\
	rm -rf xnwOut;\
	rm -rf $(LOG_FILE) $(REF_LOG_FILE);\
	rm -rf  $(TMP_REF_FILE) $(TMP_UUT_FILE) $(STATUS_FILE) $(DIFF_OUT_FILE) aiesimulator.log;\
	rm -f -R $(WORK_DIR) $(UUT_OUT_DIR);\
	rm -f -R $(REF_WORK_DIR) $(REF_OUT_DIR) $(REF_OUT_DIR_X86);\
	rm -f *_exit


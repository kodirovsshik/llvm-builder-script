define(opt_all,option(COMMON,$1))dnl
define(option,override CMAKE_OPTS_$1 := $(CMAKE_OPTS_$1) "-D$2")dnl
define(opt,option(STAGE$1,$2))dnl
define(opt_rt,opt(_rt,$1))dnl
define(sub,$(MAKE) $1)dnl
define(define_stage,
override STAGE$1_BUILD_DIR := $(REPO_DIR)/build_stage$1
override STAGE$1_SRC_DIR := $(REPO_DIR)/$2
stage$1:
	sub(stage$1-configure)
	sub(stage$1-build)
	sub(stage$1-install)
stage$1-configure:
	cmake -B $(STAGE$1_BUILD_DIR) -S $(STAGE$1_SRC_DIR) -G Ninja $(CMAKE_OPTS_COMMON) $3 $(CMAKE_OPTS_STAGE$1)
stage$1-build:
	cmake --build $(STAGE$1_BUILD_DIR)
stage$1-install:
	cmake --install $(STAGE$1_BUILD_DIR)
)dnl
define(define_stage_rt,define_stage($1,$2,$(CMAKE_OPTS_STAGE_rt)))
define(phony,
.PHONY: $1
$1)dnl


opt_all(CMAKE_BUILD_TYPE=Release)
opt_all(CMAKE_INSTALL_PREFIX=~/local/clang-multistage-test1)
phony(all):
	sub(repo_renew)
	sub(stage1)
	sub(stage2)

opt(1,LLVM_ENABLE_PROJECTS=clang;clang-tools-extra;lld;lldb)
opt(1,CMAKE_EXE_LINKER_FLAGS=-static-libgcc -static-libstdc++)
opt(1,CLANG_DEFAULT_RTLIB=compiler-rt)
define_stage(1,llvm)

opt_rt(CMAKE_C_COMPILER=clang)
opt_rt(CMAKE_CXX_COMPILER=clang++)
opt_rt(CMAKE_ASM_COMPILER=clang)

opt(2,LLVM_ENABLE_RUNTIMES=compiler-rt)
define_stage_rt(2,runtimes)

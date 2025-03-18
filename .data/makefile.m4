
define(xmake,@$(MAKE))

define(phony, .PHONY: $1
$1)

define(option,override CMAKE_OPTS_$1 := $(CMAKE_OPTS_$1) "-D$2")
define(opt,option(STAGE$1,$2))
define(opt_all,option(COMMON,$1))
define(opt_rt,opt(_rt,$1))

define(define_stage,
override STAGE$1_BUILD_DIR := $(REPO_DIR)/build_stage$1
override STAGE$1_SRC_DIR := $(REPO_DIR)/$2
stage$1:
	xmake stage$1-configure
	xmake stage$1-build
	xmake stage$1-install
stage$1-configure:
	cmake -B $(STAGE$1_BUILD_DIR) -S $(STAGE$1_SRC_DIR) -G Ninja $(CMAKE_OPTS_COMMON) $3 $(CMAKE_OPTS_STAGE$1)
stage$1-build:
	cmake --build $(STAGE$1_BUILD_DIR)
stage$1-install:
	cmake --install $(STAGE$1_BUILD_DIR)
)
define(define_stage_rt,define_stage($1,$2,$(CMAKE_OPTS_STAGE_rt)))





REPO_DIR := llvm-project
REPO_URL := https://github.com/llvm/llvm-project
BRANCH := main

INSTALL_PREFIX := ~/local

STAGE2_TARGET := x86_64-pc-none-elf



phony(all):
	xmake repo_renew
	xmake stage1
	xmake stage2


$(REPO_DIR):
	git clone -b $(BRANCH) --single-branch --depth 1 --recursive $(REPO_URL) $(REPO_DIR)

define(xgit, git -C $(REPO_DIR))dnl
phony(repo-renew): $(REPO_DIR)
	xgit fetch origin $(BRANCH) --depth 1
	xmake repo_reset

phony(repo-reset):
	xgit reset --hard "origin/$(BRANCH)"
	xgit clean -df



opt_all(CMAKE_BUILD_TYPE=Release)
opt_all(CMAKE_INSTALL_PREFIX=$(INSTALL_PREFIX)/clang-trunk-$(shell date +%Y.%m.%d-%H.%M.%S))

opt(1,CMAKE_ASM_COMPILER=CC)
opt(1,CMAKE_C_COMPILER=CC)
opt(1,CMAKE_CXX_COMPILER=CXX)
opt(1,LLVM_BUILD_TESTS=OFF)
opt(1,LLVM_ENABLE_FFI=ON)
opt(1,LLVM_ENABLE_LLD=ON)
opt(1,LLVM_ENABLE_PROJECTS=clang;clang-tools-extra;lld;lldb)
opt(1,LLVM_ENABLE_RUNTIMES=compiler-rt;libc;libcxx;libcxxabi;libunwind;openmp")
opt(1,LLVM_ENABLE_WARNINGS=OFF) #there's nothing I can do about it, stop filling my build log
opt(1,LLVM_ENABLE_Z3_SOLVER=ON)
opt(1,LLVM_INCLUDE_BENCHMARKS=OFF)
opt(1,LLVM_INCLUDE_EXAMPLES=OFF)
opt(1,LLVM_INCLUDE_TESTS=OFF)
opt(1,LLVM_TARGETS_TO_BUILD=X86)
opt(1,LLVM_USE_LINKER=lld)
opt(1,CLANG_DEFAULT_LINKER=lld)
opt(1,CLANG_DEFAULT_RTLIB=compiler-rt)
opt(1,CLANG_DEFAULT_STDLIB=libc++)
opt(1,CLANG_DEFAULT_UNWINDLIB=libunwind)
opt(1,CMAKE_EXE_LINKER_FLAGS=-static-libgcc -static-libstdc++)
#TODO: look up LLVM CMake vars
define_stage(1,llvm)

opt_rt(CMAKE_C_COMPILER=clang)
opt_rt(CMAKE_C_FLAGS=--target=$(STAGE2_TARGET))
opt_rt(CMAKE_CXX_COMPILER=clang++)
opt_rt(CMAKE_CXX_FLAGS=--target=$(STAGE2_TARGET))
opt_rt(CMAKE_ASM_COMPILER=clang)
opt_rt(CMAKE_ASM_FLAGS=--target=$(STAGE2_TARGET))
#TODO: look up runtimes' CMake vars
opt(2,LLVM_ENABLE_RUNTIMES=compiler-rt;libc;libcxxabi;libcxx;libunwind)
define_stage_rt(2,runtimes)

override DEPENDENCIES := libgmp-dev libmpfr-dev libmpc-dev
phony(dependencies-install):
	sudo apt install -y $(DEPENDENCIES)

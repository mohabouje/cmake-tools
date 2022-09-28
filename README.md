# CMake-Tools

This repository contains a set of functionalities to easily setup C++ projects.

It is integrated with different tools:

- `cmtools-ccache`: if enabled, it integrates with `ccache` to optimize compilation times
- `cmtools-clang-build-analyzer`: if enabled, it runs `clang-format` in the selected target-files
- `cmtools-clang-format`: if enabled, it runs `clang-format` in the selected target-files
- `cmtools-clang-tidy`: if enabled, it adds `clang-tidy` checks to the selected targets
- `cmtools-codechecker`: if enabled, it adds `codechecker` checks to the selected targets
- `cmtools-coverage`: if enabled, it adds code-coverage report to the selected targets or all project
- `cmtools-cppcheck`: if enabled, it adds `cppcheck` checks to the selected targets
- `cmtools-cpplint`: if enabled, it adds `cpplint` checks to the selected targets
- `cmtools-dependency-graph`: if enabled, it adds a dependency graph of all project
- `cmtools-iwyu`: if enabled, it adds `include-what-you-use` checks to the selected targets
- `cmtools-link-time-optimization`: if enabled, it adds link time optimizations (`lto`) to the selected targets
- `cmtools-lizard`: if enabled, it adds `lizard` checks to the selected targets
- `cmtools-sanitizers`: if enabled, it adds `sanitizer` checks to the selected targets

Other `cmake` functionalities that are offered in this project:

- [`cotire`](https://github.com/sakra/cotire/raw/master/CMake/cotire.cmake): integration with `useful-cmake-macros`
- [`ucm`](https://github.com/onqtam/ucm/raw/master/cmake/ucm.cmake): integration with `cotire` to optimize compilation times

It also offers a set of functionalities to create and configure targets (libraries, applications, tests, benchmarks etc)

- `cmtools-compiler`: set of functionalities to control the compilation flags of selected targets
- `cmtools-*`: miscellaneous functionalities used all over the place

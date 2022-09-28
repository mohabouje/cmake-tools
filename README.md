# CMake-Tools

This repository contains a set of functionalities to easily setup C++ projects. Among others:

- `utils`: cmake functionalities including arguments parsing, arguments inspection, json parsing etc.
- `conan`: `conan` integration helper to configure and install packages
- `clang-tidy`: if enabled, it adds `clang-tidy` checks to all targets
- `clang-format`: if enabled, it runs `clang-format` in all target-files
- `iwyu`: if enabled, it adds `include-what-you-use` checks to all targets
- `eunomia`: if enabled, it generates the configuration files for different tools defined in an `eunomia` config file
- [`cotire`](https://github.com/sakra/cotire/raw/master/CMake/cotire.cmake): integration with `useful-cmake-macros`
- [`ucm`](https://github.com/onqtam/ucm/raw/master/cmake/ucm.cmake): integration with `cotire`

# CMake-Tools

This repository contains a set of functionalities to easily setup C++ projects. Among others:

- `utils`: cmake functionalities including arguments parsing, arguments inspection, json parsing etc.
- `conan`: `conan` integration helper to configure and install packages
- `clang-tidy`: if enabled, it adds `clang-tidy` checks to all targets
- `iwyu`: if enabled, it adds `include-what-you-use` checks to all targets
- `ucm`: integration with `useful-cmake-macros` to simplify the configuration and setup of the camke environment
- `eunomia`: if enabled, it generates the configuration files for different tools defined in an `eunomia` config file

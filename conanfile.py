from conans import ConanFile
from conan.tools.cmake import CMakeToolchain


class CMTConanIntegration(ConanFile):
    name = "cmake-tools-conan-integration"
    version = "0.0.1"
    generators = ['CMakeDeps']
    settings = "os", "arch", "compiler", "build_type"

    def requirements(self):
        self.requires('spdlog/1.10.0')
        self.requires('cli11/2.2.0')
        self.requires('xxhash/0.8.1')
        self.requires('gtest/1.12.1')
        self.requires('benchmark/1.7.0')
        self.requires('cppbenchmark/1.0.0.0')

    def generate(self):
        tc = CMakeToolchain(self, generator="Ninja")
        tc.generate()

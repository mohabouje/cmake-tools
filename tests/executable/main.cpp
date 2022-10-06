#include "example.hpp"
#include "header_only.hpp"

#include <iostream>
#include <unordered_map>
#include <set>
#include <array>

int main() {
    auto example = example::ExampleClass(100);
    auto numbers = example.generate();
    auto sum = header_only::sum(numbers);
    std::cout << "Sum: " << sum << std::endl;
    for (auto number : numbers) {
    std::cout << number << std::endl;
    }

    auto array = std::array<char, 5>();
    return array[10];
}
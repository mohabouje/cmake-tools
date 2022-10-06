#include "example.hpp"

#include <iostream>
#include <unordered_map>
#include <set>
#include <array>

int main() {
    auto example = example::ExampleClass(10);
    auto numbers = example.generate();
    auto sum = example::sum(numbers);
    std::cout << "Sum: " << sum << std::endl;
    for (auto number : numbers) {
    std::cout << number << std::endl;
    }

    auto array = std::array<char, 5>();
    return array[10];
}
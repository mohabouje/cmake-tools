#include "example.hpp"

#include <iostream>

int main() {
  auto example = example::ExampleClass(10);
  auto numbers = example.generate();
  auto sum = example::sum(numbers);
  std::cout << "Sum: " << sum << std::endl;
  for (auto number : numbers) {
    std::cout << number << std::endl;
  }
  return 0;
}
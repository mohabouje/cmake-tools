#pragma once

#include <random>
#include <vector>

namespace example {

inline std::vector<int> generate_random_numbers(int count) {
  std::vector<int> numbers;
  for (int i = 0; i < count; ++i) {
    numbers.push_back(std::rand());
  }
  return numbers;
}

inline int sum(const std::vector<int> &numbers) {
  int sum = 0;
  for (int number : numbers) {
    sum += number;
  }
  return sum;
}

class ExampleClass {
public:
  explicit ExampleClass(int value) : numbers_(value) {}

  std::vector<int> generate() const;

private:
  int numbers_;
};

} // namespace library
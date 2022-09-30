#include "example.hpp"

namespace example {

std::vector<int> ExampleClass::generate() const {
  return generate_random_numbers(numbers_);
}

} // namespace example
#include "example.hpp"

#include <functional>
#include <map>

namespace example {

std::vector<int> ExampleClass::generate() const {
  return generate_random_numbers(numbers_);
}

} // namespace example
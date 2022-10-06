#include "example.hpp"
#include "header_only.hpp"

#include <functional>
#include <map>

namespace example {

std::vector<int> ExampleClass::generate() const {
  return header_only::generate_random_numbers<int>(numbers_);
}

} // namespace example
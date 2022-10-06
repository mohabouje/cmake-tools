#pragma once

#include <random>
#include <vector>

namespace example {
class ExampleClass {
public:
  explicit ExampleClass(std::size_t value) : numbers_(value) {}

  [[nodiscard]] std::vector<int> generate(

  ) const;

private:
  std::size_t numbers_;
};

} // namespace example
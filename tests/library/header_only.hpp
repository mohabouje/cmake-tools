#pragma once

#include <vector>

namespace header_only {

    template<typename T>
    inline std::vector<T> generate_random_numbers(std::size_t count) {
        std::vector<T> numbers(count);
        for (auto& number : numbers) {
            number = static_cast<T>(std::rand());
        }
        return numbers;
    }

    template<typename T>
    inline T sum(std::vector<T> const& numbers) {
        T sum = 0;
        for (auto const& number : numbers) {
            sum += number;
        }
        return sum;
    }

}
#include <gtest/gtest.h>
#include <cmath>

TEST (SquareRootTest, PositiveNos) {
    EXPECT_EQ (18.0, std::sqrt(324.0));
    EXPECT_EQ (25.4, std::sqrt(645.16));
    EXPECT_EQ (50.3321, std::sqrt(2533.310224));
}

TEST (SquareRootTest, ZeroAndNegativeNos) {
    ASSERT_EQ (0.0, std::sqrt(0.0));
    ASSERT_EQ (-1, std::sqrt(-22.0));
}
#include "test.h"

const char *input_array[] = {
    "((1+2)*(3*2))-(1+(1024/3))",
    "((00000-2)*(1024+1024)) / 2",
    "1+(1+(1+(1+(1+(1+(1+0))))))",
    "2*(2*(2*(2*(2*(2*(2*(2*(2*(2*(2*(1024*1024)))))))))))",
    "2147483647+0",
    "2147483647+1",
    "(0-2147483647)-1",
    "(0-2147483647)-2",
};

TestCase *generate_test_cases()
{
    int length = sizeof(input_array) / sizeof(input_array[0]);
    TestCase *test_cases = (TestCase *)malloc(sizeof(TestCase) * length);

    for (int i = 0; i < length; i++)
    {
        test_cases[i].input = input_array[i];
    }

    return test_cases;
}
#include <string.h>
#include "ArithmeticExpreVal.h"

int string2int(char *str)
{
    if (str[strlen(str) - 1] == '\n')
    {
        str[strlen(str) - 1] = '\0';
    }

    int result = 0, index = 0;
    while (str[index] != '\0')
    {
        result = result * 10 + str[index] - '0';
        index++;
    }

    return result;
}
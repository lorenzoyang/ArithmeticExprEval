#include <stdio.h>
#include <string.h>
#include "ArithmeticExpreVal.h"

const int MAX_CHAR = 100;

int main()
{
    char expression[MAX_CHAR];

    printf("L'espressione matematica: ");
    fgets(expression, MAX_CHAR, stdin);

    int value = string2int(expression);
    printf("Il valore dell'espressione è: %d\n", value);

    return 0;
}

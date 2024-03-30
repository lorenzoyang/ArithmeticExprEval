#include <stdio.h>
#include <string.h>
#include "ArithmeticExpreVal.h"

const int MAX_CHAR = 100;

void test(const char *input)
{
    ErrorType error = NoError;

    printf("L'espressione matematica: %s\n", input);

    int result = evaluate(input, &error);
    switch (error)
    {
    case NoError:
        printf("Il risultato dell'espressione è: %d\n", result);
        break;
    case SyntaxError:
        printf("Errore di sintassi\n");
        break;
    case DivisionByZeroError:
        printf("Errore di divisione per zero\n");
        break;
    case OverflowError:
        printf("Errore di overflow\n");
        break;
    default:
        break;
    }

    printf("\n");
}

int main()
{
    const char *input_array[] = {
        "((1+2)*(3*2))-(1+(1024/3))",
    };

    int array_length = sizeof(input_array) / sizeof(input_array[0]);
    for (int i = 0; i < array_length; i++)
    {
        test(input_array[i]);
    }
    printf("Fine----------------------------------------\n");

    return 0;
}

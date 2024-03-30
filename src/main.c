#include <stdio.h>
#include <string.h>
#include "ArithmeticExpreVal.h"

const int MAX_CHAR = 100;

void test(char *input, ErrorType *error)
{
    printf("L'espressione matematica: %s\n", input);

    int index = 0;
    int value = eval(input, &index, error);

    switch (*error)
    {
    case NoError:
        printf("Il risultato dell'espressione è: %d\n", value);
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

    *error = NoError;
}

int main()
{
    ErrorType error = NoError;

    char *input_array[] = {
        "1+2+3",
        "1+2*3",
        "12+(3*10)",
    };

    int array_length = sizeof(input_array) / sizeof(input_array[0]);
    for (int i = 0; i < array_length; i++)
    {
        test(input_array[i], &error);
    }
    printf("Fine----------------------------------------\n");

    return 0;
}

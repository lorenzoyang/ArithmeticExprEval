#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "stdbool.h"
#include "arithmetic_expre_val.h"
#include "test.h"

const int MAX_CHAR = 100;

const bool TEST_MODE = false;

int main()
{
    if (TEST_MODE)
    {
        run_test();
        return 0;
    }

    while (true)
    {
        char input[MAX_CHAR];

        printf("Inserisci l'espressione matematica: ");
        fgets(input, MAX_CHAR, stdin);

        ErrorType error = NoError;
        int result = evaluate(input, &error);
        printResult(result, error);

        printf("Vuoi continuare? (s/n): ");
        char c;
        scanf(" %c", &c);
        getchar(); // Consume the newline character

        if (c == 'n')
        {
            break;
        }
    }

    return 0;
}

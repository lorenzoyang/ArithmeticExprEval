#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "stdbool.h"
#include "../include/arithmetic_expr_val.h"
#include "../include/test_arithmetic_expr_val.h"

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

        printf("Inserisci l'espressione matematica:");
        fgets(input, MAX_CHAR, stdin);
        input[strcspn(input, "\n")] = 0; // Remove the trailing newline character

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

        printf("\n");
    }

    return 0;
}

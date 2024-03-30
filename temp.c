#include <stdio.h>
#include <limits.h>

// Global variable for error handling
char *error_message = NULL;

// Function prototypes
int evaluate(const char *expr, int *index);
int safe_add(int a, int b);
int safe_sub(int a, int b);
int safe_mul(int a, int b);
int safe_div(int a, int b);

int main()
{
    char expr[] = "(1+(2*(3-(4/2))))"; // Example expression
    int index = 0;
    int result = evaluate(expr, &index);

    if (error_message)
    {
        printf("%s\n", error_message);
    }
    else
    {
        printf("Result: %d\n", result);
    }

    return 0;
}

int evaluate(const char *expr, int *index)
{
    int value = 0, temp;
    char op = '+';

    while (expr[*index] != '\0')
    {
        if (expr[*index] == '(')
        {
            (*index)++;
            temp = evaluate(expr, index);
            if (error_message)
                return 0;
        }
        else if (expr[*index] >= '0' && expr[*index] <= '9')
        {
            temp = expr[*index] - '0';
        }
        else if (expr[*index] == ')')
        {
            (*index)++;
            break;
        }
        else if (expr[*index] == '+' || expr[*index] == '-' ||
                 expr[*index] == '*' || expr[*index] == '/')
        {
            op = expr[*index];
            (*index)++;
            continue;
        }
        else
        {
            error_message = "syntax error";
            return 0;
        }

        switch (op)
        {
        case '+':
            value = safe_add(value, temp);
            break;
        case '-':
            value = safe_sub(value, temp);
            break;
        case '*':
            value = safe_mul(value, temp);
            break;
        case '/':
            if (temp == 0)
            {
                error_message = "divide-by-zero error";
                return 0;
            }
            else
            {
                value = safe_div(value, temp);
            }
            break;
        }

        if (error_message)
            return 0;
        (*index)++;
    }
    return value;
}

// Implement safe arithmetic functions to handle potential overflows
int safe_add(int a, int b)
{
    // Check for overflow and underflow
    if ((b > 0 && a > INT_MAX - b) || (b < 0 && a < INT_MIN - b))
    {
        error_message = "overflow";
        return 0;
    }
    return a + b;
}

int safe_sub(int a, int b)
{
    if ((b < 0 && a > INT_MAX + b) || (b > 0 && a < INT_MIN + b))
    {
        error_message = "overflow";
        return 0;
    }
    return a - b;
}

int safe_mul(int a, int b)
{
    if (a > 0)
    {
        if (b > 0)
        {
            if (a > INT_MAX / b)
            {
                error_message = "overflow";
                return 0;
            }
        }
        else if (b < 0)
        {
            if (a > INT_MIN / b)
            {
                error_message = "overflow";
                return 0;
            }
        }
    }
    else if (a < 0)
    {
        if (b > 0)
        {
            if (a < INT_MIN / b)
            {
                error_message = "overflow";
                return 0;
            }
        }
        else if (b < 0)
        {
            if (a < INT_MAX / b)
            {
                error_message = "overflow";
                return 0;
            }
        }
    }
    return a * b;
}

int safe_div(int a, int b)
{
    // Note: Divide by zero is handled in the evaluate function
    return a / b;
}

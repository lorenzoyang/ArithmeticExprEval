#include <string.h>
#include <stdio.h>
#include <limits.h>
#include <stdbool.h>
#include "../include/arithmetic_expr_val.h"

// Private recursive helper function to evaluate the arithmetic expression
int eval(const char **expr, ErrorType *error, int *parentheses);

int evaluate(const char *expr, ErrorType *error)
{
    int parentheses = 0; // to check for parentheses mismatch
    int result = eval(&expr, error, &parentheses);
    if (parentheses != 0)
    {
        *error = ParenthesesMismatchError;
    }
    return result;
}

/**
 * ********************************************************************************************************************
 * Helper functions
 ********************************************************************************************************************
 */

/**
 * expr: pointer to the current character in the expression
 * error: pointer to the error type
 * parentheses: pointer to the number of open parentheses
 * firstCall: true if this is the first call to eval: la prima richiamata di eval non deve finire con ')'
 */
int eval(const char **expr, ErrorType *error, int *parentheses)
{
    int left = 0, right = 0, result = 0;

    // lettura primo operando
    *expr = read_operand(*expr, error, parentheses);
    if (*error != NoError)
    {
        return 0;
    }
    if (**expr == '(')
    {
        (*expr)++; // prossimo carattere
        left = eval(expr, error, parentheses);
    }
    else
    {
        left = string2int(expr, error);
    }

    // lettura operatore
    *expr = read_operator(*expr, error);
    if (*error != NoError)
    {
        return 0;
    }
    char op = **expr;
    (*expr)++; // prossimo carattere

    // lettura secondo operando
    *expr = read_operand(*expr, error, parentheses);
    if (*error != NoError)
    {
        return 0;
    }
    if (**expr == '(')
    {
        (*expr)++; // prossimo carattere
        right = eval(expr, error, parentheses);
    }
    else
    {
        right = string2int(expr, error);
    }

    // dopo il primo operando, l'operatore, e il secondo operando
    // non ci devono essere altri caratteri se non spazi o parentesi di chiusura
    // controllo della chiusura parentesi
    *expr = skip_spaces(*expr);
    if (**expr == ')')
    {
        (*parentheses)--;
        if (*parentheses < 0)
        {
            *error = ParenthesesMismatchError;
            return 0;
        }
        (*expr)++;
    }
    else if (**expr != '\0' && **expr != ' ')
    {
        *error = SyntaxError;
        return 0;
    }

    // calcolo del risultato
    switch (op)
    {
    case '+':
        return safe_add(left, right, error);
    case '-':
        return safe_sub(left, right, error);
    case '*':
        return safe_mul(left, right, error);
    case '/':
        return safe_div(left, right, error);
    default:
        break;
    }
    return result;
}

const char *skip_spaces(const char *expr)
{
    while (*expr == ' ') // skip spaces
    {
        expr++;
    }
    return expr;
}

const char *read_operand(const char *expr, ErrorType *error, int *parentheses)
{
    expr = skip_spaces(expr);
    if (*expr == '(' || (*expr >= '0' && *expr <= '9'))
    {
        if (*expr == '(')
        {
            (*parentheses)++;
        }
    }
    else
    {
        *error = SyntaxError;
    }
    return expr;
}

const char *read_operator(const char *expr, ErrorType *error)
{
    expr = skip_spaces(expr);
    if (*expr != '+' && *expr != '-' && *expr != '*' && *expr != '/')
    {
        *error = SyntaxError;
    }
    return expr;
}

int string2int(const char **expr, ErrorType *error)
{
    int result = 0;
    while (**expr >= '0' && **expr <= '9')
    {
        result = result * 10 + (**expr) - '0';
        if (result < 0) // check for overflow
        {
            *error = OverflowError;
            return 0;
        }
        (*expr)++;
    }
    return result;
}

/***********************************************************************************************************************
 * Operations with overflow and division by zero checking
 * ********************************************************************************************************************
 */

int safe_add(int a, int b, ErrorType *error)
{
    if (b > 0 && a > (INT_MAX - b) || b < 0 && a < (INT_MIN - b))
    {
        *error = OverflowError;
        return 0;
    }
    return a + b;
}

int safe_sub(int a, int b, ErrorType *error)
{
    if (b > 0 && a < (INT_MIN + b) || b < 0 && a > (INT_MAX + b))
    {
        *error = OverflowError;
        return 0;
    }
    return a - b;
}

int safe_mul(int a, int b, ErrorType *error)
{
    if (a > 0)
    {
        if (b > 0 && a > (INT_MAX / b) || b < 0 && b < (INT_MIN / a))
        {
            *error = OverflowError;
            return 0;
        }
    }
    else
    {
        if (b > 0 && a < (INT_MIN / b) || b < 0 && a < (INT_MAX / b))
        {
            *error = OverflowError;
            return 0;
        }
    }
    return a * b;
}

int safe_div(int a, int b, ErrorType *error)
{
    if (b == 0)
    {
        *error = DivisionByZeroError;
        return 0;
    }
    return a / b;
}

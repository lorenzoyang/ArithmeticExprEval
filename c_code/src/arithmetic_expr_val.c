#include <string.h>
#include <stdio.h>
#include <limits.h>
#include <stdbool.h>
#include "../include/arithmetic_expr_val.h"

// Private function declarations
static int eval(const char **expr, ErrorType *error, int *parentheses);
static void skip_spaces(const char **expr);
static const char read_operand(const char **expr, ErrorType *error, int *parentheses);
static const char read_operator(const char **expr, ErrorType *error);
static int string2int(const char **expr, ErrorType *error);

int evaluate(const char *expr, ErrorType *error)
{
    int parentheses = 0;
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

static int eval(const char **expr, ErrorType *error, int *parentheses)
{
    int left = 0, right = 0, result = 0;
    char op = ' ';
    char c = ' '; // variabile temporanea per le funzioni di lettura

    // lettura del primo operando, c è il primo carattere dell'operando
    c = read_operand(expr, error, parentheses);
    if (*error != NoError)
    {
        return 0;
    }
    left = (c == '(') ? eval(expr, error, parentheses) : string2int(expr, error);

    // lettura dell'operatore
    op = read_operator(expr, error);
    if (*error != NoError)
    {
        return 0;
    }

    // lettura secondo operando
    c = read_operand(expr, error, parentheses);
    if (*error != NoError)
    {
        return 0;
    }
    right = (c == '(') ? eval(expr, error, parentheses) : string2int(expr, error);

    // controllo della chiusura delle parentesi
    skip_spaces(expr);
    if (**expr == ')')
    {
        (*parentheses)--;
        if (*parentheses < 0)
        {
            *error = ParenthesesMismatchError;
            return 0;
        }
        (*expr)++; // incremento il puntatore per leggere il prossimo carattere
    }
    else if (**expr != '\0')
    {
        *error = SyntaxError;
        return 0;
    }

    // calcolo del risultato in base all'operatore
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
        return result;
    }
}

static void skip_spaces(const char **expr)
{
    while (**expr == ' ')
    {
        (*expr)++;
    }
}

// incrementa il puntatore (*expr) solo se il carattere letto è '('
static const char read_operand(const char **expr, ErrorType *error, int *parentheses)
{
    skip_spaces(expr);

    char c = **expr;
    if (c == '(' || (c >= '0' && c <= '9'))
    {
        if (c == '(')
        {
            (*parentheses)++;
            (*expr)++;
        }
    }
    else
    {
        *error = SyntaxError;
    }

    return c;
}

// incrementa anche il puntatore (*expr)
const char read_operator(const char **expr, ErrorType *error)
{
    skip_spaces(expr);

    char c = **expr;
    if (c != '+' && c != '-' && c != '*' && c != '/')
    {
        *error = SyntaxError;
    }

    (*expr)++;
    return c;
}

static int string2int(const char **expr, ErrorType *error)
{
    int result = 0;
    while (**expr >= '0' && **expr <= '9')
    {
        result = result * 10 + (**expr) - '0';
        if (result < 0) // controllo dell'overflow
        {
            *error = OverflowError;
            return 0;
        }
        (*expr)++;
    }
    return result;
}

/***********************************************************************************************************************
 * Operazioni aritmetiche sicure con il controllo dell'overflow e della divisione per zero
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

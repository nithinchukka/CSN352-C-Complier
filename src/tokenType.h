#ifndef TOKEN_TYPE_H
#define TOKEN_TYPE_H

#include <string>
using namespace std;

enum TokenType
{
    KEYWORD_AUTO = 1,
    KEYWORD_BOOL,
    KEYWORD_BREAK,
    KEYWORD_CASE,
    KEYWORD_CATCH,
    KEYWORD_CHAR,
    KEYWORD_CLASS,
    KEYWORD_CONST,
    KEYWORD_CONTINUE,
    KEYWORD_DEFAULT,
    KEYWORD_DELETE,
    KEYWORD_DO,
    KEYWORD_DOUBLE,
    KEYWORD_ELSE,
    KEYWORD_ENUM,
    KEYWORD_EXTERN,
    KEYWORD_FALSE,
    KEYWORD_FLOAT,
    KEYWORD_FOR,
    KEYWORD_FRIEND,
    KEYWORD_GOTO,
    KEYWORD_IF,
    KEYWORD_INLINE,
    KEYWORD_INT,
    KEYWORD_LONG,
    KEYWORD_NAMESPACE,
    KEYWORD_NEW,
    KEYWORD_NULLPTR,
    KEYWORD_PRIVATE,
    KEYWORD_PROTECTED,
    KEYWORD_PUBLIC,
    KEYWORD_REGISTER,
    KEYWORD_RETURN,
    KEYWORD_SHORT,
    KEYWORD_SIGNED,
    KEYWORD_SIZEOF,
    KEYWORD_STATIC,
    KEYWORD_STRUCT,
    KEYWORD_SWITCH,
    KEYWORD_THIS,
    KEYWORD_THROW,
    KEYWORD_TRUE,
    KEYWORD_TRY,
    KEYWORD_TYPEDEF,
    KEYWORD_UNION,
    KEYWORD_UNSIGNED,
    KEYWORD_USING,
    KEYWORD_VIRTUAL,
    KEYWORD_VOID,
    KEYWORD_VOLATILE,
    KEYWORD_WHILE,

    NUMBER,
    CHAR,
    STRING,
    ID,

    LBRACE,
    RBRACE,
    LBRACKET,
    RBRACKET,
    LPAREN,
    RPAREN,
    SEMICOLON,
    COMMA,
    COLON,

    PLUS_OPERATOR,
    MINUS_OPERATOR,
    MULTIPLY_OPERATOR,
    DIVIDE_OPERATOR,
    MODULO_OPERATOR,
    DECREMENT_OPERATOR,
    INCREMENT_OPERATOR,

    ASSIGNMENT_OPERATOR,
    PLUS_ASSIGN_OPERATOR,
    MINUS_ASSIGN_OPERATOR,
    MULTIPLY_ASSIGN_OPERATOR,
    DIVIDE_ASSIGN_OPERATOR,
    MODULO_ASSIGN_OPERATOR,
    BITWISE_AND_ASSIGN_OPERATOR,
    BITWISE_OR_ASSIGN_OPERATOR,
    BITWISE_XOR_ASSIGN_OPERATOR,
    RIGHT_SHIFT_ASSIGN_OPERATOR,
    LEFT_SHIFT_ASSIGN_OPERATOR,

    EQUALS_COMPARISON_OPERATOR,
    NOT_EQUALS_OPERATOR,
    GREATER_THAN_OPERATOR,
    LESS_THAN_OPERATOR,
    GREATER_THAN_OR_EQUAL_OPERATOR,
    LESS_THAN_OR_EQUAL_OPERATOR,

    LOGICAL_AND_OPERATOR,
    LOGICAL_OR_OPERATOR,
    LOGICAL_NOT_OPERATOR,

    BITWISE_AND_OPERATOR,
    BITWISE_OR_OPERATOR,
    BITWISE_XOR_OPERATOR,
    LEFT_SHIFT_OPERATOR,
    RIGHT_SHIFT_OPERATOR,
    BITWISE_NOT_OPERATOR,

    TERNARY_OPERATOR,
    DOT_OPERATOR,
    ARROW_OPERATOR,
    SCOPE_RESOLUTION_OPERATOR,
    HASH_OPERATOR,
    DOUBLE_HASH_OPERATOR,
    ELLIPSIS_OPERATOR,

    POINTER_TO_MEMBER_DOT_OPERATOR,
    POINTER_TO_MEMBER_ARROW_OPERATOR,
};

string tokenTypeToTokenClass(int token)
{
    switch (token)
    {
    case KEYWORD_AUTO:
        return "AUTO";
    case KEYWORD_BOOL:
        return "BOOL";
    case KEYWORD_BREAK:
        return "BREAK";
    case KEYWORD_CASE:
        return "CASE";
    case KEYWORD_CATCH:
        return "CATCH";
    case KEYWORD_CHAR:
        return "CHAR";
    case KEYWORD_CLASS:
        return "CLASS";
    case KEYWORD_CONST:
        return "CONST";
    case KEYWORD_CONTINUE:
        return "CONTINUE";
    case KEYWORD_DEFAULT:
        return "DEFAULT";
    case KEYWORD_DELETE:
        return "DELETE";
    case KEYWORD_DO:
        return "DO";
    case KEYWORD_DOUBLE:
        return "DOUBLE";
    case KEYWORD_ELSE:
        return "ELSE";
    case KEYWORD_ENUM:
        return "ENUM";
    case KEYWORD_EXTERN:
        return "EXTERN";
    case KEYWORD_FALSE:
        return "FALSE";
    case KEYWORD_FLOAT:
        return "FLOAT";
    case KEYWORD_FOR:
        return "FOR";
    case KEYWORD_FRIEND:
        return "FRIEND";
    case KEYWORD_GOTO:
        return "GOTO";
    case KEYWORD_IF:
        return "IF";
    case KEYWORD_INLINE:
        return "INLINE";
    case KEYWORD_INT:
        return "INT";
    case KEYWORD_LONG:
        return "LONG";
    case KEYWORD_NAMESPACE:
        return "NAMESPACE";
    case KEYWORD_NEW:
        return "NEW";
    case KEYWORD_NULLPTR:
        return "NULLPTR";
    case KEYWORD_PRIVATE:
        return "PRIVATE";
    case KEYWORD_PROTECTED:
        return "PROTECTED";
    case KEYWORD_PUBLIC:
        return "PUBLIC";
    case KEYWORD_REGISTER:
        return "REGISTER";
    case KEYWORD_RETURN:
        return "RETURN";
    case KEYWORD_SHORT:
        return "SHORT";
    case KEYWORD_SIGNED:
        return "SIGNED";
    case KEYWORD_SIZEOF:
        return "SIZEOF";
    case KEYWORD_STATIC:
        return "STATIC";
    case KEYWORD_STRUCT:
        return "STRUCT";
    case KEYWORD_SWITCH:
        return "SWITCH";
    case KEYWORD_THIS:
        return "THIS";
    case KEYWORD_THROW:
        return "THROW";
    case KEYWORD_TRUE:
        return "TRUE";
    case KEYWORD_TRY:
        return "TRY";
    case KEYWORD_TYPEDEF:
        return "TYPEDEF";
    case KEYWORD_UNION:
        return "UNION";
    case KEYWORD_UNSIGNED:
        return "UNSIGNED";
    case KEYWORD_USING:
        return "USING";
    case KEYWORD_VIRTUAL:
        return "VIRTUAL";
    case KEYWORD_VOLATILE:
        return "VOLATILE";
    case KEYWORD_VOID:
        return "VOID";
    case KEYWORD_WHILE:
        return "WHILE";

    case PLUS_OPERATOR:
        return "PLUS_OPERATOR";
    case MINUS_OPERATOR:
        return "MINUS_OPERATOR";
    case MULTIPLY_OPERATOR:
        return "MULTIPLY_OPERATOR";
    case DIVIDE_OPERATOR:
        return "DIVIDE_OPERATOR";
    case MODULO_OPERATOR:
        return "MODULO_OPERATOR";
    case DECREMENT_OPERATOR:
        return "DECREMENT_OPERATOR";
    case INCREMENT_OPERATOR:
        return "INCREMENT_OPERATOR";

    case ASSIGNMENT_OPERATOR:
        return "ASSIGNMENT_OPERATOR";
    case PLUS_ASSIGN_OPERATOR:
        return "PLUS_ASSIGN_OPERATOR";
    case MINUS_ASSIGN_OPERATOR:
        return "MINUS_ASSIGN_OPERATOR";
    case MULTIPLY_ASSIGN_OPERATOR:
        return "MULTIPLY_ASSIGN_OPERATOR";
    case DIVIDE_ASSIGN_OPERATOR:
        return "DIVIDE_ASSIGN_OPERATOR";
    case MODULO_ASSIGN_OPERATOR:
        return "MODULO_ASSIGN_OPERATOR";
    case BITWISE_AND_ASSIGN_OPERATOR:
        return "BITWISE_AND_ASSIGN_OPERATOR";
    case BITWISE_OR_ASSIGN_OPERATOR:
        return "BITWISE_OR_ASSIGN_OPERATOR";
    case BITWISE_XOR_ASSIGN_OPERATOR:
        return "BITWISE_XOR_ASSIGN_OPERATOR";
    case RIGHT_SHIFT_ASSIGN_OPERATOR:
        return "RIGHT_SHIFT_ASSIGN_OPERATOR";
    case LEFT_SHIFT_ASSIGN_OPERATOR:
        return "LEFT_SHIFT_ASSIGN_OPERATOR";

    case EQUALS_COMPARISON_OPERATOR:
        return "EQUALS_COMPARISON_OPERATOR";
    case NOT_EQUALS_OPERATOR:
        return "NOT_EQUALS_OPERATOR";
    case GREATER_THAN_OPERATOR:
        return "GREATER_THAN_OPERATOR";
    case LESS_THAN_OPERATOR:
        return "LESS_THAN_OPERATOR";
    case GREATER_THAN_OR_EQUAL_OPERATOR:
        return "GREATER_THAN_OR_EQUAL_OPERATOR";
    case LESS_THAN_OR_EQUAL_OPERATOR:
        return "LESS_THAN_OR_EQUAL_OPERATOR";

    case LOGICAL_AND_OPERATOR:
        return "LOGICAL_AND_OPERATOR";
    case LOGICAL_OR_OPERATOR:
        return "LOGICAL_OR_OPERATOR";
    case LOGICAL_NOT_OPERATOR:
        return "LOGICAL_NOT_OPERATOR";

    case BITWISE_AND_OPERATOR:
        return "BITWISE_AND_OPERATOR";
    case BITWISE_OR_OPERATOR:
        return "BITWISE_OR_OPERATOR";
    case BITWISE_XOR_OPERATOR:
        return "BITWISE_XOR_OPERATOR";
    case LEFT_SHIFT_OPERATOR:
        return "LEFT_SHIFT_OPERATOR";
    case RIGHT_SHIFT_OPERATOR:
        return "RIGHT_SHIFT_OPERATOR";
    case BITWISE_NOT_OPERATOR:
        return "BITWISE_NOT_OPERATOR";

    case TERNARY_OPERATOR:
        return "TERNARY_OPERATOR";
    case DOT_OPERATOR:
        return "DOT_OPERATOR";
    case ARROW_OPERATOR:
        return "ARROW_OPERATOR";
    case SCOPE_RESOLUTION_OPERATOR:
        return "SCOPE_RESOLUTION_OPERATOR";
    case HASH_OPERATOR:
        return "HASH_OPERATOR";
    case DOUBLE_HASH_OPERATOR:
        return "DOUBLE_HASH_OPERATOR";
    case ELLIPSIS_OPERATOR:
        return "ELLIPSIS_OPERATOR";

    case POINTER_TO_MEMBER_DOT_OPERATOR:
        return "POINTER_TO_MEMBER_DOT_OPERATOR";
    case POINTER_TO_MEMBER_ARROW_OPERATOR:
        return "POINTER_TO_MEMBER_ARROW_OPERATOR";

    case NUMBER:
        return "NUMBER";
    case CHAR:
        return "CHARACTER_LITERAL";
    case STRING:
        return "STRING_LITERAL";
    case ID:
        return "IDENTIFIER";
    case LBRACE:
        return "LBRACE";
    case RBRACE:
        return "RBRACE";
    case LBRACKET:
        return "LBRACKET";
    case RBRACKET:
        return "RBRACKET";
    case LPAREN:
        return "LPAREN";
    case RPAREN:
        return "RPAREN";
    case SEMICOLON:
        return "SEMICOLON";
    case COMMA:
        return "COMMA";
    case COLON:
        return "COLON";

    default:
        return "UNKNOWN";
    }
}

#endif

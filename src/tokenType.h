#ifndef TOKEN_TYPE_H
#define TOKEN_TYPE_H

#include <string>
using namespace std;

enum TokenType {
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
    KEYWORD_WHILE
};

string tokenTypeToTokenClass(int token) {
    switch (token) {
        case KEYWORD_AUTO: return "AUTO";
        case KEYWORD_BOOL: return "BOOL";
        case KEYWORD_BREAK: return "BREAK";
        case KEYWORD_CASE: return "CASE";
        case KEYWORD_CATCH: return "CATCH";
        case KEYWORD_CHAR: return "CHAR";
        case KEYWORD_CLASS: return "CLASS";
        case KEYWORD_CONST: return "CONST";
        case KEYWORD_CONTINUE: return "CONTINUE";
        case KEYWORD_DEFAULT: return "DEFAULT";
        case KEYWORD_DELETE: return "DELETE";
        case KEYWORD_DO: return "DO";
        case KEYWORD_DOUBLE: return "DOUBLE";
        case KEYWORD_ELSE: return "ELSE";
        case KEYWORD_ENUM: return "ENUM";
        case KEYWORD_FALSE: return "FALSE";
        case KEYWORD_FLOAT: return "FLOAT";
        case KEYWORD_FOR: return "FOR";
        case KEYWORD_FRIEND: return "FRIEND";
        case KEYWORD_GOTO: return "GOTO";
        case KEYWORD_IF: return "IF";
        case KEYWORD_INLINE: return "INLINE";
        case KEYWORD_INT: return "INT";
        case KEYWORD_LONG: return "LONG";
        case KEYWORD_NAMESPACE: return "NAMESPACE";
        case KEYWORD_NEW: return "NEW";
        case KEYWORD_NULLPTR: return "NULLPTR";
        case KEYWORD_PRIVATE: return "PRIVATE";
        case KEYWORD_PROTECTED: return "PROTECTED";
        case KEYWORD_PUBLIC: return "PUBLIC";
        case KEYWORD_REGISTER: return "REGISTER";
        case KEYWORD_RETURN: return "RETURN";
        case KEYWORD_SHORT: return "SHORT";
        case KEYWORD_SIGNED: return "SIGNED";
        case KEYWORD_SIZEOF: return "SIZEOF";
        case KEYWORD_STATIC: return "STATIC";
        case KEYWORD_STRUCT: return "STRUCT";
        case KEYWORD_SWITCH: return "SWITCH";
        case KEYWORD_THIS: return "THIS";
        case KEYWORD_THROW: return "THROW";
        case KEYWORD_TRUE: return "TRUE";
        case KEYWORD_TRY: return "TRY";
        case KEYWORD_TYPEDEF: return "TYPEDEF";
        case KEYWORD_UNION: return "UNION";
        case KEYWORD_UNSIGNED: return "UNSIGNED";
        case KEYWORD_USING: return "USING";
        case KEYWORD_VIRTUAL: return "VIRTUAL";
        case KEYWORD_VOID: return "VOID";
        case KEYWORD_WHILE: return "WHILE";
        default: return "UNKNOWN";
    }
}

#endif

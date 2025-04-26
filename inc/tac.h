#include <bits/stdc++.h>

using namespace std;

enum class TACOp
{
    ASSIGN,
    ADD,
    SUB,
    MUL,
    DIV,
    MOD,
    INDEX,
    ARR_INDEX,
    LABEL,
    GOTO,
    IF_EQ,
    IF_NE,
    LSHFT,
    RSHFT,
    LT,
    GT,
    LE,
    GE,
    EQ,
    NE,
    BIT_AND,
    BIT_OR,
    BIT_XOR,
    AND,
    OR,
    XOR,
    PRINT,
    RETURN,
    CALL,
    TYPECAST,
    CALL2,
    PARAM,
    DEREF,
    REFER,
    SCAN,
    oth
};

struct TACInstruction
{
    TACOp op;
    string result;
    string operand1;
    string operand2;
    bool isGoto = false;
    
    TACInstruction(TACOp operation, const string &res,
                   const string &op1 = "",
                   const string &op2 = "",
                   bool isGotoFlag = false)
        : op(operation), result(res), operand1(op1), operand2(op2),
          isGoto(isGotoFlag) {}

    string toString() const;
};
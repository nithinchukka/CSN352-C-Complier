#include <bits/stdc++.h>
#include "treeNode.h"

using namespace std;
extern TreeNode *lookupSymbol(string symbol, bool arg, bool orginal);

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
    BIT_NOT,
    NOT,
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
    ENDFUNC,
    STARTFUNC,
    oth
};

struct TACInstruction
{
    TACOp op;
    string result;
    string operand1;
    string operand2;
    TreeNode *resNode = nullptr;
    TreeNode *opNode1 = nullptr;
    TreeNode *opNode2 = nullptr;
    bool isGoto = false;

    TACInstruction(TACOp operation, const string &res,
                   const string &op1 = "",
                   const string &op2 = "",
                   bool isGotoFlag = false)
        : op(operation), result(res), operand1(op1), operand2(op2),
          isGoto(isGotoFlag)
    {
        resNode = lookupSymbol(result, true, true);
        opNode1 = lookupSymbol(operand1, true, true);
        opNode2 = lookupSymbol(operand2, true, true);
    }

    string toString() const;
};
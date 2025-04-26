#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#include <bits/stdc++.h>
#include "treeNode.h"

void raiseError(const string &message, int lineno = -1)
{
    cerr << "Error: " << message;
    if (lineno != -1)
        cerr << " at line " << lineno;
    cerr << endl;
}

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
    oth
};

TACOp assignToOp(const char &ch)
{
    switch (ch)
    {
    case '+':
        return TACOp::ADD;
    case '-':
        return TACOp::SUB;
    case '*':
        return TACOp::MUL;
    case '/':
        return TACOp::DIV;
    case '%':
        return TACOp::MOD;
    case '<':
        return TACOp::LSHFT;
    case '>':
        return TACOp::RSHFT;
    case '&':
        return TACOp::BIT_AND;
    case '|':
        return TACOp::BIT_OR;
    case '^':
        return TACOp::BIT_XOR;
    case '=':
        return TACOp::ASSIGN;
    }
    return TACOp::oth;
}

inline string opToStr(TACOp op)
{
    switch (op)
    {
    case TACOp::ADD:
        return "+";
    case TACOp::SUB:
        return "-";
    case TACOp::MUL:
        return "*";
    case TACOp::DIV:
        return "/";
    case TACOp::MOD:
        return "%";
    case TACOp::LSHFT:
        return "<<";
    case TACOp::RSHFT:
        return ">>";
    case TACOp::LT:
        return "<";
    case TACOp::GT:
        return ">";
    case TACOp::LE:
        return "<=";
    case TACOp::GE:
        return ">=";
    case TACOp::EQ:
        return "==";
    case TACOp::NE:
        return "!=";
    case TACOp::BIT_AND:
        return "&";
    case TACOp::BIT_OR:
        return "|";
    case TACOp::BIT_XOR:
        return "^";
    case TACOp::AND:
        return "&&";
    case TACOp::OR:
        return "||";
    case TACOp::XOR:
        return "^";
    case TACOp::ASSIGN:
        return "=";
    case TACOp::GOTO:
        return "GOTO";
    case TACOp::IF_EQ:
        return "IF ==";
    case TACOp::IF_NE:
        return "IF !=";
    case TACOp::TYPECAST:
        return "cast";
    case TACOp::CALL:
        return "CALL";
    case TACOp::PRINT:
        return "print";
    case TACOp::INDEX:
        return "index";
    case TACOp::ARR_INDEX:
        return "arr_index";
    case TACOp::RETURN:
        return "RETURN";
    case TACOp::LABEL:
        return "LABEL";
    case TACOp::PARAM:
        return "PARAM";
    case TACOp::oth:
        return "";
    default:
        return "unknown";
    }
}

struct TACInstruction
{
    TACOp op;
    string result;
    optional<string> operand1;
    optional<string> operand2;
    bool isGoto = false;
    TACInstruction(TACOp operation, const string &res,
                   const optional<string> &op1 = nullopt,
                   const optional<string> &op2 = nullopt,
                   bool isGotoFlag = false)
        : op(operation), result(res), operand1(op1), operand2(op2),
          isGoto(isGotoFlag) {}

    string toString() const
    {
        string str;
        if (isGoto)
        {
            if (op == TACOp::oth)
                str = "GOTO " + result;
            else
                str = "IF " + *operand1 + " " + opToStr(op) + " " + *operand2 + " GOTO " + result;
            return str;
        }
        switch (op)
        {
        case TACOp::ASSIGN:
            str = result + " = " + (operand1 ? *operand1 : "");
            break;
        case TACOp::ADD:
            str = result + " = " + *operand1 + " + " + *operand2;
            break;
        case TACOp::SUB:
            str = result + " = " + *operand1 + " - " + *operand2;
            break;
        case TACOp::MUL:
            str = result + " = " + *operand1 + " * " + *operand2;
            break;
        case TACOp::DIV:
            str = result + " = " + *operand1 + " / " + *operand2;
            break;
        case TACOp::MOD:
            str = result + " = " + *operand1 + " % " + *operand2;
            break;
        case TACOp::LSHFT:
            str = result + " = " + *operand1 + " << " + *operand2;
            break;
        case TACOp::RSHFT:
            str = result + " = " + *operand1 + " >> " + *operand2;
            break;
        case TACOp::LT:
            str = result + " = " + *operand1 + " < " + *operand2;
            break;
        case TACOp::GT:
            str = result + " = " + *operand1 + " > " + *operand2;
            break;
        case TACOp::LE:
            str = result + " = " + *operand1 + " <= " + *operand2;
            break;
        case TACOp::GE:
            str = result + " = " + *operand1 + " >= " + *operand2;
            break;
        case TACOp::EQ:
            str = result + " = " + *operand1 + " == " + *operand2;
            break;
        case TACOp::NE:
            str = result + " = " + *operand1 + " != " + *operand2;
            break;
        case TACOp::BIT_AND:
            str = result + " = " + *operand1 + " & " + *operand2;
            break;
        case TACOp::BIT_OR:
            str = result + " = " + *operand1 + " | " + *operand2;
            break;
        case TACOp::BIT_XOR:
            str = result + " = " + *operand1 + " ^ " + *operand2;
            break;
        case TACOp::AND:
            str = result + " = " + *operand1 + " && " + *operand2;
            break;
        case TACOp::OR:
            str = result + " = " + *operand1 + " || " + *operand2;
            break;
        case TACOp::XOR:
            str = result + " = " + *operand1 + " ^ " + *operand2;
            break;
        case TACOp::PRINT:
            str = "print " + result;
            break;
        case TACOp::INDEX:
            str = result + " = " + *operand1 + "[" + *operand2 + "]";
            break;
        case TACOp::LABEL:
            str = result + ":";
            break;
        case TACOp::GOTO:
            str = "GOTO " + result;
            break;
        case TACOp::IF_EQ:
            str = "IF " + *operand1 + " == " + *operand2 + " GOTO " + result;
            break;
        case TACOp::IF_NE:
            str = "IF " + *operand1 + " != " + *operand2 + " GOTO " + result;
            break;
        case TACOp::RETURN:
            str = "RETURN " + result;
            break;
        case TACOp::CALL:
            str = result + " = CALL " + *operand1 + "(" + (operand2 ? *operand2 : "") + ")";
            break;
        case TACOp::CALL2:
            str = "CALL " + *operand1 + "(" + (operand2 ? *operand2 : "") + ")";
            break;
        case TACOp::TYPECAST:
            str = result + " = " + *operand1 + "(" + *operand2 + ")";
            break;
        case TACOp::oth:
            str = result + " = " + *operand1 + " " + *operand2;
            break;
        case TACOp::PARAM:
            str = "PARAM " + result;
            break;
        case TACOp::DEREF:
            str = result + " = *" + *operand1;
            break;
        case TACOp::REFER:
            str = result + " = &" + *operand1;
            break;
        default:
            str = "Unknown";
            break;
        }
        return str;
    }
};

struct irGenerator
{
    vector<TACInstruction> tacCode;
    int tempCounter = 0;
    int labelCounter = 0;
    int currentInstrIndex = 0;

    string newTemp()
    {
        return "t" + to_string(tempCounter++);
    }

    string newLabel()
    {
        return "L" + to_string(labelCounter++);
    }
    int emit(TACOp op, const string &result,
             const optional<string> &op1 = nullopt,
             const optional<string> &op2 = nullopt, bool isGotoFlag = false)
    {
        tacCode.emplace_back(op, result, op1, op2, isGotoFlag);
        return currentInstrIndex++;
    }

    void printTAC()
    {
        for (const auto &instr : tacCode)
            cout << instr.toString() << '\n';
    }
};

irGenerator irGen;

string typeName(int p)
{
    if (p == 1)
    {
        return "char";
    }
    if (p == 2)
    {
        return "short";
    }
    if (p == 3)
    {
        return "int";
    }
    if (p == 4)
    {
        return "long";
    }
    if (p == 6)
    {
        return "float";
    }
    if (p == 7)
    {
        return "double";
    }
    if (p == 8)
    {
        return "string";
    }
    return "invalid type";
}

struct backpatchNode
{
    int index;
    backpatchNode *next;
    string exp;
};

class Backpatch
{
public:
    static backpatchNode *addToBackpatchList(backpatchNode *list, int index, string exp = "")
    {
        auto *newNode = new backpatchNode{index, list, exp};
        return newNode;
    }

    static void backpatch(backpatchNode *list, const string &label)
    {
        for (backpatchNode *current = list; current; current = current->next)
        {
            int idx = current->index;
            if (idx >= 0 && idx < irGen.tacCode.size())
            {
                irGen.tacCode[idx].result = label;
            }
        }
    }

    static backpatchNode *mergeBackpatchLists(backpatchNode *list1, backpatchNode *list2)
    {
        if (!list1)
            return list2;
        if (!list2)
            return list1;
        backpatchNode *current = list1;
        while (current->next)
            current = current->next;
        current->next = list2;
        return list1;
    }
};

int expectedReturnType = -1;
extern unordered_set<string> classOrStructOrUnion;

struct Table
{
    vector<pair<string, TreeNode *>> symbolTable;
    int totalSize = 0;
    Table *parent;
};

stack<Table *> tableStack;
stack<int> offsetStack;
Table *currentTable;
vector<Table *> allTables;
stack<unordered_map<string, backpatchNode *>> labelToBeDefined;

TreeNode *lookupSymbol(string symbol, bool arg = false)
{
    Table *temp = currentTable;
    while (temp != nullptr)
    {
        for (const auto &entry : temp->symbolTable)
        {
            if (entry.first == symbol)
            {
                TreeNode *original = entry.second;
                TreeNode *copy = new TreeNode(*original);
                return copy;
            }
        }
        temp = temp->parent;
    }

    if (!arg)
        raiseError("Symbol " + symbol + " not found in table");
    return nullptr;
}

int findOffset(int type, string name = "")
{
    switch (type)
    {
    case 1: // char
        return 1;
    case 3: // int
        return 4;
    case 4: // long
        return 8;
    case 6: // float
        return 4;
    case 7: // double
        return 8;
    case 20:
    {
        TreeNode *node = lookupSymbol(name);
        if (node == nullptr)
        {
            raiseError("Error: No struct definition found for type checking");
            return -1;
        }
        return node->totalOffset;
    }
    default:
        return -1; // Invalid type
    }
}

void enterScope()
{
    Table *newTable = new Table();
    newTable->parent = currentTable;
    currentTable = newTable;
    tableStack.push(newTable);
    offsetStack.push(0);
    labelToBeDefined.push({});
    allTables.push_back(newTable);
}

void exitScope()
{
    if (currentTable->parent == nullptr)
    {
        raiseError("Cannot exit global scope");
        return;
    }
    currentTable->totalSize = offsetStack.top();
    currentTable = currentTable->parent;
    tableStack.pop();
    if (labelToBeDefined.top().size())
    {
        raiseError("Unresolved labels in scope");
    }
    labelToBeDefined.pop();
    offsetStack.pop();
}

void insertSymbol(string symbol, TreeNode *node)
{
    for (const auto &entry : currentTable->symbolTable)
    {
        if (entry.first == symbol)
        {
            raiseError("Symbol " + symbol + " already exists in table");
            return;
        }
    }
    currentTable->symbolTable.emplace_back(symbol, node);
}

#include <bits/stdc++.h>
using namespace std;

string getTypeCategoryName(int cat)
{
    static vector<string> names = {
        "var", "pointer", "arr", "func", "struct", "union",
        "class", "label", "reference", "parameter"};
    return (cat >= 0 && cat < names.size()) ? names[cat] : "unknown";
}

string vecToStr(const vector<int> &v)
{
    stringstream ss;
    ss << "[";
    for (int i = 0; i < v.size(); ++i)
    {
        ss << v[i];
        if (i != v.size() - 1)
            ss << ", ";
    }
    ss << "]";
    return ss.str();
}

void printAllTables()
{
    int tblId = 0;
    for (auto &tbl : allTables)
    {
        cout << "Tbl " << tblId++ << " (Table Size): " << tbl->totalSize << "\n";
        cout << "===========================================================================================================================\n";
        cout << left << setw(16) << "Id"
             << setw(12) << "TypeCat"
             << setw(12) << "TypeSpec"
             << setw(8) << "Offset"
             << setw(8) << "PtrLvl"
             << setw(8) << "Const"
             << setw(8) << "Static"
             << setw(8) << "LVal"
             << setw(8) << "Dims"
             << setw(15) << "ParamTypes"
             << setw(10) << "ParamCnt"
             << "TAC Result"
             << "\n";
        cout << "---------------------------------------------------------------------------------------------------------------------------\n";

        for (const auto &entry : tbl->symbolTable)
        {
            TreeNode *node = entry.second;
            cout << left << setw(16) << entry.first
                 << setw(12) << getTypeCategoryName(node->typeCategory)
                 << setw(12) << node->typeSpecifier
                 << setw(8) << node->offset
                 << setw(8) << node->pointerLevel
                 << setw(8) << (node->isConst ? "yes" : "no")
                 << setw(8) << (node->isStatic ? "yes" : "no")
                 << setw(8) << (node->isLValue ? "yes" : "no")
                 << setw(8) << vecToStr(node->dimensions)
                 << setw(15) << vecToStr(node->paramTypes)
                 << setw(10) << node->paramCount
                 << node->tacResult
                 << "\n";
        }

        cout << "===========================================================================================================================\n\n";
    }
}

struct DeclaratorInfo
{
    int typeCategory = -1;  // var = 0, func = 1, struct = 2, enum = 3, class = 4
    int typeSpecifier = -1; // -1: none, void : -1: char : 1, short : 2, 3: int,, 4: long, 6: float, 7: double
    bool isConst = false;
    bool isStatic = false;
    bool isValid = false;
    bool isCustomType = false; // true if it's a class, struct, or union
    int offset = 0;
};

string typeCastInfo(int lhs, int rhs)
{
    if (lhs == 1 && rhs == 3)
        return "int_to_char";
    if (lhs == 2 && rhs == 3)
        return "int_to_short";
    if (lhs == 3 && rhs == 4)
        return "long_to_int";
    if (lhs == 1 && rhs == 4)
        return "long_to_char";
    if (lhs == 2 && rhs == 4)
        return "long_to_short";
    if (lhs == 3 && rhs == 6)
        return "float_to_int";
    if (lhs == 6 && rhs == 7)
        return "double_to_float";
    if (lhs == 3 && rhs == 7)
        return "double_to_int";
    if (lhs == 7 && rhs == 6)
        return "float_to_double";
    if (lhs == 6 && rhs == 3)
        return "int_to_float";
    if (lhs == 7 && rhs == 3)
        return "int_to_double";
    if (lhs == 3 && rhs == 1)
        return "char_to_int";
    return "invalid";
}

bool isValidCast(int toType, int fromType)
{
    if (toType >= 1 && toType <= 6 && fromType >= 1 && fromType <= 6)
        return true;
    return false;
}

bool checkFormatSpecifiers(string formatString, vector<int> argTypeList)
{
    int argIndex = 0;
    const char *ptr = formatString.c_str();
    while (*ptr)
    {
        if (*ptr == '%')
        {
            ptr++;
            if (*ptr == '\0')
                break;
            if (*ptr == '%')
            {
                ptr++;
                continue;
            }

            if (argIndex >= argTypeList.size())
            {
                raiseError("Too few arguments");
                return false;
            }

            int expectedType1 = -1, expectedType2 = -1;
            switch (*ptr)
            {
            case 'd':
                expectedType1 = 2, expectedType2 = 3;
                break;
            case 'f':
                expectedType1 = 5, expectedType2 = 6;
                break;
            case 's':
                expectedType1 = 8;
                break;
            case 'c':
                expectedType1 = 1;
                break;
            default:
                raiseError("Unknown format specifier '%" + string(1, *ptr) + "'");
                return false;
            }

            if (argTypeList[argIndex] != expectedType1 && argTypeList[argIndex] != expectedType2)
            {
                raiseError("Type mismatch for '%" + string(1, *ptr) + "'");
                return false;
            }
            argIndex++;
        }
        ptr++;
    }

    if (argIndex < argTypeList.size())
    {
        raiseError("Too many arguments");
        return false;
    }

    return true;
}

DeclaratorInfo isValidVariableDeclaration(vector<TreeNode *> &nodes, bool isFunction = false)
{
    DeclaratorInfo declInfo;
    unordered_map<string, int> baseTypes = {
        {"void", 0}, {"char", 1}, {"int", 3}, {"long", 5}, {"float", 6}, {"double", 7}};

    int typeSpecifierCount = 0;

    for (const auto &node : nodes)
    {
        string val = node->value;

        if (node->type == NODE_STORAGE_CLASS_SPECIFIER)
        {
            if (declInfo.isStatic)
                return {};
            declInfo.isStatic = true;
        }
        else if (node->type == NODE_TYPE_SPECIFIER)
        {
            if (classOrStructOrUnion.count(val))
            {
                if (declInfo.typeSpecifier != -1)
                    return {};
                declInfo.typeCategory = 4;
                declInfo.typeSpecifier = 20;
                declInfo.isCustomType = true;
                typeSpecifierCount++;
            }
            else if (baseTypes.count(val))
            {
                if (declInfo.typeSpecifier != -1)
                    return {};
                declInfo.typeSpecifier = baseTypes[val];
                typeSpecifierCount++;
            }
            else
                return {};
        }
        else if (node->type == NODE_TYPE_QUALIFIER)
        {
            if (declInfo.isConst)
                return {};
            declInfo.isConst = true;
        }
        else
            return {};
    }

    if (typeSpecifierCount == 0)
        return {};

    if (!isFunction && declInfo.typeSpecifier == 0)
        return {};

    declInfo.isValid = true;
    return declInfo;
}

bool isTypeCompatible(int lhstype, int rhstype, string op, bool lhsIsConst = false)
{
    unordered_set<int> integerTypes = {1, 2, 3, 4};
    unordered_set<int> floatingTypes = {6, 7};
    unordered_set<int> numericTypes = integerTypes;
    numericTypes.insert(floatingTypes.begin(), floatingTypes.end());
    unordered_set<int> validTypes = numericTypes;
    validTypes.insert(8);

    bool lhsIsNumeric = numericTypes.count(lhstype);
    bool rhsIsNumeric = numericTypes.count(rhstype);
    bool lhsIsInteger = integerTypes.count(lhstype);
    bool rhsIsInteger = integerTypes.count(rhstype);
    bool lhsIsString = (lhstype == 8);
    bool rhsIsString = (rhstype == 8);

    if (lhstype < -1 || rhstype < -1 ||
        (lhstype > 8 || rhstype > 8) ||
        (lhstype == 0 || rhstype == 0) ||
        (lhstype == 5 || rhstype == 5))
    {
        return false;
    }

    if (lhstype == -1 || rhstype == -1)
    {
        return false;
    }

    if (op == "+" || op == "-" || op == "*" || op == "/")
    {
        return lhsIsNumeric && rhsIsNumeric;
    }
    if (op == "%")
    {
        return lhsIsInteger && rhsIsInteger;
    }

    if (op == "==" || op == "!=")
    {
        return (lhsIsNumeric && rhsIsNumeric) || (lhsIsString && rhsIsString);
    }
    if (op == "<" || op == ">" || op == "<=" || op == ">=")
    {
        return lhsIsNumeric && rhsIsNumeric;
    }

    if (op == "=")
    {
        if (lhsIsConst)
            return false;
        if (lhstype == rhstype)
            return true;
        if (lhsIsNumeric && rhsIsNumeric)
        {

            return true;
        }
        return false;
    }

    if (op == "+=" || op == "-=" || op == "*=" || op == "/=")
    {
        if (lhsIsConst)
            return false;
        return lhsIsNumeric && rhsIsNumeric;
    }

    if (op == "+=" && lhsIsString && rhsIsString)
    {
        return !lhsIsConst;
    }

    if (op == "^" || op == "&" || op == "|")
    {
        return lhsIsInteger && rhsIsInteger;
    }
    if (op == "^=" || op == "&=" || op == "|=")
    {
        if (lhsIsConst)
            return false;
        return lhsIsInteger && rhsIsInteger;
    }
    if (op == "<<" || op == ">>")
    {
        return lhsIsInteger && rhsIsInteger;
    }
    if (op == "<<=" || op == ">>=")
    {
        if (lhsIsConst)
            return false;
        return lhsIsInteger && rhsIsInteger;
    }

    if (op == "&&" || op == "||")
    {
        return lhsIsNumeric && rhsIsNumeric;
    }

    if (op == "!" || op == "~")
    {
        return (lhstype != 8) && (rhstype == -1 || rhstype == 8);
    }

    if (op == "++" || op == "--")
    {
        if (lhsIsConst)
            return false;
        return lhsIsNumeric && (rhstype == -1 || rhstype == 8);
    }

    return false;
}

bool structInitializerCheck(TreeNode *identifierNode, TreeNode *initializerList)
{
    if (identifierNode->symbolTable.empty())
    {
        raiseError("No struct definition found for type checking");
        return false;
    }

    size_t expectedSize = identifierNode->symbolTable.size();
    size_t actualSize = initializerList->children.size();

    if (expectedSize != actualSize)
    {
        raiseError("Struct initializer size mismatch - expected " +
                   to_string(expectedSize) + " values, got " + to_string(actualSize));
        return false;
    }

    for (size_t i = 0; i < expectedSize; i++)
    {
        const auto &memberPair = identifierNode->symbolTable[i];
        TreeNode *memberNode = memberPair.second;
        TreeNode *initNode = initializerList->children[i];

        int expectedType = memberNode->typeSpecifier;
        int actualType = initNode->typeSpecifier;

        bool typesCompatible = isTypeCompatible(expectedType, actualType, "=");

        if (!typesCompatible)
        {
            raiseError("Type mismatch in struct initializer - expected " +
                       typeName(expectedType) + ", got " + typeName(actualType));
            return false;
        }
        else
        {
            string temp = irGen.newTemp();
            irGen.emit(TACOp::TYPECAST, temp, typeCastInfo(expectedType, actualType), initNode->tacResult);
            initNode->tacResult = temp;
        }

        if (memberNode->isConst)
        {
            raiseError("Cannot initialize const member '" + memberPair.first +
                       "' in struct initializer");
            return false;
        }

        if (memberNode->pointerLevel > 0)
        {
            raiseError("Pointer initialization not supported in struct initializer for '" +
                       memberPair.first + "'");
            return false;
        }
    }

    return true;
}

vector<int> typeExtract(TreeNode *node)
{
    vector<int> ans;
    for (auto child : node->children)
    {
        ans.push_back(child->typeSpecifier);
    }
    return ans;
}

int inLoop = 0;
bool inFunc = false;
bool insideClass = false;
int accessSpecifier = 0;

void GenerateTAC(TreeNode *initList, vector<int> dimensions, int level, string name)
{
    int vecSize = dimensions.size();
    if (level == vecSize - 1)
    {
        int i = 0;
        for (TreeNode *child : initList->children)
        {
            string indexedName = name + "[" + to_string(i) + "]";
            irGen.emit(TACOp::ASSIGN, indexedName, child->tacResult, nullopt);
            i++;
        }
    }
    else
    {
        int i = 0;
        for (TreeNode *child : initList->children)
        {
            string newName = name + "[" + to_string(i) + "]";
            if (child->type != NODE_INITIALIZER_LIST)
            {
                return;
            }
            GenerateTAC(child, dimensions, level + 1, newName);
            i++;
        }
    }
}

bool checkInitializerLevel(TreeNode *initList, int baseType, vector<int> &dimensions, int level, string name)
{
    int vecSize = dimensions.size();

    if (baseType != 1 && baseType != 3)
    {
        raiseError("Invalid base type for array initialization");
        return false;
    }

    for (int i = 1; i < vecSize; i++)
    {
        if (dimensions[i] == -1)
        {
            raiseError("Invalid Declaration: dimension " + to_string(i) + " cannot be unspecified");
            return false;
        }
    }

    if (level >= vecSize)
    {
        raiseError("Too many nesting levels");
        return false;
    }

    if (level == 0 && dimensions[0] == -1)
    {
        dimensions[0] = initList->children.size();
    }

    if (initList->children.size() != dimensions[level])
    {
        raiseError("Dimension mismatch at level " + to_string(level) +
                   ": expected " + to_string(dimensions[level]) +
                   ", got " + to_string(initList->children.size()));
        return false;
    }

    if (level == vecSize - 1)
    {
        for (TreeNode *child : initList->children)
        {
            if (child->typeSpecifier != baseType)
            {
                raiseError("Type mismatch at level " + to_string(level) +
                           ": expected " + typeName(baseType) +
                           ", got " + typeName(child->typeSpecifier));
                return false;
            }
        }
    }
    else
    {
        for (TreeNode *child : initList->children)
        {
            if (child->type != NODE_INITIALIZER_LIST)
            {
                raiseError("Expected nested initializer list at level " + to_string(level));
            }
            if (!checkInitializerLevel(child, baseType, dimensions, level + 1, name))
            {
                return false;
            }
        }
    }
    GenerateTAC(initList, dimensions, 0, name);
    return true;
}

vector<int> findArrayDimensions(TreeNode *arr)
{
    if (!arr || arr->children.empty())
        return {};
    vector<int> dimensions;
    TreeNode *current = arr;

    while (current)
    {
        if (current->type == ARRAY)
        {
            if (current->children.size() > 1 && current->children[1] &&
                current->children[1]->type == INTEGER_LITERAL)
            {
                dimensions.push_back(stoi(current->children[1]->value));
            }
            else
            {
                dimensions.push_back(-1);
            }
        }
        current = (!current->children.empty()) ? current->children[0] : nullptr;
    }
    reverse(dimensions.begin(), dimensions.end());
    return dimensions;
}

void addDeclarators(TreeNode *specifier, TreeNode *list)
{
    DeclaratorInfo declInfo = isValidVariableDeclaration(specifier->children, false);
    if (declInfo.isValid)
    {
        auto helper = specifier;
        for (auto child : specifier->children)
        {
            if (child->type == NODE_TYPE_SPECIFIER)
            {
                helper = child;
                break;
            }
        }
        if (declInfo.typeCategory == 4)
            helper = lookupSymbol(helper->value);
        for (auto child : list->children)
        {
            if (child->type != NODE_DECLARATOR)
                continue;

            TreeNode *firstChild = child->children[0];
            string varName;
            TreeNode *identifierNode = firstChild;
            auto setNodeAttributes = [&](TreeNode *node, int typeCategory, int pointerLevel = 0)
            {
                node->typeCategory = typeCategory;
                node->pointerLevel = pointerLevel;
                node->typeSpecifier = declInfo.typeSpecifier;
                node->isConst = declInfo.isConst;
                node->isStatic = declInfo.isStatic;
                node->symbolTable = helper->symbolTable;
                node->totalOffset = helper->totalOffset;
            };
            auto checkDuplicate = [&](const string &name)
            {
                for (const auto &entry : currentTable->symbolTable)
                {
                    if (entry.first == name)
                    {
                        raiseError("Duplicate declaration of '" + name + "'");
                        return true;
                    }
                }
                return false;
            };
            if (firstChild->type == ARRAY)
            {
                if (declInfo.typeSpecifier == 1 && child->children[1]->typeSpecifier == 1)
                {
                    int string_size = child->children[1]->value.size() - 2;
                    int array_size = stoi(firstChild->children[1]->value);
                    varName = firstChild->children[0]->value;
                    if (array_size != string_size)
                    {
                        raiseError("Dimensions doesnt match LHS Dimesnions: " + to_string(array_size) + " and RHS Dimensions: " + to_string(string_size));
                    }
                    else
                    {
                        vector<string> temp_store;
                        string s = child->children[1]->value;
                        for (int i = 0; i < array_size; i++)
                        {
                            string temp = irGen.newTemp();
                            irGen.emit(TACOp::ASSIGN, temp, "'" + string(1, s[i + 1]) + "'", nullopt);
                            temp_store.push_back(temp);
                        }
                        string temp = irGen.newTemp();
                        irGen.emit(TACOp::ASSIGN, temp, "/0", nullopt);
                        for (int i = 0; i < array_size; i++)
                        {
                            string indexedName = varName + "[" + to_string(i) + "]";
                            irGen.emit(TACOp::ASSIGN, indexedName, temp_store[i], nullopt);
                        }
                    }
                }
                else
                {
                    vector<int> dimensions = findArrayDimensions(firstChild);
                    while (identifierNode && identifierNode->type == ARRAY)
                    {
                        if (identifierNode->children.empty())
                            break;
                        identifierNode = identifierNode->children[0];
                    }
                    varName = identifierNode->value;
                    if (checkDuplicate(varName))
                        continue;
                    int size = child->children.size();
                    if (size == 1 || size == 2)
                    {
                        bool validDims = all_of(dimensions.begin(), dimensions.end(), [](int d)
                                                { return d != -1; });
                        if (!validDims)
                        {
                            raiseError("Invalid declaration dimension cannot be empty");
                            continue;
                        }
                        if (size == 2 && !checkInitializerLevel(child->children[1], declInfo.typeSpecifier, dimensions, 0, varName))
                        {
                            raiseError("Invalid initializer for array '" + varName + "'");
                            continue;
                        }
                        setNodeAttributes(identifierNode, 2, 0);
                        identifierNode->dimensions = dimensions;
                        identifierNode->pointerLevel = dimensions.size();
                        insertSymbol(varName, identifierNode);
                        identifierNode->offset = offsetStack.top();
                        int totalSize = 1;
                        for(auto i:dimensions) totalSize *= i;
                        offsetStack.top() += totalSize * findOffset(declInfo.typeSpecifier);
                    }
                }
            }
            else if (firstChild->type == NODE_POINTER)
            {
                int pointerDepth = 0;
                while (identifierNode && identifierNode->type == NODE_POINTER)
                {
                    pointerDepth++;
                    if (identifierNode->children.empty())
                        break;
                    identifierNode = identifierNode->children[0];
                }
                varName = identifierNode->value;
                if (identifierNode->type == ARRAY)
                {
                    vector<int> dimensions = findArrayDimensions(identifierNode);
                    varName = identifierNode->children[0]->value;
                    if (checkDuplicate(varName))
                        continue;

                    int size = child->children.size();
                    if (size == 1 || size == 2)
                    {
                        bool validDims = all_of(dimensions.begin(), dimensions.end(), [](int d)
                                                { return d != -1; });
                        if (!validDims)
                        {
                            raiseError("Invalid declaration dimension cannot be empty");
                            continue;
                        }
                        if (size == 2 && !checkInitializerLevel(child->children[1], declInfo.typeSpecifier, dimensions, pointerDepth, varName))
                        {
                            raiseError("Invalid initializer for array '" + varName + "'");
                            continue;
                        }
                        setNodeAttributes(identifierNode, 2, pointerDepth);
                        identifierNode->dimensions = dimensions;
                        insertSymbol(varName, identifierNode);
                    }
                }
                else
                {
                    if (checkDuplicate(varName))
                        continue;
                    int size = child->children.size();
                    if (size == 1)
                    {
                        setNodeAttributes(identifierNode, 1, pointerDepth);
                        insertSymbol(varName, identifierNode);
                    }
                    else
                    {
                        int lhsPointerlevel = pointerDepth;
                        int rhsPointerlevel = child->children[1]->pointerLevel;
                        cout << lhsPointerlevel << " " << rhsPointerlevel;
                        if (((lhsPointerlevel == 1 && rhsPointerlevel == 1) && (declInfo.typeSpecifier != child->children[1]->typeSpecifier)) && (child->children[1]->typeSpecifier != 9))
                        {
                            raiseError("Incompatible pointer types in assignment — LHS is of type '" + typeName(declInfo.typeSpecifier) + "*', RHS is of type '" + typeName(child->children[1]->typeSpecifier) + "*'.");
                        }
                        else if (lhsPointerlevel != rhsPointerlevel)
                        {
                            raiseError("Error: Invalid pointer initialization for '" + varName + "'\n");
                        }
                        else
                        {
                            if (declInfo.typeSpecifier == 3 && child->children[1]->typeCategory == 2)
                            {
                                setNodeAttributes(identifierNode, 1, pointerDepth);
                                insertSymbol(varName, identifierNode);
                                if (child->children[1]->trueList || child->children[1]->falseList)
                                {
                                    Backpatch::backpatch(child->children[1]->trueList, to_string(irGen.currentInstrIndex));
                                    Backpatch::backpatch(child->children[1]->falseList, to_string(irGen.currentInstrIndex + 1));
                                    irGen.emit(TACOp::ASSIGN, varName, "1", nullopt);
                                    irGen.emit(TACOp::ASSIGN, varName, "0", nullopt);
                                }
                                else
                                {
                                    irGen.emit(TACOp::ASSIGN, varName, child->children[1]->tacResult, nullopt);
                                }
                            }
                            else if (isTypeCompatible(declInfo.typeSpecifier, child->children[1]->typeSpecifier, "="))
                            {
                                if (declInfo.typeSpecifier != child->children[1]->typeSpecifier)
                                {
                                    string temp = irGen.newTemp();
                                    irGen.emit(TACOp::TYPECAST, temp, typeCastInfo(declInfo.typeSpecifier, child->children[1]->typeSpecifier), child->children[1]->tacResult);
                                    child->children[1]->tacResult = temp;
                                }
                                setNodeAttributes(identifierNode, 1, pointerDepth);
                                insertSymbol(varName, identifierNode);
                                // if (child->children[1]->trueList || child->children[1]->falseList)
                                // {    
                                //     Backpatch::backpatch(child->children[1]->trueList, to_string(irGen.currentInstrIndex));
                                //     Backpatch::backpatch(child->children[1]->falseList, to_string(irGen.currentInstrIndex + 1));
                                //     irGen.emit(TACOp::ASSIGN, varName, "1", nullopt);
                                //     irGen.emit(TACOp::ASSIGN, varName, "0", nullopt);
                                // }

                                // else
                                irGen.emit(TACOp::ASSIGN, varName, child->children[1]->tacResult, nullopt);
                            }
                            else if (declInfo.typeSpecifier == 1 && child->children[1]->typeSpecifier == 8)
                            {
                                irGen.emit(TACOp::ASSIGN, varName, child->children[1]->tacResult);
                            }
                            else if (child->children[0]->pointerLevel > 0 && child->children[1]->typeSpecifier == 9)
                            {
                                irGen.emit(TACOp::ASSIGN, varName, child->children[1]->tacResult);
                            }
                            else
                            {
                                raiseError("Type mismatch in assignment: LHS is of type '" + typeName(declInfo.typeSpecifier) + "' and RHS is of type '" + typeName(child->children[1]->typeSpecifier) + "'");
                            }
                        }
                    }
                }
                identifierNode->offset = offsetStack.top();
                offsetStack.top() = identifierNode->offset + 4;
            }
            else
            {
                varName = firstChild->value;
                if (checkDuplicate(varName))
                    continue;
                int size = child->children.size();
                if (size == 1)
                {
                    if (declInfo.isConst)
                    {
                        raiseError("Const variable '" + varName + "' must be initialized");
                        continue;
                    }
                    setNodeAttributes(identifierNode, 0);
                    insertSymbol(varName, identifierNode);
                }
                else
                {
                    int lhsPointerLevel = child->children[0]->pointerLevel;
                    int rhsPointerLevel = child->children[1]->pointerLevel;
                    if (((lhsPointerLevel == 1 && rhsPointerLevel == 1) && (child->children[0]->typeSpecifier != child->children[1]->typeSpecifier)) && (child->children[1]->typeSpecifier != 9))
                    {
                        raiseError("Incompatible pointer types in assignment — LHS is of type '" + typeName(child->children[0]->typeSpecifier) + "*', RHS is of type '" + typeName(child->children[1]->typeSpecifier) + "*");
                    }
                    else if (rhsPointerLevel != lhsPointerLevel)
                    {
                        raiseError("Error: Invalid pointer initialization for '" + varName + "'\n");
                    }
                    else
                    {
                        if (size == 2 && declInfo.typeSpecifier == 20)
                        {
                            if (structInitializerCheck(helper, child->children[1]))
                            {
                                insertSymbol(varName, identifierNode);
                                setNodeAttributes(identifierNode, 0);
                            }
                        }
                        else if (size == 2 && isTypeCompatible(declInfo.typeSpecifier, child->children[1]->typeSpecifier, "="))
                        {
                            if (declInfo.typeSpecifier != child->children[1]->typeSpecifier)
                            {
                                string temp = irGen.newTemp();
                                irGen.emit(TACOp::TYPECAST, temp, typeCastInfo(declInfo.typeSpecifier, child->children[1]->typeSpecifier), child->children[1]->tacResult);
                                child->children[1]->tacResult = temp;
                            }
                            setNodeAttributes(identifierNode, 0);
                            insertSymbol(varName, identifierNode);

                            if (child->children[1]->trueList || child->children[1]->falseList)
                            {
                                Backpatch::backpatch(child->children[1]->trueList, to_string(irGen.currentInstrIndex));
                                Backpatch::backpatch(child->children[1]->falseList, to_string(irGen.currentInstrIndex + 1));
                                irGen.emit(TACOp::ASSIGN, varName, "1", nullopt);
                                irGen.emit(TACOp::ASSIGN, varName, "0", nullopt);
                            }
                            else
                            {
                                irGen.emit(TACOp::ASSIGN, varName, child->children[1]->tacResult, nullopt);
                            }
                        }
                        else
                        {
                            raiseError("Type mismatch in assignment: LHS is of type '" + typeName(declInfo.typeSpecifier) + "' and RHS is of type '" + typeName(child->children[1]->typeSpecifier) + "'");
                        }
                    }
                }
                identifierNode->offset = offsetStack.top();
                offsetStack.top() += findOffset(declInfo.typeSpecifier, varName);
            }
        }
    }
}

void addFunction(TreeNode *declSpec, TreeNode *decl)
{
    DeclaratorInfo declInfo = isValidVariableDeclaration(declSpec->children, true);
    if (declInfo.isValid)
    {
        string funcName = decl->children[0]->value;
        irGen.emit(TACOp::LABEL, funcName, nullopt, nullopt);
        insertSymbol(funcName, decl->children[0]);
        TreeNode *funcNode = decl->children[0];
        funcNode->typeSpecifier = declInfo.typeSpecifier;
        expectedReturnType = declInfo.typeSpecifier;
        funcNode->isConst = declInfo.isConst;
        funcNode->isStatic = declInfo.isStatic;
        funcNode->typeCategory = 3;
        enterScope();
        if (decl->children.size() > 1 && decl->children[1]->type == NODE_PARAMETER_LIST)
        {
            for (auto param : decl->children[1]->children)
            {
                if (param->type == NODE_PARAMETER_DECLARATION)
                {

                    string varName = param->children[1]->value;

                    bool isDuplicate = false;
                    for (const auto &entry : currentTable->symbolTable)
                    {
                        if (entry.first == varName)
                        {
                            raiseError("Duplicate declaration of parameter '" + varName + "'");
                            isDuplicate = true;
                            break;
                        }
                    }
                    if (isDuplicate)
                        continue;

                    DeclaratorInfo paramInfo = isValidVariableDeclaration(param->children[0]->children, false);
                    if (paramInfo.isValid)
                    {
                        TreeNode *varNode = param->children[1];
                        varNode->typeCategory = 9;
                        varNode->typeSpecifier = paramInfo.typeSpecifier;
                        varNode->isConst = paramInfo.isConst;
                        varNode->isStatic = paramInfo.isStatic;
                        funcNode->paramTypes.push_back(varNode->typeSpecifier);
                        funcNode->paramCount++;
                        insertSymbol(varName, varNode);
                    }
                }
            }
        }
    }
    else
    {
        raiseError("Invalid function declaration for '" + decl->children[0]->value + "'");
    }
}

stack<bool> inSwitch;
stack<int> switchStack;
int switch_type;
stack<unordered_set<string>> case_id;
#endif
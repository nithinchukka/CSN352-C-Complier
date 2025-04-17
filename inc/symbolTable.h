#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#include <bits/stdc++.h>
#include "treeNode.h"
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
    oth
};

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
        return "goto";
    case TACOp::IF_EQ:
        return "if ==";
    case TACOp::IF_NE:
        return "if !=";
    case TACOp::TYPECAST:
        return "cast";
    case TACOp::CALL:
        return "call";
    case TACOp::PRINT:
        return "print";
    case TACOp::INDEX:
        return "index";
    case TACOp::ARR_INDEX:
        return "arr_index";
    case TACOp::RETURN:
        return "return";
    case TACOp::LABEL:
        return "label";
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
                str = "goto " + result;
            else
                str = "goto " + result + " if " + *operand1 + " " + opToStr(op) + " " + *operand2;
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
            str = "goto " + result;
            break;
        case TACOp::IF_EQ:
            str = "if " + *operand1 + " == " + *operand2 + " goto " + result;
            break;
        case TACOp::IF_NE:
            str = "if " + *operand1 + " != " + *operand2 + " goto " + result;
            break;
        case TACOp::RETURN:
            str = "return " + result;
            break;
        case TACOp::CALL:
            str = result + " = call " + *operand1 + "(" + (operand2 ? *operand2 : "") + ")";
            break;
        case TACOp::CALL2:
            str = "call " + *operand1 + "(" + (operand2 ? *operand2 : "") + ")";
            break;
        case TACOp::TYPECAST:
            str = result + " = " + *operand1 + "(" + *operand2 + ")";
            break;
        case TACOp::oth:
            str = result + " = " + *operand1 + " " + *operand2;
            break;
        default:
            str = "Unknown";
            break;
        }
        return str;
    }
};

struct CodeGenerator
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

CodeGenerator codeGen;

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
            if (idx >= 0 && idx < codeGen.tacCode.size())
            {
                codeGen.tacCode[idx].result = label;
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
        cerr << "Symbol " << symbol << " not found in table" << endl;
    return nullptr;
}


void enterScope()
{
    Table *newTable = new Table();
    newTable->parent = currentTable;
    currentTable = newTable;
    tableStack.push(newTable);
    offsetStack.push(0);
    allTables.push_back(newTable);
}

void exitScope()
{
    if (currentTable->parent == nullptr)
    {
        cerr << "Cannot exit global scope" << endl;
        return;
    }
    Table *temp = currentTable;
    currentTable = currentTable->parent;
    currentTable->totalSize = offsetStack.top();
    tableStack.pop();
    offsetStack.pop();
}

void insertSymbol(string symbol, TreeNode *node)
{
    for (const auto &entry : currentTable->symbolTable)
    {
        if (entry.first == symbol)
        {
            cerr << "Symbol " << symbol << " already exists in table" << endl;
            return;
        }
    }
    currentTable->symbolTable.emplace_back(symbol, node);
}

void printAllTables()
{
    int tblId = 0;
    for (auto &tbl : allTables)
    {
        cout << "Tbl " << tblId++ << " (Table Size): " << tbl->totalSize << "\n";
        // cout << "-------------------------------------------------------------------------------------------------------\n";
        // cout << left << setw(12) << "Id" << setw(12) << "TypeCat" << setw(12) << "TypeSpec"
        //      << setw(12) << "StorCls" << setw(8) << "Params" << setw(8) << "Const" << setw(8) << "Static"
        //      << setw(8) << "Volat" << setw(12) << "PtrLvl" << setw(12) << "SymTabSize" << "\n";
        // cout << "------------------------------------------------------------------------------------------------------\n";
        cout << "-------------------------------------------\n";
        cout << left << setw(12) << "Id" << setw(12) << "TypeCat" << setw(12) << "TypeSpec"
             << setw(12) << "Offset" << "\n";
        cout << "------------------------------------------\n";

        for (const auto &entry : tbl->symbolTable)
        {
            TreeNode *node = entry.second;
            cout << left << setw(12) << entry.first
                 << setw(12) << node->typeCategory
                 << setw(12) << node->typeSpecifier
                 << setw(12) << node->offset
                 << "\n";
        }

        cout << "-----------------------------------------\n\n";
    }
}

struct DeclaratorInfo
{
    int typeCategory = -1;  // var = 0, func = 1, struct = 2, enum = 3, class = 4
    int storageClass = -1;  // -1: none, 0: extern, 1: static, 2: auto, 3: register
    int typeSpecifier = -1; // -1: none, void : -1: char : 1, short : 2, 3: int, 4: bool, 5: long, 6: float, 7: double
    bool isConst = false;
    bool isStatic = false;
    bool isVolatile = false;
    bool isUnsigned = false;
    bool hasLong = false;
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
                cerr << "Error: Too few arguments\n";
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
                cerr << "Error: Unknown format specifier '%" << *ptr << "'\n";
                return false;
            }

            if (argTypeList[argIndex] != expectedType1 && argTypeList[argIndex] != expectedType2)
            {
                cerr << "Error: Type mismatch for '%" << *ptr << "'\n";
                return false;
            }
            argIndex++;
        }
        ptr++;
    }

    if (argIndex < argTypeList.size())
    {
        cerr << "Error: Too many arguments\n";
        return false;
    }

    return true;
}

DeclaratorInfo isValidVariableDeclaration(vector<TreeNode *> &nodes, bool isFunction = false)
{
    DeclaratorInfo declInfo;
    unordered_map<string, int> storageClasses = {
        {"extern", 0}, {"static", 1}, {"auto", 2}, {"register", 3}};
    unordered_map<string, int> baseTypes = {
        {"void", 0}, {"char", 1}, {"short", 2}, {"int", 3}, {"long", 5}, {"float", 6}, {"double", 7}};
    unordered_set<string> typeModifiers = {"signed", "unsigned"};
    unordered_set<string> qualifiers = {"const", "volatile"};

    int storageClassCount = 0, typeSpecifierCount = 0, typeModifierCount = 0, qualifierCount = 0;
    bool hasSignedOrUnsigned = false;

    for (const auto &node : nodes)
    {
        string val = node->valueToString();

        if (node->type == NODE_STORAGE_CLASS_SPECIFIER)
        {
            if (!storageClasses.count(val))
                return {};
            declInfo.storageClass = storageClasses[val];
            if (val == "static")
                declInfo.isStatic = true;
            storageClassCount++;
            if (storageClassCount > 1)
                return {};
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
            else if (typeModifiers.count(val))
            {
                typeModifierCount++;
                if (val == "unsigned")
                    declInfo.isUnsigned = true;
                if (val == "signed")
                    hasSignedOrUnsigned = true;
            }
            else
            {
                return {};
            }
        }
        else if (node->type == NODE_TYPE_QUALIFIER)
        {
            if (!qualifiers.count(val))
                return {};
            if (val == "const")
                declInfo.isConst = true;
            if (val == "volatile")
                declInfo.isVolatile = true;
            qualifierCount++;
        }
        else
        {
            return {};
        }
    }

    if (typeSpecifierCount == 0)
        return {};
    if (typeModifierCount > 2)
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
        cerr << "Error: No struct definition found for type checking" << endl;
        return false;
    }

    size_t expectedSize = identifierNode->symbolTable.size();
    size_t actualSize = initializerList->children.size();

    if (expectedSize != actualSize)
    {
        cerr << "Error: Struct initialization mismatch - expected "
             << expectedSize << " values, got " << actualSize << endl;
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
            cerr << "Error: Type mismatch at position " << i + 1
                 << " (member '" << memberPair.first << "'): expected "
                 << expectedType
                 << ", got " << actualType << endl;
            return false;
        }
        else
        {
            string temp = codeGen.newTemp();
            codeGen.emit(TACOp::TYPECAST, temp, typeCastInfo(expectedType, actualType), initNode->tacResult);
            initNode->tacResult = temp;
        }

        if (memberNode->isConst)
        {
            cerr << "Error: Cannot initialize const member '"
                 << memberPair.first << "' in struct" << endl;
            return false;
        }

        if (memberNode->pointerLevel > 0)
        {
            cerr << "Error: Pointer initialization not supported in struct initializer for '"
                 << memberPair.first << "'" << endl;
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
            codeGen.emit(TACOp::ASSIGN, indexedName, child->tacResult, nullopt);
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

bool checkInitializerLevel(TreeNode *initList, int baseType, vector<int> &dimensions, int level)
{
    int vecSize = dimensions.size();

    if (baseType != 1 && baseType != 3)
    {
        cerr << "Invalid declaration for an array" << endl;
        return false;
    }

    for (int i = 1; i < vecSize; i++)
    {
        if (dimensions[i] == -1)
        {
            cerr << "Invalid Declaration: dimension " << i << " cannot be unspecified" << endl;
            return false;
        }
    }

    if (level >= vecSize)
    {
        cerr << "Too many nesting levels at level " << level << endl;
        return false;
    }

    if (level == 0 && dimensions[0] == -1)
    {
        dimensions[0] = initList->children.size();
    }

    if (initList->children.size() > dimensions[level])
    {
        cerr << "Dimension mismatch at level " << level << ": expected at most "
             << dimensions[level] << ", got " << initList->children.size() << endl;
        return false;
    }

    if (level == vecSize - 1)
    {
        for (TreeNode *child : initList->children)
        {
            if (child->typeSpecifier != baseType)
            {
                cerr << "Type mismatch at level " << level << ": expected "
                     << baseType << ", got " << child->typeSpecifier << endl;
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
                cerr << "Expected nested initializer list at level " << level << endl;
                return false;
            }
            if (!checkInitializerLevel(child, baseType, dimensions, level + 1))
            {
                return false;
            }
        }
    }
    GenerateTAC(initList, dimensions, 0, "arr");
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
                dimensions.push_back(stoi(current->children[1]->valueToString()));
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
            helper = lookupSymbol(helper->valueToString());
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
                node->storageClass = declInfo.storageClass;
                node->typeSpecifier = declInfo.typeSpecifier;
                node->isConst = declInfo.isConst;
                node->isStatic = declInfo.isStatic;
                node->isVolatile = declInfo.isVolatile;
                node->isUnsigned = declInfo.isUnsigned;
                node->symbolTable = helper->symbolTable;
            };
            auto checkDuplicate = [&](const string &name)
            {
                for (const auto &entry : currentTable->symbolTable)
                {
                    if (entry.first == name)
                    {
                        cerr << "Error: Duplicate declaration of '" << name << "'\n";
                        return true;
                    }
                }
                return false;
            };

            if (firstChild->type == ARRAY)
            {
                vector<int> dimensions = findArrayDimensions(firstChild);
                while (identifierNode && identifierNode->type == ARRAY)
                {
                    if (identifierNode->children.empty())
                        break;
                    identifierNode = identifierNode->children[0];
                }
                varName = identifierNode->valueToString();
                if (checkDuplicate(varName))
                    continue;

                int size = child->children.size();
                if (size == 1 || size == 2)
                {
                    bool validDims = all_of(dimensions.begin(), dimensions.end(), [](int d)
                                            { return d != -1; });
                    if (!validDims)
                    {
                        cerr << "Invalid declaration dimension cannot be empty\n";
                        continue;
                    }
                    if (size == 2 && !checkInitializerLevel(child->children[1], declInfo.typeSpecifier, dimensions, 0))
                    {
                        cerr << "Error\n";
                        continue;
                    }
                    setNodeAttributes(identifierNode, 2);
                    identifierNode->dimensions = dimensions;
                    insertSymbol(varName, identifierNode);
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
                varName = identifierNode->valueToString();

                if (identifierNode->type == ARRAY)
                {
                    vector<int> dimensions = findArrayDimensions(identifierNode);
                    varName = identifierNode->children[0]->valueToString();
                    if (checkDuplicate(varName))
                        continue;

                    int size = child->children.size();
                    if (size == 1 || size == 2)
                    {
                        bool validDims = all_of(dimensions.begin(), dimensions.end(), [](int d)
                                                { return d != -1; });
                        if (!validDims)
                        {
                            cerr << "Invalid declaration dimension cannot be empty\n";
                            continue;
                        }
                        if (size == 2 && !checkInitializerLevel(child->children[1], declInfo.typeSpecifier, dimensions, pointerDepth))
                        {
                            cerr << "Error: Invalid initializer for array of pointers '" << varName << "'\n";
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
                        int lhsPointerlevel = child->children[0]->pointerLevel;
                        int rhsPointerlevel = child->children[1]->pointerLevel;
                        if (lhsPointerlevel != rhsPointerlevel && !(declInfo.typeSpecifier == 3 && child->children[1]->typeCategory == 2))
                        {
                            cerr << "Error: Invalid pointer initialization for '" << varName << "'\n";
                        }
                        else
                        {
                            if (declInfo.typeSpecifier == 3 && child->children[1]->typeCategory == 2)
                            {
                                setNodeAttributes(identifierNode, 1, pointerDepth);
                                insertSymbol(varName, identifierNode);
                                codeGen.emit(TACOp::ASSIGN, varName, child->children[1]->tacResult, nullopt);
                            }
                            else if (isTypeCompatible(declInfo.typeSpecifier, child->children[1]->typeSpecifier, "="))
                            {
                                if (declInfo.typeSpecifier != child->children[1]->typeSpecifier)
                                {
                                    string temp = codeGen.newTemp();
                                    codeGen.emit(TACOp::TYPECAST, temp, typeCastInfo(declInfo.typeSpecifier, child->children[1]->typeSpecifier), child->children[1]->tacResult);
                                    child->children[1]->tacResult = temp;
                                }
                                setNodeAttributes(identifierNode, 1, pointerDepth);
                                insertSymbol(varName, identifierNode);
                                codeGen.emit(TACOp::ASSIGN, varName, child->children[1]->tacResult, nullopt);
                            }
                        }
                    }
                }
            }
            else
            {
                varName = firstChild->valueToString();
                if (checkDuplicate(varName))
                    continue;
                int size = child->children.size();
                if (size == 1)
                {
                    if (declInfo.isConst)
                    {
                        cerr << "Error: Const variable '" << varName << "' must be initialized\n";
                        continue;
                    }
                    setNodeAttributes(identifierNode, 0);
                    insertSymbol(varName, identifierNode);
                }
                else
                {
                    int lhsPointerLevel = child->children[0]->pointerLevel;
                    int rhsPointerLevel = child->children[1]->pointerLevel;
                    if (rhsPointerLevel != lhsPointerLevel)
                    {
                        cerr << "Error: Invalid pointer initialization for '" << varName << "'\n";
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
                                string temp = codeGen.newTemp();
                                codeGen.emit(TACOp::TYPECAST, temp, typeCastInfo(declInfo.typeSpecifier, child->children[1]->typeSpecifier), child->children[1]->tacResult);
                                child->children[1]->tacResult = temp;
                            }
                            setNodeAttributes(identifierNode, 0);
                            insertSymbol(varName, identifierNode);
                            codeGen.emit(TACOp::ASSIGN, varName, child->children[1]->tacResult, nullopt);
                        }
                    }
                }
            }
        }
    }
}

stack<bool> inSwitch;
stack<int> switchStack;

#endif
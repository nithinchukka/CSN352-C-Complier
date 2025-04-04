#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#include <bits/stdc++.h>
#include "ast.h"
using namespace std;
extern unordered_set<string> classOrStructOrUnion;

struct Table
{
    vector<pair<string,TreeNode*>> symbolTable;
    Table *parent;
};

stack<Table *> tableStack;
stack<int> offsetStack;
Table *currentTable;
vector<Table *> allTables;


TreeNode* lookupSymbol(string symbol)
{
    Table *temp = currentTable;
    while (temp != nullptr)
    {
        for (const auto &entry : temp->symbolTable)
        {
            if (entry.first == symbol)
            {
                return entry.second;
            }
        }
        temp = temp->parent;
    }
    cout << "Symbol " << symbol << " not found in table" << endl;
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
        cout << "Cannot exit global scope" << endl;
        return;
    }
    Table *temp = currentTable;
    currentTable = currentTable->parent;
    tableStack.pop();
    offsetStack.pop();
    // delete temp;
}

void insertSymbol(string symbol, TreeNode* node)
{
    for (const auto &entry : currentTable->symbolTable)
    {
        if (entry.first == symbol)
        {
            cout << "Symbol " << symbol << " already exists in table" << endl;
            return;
        }
    }
    currentTable->symbolTable.emplace_back(symbol, node);
}


void printAllTables() {
    int tblId = 0;
    for (auto &tbl : allTables) {
        cout << "Tbl " << tblId++ << " (Scope Lvl):\n";
        cout << "-------------------------------------------------------------------------------------------------------\n";
        cout << left << setw(12) << "Id" << setw(12) << "TypeCat" << setw(12) << "TypeSpec" 
             << setw(12) << "StorCls" << setw(8) << "Params" << setw(8) << "Const" << setw(8) << "Static" 
             << setw(8) << "Volat" << setw(12) << "PtrLvl"  << setw(12) << "SymTabSize" << "\n";
        cout << "------------------------------------------------------------------------------------------------------\n";
        
        for (const auto &entry : tbl->symbolTable) {
            TreeNode *node = entry.second;
            cout << left << setw(12) << entry.first
                 << setw(12) << node->typeCategory
                 << setw(12) << node->typeSpecifier
                 << setw(12) << node->storageClass
                 << setw(8) << node->paramCount
                 << setw(8) << (node->isConst ? "Y" : "N")
                 << setw(8) << (node->isStatic ? "Y" : "N")
                 << setw(8) << (node->isVolatile ? "Y" : "N")
                 << setw(12) << node->pointerLevel
                 << setw(12) << node->symbolTable.size()
                 << "\n";
        }
        
        cout << "------------------------------------------------------------------------------------\n\n";
    }
}


struct DeclaratorInfo {
    int typeCategory = -1; // var = 0, func = 1, struct = 2, enum = 3, class = 4
    int storageClass = -1; // -1: none, 0: extern, 1: static, 2: auto, 3: register
    int typeSpecifier = -1; // -1: none, void : -1: char : 1, short : 2, 3: int, 4: bool, 5: long, 6: float, 7: double
    bool isConst = false;
    bool isStatic = false;
    bool isVolatile = false;
    bool isUnsigned = false;
    bool hasLong = false;
    bool isValid = false;
    bool isCustomType = false; // true if it's a class, struct, or union
};

bool isValidCast(int toType, int fromType) {
    if (toType >= 1 && toType <= 6 && fromType >= 1 && fromType <= 6)
        return true;
    return false;
}



bool checkFormatSpecifiers(string formatString, vector<int> argTypeList) {
    int argIndex = 0;
    const char* ptr = formatString.c_str();
    while (*ptr) {
        if (*ptr == '%') {
            ptr++;
            if (*ptr == '\0') break; // Avoid accessing out-of-bounds memory

            if (*ptr == '%') {  // Literal '%%'
                ptr++;
                continue;
            }

            if (argIndex >= argTypeList.size()) {
                cerr << "Error: Too few arguments\n";
                return false;
            }

            int expectedType1 = -1, expectedType2 = -1;
            switch (*ptr) {
                case 'd': expectedType1 = 2, expectedType2 = 3; break;  // int or long
                case 'f': expectedType1 = 5, expectedType2 = 6; break;  // float or double
                case 's': expectedType1 = 8; break;  // string
                case 'c': expectedType1 = 1; break;  // char
                default: 
                    cerr << "Error: Unknown format specifier '%" << *ptr << "'\n";
                    return false;
            }

            if (argTypeList[argIndex] != expectedType1 && argTypeList[argIndex] != expectedType2) {
                cerr << "Error: Type mismatch for '%" << *ptr << "'\n";
                return false;
            }
            argIndex++;
        }
        ptr++;
    }

    if (argIndex < argTypeList.size()) {
        cerr << "Error: Too many arguments\n";
        return false;
    }

    return true;
}

DeclaratorInfo isValidVariableDeclaration(vector<TreeNode*>& nodes, bool isFunction = false) {
    DeclaratorInfo declInfo;
    unordered_map<string, int> storageClasses = {
        {"extern", 0}, {"static", 1}, {"auto", 2}, {"register", 3}
    };
    unordered_map<string, int> baseTypes = {
        {"void", 0}, {"char", 1}, {"short", 2}, {"int", 3}, {"long", 5}, {"float", 6}, {"double", 7}
    };
    unordered_set<string> typeModifiers = {"signed", "unsigned"};
    unordered_set<string> qualifiers = {"const", "volatile"};

    int storageClassCount = 0, typeSpecifierCount = 0, typeModifierCount = 0, qualifierCount = 0;
    bool hasSignedOrUnsigned = false;

    for (const auto& node : nodes) {
        string val = node->valueToString();
        
        if (node->type == NODE_STORAGE_CLASS_SPECIFIER) {
            if (!storageClasses.count(val)) return {};
            declInfo.storageClass = storageClasses[val];
            if (val == "static") declInfo.isStatic = true;
            storageClassCount++;
            if (storageClassCount > 1) return {};
        } else if (node->type == NODE_TYPE_SPECIFIER) {
            if (classOrStructOrUnion.count(val)) {
                if (declInfo.typeSpecifier != -1) return {};
                declInfo.typeCategory = 4;
                declInfo.typeSpecifier = 20;
                declInfo.isCustomType = true;
                typeSpecifierCount++;
            }
            else if (baseTypes.count(val)) {
                if (declInfo.typeSpecifier != -1) return {};
                declInfo.typeSpecifier = baseTypes[val];
                typeSpecifierCount++;
            }
            else if (typeModifiers.count(val)) {
                typeModifierCount++;
                if (val == "unsigned") declInfo.isUnsigned = true;
                if (val == "signed") hasSignedOrUnsigned = true;
            } else {
                return {};
            }
        } else if (node->type == NODE_TYPE_QUALIFIER) {
            if (!qualifiers.count(val)) return {};
            if (val == "const") declInfo.isConst = true;
            if (val == "volatile") declInfo.isVolatile = true;
            qualifierCount++;
        } else {
            return {};
        }
    }

    if (typeSpecifierCount == 0) return {};
    if (typeModifierCount > 2) return {};

    if (!isFunction && declInfo.typeSpecifier == 0) return {};
    declInfo.isValid = true;
    return declInfo;
}


bool isTypeCompatible(int lhstype, int rhstype, string op, bool lhsIsConst = false) {
    // Define type categories by storage class numbers
    unordered_set<int> integerTypes = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11}; // char to unsigned long long
    unordered_set<int> floatingTypes = {12, 13, 14}; // float, double, long double
    unordered_set<int> numericTypes = integerTypes;
    numericTypes.insert(floatingTypes.begin(), floatingTypes.end());
    // Check if types are numeric or integer
    bool lhsIsNumeric = numericTypes.count(lhstype);
    bool rhsIsNumeric = numericTypes.count(rhstype);
    bool lhsIsInteger = integerTypes.count(lhstype);
    bool rhsIsInteger = integerTypes.count(rhstype);
    // Validate type numbers (1-14 are valid)
    if (lhstype < 1 || rhstype < 1) {
        return false; // Invalid storage class
    }
    // Arithmetic operators
    if (op == "+" || op == "-" || op == "*" || op == "/") {
        return lhsIsNumeric && rhsIsNumeric; // Both must be numeric
    }
    if (op == "%") {
        return lhsIsInteger && rhsIsInteger; // Both must be integers
    }
    // Comparison operators
    if (op == "==" || op == "!=" || op == "<" || op == ">" || op == "<=" || op == ">=") {
        return lhsIsNumeric && rhsIsNumeric; // Both must be numeric
    }
    // Assignment operator
    if (op == "=") {
        if (lhsIsConst) return false; // Cannot assign to const
        if (lhstype == rhstype) return true; // Exact match
        if (lhsIsNumeric && rhsIsNumeric){
            if(rhstype>lhstype){
                return false;
            }
            else{
                return true;
            }
        } // Numeric conversion
        return false;
    }
    // Compound arithmetic operators
    if (op == "+=" || op == "-=" || op == "*=" || op == "/=") {
        if (lhsIsConst) return false; // Cannot modify const
        return lhsIsNumeric && rhsIsNumeric; // Both must be numeric
    }
    // Compound bitwise operators
    if (op == "^=" || op == "&=" || op == "|=") {
        if (lhsIsConst) return false; // Cannot modify const
        return lhsIsInteger && rhsIsInteger; // Both must be integers
    }
    // Shift operators
    if (op == "<<=" || op == ">>=") {
        if (lhsIsConst) return false; // Cannot modify const
        return lhsIsInteger && rhsIsInteger; // Both must be integers
    }
    // Unknown operator
    return false;
}

bool checkInitializerLevel(TreeNode* initList, int baseType, vector<int>& dimensions, int level) {
    int vecSize = dimensions.size();

    if (baseType != 1 && baseType != 3) {
        cerr << "Invalid declaration for an array" << endl;
        return false;
    }

    // Ensure all dimensions except the first are specified
    for (int i = 1; i < vecSize; i++) {
        if (dimensions[i] == -1) { // Use -1 instead of 0 for unspecified dimensions
            cerr << "Invalid Declaration: dimension " << i << " cannot be unspecified" << endl;
            return false;
        }
    }

    // Ensure level doesn't exceed defined dimensions
    if (level >= vecSize) {
        cerr << "Too many nesting levels at level " << level << endl;
        return false;
    }

    // Infer first dimension if unspecified
    if (level == 0 && dimensions[0] == -1) {
        dimensions[0] = initList->children.size();  
    }

    // Check that the initializer list does not exceed the expected dimension
    if (initList->children.size() > dimensions[level]) {
        cerr << "Dimension mismatch at level " << level << ": expected at most " 
             << dimensions[level] << ", got " << initList->children.size() << endl;
        return false;
    }

    if (level == vecSize - 1) {
        // Innermost level: check scalar types
        for (TreeNode* child : initList->children) {
            if (child->type != NODE_UNARY_EXPRESSION) {
                cerr << "Expected scalar at level " << level << ", got " << child->type << endl;
                return false;
            }
            // Check type correctness
            if (child->typeSpecifier != baseType) {
                cerr << "Type mismatch at level " << level << ": expected " 
                     << baseType << ", got " << child->typeSpecifier << endl;
                return false;
            }
        }
    } else {
        // Recurse for nested lists, check all children
        for (TreeNode* child : initList->children) {
            if (child->type != NODE_INITIALIZER_LIST) {
                cerr << "Expected nested initializer list at level " << level << endl;
                return false;
            }
            if (!checkInitializerLevel(child, baseType, dimensions, level + 1)) {
                return false;
            }
        }
    }
    
    return true;
}


vector<int> findArrayDimensions(TreeNode* arr) {
    if (!arr || arr->children.empty()) 
        return {};

    vector<int> dimensions;
    TreeNode* current = arr;

    while (current) {
        if (current->type == ARRAY) {
            if (current->children.size() > 1 && current->children[1] &&
                current->children[1]->type == INTEGER_LITERAL) {
                dimensions.push_back(stoi(current->children[1]->valueToString()));
            } else {
                dimensions.push_back(-1);
            }
        }
        current = (!current->children.empty()) ? current->children[0] : nullptr;
    }
    reverse(dimensions.begin(), dimensions.end());
    return dimensions;
}


bool checkInvalidReturn(TreeNode* node, int returnType = -1) {
    if (!node) return false;

    if (node->type == NODE_JUMP_STATEMENT) {
        if (node->children.size() >= 1 && node->children[0]->type == NODE_KEYWORD &&
            node->children[0]->valueToString() == "return") {
            
            if (returnType == 0) {
                if (node->children.size() > 1) {
                    cout << "Error: Return statement with a value in a void function.\n";
                    return true;
                }
                return false;
            }

            if (returnType != 0) {
                if (node->children.size() == 1) {
                    cout << "Error: Return statement without an expression.\n";
                    return true;
                }

                TreeNode* returnExpr = node->children[1];
                if (!isTypeCompatible(returnType, returnExpr->typeSpecifier, "=")) {
                    cout << "Error: Type mismatch in return statement.\n";
                    return true;
                }
            }
        }
    }

    for (TreeNode* child : node->children) {
        if (checkInvalidReturn(child, returnType)) return true;
    }

    return false;
}


bool structInitializerCheck(TreeNode* identifierNode, TreeNode* initializerList) {
    if (identifierNode->symbolTable.empty()) {
        cerr << "Error: No struct definition found for type checking" << endl;
        return false;
    }

    size_t expectedSize = identifierNode->symbolTable.size();
    size_t actualSize = initializerList->children.size();

    if (expectedSize != actualSize) {
        cerr << "Error: Struct initialization mismatch - expected " 
             << expectedSize << " values, got " << actualSize << endl;
        return false;
    }

    for (size_t i = 0; i < expectedSize; i++) {
        const auto& memberPair = identifierNode->symbolTable[i];
        TreeNode* memberNode = memberPair.second;
        TreeNode* initNode = initializerList->children[i];

        int expectedType = memberNode->typeSpecifier;
        int actualType = initNode->typeSpecifier;

        bool typesCompatible = isTypeCompatible(expectedType, actualType, "=");
        
        if (!typesCompatible) {
            cerr << "Error: Type mismatch at position " << i + 1 
                 << " (member '" << memberPair.first << "'): expected " 
                 << expectedType
                 << ", got " << actualType << endl;
            return false;
        }

        if (memberNode->isConst) {
            cerr << "Error: Cannot initialize const member '" 
                 << memberPair.first << "' in struct" << endl;
            return false;
        }

        if (memberNode->pointerLevel > 0) {
            cerr << "Error: Pointer initialization not supported in struct initializer for '" 
                 << memberPair.first << "'" << endl;
            return false;
        }
    }

    return true;
}

vector<int> typeExtract(TreeNode* node){
    vector<int> ans;
    for(auto child:node->children){
        ans.push_back(child->typeSpecifier);
    }
    return ans;
}

int inLoop = 0;
bool inFunc = false;
bool insideClass = false;
int accessSpecifier = 0;

void addDeclarators(TreeNode* specifier, TreeNode* list)
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
            // Helper function to set common node attributes
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
            // Check for duplicate declaration
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

            if (firstChild->type == ARRAY) // Pointer-to-array (e.g., int (*arr)[3])
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
                        cout << "Error\n";
                        continue;
                    }
                    setNodeAttributes(identifierNode, 2); // Array
                    identifierNode->dimensions = dimensions;
                    insertSymbol(varName, identifierNode);
                }
            }
            else if (firstChild->type == NODE_POINTER) // Pointers, including array of pointers
            {
                int pointerDepth = 0;
                while (identifierNode && identifierNode->type == NODE_POINTER)
                {
                    pointerDepth++;
                    if (identifierNode->children.empty())
                        break;
                    identifierNode = identifierNode->children[0];
                }
                for (int i = 0; i < pointerDepth; i++)
                {
                    declInfo.typeSpecifier *= 10;
                }
                varName = identifierNode->valueToString();

                if (identifierNode->type == ARRAY) // Array of pointers (e.g., int *arr[3])
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
                else // Regular pointer (e.g., int *p)
                {
                    if (checkDuplicate(varName))
                        continue;
                    int size = child->children.size();
    
                    cout << declInfo.typeSpecifier<< endl;
                    cout << *child->children[1] << endl;
                    cout << child->children[1]->typeSpecifier << endl;
                    if(size == 1){
                        setNodeAttributes(identifierNode, 1, pointerDepth);
                        insertSymbol(varName, identifierNode);
                    }
                    else if(declInfo.typeSpecifier==30 && child->children[1]->typeCategory==2){
                        setNodeAttributes(identifierNode, 1, pointerDepth);
                        insertSymbol(varName, identifierNode);
                    }
                    else if (isTypeCompatible(declInfo.typeSpecifier, child->children[1]->typeSpecifier, "="))
                    {
                        setNodeAttributes(identifierNode, 1, pointerDepth);
                        insertSymbol(varName, identifierNode);
                    }
                    else
                    {
                        cerr << "Error: Invalid pointer " << (size == 2 ? "initialization" : "declarator syntax") << " for '" << varName << "'\n";
                    }
                }
            }
            else // Regular variable (e.g., int x)
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
                else if (size == 2 && declInfo.typeSpecifier == 20)
                {
                    if (structInitializerCheck(helper, child->children[1]))
                    {
                        insertSymbol(varName, identifierNode);
                        setNodeAttributes(identifierNode, 0);
                    }
                }
                else if (size == 2 && isTypeCompatible(declInfo.typeSpecifier, child->children[1]->typeSpecifier, "="))
                {
                    setNodeAttributes(identifierNode, 0);
                    insertSymbol(varName, identifierNode);
                }
                else
                {
                    cerr << "Error: " << (size == 2 ? "Type mismatch in initialization" : "Invalid declarator syntax") << " for '" << varName << "'\n";
                }
            }
        }
    }
}
stack<bool> inSwitch;



#endif
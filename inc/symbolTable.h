#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#include <bits/stdc++.h>
#include "ast.h"
using namespace std;

struct Table
{
    vector<pair<string,TreeNode*>> symbolTable;
    Table *parent;
};

stack<Table *> tableStack;
stack<int> offsetStack;
Table *currentTable;
vector<Table *> allTables;

int getStorageClass(const std::string& type) {
    if (type == "char") return 1;
    if (type == "short") return 2;
    if (type == "int") return 3;
    if (type == "long") return 4;
    if (type == "unsigned char") return 5;
    if (type == "unsigned short") return 6;
    if (type == "unsigned int") return 7;
    if (type == "unsigned long") return 8;
    if (type == "bool") return 9;
    if (type == "long long") return 10;
    if (type == "unsigned long long") return 11;
    if (type == "float") return 12;
    if (type == "double") return 13;
    if (type == "long double") return 14;
    return 100; // Invalid type
}


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


// void addDeclaratorsToSymbolTable(TreeNode *a, TreeNode *b)
// {
//     string typeSpecifiers;
//     if (a->children[0]->type == NODE_STRUCT_OR_UNION_SPECIFIER || a->children[0]->type == NODE_CLASS_SPECIFIER)
//     {
//         TreeNode *specifier = a->children[0];
//         if (specifier->children[1]->type != NODE_IDENTIFIER)
//             typeSpecifiers = specifier->children[0]->valueToString();
//         else
//             typeSpecifiers = specifier->children[1]->valueToString();
//     }
//     else

//     {
//         for (TreeNode *specifier : a->children)
//         {
//             if (specifier)
//             {
//                 if (!typeSpecifiers.empty())
//                 {
//                     typeSpecifiers += " ";
//                 }
//                 typeSpecifiers += specifier->valueToString();
//             }
//         }
//     }

//     for (TreeNode *declarator : b->children)
//     {
//         if (!declarator || declarator->children.empty())
//             continue;

//         string varName;
//         string varType = typeSpecifiers;
//         int pointerCount = 0;
//         vector<string> dimensions;

//         TreeNode *current = declarator;

//         while (current)
//         {
//             string nodeType = TreeNode::nodeTypeToString(current->type);

//             if (nodeType == "DECLARATOR")
//             {
//                 if (!current->children.empty())
//                 {
//                     current = current->children[0];
//                     continue;
//                 }
//             }
//             else if (nodeType == "POINTER")
//             {
//                 pointerCount++;
//             }
//             else if (nodeType == "ARRAY")
//             {
//                 dimensions.push_back(current->children[1] ? current->children[1]->valueToString() : "");
//             }
//             else
//             {
//                 varName = current->valueToString();
//             }

//             current = current->children.empty() ? nullptr : current->children[0];
//         }

//         varType.append(pointerCount, '*');

//         for (const string &dim : dimensions)
//         {
//             varType += "[" + dim + "]";
//         }

//         insertSymbol(varName, varType);
//     }
// }

// void addFunctionParameters(TreeNode *parameterList)
// {
//     if (parameterList == nullptr)
//         return;

//     for (TreeNode *paramDecl : parameterList->children)
//     {
//         if (!paramDecl)
//             continue;

//         string typeSpecifiers;
//         TreeNode *declSpecs = nullptr;

//         for (TreeNode *child : paramDecl->children)
//         {
//             if (child && TreeNode::nodeTypeToString(child->type) == "DECLARATION_SPECIFIERS")
//             {
//                 declSpecs = child;
//                 break;
//             }
//         }

//         if (declSpecs)
//         {
//             for (TreeNode *specifier : declSpecs->children)
//             {
//                 if (specifier)
//                 {
//                     if (!typeSpecifiers.empty())
//                     {
//                         typeSpecifiers += " ";
//                     }
//                     typeSpecifiers += specifier->valueToString();
//                 }
//             }
//         }

//         string varName;
//         string varType = typeSpecifiers;
//         int pointerCount = 0;
//         vector<string> dimensions;

//         for (TreeNode *child : paramDecl->children)
//         {
//             string nodeType = TreeNode::nodeTypeToString(child->type);

//             if (nodeType == "ARRAY")
//             {
//                 varName = child->children[0]->valueToString();
//                 dimensions.push_back(child->children[1] ? child->children[1]->valueToString() : "");
//             }
//             else if (nodeType == "POINTER")
//             {
//                 pointerCount++;
//                 varName = child->children[0]->valueToString();
//             }
//             else if (nodeType == "IDENTIFIER")
//             {
//                 varName = child->valueToString();
//             }
//         }

//         varType.append(pointerCount, '*');

//         for (const string &dim : dimensions)
//         {
//             varType += "[" + dim + "]";
//         }

//         if (!varName.empty())
//         {
//             insertSymbol(varName, varType);
//         }
//     }
// }

// void addFunction(TreeNode *funcDeclSpec, TreeNode *declarator)
// {
//     string typeSpecifiers;
//     for (TreeNode *specifier : funcDeclSpec->children)
//     {
//         if (specifier)
//         {
//             if (!typeSpecifiers.empty())
//             {
//                 typeSpecifiers += " ";
//             }
//             typeSpecifiers += specifier->valueToString();
//         }
//     }

//     string funcName;
//     string returnType = typeSpecifiers;
//     int pointerCount = 0;

//     TreeNode *current = declarator;
//     while (current)
//     {
//         string nodeType = TreeNode::nodeTypeToString(current->type);

//         if (nodeType == "IDENTIFIER")
//         {
//             funcName = current->valueToString();
//             break;
//         }
//         else if (nodeType == "POINTER")
//         {
//             pointerCount++;
//         }

//         current = current->children.empty() ? nullptr : current->children[0];
//     }

//     returnType.append(pointerCount, '*');

//     if (!funcName.empty())
//     {
//         insertSymbol(funcName, returnType);
//     }
// }

// void addStructMembersToSymbolTable(TreeNode *structDeclList) {
//     if (!structDeclList || structDeclList->type != NODE_STRUCT_DECLARATION_LIST) {
//         return;
//     }

//     for (TreeNode *structDecl : structDeclList->children) {
//         TreeNode *typeSpec = structDecl->children[0];
//         TreeNode *declaratorList = structDecl->children[1];

//         bool isNestedStruct = false;
//         if (typeSpec->type == NODE_STRUCT_OR_UNION_SPECIFIER) {
//             for (TreeNode *child : typeSpec->children) {
//                 if (child->type == NODE_STRUCT_DECLARATION_LIST) {
//                     std::cout << "Error: Nested struct definition is not allowed." << std::endl;
//                     isNestedStruct = true;
//                     break;
//                 }
//             }
//         }

//         if (isNestedStruct) {
//             continue;
//         }

//         std::string typeStr;
//         if (typeSpec->type == NODE_TYPE_SPECIFIER) {
//             typeStr = typeSpec->valueToString();
//         } else if (typeSpec->type == NODE_STRUCT_OR_UNION_SPECIFIER) {
//             typeStr = "struct " + typeSpec->children[1]->valueToString();
//         }

//         for (TreeNode *declarator : declaratorList->children) {
//             std::string memberName;
//             std::string memberType = typeStr;
//             int pointerCount = 0;

//             TreeNode *current = declarator;
//             while (current) {
//                 std::string nodeType = TreeNode::nodeTypeToString(current->type);
//                 if (nodeType == "IDENTIFIER") {
//                     memberName = current->valueToString();
//                     break;
//                 } else if (nodeType == "POINTER") {
//                     pointerCount++;
//                 }
//                 current = current->children.empty() ? nullptr : current->children[0];
//             }

//             memberType.append(pointerCount, '*');

//             if (!memberName.empty()) {
//                 insertSymbol(memberName, memberType);
//             }
//         }
//     }
// }

// vector<tuple<string, string, string>> symbolTable;

// void addToSymbolTable(const string& token, const string& tokenType, const string& extraInfo="") {
//     symbolTable.emplace_back(token, tokenType, extraInfo);
// }

// void addConstantsToSymbolTable(TreeNode *a){
//         addToSymbolTable(a->valueToString(), TreeNode::nodeTypeToString(a->type));
// }

// void addStructMembersToSymbolTable(TreeNode *structOrUnionSpecifier) {
// if (!structOrUnionSpecifier) return;

// string structName;
// vector<pair<string, string>> members;

// for (TreeNode* child : structOrUnionSpecifier->children) {
//     if (!child) continue;

//     string nodeType = TreeNode::nodeTypeToString(child->type);

//     if (nodeType == "IDENTIFIER") {
//         structName = child->valueToString();
//     }
//     else if (nodeType == "STRUCT_DECLARATION_LIST") {
//         for (TreeNode* structDecl : child->children) {
//             if (!structDecl) continue;

//             string typeSpecifiers;
//             TreeNode* declaratorList = nullptr;

//             for (TreeNode* declChild : structDecl->children) {
//                 if (!declChild) continue;

//                 string declType = TreeNode::nodeTypeToString(declChild->type);

//                 if (declType == "KEYWORD" || declType == "IDENTIFIER") {
//                     if (!typeSpecifiers.empty()) typeSpecifiers += " ";
//                     typeSpecifiers += declChild->valueToString();
//                 }
//                 else if (declType == "STRUCT_DECLARATOR_LIST") {
//                     declaratorList = declChild;
//                 }
//             }

//             if (!typeSpecifiers.empty() && declaratorList) {
//                 for (TreeNode* declarator : declaratorList->children) {
//                     if (!declarator || declarator->children.empty()) continue;

//                     string varName;
//                     string varType = typeSpecifiers;
//                     int pointerCount = 0;
//                     vector<string> dimensions;

//                     TreeNode* current = declarator;

//                     while (current) {
//                         string nodeType = TreeNode::nodeTypeToString(current->type);

//                         if (nodeType == "DECLARATOR") {
//                             if (!current->children.empty()) {
//                                 current = current->children[0];
//                                 continue;
//                             }
//                         }
//                         else if (nodeType == "POINTER") {
//                             pointerCount++;
//                         }
//                         else if (nodeType == "ARRAY") {
//                             dimensions.push_back(current->children[1] ? current->children[1]->valueToString() : "");
//                         }
//                         else {
//                             varName = current->valueToString();
//                         }

//                         current = current->children.empty() ? nullptr : current->children[0];
//                     }

//                     varType.append(pointerCount, '*');

//                     for (const string& dim : dimensions) {
//                         varType += "[" + dim + "]";
//                     }

//                     members.emplace_back(varName, varType);
//                 }
//             }
//         }
//     }
// }

// if (!structName.empty()) {
//     addToSymbolTable(structName, "struct");
// }

// for (const auto& [varName, varType] : members) {
//     addToSymbolTable(varName, varType);
// }
// }

vector<string> extractInitDeclarators(TreeNode *initDeclaratorList)
{
    vector<string> identifiers;
    if (!initDeclaratorList)
        return identifiers;

    for (TreeNode *initDeclarator : initDeclaratorList->children)
    {
        TreeNode *declarator = initDeclarator->children[0];
        while (!declarator->children.empty())
            declarator = declarator->children[0];

        identifiers.push_back(declarator->valueToString());
    }
    return identifiers;
}

// void addFunctionToSymbolTable(TreeNode* declarationSpecifiersNode, TreeNode* declaratorNode) {
// if (!declarationSpecifiersNode || !declaratorNode) return;

// TreeNode* current = declaratorNode;
// while (current && !current->children.empty()) {
//     current = current->children[0];
//     if (current->type == NODE_IDENTIFIER) {
//         string functionName = current->valueToString();
//         addToSymbolTable(functionName, "function");
//         return;
//     }
// }
// cerr << "Error: Function name not found in declarator!" << endl;
// }

// void addStructVariablesToSymbolTable(TreeNode* structSpecifierNode, TreeNode* initDeclaratorList) {
//     if (!structSpecifierNode || !initDeclaratorList) return;
//     TreeNode* structNameNode = structSpecifierNode->children[1];
//     string structName = "struct " + structNameNode->valueToString();

//     vector<string> identifiers = extractInitDeclarators(initDeclaratorList);

//     for(const auto id : identifiers) addToSymbolTable(id, structName);
// }

// void printSymbolTable() {
//     cout << left << setw(30) << "Token" << setw(30) << "TokenType" << endl;
//     cout << string(60, '-') << endl;

//     for (const auto& entry : symbolTable) {
//         cout << left << setw(30) << get<0>(entry)
//              << setw(30) << get<1>(entry)
//              << endl;
//     }
// }

// void addClassMembersToSymbolTable(TreeNode* classSpecifierNode) {
//     string className = classSpecifierNode->children[0]->valueToString();
//     addToSymbolTable(className, "class");
//     // if (classSpecifierNode->children.size() <= 2 || classSpecifierNode->children[2] == nullptr) {
//     //     return;  // No members
//     // }
//     // TreeNode* memberDeclarationListNode = classSpecifierNode->children[2];
//     // string currentAccess = "private";  // Default access for class
//     // for (TreeNode* memberNode : memberDeclarationListNode->children) {
//     //     if (memberNode == nullptr || memberNode->type != NODE_DECLARATION) continue;  // Skip non-declarations
//     //     if (memberNode->children.size() < 2 || memberNode->children[0] == nullptr || memberNode->children[1] == nullptr) continue;  // Must have type and declarators
//     //     TreeNode* typeNode = memberNode->children[0];
//     //     string memberType = typeNode->valueToString();
//     //     TreeNode* initDeclaratorList = memberNode->children[1];
//     //     for (TreeNode* declaratorNode : initDeclaratorList->children) {
//     //         if (declaratorNode == nullptr || declaratorNode->children.empty()) continue;
//     //         TreeNode* current = declaratorNode->children[0];  // First child is NODE_DECLARATOR
//     //         while (current && current->type == NODE_DECLARATOR && !current->children.empty()) {
//     //             current = current->children[0];
//     //         }
//     //         if (current == nullptr || current->valueToString().empty()) continue;
//     //         string memberName = current->valueToString();
//     //         addToSymbolTable(memberName, memberType + " (" + currentAccess + ")", className);
//     //     }
//     // }
// }

// void addClassVariablesToSymbolTable(TreeNode* classSpecifierNode, TreeNode* initDeclaratorList) {

//     TreeNode* classNameNode = classSpecifierNode->children[0];
//     string className = "class " + classNameNode->valueToString();

//     vector<string> identifiers = extractInitDeclarators(initDeclaratorList);
//     for(const auto id : identifiers) addToSymbolTable(id, className);

//     }

#endif
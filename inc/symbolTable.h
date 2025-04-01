#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#include <bits/stdc++.h>
#include "ast.h"
using namespace std;

struct Table
{
    unordered_map<string, string> symbolTable;
    Table *parent;
};

stack<Table *> tableStack;
stack<int> offsetStack;
Table *currentTable;
vector<Table *> allTables;

void lookupSymbol(string symbol)
{
    Table *temp = currentTable;
    while (temp != nullptr)
    {
        if (temp->symbolTable.find(symbol) != temp->symbolTable.end())
        {
            cout << "Symbol found in table" << endl;
            return;
        }
        temp = temp->parent;
    }
    cout << "Symbol not found in table" << endl;
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

void insertSymbol(string symbol, string type)
{
    if (currentTable->symbolTable.find(symbol) != currentTable->symbolTable.end())
    {
        cout << "Symbol " << symbol << " already exists in table" << endl;
        return;
    }
    currentTable->symbolTable[symbol] = type;
}

void printAllTables()
{
    int tableId = 0;
    for (auto table : allTables)
    {
        cout << "Table " << tableId++ << " (Scope Level):\n";
        for (const auto &entry : table->symbolTable)
        {
            cout << "  " << entry.first << " -> " << entry.second << endl;
        }
        cout << "----------------------\n";
    }
}

void addDeclaratorsToSymbolTable(ASTNode *a, ASTNode *b)
{
    string typeSpecifiers;
    if (a->children[0]->type == NODE_STRUCT_OR_UNION_SPECIFIER || a->children[0]->type == NODE_CLASS_SPECIFIER)
    {
        ASTNode *specifier = a->children[0];
        if (specifier->children[1]->type != NODE_IDENTIFIER)
            typeSpecifiers = specifier->children[0]->valueToString();
        else
            typeSpecifiers = specifier->children[1]->valueToString();
    }
    else
    {
        for (ASTNode *specifier : a->children)
        {
            if (specifier)
            {
                if (!typeSpecifiers.empty())
                {
                    typeSpecifiers += " ";
                }
                typeSpecifiers += specifier->valueToString();
            }
        }
    }

    for (ASTNode *declarator : b->children)
    {
        if (!declarator || declarator->children.empty())
            continue;

        string varName;
        string varType = typeSpecifiers;
        int pointerCount = 0;
        vector<string> dimensions;

        ASTNode *current = declarator;

        while (current)
        {
            string nodeType = ASTNode::nodeTypeToString(current->type);

            if (nodeType == "DECLARATOR")
            {
                if (!current->children.empty())
                {
                    current = current->children[0];
                    continue;
                }
            }
            else if (nodeType == "POINTER")
            {
                pointerCount++;
            }
            else if (nodeType == "ARRAY")
            {
                dimensions.push_back(current->children[1] ? current->children[1]->valueToString() : "");
            }
            else
            {
                varName = current->valueToString();
            }

            current = current->children.empty() ? nullptr : current->children[0];
        }

        varType.append(pointerCount, '*');

        for (const string &dim : dimensions)
        {
            varType += "[" + dim + "]";
        }

        insertSymbol(varName, varType);
    }
}

void addFunctionParameters(ASTNode *parameterList)
{
    if (parameterList == nullptr)
        return;

    for (ASTNode *paramDecl : parameterList->children)
    {
        if (!paramDecl)
            continue;

        string typeSpecifiers;
        ASTNode *declSpecs = nullptr;

        for (ASTNode *child : paramDecl->children)
        {
            if (child && ASTNode::nodeTypeToString(child->type) == "DECLARATION_SPECIFIERS")
            {
                declSpecs = child;
                break;
            }
        }

        if (declSpecs)
        {
            for (ASTNode *specifier : declSpecs->children)
            {
                if (specifier)
                {
                    if (!typeSpecifiers.empty())
                    {
                        typeSpecifiers += " ";
                    }
                    typeSpecifiers += specifier->valueToString();
                }
            }
        }

        string varName;
        string varType = typeSpecifiers;
        int pointerCount = 0;
        vector<string> dimensions;

        for (ASTNode *child : paramDecl->children)
        {
            string nodeType = ASTNode::nodeTypeToString(child->type);

            if (nodeType == "ARRAY")
            {
                varName = child->children[0]->valueToString();
                dimensions.push_back(child->children[1] ? child->children[1]->valueToString() : "");
            }
            else if (nodeType == "POINTER")
            {
                pointerCount++;
                varName = child->children[0]->valueToString();
            }
            else if (nodeType == "IDENTIFIER")
            {
                varName = child->valueToString();
            }
        }

        varType.append(pointerCount, '*');

        for (const string &dim : dimensions)
        {
            varType += "[" + dim + "]";
        }

        if (!varName.empty())
        {
            insertSymbol(varName, varType);
        }
    }
}

void addFunction(ASTNode *funcDeclSpec, ASTNode *declarator)
{
    string typeSpecifiers;
    for (ASTNode *specifier : funcDeclSpec->children)
    {
        if (specifier)
        {
            if (!typeSpecifiers.empty())
            {
                typeSpecifiers += " ";
            }
            typeSpecifiers += specifier->valueToString();
        }
    }

    string funcName;
    string returnType = typeSpecifiers;
    int pointerCount = 0;

    ASTNode *current = declarator;
    while (current)
    {
        string nodeType = ASTNode::nodeTypeToString(current->type);

        if (nodeType == "IDENTIFIER")
        {
            funcName = current->valueToString();
            break;
        }
        else if (nodeType == "POINTER")
        {
            pointerCount++;
        }

        current = current->children.empty() ? nullptr : current->children[0];
    }

    returnType.append(pointerCount, '*');

    if (!funcName.empty())
    {
        insertSymbol(funcName, returnType);
    }
}

void addStructMembersToSymbolTable(ASTNode *structDeclList) {
    if (!structDeclList || structDeclList->type != NODE_STRUCT_DECLARATION_LIST) {
        return;
    }

    for (ASTNode *structDecl : structDeclList->children) {
        ASTNode *typeSpec = structDecl->children[0];
        ASTNode *declaratorList = structDecl->children[1];

        bool isNestedStruct = false;
        if (typeSpec->type == NODE_STRUCT_OR_UNION_SPECIFIER) {
            for (ASTNode *child : typeSpec->children) {
                if (child->type == NODE_STRUCT_DECLARATION_LIST) {
                    std::cout << "Error: Nested struct definition is not allowed." << std::endl;
                    isNestedStruct = true;
                    break;
                }
            }
        }

        if (isNestedStruct) {
            continue;
        }

        std::string typeStr;
        if (typeSpec->type == NODE_TYPE_SPECIFIER) {
            typeStr = typeSpec->valueToString();
        } else if (typeSpec->type == NODE_STRUCT_OR_UNION_SPECIFIER) {
            typeStr = "struct " + typeSpec->children[1]->valueToString();
        }

        for (ASTNode *declarator : declaratorList->children) {
            std::string memberName;
            std::string memberType = typeStr;
            int pointerCount = 0;

            ASTNode *current = declarator;
            while (current) {
                std::string nodeType = ASTNode::nodeTypeToString(current->type);
                if (nodeType == "IDENTIFIER") {
                    memberName = current->valueToString();
                    break;
                } else if (nodeType == "POINTER") {
                    pointerCount++;
                }
                current = current->children.empty() ? nullptr : current->children[0];
            }

            memberType.append(pointerCount, '*');

            if (!memberName.empty()) {
                insertSymbol(memberName, memberType);
            }
        }
    }
}

// vector<tuple<string, string, string>> symbolTable;

// void addToSymbolTable(const string& token, const string& tokenType, const string& extraInfo="") {
//     symbolTable.emplace_back(token, tokenType, extraInfo);
// }

// void addConstantsToSymbolTable(ASTNode *a){
//         addToSymbolTable(a->valueToString(), ASTNode::nodeTypeToString(a->type));
// }

// void addStructMembersToSymbolTable(ASTNode *structOrUnionSpecifier) {
// if (!structOrUnionSpecifier) return;

// string structName;
// vector<pair<string, string>> members;

// for (ASTNode* child : structOrUnionSpecifier->children) {
//     if (!child) continue;

//     string nodeType = ASTNode::nodeTypeToString(child->type);

//     if (nodeType == "IDENTIFIER") {
//         structName = child->valueToString();
//     }
//     else if (nodeType == "STRUCT_DECLARATION_LIST") {
//         for (ASTNode* structDecl : child->children) {
//             if (!structDecl) continue;

//             string typeSpecifiers;
//             ASTNode* declaratorList = nullptr;

//             for (ASTNode* declChild : structDecl->children) {
//                 if (!declChild) continue;

//                 string declType = ASTNode::nodeTypeToString(declChild->type);

//                 if (declType == "KEYWORD" || declType == "IDENTIFIER") {
//                     if (!typeSpecifiers.empty()) typeSpecifiers += " ";
//                     typeSpecifiers += declChild->valueToString();
//                 }
//                 else if (declType == "STRUCT_DECLARATOR_LIST") {
//                     declaratorList = declChild;
//                 }
//             }

//             if (!typeSpecifiers.empty() && declaratorList) {
//                 for (ASTNode* declarator : declaratorList->children) {
//                     if (!declarator || declarator->children.empty()) continue;

//                     string varName;
//                     string varType = typeSpecifiers;
//                     int pointerCount = 0;
//                     vector<string> dimensions;

//                     ASTNode* current = declarator;

//                     while (current) {
//                         string nodeType = ASTNode::nodeTypeToString(current->type);

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

vector<string> extractInitDeclarators(ASTNode *initDeclaratorList)
{
    vector<string> identifiers;
    if (!initDeclaratorList)
        return identifiers;

    for (ASTNode *initDeclarator : initDeclaratorList->children)
    {
        ASTNode *declarator = initDeclarator->children[0];
        while (!declarator->children.empty())
            declarator = declarator->children[0];

        identifiers.push_back(declarator->valueToString());
    }
    return identifiers;
}

// void addFunctionToSymbolTable(ASTNode* declarationSpecifiersNode, ASTNode* declaratorNode) {
// if (!declarationSpecifiersNode || !declaratorNode) return;

// ASTNode* current = declaratorNode;
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

// void addStructVariablesToSymbolTable(ASTNode* structSpecifierNode, ASTNode* initDeclaratorList) {
//     if (!structSpecifierNode || !initDeclaratorList) return;
//     ASTNode* structNameNode = structSpecifierNode->children[1];
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

// void addClassMembersToSymbolTable(ASTNode* classSpecifierNode) {
//     string className = classSpecifierNode->children[0]->valueToString();
//     addToSymbolTable(className, "class");
//     // if (classSpecifierNode->children.size() <= 2 || classSpecifierNode->children[2] == nullptr) {
//     //     return;  // No members
//     // }
//     // ASTNode* memberDeclarationListNode = classSpecifierNode->children[2];
//     // string currentAccess = "private";  // Default access for class
//     // for (ASTNode* memberNode : memberDeclarationListNode->children) {
//     //     if (memberNode == nullptr || memberNode->type != NODE_DECLARATION) continue;  // Skip non-declarations
//     //     if (memberNode->children.size() < 2 || memberNode->children[0] == nullptr || memberNode->children[1] == nullptr) continue;  // Must have type and declarators
//     //     ASTNode* typeNode = memberNode->children[0];
//     //     string memberType = typeNode->valueToString();
//     //     ASTNode* initDeclaratorList = memberNode->children[1];
//     //     for (ASTNode* declaratorNode : initDeclaratorList->children) {
//     //         if (declaratorNode == nullptr || declaratorNode->children.empty()) continue;
//     //         ASTNode* current = declaratorNode->children[0];  // First child is NODE_DECLARATOR
//     //         while (current && current->type == NODE_DECLARATOR && !current->children.empty()) {
//     //             current = current->children[0];
//     //         }
//     //         if (current == nullptr || current->valueToString().empty()) continue;
//     //         string memberName = current->valueToString();
//     //         addToSymbolTable(memberName, memberType + " (" + currentAccess + ")", className);
//     //     }
//     // }
// }

// void addClassVariablesToSymbolTable(ASTNode* classSpecifierNode, ASTNode* initDeclaratorList) {

//     ASTNode* classNameNode = classSpecifierNode->children[0];
//     string className = "class " + classNameNode->valueToString();

//     vector<string> identifiers = extractInitDeclarators(initDeclaratorList);
//     for(const auto id : identifiers) addToSymbolTable(id, className);

//     }

#endif
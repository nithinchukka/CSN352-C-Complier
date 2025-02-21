#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#include<bits/stdc++.h>
#include "ast.h"
using namespace std;


vector<tuple<string, string, string>> symbolTable;

void addToSymbolTable(const string& token, const string& tokenType, const string& extraInfo="") {
    symbolTable.emplace_back(token, tokenType, extraInfo);
}

void addConstantsToSymbolTable(ASTNode *a){
        addToSymbolTable(a->valueToString(), ASTNode::nodeTypeToString(a->type));
}

void addStructMembersToSymbolTable(ASTNode *structOrUnionSpecifier) {
if (!structOrUnionSpecifier) return;

string structName;
vector<pair<string, string>> members;

for (ASTNode* child : structOrUnionSpecifier->children) {
    if (!child) continue;

    string nodeType = ASTNode::nodeTypeToString(child->type);

    if (nodeType == "IDENTIFIER") {
        structName = child->valueToString();
    } 
    else if (nodeType == "STRUCT_DECLARATION_LIST") {
        for (ASTNode* structDecl : child->children) {
            if (!structDecl) continue;

            string typeSpecifiers;
            ASTNode* declaratorList = nullptr;

            for (ASTNode* declChild : structDecl->children) {
                if (!declChild) continue;
                
                string declType = ASTNode::nodeTypeToString(declChild->type);

                if (declType == "KEYWORD" || declType == "IDENTIFIER") {
                    if (!typeSpecifiers.empty()) typeSpecifiers += " ";
                    typeSpecifiers += declChild->valueToString();
                } 
                else if (declType == "STRUCT_DECLARATOR_LIST") {
                    declaratorList = declChild;
                }
            }

            if (!typeSpecifiers.empty() && declaratorList) {
                for (ASTNode* declarator : declaratorList->children) {
                    if (!declarator || declarator->children.empty()) continue;

                    string varName;
                    string varType = typeSpecifiers;
                    int pointerCount = 0;
                    vector<string> dimensions;

                    ASTNode* current = declarator;

                    while (current) {
                        string nodeType = ASTNode::nodeTypeToString(current->type);

                        if (nodeType == "DECLARATOR") {
                            if (!current->children.empty()) {
                                current = current->children[0];
                                continue;
                            }
                        } 
                        else if (nodeType == "POINTER") {
                            pointerCount++;
                        } 
                        else if (nodeType == "ARRAY") {
                            dimensions.push_back(current->children[1] ? current->children[1]->valueToString() : "");
                        } 
                        else {
                            varName = current->valueToString();
                        }

                        current = current->children.empty() ? nullptr : current->children[0];
                    }

                    varType.append(pointerCount, '*');

                    for (const string& dim : dimensions) {
                        varType += "[" + dim + "]";
                    }

                    members.emplace_back(varName, varType);
                }
            }
        }
    }
}

if (!structName.empty()) {
    addToSymbolTable(structName, "struct");
}

for (const auto& [varName, varType] : members) {
    addToSymbolTable(varName, varType);
}
}

vector<string> extractInitDeclarators(ASTNode* initDeclaratorList) {
    vector<string> identifiers;
    if (!initDeclaratorList) return identifiers;

    for (ASTNode* initDeclarator : initDeclaratorList->children) {
        ASTNode* declarator = initDeclarator->children[0];
        while (!declarator->children.empty()) 
            declarator = declarator->children[0];
        
        identifiers.push_back(declarator->valueToString());
    }
    return identifiers;
}


void addDeclaratorsToSymbolTable(ASTNode *a, ASTNode* b) {
    string typeSpecifiers;
    for (ASTNode* specifier : a->children) {
        if (specifier) {
            if (!typeSpecifiers.empty()) {
                typeSpecifiers += " ";
            }
            typeSpecifiers += specifier->valueToString();
        }
    }

    for (ASTNode* declarator : b->children) {
        if (!declarator || declarator->children.empty()) continue;

        string varName;
        string varType = typeSpecifiers;
        int pointerCount = 0;
        vector<string> dimensions;

        ASTNode* current = declarator;

        while (current) {
            string nodeType = ASTNode::nodeTypeToString(current->type);
            
            if (nodeType == "DECLARATOR") {
                if (!current->children.empty()) {
                    current = current->children[0];
                    continue;
                }
            } else if (nodeType == "POINTER") {
                pointerCount++;
            } else if (nodeType == "ARRAY") {
                dimensions.push_back(current->children[1] ? current->children[1]->valueToString() : "");
            } else {
                varName = current->valueToString();
            }
            
            current = current->children.empty() ? nullptr : current->children[0];
        }

        varType.append(pointerCount, '*');

        for (const string& dim : dimensions) {
            varType += "[" + dim + "]";
        }

        addToSymbolTable(varName, varType);
    }
}

void addFunctionToSymbolTable(ASTNode* declarationSpecifiersNode, ASTNode* declaratorNode) {
if (!declarationSpecifiersNode || !declaratorNode) return;

ASTNode* current = declaratorNode;
while (current && !current->children.empty()) {
    current = current->children[0];
    if (current->type == NODE_IDENTIFIER) {
        string functionName = current->valueToString();
        addToSymbolTable(functionName, "function");
        return;
    }
}
cerr << "Error: Function name not found in declarator!" << endl;
}

void addStructVariablesToSymbolTable(ASTNode* structSpecifierNode, ASTNode* initDeclaratorList) {
    if (!structSpecifierNode || !initDeclaratorList) return;
    ASTNode* structNameNode = structSpecifierNode->children[1];
    string structName = "struct " + structNameNode->valueToString();

    vector<string> identifiers = extractInitDeclarators(initDeclaratorList);
    
    for(const auto id : identifiers) addToSymbolTable(id, structName);
}


void printSymbolTable() {
    cout << left << setw(20) << "Token" << setw(20) << "TokenType" << setw(20) << "Scope" << endl;
    cout << string(60, '-') << endl;

    for (const auto& entry : symbolTable) {
        cout << left << setw(20) << get<0>(entry)
             << setw(20) << get<1>(entry)
             << setw(20) << get<2>(entry)
             << endl;
    }
}

#endif
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
#endif
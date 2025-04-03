#ifndef ASTNODE_H
#define ASTNODE_H

#include <bits/stdc++.h>
using namespace std;

enum NodeType
{
    NODE_ASSIGNMENT,
    NODE_TRANSLATION_UNIT,
    NODE_PARAMETER_TYPE_LIST,
    NODE_PARAMETER_LIST,
    NODE_PARAMETER_DECLARATION,
    NODE_IDENTIFIER_LIST,
    NODE_FUNCTION_DEFINITION,
    NODE_TYPE_NAME,
    NODE_ABSTRACT_DECLARATOR,
    NODE_DIRECT_ABSTRACT_DECLARATOR,
    NODE_TYPE_SPECIFIER,
    NODE_STORAGE_CLASS_SPECIFIER,
    NODE_STRUCT_OR_UNION_SPECIFIER,
    NODE_STRUCT_DECLARATION_LIST,
    NODE_STRUCT_DECLARATION,
    NODE_SPECIFIER_QUALIFIER_LIST,
    NODE_STRUCT_DECLARATOR_LIST,
    NODE_STRUCT_DECLARATOR,
    NODE_ENUM_SPECIFIER,
    NODE_ENUMERATOR_LIST,
    NODE_ENUMERATOR,
    NODE_DECLARATION_SPECIFIERS,
    NODE_DECLARATION,
    NODE_DIRECT_DECLARATOR,
    NODE_INITIALIZER,
    NODE_INITIALIZER_LIST,
    NODE_ID,
    NODE_CONSTANT,
    NODE_TYPE_QUALIFIER,
    NODE_DECLARATION_LIST,
    NODE_STATEMENT_LIST,
    NODE_STATEMENT,
    NODE_LABELED_STATEMENT,
    NODE_EXPRESSION_STATEMENT,
    NODE_SELECTION_STATEMENT,
    NODE_ITERATION_STATEMENT,
    NODE_JUMP_STATEMENT,
    NODE_EXPRESSION,
    NODE_ASSIGNMENT_EXPRESSION,
    NODE_CONDITIONAL_EXPRESSION,
    NODE_LOGICAL_OR_EXPRESSION,
    NODE_LOGICAL_AND_EXPRESSION,
    NODE_INCLUSIVE_OR_EXPRESSION,
    NODE_EXCLUSIVE_OR_EXPRESSION,
    NODE_AND_EXPRESSION,
    NODE_EQUALITY_EXPRESSION,
    NODE_RELATIONAL_EXPRESSION,
    NODE_SHIFT_EXPRESSION,
    NODE_ADDITIVE_EXPRESSION,
    NODE_MULTIPLICATIVE_EXPRESSION,
    NODE_CAST_EXPRESSION,
    NODE_UNARY_EXPRESSION,
    NODE_POSTFIX_EXPRESSION,
    NODE_PRIMARY_EXPRESSION,
    NODE_ARGUMENT_EXPRESSION_LIST,
    NODE_CONSTANT_EXPRESSION,
    NODE_ASSIGNMENT_OPERATOR,
    NODE_UNARY_OPERATOR,
    NODE_TYPE_NAME_SPECIFIER,
    NODE_POINTER,
    NODE_TYPE_QUALIFIER_LIST,
    NODE_ELLIPSIS,
    NODE_COMPOUND_STATEMENT,
    NODE_DECLARATOR_LIST,
    NODE_DECLARATOR,
    NODE_IDENTIFIER,
    NODE_STRING_LITERAL,
    NODE_CHAR_LITERAL,
    NODE_KEYWORD,
    ARRAY,
    NODE_BOOLEAN_LITERAL,
    NODE_IO_STATEMENT,
    NODE_CLASS_SPECIFIER,         // For class definitions (named or anonymous)
    NODE_MEMBER_DECLARATION_LIST, // List of member declarations in a class
    NODE_MEMBER_DECLARATION,      // Individual member declaration (access specifier or declaration)
    NODE_ACCESS_SPECIFIER,
    INTEGER_LITERAL,
    FLOAT_LITERAL,
    NODE_DESTRUCTOR_FUNCTION,
    NODE_CONSTRUCTOR_FUNCTION,
    NODE_BLOCK_ITEM_LIST,
    NODE_SCOPE_RESOLUTION_STATEMENT,
    NODE_TYPE,
};

using NodeValue = variant<monostate, string, int, double, bool, char>;

class ASTNode
{
public:
    NodeType type;
    NodeValue value;
    int offset = 0;
    vector<ASTNode *> children;
    int typeCategory = -1; // var = 0, pointer = 1, arr = 2,  func = 3, struct = 4, union = 5, class = 6
    bool isConst = false;
    bool isStatic = false;
    bool isVolatile = false;
    bool isUnsigned = false;
    int typeSpecifier = -1; //"char", "short", "int", "long", "bool", "float", "double"
    int storageClass = -1;  // -1: none, 0: extern, 1: static, 2: auto, 3: register
    int paramCount = 0;
    int pointerLevel = 0;
    vector<int> paramTypes;
    vector<int> dimensions;
    unordered_map<string, ASTNode*> symbolTable;

    ASTNode(NodeType type, NodeValue value = monostate()) : type(type), value(value)
    {
    }

    void addChild(ASTNode *child)
    {
        if (child)
            children.push_back(child);
    }

    void printAST(int depth = 0, ostream &os = cout) const
    {
        for (int i = 0; i < depth; ++i)
            os << "  ";
        os << "|- " << nodeTypeToString(type) << " " << valueToString() << "\n";

        for (const ASTNode *child : children)
        {
            if (child == nullptr)
            {
                os << "  (nullptr child detected!)\n";
                continue;
            }
            child->printAST(depth + 1, os);
        }
    }

    void print() const
    {
        printAST();
    }

    static string nodeTypeToString(NodeType type)
    {
        switch (type)
        {
        case NODE_ASSIGNMENT:
            return "ASSIGNMENT";
        case NODE_TRANSLATION_UNIT:
            return "TRANSLATION_UNIT";
        case NODE_PARAMETER_TYPE_LIST:
            return "PARAMETER_TYPE_LIST";
        case NODE_PARAMETER_LIST:
            return "PARAMETER_LIST";
        case NODE_PARAMETER_DECLARATION:
            return "PARAMETER_DECLARATION";
        case NODE_IDENTIFIER_LIST:
            return "IDENTIFIER_LIST";
        case NODE_FUNCTION_DEFINITION:
            return "FUNCTION_DEFINITION";
        case NODE_TYPE_NAME:
            return "TYPE_NAME";
        case NODE_ABSTRACT_DECLARATOR:
            return "ABSTRACT_DECLARATOR";
        case NODE_DIRECT_ABSTRACT_DECLARATOR:
            return "DIRECT_ABSTRACT_DECLARATOR";
        case NODE_TYPE_SPECIFIER:
            return "TYPE_SPECIFIER";
        case NODE_STORAGE_CLASS_SPECIFIER:
            return "STORAGE_CLASS_SPECIFIER";
        case NODE_STRUCT_OR_UNION_SPECIFIER:
            return "STRUCT_SPECIFIER";
        case NODE_STRUCT_DECLARATION_LIST:
            return "STRUCT_DECLARATION_LIST";
        case NODE_STRUCT_DECLARATION:
            return "STRUCT_DECLARATION";
        case NODE_SPECIFIER_QUALIFIER_LIST:
            return "SPECIFIER_QUALIFIER_LIST";
        case NODE_STRUCT_DECLARATOR_LIST:
            return "STRUCT_DECLARATOR_LIST";
        case NODE_STRUCT_DECLARATOR:
            return "STRUCT_DECLARATOR";
        case NODE_ENUM_SPECIFIER:
            return "ENUM_SPECIFIER";
        case NODE_ENUMERATOR_LIST:
            return "ENUMERATOR_LIST";
        case NODE_ENUMERATOR:
            return "ENUMERATOR";
        case NODE_DECLARATION_SPECIFIERS:
            return "DECLARATION_SPECIFIERS";
        case NODE_DECLARATION:
            return "DECLARATION";
        case NODE_DECLARATOR:
            return "DECLARATOR";
        case NODE_DIRECT_DECLARATOR:
            return "DIRECT_DECLARATOR";
        case NODE_INITIALIZER:
            return "INITIALIZER";
        case NODE_INITIALIZER_LIST:
            return "INITIALIZER_LIST";
        case NODE_ID:
            return "IDENTIFIER";
        case NODE_CONSTANT:
            return "CONSTANT";
        case NODE_TYPE_QUALIFIER:
            return "TYPE_QUALIFIER";
        case NODE_DECLARATION_LIST:
            return "DECLARATION_LIST";
        case NODE_STATEMENT_LIST:
            return "STATEMENT_LIST";
        case NODE_STATEMENT:
            return "STATEMENT";
        case NODE_LABELED_STATEMENT:
            return "LABELED_STATEMENT";
        case NODE_EXPRESSION_STATEMENT:
            return "EXPRESSION_STATEMENT";
        case NODE_SELECTION_STATEMENT:
            return "SELECTION_STATEMENT";
        case NODE_ITERATION_STATEMENT:
            return "ITERATION_STATEMENT";
        case NODE_JUMP_STATEMENT:
            return "JUMP_STATEMENT";
        case NODE_EXPRESSION:
            return "EXPRESSION";
        case NODE_ASSIGNMENT_EXPRESSION:
            return "ASSIGNMENT_EXPRESSION";
        case NODE_CONDITIONAL_EXPRESSION:
            return "CONDITIONAL_EXPRESSION";
        case NODE_LOGICAL_OR_EXPRESSION:
            return "LOGICAL_OR_EXPRESSION";
        case NODE_LOGICAL_AND_EXPRESSION:
            return "LOGICAL_AND_EXPRESSION";
        case NODE_INCLUSIVE_OR_EXPRESSION:
            return "INCLUSIVE_OR_EXPRESSION";
        case NODE_EXCLUSIVE_OR_EXPRESSION:
            return "EXCLUSIVE_OR_EXPRESSION";
        case NODE_AND_EXPRESSION:
            return "AND_EXPRESSION";
        case NODE_EQUALITY_EXPRESSION:
            return "EQUALITY_EXPRESSION";
        case NODE_RELATIONAL_EXPRESSION:
            return "RELATIONAL_EXPRESSION";
        case NODE_SHIFT_EXPRESSION:
            return "SHIFT_EXPRESSION";
        case NODE_ADDITIVE_EXPRESSION:
            return "ADDITIVE_EXPRESSION";
        case NODE_MULTIPLICATIVE_EXPRESSION:
            return "MULTIPLICATIVE_EXPRESSION";
        case NODE_CAST_EXPRESSION:
            return "CAST_EXPRESSION";
        case NODE_UNARY_EXPRESSION:
            return "UNARY_EXPRESSION";
        case NODE_POSTFIX_EXPRESSION:
            return "POSTFIX_EXPRESSION";
        case NODE_PRIMARY_EXPRESSION:
            return "PRIMARY_EXPRESSION";
        case NODE_ARGUMENT_EXPRESSION_LIST:
            return "ARGUMENT_EXPRESSION_LIST";
        case NODE_CONSTANT_EXPRESSION:
            return "CONSTANT_EXPRESSION";
        case NODE_ASSIGNMENT_OPERATOR:
            return "ASSIGNMENT_OPERATOR";
        case NODE_UNARY_OPERATOR:
            return "UNARY_OPERATOR";
        case NODE_TYPE_NAME_SPECIFIER:
            return "TYPE_NAME_SPECIFIER";
        case NODE_POINTER:
            return "POINTER";
        case NODE_TYPE_QUALIFIER_LIST:
            return "TYPE_QUALIFIER_LIST";
        case NODE_ELLIPSIS:
            return "ELLIPSIS";
        case NODE_COMPOUND_STATEMENT:
            return "COMPOUND_STATEMENT";
        case NODE_DECLARATOR_LIST:
            return "DECLARATOR_LIST";
        case NODE_IDENTIFIER:
            return "IDENTIFIER";
        case NODE_KEYWORD:
            return "KEYWORD";
        case ARRAY:
            return "ARRAY";
        case NODE_CHAR_LITERAL:
            return "CHAR_LITERAL";
        case NODE_STRING_LITERAL:
            return "STRING_LITERAL";
        case NODE_BOOLEAN_LITERAL:
            return "BOOLEAN_LITERAL";
        case NODE_IO_STATEMENT:
            return "NODE_IO_STATEMENT";
        case NODE_CLASS_SPECIFIER:
            return "CLASS_SPECIFIER";
        case NODE_MEMBER_DECLARATION_LIST:
            return "MEMBER_DECLARATION_LIST";
        case NODE_MEMBER_DECLARATION:
            return "MEMBER_DECLARATION";
        case NODE_ACCESS_SPECIFIER:
            return "ACCESS_SPECIFIER";
        case INTEGER_LITERAL:
            return "INTEGER_LITERAL";
        case FLOAT_LITERAL:
            return "FLOAT_LITERAL";
        case NODE_DESTRUCTOR_FUNCTION:
            return "DESTRUCTOR";
        case NODE_CONSTRUCTOR_FUNCTION:
            return "CONSTRUCTOR";
        case NODE_BLOCK_ITEM_LIST:
            return "BLOCK_ITEM_LIST";
        case NODE_SCOPE_RESOLUTION_STATEMENT:
            return "SCOPE_RESOLUTION_STATEMENT";
        case NODE_TYPE:
            return "TYPE";
        default:
            return "UNKNOWN";
        }
    }

    string valueToString() const
    {
        if (holds_alternative<monostate>(value))
            return "(null)";
        if (holds_alternative<string>(value))
            return get<string>(value);
        if (holds_alternative<int>(value))
            return to_string(get<int>(value));
        if (holds_alternative<double>(value))
            return to_string(get<double>(value));
        if (holds_alternative<bool>(value))
            return string(get<bool>(value) ? "true" : "false");
        if (holds_alternative<char>(value))
            return string(1, get<char>(value));
        return "(unknown)";
    }

    friend ostream &operator<<(ostream &os, const ASTNode &node)
    {
        node.printAST(0, os);
        return os;
    }
};

template <typename... Args>
ASTNode *createNode(NodeType type, NodeValue value = monostate(), Args... children)
{
    ASTNode *node = new ASTNode(type, value);
    (node->addChild(children), ...);
    return node;
}

#endif // ASTNODE_H
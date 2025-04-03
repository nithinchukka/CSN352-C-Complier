%code requires {
	#include "../inc/ast.h"
}
%define parse.error verbose

%{
    #include <bits/stdc++.h>
	#include "../inc/ast.h"
    #include "../inc/symbolTable.h"
    using namespace std;
    void yyerror(const char *s);
    extern int yylex();
    extern FILE *yyin;
    extern unordered_set<string> classOrStructOrUnion;
    map<string, vector<pair<string, ASTNode*>>> alphaSymbolTable;
struct DeclaratorInfo {
    int typeCategory = -1; // var = 0, func = 1, struct = 2, enum = 3, class = 4
    int storageClass = -1; // -1: none, 0: extern, 1: static, 2: auto, 3: register
    int typeSpecifier = -1; // -1: none, 0: void, 1: char, 2: short, 3: int, 4: bool, 5: long, 6: float, 7: double
    bool isConst = false;
    bool isStatic = false;
    bool isVolatile = false;
    bool isUnsigned = false;
    bool hasLong = false;
    bool isValid = false;
    bool isCustomType = false; // true if it's a class, struct, or union
};

DeclaratorInfo isValidVariableDeclaration(vector<ASTNode*>& nodes, bool isFunction = false) {
    DeclaratorInfo declInfo;
    unordered_map<string, int> storageClasses = {
        {"extern", 0}, {"static", 1}, {"auto", 2}, {"register", 3}
    };
    unordered_map<string, int> baseTypes = {
        {"void", 0}, {"char", 1}, {"short", 2}, {"int", 3}, {"bool", 4}, {"long", 5}, {"float", 6}, {"double", 7}
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
                declInfo.typeSpecifier = 8;
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
    if (lhstype < 1 || lhstype > 14 || rhstype < 1 || rhstype > 14) {
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

bool checkInitializerLevel(ASTNode* initList, int baseType, vector<int>& dimensions, int level) {
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
        for (ASTNode* child : initList->children) {
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
        for (ASTNode* child : initList->children) {
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


vector<int> findArrayDimensions(ASTNode* arr) {
    if (!arr || arr->children.empty()) 
        return {};

    vector<int> dimensions;
    ASTNode* current = arr;

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


bool checkInvalidReturn(ASTNode* node, int returnType = -1) {
    if (!node) return false;
    
    if (node->type == NODE_JUMP_STATEMENT) {
        if (returnType == 0 && node->children.size() == 1 && node->children[0]->type == NODE_KEYWORD && node->children[0]->valueToString() == "return") {
            return false;
        }

        if (returnType != 0 && node->children.size() == 1 && node->children[0]->type == NODE_KEYWORD && node->children[0]->valueToString() == "return") {
            cout << "Error: Return statement without an expression.\n";
            return true;
        }

        if (returnType != 0 && node->children.size() > 0) {
            ASTNode* returnExpr = node->children[1];
            if (!isTypeCompatible(returnType, returnExpr->typeSpecifier, "=")) {
                cout << "Error: Type mismatch in return statement.\n";
                return true;
            }
        }
    }
    
    for (ASTNode* child : node->children) {
        if (checkInvalidReturn(child, returnType)) return true;
    }
    
    return false;
}

bool structInitializerCheck(ASTNode* identifierNode, ASTNode* initializerList) {
    // Check if identifierNode has a symbol table for struct members
    if (identifierNode->symbolTable.empty()) {
        cerr << "Error: No struct definition found for type checking" << endl;
        return false;
    }

    // Get the number of members in the struct definition
    size_t expectedSize = identifierNode->symbolTable.size();
    
    // Count actual initializers provided
    size_t actualSize = initializerList->children.size();

    // Check if number of initializers matches struct members
    if (expectedSize != actualSize) {
        cerr << "Error: Struct initialization mismatch - expected " 
             << expectedSize << " values, got " << actualSize << endl;
        return false;
    }

    // Check type compatibility using a for loop
    for (size_t i = 0; i < expectedSize; i++) {
        const auto& memberPair = identifierNode->symbolTable[i];
        ASTNode* memberNode = memberPair.second;  // ASTNode* from symbol table
        ASTNode* initNode = initializerList->children[i];

        int expectedType = memberNode->typeSpecifier;
        int actualType = initNode->typeSpecifier;

        // General type compatibility check

        bool typesCompatible = isTypeCompatible(expectedType, actualType, "=");
        
        if (!typesCompatible) {
            cerr << "Error: Type mismatch at position " << i + 1 
                 << " (member '" << memberPair.first << "'): expected " 
                 << expectedType
                 << ", got " << actualType << endl;
            return false;
        }

        // Additional checks from symbol table
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
%}


%union {
	ASTNode *node;
    char *str;
}


/* Keywords */
%token <node>
    KEYWORD_AUTO KEYWORD_BOOL KEYWORD_BREAK KEYWORD_CASE KEYWORD_CATCH KEYWORD_CHAR 
    KEYWORD_CLASS KEYWORD_CONST KEYWORD_CONTINUE KEYWORD_DEFAULT KEYWORD_DELETE KEYWORD_DO 
    KEYWORD_DOUBLE KEYWORD_ELSE KEYWORD_EXTERN KEYWORD_FLOAT 
    KEYWORD_FOR KEYWORD_GOTO KEYWORD_IF KEYWORD_INT 
    KEYWORD_LONG KEYWORD_NEW KEYWORD_NULLPTR KEYWORD_PRIVATE KEYWORD_PROTECTED 
    KEYWORD_PUBLIC KEYWORD_REGISTER KEYWORD_RETURN KEYWORD_SHORT KEYWORD_SIGNED KEYWORD_SIZEOF 
    KEYWORD_STATIC KEYWORD_STRUCT KEYWORD_SWITCH KEYWORD_THIS KEYWORD_THROW KEYWORD_UNION
    KEYWORD_TRY KEYWORD_TYPEDEF KEYWORD_UNSIGNED 
    KEYWORD_VOID KEYWORD_VOLATILE KEYWORD_WHILE KEYWORD_PRINTF KEYWORD_SCANF TYPE_NAME

/* Identifiers and Literals */
%token <node> INTEGER FLOAT CHAR STRING ID ELLIPSIS_OPERATOR BOOLEAN_LITERAL

/* Delimiters and Separators */
%token <str>
    LBRACE RBRACE LBRACKET RBRACKET LPAREN RPAREN SEMICOLON COMMA COLON

/* Operators */
%token <str>
    PLUS_OPERATOR MINUS_OPERATOR MULTIPLY_OPERATOR DIVIDE_OPERATOR MODULO_OPERATOR
    DECREMENT_OPERATOR INCREMENT_OPERATOR

/* Assignment Operators */
%token <str>
    ASSIGNMENT_OPERATOR PLUS_ASSIGN_OPERATOR MINUS_ASSIGN_OPERATOR MULTIPLY_ASSIGN_OPERATOR 
    DIVIDE_ASSIGN_OPERATOR MODULO_ASSIGN_OPERATOR BITWISE_AND_ASSIGN_OPERATOR BITWISE_OR_ASSIGN_OPERATOR 
    BITWISE_XOR_ASSIGN_OPERATOR RIGHT_SHIFT_ASSIGN_OPERATOR LEFT_SHIFT_ASSIGN_OPERATOR

/* Comparison Operators */
%token <str>
    EQUALS_COMPARISON_OPERATOR NOT_EQUALS_OPERATOR GREATER_THAN_OPERATOR LESS_THAN_OPERATOR 
    GREATER_THAN_OR_EQUAL_OPERATOR LESS_THAN_OR_EQUAL_OPERATOR

/* Logical Operators */
%token <str>
    LOGICAL_AND_OPERATOR LOGICAL_OR_OPERATOR LOGICAL_NOT_OPERATOR

/* Bitwise Operators */   
%token <str>
    BITWISE_AND_OPERATOR BITWISE_OR_OPERATOR BITWISE_XOR_OPERATOR LEFT_SHIFT_OPERATOR 
    RIGHT_SHIFT_OPERATOR BITWISE_NOT_OPERATOR

/* Other Operators & Symbols */
%token <str>
    TERNARY_OPERATOR DOT_OPERATOR  SCOPE_RESOLUTION_OPERATOR  
    POINTER_TO_MEMBER_DOT_OPERATOR POINTER_TO_MEMBER_ARROW_OPERATOR

%nonassoc LOWER_THAN_ELSE
%nonassoc KEYWORD_ELSE

%type<node> translation_unit external_declaration function_definition constructor_function destructor_function struct_type_specifier

%type<node> declaration declaration_specifiers declarator compound_statement struct_declaration_list

%type<node> storage_class_specifier type_specifier struct_or_union_specifier struct_or_union class_specifier member_declaration_list member_declaration access_specifier

%type<node> struct_declaration struct_declarator_list specifier_qualifier_list type_qualifier constant_expression

%type<node> type_qualifier_list parameter_type_list parameter_list parameter_declaration identifier_list type_name abstract_declarator

%type<node> initializer initializer_list direct_declarator pointer direct_abstract_declarator assignment_expression

%type<node> statement labeled_statement expression_statement selection_statement iteration_statement jump_statement block_item block_item_list

%type<node> expression init_declarator init_declarator_list conditional_expression primary_expression postfix_expression

%type<node> unary_expression unary_operator cast_expression multiplicative_expression additive_expression shift_expression

%type<node> relational_expression equality_expression and_expression exclusive_or_expression inclusive_or_expression scope_resolution_statements

%type<node> logical_and_expression logical_or_expression argument_expression_list assignment_operator try_catch_statement io_statement scope_resolution_statement

%start translation_unit
%%

primary_expression
	: ID { $$ = $1;$$ = lookupSymbol($$->valueToString());}
	| INTEGER { $$ = $1;$$->typeSpecifier=3;}
    | FLOAT { $$ = $1;$$->typeSpecifier=6;}
	| STRING { $$ = $1; $$->typeSpecifier=8;}
	| CHAR { $$ = $1;$$->typeSpecifier=1; }
	| BOOLEAN_LITERAL {$$ = $1;$$->typeSpecifier=3; } 
    | KEYWORD_NULLPTR {$$ = $1; }
    | KEYWORD_THIS {$$ = $1; }
	| LPAREN expression RPAREN { $$ = $2; }
	;

postfix_expression
	: primary_expression { $$ = $1; }
	| postfix_expression LBRACKET expression RBRACKET { $$ = createNode(NODE_POSTFIX_EXPRESSION, monostate(), $1, $3); }
	| postfix_expression LPAREN RPAREN { $$ = createNode(NODE_POSTFIX_EXPRESSION, monostate(), $1); }
	| postfix_expression LPAREN argument_expression_list RPAREN { $$ = createNode(NODE_POSTFIX_EXPRESSION, monostate(), $1, $3); }
	| postfix_expression DOT_OPERATOR ID { $$ = createNode(NODE_POSTFIX_EXPRESSION, $2, $1, $3); }
	| postfix_expression POINTER_TO_MEMBER_ARROW_OPERATOR ID { $$ = createNode(NODE_POSTFIX_EXPRESSION, $2, $1, $3); }
    | postfix_expression POINTER_TO_MEMBER_DOT_OPERATOR ID { $$ = createNode(NODE_POSTFIX_EXPRESSION, $2, $1, $3); }
	| postfix_expression INCREMENT_OPERATOR { $$ = createNode(NODE_POSTFIX_EXPRESSION, $2, $1);}
	| postfix_expression DECREMENT_OPERATOR { $$ = createNode(NODE_POSTFIX_EXPRESSION, $2, $1); }
	;

argument_expression_list
    : assignment_expression { 
        $$ = createNode(NODE_ARGUMENT_EXPRESSION_LIST, monostate(), $1); 
    }
    | argument_expression_list COMMA assignment_expression { 
        $$ = $1;
        $$->children.push_back($3);
    }
    ;

unary_expression
	: postfix_expression { $$ = $1; $$->type=NODE_UNARY_EXPRESSION;}
	| INCREMENT_OPERATOR unary_expression { $$ = createNode(NODE_UNARY_EXPRESSION, $1, $2);}
	| DECREMENT_OPERATOR unary_expression { $$ = createNode(NODE_UNARY_EXPRESSION, $1, $2); }
	| unary_operator cast_expression { $$ = createNode(NODE_UNARY_EXPRESSION, monostate(), $1, $2);}
	| KEYWORD_SIZEOF unary_expression { $$ = createNode(NODE_UNARY_EXPRESSION, monostate(),$1, $2); }
	| KEYWORD_SIZEOF LPAREN type_name RPAREN { $$ = createNode(NODE_UNARY_EXPRESSION, monostate(), $1, $3);}
	| KEYWORD_NEW LPAREN type_name RPAREN { $$ = createNode(NODE_UNARY_EXPRESSION, monostate(), $3); }
	| KEYWORD_NEW LPAREN type_name RPAREN LBRACKET expression RBRACKET { $$ = createNode(NODE_UNARY_EXPRESSION, monostate(), $3, $6); }
	| KEYWORD_DELETE cast_expression
	| KEYWORD_DELETE LBRACKET RBRACKET cast_expression 
	;


unary_operator
	: BITWISE_AND_OPERATOR { $$ = createNode(NODE_UNARY_OPERATOR, $1); }
	| MULTIPLY_OPERATOR { $$ = createNode(NODE_UNARY_OPERATOR, $1); }
	| PLUS_OPERATOR { $$ = createNode(NODE_UNARY_OPERATOR, $1); }
	| MINUS_OPERATOR { $$ = createNode(NODE_UNARY_OPERATOR, $1); }
	| BITWISE_NOT_OPERATOR { $$ = createNode(NODE_UNARY_OPERATOR, $1); }
	| LOGICAL_NOT_OPERATOR { $$ = createNode(NODE_UNARY_OPERATOR,$1); }
	;

cast_expression
	: unary_expression { $$ = $1; }
	| LPAREN type_name RPAREN cast_expression { $$ = createNode(NODE_CAST_EXPRESSION, monostate(), $2, $4); }
	;

multiplicative_expression
	: cast_expression { $$ = $1; }
	| multiplicative_expression MULTIPLY_OPERATOR cast_expression { 
        $$ = createNode(NODE_MULTIPLICATIVE_EXPRESSION, string($2), $1, $3);
        bool b=isTypeCompatible($1->typeSpecifier, $3->typeSpecifier, "*",$1->isConst);
        if(b){
          $$->typeSpecifier = $1->typeSpecifier;  
        } }
	| multiplicative_expression DIVIDE_OPERATOR cast_expression { 
        $$ = createNode(NODE_MULTIPLICATIVE_EXPRESSION, $2, $1, $3);
        bool b=isTypeCompatible($1->typeSpecifier, $3->typeSpecifier, "/",$1->isConst);
        if(b){
          $$->typeSpecifier = $1->typeSpecifier;  
        } }
	| multiplicative_expression MODULO_OPERATOR cast_expression { 
        $$ = createNode(NODE_MULTIPLICATIVE_EXPRESSION, $2, $1, $3);
        bool b=isTypeCompatible($1->typeSpecifier, $3->typeSpecifier, "%",$1->isConst);
        if(b){
          $$->typeSpecifier = $1->typeSpecifier;  
        } }
	;

additive_expression
	: multiplicative_expression { $$ = $1; }
	| additive_expression PLUS_OPERATOR multiplicative_expression {
         $$ = createNode(NODE_ADDITIVE_EXPRESSION, $2, $1, $3);
         bool b=isTypeCompatible($1->typeSpecifier, $3->typeSpecifier, "+",$1->isConst);
        if(b){
          $$->typeSpecifier = $1->typeSpecifier;  
        } }
	| additive_expression MINUS_OPERATOR multiplicative_expression { 
        $$ = createNode(NODE_ADDITIVE_EXPRESSION, $2, $1, $3);
        bool b=isTypeCompatible($1->typeSpecifier, $3->typeSpecifier, "-",$1->isConst);
        if(b){
          $$->typeSpecifier = $1->typeSpecifier;  
        } }
	;

shift_expression
	: additive_expression { $$ = $1; }
	| shift_expression LEFT_SHIFT_OPERATOR additive_expression { 
        $$ = createNode(NODE_SHIFT_EXPRESSION, $2, $1, $3); 
        bool b=isTypeCompatible($1->typeSpecifier, $3->typeSpecifier, "<<",$1->isConst);
        if(b){
          $$->typeSpecifier = $1->typeSpecifier;  
        }}
	| shift_expression RIGHT_SHIFT_OPERATOR additive_expression {
         $$ = createNode(NODE_SHIFT_EXPRESSION, $2, $1, $3);
         bool b=isTypeCompatible($1->typeSpecifier, $3->typeSpecifier, ">>",$1->isConst);
        if(b){
          $$->typeSpecifier = $1->typeSpecifier;  
        } }
	;

relational_expression
	: shift_expression { $$ = $1; }
	| relational_expression LESS_THAN_OPERATOR shift_expression {
         $$ = createNode(NODE_RELATIONAL_EXPRESSION, $2, $1, $3);
         bool b=isTypeCompatible($1->typeSpecifier, $3->typeSpecifier, "<",$1->isConst);
        if(b){
          $$->typeSpecifier = $1->typeSpecifier;  
        } }
	| relational_expression GREATER_THAN_OPERATOR shift_expression { 
        $$ = createNode(NODE_RELATIONAL_EXPRESSION, $2, $1, $3);
        cout << "hello" << endl;
        bool b=isTypeCompatible($1->typeSpecifier, $3->typeSpecifier, ">",$1->isConst);
        if(b){
          $$->typeSpecifier = $1->typeSpecifier;  
        } }
	| relational_expression LESS_THAN_OR_EQUAL_OPERATOR shift_expression {
         $$ = createNode(NODE_RELATIONAL_EXPRESSION, $2, $1, $3); 
         bool b=isTypeCompatible($1->typeSpecifier, $3->typeSpecifier, "<+",$1->isConst);
        if(b){
          $$->typeSpecifier = $1->typeSpecifier;  
        }}
	| relational_expression GREATER_THAN_OR_EQUAL_OPERATOR shift_expression { 
        $$ = createNode(NODE_RELATIONAL_EXPRESSION, $2, $1, $3);
        bool b=isTypeCompatible($1->typeSpecifier, $3->typeSpecifier, ">=",$1->isConst);
        if(b){
          $$->typeSpecifier = $1->typeSpecifier;  
        } }
	;

equality_expression
	: relational_expression { $$ = $1; }
	| equality_expression EQUALS_COMPARISON_OPERATOR relational_expression { 
        $$ = createNode(NODE_EQUALITY_EXPRESSION, $2, $1, $3);
        bool b=isTypeCompatible($1->typeSpecifier, $3->typeSpecifier, "==",$1->isConst);
        if(b){
          $$->typeSpecifier = $1->typeSpecifier;  
        } }
	| equality_expression NOT_EQUALS_OPERATOR relational_expression { 
        $$ = createNode(NODE_EQUALITY_EXPRESSION, $2, $1, $3);
        bool b=isTypeCompatible($1->typeSpecifier, $3->typeSpecifier, "!=",$1->isConst);
        if(b){
          $$->typeSpecifier = $1->typeSpecifier;  
        } }
	;

and_expression
	: equality_expression { $$ = $1; }
	| and_expression BITWISE_AND_OPERATOR equality_expression { 
        $$ = createNode(NODE_AND_EXPRESSION, $2, $1, $3); 
        bool b=isTypeCompatible($1->typeSpecifier, $3->typeSpecifier, "&",$1->isConst);
        if(b){
          $$->typeSpecifier = $1->typeSpecifier;  
        }}
	;

exclusive_or_expression
	: and_expression { $$ = $1; }
	| exclusive_or_expression BITWISE_XOR_OPERATOR and_expression { 
        $$ = createNode(NODE_EXCLUSIVE_OR_EXPRESSION, $2, $1, $3); 
        bool b=isTypeCompatible($1->typeSpecifier, $3->typeSpecifier, "^",$1->isConst);
        if(b){
          $$->typeSpecifier = $1->typeSpecifier;  
        }}
	;

inclusive_or_expression
	: exclusive_or_expression { $$ = $1; }
	| inclusive_or_expression BITWISE_OR_OPERATOR exclusive_or_expression {
         $$ = createNode(NODE_INCLUSIVE_OR_EXPRESSION, $2, $1, $3);
         bool b=isTypeCompatible($1->typeSpecifier, $3->typeSpecifier, "|",$1->isConst);
        if(b){
          $$->typeSpecifier = $1->typeSpecifier;  
        } }
	;

logical_and_expression
	: inclusive_or_expression { $$ = $1; }
	| logical_and_expression LOGICAL_AND_OPERATOR inclusive_or_expression { 
        $$ = createNode(NODE_LOGICAL_AND_EXPRESSION, $2, $1, $3); 
        bool b=isTypeCompatible($1->typeSpecifier, $3->typeSpecifier, "&&",$1->isConst);
        if(b){
          $$->typeSpecifier = $1->typeSpecifier;  
        }}
	;

logical_or_expression
	: logical_and_expression { $$ = $1; }
	| logical_or_expression LOGICAL_OR_OPERATOR logical_and_expression { 
        $$ = createNode(NODE_LOGICAL_OR_EXPRESSION, $2, $1, $3); 
        bool b=isTypeCompatible($1->typeSpecifier, $3->typeSpecifier, "||",$1->isConst);
        if(b){
          $$->typeSpecifier = $1->typeSpecifier;  
        }}
	;

conditional_expression
	: logical_or_expression { $$ = $1; }
	| logical_or_expression TERNARY_OPERATOR expression COLON conditional_expression { $$ = createNode(NODE_CONDITIONAL_EXPRESSION, "?:", $1, $3, $5); }
	;

assignment_expression
	: conditional_expression { $$ = $1; }
	| unary_expression assignment_operator assignment_expression { 
        $$ = createNode(NODE_ASSIGNMENT_EXPRESSION, $2->value, $1, $3);
        bool b=isTypeCompatible($1->typeSpecifier, $3->typeSpecifier, string($2->valueToString()),$1->isConst);
        if(b){
          $$->typeSpecifier = $1->typeSpecifier;  
        } }
	;


assignment_operator
	: ASSIGNMENT_OPERATOR { $$ = createNode(NODE_ASSIGNMENT_OPERATOR, $1); }
	| MULTIPLY_ASSIGN_OPERATOR { $$ = createNode(NODE_ASSIGNMENT_OPERATOR, $1); }
	| DIVIDE_ASSIGN_OPERATOR { $$ = createNode(NODE_ASSIGNMENT_OPERATOR, $1); }
	| MODULO_ASSIGN_OPERATOR { $$ = createNode(NODE_ASSIGNMENT_OPERATOR, $1); }
	| PLUS_ASSIGN_OPERATOR { $$ = createNode(NODE_ASSIGNMENT_OPERATOR, $1); }
	| MINUS_ASSIGN_OPERATOR { $$ = createNode(NODE_ASSIGNMENT_OPERATOR, $1); }
	| LEFT_SHIFT_ASSIGN_OPERATOR { $$ = createNode(NODE_ASSIGNMENT_OPERATOR, $1); } 
	| RIGHT_SHIFT_ASSIGN_OPERATOR { $$ = createNode(NODE_ASSIGNMENT_OPERATOR, $1); }
	| BITWISE_AND_ASSIGN_OPERATOR { $$ = createNode(NODE_ASSIGNMENT_OPERATOR, $1); }
	| BITWISE_XOR_ASSIGN_OPERATOR { $$ = createNode(NODE_ASSIGNMENT_OPERATOR, $1); }
 	| BITWISE_OR_ASSIGN_OPERATOR { $$ = createNode(NODE_ASSIGNMENT_OPERATOR, $1); }
	;

expression
	: assignment_expression { $$ = $1; }
	| expression COMMA assignment_expression { $$ = createNode(NODE_EXPRESSION, monostate(), $1, $3); }
	;

constant_expression
	: conditional_expression { $$ = $1; }
	;

declaration
    : declaration_specifiers SEMICOLON {
        $$ = $1;
    }
    | declaration_specifiers init_declarator_list SEMICOLON 
    {
        $$ = createNode(NODE_DECLARATION, monostate(), $1, $2);
        DeclaratorInfo declInfo = isValidVariableDeclaration($1->children, false);
        if (declInfo.isValid)
        {
            auto helper = $1;
            for(auto child : $1->children){
                if(child->type == NODE_TYPE_SPECIFIER){
                    helper = child;
                    break;
                }
            }
            cout << *helper << endl;

    for (auto child : $2->children)
    {
        if (child->type != NODE_DECLARATOR) continue;

        ASTNode *firstChild = child->children[0];
        string varName;
        ASTNode *identifierNode = firstChild;
        cout << *helper << endl;
        // Helper function to set common node attributes
        auto setNodeAttributes = [&](ASTNode *node, int typeCategory, int pointerLevel = 0) {
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
        auto checkDuplicate = [&](const string &name) {
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
            while (identifierNode && identifierNode->type == ARRAY) {
                if (identifierNode->children.empty()) break;
                identifierNode = identifierNode->children[0];
            }
            varName = identifierNode->valueToString();
            if (checkDuplicate(varName)) continue;

            int size = child->children.size();
            if (size == 1 || size == 2) {
                bool validDims = all_of(dimensions.begin(), dimensions.end(), [](int d) { return d != -1; });
                if (!validDims) {
                    cerr << "Invalid declaration dimension cannot be empty\n";
                    continue;
                }
                if (size == 2 && !checkInitializerLevel(child->children[1], declInfo.typeSpecifier, dimensions, 0)) {
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
            while (identifierNode && identifierNode->type == NODE_POINTER) {
                pointerDepth++;
                if (identifierNode->children.empty()) break;
                identifierNode = identifierNode->children[0];
            }
            varName = identifierNode->valueToString();

            if (identifierNode->type == ARRAY) // Array of pointers (e.g., int *arr[3])
            {
                vector<int> dimensions = findArrayDimensions(identifierNode);
                varName = identifierNode->children[0]->valueToString();
                if (checkDuplicate(varName)) continue;

                int size = child->children.size();
                if (size == 1 || size == 2) {
                    bool validDims = all_of(dimensions.begin(), dimensions.end(), [](int d) { return d != -1; });
                    if (!validDims) {
                        cerr << "Invalid declaration dimension cannot be empty\n";
                        continue;
                    }
                    if (size == 2 && !checkInitializerLevel(child->children[1], declInfo.typeSpecifier, dimensions, pointerDepth)) {
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
                if (checkDuplicate(varName)) continue;
                int size = child->children.size();
                if (size == 1 || (size == 2 && true /* Replace with isPointerCompatible */)) {
                    setNodeAttributes(identifierNode, 1, pointerDepth);
                    insertSymbol(varName, identifierNode);
                }
                else {
                    cerr << "Error: Invalid pointer " << (size == 2 ? "initialization" : "declarator syntax") << " for '" << varName << "'\n";
                }
            }
        }
        else // Regular variable (e.g., int x)
        {
            varName = firstChild->valueToString();
            if (checkDuplicate(varName)) continue;
            int size = child->children.size();
            if (size == 1) {
                if (declInfo.isConst) {
                    cerr << "Error: Const variable '" << varName << "' must be initialized\n";
                    continue;
                }
                setNodeAttributes(identifierNode, 0);
                insertSymbol(varName, identifierNode);
            }
            else if (size == 2 && isTypeCompatible(declInfo.typeSpecifier, child->children[1]->typeSpecifier, "=")) {
                setNodeAttributes(identifierNode, 0);
                insertSymbol(varName, identifierNode);
            }
            else if(size == 2 && declInfo.typeSpecifier == 8){
                //cout << *identifierNode << endl;
                //cout << identifierNode->symbolTable.size() << endl;
                auto x = lookupSymbol(helper->valueToString());
                bool hp = structInitializerCheck(x,child->children[1]);
                if(hp)insertSymbol(varName,identifierNode);
            }
            else {
                cerr << "Error: " << (size == 2 ? "Type mismatch in initialization" : "Invalid declarator syntax") << " for '" << varName << "'\n";
            }
        }
        
}        }
    };


declaration_specifiers
	: storage_class_specifier { $$ = createNode(NODE_DECLARATION_SPECIFIERS, monostate(), $1); }
	| storage_class_specifier declaration_specifiers { 
        $$ = createNode(NODE_DECLARATION_SPECIFIERS, monostate(), $1);
        for(auto child : $2->children){
            $$->addChild(child);
        }
        // $2->addChild($1);
        // $$ = $2; 
    }
	| type_specifier { $$ = createNode(NODE_DECLARATION_SPECIFIERS, monostate(), $1);$$->storageClass = $1->storageClass;}
	| type_specifier declaration_specifiers { 
        $$ = createNode(NODE_DECLARATION_SPECIFIERS, monostate(), $1);
        for(auto child : $2->children){
            $$->addChild(child);
        }
        // $$ = $2; 
    }
	| type_qualifier { $$ = createNode(NODE_DECLARATION_SPECIFIERS, monostate(), $1); $$->storageClass = $1->storageClass;}
	| type_qualifier declaration_specifiers { 
        $$ = createNode(NODE_DECLARATION_SPECIFIERS, monostate(), $1);
        for(auto child : $2->children){
            $$->addChild(child);
        }
         
    }
	;    

init_declarator_list
    : init_declarator { 
        $$ = createNode(NODE_DECLARATOR_LIST, monostate(), $1); 
    }
    | init_declarator_list COMMA init_declarator { 
        $$ = $1;
        $$->children.push_back($3);
    }
    ;

init_declarator
    : declarator { 
        $$ = createNode(NODE_DECLARATOR, monostate(), $1, nullptr); 
    }
    | declarator ASSIGNMENT_OPERATOR initializer { 
        $$ = createNode(NODE_DECLARATOR, $2, $1, $3);   
        $$->storageClass = $3->storageClass;
    }
    ;

storage_class_specifier
    : KEYWORD_TYPEDEF   { $$ = $1; $$->type = NODE_STORAGE_CLASS_SPECIFIER; }
    | KEYWORD_EXTERN    { $$ = $1; $$->type = NODE_STORAGE_CLASS_SPECIFIER; }
    | KEYWORD_STATIC    { $$ = $1; $$->type = NODE_STORAGE_CLASS_SPECIFIER; }
    | KEYWORD_AUTO      { $$ = $1; $$->type = NODE_STORAGE_CLASS_SPECIFIER; }
    | KEYWORD_REGISTER  { $$ = $1; $$->type = NODE_STORAGE_CLASS_SPECIFIER; }
    ;


type_specifier
	: struct_type_specifier { $$ = $1; }
    | struct_or_union_specifier { $$ = $1; }
    | class_specifier { $$ = $1;}
	;

struct_type_specifier
	: KEYWORD_VOID { $$ = $1; $$->type = NODE_TYPE_SPECIFIER; $$->storageClass = 0;}
	| KEYWORD_CHAR { $$ = $1; $$->type = NODE_TYPE_SPECIFIER; $$->storageClass = 1;}
    | KEYWORD_SHORT { $$ = $1; $$->type = NODE_TYPE_SPECIFIER; $$->storageClass = 2;}
    | KEYWORD_INT { $$ = $1; $$->type = NODE_TYPE_SPECIFIER; $$->storageClass = 3;}
    | KEYWORD_BOOL { $$ = $1; $$->type = NODE_TYPE_SPECIFIER; $$->storageClass = 9;}
    | KEYWORD_LONG { $$ = $1; $$->type = NODE_TYPE_SPECIFIER; $$->storageClass = 4;}
    | KEYWORD_FLOAT { $$ = $1; $$->type = NODE_TYPE_SPECIFIER; $$->storageClass = 12;}
    | KEYWORD_DOUBLE { $$ = $1; $$->type = NODE_TYPE_SPECIFIER; $$->storageClass = 13;}
    | KEYWORD_SIGNED { $$ = $1; $$->type = NODE_TYPE_SPECIFIER; }
    | KEYWORD_UNSIGNED { $$ = $1; $$->type = NODE_TYPE_SPECIFIER; }
    | TYPE_NAME {$$ = $1; $$->type = NODE_TYPE_SPECIFIER; }
	;

class_specifier
    : KEYWORD_CLASS ID LBRACE member_declaration_list RBRACE 
        {
            classOrStructOrUnion.insert($2->valueToString());
            enterScope();
            $$ = createNode(NODE_CLASS_SPECIFIER, monostate(), $2, $4); 
            exitScope();
        }
    | KEYWORD_CLASS LBRACE member_declaration_list RBRACE
        {
            enterScope();
            $$ = createNode(NODE_CLASS_SPECIFIER, monostate(), $1, $3); 
            exitScope();
        }
    | KEYWORD_CLASS ID
        {   classOrStructOrUnion.insert($2->valueToString());
            $$ = createNode(NODE_CLASS_SPECIFIER, monostate(), $1, $2);
        }
    ;

member_declaration_list
    : member_declaration
        { $$ = createNode(NODE_MEMBER_DECLARATION_LIST, monostate(), $1); }
    | member_declaration_list member_declaration
        { $$ = $1; $$->children.push_back($2); }
    ;

member_declaration
    : access_specifier COLON
        { $$ = createNode(NODE_ACCESS_SPECIFIER, monostate(), $1); }
    | declaration
        { $$ = $1; }
    | constructor_function
        { $$ = $1; }
    | function_definition {$$ = $1;}
    | destructor_function
        { $$ = $1; }
    ;

access_specifier
    : KEYWORD_PUBLIC { $$ = $1; }
    | KEYWORD_PRIVATE { $$ = $1; }
    | KEYWORD_PROTECTED { $$ = $1; }
    ;

struct_or_union_specifier
    : struct_or_union ID {
            string varName = $2->valueToString();
            classOrStructOrUnion.insert(varName);
            auto checkDuplicate = [&](const string &name) {
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
            if(!checkDuplicate(varName)){
                insertSymbol(varName, $2);
            }
            $2->typeCategory = 4;
            enterScope();
            alphaSymbolTable[varName] = currentTable->symbolTable;
    } LBRACE struct_declaration_list RBRACE {
            $$ = createNode(NODE_STRUCT_OR_UNION_SPECIFIER,monostate(), $1, $2, $5);
            $2->symbolTable = currentTable->symbolTable;
            cout << *$2 << endl;
            exitScope();

    };

struct_or_union
    : KEYWORD_STRUCT { $$ = $1; }
    | KEYWORD_UNION { $$ = $1; }
    ;

struct_declaration_list
    : struct_declaration { 
        $$ = createNode(NODE_STRUCT_DECLARATION_LIST, monostate(), $1); 
    }
    | struct_declaration_list struct_declaration { 
        $$ = $1;
        $$->children.push_back($2);
    }
    ;

struct_declaration
    : specifier_qualifier_list struct_declarator_list SEMICOLON {
        $$ = createNode(NODE_STRUCT_DECLARATION, monostate(), $1, $2);
        DeclaratorInfo declInfo = isValidVariableDeclaration($1->children, false);
        if (declInfo.isValid)
        {
    for (auto child : $2->children)
    {
        if (child->type != NODE_DECLARATOR) continue;

        ASTNode *firstChild = child->children[0];
        string varName;
        ASTNode *identifierNode = firstChild;

        // Helper function to set common node attributes
        auto setNodeAttributes = [&](ASTNode *node, int typeCategory, int pointerLevel = 0) {
            node->typeCategory = typeCategory;
            node->pointerLevel = pointerLevel;
            node->storageClass = declInfo.storageClass;
            node->typeSpecifier = declInfo.typeSpecifier;
            node->isConst = declInfo.isConst;
            node->isStatic = declInfo.isStatic;
            node->isVolatile = declInfo.isVolatile;
            node->isUnsigned = declInfo.isUnsigned;
        };

        // Check for duplicate declaration
        auto checkDuplicate = [&](const string &name) {
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
            while (identifierNode && identifierNode->type == ARRAY) {
                if (identifierNode->children.empty()) break;
                identifierNode = identifierNode->children[0];
            }
            varName = identifierNode->valueToString();
            if (checkDuplicate(varName)) continue;

            int size = child->children.size();
            if (size == 1 || size == 2) {
                bool validDims = all_of(dimensions.begin(), dimensions.end(), [](int d) { return d != -1; });
                if (!validDims) {
                    cerr << "Invalid declaration dimension cannot be empty\n";
                    continue;
                }
                if (size == 2 && !checkInitializerLevel(child->children[1], declInfo.typeSpecifier, dimensions, 0)) {
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
            while (identifierNode && identifierNode->type == NODE_POINTER) {
                pointerDepth++;
                if (identifierNode->children.empty()) break;
                identifierNode = identifierNode->children[0];
            }
            varName = identifierNode->valueToString();

            if (identifierNode->type == ARRAY) // Array of pointers (e.g., int *arr[3])
            {
                vector<int> dimensions = findArrayDimensions(identifierNode);
                varName = identifierNode->children[0]->valueToString();
                if (checkDuplicate(varName)) continue;

                int size = child->children.size();
                if (size == 1 || size == 2) {
                    bool validDims = all_of(dimensions.begin(), dimensions.end(), [](int d) { return d != -1; });
                    if (!validDims) {
                        cerr << "Invalid declaration dimension cannot be empty\n";
                        continue;
                    }
                    if (size == 2 && !checkInitializerLevel(child->children[1], declInfo.typeSpecifier, dimensions, pointerDepth)) {
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
                if (checkDuplicate(varName)) continue;
                int size = child->children.size();
                if (size == 1 || (size == 2 && true /* Replace with isPointerCompatible */)) {
                    setNodeAttributes(identifierNode, 1, pointerDepth);
                    insertSymbol(varName, identifierNode);
                }
                else {
                    cerr << "Error: Invalid pointer " << (size == 2 ? "initialization" : "declarator syntax") << " for '" << varName << "'\n";
                }
            }
        }
        else // Regular variable (e.g., int x)
        {
            varName = firstChild->valueToString();
            if (checkDuplicate(varName)) continue;

            int size = child->children.size();
            if (size == 1) {
                if (declInfo.isConst) {
                    cerr << "Error: Const variable '" << varName << "' must be initialized\n";
                    continue;
                }
                setNodeAttributes(identifierNode, 0);
                insertSymbol(varName, identifierNode);
            }
            else if (size == 2 && isTypeCompatible(declInfo.typeSpecifier, child->children[1]->typeSpecifier, "=")) {
                setNodeAttributes(identifierNode, 0);
                insertSymbol(varName, identifierNode);
            }
            else {
                cerr << "Error: " << (size == 2 ? "Type mismatch in initialization" : "Invalid declarator syntax") << " for '" << varName << "'\n";
            }
        }
}        }
    }
    ;

specifier_qualifier_list
	: struct_type_specifier specifier_qualifier_list {$$ = $2; $2->addChild($1);}
	| struct_type_specifier { $$ = createNode(NODE_SPECIFIER_QUALIFIER_LIST, monostate(), $1); }
	| type_qualifier specifier_qualifier_list { $$ = $2; $2->addChild($1); }
	| type_qualifier { $$ = createNode(NODE_SPECIFIER_QUALIFIER_LIST, monostate(), $1); }
	;

struct_declarator_list
    : declarator { 
        ASTNode* temp = createNode(NODE_DECLARATOR, monostate(), $1);
        $$ = createNode(NODE_STRUCT_DECLARATOR_LIST, monostate(), temp); 
    }
    | struct_declarator_list COMMA declarator { 
        ASTNode* temp = createNode(NODE_DECLARATOR, monostate(), $3);
        $$->children.push_back(temp);
    }
    ;
    
type_qualifier
	: KEYWORD_CONST { $$ = $1; $$->type = NODE_TYPE_QUALIFIER; }
	| KEYWORD_VOLATILE { $$ = $1; $$->type = NODE_TYPE_QUALIFIER; }
	;

declarator
    : pointer direct_declarator { 
        ASTNode* lastPointer = $1;
        while (!lastPointer->children.empty() && lastPointer->children[0]->type == NODE_POINTER) {
            lastPointer = lastPointer->children[0];
        }
        lastPointer->addChild($2);
        // $$ = createNode(NODE_DECLARATOR, monostate(), $1);
        $$ = $1;
        $$->pointerLevel++;
    }
    | direct_declarator { 
        $$ = $1; 
    }
    ;

direct_declarator
    : ID { 
        $$ = $1;
    }
    | LPAREN declarator RPAREN { 
        $$ = $2;
    }
    | direct_declarator LBRACKET INTEGER RBRACKET { 
        $$ = createNode(ARRAY, monostate(), $1, $3); // restricted to constant expression
    }
    | direct_declarator LBRACKET RBRACKET {  // array of unknown size
        $$ = createNode(ARRAY, monostate(), $1, nullptr); 
    }
    | direct_declarator LPAREN parameter_type_list RPAREN { 
        $$ = createNode(NODE_DECLARATOR, monostate(), $1, $3); // func declaration
    }
    | direct_declarator LPAREN identifier_list RPAREN { 
        $$ = createNode(NODE_DECLARATOR, monostate(), $1, $3);  // func call??
    }
    | direct_declarator LPAREN RPAREN { 
        $$ = createNode(NODE_DECLARATOR, monostate(), $1, nullptr); 
    }
    ;

pointer
	: MULTIPLY_OPERATOR { $$ = createNode(NODE_POINTER, $1); }
	| MULTIPLY_OPERATOR type_qualifier_list { $$ = createNode(NODE_POINTER, $1, $2); }
	| MULTIPLY_OPERATOR pointer { $$ = createNode(NODE_POINTER, $1, $2); }
	| MULTIPLY_OPERATOR type_qualifier_list pointer { $$ = createNode(NODE_POINTER, $1, $2, $3); }
	;

type_qualifier_list
    : type_qualifier { 
        $$ = createNode(NODE_TYPE_QUALIFIER_LIST, monostate(), $1); 
    }
    | type_qualifier_list type_qualifier { 
        $$ = $1;
        $$->children.push_back($2);
    }
    ;

parameter_type_list
    : parameter_list { 
        $$ = $1; 
    }
    | parameter_list COMMA ELLIPSIS_OPERATOR { 
        $$ = createNode(NODE_PARAMETER_TYPE_LIST, monostate(), $1);
        $$->children.push_back($3);
    }
    ;


parameter_list
    : parameter_declaration { 
        $$ = createNode(NODE_PARAMETER_LIST, monostate(), $1); 
    }
    | parameter_list COMMA parameter_declaration { 
        $$ = $1;
        $$->children.push_back($3);
    }
    ;

parameter_declaration
	: declaration_specifiers declarator { $$ = createNode(NODE_PARAMETER_DECLARATION, monostate(), $1, $2); }
	| declaration_specifiers abstract_declarator { $$ = createNode(NODE_PARAMETER_DECLARATION, monostate(), $1, $2); }
	| declaration_specifiers { $$ = $1; }
	;

identifier_list
    : ID { 
        $$ = createNode(NODE_IDENTIFIER_LIST, monostate(), $1); 
    }
    | identifier_list COMMA ID { 
        $$ = $1;
        $$->children.push_back($3);
    }
    ;

type_name
	: specifier_qualifier_list { $$ = $1; }
	| specifier_qualifier_list abstract_declarator { $$ = createNode(NODE_TYPE_NAME, monostate(), $1, $2); }
	;

abstract_declarator
	: pointer {  $$ = $1;}
	| direct_abstract_declarator { $$ = createNode(NODE_ABSTRACT_DECLARATOR, monostate(), $1); }
	| pointer direct_abstract_declarator { $$ = createNode(NODE_ABSTRACT_DECLARATOR, monostate(), $1, $2); }
	;

direct_abstract_declarator
	: LPAREN abstract_declarator RPAREN {  $$ = $2; }
	| LBRACKET RBRACKET { $$ = createNode(NODE_DIRECT_ABSTRACT_DECLARATOR, monostate()); }
	| LBRACKET constant_expression RBRACKET {  $$ = $2; }
	| direct_abstract_declarator LBRACKET RBRACKET  {  $$ = $1; } 
	| direct_abstract_declarator LBRACKET constant_expression RBRACKET { $$ = createNode(NODE_DIRECT_ABSTRACT_DECLARATOR, monostate(), $1, $3); }
	| LPAREN RPAREN { $$ = createNode(NODE_DIRECT_ABSTRACT_DECLARATOR, monostate()); }
	| LPAREN parameter_type_list RPAREN {  $$ = $2; }
	| direct_abstract_declarator LPAREN RPAREN {  $$ = $1; }
	| direct_abstract_declarator LPAREN parameter_type_list RPAREN { $$ = createNode(NODE_DIRECT_ABSTRACT_DECLARATOR, monostate(), $1, $3); }
	;

initializer
	: assignment_expression { $$ = $1; }
	| LBRACE initializer_list RBRACE {  $$ = $2;}
	| LBRACE initializer_list COMMA RBRACE {  $$ = $2; }
	;

initializer_list
    : initializer { 
        $$ = createNode(NODE_INITIALIZER_LIST, monostate(), $1); 
    }
    | initializer_list COMMA initializer { 
        $$ = $1;
        $$->children.push_back($3);
        // int size = $$->children.size();
        // for(int i=0;i<size;i++){
        //     cout << $$->children[i]->valueToString() << " ";
        // }
    }
    ;

statement
	: labeled_statement { $$ = $1; }
	| {enterScope();} compound_statement { $$ = $2; exitScope();}
	| expression_statement { $$ = $1; }
	| selection_statement { $$ = $1; }
	| iteration_statement { $$ = $1; }
	| jump_statement { $$ = $1; }
	| try_catch_statement {$$ = $1; }
    | io_statement{$$ = $1;}
    | scope_resolution_statement { $$ = $1; }
    ;

scope_resolution_statement
    : ID SCOPE_RESOLUTION_OPERATOR ID SEMICOLON { $$ = createNode(NODE_SCOPE_RESOLUTION_STATEMENT, monostate(), $1, $3); }
    | ID SCOPE_RESOLUTION_OPERATOR ID ASSIGNMENT_OPERATOR expression SEMICOLON { $$ = createNode(NODE_SCOPE_RESOLUTION_STATEMENT, $4, $1, $3, $5); }
	;

io_statement
    : KEYWORD_PRINTF LPAREN STRING RPAREN SEMICOLON 
        { 
            $$ = createNode(NODE_IO_STATEMENT, monostate(), $1, $3); 
        }
    | KEYWORD_PRINTF LPAREN STRING COMMA argument_expression_list RPAREN SEMICOLON 
        {  
            $$ = createNode(NODE_IO_STATEMENT, monostate(), $1, $3, $5); 
        }
    | KEYWORD_SCANF LPAREN STRING COMMA argument_expression_list RPAREN SEMICOLON 
        { 
            $$ = createNode(NODE_IO_STATEMENT, monostate(), $1, $3, $5);
        }
    ;
try_catch_statement
    : KEYWORD_TRY {enterScope();} compound_statement {exitScope();} catch_clauses
    ;

catch_clauses
    : catch_clause
    | catch_clauses catch_clause
    ;

catch_clause
    : KEYWORD_CATCH LPAREN parameter_declaration RPAREN {enterScope();} compound_statement {exitScope();}
    | KEYWORD_CATCH LPAREN ELLIPSIS_OPERATOR RPAREN {enterScope();} compound_statement {exitScope();}
    ;	

labeled_statement
	: ID COLON statement { $$ = createNode(NODE_LABELED_STATEMENT, monostate(), $1, $3); }
	| KEYWORD_CASE constant_expression COLON statement { $$ = createNode(NODE_LABELED_STATEMENT,monostate(), $1, $2, $4); }
	| KEYWORD_DEFAULT COLON statement { $$ = createNode(NODE_LABELED_STATEMENT, monostate(), $1, $3); }
	;

compound_statement
    : LBRACE RBRACE { $$ = createNode(NODE_COMPOUND_STATEMENT, monostate()); }
    | LBRACE block_item_list RBRACE {$$ = $2; }
    ;

block_item_list
    : block_item { $$ = createNode(NODE_BLOCK_ITEM_LIST, monostate(), $1); }
    | block_item_list block_item { $$ = $1; $$->children.push_back($2); }
    ;

block_item
    : declaration {$$ = $1;}
    | statement {$$ = $1;}
    ;

expression_statement
	: SEMICOLON { $$ = createNode(NODE_EXPRESSION_STATEMENT, monostate()); }
	| expression SEMICOLON { $$ = $1; }
	;

selection_statement
    : KEYWORD_IF LPAREN expression RPAREN statement LOWER_THAN_ELSE 
        { $$ = createNode(NODE_SELECTION_STATEMENT,monostate(), $1, $3, $5); }
    | KEYWORD_IF LPAREN expression RPAREN statement KEYWORD_ELSE statement 
        { $$ = createNode(NODE_SELECTION_STATEMENT,monostate() , $1, $3, $5, $7); }
    | KEYWORD_SWITCH LPAREN expression RPAREN statement 
        { $$ = createNode(NODE_SELECTION_STATEMENT, monostate(), $1, $3, $5); }
    ;

iteration_statement
    : KEYWORD_WHILE LPAREN expression RPAREN statement
    | KEYWORD_DO statement KEYWORD_WHILE LPAREN expression RPAREN
    | KEYWORD_FOR LPAREN expression_statement expression_statement expression RPAREN statement
    | KEYWORD_FOR LPAREN expression_statement expression_statement expression_statement RPAREN statement
    | KEYWORD_FOR LPAREN declaration expression_statement expression RPAREN statement
    | KEYWORD_FOR LPAREN declaration expression_statement expression_statement RPAREN statement
    ;


jump_statement
	: KEYWORD_GOTO ID SEMICOLON { $$ = createNode(NODE_JUMP_STATEMENT, monostate(), $1, $2); }
	| KEYWORD_CONTINUE SEMICOLON { $$ = $1;}
	| KEYWORD_BREAK SEMICOLON { $$ = $1; }
	| KEYWORD_RETURN SEMICOLON { $$ = $1; }
	| KEYWORD_RETURN expression SEMICOLON { $$ = createNode(NODE_JUMP_STATEMENT, monostate(), $1, $2); }
	| KEYWORD_THROW STRING SEMICOLON
    | KEYWORD_THROW SEMICOLON
	;

translation_unit
    : external_declaration {
        $$ = $1;
    }
    | translation_unit external_declaration {
        $$ = createNode(NODE_TRANSLATION_UNIT, monostate(), $1, $2);
    }
    ;


external_declaration
	: function_definition { $$ = $1;}
	| declaration { $$ = $1;}
    | scope_resolution_statements {}
    ;

scope_resolution_statements
    : ID SCOPE_RESOLUTION_OPERATOR ID SEMICOLON
    | ID SCOPE_RESOLUTION_OPERATOR ID assignment_operator expression SEMICOLON
    | ID SCOPE_RESOLUTION_OPERATOR ID LPAREN RPAREN SEMICOLON
    | ID SCOPE_RESOLUTION_OPERATOR ID LPAREN argument_expression_list RPAREN SEMICOLON
    ;

constructor_function
    : ID LPAREN {enterScope();} parameter_list RPAREN compound_statement {
        $$ = createNode(NODE_CONSTRUCTOR_FUNCTION, monostate(), $1, $4, $6);
        // addFunctionParameters($4);
        exitScope();
    }
    | ID LPAREN RPAREN {enterScope();} compound_statement {
        $$ = createNode(NODE_CONSTRUCTOR_FUNCTION, monostate(), $1, $5); exitScope();
    }
    ;

function_definition
    : declaration_specifiers declarator {
        DeclaratorInfo declInfo = isValidVariableDeclaration($1->children, true);
        if (declInfo.isValid) {
            string funcName = $2->children[0]->valueToString();
            insertSymbol(funcName, $2->children[0]);
            ASTNode* funcNode = $2->children[0];
            funcNode->storageClass = declInfo.storageClass;
            funcNode->typeSpecifier = declInfo.typeSpecifier;
            funcNode->isConst = declInfo.isConst;
            funcNode->isStatic = declInfo.isStatic;
            funcNode->isVolatile = declInfo.isVolatile;
            funcNode->isUnsigned = declInfo.isUnsigned;
            funcNode->typeCategory = 3;
            enterScope();
            if($2->children.size() > 1 && $2->children[1]->type == NODE_PARAMETER_TYPE_LIST) {
            for (auto param : $2->children[1]->children) {
                if (param->type == NODE_PARAMETER_DECLARATION) {
                    string varName = param->children[1]->valueToString();
                    
                    bool isDuplicate = false;
                    for (const auto &entry : currentTable->symbolTable)
                    {
                        if (entry.first == varName)
                        {
                            cerr << "Error: Duplicate declaration of variable '" << varName << "'\n";
                            isDuplicate = true;
                            break;
                        }
                    }
                    if (isDuplicate) continue;

                    DeclaratorInfo paramInfo = isValidVariableDeclaration(param->children[0]->children, false);
                    if (paramInfo.isValid) {
                        ASTNode* varNode = param->children[1];
                        varNode->typeCategory = 0;
                        varNode->storageClass = paramInfo.storageClass;
                        varNode->typeSpecifier = paramInfo.typeSpecifier;
                        varNode->isConst = paramInfo.isConst;
                        varNode->isStatic = paramInfo.isStatic;
                        varNode->isVolatile = paramInfo.isVolatile;
                        varNode->isUnsigned = paramInfo.isUnsigned;
                        funcNode->paramTypes.push_back(varNode->typeSpecifier);
                        funcNode->paramCount++;
                        insertSymbol(varName, varNode); // Insert the parameter into the symbol table
                    }
                }
            }}                    
        }else {
            cerr << "Error: Invalid function declaration for '" << $2->children[0]->valueToString() << "'\n";
        }
    } compound_statement {
        $$ = createNode(NODE_FUNCTION_DEFINITION, monostate(), $1, $2, $4);
        if(checkInvalidReturn($4, $2->children[0]->typeSpecifier)){
            cout << "Error: Invalid return type for function '" << $2->children[0]->valueToString() << "'\n";
        }
        exitScope();
    }


destructor_function
    : BITWISE_NOT_OPERATOR ID LPAREN RPAREN {enterScope();} compound_statement {
        $$ = createNode(NODE_DESTRUCTOR_FUNCTION, monostate(),$2, $6); exitScope();
    }
    ;
%%

void yyerror(const char *s) {
    extern char *yytext;
    extern int yylineno;
    cout << "Error: " << s << " at '" << yytext << "' on line " << yylineno << endl;
}


int main(int argc, char **argv) {
    if (argc < 2) {
        cout << "Usage: " << argv[0] << " <input_file>" << endl;
        return 1;
    }

    yyin = fopen(argv[1], "r");

    if (!yyin) {
        cout << "Error opening file" << endl;
        return 1;
    }

    currentTable = new Table();
    tableStack.push(currentTable);
    offsetStack.push(0);
    allTables.push_back(currentTable);
    int result = yyparse();

    fclose(yyin);

    printAllTables();
    return 0;
}
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




    bool isValidVariableDeclaration(vector<ASTNode*>& nodes,bool isfunction = false) {
    int storageClassCount = 0;
    int typeSpecifierCount = 0; // Base types (int, char, etc.)
    int typeModifierCount = 0;  // signed, unsigned, long
    int qualifierCount = 0;

    // Valid sets for each category
    unordered_set<string> storageClasses = {
         "extern", "static", "auto", "register"
    };
    unordered_set<string> baseTypes = {
        "void", "char", "short", "int", "bool", "long", "float", "double"
    };
    unordered_set<string> typeModifiers = {
        "signed", "unsigned", "long"
    };
    unordered_set<string> qualifiers = {
        "const", "volatile"
    };

    // Track specific modifiers to enforce valid combos
    bool hasLong = false;
    bool hasSignedOrUnsigned = false;

    // Process each node
    for (const auto& node : nodes) {
        std::string val = node->valueToString();

        if (node->type == NODE_STORAGE_CLASS_SPECIFIER) {
            if (!storageClasses.count(val)) return false; // Unknown storage class
            storageClassCount++;
            if (storageClassCount > 1) return false; // Too many storage classes

        } else if (node->type == NODE_TYPE_SPECIFIER) {
            if (baseTypes.count(val)) {
                typeSpecifierCount++;
                if (val == "long") hasLong = true;
            } else if (typeModifiers.count(val)) {
                typeModifierCount++;
                if (val == "long") hasLong = true;
                if (val == "signed" || val == "unsigned") hasSignedOrUnsigned = true;
            } else {
                return false; // Unknown type specifier
            }

        } else if (node->type == NODE_TYPE_QUALIFIER) {
            if (!qualifiers.count(val)) return false; // Unknown qualifier
            qualifierCount++;

        } else {
            return false; // Unknown node type
        }
    }

    // Validate counts and combinations
    if (typeSpecifierCount == 0) return false; // Must have at least one base type
    if (typeSpecifierCount > 1) return false; // Can't have multiple base types (e.g., int float)

    // Handle type modifier rules
    if (typeModifierCount > 2) return false; // e.g., "unsigned signed long" is too many
    if (hasLong && typeModifierCount > 1 && typeSpecifierCount == 1) {
        // "long long" is valid in C++, but "long long int" is max
        if (typeModifierCount == 2 && hasSignedOrUnsigned) return false; // e.g., "unsigned long long"
    }

    // "void" can't be a variable type (only for functions)
    if(!isfunction){
        if (nodes.size() == 1 && nodes[0]->valueToString() == "void") return false;
    }
    // If we get here, the combination is valid
    return true;
}


bool isTypeCompatible(int lhstype, int rhstype, string op, bool lhsIsConst = false) {
    // Define type categories by storage class numbers
    std::unordered_set<int> integerTypes = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11}; // char to unsigned long long
    std::unordered_set<int> floatingTypes = {12, 13, 14}; // float, double, long double
    std::unordered_set<int> numericTypes = integerTypes;
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
        if (lhsIsNumeric && rhsIsNumeric) return true; // Numeric conversion
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

// Helper function to map type string to number (for testing)
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
    return -1; // Invalid type
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

%type<node> translation_unit external_declaration function_definition constructor_function destructor_function

%type<node> declaration declaration_specifiers declarator declaration_list compound_statement struct_declaration_list

%type<node> storage_class_specifier type_specifier struct_or_union_specifier struct_or_union class_specifier member_declaration_list member_declaration access_specifier

%type<node> struct_declaration struct_declarator_list struct_declarator specifier_qualifier_list type_qualifier constant_expression

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
	: ID { $$ = $1; }
	| INTEGER { $$ = $1;$$->storageClass=3;}
    | FLOAT { $$ = $1;$$->storageClass=6;}
	| STRING { $$ = $1; $$->storageClass=8;}
	| CHAR { $$ = $1;$$->storageClass=1; }
	| BOOLEAN_LITERAL {$$ = $1;$$->storageClass=3; } 
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
	| unary_operator cast_expression { $$ = createNode(NODE_UNARY_EXPRESSION, monostate(), $1, $2); }
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
        bool b=isTypeCompatible($1->storageClass, $3->storageClass, "*",$1->isConst);
        if(b){
          $$->storageClass = $1->storageClass;  
        } }
	| multiplicative_expression DIVIDE_OPERATOR cast_expression { 
        $$ = createNode(NODE_MULTIPLICATIVE_EXPRESSION, $2, $1, $3);
        bool b=isTypeCompatible($1->storageClass, $3->storageClass, "/",$1->isConst);
        if(b){
          $$->storageClass = $1->storageClass;  
        } }
	| multiplicative_expression MODULO_OPERATOR cast_expression { 
        $$ = createNode(NODE_MULTIPLICATIVE_EXPRESSION, $2, $1, $3);
        bool b=isTypeCompatible($1->storageClass, $3->storageClass, "%",$1->isConst);
        if(b){
          $$->storageClass = $1->storageClass;  
        } }
	;

additive_expression
	: multiplicative_expression { $$ = $1; }
	| additive_expression PLUS_OPERATOR multiplicative_expression {
         $$ = createNode(NODE_ADDITIVE_EXPRESSION, $2, $1, $3);
         bool b=isTypeCompatible($1->storageClass, $3->storageClass, "+",$1->isConst);
        if(b){
          $$->storageClass = $1->storageClass;  
        } }
	| additive_expression MINUS_OPERATOR multiplicative_expression { 
        $$ = createNode(NODE_ADDITIVE_EXPRESSION, $2, $1, $3);
        bool b=isTypeCompatible($1->storageClass, $3->storageClass, "-",$1->isConst);
        if(b){
          $$->storageClass = $1->storageClass;  
        } }
	;

shift_expression
	: additive_expression { $$ = $1; }
	| shift_expression LEFT_SHIFT_OPERATOR additive_expression { 
        $$ = createNode(NODE_SHIFT_EXPRESSION, $2, $1, $3); 
        bool b=isTypeCompatible($1->storageClass, $3->storageClass, "<<",$1->isConst);
        if(b){
          $$->storageClass = $1->storageClass;  
        }}
	| shift_expression RIGHT_SHIFT_OPERATOR additive_expression {
         $$ = createNode(NODE_SHIFT_EXPRESSION, $2, $1, $3);
         bool b=isTypeCompatible($1->storageClass, $3->storageClass, ">>",$1->isConst);
        if(b){
          $$->storageClass = $1->storageClass;  
        } }
	;

relational_expression
	: shift_expression { $$ = $1; }
	| relational_expression LESS_THAN_OPERATOR shift_expression {
         $$ = createNode(NODE_RELATIONAL_EXPRESSION, $2, $1, $3);
         bool b=isTypeCompatible($1->storageClass, $3->storageClass, "<",$1->isConst);
        if(b){
          $$->storageClass = $1->storageClass;  
        } }
	| relational_expression GREATER_THAN_OPERATOR shift_expression { 
        $$ = createNode(NODE_RELATIONAL_EXPRESSION, $2, $1, $3);
        bool b=isTypeCompatible($1->storageClass, $3->storageClass, ">",$1->isConst);
        if(b){
          $$->storageClass = $1->storageClass;  
        } }
	| relational_expression LESS_THAN_OR_EQUAL_OPERATOR shift_expression {
         $$ = createNode(NODE_RELATIONAL_EXPRESSION, $2, $1, $3); 
         bool b=isTypeCompatible($1->storageClass, $3->storageClass, "<+",$1->isConst);
        if(b){
          $$->storageClass = $1->storageClass;  
        }}
	| relational_expression GREATER_THAN_OR_EQUAL_OPERATOR shift_expression { 
        $$ = createNode(NODE_RELATIONAL_EXPRESSION, $2, $1, $3);
        bool b=isTypeCompatible($1->storageClass, $3->storageClass, ">=",$1->isConst);
        if(b){
          $$->storageClass = $1->storageClass;  
        } }
	;

equality_expression
	: relational_expression { $$ = $1; }
	| equality_expression EQUALS_COMPARISON_OPERATOR relational_expression { 
        $$ = createNode(NODE_EQUALITY_EXPRESSION, $2, $1, $3);
        bool b=isTypeCompatible($1->storageClass, $3->storageClass, "==",$1->isConst);
        if(b){
          $$->storageClass = $1->storageClass;  
        } }
	| equality_expression NOT_EQUALS_OPERATOR relational_expression { 
        $$ = createNode(NODE_EQUALITY_EXPRESSION, $2, $1, $3);
        bool b=isTypeCompatible($1->storageClass, $3->storageClass, "!=",$1->isConst);
        if(b){
          $$->storageClass = $1->storageClass;  
        } }
	;

and_expression
	: equality_expression { $$ = $1; }
	| and_expression BITWISE_AND_OPERATOR equality_expression { 
        $$ = createNode(NODE_AND_EXPRESSION, $2, $1, $3); 
        bool b=isTypeCompatible($1->storageClass, $3->storageClass, "&",$1->isConst);
        if(b){
          $$->storageClass = $1->storageClass;  
        }}
	;

exclusive_or_expression
	: and_expression { $$ = $1; }
	| exclusive_or_expression BITWISE_XOR_OPERATOR and_expression { 
        $$ = createNode(NODE_EXCLUSIVE_OR_EXPRESSION, $2, $1, $3); 
        bool b=isTypeCompatible($1->storageClass, $3->storageClass, "^",$1->isConst);
        if(b){
          $$->storageClass = $1->storageClass;  
        }}
	;

inclusive_or_expression
	: exclusive_or_expression { $$ = $1; }
	| inclusive_or_expression BITWISE_OR_OPERATOR exclusive_or_expression {
         $$ = createNode(NODE_INCLUSIVE_OR_EXPRESSION, $2, $1, $3);
         bool b=isTypeCompatible($1->storageClass, $3->storageClass, "|",$1->isConst);
        if(b){
          $$->storageClass = $1->storageClass;  
        } }
	;

logical_and_expression
	: inclusive_or_expression { $$ = $1; }
	| logical_and_expression LOGICAL_AND_OPERATOR inclusive_or_expression { 
        $$ = createNode(NODE_LOGICAL_AND_EXPRESSION, $2, $1, $3); 
        bool b=isTypeCompatible($1->storageClass, $3->storageClass, "&&",$1->isConst);
        if(b){
          $$->storageClass = $1->storageClass;  
        }}
	;

logical_or_expression
	: logical_and_expression { $$ = $1; }
	| logical_or_expression LOGICAL_OR_OPERATOR logical_and_expression { 
        $$ = createNode(NODE_LOGICAL_OR_EXPRESSION, $2, $1, $3); 
        bool b=isTypeCompatible($1->storageClass, $3->storageClass, "||",$1->isConst);
        if(b){
          $$->storageClass = $1->storageClass;  
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
        bool b=isTypeCompatible($1->storageClass, $3->storageClass, string($2->valueToString()),$1->isConst);
        if(b){
          $$->storageClass = $1->storageClass;  
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
        cout<<isValidVariableDeclaration($1->children,false) << endl;
        $$ = $1;
        if($$->children.size() && $$->children[0]->type == NODE_STRUCT_OR_UNION_SPECIFIER){
            for(auto child : $1->children[0]->children){
                if(child->type == NODE_STRUCT_DECLARATION_LIST){
                    enterScope();
                    addStructMembersToSymbolTable(child);
                    exitScope();
                    break;
                }else if(child->type == NODE_IDENTIFIER){
                    insertSymbol(child->valueToString(), "struct");
                }
            }
        }else{

        }
    }
    | declaration_specifiers init_declarator_list SEMICOLON {
        cout<<isValidVariableDeclaration($1->children,false) << endl;
        $$ = createNode(NODE_DECLARATION, monostate(), $1, $2);
        
        if($1->children[0]->type == NODE_STRUCT_OR_UNION_SPECIFIER){
            for(auto child : $1->children[0]->children){
                if(child->type == NODE_STRUCT_DECLARATION_LIST){
                    enterScope();
                    addStructMembersToSymbolTable(child);
                    exitScope();
                    break;
                }else if(child->type == NODE_IDENTIFIER){
                    insertSymbol(child->valueToString(), "struct");
                }
            }
        }else{
            addDeclaratorsToSymbolTable($1, $2);
        }
        cout << *$$ << endl;
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
	| type_specifier { $$ = createNode(NODE_DECLARATION_SPECIFIERS, monostate(), $1); }
	| type_specifier declaration_specifiers { 
        $$ = createNode(NODE_DECLARATION_SPECIFIERS, monostate(), $1);
        for(auto child : $2->children){
            $$->addChild(child);
        }
        // $2->addChild($1);
        // $$ = $2; 
    }
	| type_qualifier { $$ = createNode(NODE_DECLARATION_SPECIFIERS, monostate(), $1); }
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
	: KEYWORD_VOID { $$ = $1; $$->type = NODE_TYPE_SPECIFIER; }
	| KEYWORD_CHAR { $$ = $1; $$->type = NODE_TYPE_SPECIFIER; }
    | KEYWORD_SHORT { $$ = $1; $$->type = NODE_TYPE_SPECIFIER; }
    | KEYWORD_INT { $$ = $1; $$->type = NODE_TYPE_SPECIFIER; }
    | KEYWORD_BOOL { $$ = $1; $$->type = NODE_TYPE_SPECIFIER; }
    | KEYWORD_LONG { $$ = $1; $$->type = NODE_TYPE_SPECIFIER; }
    | KEYWORD_FLOAT { $$ = $1; $$->type = NODE_TYPE_SPECIFIER; }
    | KEYWORD_DOUBLE { $$ = $1; $$->type = NODE_TYPE_SPECIFIER; }
    | KEYWORD_SIGNED { $$ = $1; $$->type = NODE_TYPE_SPECIFIER; }
    | KEYWORD_UNSIGNED { $$ = $1; $$->type = NODE_TYPE_SPECIFIER; }
    | TYPE_NAME {$$ = $1; $$->type = NODE_TYPE_SPECIFIER;}
    | struct_or_union_specifier { $$ = $1; }
    | class_specifier { $$ = $1;}
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
    : struct_or_union ID LBRACE struct_declaration_list RBRACE  
        {   classOrStructOrUnion.insert($2->valueToString());
            $$ = createNode(NODE_STRUCT_OR_UNION_SPECIFIER,monostate(), $1, $2, $4); 
        }
    | struct_or_union LBRACE struct_declaration_list RBRACE  
        { $$ = createNode(NODE_STRUCT_OR_UNION_SPECIFIER, monostate(), $1, $3); }
    | struct_or_union ID 
        {   classOrStructOrUnion.insert($2->valueToString());
            $$ = createNode(NODE_STRUCT_OR_UNION_SPECIFIER,monostate(), $1, $2); 
        }
    ;

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
    }
    ;

specifier_qualifier_list
	: type_specifier specifier_qualifier_list {$$ = createNode(NODE_SPECIFIER_QUALIFIER_LIST, monostate(), $1, $2);}
	| type_specifier { $$ = $1; }
	| type_qualifier specifier_qualifier_list { $$ = createNode(NODE_SPECIFIER_QUALIFIER_LIST, monostate(), $1, $2);}
	| type_qualifier { $$ = $1; }
	;

struct_declarator_list
    : struct_declarator { 
        $$ = createNode(NODE_STRUCT_DECLARATOR_LIST, monostate(), $1); 
    }
    | struct_declarator_list COMMA struct_declarator { 
        $$ = $1;
        $$->children.push_back($3);
    }
    ;

struct_declarator
	: declarator { $$ = $1; }
	| COLON constant_expression { $$ = $2; }
	| declarator COLON constant_expression { $$ = createNode(NODE_STRUCT_DECLARATOR, monostate(), $1, $3); }
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
    | direct_declarator LBRACKET constant_expression RBRACKET { 
        $$ = createNode(ARRAY, monostate(), $1, $3);  
    }
    | direct_declarator LBRACKET RBRACKET { 
        $$ = createNode(ARRAY, monostate(), $1, nullptr); 
    }
    | direct_declarator LPAREN parameter_type_list RPAREN { 
        $$ = createNode(NODE_DECLARATOR, monostate(), $1, $3); 
    }
    | direct_declarator LPAREN identifier_list RPAREN { 
        $$ = createNode(NODE_DECLARATOR, monostate(), $1, $3); 
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
	| LBRACE initializer_list RBRACE {  $$ = $2; }
	| LBRACE initializer_list COMMA RBRACE {  $$ = $2; }
	;

initializer_list
    : initializer { 
        $$ = createNode(NODE_INITIALIZER_LIST, monostate(), $1); 
    }
    | initializer_list COMMA initializer { 
        $$ = $1;
        $$->children.push_back($3);
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

declaration_list
    : declaration { 
        $$ = createNode(NODE_DECLARATION_LIST, monostate(), $1); 
    }
    | declaration_list declaration { 
        $$ = $1;
        $$->children.push_back($2);
    } 
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
	: function_definition { $$ = $1; addFunction($$->children[0], $$->children[1]);}
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
        addFunctionParameters($4);
        exitScope();
    }
    | ID LPAREN RPAREN {enterScope();} compound_statement {
        $$ = createNode(NODE_CONSTRUCTOR_FUNCTION, monostate(), $1, $5); exitScope();
    }
    ;

function_definition
    : declaration_specifiers declarator {enterScope();}  declaration_list compound_statement {
         cout<<isValidVariableDeclaration($1->children,true) << endl;

        $$ = createNode(NODE_FUNCTION_DEFINITION, monostate(), $1, $2, $4, $5); exitScope();
        // TODO 
        // addFunctionToSymbolTable($1, $2);
    }
    | declaration_specifiers declarator {enterScope();} compound_statement {
         cout<<isValidVariableDeclaration($1->children,true) << endl;

        $$ = createNode(NODE_FUNCTION_DEFINITION, monostate(), $1, $2, $4);
        ASTNode* decl = $2;
        while(decl->type != NODE_DECLARATOR){
            decl = decl->children[0];
        }
        addFunctionParameters(decl->children[1]);
        exitScope();
    }
    ;

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

    if (result) {
        cout << "Parsing completed with errors." << endl;
        return 1;
    } else {
        cout << "Parsing completed successfully!" << endl;
    }

    printAllTables();

    return 0;
}

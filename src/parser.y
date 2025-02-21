%code requires {
	#include "../inc/ast.h"
}

%{
    #include <bits/stdc++.h>
	#include "../inc/ast.h"
    #include "../inc/symbolTable.h"
    using namespace std;
    
    void yyerror(const char *s);
    
    extern int yylex();
    extern FILE *yyin;

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
    KEYWORD_STATIC KEYWORD_STRUCT KEYWORD_SWITCH KEYWORD_THIS KEYWORD_THROW  
    KEYWORD_TRY KEYWORD_TYPEDEF KEYWORD_UNSIGNED 
    KEYWORD_VOID KEYWORD_VOLATILE KEYWORD_WHILE

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

%type<node> translation_unit external_declaration function_definition

%type<node> declaration declaration_specifiers declaration_specifier declarator declaration_list compound_statement struct_declaration_list

%type<node> storage_class_specifier type_specifier struct_specifier

%type<node> struct_declaration struct_declarator_list struct_declarator specifier_qualifier_list type_qualifier constant_expression

%type<node> type_qualifier_list parameter_type_list parameter_list parameter_declaration identifier_list type_name abstract_declarator

%type<node> initializer initializer_list direct_declarator pointer direct_abstract_declarator assignment_expression

%type<node> statement labeled_statement statement_list expression_statement selection_statement iteration_statement jump_statement

%type<node> expression init_declarator init_declarator_list conditional_expression primary_expression postfix_expression

%type<node> unary_expression unary_operator cast_expression multiplicative_expression additive_expression shift_expression

%type<node> relational_expression equality_expression and_expression exclusive_or_expression inclusive_or_expression

%type<node> logical_and_expression logical_or_expression argument_expression_list assignment_operator try_catch_statement

%start translation_unit
%%

primary_expression
	: ID { $$ = $1; }
	| INTEGER { $$ = $1; }
    | FLOAT { $$ = $1; }
	| STRING { $$ = $1; }
	| CHAR { $$ = $1; }
	| BOOLEAN_LITERAL {$$ = $1; } 
    | KEYWORD_NULLPTR {$$ = $1; }
    | KEYWORD_THIS
	| LPAREN expression RPAREN { $$ = $2; }
	;

postfix_expression
	: primary_expression { $$ = $1; }
	| postfix_expression LBRACKET expression RBRACKET { $$ = createNode(NODE_POSTFIX_EXPRESSION, monostate(), $1, $3); }
	| postfix_expression LPAREN RPAREN { $$ = createNode(NODE_POSTFIX_EXPRESSION, monostate(), $1); }
	| postfix_expression LPAREN argument_expression_list RPAREN { $$ = createNode(NODE_POSTFIX_EXPRESSION, monostate(), $1, $3); }
	| postfix_expression DOT_OPERATOR ID { $$ = createNode(NODE_POSTFIX_EXPRESSION, monostate(), $1, $3); }
	| postfix_expression POINTER_TO_MEMBER_ARROW_OPERATOR ID { $$ = createNode(NODE_POSTFIX_EXPRESSION, monostate(), $1, $3); }
    | postfix_expression POINTER_TO_MEMBER_DOT_OPERATOR ID { $$ = createNode(NODE_POSTFIX_EXPRESSION, monostate(), $1, $3); }
	| postfix_expression INCREMENT_OPERATOR { $$ = createNode(NODE_POSTFIX_EXPRESSION, monostate(), $1); }
	| postfix_expression DECREMENT_OPERATOR { $$ = createNode(NODE_POSTFIX_EXPRESSION, monostate(), $1); }
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
	: postfix_expression { $$ = $1; }
	| INCREMENT_OPERATOR unary_expression { $$ = createNode(NODE_UNARY_EXPRESSION, monostate(), $2); }
	| DECREMENT_OPERATOR unary_expression { $$ = createNode(NODE_UNARY_EXPRESSION, monostate(), $2); }
	| unary_operator cast_expression { $$ = createNode(NODE_UNARY_EXPRESSION, monostate(), $1, $2); }
	| KEYWORD_SIZEOF unary_expression { $$ = createNode(NODE_UNARY_EXPRESSION, monostate(),$1, $2); }
	| KEYWORD_SIZEOF LPAREN type_name RPAREN { $$ = createNode(NODE_UNARY_EXPRESSION, monostate(), $1, $3);}
	| KEYWORD_NEW LPAREN type_name RPAREN { $$ = createNode(NODE_UNARY_EXPRESSION, monostate(), $3); }
	| KEYWORD_NEW LPAREN type_name RPAREN LBRACKET expression RBRACKET { $$ = createNode(NODE_UNARY_EXPRESSION, monostate(), $3, $6); }
	| KEYWORD_DELETE cast_expression
	| KEYWORD_DELETE LBRACKET RBRACKET cast_expression 
	;


unary_operator
	: BITWISE_AND_OPERATOR { $$ = createNode(NODE_UNARY_OPERATOR, monostate()); }
	| MULTIPLY_OPERATOR { $$ = createNode(NODE_UNARY_OPERATOR, monostate()); }
	| PLUS_OPERATOR { $$ = createNode(NODE_UNARY_OPERATOR, monostate()); }
	| MINUS_OPERATOR { $$ = createNode(NODE_UNARY_OPERATOR, monostate()); }
	| BITWISE_NOT_OPERATOR { $$ = createNode(NODE_UNARY_OPERATOR, monostate()); }
	| LOGICAL_NOT_OPERATOR { $$ = createNode(NODE_UNARY_OPERATOR, monostate()); }
	;

cast_expression
	: unary_expression { $$ = $1; }
	| LPAREN type_name RPAREN cast_expression { $$ = createNode(NODE_CAST_EXPRESSION, monostate(), $2, $4); }
	;

multiplicative_expression
	: cast_expression { $$ = $1; }
	| multiplicative_expression MULTIPLY_OPERATOR cast_expression { $$ = createNode(NODE_MULTIPLICATIVE_EXPRESSION, monostate(), $1, $3); }
	| multiplicative_expression DIVIDE_OPERATOR cast_expression { $$ = createNode(NODE_MULTIPLICATIVE_EXPRESSION, monostate(), $1, $3); }
	| multiplicative_expression MODULO_OPERATOR cast_expression { $$ = createNode(NODE_MULTIPLICATIVE_EXPRESSION, monostate(), $1, $3); }
	;

additive_expression
	: multiplicative_expression { $$ = $1; }
	| additive_expression PLUS_OPERATOR multiplicative_expression { $$ = createNode(NODE_ADDITIVE_EXPRESSION, monostate(), $1, $3); }
	| additive_expression MINUS_OPERATOR multiplicative_expression { $$ = createNode(NODE_ADDITIVE_EXPRESSION, monostate(), $1, $3); }
	;

shift_expression
	: additive_expression { $$ = $1; }
	| shift_expression LEFT_SHIFT_OPERATOR additive_expression { $$ = createNode(NODE_SHIFT_EXPRESSION, monostate(), $1, $3); }
	| shift_expression RIGHT_SHIFT_OPERATOR additive_expression { $$ = createNode(NODE_SHIFT_EXPRESSION, monostate(), $1, $3); }
	;

relational_expression
	: shift_expression { $$ = $1; }
	| relational_expression LESS_THAN_OPERATOR shift_expression { $$ = createNode(NODE_RELATIONAL_EXPRESSION, monostate(), $1, $3); }
	| relational_expression GREATER_THAN_OPERATOR shift_expression { $$ = createNode(NODE_RELATIONAL_EXPRESSION, monostate(), $1, $3); }
	| relational_expression LESS_THAN_OR_EQUAL_OPERATOR shift_expression { $$ = createNode(NODE_RELATIONAL_EXPRESSION, monostate(), $1, $3); }
	| relational_expression GREATER_THAN_OR_EQUAL_OPERATOR shift_expression { $$ = createNode(NODE_RELATIONAL_EXPRESSION, monostate(), $1, $3); }
	;

equality_expression
	: relational_expression { $$ = $1; }
	| equality_expression EQUALS_COMPARISON_OPERATOR relational_expression { $$ = createNode(NODE_EQUALITY_EXPRESSION, monostate(), $1, $3); }
	| equality_expression NOT_EQUALS_OPERATOR relational_expression { $$ = createNode(NODE_EQUALITY_EXPRESSION, monostate(), $1, $3); }
	;

and_expression
	: equality_expression { $$ = $1; }
	| and_expression BITWISE_AND_OPERATOR equality_expression { $$ = createNode(NODE_AND_EXPRESSION, monostate(), $1, $3); }
	;

exclusive_or_expression
	: and_expression { $$ = $1; }
	| exclusive_or_expression BITWISE_XOR_OPERATOR and_expression { $$ = createNode(NODE_EXCLUSIVE_OR_EXPRESSION, monostate(), $1, $3); }
	;

inclusive_or_expression
	: exclusive_or_expression { $$ = $1; }
	| inclusive_or_expression BITWISE_OR_OPERATOR exclusive_or_expression { $$ = createNode(NODE_INCLUSIVE_OR_EXPRESSION, monostate(), $1, $3); }
	;

logical_and_expression
	: inclusive_or_expression { $$ = $1; }
	| logical_and_expression LOGICAL_AND_OPERATOR inclusive_or_expression { $$ = createNode(NODE_LOGICAL_AND_EXPRESSION, monostate(), $1, $3); }
	;

logical_or_expression
	: logical_and_expression { $$ = $1; }
	| logical_or_expression LOGICAL_OR_OPERATOR logical_and_expression { $$ = createNode(NODE_LOGICAL_OR_EXPRESSION, monostate(), $1, $3); }
	;

conditional_expression
	: logical_or_expression { $$ = $1; }
	| logical_or_expression TERNARY_OPERATOR expression COLON conditional_expression { $$ = createNode(NODE_CONDITIONAL_EXPRESSION, monostate(), $1, $3, $5); }
	;

assignment_expression
	: conditional_expression { $$ = $1; }
	| unary_expression assignment_operator assignment_expression { $$ = createNode(NODE_ASSIGNMENT_EXPRESSION, monostate(), $1, $2, $3); }
	;


assignment_operator
	: ASSIGNMENT_OPERATOR { $$ = createNode(NODE_ASSIGNMENT_OPERATOR, string($1)); }
	| MULTIPLY_ASSIGN_OPERATOR { $$ = createNode(NODE_ASSIGNMENT_OPERATOR, string($1)); }
	| DIVIDE_ASSIGN_OPERATOR { $$ = createNode(NODE_ASSIGNMENT_OPERATOR, string($1)); }
	| MODULO_ASSIGN_OPERATOR { $$ = createNode(NODE_ASSIGNMENT_OPERATOR, string($1)); }
	| PLUS_ASSIGN_OPERATOR { $$ = createNode(NODE_ASSIGNMENT_OPERATOR, string($1)); }
	| MINUS_ASSIGN_OPERATOR { $$ = createNode(NODE_ASSIGNMENT_OPERATOR, string($1)); }
	| LEFT_SHIFT_ASSIGN_OPERATOR { $$ = createNode(NODE_ASSIGNMENT_OPERATOR, string($1)); }
	| RIGHT_SHIFT_ASSIGN_OPERATOR { $$ = createNode(NODE_ASSIGNMENT_OPERATOR, string($1)); }
	| BITWISE_AND_ASSIGN_OPERATOR { $$ = createNode(NODE_ASSIGNMENT_OPERATOR, string($1)); }
	| BITWISE_XOR_ASSIGN_OPERATOR { $$ = createNode(NODE_ASSIGNMENT_OPERATOR, string($1)); }
 	| BITWISE_OR_ASSIGN_OPERATOR { $$ = createNode(NODE_ASSIGNMENT_OPERATOR, string($1)); }
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
        if(ASTNode::nodeTypeToString($$->children[0]->type) == "STRUCT_SPECIFIER"){
            addStructMembersToSymbolTable($$->children[0]);
        }
    }
    | declaration_specifiers init_declarator_list SEMICOLON {
        $$ = createNode(NODE_DECLARATION, monostate(), $1, $2);
        if(ASTNode::nodeTypeToString($1->children[0]->type) == "STRUCT_SPECIFIER"){
            addStructMembersToSymbolTable($1->children[0]);
            addStructVariablesToSymbolTable($1->children[0], $2);
        }else
		    addDeclaratorsToSymbolTable($1, $2);
    };


declaration_specifiers
    : declaration_specifier { 
        $$ = createNode(NODE_DECLARATION_SPECIFIERS, monostate(), $1); 
    }
    | declaration_specifiers declaration_specifier { 
        $$ = $1;
        $$->children.push_back($2);
    }
    ;

declaration_specifier
    : storage_class_specifier { $$ = $1; }
    | type_specifier { $$ = $1; }
    | type_qualifier { $$ = $1; }
    ;

init_declarator_list
    : init_declarator { 
        $$ = createNode(NODE_INIT_DECLARATOR_LIST, monostate(), $1); 
    }
    | init_declarator_list COMMA init_declarator { 
        $$ = $1;
        $$->children.push_back($3);
    }
    ;

init_declarator
    : declarator { 
        $$ = createNode(NODE_INIT_DECLARATOR, monostate(), $1, nullptr); 
    }

	
    | declarator ASSIGNMENT_OPERATOR initializer { 
        $$ = createNode(NODE_INIT_DECLARATOR, monostate(), $1, $3);
    }
    ;

storage_class_specifier
    : KEYWORD_TYPEDEF   { $$ = $1; }
    | KEYWORD_EXTERN    { $$ = $1; }
    | KEYWORD_STATIC    { $$ = $1; }
    | KEYWORD_AUTO      { $$ = $1; }
    | KEYWORD_REGISTER  { $$ = $1; }
    ;


type_specifier
	: KEYWORD_VOID { $$ = $1; }
	| KEYWORD_CHAR { $$ = $1; }
	| KEYWORD_SHORT { $$ = $1; }
	| KEYWORD_INT { $$ = $1;}
    | KEYWORD_BOOL { $$ = $1; }
	| KEYWORD_LONG { $$ = $1; }
	| KEYWORD_FLOAT { $$ = $1; }
	| KEYWORD_DOUBLE { $$ = $1; }
	| KEYWORD_SIGNED { $$ = $1; }
    | KEYWORD_UNSIGNED { $$ = $1; }
	| struct_specifier  { $$ = $1;}
	;

struct_specifier
    : KEYWORD_STRUCT ID LBRACE struct_declaration_list RBRACE  
        { $$ = createNode(NODE_STRUCT_SPECIFIER,monostate(), $1, $2, $4); }
    | KEYWORD_STRUCT LBRACE struct_declaration_list RBRACE  
        { $$ = createNode(NODE_STRUCT_SPECIFIER, monostate(), $1, $3); }
    | KEYWORD_STRUCT ID 
        { $$ = createNode(NODE_STRUCT_SPECIFIER,monostate(), $1, $2); }
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
	: specifier_qualifier_list struct_declarator_list SEMICOLON { $$ = createNode(NODE_STRUCT_DECLARATION, monostate(), $1, $2); }
	;

specifier_qualifier_list
	: type_specifier specifier_qualifier_list { $$ = createNode(NODE_SPECIFIER_QUALIFIER_LIST, monostate(), $1, $2); }
	| type_specifier { $$ = $1; }
	| type_qualifier specifier_qualifier_list { $$ = createNode(NODE_SPECIFIER_QUALIFIER_LIST, monostate(), $1, $2); }
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
	: KEYWORD_CONST { $$ = $1; }
	| KEYWORD_VOLATILE { $$ = $1; }
	;

declarator
    : pointer direct_declarator { 
        ASTNode* lastPointer = $1;
        while (!lastPointer->children.empty() && lastPointer->children[0]->type == NODE_POINTER) {
            lastPointer = lastPointer->children[0];
        }
        lastPointer->addChild($2);
        $$ = createNode(NODE_DECLARATOR, monostate(), $1);
    }
    | direct_declarator { 
        $$ = createNode(NODE_DECLARATOR, monostate(), $1); 
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
	: MULTIPLY_OPERATOR { $$ = createNode(NODE_POINTER, string($1)); }
	| MULTIPLY_OPERATOR type_qualifier_list { $$ = createNode(NODE_POINTER, string($1), $2); }
	| MULTIPLY_OPERATOR pointer { $$ = createNode(NODE_POINTER, string($1), $2); }
	| MULTIPLY_OPERATOR type_qualifier_list pointer { $$ = createNode(NODE_POINTER, string($1), $2, $3); }
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
	| compound_statement { $$ = $1; }
	| expression_statement { $$ = $1; }
	| selection_statement { $$ = $1; }
	| iteration_statement { $$ = $1; }
	| jump_statement { $$ = $1; }
	| try_catch_statement {$$ = $1; }
	;

try_catch_statement
    : KEYWORD_TRY compound_statement catch_clauses
    ;

catch_clauses
    : catch_clause
    | catch_clauses catch_clause
    ;

catch_clause
    : KEYWORD_CATCH LPAREN parameter_declaration RPAREN compound_statement
    | KEYWORD_CATCH LPAREN ELLIPSIS_OPERATOR RPAREN compound_statement
    ;	

labeled_statement
	: ID COLON statement { $$ = createNode(NODE_LABELED_STATEMENT, monostate(), $1, $3); }
	| KEYWORD_CASE constant_expression COLON statement { $$ = createNode(NODE_LABELED_STATEMENT,monostate(), $1, $2, $4); }
	| KEYWORD_DEFAULT COLON statement { $$ = createNode(NODE_LABELED_STATEMENT, monostate(), $1, $3); }
	;

compound_statement
	: LBRACE RBRACE { $$ = createNode(NODE_COMPOUND_STATEMENT, monostate()); }
	| LBRACE statement_list RBRACE { $$ = $2; }
	| LBRACE declaration_list RBRACE { $$ = $2; }
	| LBRACE declaration_list statement_list RBRACE { $$ = createNode(NODE_COMPOUND_STATEMENT, monostate(), $2, $3); }
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

statement_list
    : statement { 
        $$ = createNode(NODE_STATEMENT_LIST, monostate(), $1); 
    }
    | statement_list statement { 
        $$ = $1;
        $$->children.push_back($2);
    }
    ;

expression_statement
	: SEMICOLON { $$ = createNode(NODE_EXPRESSION_STATEMENT, monostate()); }
	| expression SEMICOLON { $$ = $1; }
	;

selection_statement
    : KEYWORD_IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE 
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
	: function_definition { $$ = $1; }
	| declaration { $$ = $1; }
	;

function_definition
    : declaration_specifiers declarator declaration_list compound_statement {
        $$ = createNode(NODE_FUNCTION_DEFINITION, monostate(), $1, $2, $3, $4);
        addFunctionToSymbolTable($1, $2);
    }
    | declaration_specifiers declarator compound_statement {
        $$ = createNode(NODE_FUNCTION_DEFINITION, monostate(), $1, $2, $3);
        addFunctionToSymbolTable($1, $2);
    }
    | declarator declaration_list compound_statement {
        $$ = createNode(NODE_FUNCTION_DEFINITION, monostate(), $1, $2, $3);
        addFunctionToSymbolTable(nullptr, $1);
    }
    | declarator compound_statement {
        $$ = createNode(NODE_FUNCTION_DEFINITION, monostate(), $1, $2);
        addFunctionToSymbolTable(nullptr, $1);
    }
    ;


%%

void yyerror(const char *s) {
    extern char *yytext;
    extern int yylineno;
    cerr << "Error: " << s << " at '" << yytext << "' on line " << yylineno << endl;
}


int main(int argc, char **argv) {
    if (argc < 2) {
        cerr << "Usage: " << argv[0] << " <input_file>" << endl;
        return 1;
    }

    yyin = fopen(argv[1], "r");

    if (!yyin) {
        cerr << "Error opening file" << endl;
        return 1;
    }

    int result = yyparse();

    fclose(yyin);

    if (result) {
        cerr << "Parsing completed with errors." << endl;
        return 1;
    } else {
        cout << "Parsing completed successfully!" << endl;
    }

	printSymbolTable();

    return 0;
}

%code requires {
	#include "../src/ast.h"
    #include <string>
    #include <vector>
    using std::vector;
    using std::string;
}

%{
    #include <bits/stdc++.h>
    using namespace std;
    
    void yyerror(const char *s);
    
    extern int yylex();
    extern FILE *yyin;

	vector<pair<string, string>> symbolTable;
%}


%union {
	ASTNode *node;
    char *str;
}


/* Keywords */
%token <node>
    KEYWORD_AUTO KEYWORD_BOOL KEYWORD_BREAK KEYWORD_CASE KEYWORD_CATCH KEYWORD_CHAR 
    KEYWORD_CLASS KEYWORD_CONST KEYWORD_CONTINUE KEYWORD_DEFAULT KEYWORD_DELETE KEYWORD_DO 
    KEYWORD_DOUBLE KEYWORD_ELSE KEYWORD_ENUM KEYWORD_EXTERN KEYWORD_FALSE KEYWORD_FLOAT 
    KEYWORD_FOR KEYWORD_FRIEND KEYWORD_GOTO KEYWORD_IF KEYWORD_INLINE KEYWORD_INT 
    KEYWORD_LONG KEYWORD_NAMESPACE KEYWORD_NEW KEYWORD_NULLPTR KEYWORD_PRIVATE KEYWORD_PROTECTED 
    KEYWORD_PUBLIC KEYWORD_REGISTER KEYWORD_RETURN KEYWORD_SHORT KEYWORD_SIGNED KEYWORD_SIZEOF 
    KEYWORD_STATIC KEYWORD_STRUCT KEYWORD_SWITCH KEYWORD_THIS KEYWORD_THROW KEYWORD_TRUE 
    KEYWORD_TRY KEYWORD_TYPEDEF KEYWORD_UNION KEYWORD_UNSIGNED KEYWORD_USING KEYWORD_VIRTUAL 
    KEYWORD_VOID KEYWORD_VOLATILE KEYWORD_WHILE

/* Identifiers and Literals */
%token <node> INTEGER FLOAT CHAR STRING ID ELLIPSIS_OPERATOR

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
    HASH_OPERATOR DOUBLE_HASH_OPERATOR 
    POINTER_TO_MEMBER_DOT_OPERATOR POINTER_TO_MEMBER_ARROW_OPERATOR

%nonassoc LOWER_THAN_ELSE
%nonassoc KEYWORD_ELSE

%type<node> translation_unit external_declaration function_definition

%type<node> declaration declaration_specifiers declarator declaration_list compound_statement struct_declaration_list

%type<node> storage_class_specifier type_specifier struct_or_union struct_or_union_specifier

%type<node> struct_declaration struct_declarator_list struct_declarator specifier_qualifier_list type_qualifier constant_expression

%type<node> enum_specifier enumerator_list enumerator type_qualifier_list parameter_type_list parameter_list parameter_declaration identifier_list type_name abstract_declarator

%type<node> initializer initializer_list direct_declarator pointer direct_abstract_declarator assignment_expression

%type<node> statement labeled_statement statement_list expression_statement selection_statement iteration_statement jump_statement

%type<node> expression init_declarator init_declarator_list conditional_expression primary_expression postfix_expression

%type<node> unary_expression unary_operator cast_expression multiplicative_expression additive_expression shift_expression

%type<node> relational_expression equality_expression and_expression exclusive_or_expression inclusive_or_expression

%type<node> logical_and_expression logical_or_expression argument_expression_list assignment_operator

%start translation_unit
%%

primary_expression
	: ID { $$ = $1; }
	| INTEGER { $$ = $1;}
    | FLOAT { $$ = $1; }
	| STRING { $$ = $1; }
	| CHAR { $$ = $1; }
	| LPAREN expression RPAREN { $$ = createNode(NODE_PRIMARY_EXPRESSION, monostate(), $2); }
	;

postfix_expression
	: primary_expression { $$ = $1; $$->type = (NODE_POSTFIX_EXPRESSION); }
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
	: assignment_expression { $$ = $1; $$->type = (NODE_ARGUMENT_EXPRESSION_LIST);}
	| argument_expression_list COMMA assignment_expression { $$ = createNode(NODE_ARGUMENT_EXPRESSION_LIST, monostate(), $1, $3); }
	;

unary_expression
	: postfix_expression { $$ = $1; $$->type = (NODE_UNARY_EXPRESSION); }
	| INCREMENT_OPERATOR unary_expression { $$ = createNode(NODE_UNARY_EXPRESSION, monostate(), $2); }
	| DECREMENT_OPERATOR unary_expression { $$ = createNode(NODE_UNARY_EXPRESSION, monostate(), $2); }
	| unary_operator cast_expression { $$ = createNode(NODE_UNARY_EXPRESSION, monostate(), $1, $2); }
	| KEYWORD_SIZEOF unary_expression { $$ = createNode(NODE_UNARY_EXPRESSION, monostate(),$1, $2); }
	| KEYWORD_SIZEOF LPAREN type_name RPAREN { $$ = createNode(NODE_UNARY_EXPRESSION, monostate(), $1, $3);}
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
	: unary_expression { $$ = createNode(NODE_CAST_EXPRESSION, monostate(), $1); }
	| LPAREN type_name RPAREN cast_expression { $$ = createNode(NODE_CAST_EXPRESSION, monostate(), $2, $4); }
	;

multiplicative_expression
	: cast_expression { $$ = createNode(NODE_MULTIPLICATIVE_EXPRESSION, monostate(), $1); }
	| multiplicative_expression MULTIPLY_OPERATOR cast_expression { $$ = createNode(NODE_MULTIPLICATIVE_EXPRESSION, monostate(), $1, $3); }
	| multiplicative_expression DIVIDE_OPERATOR cast_expression { $$ = createNode(NODE_MULTIPLICATIVE_EXPRESSION, monostate(), $1, $3); }
	| multiplicative_expression MODULO_OPERATOR cast_expression { $$ = createNode(NODE_MULTIPLICATIVE_EXPRESSION, monostate(), $1, $3); }
	;

additive_expression
	: multiplicative_expression { $$ = createNode(NODE_ADDITIVE_EXPRESSION, monostate(), $1); }
	| additive_expression PLUS_OPERATOR multiplicative_expression { $$ = createNode(NODE_ADDITIVE_EXPRESSION, monostate(), $1, $3); }
	| additive_expression MINUS_OPERATOR multiplicative_expression { $$ = createNode(NODE_ADDITIVE_EXPRESSION, monostate(), $1, $3); }
	;

shift_expression
	: additive_expression { $$ = createNode(NODE_SHIFT_EXPRESSION, monostate(), $1); }
	| shift_expression LEFT_SHIFT_OPERATOR additive_expression { $$ = createNode(NODE_SHIFT_EXPRESSION, monostate(), $1, $3); }
	| shift_expression RIGHT_SHIFT_OPERATOR additive_expression { $$ = createNode(NODE_SHIFT_EXPRESSION, monostate(), $1, $3); }
	;

relational_expression
	: shift_expression { $$ = createNode(NODE_RELATIONAL_EXPRESSION, monostate(), $1); }
	| relational_expression LESS_THAN_OPERATOR shift_expression { $$ = createNode(NODE_RELATIONAL_EXPRESSION, monostate(), $1, $3); }
	| relational_expression GREATER_THAN_OPERATOR shift_expression { $$ = createNode(NODE_RELATIONAL_EXPRESSION, monostate(), $1, $3); }
	| relational_expression LESS_THAN_OR_EQUAL_OPERATOR shift_expression { $$ = createNode(NODE_RELATIONAL_EXPRESSION, monostate(), $1, $3); }
	| relational_expression GREATER_THAN_OR_EQUAL_OPERATOR shift_expression { $$ = createNode(NODE_RELATIONAL_EXPRESSION, monostate(), $1, $3); }
	;

equality_expression
	: relational_expression { $$ = createNode(NODE_EQUALITY_EXPRESSION, monostate(), $1); }
	| equality_expression EQUALS_COMPARISON_OPERATOR relational_expression { $$ = createNode(NODE_EQUALITY_EXPRESSION, monostate(), $1, $3); }
	| equality_expression NOT_EQUALS_OPERATOR relational_expression { $$ = createNode(NODE_EQUALITY_EXPRESSION, monostate(), $1, $3); }
	;

and_expression
	: equality_expression { $$ = createNode(NODE_AND_EXPRESSION, monostate(), $1); }
	| and_expression BITWISE_AND_OPERATOR equality_expression { $$ = createNode(NODE_AND_EXPRESSION, monostate(), $1, $3); }
	;

exclusive_or_expression
	: and_expression { $$ = createNode(NODE_EXCLUSIVE_OR_EXPRESSION, monostate(), $1); }
	| exclusive_or_expression BITWISE_XOR_OPERATOR and_expression { $$ = createNode(NODE_EXCLUSIVE_OR_EXPRESSION, monostate(), $1, $3); }
	;

inclusive_or_expression
	: exclusive_or_expression { $$ = createNode(NODE_INCLUSIVE_OR_EXPRESSION, monostate(), $1); }
	| inclusive_or_expression BITWISE_OR_OPERATOR exclusive_or_expression { $$ = createNode(NODE_INCLUSIVE_OR_EXPRESSION, monostate(), $1, $3); }
	;

logical_and_expression
	: inclusive_or_expression { $$ = createNode(NODE_LOGICAL_AND_EXPRESSION, monostate(), $1); }
	| logical_and_expression LOGICAL_AND_OPERATOR inclusive_or_expression { $$ = createNode(NODE_LOGICAL_AND_EXPRESSION, monostate(), $1, $3); }
	;

logical_or_expression
	: logical_and_expression { $$ = createNode(NODE_LOGICAL_OR_EXPRESSION, monostate(), $1); }
	| logical_or_expression LOGICAL_OR_OPERATOR logical_and_expression { $$ = createNode(NODE_LOGICAL_OR_EXPRESSION, monostate(), $1, $3); }
	;

conditional_expression
	: logical_or_expression { $$ = createNode(NODE_CONDITIONAL_EXPRESSION, monostate(), $1); }
	| logical_or_expression TERNARY_OPERATOR expression COLON conditional_expression { $$ = createNode(NODE_CONDITIONAL_EXPRESSION, monostate(), $1, $3, $5); }
	;

assignment_expression
	: conditional_expression { $$ = createNode(NODE_ASSIGNMENT_EXPRESSION, monostate(), $1); }
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
	: assignment_expression { $$ = createNode(NODE_EXPRESSION, monostate(), $1); }
	| expression COMMA assignment_expression { $$ = createNode(NODE_EXPRESSION, monostate(), $1, $3); }
	;

constant_expression
	: conditional_expression { $$ = createNode(NODE_CONSTANT_EXPRESSION, monostate(), $1); }
	;

declaration
    : declaration_specifiers SEMICOLON {
        $$ = $1; $$->type = (NODE_DECLARATION);
    }
    | declaration_specifiers init_declarator_list SEMICOLON {
        $$ = createNode(NODE_DECLARATION, monostate(), $1, $2);
		cout << *$1 << endl;
		cout << *$2 << endl;
    };


declaration_specifiers
	: storage_class_specifier { $$ = $1; $1->type = (NODE_DECLARATION_SPECIFIERS); }
	| storage_class_specifier declaration_specifiers { $$ = createNode(NODE_DECLARATION_SPECIFIERS, monostate(), $1, $2);}
	| type_specifier { $$ = $1; $$->type = (NODE_DECLARATION_SPECIFIERS); }
	| type_specifier declaration_specifiers { $$ = createNode(NODE_DECLARATION_SPECIFIERS, monostate(), $1, $2);}
	| type_qualifier { $$ = $1; $$->type = (NODE_DECLARATION_SPECIFIERS); }
	| type_qualifier declaration_specifiers { $$ = createNode(NODE_DECLARATION_SPECIFIERS, monostate(), $1, $2);}
	;

init_declarator_list
	: init_declarator { $$ = $1; $$->type = (NODE_INIT_DECLARATOR_LIST); }
	| init_declarator_list COMMA init_declarator { $$ = createNode(NODE_INIT_DECLARATOR_LIST, monostate(), $1, $3);}
	;

init_declarator
	: declarator { $$ = $1; $$->type = (NODE_INIT_DECLARATOR); }
	| declarator ASSIGNMENT_OPERATOR initializer { $$ = createNode(NODE_INIT_DECLARATOR, monostate(), $1, $3); }
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
	| KEYWORD_LONG { $$ = $1; }
	| KEYWORD_FLOAT { $$ = $1; }
	| KEYWORD_DOUBLE { $$ = $1; }
	| KEYWORD_SIGNED { $$ = $1; }
    | KEYWORD_UNSIGNED { $$ = $1; }
	| struct_or_union_specifier  { $$ = $1; }
	| enum_specifier { $$ = $1; }
	;

struct_or_union_specifier
    : struct_or_union ID LBRACE struct_declaration_list RBRACE  
        { $$ = createNode(NODE_STRUCT_OR_UNION_SPECIFIER,monostate(), $1, $2, $4); }
    | struct_or_union LBRACE struct_declaration_list RBRACE  
        { $$ = createNode(NODE_STRUCT_OR_UNION_SPECIFIER, monostate(), $1, $3); }
    | struct_or_union ID  
        { $$ = createNode(NODE_STRUCT_OR_UNION_SPECIFIER,monostate(), $1, $2); }
    ;

struct_or_union
    : KEYWORD_STRUCT { $$ = $1; }
    | KEYWORD_UNION { $$ = $1; }
    ;


struct_declaration_list
    : struct_declaration { $$ = $1; $$->type = (NODE_STRUCT_DECLARATION_LIST); }
    | struct_declaration_list struct_declaration { $$ = createNode(NODE_STRUCT_DECLARATION_LIST, monostate(), $1, $2); }
	;

struct_declaration
	: specifier_qualifier_list struct_declarator_list SEMICOLON { $$ = createNode(NODE_STRUCT_DECLARATION, monostate(), $1, $2); }
	;

specifier_qualifier_list
	: type_specifier specifier_qualifier_list { $$ = createNode(NODE_SPECIFIER_QUALIFIER_LIST, monostate(), $1, $2); }
	| type_specifier { $$ = $1; $$->type = (NODE_SPECIFIER_QUALIFIER_LIST); }
	| type_qualifier specifier_qualifier_list { $$ = createNode(NODE_SPECIFIER_QUALIFIER_LIST, monostate(), $1, $2); }
	| type_qualifier { $$ = $1; $$->type = (NODE_SPECIFIER_QUALIFIER_LIST); }
	;

struct_declarator_list
	: struct_declarator { $$ = $1; $$->type = (NODE_STRUCT_DECLARATOR_LIST); }
	| struct_declarator_list COMMA struct_declarator { $$ = createNode(NODE_STRUCT_DECLARATOR_LIST, monostate(), $1, $3); }
	;

struct_declarator
	: declarator { $$ = $1; $$->type = (NODE_STRUCT_DECLARATOR); }
	| COLON constant_expression { $$ = $2; $$->type = (NODE_STRUCT_DECLARATOR); }
	| declarator COLON constant_expression { $$ = createNode(NODE_STRUCT_DECLARATOR, monostate(), $1, $3); }
	;

enum_specifier
	: KEYWORD_ENUM LBRACE enumerator_list RBRACE { $$ = createNode(NODE_ENUM_SPECIFIER, monostate(), $1, $3); }
	| KEYWORD_ENUM ID LBRACE enumerator_list RBRACE { $$ = createNode(NODE_ENUM_SPECIFIER, monostate(), $1, $2, $4); }
	| KEYWORD_ENUM ID { $$ = createNode(NODE_ENUM_SPECIFIER, monostate(), $1, $2); }
	;

enumerator_list
	: enumerator { $$ = $1; $$->type = (NODE_ENUMERATOR_LIST); }
	| enumerator_list COMMA enumerator { $$ = createNode(NODE_ENUMERATOR_LIST, monostate(), $1, $3); }
	;

enumerator
	: ID { $$ = $1; $$->type = (NODE_ENUMERATOR); }
	| ID ASSIGNMENT_OPERATOR constant_expression { $$ = createNode(NODE_ENUMERATOR, monostate(), $1, $3); }
	;

type_qualifier
	: KEYWORD_CONST { $$ = $1; }
	| KEYWORD_VOLATILE { $$ = $1; }
	;

declarator
	: pointer direct_declarator { $$ = createNode(NODE_DECLARATOR, monostate(), $1, $2); }
	| direct_declarator { $$ = $1; $$->type = (NODE_DECLARATOR); }
	;

direct_declarator
	: ID { $$ = $1; $$->type = (NODE_DECLARATOR); }
	| LPAREN declarator RPAREN { $$ = $2; $$->type = (NODE_DECLARATOR); }
	| direct_declarator LBRACKET constant_expression RBRACKET { $$ = createNode(ARRAY, monostate(), $1, $3); cout << "ARRAY\n";}
	| direct_declarator LBRACKET RBRACKET{ $$ = $1; $$->type = (ARRAY); }
	| direct_declarator LPAREN parameter_type_list RPAREN { $$ = createNode(NODE_DECLARATOR, monostate(), $1, $3); }
	| direct_declarator LPAREN identifier_list RPAREN { $$ = createNode(NODE_DECLARATOR, monostate(), $1, $3); }
	| direct_declarator LPAREN RPAREN { $$ = $1; $$->type = (NODE_DECLARATOR); }
	;

pointer
	: MULTIPLY_OPERATOR { $$ = createNode(NODE_POINTER, string($1)); }
	| MULTIPLY_OPERATOR type_qualifier_list { $$ = createNode(NODE_POINTER, string($1), $2); }
	| MULTIPLY_OPERATOR pointer { $$ = createNode(NODE_POINTER, string($1), $2); }
	| MULTIPLY_OPERATOR type_qualifier_list pointer { $$ = createNode(NODE_POINTER, string($1), $2, $3); }
	;

type_qualifier_list
	: type_qualifier { $$ = $1; $$->type = (NODE_TYPE_QUALIFIER_LIST); }
	| type_qualifier_list type_qualifier { $$ = createNode(NODE_TYPE_QUALIFIER_LIST, monostate(), $1, $2); }
	;


parameter_type_list
	: parameter_list { $$ = $1; $$->type = (NODE_PARAMETER_TYPE_LIST); }
	| parameter_list COMMA ELLIPSIS_OPERATOR { $$ = createNode(NODE_PARAMETER_TYPE_LIST, monostate(), $1, $3); }

	;

parameter_list
	: parameter_declaration { $$ = $1; $$->type = (NODE_PARAMETER_LIST); }
	| parameter_list COMMA parameter_declaration { $$ = createNode(NODE_PARAMETER_LIST, monostate(), $1, $3); }
	;

parameter_declaration
	: declaration_specifiers declarator { $$ = createNode(NODE_PARAMETER_DECLARATION, monostate(), $1, $2); }
	| declaration_specifiers abstract_declarator { $$ = createNode(NODE_PARAMETER_DECLARATION, monostate(), $1, $2); }
	| declaration_specifiers { $$ = $1; $$->type = (NODE_PARAMETER_DECLARATION); }
	;

identifier_list
	: ID { $$ = $1; $$->type = NODE_IDENTIFIER_LIST; }
	| identifier_list COMMA ID { $$ = createNode(NODE_IDENTIFIER_LIST, monostate(), $1, $3); }
	;

type_name
	: specifier_qualifier_list { $$ = $1;$$->type = NODE_TYPE_NAME; }
	| specifier_qualifier_list abstract_declarator { $$ = createNode(NODE_TYPE_NAME, monostate(), $1, $2); }
	;

abstract_declarator
	: pointer {  $$ = $1;$$->type = NODE_ABSTRACT_DECLARATOR; }
	| direct_abstract_declarator { $$ = createNode(NODE_ABSTRACT_DECLARATOR, monostate(), $1); }
	| pointer direct_abstract_declarator { $$ = createNode(NODE_ABSTRACT_DECLARATOR, monostate(), $1, $2); }
	;

direct_abstract_declarator
	: LPAREN abstract_declarator RPAREN {  $$ = $2; $$->type = NODE_DIRECT_ABSTRACT_DECLARATOR; }
	| LBRACKET RBRACKET { $$ = createNode(NODE_DIRECT_ABSTRACT_DECLARATOR, monostate()); }
	| LBRACKET constant_expression RBRACKET {  $$ = $2; $$->type = NODE_DIRECT_ABSTRACT_DECLARATOR; }
	| direct_abstract_declarator LBRACKET RBRACKET  {  $$ = $1; $$->type = NODE_DIRECT_ABSTRACT_DECLARATOR; } 
	| direct_abstract_declarator LBRACKET constant_expression RBRACKET { $$ = createNode(NODE_DIRECT_ABSTRACT_DECLARATOR, monostate(), $1, $3); }
	| LPAREN RPAREN { $$ = createNode(NODE_DIRECT_ABSTRACT_DECLARATOR, monostate()); }
	| LPAREN parameter_type_list RPAREN {  $$ = $2; $$->type = NODE_DIRECT_ABSTRACT_DECLARATOR;  }
	| direct_abstract_declarator LPAREN RPAREN {  $$ = $1; $$->type = NODE_DIRECT_ABSTRACT_DECLARATOR; }
	| direct_abstract_declarator LPAREN parameter_type_list RPAREN { $$ = createNode(NODE_DIRECT_ABSTRACT_DECLARATOR, monostate(), $1, $3); }
	;

initializer
	: assignment_expression { $$ = $1;$$->type = NODE_INITIALIZER; }
	| LBRACE initializer_list RBRACE {  $$ = $2;$$->type = NODE_INITIALIZER; }
	| LBRACE initializer_list COMMA RBRACE {  $$ = $2;$$->type = NODE_INITIALIZER; }
	;

initializer_list
	: initializer {  $$ = $1;$$->type = NODE_INITIALIZER_LIST; }
	| initializer_list COMMA initializer { $$ = createNode(NODE_INITIALIZER_LIST, monostate(), $1, $3); }
	;

statement
	: labeled_statement { $$ = $1; }
	| compound_statement { $$ = $1; }
	| expression_statement { $$ = $1; }
	| selection_statement { $$ = $1; }
	| iteration_statement { $$ = $1; }
	| jump_statement { $$ = $1; }
	;

labeled_statement
	: ID COLON statement { $$ = createNode(NODE_LABELED_STATEMENT, monostate(), $1, $3); }
	| KEYWORD_CASE constant_expression COLON statement { $$ = createNode(NODE_LABELED_STATEMENT,monostate(), $1, $2, $4); }
	| KEYWORD_DEFAULT COLON statement { $$ = createNode(NODE_LABELED_STATEMENT, monostate(), $1, $3); }
	;

compound_statement
	: LBRACE RBRACE { $$ = createNode(NODE_COMPOUND_STATEMENT, monostate()); }
	| LBRACE statement_list RBRACE { $$ = $2; $$->type = NODE_COMPOUND_STATEMENT; }
	| LBRACE declaration_list RBRACE { $$ = $2; $$->type = NODE_COMPOUND_STATEMENT; }
	| LBRACE declaration_list statement_list RBRACE { $$ = createNode(NODE_COMPOUND_STATEMENT, monostate(), $2, $3); }
	;

declaration_list
	: declaration { $$ = $1; }
	| declaration_list declaration { $$ = createNode(NODE_DECLARATION_LIST, monostate(), $1, $2); }
	;

statement_list
	: statement { $$ = $1; }
	| statement_list statement { $$ = createNode(NODE_STATEMENT_LIST, monostate(), $1, $2); }
	;

expression_statement
	: SEMICOLON { $$ = createNode(NODE_EXPRESSION_STATEMENT, monostate()); }
	| expression SEMICOLON { $$ = $1; $$->type = NODE_EXPRESSION_STATEMENT; }
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
        { $$ = createNode(NODE_ITERATION_STATEMENT, monostate(), $1, $3, $5); }
    | KEYWORD_DO statement KEYWORD_WHILE LPAREN expression RPAREN SEMICOLON
        { $$ = createNode(NODE_ITERATION_STATEMENT, monostate(), $1, $2, $5); }
    | KEYWORD_FOR LPAREN expression_statement expression_statement RPAREN statement
        { $$ = createNode(NODE_ITERATION_STATEMENT, monostate(), $1, $3, $4, $6); }
    | KEYWORD_FOR LPAREN expression_statement expression_statement expression RPAREN statement
        { $$ = createNode(NODE_ITERATION_STATEMENT, monostate(), $1, $3, $4, $5, $7); }
    ;

jump_statement
	: KEYWORD_GOTO ID SEMICOLON { $$ = createNode(NODE_JUMP_STATEMENT, monostate(), $1, $2); }
	| KEYWORD_CONTINUE SEMICOLON { $$ = $1; $$->type = NODE_JUMP_STATEMENT;}
	| KEYWORD_BREAK SEMICOLON { $$ = $1; $$->type = NODE_JUMP_STATEMENT; }
	| KEYWORD_RETURN SEMICOLON { $$ = $1; $$->type = NODE_JUMP_STATEMENT; }
	| KEYWORD_RETURN expression SEMICOLON { $$ = createNode(NODE_JUMP_STATEMENT, monostate(), $1, $2); }
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
	: function_definition {
		$$ = $1;
	}
	| declaration {
		$$ = $1;
	}
	;

function_definition
	: declaration_specifiers declarator declaration_list compound_statement {
		cout << 1 << endl;
		$$ = createNode(NODE_FUNCTION_DEFINITION, monostate(), $1, $2, $3, $4);
	}
	| declaration_specifiers declarator compound_statement {
		cout << 2 << endl;
		$$ = createNode(NODE_FUNCTION_DEFINITION, monostate(), $1, $2, $3);
		cout << *$1 << endl;
		cout << *$2 << endl;
		//function calls this part...
	}
	| declarator declaration_list compound_statement {
		cout << 3 << endl;
		$$ = createNode(NODE_FUNCTION_DEFINITION, monostate(), $1, $2, $3);
	}
	| declarator compound_statement {
		cout << 4 << endl;
		$$ = createNode(NODE_FUNCTION_DEFINITION, monostate(), $1, $2);
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

    return 0;
}

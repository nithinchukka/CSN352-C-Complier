%{
    #include <bits/stdc++.h>
    using namespace std;
	extern int yydebug;

    void yyerror(const char *s);
    
    extern int yylex();
    extern FILE *yyin;

%}


%union {
    int integer;
    double floating;
    char* str;
}

/* Keywords */
%token <str>
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
%token <integer> INTEGER 
%token <floating> FLOAT
%token <str> CHAR STRING ID


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
    HASH_OPERATOR DOUBLE_HASH_OPERATOR ELLIPSIS_OPERATOR
    POINTER_TO_MEMBER_DOT_OPERATOR POINTER_TO_MEMBER_ARROW_OPERATOR

%start translation_unit
%%

primary_expression
	: ID
	| qualified_id
	| INTEGER
    | FLOAT
	| STRING
	| CHAR
	| KEYWORD_TRUE  // <-- Add this line
    | KEYWORD_FALSE // <-- Add this line
    | KEYWORD_NULLPTR // <-- Add this line
    | KEYWORD_THIS
	| LPAREN expression RPAREN
	;

postfix_expression
    : primary_expression
    | postfix_expression LPAREN RPAREN
    | postfix_expression LPAREN argument_expression_list RPAREN
    | postfix_expression DOT_OPERATOR ID
    | postfix_expression POINTER_TO_MEMBER_ARROW_OPERATOR ID
    | postfix_expression INCREMENT_OPERATOR
    | postfix_expression DECREMENT_OPERATOR
    | postfix_expression LBRACKET expression RBRACKET  // Array indexing support
    | qualified_id LPAREN argument_expression_list RPAREN
    ;



argument_expression_list
	: assignment_expression
	| argument_expression_list COMMA assignment_expression
	;

unary_expression
	: postfix_expression
	| INCREMENT_OPERATOR unary_expression
	| DECREMENT_OPERATOR unary_expression
	| unary_operator cast_expression
	| KEYWORD_SIZEOF unary_expression
	| KEYWORD_SIZEOF LPAREN type_name RPAREN
	| KEYWORD_NEW type_name
    | KEYWORD_NEW type_name LBRACKET expression RBRACKET  // Array allocation
    | KEYWORD_DELETE cast_expression
    | KEYWORD_DELETE LBRACKET RBRACKET cast_expression  // Array deallocation
	;

unary_operator
	: BITWISE_AND_OPERATOR
	| MULTIPLY_OPERATOR
	| PLUS_OPERATOR
	| MINUS_OPERATOR
	| BITWISE_NOT_OPERATOR
	| LOGICAL_NOT_OPERATOR
	;

cast_expression
	: unary_expression
	| LPAREN type_name RPAREN cast_expression
	;

multiplicative_expression
	: cast_expression
	| multiplicative_expression MULTIPLY_OPERATOR cast_expression
	| multiplicative_expression DIVIDE_OPERATOR cast_expression
	| multiplicative_expression MODULO_OPERATOR cast_expression
	;

additive_expression
	: multiplicative_expression
	| additive_expression PLUS_OPERATOR multiplicative_expression
	| additive_expression MINUS_OPERATOR multiplicative_expression
	;

shift_expression
	: additive_expression
	| shift_expression LEFT_SHIFT_OPERATOR additive_expression
	| shift_expression RIGHT_SHIFT_OPERATOR additive_expression
	;

relational_expression
	: shift_expression
	| relational_expression LESS_THAN_OPERATOR shift_expression
	| relational_expression GREATER_THAN_OPERATOR shift_expression
	| relational_expression LESS_THAN_OR_EQUAL_OPERATOR shift_expression
	| relational_expression GREATER_THAN_OR_EQUAL_OPERATOR shift_expression
	;

equality_expression
	: relational_expression
	| equality_expression EQUALS_COMPARISON_OPERATOR relational_expression
	| equality_expression NOT_EQUALS_OPERATOR relational_expression
	;

and_expression
	: equality_expression
	| and_expression BITWISE_AND_OPERATOR equality_expression
	;

exclusive_or_expression
	: and_expression
	| exclusive_or_expression BITWISE_XOR_OPERATOR and_expression
	;

inclusive_or_expression
	: exclusive_or_expression
	| inclusive_or_expression BITWISE_OR_OPERATOR exclusive_or_expression
	;

logical_and_expression
	: inclusive_or_expression
	| logical_and_expression LOGICAL_AND_OPERATOR inclusive_or_expression
	;

logical_or_expression
	: logical_and_expression
	| logical_or_expression LOGICAL_OR_OPERATOR logical_and_expression
	;

conditional_expression
	: logical_or_expression
	| logical_or_expression TERNARY_OPERATOR expression COLON conditional_expression
	;

assignment_expression
    : conditional_expression
    | unary_expression assignment_operator assignment_expression
    | postfix_expression LBRACKET expression RBRACKET assignment_operator assignment_expression  // Array element assignment
    ;


assignment_operator
	: ASSIGNMENT_OPERATOR
	| MULTIPLY_ASSIGN_OPERATOR
	| DIVIDE_ASSIGN_OPERATOR
	| MODULO_ASSIGN_OPERATOR
	| PLUS_ASSIGN_OPERATOR
	| MINUS_ASSIGN_OPERATOR
	| LEFT_SHIFT_ASSIGN_OPERATOR
	| RIGHT_SHIFT_ASSIGN_OPERATOR
	| BITWISE_AND_ASSIGN_OPERATOR
	| BITWISE_XOR_ASSIGN_OPERATOR
	| BITWISE_OR_ASSIGN_OPERATOR
	;

expression
	: assignment_expression
	| expression COMMA assignment_expression
	;

constant_expression
	: conditional_expression
	| CHAR
	;

declaration
    : declaration_specifiers  SEMICOLON
    | declaration_specifiers init_declarator_list SEMICOLON
    | class_declaration
    | namespace_declaration
    ;

class_declaration
    : KEYWORD_CLASS ID class_body SEMICOLON
	| KEYWORD_CLASS ID class_body ID SEMICOLON
    | KEYWORD_CLASS ID SEMICOLON
    ;

class_body
    : LBRACE class_members RBRACE
    ;

class_members
    : /* empty */
    | class_members class_member
    ;

class_member
    : access_specifier COLON class_members
    | function_definition
    | declaration
	| KEYWORD_VIRTUAL function_definition  // <-- Add this line
    | KEYWORD_FRIEND function_definition   // <-- Add this line
    | KEYWORD_FRIEND declaration
    ;

access_specifier
    : KEYWORD_PRIVATE
    | KEYWORD_PROTECTED
    | KEYWORD_PUBLIC
    ;
namespace_declaration
    : KEYWORD_NAMESPACE ID LBRACE translation_unit RBRACE
    | KEYWORD_NAMESPACE ID SEMICOLON
    ; 



declaration_specifiers
	: storage_class_specifier
	| storage_class_specifier declaration_specifiers
	| type_specifier
	| type_specifier declaration_specifiers
	| type_qualifier
	| type_qualifier declaration_specifiers
	;

init_declarator_list
    : init_declarator
    | init_declarator_list COMMA init_declarator
    | init_declarator LBRACKET constant_expression RBRACKET  // Array declaration with a fixed size
    | init_declarator LBRACKET RBRACKET  // Dynamic array declaration
	| init_declarator ASSIGNMENT_OPERATOR STRING
    ;


init_declarator
	: declarator
	| declarator ASSIGNMENT_OPERATOR initializer
	| declarator ASSIGNMENT_OPERATOR STRING 
	;

storage_class_specifier
	: KEYWORD_TYPEDEF
	| KEYWORD_EXTERN
	| KEYWORD_STATIC
	| KEYWORD_AUTO
	| KEYWORD_REGISTER
	;

type_specifier
	: KEYWORD_VOID
	| KEYWORD_CHAR
	| KEYWORD_SHORT
	| KEYWORD_INT
	| KEYWORD_LONG
	| KEYWORD_FLOAT
	| KEYWORD_DOUBLE
	| KEYWORD_SIGNED
    | KEYWORD_UNSIGNED
	| struct_or_union_specifier
	| enum_specifier
	;

struct_or_union_specifier
	: struct_or_union ID LBRACE struct_declaration_list RBRACE
	| struct_or_union LBRACE struct_declaration_list RBRACE
	| struct_or_union ID
	;

struct_or_union
	: KEYWORD_STRUCT
	| KEYWORD_UNION
	;

struct_declaration_list
	: struct_declaration
	| struct_declaration_list struct_declaration
	;

struct_declaration
	: specifier_qualifier_list struct_declarator_list SEMICOLON
	;

specifier_qualifier_list
	: type_specifier specifier_qualifier_list
	| type_specifier
	| type_qualifier specifier_qualifier_list
	| type_qualifier
	;

struct_declarator_list
	: struct_declarator
	| struct_declarator_list COMMA struct_declarator
	;

struct_declarator
	: declarator
	| COLON constant_expression
	| declarator COLON constant_expression
	;

enum_specifier
	: KEYWORD_ENUM LBRACE enumerator_list RBRACE
	| KEYWORD_ENUM ID LBRACE enumerator_list RBRACE
	| KEYWORD_ENUM ID
	;

enumerator_list
	: enumerator
	| enumerator_list COMMA enumerator
	;

enumerator
	: ID
	| ID ASSIGNMENT_OPERATOR constant_expression
	;

type_qualifier
	: KEYWORD_CONST
	| KEYWORD_VOLATILE
	;

declarator
	: pointer direct_declarator
	| direct_declarator
	;
qualified_id
    : ID
    | qualified_id SCOPE_RESOLUTION_OPERATOR ID
    ;


direct_declarator
    : qualified_id
    | scope_resolution_operator ID
    | LPAREN declarator RPAREN
    | direct_declarator LBRACKET constant_expression RBRACKET
    | direct_declarator LBRACKET RBRACKET
    | direct_declarator LBRACKET constant_expression RBRACKET direct_declarator  // Multi-dimensional array support
    | direct_declarator LPAREN parameter_type_list RPAREN
    | direct_declarator LPAREN identifier_list RPAREN
    | direct_declarator LPAREN RPAREN
    ;


scope_resolution_operator
    : SCOPE_RESOLUTION_OPERATOR ID
    | scope_resolution_operator SCOPE_RESOLUTION_OPERATOR ID
    ;


pointer
	: MULTIPLY_OPERATOR
	| MULTIPLY_OPERATOR type_qualifier_list
	| MULTIPLY_OPERATOR pointer
	| MULTIPLY_OPERATOR type_qualifier_list pointer
	;

type_qualifier_list
	: type_qualifier
	| type_qualifier_list type_qualifier
	;


parameter_type_list
	: parameter_list
	| parameter_list COMMA ELLIPSIS_OPERATOR
	;

parameter_list
	: parameter_declaration
	| parameter_list COMMA parameter_declaration
	;

parameter_declaration
	: declaration_specifiers declarator
	| declaration_specifiers abstract_declarator
	| declaration_specifiers
	;

identifier_list
	: ID
	| identifier_list COMMA ID
	;

type_name
	: specifier_qualifier_list
	| specifier_qualifier_list abstract_declarator
	;

abstract_declarator
	: pointer
	| direct_abstract_declarator
	| pointer direct_abstract_declarator
	;

direct_abstract_declarator
	: LPAREN abstract_declarator RPAREN
	| LBRACKET RBRACKET
	| LBRACKET constant_expression RBRACKET
	| direct_abstract_declarator LBRACKET RBRACKET
	| direct_abstract_declarator LBRACKET constant_expression RBRACKET
	| LPAREN RPAREN
	| LPAREN parameter_type_list RPAREN
	| direct_abstract_declarator LPAREN RPAREN
	| direct_abstract_declarator LPAREN parameter_type_list RPAREN
	;

initializer
    : assignment_expression
    | LBRACE initializer_list RBRACE
    | LBRACE initializer_list COMMA RBRACE
    | LBRACE RBRACE  // Support empty array initialization
    ;


initializer_list
	: initializer
	| initializer_list COMMA initializer
	;

statement
	: labeled_statement
	| compound_statement
	| expression_statement
	| selection_statement
	| iteration_statement
	| jump_statement
	| try_catch_statement 
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
    | KEYWORD_CATCH LPAREN ELLIPSIS_OPERATOR RPAREN compound_statement  // Catch-all handler
    ;
labeled_statement
	: ID COLON statement
	| KEYWORD_CASE constant_expression COLON statement
	| KEYWORD_DEFAULT COLON statement
	;

compound_statement
	: LBRACE RBRACE
	| LBRACE statement_list RBRACE
	| LBRACE declaration_list RBRACE
	| LBRACE declaration_list statement_list RBRACE
	;

declaration_list
	: declaration
	| declaration_list declaration
	;

statement_list
	: statement
	| statement_list statement
	;

expression_statement
	: SEMICOLON
	| expression SEMICOLON
	;

selection_statement
	: KEYWORD_IF LPAREN expression RPAREN statement
	| KEYWORD_IF LPAREN expression RPAREN statement KEYWORD_ELSE statement
	| KEYWORD_SWITCH LPAREN expression RPAREN statement
	;

iteration_statement
	: KEYWORD_WHILE LPAREN expression RPAREN statement
	| KEYWORD_DO statement KEYWORD_WHILE LPAREN expression RPAREN SEMICOLON
	| KEYWORD_FOR LPAREN expression_statement expression_statement RPAREN statement
	| KEYWORD_FOR LPAREN expression_statement expression_statement expression RPAREN statement
	| KEYWORD_FOR LPAREN declaration expression_statement RPAREN statement   // Added support for variable declaration inside for loop
	| KEYWORD_FOR LPAREN declaration expression_statement expression RPAREN statement  // Added support for variable declaration inside for loop
	;


jump_statement
    : KEYWORD_GOTO ID SEMICOLON
    | KEYWORD_CONTINUE SEMICOLON
    | KEYWORD_BREAK SEMICOLON
    | KEYWORD_RETURN SEMICOLON
    | KEYWORD_RETURN expression SEMICOLON
    | KEYWORD_THROW expression SEMICOLON
    | KEYWORD_THROW STRING SEMICOLON   // Allow `throw "Exception!"`
    | KEYWORD_THROW SEMICOLON
    ;

translation_unit
	: external_declaration
	| translation_unit external_declaration
    | translation_unit namespace_declaration
	;

external_declaration
	: function_definition
	| declaration
	;
constructor_initializer
    : COLON mem_initializer_list
    ;

mem_initializer_list
    : mem_initializer
    | mem_initializer_list COMMA mem_initializer
    ;

mem_initializer
    : ID LPAREN argument_expression_list RPAREN
    | ID LPAREN RPAREN
    ;
function_definition
    : declaration_specifiers declarator constructor_initializer declaration_list compound_statement
    | declaration_specifiers declarator constructor_initializer compound_statement
    | declaration_specifiers declarator declaration_list compound_statement
    | declaration_specifiers declarator compound_statement
    | declarator constructor_initializer declaration_list compound_statement
    | declarator constructor_initializer compound_statement
    | declarator declaration_list compound_statement
    | declarator compound_statement
	| scope_resolution_operator declarator compound_statement
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

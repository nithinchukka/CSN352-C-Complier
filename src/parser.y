%{
    #include <bits/stdc++.h>
    using namespace std;

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
	| INTEGER
    | FLOAT
	| STRING
	| LPAREN expression RPAREN
	;

postfix_expression
	: primary_expression
	| postfix_expression LBRACKET expression RBRACKET
	| postfix_expression LPAREN RPAREN
	| postfix_expression LPAREN argument_expression_list RPAREN
	| postfix_expression DOT_OPERATOR ID
	| postfix_expression POINTER_TO_MEMBER_ARROW_OPERATOR ID
    | postfix_expression POINTER_TO_MEMBER_DOT_OPERATOR ID
	| postfix_expression INCREMENT_OPERATOR
	| postfix_expression DECREMENT_OPERATOR
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
	;

declaration
	: declaration_specifiers SEMICOLON
	| declaration_specifiers init_declarator_list SEMICOLON
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
	;

init_declarator
	: declarator
	| declarator ASSIGNMENT_OPERATOR initializer
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
    | ID
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

direct_declarator
	: ID
	| LPAREN declarator RPAREN
	| direct_declarator LBRACKET constant_expression RBRACKET
	| direct_declarator LBRACKET RBRACKET
	| direct_declarator LPAREN parameter_type_list RPAREN
	| direct_declarator LPAREN identifier_list RPAREN
	| direct_declarator LPAREN RPAREN
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
	;

jump_statement
	: KEYWORD_GOTO ID SEMICOLON
	| KEYWORD_CONTINUE SEMICOLON
	| KEYWORD_BREAK SEMICOLON
	| KEYWORD_RETURN SEMICOLON
	| KEYWORD_RETURN expression SEMICOLON
	;

translation_unit
	: external_declaration
	| translation_unit external_declaration
	;

external_declaration
	: function_definition
	| declaration
	;

function_definition
	: declaration_specifiers declarator declaration_list compound_statement
	| declaration_specifiers declarator compound_statement
	| declarator declaration_list compound_statement
	| declarator compound_statement
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

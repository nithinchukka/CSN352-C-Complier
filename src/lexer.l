%option noyywrap yylineno

digit   [0-9]
digits  {digit}+
alpha   [A-Za-z]
integer     {digits}
float       {digits}"."{digits}([eE][+-]?{digits})?
id      ({alpha}|_)({alpha}|{digit}|_)*
char    \'([^\'\\]|\\.)\'
string  \"([^\"\\]|\\.)*\"
space   [ \t\v\f\n]+

%{
    #include "y.tab.hh"
    unordered_set<string> classOrStructOrUnion;
%}

%%
"//"[^\n]*    {/* Ignore Single Line Comments */}
"/*"            {
                    // Ignore Multi Line Comments
                    int c;
                    while((c = yyinput()) != 0){
                        if(c == '\n')
                            continue;
                        else if(c == '*'){
                            if((c = yyinput()) == '/')
                                break;
                            else
                                unput(c);
                        }
                    }
                }

auto        { yylval.node = createNode(NODE_KEYWORD, string(yytext)); return (KEYWORD_AUTO); }
break       { yylval.node = createNode(NODE_KEYWORD, string(yytext)); return (KEYWORD_BREAK); }
case        { yylval.node = createNode(NODE_KEYWORD, string(yytext)); return (KEYWORD_CASE); }
char        { yylval.node = createNode(NODE_KEYWORD, string(yytext)); yylval.node->offset = 1; return (KEYWORD_CHAR); }
const       { yylval.node = createNode(NODE_KEYWORD, string(yytext)); return (KEYWORD_CONST); }
continue    { yylval.node = createNode(NODE_KEYWORD, string(yytext)); return (KEYWORD_CONTINUE); }
default     { yylval.node = createNode(NODE_KEYWORD, string(yytext)); return (KEYWORD_DEFAULT); }
delete      { yylval.node = createNode(NODE_KEYWORD, string(yytext)); return (KEYWORD_DELETE); }
do          { yylval.node = createNode(NODE_KEYWORD, string(yytext)); return (KEYWORD_DO); }
double      { yylval.node = createNode(NODE_KEYWORD, string(yytext)); yylval.node->offset = 8; return (KEYWORD_DOUBLE); }
else        { yylval.node = createNode(NODE_KEYWORD, string(yytext)); return (KEYWORD_ELSE); }
extern      { yylval.node = createNode(NODE_KEYWORD, string(yytext)); return (KEYWORD_EXTERN); }
float       { yylval.node = createNode(NODE_KEYWORD, string(yytext)); yylval.node->offset = 4; return (KEYWORD_FLOAT); }
for         { yylval.node = createNode(NODE_KEYWORD, string(yytext)); return (KEYWORD_FOR); }
goto        { yylval.node = createNode(NODE_KEYWORD, string(yytext)); return (KEYWORD_GOTO); }
if          { yylval.node = createNode(NODE_KEYWORD, string(yytext)); return (KEYWORD_IF); }
int         { yylval.node = createNode(NODE_KEYWORD, string(yytext)); yylval.node->offset = 4; return (KEYWORD_INT); }
long        { yylval.node = createNode(NODE_KEYWORD, string(yytext)); yylval.node->offset = 8; return (KEYWORD_LONG); }
new         { yylval.node = createNode(NODE_KEYWORD, string(yytext)); return (KEYWORD_NEW); }
nullptr     { yylval.node = createNode(NODE_KEYWORD, string(yytext)); return (KEYWORD_NULLPTR); }
register    { yylval.node = createNode(NODE_KEYWORD, string(yytext)); return (KEYWORD_REGISTER); }
return      { yylval.node = createNode(NODE_KEYWORD, string(yytext)); return (KEYWORD_RETURN); }
short       { yylval.node = createNode(NODE_KEYWORD, string(yytext)); yylval.node->offset = 2; return (KEYWORD_SHORT); }
signed      { yylval.node = createNode(NODE_KEYWORD, string(yytext)); return (KEYWORD_SIGNED); }
sizeof      { yylval.node = createNode(NODE_KEYWORD, string(yytext)); return (KEYWORD_SIZEOF); }
static      { yylval.node = createNode(NODE_KEYWORD, string(yytext)); return (KEYWORD_STATIC); }
struct      { yylval.node = createNode(NODE_KEYWORD, string(yytext)); return (KEYWORD_STRUCT); }
switch      { yylval.node = createNode(NODE_KEYWORD, string(yytext)); return (KEYWORD_SWITCH); }
this        { yylval.node = createNode(NODE_KEYWORD, string(yytext)); return (KEYWORD_THIS); }
typedef     { yylval.node = createNode(NODE_KEYWORD, string(yytext)); return (KEYWORD_TYPEDEF); }
union       { yylval.node = createNode(NODE_KEYWORD, string(yytext)); return (KEYWORD_UNION); }
unsigned    { yylval.node = createNode(NODE_KEYWORD, string(yytext)); return (KEYWORD_UNSIGNED); }
void        { yylval.node = createNode(NODE_KEYWORD, string(yytext)); return (KEYWORD_VOID); }
volatile    { yylval.node = createNode(NODE_KEYWORD, string(yytext)); return (KEYWORD_VOLATILE); }
while       { yylval.node = createNode(NODE_KEYWORD, string(yytext)); return (KEYWORD_WHILE); }
"printf"    { yylval.node = createNode(NODE_KEYWORD, string("printf")); return (KEYWORD_PRINTF); }
"scanf"     { yylval.node = createNode(NODE_KEYWORD, string("scanf")); return (KEYWORD_SCANF); }

"+"         { yylval.str = strdup(yytext); return (PLUS_OPERATOR); }
"-"         { yylval.str = strdup(yytext); return (MINUS_OPERATOR); }
"*"         { yylval.str = strdup(yytext); return (MULTIPLY_OPERATOR); }
"/"         { yylval.str = strdup(yytext); return (DIVIDE_OPERATOR); }
"%"         { yylval.str = strdup(yytext); return (MODULO_OPERATOR); }
"--"        { yylval.str = strdup(yytext); return (DECREMENT_OPERATOR); }
"++"        { yylval.str = strdup(yytext); return (INCREMENT_OPERATOR); }

"="         { yylval.str = strdup(yytext); return (ASSIGNMENT_OPERATOR); }
"+="        { yylval.str = strdup(yytext); return (PLUS_ASSIGN_OPERATOR); }
"-="        { yylval.str = strdup(yytext); return (MINUS_ASSIGN_OPERATOR); }
"*="        { yylval.str = strdup(yytext); return (MULTIPLY_ASSIGN_OPERATOR); }
"/="        { yylval.str = strdup(yytext); return (DIVIDE_ASSIGN_OPERATOR); }
"%="        { yylval.str = strdup(yytext); return (MODULO_ASSIGN_OPERATOR); }
"&="        { yylval.str = strdup(yytext); return (BITWISE_AND_ASSIGN_OPERATOR); }
"|="        { yylval.str = strdup(yytext); return (BITWISE_OR_ASSIGN_OPERATOR); }
"^="        { yylval.str = strdup(yytext); return (BITWISE_XOR_ASSIGN_OPERATOR); }
">>="       { yylval.str = strdup(yytext); return (RIGHT_SHIFT_ASSIGN_OPERATOR); }
"<<="       { yylval.str = strdup(yytext); return (LEFT_SHIFT_ASSIGN_OPERATOR); }

"=="        { yylval.str = strdup(yytext); return (EQUALS_COMPARISON_OPERATOR); }
"!="        { yylval.str = strdup(yytext); return (NOT_EQUALS_OPERATOR); }
">"         { yylval.str = strdup(yytext); return (GREATER_THAN_OPERATOR); }
"<"         { yylval.str = strdup(yytext); return (LESS_THAN_OPERATOR); }
">="        { yylval.str = strdup(yytext); return (GREATER_THAN_OR_EQUAL_OPERATOR); }
"<="        { yylval.str = strdup(yytext); return (LESS_THAN_OR_EQUAL_OPERATOR); }

"&&"        { yylval.str = strdup(yytext); return (LOGICAL_AND_OPERATOR); }
"||"        { yylval.str = strdup(yytext); return (LOGICAL_OR_OPERATOR); }
"!"         { yylval.str = strdup(yytext); return (LOGICAL_NOT_OPERATOR); }

"&"         { yylval.str = strdup(yytext); return (BITWISE_AND_OPERATOR); }
"|"         { yylval.str = strdup(yytext); return (BITWISE_OR_OPERATOR); }
"^"         { yylval.str = strdup(yytext); return (BITWISE_XOR_OPERATOR); }
"<<"        { yylval.str = strdup(yytext); return (LEFT_SHIFT_OPERATOR); }
">>"        { yylval.str = strdup(yytext); return (RIGHT_SHIFT_OPERATOR); }
"~"         { yylval.str = strdup(yytext); return (BITWISE_NOT_OPERATOR); }

"?"         { yylval.str = strdup(yytext); return (TERNARY_OPERATOR); }

"."         { yylval.str = strdup(yytext); return (DOT_OPERATOR); }
"::"        { yylval.str = strdup(yytext); return (SCOPE_RESOLUTION_OPERATOR); }

"..."       { yylval.node = createNode(NODE_ELLIPSIS, string(yytext)); return (ELLIPSIS_OPERATOR); }

".*"        { yylval.str = strdup(yytext); return (POINTER_TO_MEMBER_DOT_OPERATOR); }
"->*"       { yylval.str = strdup(yytext); return (POINTER_TO_MEMBER_ARROW_OPERATOR); }

{integer}   { yylval.node = createNode(INTEGER_LITERAL, yytext); return INTEGER; }
{float}     { yylval.node = createNode(FLOAT_LITERAL, yytext); return FLOAT; }
{char}      { yylval.node = createNode(NODE_CHAR_LITERAL, yytext); return (CHAR); }
{string}    { yylval.node = createNode(NODE_STRING_LITERAL, string(yytext)); return (STRING); }
{id}        { if(classOrStructOrUnion.count(yytext) > 0){
                    yylval.node = createNode(NODE_TYPE, yytext); 
                    return (TYPE_NAME);
                }
                else{
                    yylval.node = createNode(NODE_IDENTIFIER, yytext); 
                    return (ID); 
                }
            }


";"         { yylval.str = strdup(yytext); return (SEMICOLON); }
":"         { yylval.str = strdup(yytext); return (COLON); }
","         { yylval.str = strdup(yytext); return (COMMA); }
"{"         { yylval.str = strdup(yytext); return (LBRACE); }
"}"         { yylval.str = strdup(yytext); return (RBRACE); }
"("         { yylval.str = strdup(yytext); return (LPAREN); }
")"         { yylval.str = strdup(yytext); return (RPAREN); }
"["         { yylval.str = strdup(yytext); return (LBRACKET); }
"]"         { yylval.str = strdup(yytext); return (RBRACKET); }

{space}   { /* Ignore Spaces */ }
.         { printf("Unrecognized Token: %s at line no: %d\n", yytext, yylineno); }
%%s
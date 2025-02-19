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

auto        { yylval.str = strdup(yytext); return (KEYWORD_AUTO); }
bool        { yylval.str = strdup(yytext); return (KEYWORD_BOOL); }
break       { yylval.str = strdup(yytext); return (KEYWORD_BREAK); }
case        { yylval.str = strdup(yytext); return (KEYWORD_CASE); }
catch       { yylval.str = strdup(yytext); return (KEYWORD_CATCH); }
char        { yylval.str = strdup(yytext); return (KEYWORD_CHAR); }
class       { yylval.str = strdup(yytext); return (KEYWORD_CLASS); }
const       { yylval.str = strdup(yytext); return (KEYWORD_CONST); }
continue    { yylval.str = strdup(yytext); return (KEYWORD_CONTINUE); }
default     { yylval.str = strdup(yytext); return (KEYWORD_DEFAULT); }
delete      { yylval.str = strdup(yytext); return (KEYWORD_DELETE); }
do          { yylval.str = strdup(yytext); return (KEYWORD_DO); }
double      { yylval.str = strdup(yytext); return (KEYWORD_DOUBLE); }
else        { yylval.str = strdup(yytext); return (KEYWORD_ELSE); }
enum        { yylval.str = strdup(yytext); return (KEYWORD_ENUM); }
extern      { yylval.str = strdup(yytext); return (KEYWORD_EXTERN); }
false       { yylval.str = strdup(yytext); return (KEYWORD_FALSE); }
float       { yylval.str = strdup(yytext); return (KEYWORD_FLOAT); }
for         { yylval.str = strdup(yytext); return (KEYWORD_FOR); }
friend      { yylval.str = strdup(yytext); return (KEYWORD_FRIEND); }
goto        { yylval.str = strdup(yytext); return (KEYWORD_GOTO); }
if          { yylval.str = strdup(yytext); return (KEYWORD_IF); }
inline      { yylval.str = strdup(yytext); return (KEYWORD_INLINE); }
int         { yylval.str = strdup(yytext); return (KEYWORD_INT); }
long        { yylval.str = strdup(yytext); return (KEYWORD_LONG); }
namespace   { yylval.str = strdup(yytext); return (KEYWORD_NAMESPACE); }
new         { yylval.str = strdup(yytext); return (KEYWORD_NEW); }
nullptr     { yylval.str = strdup(yytext); return (KEYWORD_NULLPTR); }
private     { yylval.str = strdup(yytext); return (KEYWORD_PRIVATE); }
protected   { yylval.str = strdup(yytext); return (KEYWORD_PROTECTED); }
public      { yylval.str = strdup(yytext); return (KEYWORD_PUBLIC); }
register    { yylval.str = strdup(yytext); return (KEYWORD_REGISTER); }
return      { yylval.str = strdup(yytext); return (KEYWORD_RETURN); }
short       { yylval.str = strdup(yytext); return (KEYWORD_SHORT); }
signed      { yylval.str = strdup(yytext); return (KEYWORD_SIGNED); }
sizeof      { yylval.str = strdup(yytext); return (KEYWORD_SIZEOF); }
static      { yylval.str = strdup(yytext); return (KEYWORD_STATIC); }
struct      { yylval.str = strdup(yytext); return (KEYWORD_STRUCT); }
switch      { yylval.str = strdup(yytext); return (KEYWORD_SWITCH); }
this        { yylval.str = strdup(yytext); return (KEYWORD_THIS); }
throw       { yylval.str = strdup(yytext); return (KEYWORD_THROW); }
true        { yylval.str = strdup(yytext); return (KEYWORD_TRUE); }
try         { yylval.str = strdup(yytext); return (KEYWORD_TRY); }
typedef     { yylval.str = strdup(yytext); return (KEYWORD_TYPEDEF); }
union       { yylval.str = strdup(yytext); return (KEYWORD_UNION); }
unsigned    { yylval.str = strdup(yytext); return (KEYWORD_UNSIGNED); }
using       { yylval.str = strdup(yytext); return (KEYWORD_USING); }
virtual     { yylval.str = strdup(yytext); return (KEYWORD_VIRTUAL); }
void        { yylval.str = strdup(yytext); return (KEYWORD_VOID); }
volatile    { yylval.str = strdup(yytext); return (KEYWORD_VOLATILE); }
while       { yylval.str = strdup(yytext); return (KEYWORD_WHILE); }

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
"->"        { yylval.str = strdup(yytext); return (ARROW_OPERATOR); }

"::"        { yylval.str = strdup(yytext); return (SCOPE_RESOLUTION_OPERATOR); }

"#"         { yylval.str = strdup(yytext); return (HASH_OPERATOR); }
"##"        { yylval.str = strdup(yytext); return (DOUBLE_HASH_OPERATOR); }

"..."       { yylval.str = strdup(yytext); return (ELLIPSIS_OPERATOR); }

".*"        { yylval.str = strdup(yytext); return (POINTER_TO_MEMBER_DOT_OPERATOR); }
"->*"       { yylval.str = strdup(yytext); return (POINTER_TO_MEMBER_ARROW_OPERATOR); }

{id}        { yylval.str = strdup(yytext); return (ID); }
{integer}   { yylval.integer = atoi(yytext); return INTEGER; }
{float}     { yylval.floating = atof(yytext); return FLOAT; }
{char}      { yylval.str = strdup(yytext); return (CHAR); }
{string}    { yylval.str = strdup(yytext); return (STRING); }

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
%%
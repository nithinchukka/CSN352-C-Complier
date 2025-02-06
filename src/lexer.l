%option noyywrap c++

digit   [0-9]
digits  {digit}+
alpha   [A-Za-z]
number  {digits}(\.{digits})?([eE][+-]?{digits})?
id      ({alpha}|_)({alpha}|{digit}|_)*
char    \'([^\'\\]|\\.)\'
string  \"([^\"\\]|\\.)*\"
space   [ \t\v\f\n]+



%{
#include "tokenType.h"
#include <fstream>
#include <vector>
#include <iomanip>
using namespace std;

struct SymbolTableEntry
{
    string token;
    string lexeme;
};
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

auto        {return (KEYWORD_AUTO);}
bool        {return (KEYWORD_BOOL);}
break       {return (KEYWORD_BREAK);}
case        {return (KEYWORD_CASE);}
catch       {return (KEYWORD_CATCH);}
char        {return (KEYWORD_CHAR);}
class       {return (KEYWORD_CLASS);}
const       {return (KEYWORD_CONST);}
continue    {return (KEYWORD_CONTINUE);}
default     {return (KEYWORD_DEFAULT);}
delete      {return (KEYWORD_DELETE);}
do          {return (KEYWORD_DO);}
double      {return (KEYWORD_DOUBLE);}
else        {return (KEYWORD_ELSE);}
enum        {return (KEYWORD_ENUM);}
extern      {return (KEYWORD_EXTERN);}
false       {return (KEYWORD_FALSE);}
float       {return (KEYWORD_FLOAT);}
for         {return (KEYWORD_FOR);}
friend      {return (KEYWORD_FRIEND);}
goto        {return (KEYWORD_GOTO);}
if          {return (KEYWORD_IF);}
inline      {return (KEYWORD_INLINE);}
int         {return (KEYWORD_INT);}
long        {return (KEYWORD_LONG);}
namespace   {return (KEYWORD_NAMESPACE);}
new         {return (KEYWORD_NEW);}
nullptr     {return (KEYWORD_NULLPTR);}
private     {return (KEYWORD_PRIVATE);}
protected   {return (KEYWORD_PROTECTED);}
public      {return (KEYWORD_PUBLIC);}
register    {return (KEYWORD_REGISTER);}
return      {return (KEYWORD_RETURN);}
short       {return (KEYWORD_SHORT);}
signed      {return (KEYWORD_SIGNED);}
sizeof      {return (KEYWORD_SIZEOF);}
static      {return (KEYWORD_STATIC);}
struct      {return (KEYWORD_STRUCT);}
switch      {return (KEYWORD_SWITCH);}
this        {return (KEYWORD_THIS);}
throw       {return (KEYWORD_THROW);}
true        {return (KEYWORD_TRUE);}
try         {return (KEYWORD_TRY);}
typedef     {return (KEYWORD_TYPEDEF);}
union       {return (KEYWORD_UNION);}
unsigned    {return (KEYWORD_UNSIGNED);}
using       {return (KEYWORD_USING);}
virtual     {return (KEYWORD_VIRTUAL);}
void        {return (KEYWORD_VOID);}
volatile   {return (KEYWORD_VOLATILE);}
while       {return (KEYWORD_WHILE);}

"+"         {return (PLUS_OPERATOR);}
"-"         {return (MINUS_OPERATOR);}
"*"         {return (MULTIPLY_OPERATOR);}
"/"         {return (DIVIDE_OPERATOR);}
"%"         {return (MODULO_OPERATOR);}
"--"        {return (DECREMENT_OPERATOR);}
"++"        {return (INCREMENT_OPERATOR);}

"="         {return (ASSIGNMENT_OPERATOR);}
"+="        {return (PLUS_ASSIGN_OPERATOR);}
"-="        {return (MINUS_ASSIGN_OPERATOR);}
"*="        {return (MULTIPLY_ASSIGN_OPERATOR);}
"/="        {return (DIVIDE_ASSIGN_OPERATOR);}
"%="        {return (MODULO_ASSIGN_OPERATOR);}
"&="        {return (BITWISE_AND_ASSIGN_OPERATOR);}
"|="        {return (BITWISE_OR_ASSIGN_OPERATOR);}
"^="        {return (BITWISE_XOR_ASSIGN_OPERATOR);}
">>="       {return (RIGHT_SHIFT_ASSIGN_OPERATOR);}
"<<="       {return (LEFT_SHIFT_ASSIGN_OPERATOR);}

"=="        {return (EQUALS_COMPARISON_OPERATOR);}
"!="        {return (NOT_EQUALS_OPERATOR);}
">"         {return (GREATER_THAN_OPERATOR);}
"<"         {return (LESS_THAN_OPERATOR);}
">="        {return (GREATER_THAN_OR_EQUAL_OPERATOR);}
"<="        {return (LESS_THAN_OR_EQUAL_OPERATOR);}

"&&"        {return (LOGICAL_AND_OPERATOR);}
"||"        {return (LOGICAL_OR_OPERATOR);}
"!"         {return (LOGICAL_NOT_OPERATOR);}

"&"         {return (BITWISE_AND_OPERATOR);}
"|"         {return (BITWISE_OR_OPERATOR);}
"^"         {return (BITWISE_XOR_OPERATOR);}
"<<"        {return (LEFT_SHIFT_OPERATOR);}
">>"        {return (RIGHT_SHIFT_OPERATOR);}
"~"         {return (BITWISE_NOT_OPERATOR);}

"?"         {return (TERNARY_OPERATOR);}

"."         {return (DOT_OPERATOR);}
"->"        {return (ARROW_OPERATOR);}

"::"        {return (SCOPE_RESOLUTION_OPERATOR);}

"#"         {return (HASH_OPERATOR);}
"##"        {return (DOUBLE_HASH_OPERATOR);}

"..."       {return (ELLIPSIS_OPERATOR);}

".*"        {return (POINTER_TO_MEMBER_DOT_OPERATOR);}
"->*"       {return (POINTER_TO_MEMBER_ARROW_OPERATOR);}

{id}        {return (ID);}
{number}    {return (NUMBER);}
{char}      {return (CHAR);}
{string}    {return (STRING);}

";"         {return (SEMICOLON);}
":"         {return (COLON);}
","         {return (COMMA);}
"{"         {return (LBRACE);}
"}"         {return (RBRACE);}
"("         {return (LPAREN);}
")"         {return (RPAREN);}
"["         {return (LBRACKET);}
"]"         {return (RBRACKET);}

{space}   { /* Ignore Spaces */ }
.         {cout << "Unrecognized Token: " << yytext << " at line no: " << yylineno << endl;} 
%%

void printSymbolTable(vector<SymbolTableEntry> symbolTable)
{
    cout << setw(64) << setfill('=') << left << "+" << "+" << "\n";

    cout << "| " << setw(15) << setfill(' ') << right << "Tok" << setw(15) << left << "en"
         << "| " << setw(15) << setfill(' ') << right << "Lex" << setw(15) << left << "eme" << "|\n";

    cout << setw(64) << setfill('=') << left << "+" << "+" << "\n";

    for(auto entry : symbolTable)
    {
        cout << "| " << setw(30) << setfill(' ') << left << entry.token
             << "| " << setw(30) << left << entry.lexeme
             << "|\n";
        cout << setw(64) << setfill('-') << left << "+" << "+" << "\n";
    }
    cout << "\n";
}


int main(int argc, char **argv) {
    if(argc < 2){
        cout << "Usage: " << argv[0] << " <input_file>" << endl;
        return 1;
    }

    ifstream file(argv[1]);
    if(!file.is_open()){
        cout << "Error: Unable to open file " << argv[1] << endl;
        return 1;
    }
    
    vector<SymbolTableEntry> symbolTable;

    yyFlexLexer* lexer = new yyFlexLexer(&file);
    
    int token;
    while ((token = lexer->yylex()) != 0) {
        symbolTable.push_back({tokenTypeToTokenClass(token), lexer->YYText()});
    } 

    printSymbolTable(symbolTable);
    
    delete lexer;
    return 0;
}

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
using namespace std;
%}

%%
"//"[^\n]*    {/* Ignore Single Line Comments */}
"/*"            {
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
while       {return (KEYWORD_WHILE);}

{id}        {return (ID);}
{number}    {return (NUMBER);}
{char}      {return (CHAR);}
{string}    {return (STRING);}

{space}   { /* Ignore Spaces */ }
.         {cout << "Unrecognized Token: " << yytext << endl;} 
%% 


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

    yyFlexLexer* lexer = new yyFlexLexer(&file);
    int token;
    while ((token = lexer->yylex()) != 0) {
        cout << tokenTypeToTokenClass(token) << " " << lexer->YYText() << endl;
    } 

    delete lexer;
    return 0;
}

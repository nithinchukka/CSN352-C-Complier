%option noyywrap

digit   [0-9]
digits  [0-9]+  
alpha   [A-Za-z]  
number  {digits}(\.{digits})?((e|E)[+-]?{digits})?
id      [{alpha}_][{alpha}{digit}_]*
space   [ \t\v\f\n]+



%{
    using namespace std;

enum TokenType {
    KEYWORD_AUTO = 1,
    KEYWORD_BOOL,
    KEYWORD_BREAK,
    KEYWORD_CASE,
    KEYWORD_CATCH,
    KEYWORD_CHAR,
    KEYWORD_CLASS,
    KEYWORD_CONST,
    KEYWORD_CONTINUE,
    KEYWORD_DEFAULT,
    KEYWORD_DELETE,
    KEYWORD_DO,
    KEYWORD_DOUBLE,
    KEYWORD_ELSE,
    KEYWORD_ENUM,
    KEYWORD_FALSE,
    KEYWORD_FLOAT,
    KEYWORD_FOR,
    KEYWORD_FRIEND,
    KEYWORD_GOTO,
    KEYWORD_IF,
    KEYWORD_INLINE,
    KEYWORD_INT,
    KEYWORD_LONG,
    KEYWORD_NAMESPACE,
    KEYWORD_NEW,
    KEYWORD_NULLPTR,
    KEYWORD_PRIVATE,
    KEYWORD_PROTECTED,
    KEYWORD_PUBLIC,
    KEYWORD_REGISTER,
    KEYWORD_RETURN,
    KEYWORD_SHORT,
    KEYWORD_SIGNED,
    KEYWORD_STATIC,
    KEYWORD_STRUCT,
    KEYWORD_SWITCH,
    KEYWORD_THIS,
    KEYWORD_THROW,
    KEYWORD_TRUE,
    KEYWORD_TRY,
    KEYWORD_TYPEDEF,
    KEYWORD_UNION,
    KEYWORD_UNSIGNED,
    KEYWORD_USING,
    KEYWORD_VIRTUAL,
    KEYWORD_VOID,
    KEYWORD_WHILE
};

%}

%%
auto        {return (KEYWORD_AUTO);}
bool        {return (KEYWORD_BOOL);}
break       {return (KEYWORD_BREAK);}
case        {return (KEYWORD_CASE);}
catch       {return (KEYWORD_CATCH);}
char        {return (KEYWORD_CHAR);}
class       {return (KEYWORD_CONST);}
const       {return (KEYWORD_CONST);}
continue    {return (KEYWORD_CONTINUE);}
default     {return (KEYWORD_DELETE);}
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
public      {return {KEYWORD_PUBLIC};}
register    {return (KEYWORD_REGISTER);}
return      {return (KEYWORD_RETURN);}
short       {return (KEYWORD_SHORT);}
signed      {return (KEYWORD_SIGNED);}
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

{space}   { /* Ignore Spaces */ }
%% 

int main() {
    FlexLexer* lexer = new yyFlexLexer();
    
    int token;
    while ((token = lexer->yylex()) != 0) {
        cout << "Token: " << token << endl;
    }

    delete lexer;
    return 0;
}

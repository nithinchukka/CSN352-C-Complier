%code requires {
	#include "../inc/treeNode.h"
    #include <bits/stdc++.h>
}
%define parse.error verbose

%{
    #include <bits/stdc++.h>
    #include "../inc/symbolTable.h"
	#include "../inc/treeNode.h"
    #include <sys/stat.h> // for mkdir

    extern irGenerator irGen;
    using namespace std;
    void yyerror(const char *s);

    extern int yylex();
    extern int yylineno;
    extern FILE *yyin;
    extern unordered_set<string> classOrStructOrUnion;
    extern int expectedReturnType;
    TreeNode* helper;
    void backTrackExpr(TreeNode* nd){
        if(nd == nullptr) return;
        if(nd->trueList || nd->falseList){
            Backpatch::backpatch(nd->trueList, to_string(irGen.currentInstrIndex));
            Backpatch::backpatch(nd->falseList, to_string(irGen.currentInstrIndex  + 1));
            irGen.emit(TACOp::ASSIGN, nd->tacResult, "1", "");
            irGen.emit(TACOp::ASSIGN, nd->tacResult, "0", "");
        }
    }

    void backTrackRelExpr(TreeNode* nd){
        if(nd == nullptr) return;
        backpatchNode* curr = nd->trueList;
        backpatchNode* next = Backpatch::addToBackpatchList(curr, irGen.currentInstrIndex);
        nd->trueList = next;
        curr = nd->falseList;
        next = Backpatch::addToBackpatchList(curr, irGen.currentInstrIndex + 1);
        nd->falseList = next;
    }

    void typeCastFunction(TreeNode *a, TreeNode *b, bool isRel = false){
        if (a->typeSpecifier < b->typeSpecifier) {
            string temp = irGen.newTemp();
            helper = new TreeNode(OTHERS);
            helper->typeSpecifier = a->typeSpecifier;
            helper->value = temp;
            helper->offset = offsetStack.top();
            offsetStack.top() += 4;
            insertSymbol(temp,helper);
            irGen.emit(TACOp::TYPECAST, temp, typeCastInfo(b->typeSpecifier, a->typeSpecifier), a->tacResult);
            a->tacResult = temp;
        } else if (a->typeSpecifier > b->typeSpecifier) {
            string temp = irGen.newTemp();
            helper = new TreeNode(OTHERS);
            helper->typeSpecifier = b->typeSpecifier;
            helper->value = temp;
            helper->offset = offsetStack.top();
            offsetStack.top() += 4;
            insertSymbol(temp,helper);
            irGen.emit(TACOp::TYPECAST, temp, typeCastInfo(a->typeSpecifier, b->typeSpecifier), b->tacResult);
            b->tacResult = temp;
        }
        if(!isRel){
            backTrackExpr(a);
            backTrackExpr(b);
        }
    }
    vector<int> curr_dimensions;
    TreeNode* curr_struct;
    string curr_value;
%}


%union {
	TreeNode *node;
    char *str;
    int integer;
}


%token <node>
    KEYWORD_BREAK KEYWORD_CASE KEYWORD_CHAR 
    KEYWORD_CONST KEYWORD_CONTINUE KEYWORD_DEFAULT KEYWORD_DO 
    KEYWORD_DOUBLE KEYWORD_ELSE KEYWORD_FLOAT 
    KEYWORD_FOR KEYWORD_GOTO KEYWORD_IF KEYWORD_INT 
    KEYWORD_LONG KEYWORD_NULLPTR KEYWORD_RETURN 
    KEYWORD_STATIC KEYWORD_STRUCT KEYWORD_SWITCH 
    KEYWORD_VOID KEYWORD_WHILE KEYWORD_PRINTF KEYWORD_SCANF TYPE_NAME KEYWORD_UNTIL KEYWORD_DONE

%token <node> INTEGER FLOAT CHAR STRING ID LONG

%token <str>
    LBRACE RBRACE LBRACKET RBRACKET LPAREN RPAREN SEMICOLON COMMA COLON

%token <str>
    PLUS_OPERATOR MINUS_OPERATOR MULTIPLY_OPERATOR DIVIDE_OPERATOR MODULO_OPERATOR
    DECREMENT_OPERATOR INCREMENT_OPERATOR

%token <str>
    ASSIGNMENT_OPERATOR PLUS_ASSIGN_OPERATOR MINUS_ASSIGN_OPERATOR MULTIPLY_ASSIGN_OPERATOR 
    DIVIDE_ASSIGN_OPERATOR MODULO_ASSIGN_OPERATOR BITWISE_AND_ASSIGN_OPERATOR BITWISE_OR_ASSIGN_OPERATOR 
    BITWISE_XOR_ASSIGN_OPERATOR RIGHT_SHIFT_ASSIGN_OPERATOR LEFT_SHIFT_ASSIGN_OPERATOR

%token <str>
    EQUALS_COMPARISON_OPERATOR NOT_EQUALS_OPERATOR GREATER_THAN_OPERATOR LESS_THAN_OPERATOR 
    GREATER_THAN_OR_EQUAL_OPERATOR LESS_THAN_OR_EQUAL_OPERATOR

%token <str>
    LOGICAL_AND_OPERATOR LOGICAL_OR_OPERATOR LOGICAL_NOT_OPERATOR

%token <str>
    BITWISE_AND_OPERATOR BITWISE_OR_OPERATOR BITWISE_XOR_OPERATOR LEFT_SHIFT_OPERATOR 
    RIGHT_SHIFT_OPERATOR BITWISE_NOT_OPERATOR 

%token <str>
    DOT_OPERATOR POINTER_TO_MEMBER_ARROW_OPERATOR

%type<node> translation_unit external_declaration function_definition struct_type_specifier

%type<node> declaration declaration_specifiers declarator compound_statement struct_declaration_list M N  

%type<node> storage_class_specifier type_specifier struct_specifier

%type<node> struct_declaration struct_declarator_list specifier_qualifier_list type_qualifier constant_expression

%type<node> parameter_list parameter_declaration 

%type<node> initializer initializer_list direct_declarator pointer assignment_expression 

%type<node> statement labeled_statement expression_statement selection_statement iteration_statement jump_statement block_item block_item_list

%type<node> expression init_declarator init_declarator_list primary_expression postfix_expression for_cond for_inc for_init

%type<node> unary_expression unary_operator cast_expression multiplicative_expression additive_expression shift_expression

%type<node> relational_expression equality_expression and_expression exclusive_or_expression inclusive_or_expression

%type<node> logical_and_expression logical_or_expression argument_expression_list assignment_operator io_statement single_expression compound_statement_func

%start translation_unit

%nonassoc NO_ELSE
%nonassoc KEYWORD_ELSE 

%%

N
: {
      $$ = new TreeNode(OTHERS);
      backpatchNode* curr = $$->nextList;
      backpatchNode* next = Backpatch::addToBackpatchList(curr, irGen.currentInstrIndex);
      $$->nextList = next;
      irGen.emit(TACOp::oth, "", "", "", true);
  }
;

primary_expression
    : ID { 
          $$ = $1;
          $$ = lookupSymbol($$->value, true);
          if (!$$) {
              raiseError("Undeclared identifier : " + $1->value, yylineno);
          }
          $$->tacResult = $1->value;
          $$->isLValue = true;
          if($$->typeCategory==2)curr_dimensions = $$->dimensions;
      }
    | INTEGER { 
          $$ = $1;
          $$->tacResult = $1->value;
          $$->typeSpecifier = 3; 
          $$->isLValue = false;
          $$->isConstVal = 1;
      }
    | LONG {
          $$ = $1;
          $$->tacResult = $1->value;
          $$->typeSpecifier = 4; 
          $$->isLValue = false;
          $$->isConstVal = 1;    
    }
    | FLOAT { 
          $$ = $1;
          $$->tacResult = $1->value;
          $$->typeSpecifier = 6; 
          $$->isLValue = false; 
          $$->isConstVal = 1;
      }
    | STRING { 
          $$ = $1;
          $$->tacResult = $1->value; 
          $$->typeSpecifier = 1; 
          $$->isLValue = false; 
          $$->pointerLevel = 1;
      }
    | CHAR { 
          $$ = $1; 
          $$->tacResult = $1->value;
          $$->typeSpecifier = 1; 
          $$->isLValue = false; 
          $$->isConstVal = 1;
      }
    | KEYWORD_NULLPTR { 
          $$ = $1;
          $$->tacResult = "nullptr";
          $$->typeSpecifier = 9; 
          $$->isLValue = false; 
          $$->pointerLevel = 1;
      }
    | LPAREN expression RPAREN { 
          $$ = $2;
      }
    ;

postfix_expression
    : primary_expression { 
        $$ = $1; 
    }
    | postfix_expression LBRACKET expression RBRACKET { 
        $$ = createNode(NODE_POSTFIX_EXPRESSION, "", $1, $3);
        if ($3->typeSpecifier != 3) {
            raiseError("Array index must be an integer", yylineno);
        } 
        else if($1->typeCategory == 2){
            if($1->typeSpecifier != 1 && $1->typeSpecifier !=3){
                raiseError("can only index a char or int pointer at line", yylineno);
            }
            else{
                $$->typeSpecifier = $1->typeSpecifier;
                $$->typeCategory = 2;
                $$->isLValue = true;
                $$->pointerLevel = $1->pointerLevel-1;
                string temp = irGen.newTemp();
                helper = new TreeNode(OTHERS);
                helper->typeSpecifier = $3->typeSpecifier;
                helper->value = temp;
                helper->offset = offsetStack.top();
                offsetStack.top() += 4;
                insertSymbol(temp,helper);
                irGen.emit(TACOp::ASSIGN,temp,$3->tacResult,"");
                for(int i=curr_dimensions.size()-$$->pointerLevel;i<curr_dimensions.size();i++){
                    irGen.emit(TACOp::MUL,temp,temp,to_string(curr_dimensions[i]));
                }
                if($1->typeSpecifier == 1){
                    irGen.emit(TACOp::MUL,temp,temp,string(1,'1'));
                }
                else 
                    irGen.emit(TACOp::MUL,temp,temp,string(1,'4'));
                string temp2 = irGen.newTemp();
                helper = new TreeNode(OTHERS);
                helper->typeSpecifier = $3->typeSpecifier;
                helper->value = temp2;
                helper->offset = offsetStack.top();
                offsetStack.top() += 4;
                insertSymbol(temp2,helper);
                irGen.emit(TACOp::ADD,temp2,temp,$1->tacResult);
                if($$->pointerLevel == 0){
                    string temp3 = irGen.newTemp();
                    helper = new TreeNode(OTHERS);
                    helper->value = temp3;
                    helper->offset = offsetStack.top();
                    offsetStack.top() += 4;
                    insertSymbol(temp3,helper);
                    irGen.emit(TACOp::DEREF, temp3, temp2, "");
                    $$->tacResult = temp3;
                }
                else 
                    $$->tacResult = temp2;
            }
        }
        else if($1->typeCategory == 1){
            
        }
        else if($1->typeCategory == 4){
            if ($1->typeSpecifier != 1 && $1->typeSpecifier != 3){
                raiseError("can only index a char or int pointer at line", yylineno);
            }
            TreeNode* member = lookupSymbol(curr_struct->value);
            int offset = 0;
                if (member != nullptr) {
                    bool found = false;
                    for (auto entry : member->symbolTable) {
                        if (entry.first == curr_value) {
                            found = true;
                            $$->typeSpecifier = entry.second->typeSpecifier;
                            $$->typeCategory = 4;
                            $$->isConst = entry.second->isConst;
                            $$->isStatic = entry.second->isStatic;
                            $$->isLValue = true;
                            $$->pointerLevel = $1->pointerLevel-1;
                            string temp = irGen.newTemp();
                            helper = new TreeNode(OTHERS);
                            helper->value = temp;
                            helper->offset = offsetStack.top();
                            offsetStack.top() += 4;
                            insertSymbol(temp,helper);
                            irGen.emit(TACOp::ASSIGN,temp,$3->tacResult,"");
                            for(int i=curr_dimensions.size()-$$->pointerLevel;i<curr_dimensions.size();i++){
                                irGen.emit(TACOp::MUL,temp,temp,to_string(curr_dimensions[i]));
                            }
                            if($1->typeSpecifier == 1){
                                irGen.emit(TACOp::MUL,temp,temp,string(1,'1'));
                            }
                            else 
                                irGen.emit(TACOp::MUL,temp,temp,string(1,'4'));
                            string temp2 = irGen.newTemp();
                            helper = new TreeNode(OTHERS);
                            helper->value = temp2;
                            helper->offset = offsetStack.top();
                            offsetStack.top() += 4;
                            insertSymbol(temp2,helper);
                            irGen.emit(TACOp::ADD,temp2,temp,$1->tacResult);
                            if($$->pointerLevel == 0){
                                string temp3 = irGen.newTemp();
                                helper = new TreeNode(OTHERS);
                                helper->value = temp3;
                                helper->offset = offsetStack.top();
                                offsetStack.top() += 4;
                                insertSymbol(temp3,helper);
                                irGen.emit(TACOp::DEREF, temp3, temp2, "");
                                $$->tacResult = temp3;
                            }
                            else 
                                $$->tacResult = temp2;
                            offset = entry.second->offset;
                            break;
                        }
                    }
                    if (!found) {
                        raiseError("member " + $3->value + " not found in object " + $1->value, yylineno);
                    }
                }  
        }
    }
    | postfix_expression LPAREN RPAREN { 
        $$ = $1;
        if ($$->paramCount > 0) {
            raiseError("function call with no params, expected " + to_string($$->paramCount), yylineno);
        } else {
            if ($1->typeSpecifier == 0) {
                irGen.emit(TACOp::CALL2, "", $1->tacResult, "0");
            } else {
                string temp = irGen.newTemp();
                irGen.emit(TACOp::CALL, temp, $1->tacResult, "0");
                $$->tacResult = temp;
            }
            $$->isLValue = false;
        } 
    }
    | postfix_expression LPAREN argument_expression_list RPAREN { 
        $$ = createNode(NODE_POSTFIX_EXPRESSION, "", $1, $3); 
        $$->typeSpecifier = $1->typeSpecifier;
        $$->isLValue = false;
        if ($1->typeCategory == 3) {
            if ($1->paramCount == $3->children.size()) {
                for (int i = 0; i < $1->paramCount; i++) {
                    int lhs = $1->paramTypes[i];
                    int rhs = $3->children[i]->typeSpecifier;
                    if (!isTypeCompatible(lhs, rhs, "=")) {
                        raiseError("Expected: " + to_string($1->paramTypes[i]) + ", Got: " + to_string($3->children[i]->typeSpecifier), yylineno);
                        break;
                    } else {
                        if (lhs != rhs) {
                            string temp = irGen.newTemp();
                            irGen.emit(TACOp::TYPECAST, temp, typeCastInfo(lhs, rhs), $3->children[i]->tacResult);
                            $3->children[i]->tacResult = temp;
                        }
                    }
                }
            } else {
                raiseError("function call with " + to_string($3->children.size()) + " params, expected " + to_string($1->paramCount), yylineno);
            }
        }
        for (auto* arg : $3->children) {
            irGen.emit(TACOp::ASSIGN, "param", arg->tacResult, "");
        }
        if ($1->typeSpecifier == 0) {
            irGen.emit(TACOp::CALL2, "", $1->value, to_string($3->children.size()));
        } else {
            string temp = irGen.newTemp();
            irGen.emit(TACOp::CALL, temp, $1->tacResult, to_string($3->children.size()));
            $$->tacResult = temp; 
        }
    }
    | postfix_expression DOT_OPERATOR ID {
        $$ = createNode(NODE_POSTFIX_EXPRESSION, $2, $1, $3);
        if ($1->typeSpecifier == 20) {
            TreeNode* member = lookupSymbol($1->value);
            curr_struct = member;
            if (member != nullptr) {
                bool found = false;
                for (auto entry : member->symbolTable) {
                    if (entry.first == $3->value) {
                        found = true;
                        $$->typeSpecifier = entry.second->typeSpecifier;
                        $$->typeCategory = 4;
                        $$->pointerLevel = entry.second->pointerLevel;
                        $$->isConst = entry.second->isConst;
                        $$->isStatic = entry.second->isStatic;
                        $$->isLValue = true;
                        if (entry.second->typeCategory == 2) {
                            curr_dimensions = entry.second->dimensions;
                            curr_value = entry.first;
                            string temp = irGen.newTemp();
                            helper = new TreeNode(OTHERS);
                            helper->value = temp;
                            helper->offset = offsetStack.top();
                            offsetStack.top() += 4;
                            insertSymbol(temp,helper);
                            string temp1 = irGen.newTemp();
                            helper = new TreeNode(OTHERS);
                            helper->value = temp1;
                            helper->offset = offsetStack.top();
                            offsetStack.top() += 4;
                            insertSymbol(temp1,helper);
                            irGen.emit(TACOp::REFER, temp1, $1->tacResult);
                            irGen.emit(TACOp::ADD, temp, temp1, to_string(entry.second->offset));
                            $$->tacResult = temp;
                            break;
                        } else {
                            string temp = irGen.newTemp();
                            helper = new TreeNode(OTHERS);
                            helper->value = temp;
                            helper->offset = offsetStack.top();
                            offsetStack.top() += 4;
                            insertSymbol(temp,helper);
                            string temp1 = irGen.newTemp();
                            helper = new TreeNode(OTHERS);
                            helper->value = temp1;
                            helper->offset = offsetStack.top();
                            offsetStack.top() += 4;
                            insertSymbol(temp1,helper);
                            irGen.emit(TACOp::REFER, temp1, $1->tacResult);
                            irGen.emit(TACOp::ADD, temp, temp1, to_string(entry.second->offset));
                            string temp2 = irGen.newTemp();
                            helper = new TreeNode(OTHERS);
                            helper->value = temp2;
                            helper->offset = offsetStack.top();
                            offsetStack.top() += 4;
                            insertSymbol(temp2,helper);
                            irGen.emit(TACOp::DEREF, temp2, temp, "");
                            $$->tacResult = temp2;
                        }
                        break;
                    }
                }
                if (!found) {
                    raiseError("member " + $3->value + " not found in object " + $1->value, yylineno);
                }
            }
        } else {
            raiseError("We can use member access only for classes, structs, and unions", yylineno);
        }
    }
    | postfix_expression POINTER_TO_MEMBER_ARROW_OPERATOR ID { 
        $$ = createNode(NODE_POSTFIX_EXPRESSION, $2, $1, $3);
        if ($1->typeSpecifier == 20 && $1->typeCategory == 1) {
            TreeNode* member = lookupSymbol($1->value);
            int offset = 0;
            if (member != nullptr) {
                bool found = false;
                for (auto entry : member->symbolTable) {
                    if (entry.first == $3->value) {
                        found = true;
                        $$->typeSpecifier = entry.second->typeSpecifier;
                        $$->typeCategory = entry.second->typeCategory;
                        $$->pointerLevel = entry.second->pointerLevel;
                        $$->isConst = entry.second->isConst;
                        $$->isStatic = entry.second->isStatic;
                        $$->isLValue = true;
                        if (entry.second->typeCategory == 2) {
                            break;
                        } else {
                            string temp = irGen.newTemp();
                            helper = new TreeNode(OTHERS);
                            helper->value = temp;
                            helper->offset = offsetStack.top();
                            offsetStack.top() += 4;
                            insertSymbol(temp,helper);
                            irGen.emit(TACOp::ADD, temp, $1->tacResult, to_string(offset));
                            string temp1 = irGen.newTemp();
                            helper = new TreeNode(OTHERS);
                            helper->value = temp1;
                            helper->offset = offsetStack.top();
                            offsetStack.top() += 4;
                            insertSymbol(temp1,helper);
                            irGen.emit(TACOp::DEREF, temp1, temp, "");
                            $$->tacResult = temp1;
                        }
                    } else {
                        if (entry.second->typeCategory == 1) {
                            offset += 4;
                        } else {
                            offset += findOffset(entry.second->typeSpecifier);
                        }
                    }
                }
                if (!found) {
                    raiseError("member " + $3->value + " not found in object " + $1->value, yylineno);
                }
            }
        } else {
            raiseError("We can use member access only for classes, structs, and unions", yylineno);
        }
    }
    | postfix_expression INCREMENT_OPERATOR { 
        if (!$1->isLValue) {  
            raiseError("Cannot post-increment an R-value", yylineno);
        }
        $$ = $1;
        $$->type = NODE_POSTFIX_EXPRESSION;
        int typeSpec = $1->typeSpecifier;
        if (typeSpec > 7) {
            raiseError("invalid type for increment operator", yylineno);
        }
        $$->isLValue = false; 
        string temp = irGen.newTemp();
        helper = new TreeNode(OTHERS);
        helper->typeSpecifier = typeSpec;
        helper->value = temp;
        helper->offset = offsetStack.top();
        offsetStack.top() += 4;
        insertSymbol(temp,helper);
        irGen.emit(TACOp::ASSIGN, temp, $1->tacResult, "");
        string temp2 = irGen.newTemp();
        helper = new TreeNode(OTHERS);
        helper->typeSpecifier = typeSpec;
        helper->value = temp2;
        helper->offset = offsetStack.top();
        offsetStack.top() += 4;
        insertSymbol(temp2,helper);
        irGen.emit(TACOp::ADD, temp2, temp, "1");
        irGen.emit(TACOp::ASSIGN, $1->tacResult, temp2, "");
        $$->tacResult = temp;
    }
    | postfix_expression DECREMENT_OPERATOR {
        if (!$1->isLValue) {
            raiseError("Cannot post-decrement an R-value", yylineno);
        } 
        $$ = $1;
        $$->type = NODE_POSTFIX_EXPRESSION;
        int typeSpec = $1->typeSpecifier;
        if (typeSpec > 7) {
            raiseError("invalid type for decrement operator", yylineno);
        }
        $$->isLValue = false;
        string temp = irGen.newTemp();
        helper = new TreeNode(OTHERS);
        helper->typeSpecifier = typeSpec;
        helper->value = temp;
        helper->offset = offsetStack.top();
        offsetStack.top() += 4;
        insertSymbol(temp,helper);
        irGen.emit(TACOp::ASSIGN, temp, $1->tacResult, "");
        string temp2 = irGen.newTemp();
        helper = new TreeNode(OTHERS);
        helper->typeSpecifier = typeSpec;
        helper->value = temp2;
        helper->offset = offsetStack.top();
        offsetStack.top() += 4;
        insertSymbol(temp2,helper);
        irGen.emit(TACOp::SUB, temp2, temp, "1");
        irGen.emit(TACOp::ASSIGN, $1->tacResult, temp2, "");
        $$->tacResult = temp;
    }
    ;

argument_expression_list
    : assignment_expression { 
        $$ = createNode(NODE_ARGUMENT_EXPRESSION_LIST, "", $1); 
        $$->tacResult = $1->tacResult;
    }
    | argument_expression_list COMMA assignment_expression { 
        $$ = $1;
        $$->children.push_back($3);
    }
    ;

unary_expression
    : postfix_expression { 
        $$ = $1; 
        $$->type = NODE_UNARY_EXPRESSION;
        $$->isLValue = $1->isLValue; 
    }
    | INCREMENT_OPERATOR unary_expression {
        if (!$2->isLValue) {  
            raiseError("Cannot pre-increment an R-value", yylineno);
        } 
        $$ = $2;
        string temp = irGen.newTemp();
        helper = new TreeNode(OTHERS);
        helper->value = temp;
        helper->offset = offsetStack.top();
        offsetStack.top() += 4;
        insertSymbol(temp,helper);
        irGen.emit(TACOp::ASSIGN, temp, $2->tacResult, "");
        string temp2 = irGen.newTemp();
        helper = new TreeNode(OTHERS);
        helper->value = temp2;
        helper->offset = offsetStack.top();
        offsetStack.top() += 4;
        insertSymbol(temp2,helper);
        irGen.emit(TACOp::ADD, temp2, temp, "1");
        irGen.emit(TACOp::ASSIGN, $2->tacResult, temp2, "");
        $$->tacResult = temp2; 
        int typeSpec = $2->typeSpecifier;
        if (typeSpec > 7) {
            raiseError("invalid type for increment operator", yylineno);
        }
        $$->isLValue = false; 
    }
    | DECREMENT_OPERATOR unary_expression {
        if (!$2->isLValue) {
            raiseError("Cannot pre-decrement an R-value", yylineno);
        }
        $$ = $2;
        string temp = irGen.newTemp();
        helper = new TreeNode(OTHERS);
        helper->value = temp;
        helper->offset = offsetStack.top();
        offsetStack.top() += 4;
        insertSymbol(temp,helper);
        irGen.emit(TACOp::ASSIGN, temp, $2->tacResult, "");
        string temp2 = irGen.newTemp();
        helper = new TreeNode(OTHERS);
        helper->value = temp2;
        helper->offset = offsetStack.top();
        offsetStack.top() += 4;
        insertSymbol(temp2,helper);
        irGen.emit(TACOp::SUB, temp2, temp, "1");
        irGen.emit(TACOp::ASSIGN, $2->tacResult, temp2, "");
        $$->tacResult = temp2;        
        int typeSpec = $2->typeSpecifier;
        if (typeSpec > 7) {
            raiseError("invalid type for decrement operator", yylineno);
        }
        $$->isLValue = false; 
    }
    | unary_operator cast_expression { 
        $$ = createNode(NODE_UNARY_EXPRESSION, "", $1, $2);
        if ($1->isConstVal) $$->isConstVal = 1;
        $$->typeSpecifier = $2->typeSpecifier;
        string temp = irGen.newTemp();
        helper = new TreeNode(OTHERS);
        helper->value = temp;
        helper->offset = offsetStack.top();
        offsetStack.top() += 4;
        insertSymbol(temp,helper);
        string op = $1->value;
        if (op == "&") {
            string temp1 = irGen.newTemp();
            helper = new TreeNode(OTHERS);
            helper->value = temp1;
            helper->offset = offsetStack.top();
            offsetStack.top() += 4;
            insertSymbol(temp1,helper);
            irGen.emit(TACOp::REFER, temp1, $2->tacResult, "");
            irGen.emit(TACOp::ASSIGN, temp, temp1, "");
            $$->isLValue = false;
            $$->pointerLevel = $2->pointerLevel+1;
        } else if (op == "*") {
            string temp1 = irGen.newTemp();
            helper = new TreeNode(OTHERS);
            helper->value = temp1;
            helper->offset = offsetStack.top();
            offsetStack.top() += 4;
            insertSymbol(temp1,helper);
            irGen.emit(TACOp::DEREF, temp1, temp, "");
            irGen.emit(TACOp::ASSIGN, temp, temp1, "");
            $$->isLValue = true;
            $$->pointerLevel = $2->pointerLevel-1;
        } else if (op == "+") {
            $$->isConstVal = 1;
            irGen.emit(TACOp::ASSIGN, temp, $2->tacResult, "");
            $$->isLValue = false;
        } else if (op == "-") {
            $$->isConstVal = 1;
            irGen.emit(TACOp::SUB, temp, "0", $2->tacResult);
            $$->isLValue = false;
        } else if (op == "~") {
            $$->isConstVal = 1;
            irGen.emit(TACOp::BIT_XOR, temp, $2->tacResult, "-1");
            $$->isLogical = true;
            $$->falseList = $2->falseList;
            $$->trueList = $2->trueList;
            $$->isLValue = false;
        } else if (op == "!") {
            $$->isConstVal = 1;
            irGen.emit(TACOp::EQ, temp, $2->tacResult, "0");
            $$->isLValue = false;
        }
        $$->tacResult = temp;         
        if (op == "&" && !$2->isLValue) {
            raiseError("Cannot apply '&' to an R-value", yylineno);
        } else if (op == "*" && $2->pointerLevel == 0) {
            raiseError("Cannot dereference a non-pointer type", yylineno);
        }
    }
    ;

unary_operator
    : BITWISE_AND_OPERATOR { $$ = createNode(NODE_UNARY_OPERATOR, $1); }
    | MULTIPLY_OPERATOR { $$ = createNode(NODE_UNARY_OPERATOR, $1); }
    | PLUS_OPERATOR { $$ = createNode(NODE_UNARY_OPERATOR, $1); }
    | MINUS_OPERATOR { $$ = createNode(NODE_UNARY_OPERATOR, $1); }
    | BITWISE_NOT_OPERATOR { $$ = createNode(NODE_UNARY_OPERATOR, $1); }
    | LOGICAL_NOT_OPERATOR { $$ = createNode(NODE_UNARY_OPERATOR, $1); }
    ;

cast_expression
    : unary_expression { $$ = $1; }
    /* | LPAREN type_name RPAREN cast_expression
        {
            int toType = $2->typeSpecifier;
            int fromType = $4->typeSpecifier;

            if (!isValidCast(toType, fromType)) {
                raiseError("Invalid type cast");
            }
            
            $$ = createNode(NODE_CAST_EXPRESSION, "", $2, $4);
            $$->typeSpecifier = toType;
            $$->isLValue = false;
            string temp = irGen.newTemp();
            string castExpr = "(" + $2->value + ")" + $4->tacResult;
            irGen.emit(TACOp::ASSIGN, temp, castExpr, "");
            $$->tacResult = temp;
        } */
    ;

multiplicative_expression
    : cast_expression { 
        $$ = $1; 
    }
    | multiplicative_expression MULTIPLY_OPERATOR cast_expression { 
        $$ = createNode(NODE_MULTIPLICATIVE_EXPRESSION, $2, $1, $3);
        $$->isLValue = false; 
        if ($1->isConstVal && $3->isConstVal) $$->isConstVal = 1;
        int rhsPointerLevel = $3->pointerLevel;
        int lhsPointerLevel = $1->pointerLevel;
        if (rhsPointerLevel || lhsPointerLevel) {
            raiseError("Invalid operands to binary '*' — multiplication involving pointer types is not allowed", yylineno);
        } else {
            if (isTypeCompatible($1->typeSpecifier, $3->typeSpecifier, "*")) {
                $$->typeSpecifier = max($1->typeSpecifier, $3->typeSpecifier);
                typeCastFunction($1, $3);
                string temp = irGen.newTemp();
                helper = new TreeNode(OTHERS);
                helper->typeSpecifier = $$->typeSpecifier;
                helper->value = temp;
                helper->offset = offsetStack.top();
                offsetStack.top() += 4;
                insertSymbol(temp,helper);
                irGen.emit(TACOp::MUL, temp, $1->tacResult, $3->tacResult);
                $$->tacResult = temp;
            } else {
                raiseError("Incompatible Type: " + to_string($1->typeSpecifier) + " and " + to_string($3->typeSpecifier), yylineno);
            }
        }
    }
    | multiplicative_expression DIVIDE_OPERATOR cast_expression { 
        $$ = createNode(NODE_MULTIPLICATIVE_EXPRESSION, $2, $1, $3);
        if ($1->isConstVal && $3->isConstVal) $$->isConstVal = 1;
        $$->isLValue = false;
        int rhsPointerLevel = $3->pointerLevel;
        int lhsPointerLevel = $1->pointerLevel;
        if (rhsPointerLevel || lhsPointerLevel) {
            raiseError("Invalid operands to binary '/' — multiplication involving pointer types is not allowed", yylineno);
        } else {
            if (isTypeCompatible($1->typeSpecifier, $3->typeSpecifier, "/")) {
                typeCastFunction($1, $3);
                $$->typeSpecifier = max($1->typeSpecifier, $3->typeSpecifier);
                string temp = irGen.newTemp();
                helper = new TreeNode(OTHERS);
                helper->typeSpecifier = $$->typeSpecifier;
                helper->value = temp;
                helper->offset = offsetStack.top();
                offsetStack.top() += 4;
                insertSymbol(temp,helper);
                irGen.emit(TACOp::DIV, temp, $1->tacResult, $3->tacResult);
                $$->tacResult = temp;
            } else {
                raiseError("Incompatible Type: " + to_string($1->typeSpecifier) + " and " + to_string($3->typeSpecifier), yylineno);
            }
        }
    }
    | multiplicative_expression MODULO_OPERATOR cast_expression { 
        $$ = createNode(NODE_MULTIPLICATIVE_EXPRESSION, $2, $1, $3);
        if ($1->isConstVal && $3->isConstVal) $$->isConstVal = 1;
        int rhsPointerLevel = $3->pointerLevel;
        int lhsPointerLevel = $1->pointerLevel;
        if (rhsPointerLevel || lhsPointerLevel) {
            raiseError("Invalid operands to binary '%' — multiplication involving pointer types is not allowed", yylineno);
        } else {
            $$->isLValue = false; 
            if (($1->typeSpecifier == 3 || $1->typeSpecifier == 4) && 
                ($3->typeSpecifier == 3 || $3->typeSpecifier == 4) && 
                isTypeCompatible($1->typeSpecifier, $3->typeSpecifier, "%")) {
                typeCastFunction($1, $3);
                $$->typeSpecifier = max($1->typeSpecifier, $3->typeSpecifier);
                string temp = irGen.newTemp();
                helper = new TreeNode(OTHERS);
                helper->typeSpecifier = $$->typeSpecifier;
                helper->value = temp;
                helper->offset = offsetStack.top();
                offsetStack.top() += 4;
                insertSymbol(temp,helper);
                irGen.emit(TACOp::MOD, temp, $1->tacResult, $3->tacResult);
                $$->tacResult = temp;
            } else {
                raiseError("Incompatible Type: " + to_string($1->typeSpecifier) + " and " + to_string($3->typeSpecifier), yylineno);
            }
        }
    }
    ;

additive_expression
    : multiplicative_expression { 
        $$ = $1; 
    }
    | additive_expression PLUS_OPERATOR multiplicative_expression {
        $$ = createNode(NODE_ADDITIVE_EXPRESSION, $2, $1, $3);
        if ($1->isConstVal && $3->isConstVal) $$->isConstVal = 1;
        int rhsPointerLevel = $3->pointerLevel;
        int lhsPointerLevel = $1->pointerLevel;
        if (rhsPointerLevel && lhsPointerLevel) {
            raiseError("Invalid operands to binary '+' — cannot add two pointers (LHS pointer level: " + 
                       to_string(lhsPointerLevel) + ", RHS pointer level: " + to_string(rhsPointerLevel) + ")", yylineno);
        } else {
            $$->isLValue = false; 
            $$->pointerLevel = lhsPointerLevel + rhsPointerLevel;
            if (isTypeCompatible($1->typeSpecifier, $3->typeSpecifier, "+")) {
                $$->typeSpecifier = max($1->typeSpecifier, $3->typeSpecifier);
                typeCastFunction($1, $3);
                string temp = irGen.newTemp(); 
                helper = new TreeNode(OTHERS);
                helper->typeSpecifier = $$->typeSpecifier;
                helper->value = temp;
                helper->offset = offsetStack.top();
                offsetStack.top() += 4;
                insertSymbol(temp,helper);
                if ($1->typeCategory == 2 || $3->typeCategory == 2) {
                    $$->typeCategory = 2;
                } else {
                    $$->typeCategory = 0;
                }
                irGen.emit(TACOp::ADD, temp, $1->tacResult, $3->tacResult);
                $$->tacResult = temp;
            } else {
                raiseError("Incompatible Type: " + to_string($1->typeSpecifier) + " and " + 
                           to_string($3->typeSpecifier), yylineno);
            }
        }
    }
    | additive_expression MINUS_OPERATOR multiplicative_expression { 
        $$ = createNode(NODE_ADDITIVE_EXPRESSION, $2, $1, $3);
        if ($1->isConstVal && $3->isConstVal) $$->isConstVal = 1;
        $$->isLValue = false;
        int rhsPointerLevel = $3->pointerLevel;
        int lhsPointerLevel = $1->pointerLevel;
        if (rhsPointerLevel && lhsPointerLevel) {
            raiseError("Invalid operands to binary '-' — cannot subtract two pointers (LHS pointer level: " + 
                       to_string(lhsPointerLevel) + ", RHS pointer level: " + to_string(rhsPointerLevel) + ")", yylineno);
        } else {
            $$->pointerLevel = lhsPointerLevel + rhsPointerLevel;
            if (isTypeCompatible($1->typeSpecifier, $3->typeSpecifier, "-")) {
                typeCastFunction($1, $3);
                $$->typeSpecifier = max($1->typeSpecifier, $3->typeSpecifier);
                if ($1->typeCategory == 2 || $3->typeCategory == 2) {
                    $$->typeCategory = 2;
                }
                string temp = irGen.newTemp();
                helper = new TreeNode(OTHERS);
                helper->typeSpecifier = $$->typeSpecifier;
                helper->value = temp;
                helper->offset = offsetStack.top();
                offsetStack.top() += 4;
                insertSymbol(temp,helper);
                irGen.emit(TACOp::SUB, temp, $1->tacResult, $3->tacResult);
                $$->tacResult = temp; 
            } else {
                raiseError("Incompatible Type: " + to_string($1->typeSpecifier) + " and " + 
                           to_string($3->typeSpecifier), yylineno);
            }
        }
    }
    ;

shift_expression
    : additive_expression { 
        $$ = $1; 
    }
    | shift_expression LEFT_SHIFT_OPERATOR additive_expression {
        $$ = createNode(NODE_SHIFT_EXPRESSION, $2, $1, $3);
        if ($1->isConstVal && $3->isConstVal) $$->isConstVal = 1; 
        int rhsPointerLevel = $3->pointerLevel;
        int lhsPointerLevel = $1->pointerLevel;
        if (rhsPointerLevel || lhsPointerLevel) {
            raiseError("Invalid operands to binary '<<' — shift operations require integral types, but got pointer types (LHS pointer level: " + 
                       to_string(lhsPointerLevel) + ", RHS pointer level: " + to_string(rhsPointerLevel) + ")", yylineno);
        } else {
            $$->isLValue = false; 
            if (($1->typeSpecifier == 3 || $1->typeSpecifier == 4) && 
                ($3->typeSpecifier == 3 || $3->typeSpecifier == 4) && 
                (isTypeCompatible($1->typeSpecifier, $3->typeSpecifier, "<<"))) {
                typeCastFunction($1, $3);
                $$->typeSpecifier = max($1->typeSpecifier, $3->typeSpecifier);
                string temp = irGen.newTemp();
                helper = new TreeNode(OTHERS);
                helper->typeSpecifier = $$->typeSpecifier;
                helper->value = temp;
                helper->offset = offsetStack.top();
                offsetStack.top() += 4;
                insertSymbol(temp,helper);
                irGen.emit(TACOp::LSHFT, temp, $1->tacResult, $3->tacResult);
                $$->tacResult = temp;
            } else {
                raiseError("Incompatible Type: " + to_string($1->typeSpecifier) + " and " + 
                           to_string($3->typeSpecifier), yylineno);
            }
        }
    }
    | shift_expression RIGHT_SHIFT_OPERATOR additive_expression {
        $$ = createNode(NODE_SHIFT_EXPRESSION, $2, $1, $3);
        if ($1->isConstVal && $3->isConstVal) $$->isConstVal = 1;
        $$->isLValue = false;
        int rhsPointerLevel = $3->pointerLevel;
        int lhsPointerLevel = $1->pointerLevel;
        if (rhsPointerLevel || lhsPointerLevel) {
            raiseError("Invalid operands to binary '>>' — shift operations require integral types, but got pointer types (LHS pointer level: " + 
                       to_string(lhsPointerLevel) + ", RHS pointer level: " + to_string(rhsPointerLevel) + ")", yylineno);
        } else {
            if (($1->typeSpecifier == 3 || $1->typeSpecifier == 4) && 
                ($3->typeSpecifier == 3 || $3->typeSpecifier == 4) && 
                (isTypeCompatible($1->typeSpecifier, $3->typeSpecifier, ">>"))) {
                $$->typeSpecifier = max($1->typeSpecifier, $3->typeSpecifier);
                typeCastFunction($1, $3);
                string temp = irGen.newTemp();
                helper = new TreeNode(OTHERS);
                helper->typeSpecifier = $$->typeSpecifier;
                helper->value = temp;
                helper->offset = offsetStack.top();
                offsetStack.top() += 4;
                insertSymbol(temp,helper);
                irGen.emit(TACOp::RSHFT, temp, $1->tacResult, $3->tacResult);
                $$->tacResult = temp; 
            } else {
                raiseError("Incompatible Type: " + to_string($1->typeSpecifier) + " and " + 
                           to_string($3->typeSpecifier), yylineno);
            }
        }
    }
    ;
    
relational_expression
    : shift_expression { $$ = $1; }
    | relational_expression LESS_THAN_OPERATOR shift_expression {
        $$ = createNode(NODE_RELATIONAL_EXPRESSION, $2, $1, $3);
        if ($1->isConstVal && $3->isConstVal) $$->isConstVal = 1;
        $$->isLogical = true;
        int rhsPointerLevel = $3->pointerLevel;
        int lhsPointerLevel = $1->pointerLevel;
        if (rhsPointerLevel != lhsPointerLevel) {
            raiseError("Invalid operands to binary '<' — relational comparison requires arithmetic types, but one or both operands are pointers (LHS pointer level: " + 
                       to_string(lhsPointerLevel) + ", RHS pointer level: " + to_string(rhsPointerLevel) + ")", yylineno);
        } else {
            $$->isLValue = false; 
            if (isTypeCompatible($1->typeSpecifier, $3->typeSpecifier, "<")) {
                $$->typeSpecifier = 3;
                typeCastFunction($1, $3, true);
                backTrackRelExpr($$);
                $$->tacResult = irGen.newTemp();
                helper = new TreeNode(OTHERS);
                helper->typeSpecifier = $$->typeSpecifier;
                helper->value = $$->tacResult;
                helper->offset = offsetStack.top();
                offsetStack.top() += 4;
                insertSymbol($$->tacResult,helper);
                irGen.emit(TACOp::LT, "", $1->tacResult, $3->tacResult, true);
                irGen.emit(TACOp::oth, "", "", "", true);
            } else {
                raiseError("Incompatible Type: " + to_string($1->typeSpecifier) + " and " + 
                           to_string($3->typeSpecifier), yylineno);
            } 
        }
    }
    | relational_expression GREATER_THAN_OPERATOR shift_expression { 
        $$ = createNode(NODE_RELATIONAL_EXPRESSION, $2, $1, $3);
        if ($1->isConstVal && $3->isConstVal) $$->isConstVal = 1;
        $$->isLogical = true;
        $$->isLValue = false;
        int rhsPointerLevel = $3->pointerLevel;
        int lhsPointerLevel = $1->pointerLevel;
        if (rhsPointerLevel != lhsPointerLevel) {
            raiseError("Invalid operands to binary '>' — relational comparison requires arithmetic types, but one or both operands are pointers (LHS pointer level: " + 
                       to_string(lhsPointerLevel) + ", RHS pointer level: " + to_string(rhsPointerLevel) + ")", yylineno);
        } else {
            if (isTypeCompatible($1->typeSpecifier, $3->typeSpecifier, ">")) {
                $$->typeSpecifier = 3;
                typeCastFunction($1, $3, true);
                backTrackRelExpr($$);
                irGen.emit(TACOp::GT, "", $1->tacResult, $3->tacResult, true);
                irGen.emit(TACOp::oth, "", "", "", true);
                $$->tacResult = irGen.newTemp();
                helper = new TreeNode(OTHERS);
                helper->typeSpecifier = $$->typeSpecifier;
                helper->value = $$->tacResult;
                helper->offset = offsetStack.top();
                offsetStack.top() += 4;
                insertSymbol($$->tacResult,helper);
            } else {
                raiseError("Incompatible Type: " + to_string($1->typeSpecifier) + " and " + 
                           to_string($3->typeSpecifier), yylineno);
            } 
        }
    }
    | relational_expression LESS_THAN_OR_EQUAL_OPERATOR shift_expression {
        $$ = createNode(NODE_RELATIONAL_EXPRESSION, $2, $1, $3);
        if ($1->isConstVal && $3->isConstVal) $$->isConstVal = 1;
        $$->isLogical = true;
        $$->isLValue = false;
        int rhsPointerLevel = $3->pointerLevel;
        int lhsPointerLevel = $1->pointerLevel;
        if (rhsPointerLevel != lhsPointerLevel) {
            raiseError("Invalid operands to binary '<=' — relational comparison requires arithmetic types, but one or both operands are pointers (LHS pointer level: " + 
                       to_string(lhsPointerLevel) + ", RHS pointer level: " + to_string(rhsPointerLevel) + ")", yylineno);
        } else {
            if (isTypeCompatible($1->typeSpecifier, $3->typeSpecifier, "<=")) {
                $$->typeSpecifier = 3;
                typeCastFunction($1, $3, true);
                backTrackRelExpr($$);
                irGen.emit(TACOp::LE, "", $1->tacResult, $3->tacResult, true);
                irGen.emit(TACOp::oth, "", "", "", true);
                $$->tacResult = irGen.newTemp();
                helper = new TreeNode(OTHERS);
                helper->typeSpecifier = $$->typeSpecifier;
                helper->value = $$->tacResult;
                helper->offset = offsetStack.top();
                offsetStack.top() += 4;
                insertSymbol($$->tacResult,helper);
            } else {
                raiseError("Incompatible Type: " + to_string($1->typeSpecifier) + " and " + 
                           to_string($3->typeSpecifier), yylineno);
            }
        }
    }
    | relational_expression GREATER_THAN_OR_EQUAL_OPERATOR shift_expression { 
        $$ = createNode(NODE_RELATIONAL_EXPRESSION, $2, $1, $3);
        $$->isLValue = false;
        $$->isLogical = true;
        if ($1->isConstVal && $3->isConstVal) $$->isConstVal = 1;
        int rhsPointerLevel = $3->pointerLevel;
        int lhsPointerLevel = $1->pointerLevel;
        if (rhsPointerLevel != lhsPointerLevel ) {
            raiseError("Invalid operands to binary '>=' — relational comparison requires arithmetic types, but one or both operands are pointers (LHS pointer level: " + 
                       to_string(lhsPointerLevel) + ", RHS pointer level: " + to_string(rhsPointerLevel) + ")", yylineno);
        } else {
            if (isTypeCompatible($1->typeSpecifier, $3->typeSpecifier, ">=")) {
                $$->typeSpecifier = 3;
                typeCastFunction($1, $3, true);
                backTrackRelExpr($$);
                irGen.emit(TACOp::GE, "", $1->tacResult, $3->tacResult, true);
                irGen.emit(TACOp::oth, "", "", "", true);
                $$->tacResult = irGen.newTemp();
                helper = new TreeNode(OTHERS);
                helper->typeSpecifier = $$->typeSpecifier;
                helper->value = $$->tacResult;
                helper->offset = offsetStack.top();
                offsetStack.top() += 4;
                insertSymbol($$->tacResult,helper);
            } else {
                raiseError("Incompatible Type: " + to_string($1->typeSpecifier) + " and " + 
                           to_string($3->typeSpecifier), yylineno);
            } 
        }
    }
    ;

equality_expression
    : relational_expression { $$ = $1; }
    | equality_expression EQUALS_COMPARISON_OPERATOR relational_expression { 
        $$ = createNode(NODE_EQUALITY_EXPRESSION, $2, $1, $3);
        $$->isLogical = true;
        if ($1->isConstVal && $3->isConstVal) $$->isConstVal = 1;
        $$->isLValue = false;
        int rhsPointerLevel = $3->pointerLevel;
        int lhsPointerLevel = $1->pointerLevel;
        if ((rhsPointerLevel != lhsPointerLevel)) {
            raiseError("Invalid operands to binary '==' — cannot compare values with mismatched pointer levels (LHS pointer level: " + 
                       to_string(lhsPointerLevel) + ", RHS pointer level: " + to_string(rhsPointerLevel) + ")", yylineno);
        } else {
            if (isTypeCompatible($1->typeSpecifier, $3->typeSpecifier, "==")) {
                typeCastFunction($1, $3, true);
                $$->typeSpecifier = 3;
                backTrackRelExpr($$);
                irGen.emit(TACOp::EQ, "", $1->tacResult, $3->tacResult, true);
                irGen.emit(TACOp::oth, "", "", "", true);
                $$->tacResult = irGen.newTemp();
                helper = new TreeNode(OTHERS);
                helper->typeSpecifier = $$->typeSpecifier;
                helper->value = $$->tacResult;
                helper->offset = offsetStack.top();
                offsetStack.top() += 4;
                insertSymbol($$->tacResult,helper);
            } else {
                raiseError("Incompatible Type: " + to_string($1->typeSpecifier) + " and " + 
                           to_string($3->typeSpecifier), yylineno);
            } 
        }
    }
    | equality_expression NOT_EQUALS_OPERATOR relational_expression { 
        $$ = createNode(NODE_EQUALITY_EXPRESSION, $2, $1, $3);
        $$->isLValue = false;
        $$->isLogical = true;
        if ($1->isConstVal && $3->isConstVal) $$->isConstVal = 1;
        int rhsPointerLevel = $3->pointerLevel;
        int lhsPointerLevel = $1->pointerLevel;
        if (rhsPointerLevel != lhsPointerLevel) {
            raiseError("Invalid operands to binary '!=' — cannot compare values with mismatched pointer levels (LHS pointer level: " + 
                       to_string(lhsPointerLevel) + ", RHS pointer level: " + to_string(rhsPointerLevel) + ")", yylineno);
        } else {
            if (isTypeCompatible($1->typeSpecifier, $3->typeSpecifier, "!=")) {
                $$->typeSpecifier = 3;
                typeCastFunction($1, $3, true);
                backTrackRelExpr($$);
                irGen.emit(TACOp::NE, "", $1->tacResult, $3->tacResult, true);
                irGen.emit(TACOp::oth, "", "", "", true);
                $$->tacResult = irGen.newTemp();
                helper = new TreeNode(OTHERS);
                helper->typeSpecifier = $$->typeSpecifier;
                helper->value = $$->tacResult;
                helper->offset = offsetStack.top();
                offsetStack.top() += 4;
                insertSymbol($$->tacResult,helper);
            } else {
                raiseError("Incompatible Type: " + to_string($1->typeSpecifier) + " and " + 
                           to_string($3->typeSpecifier), yylineno);
            }
        }
    }
    ;

and_expression
    : equality_expression { $$ = $1; }
    | and_expression BITWISE_AND_OPERATOR equality_expression { 
        $$ = createNode(NODE_AND_EXPRESSION, $2, $1, $3); 
        $$->isLValue = false;
        if ($1->isConstVal && $3->isConstVal) $$->isConstVal = 1;
        int rhsPointerLevel = $3->pointerLevel;
        int lhsPointerLevel = $1->pointerLevel;
        if (rhsPointerLevel || lhsPointerLevel) {
            raiseError("Invalid operands to binary '&' — bitwise operations require integral types, but found pointer operand(s) (LHS pointer level: " + 
                       to_string(lhsPointerLevel) + ", RHS pointer level: " + to_string(rhsPointerLevel) + ")", yylineno);
        } else {
            if (($1->typeSpecifier == 3 || $1->typeSpecifier == 4) &&
                ($3->typeSpecifier == 3 || $3->typeSpecifier == 4) &&
                (isTypeCompatible($1->typeSpecifier, $3->typeSpecifier, "&"))) {
                $$->typeSpecifier = max($1->typeSpecifier, $3->typeSpecifier);
                typeCastFunction($1, $3);
                string temp = irGen.newTemp();
                helper = new TreeNode(OTHERS);
                helper->typeSpecifier = $$->typeSpecifier;
                helper->value = temp;
                helper->offset = offsetStack.top();
                offsetStack.top() += 4;
                insertSymbol(temp,helper);
                irGen.emit(TACOp::BIT_AND, temp, $1->tacResult, $3->tacResult);
                $$->tacResult = temp;
            } else {
                raiseError("Incompatible Type: " + to_string($1->typeSpecifier) + " and " + 
                           to_string($3->typeSpecifier), yylineno);
            }
        }
    }
    ;

exclusive_or_expression
    : and_expression { $$ = $1; }
    | exclusive_or_expression BITWISE_XOR_OPERATOR and_expression { 
        if ($1->isConstVal && $3->isConstVal) $$->isConstVal = 1;
        int rhsPointerLevel = $3->pointerLevel;
        int lhsPointerLevel = $1->pointerLevel;
        if (rhsPointerLevel || lhsPointerLevel) {
            raiseError("Invalid operands to binary '^' — bitwise operations require integral types, but found pointer operand(s) (LHS pointer level: " + 
                       to_string(lhsPointerLevel) + ", RHS pointer level: " + to_string(rhsPointerLevel) + ")", yylineno);
        } else {
            $$ = createNode(NODE_EXCLUSIVE_OR_EXPRESSION, $2, $1, $3);
            $$->isLValue = false;
            if (($1->typeSpecifier == 3 || $1->typeSpecifier == 4) &&
                ($3->typeSpecifier == 3 || $3->typeSpecifier == 4) &&
                (isTypeCompatible($1->typeSpecifier, $3->typeSpecifier, "^"))) {
                $$->typeSpecifier = max($1->typeSpecifier, $3->typeSpecifier);
                typeCastFunction($1, $3);
                string temp = irGen.newTemp();
                helper = new TreeNode(OTHERS);
                helper->typeSpecifier = $$->typeSpecifier;
                helper->value = temp;
                helper->offset = offsetStack.top();
                offsetStack.top() += 4;
                insertSymbol(temp,helper);
                irGen.emit(TACOp::BIT_XOR, temp, $1->tacResult, $3->tacResult);
                $$->tacResult = temp;
            } else {
                raiseError("Incompatible Type: " + to_string($1->typeSpecifier) + " and " + 
                           to_string($3->typeSpecifier), yylineno);
            }
        }
    }
    ;

inclusive_or_expression
    : exclusive_or_expression { $$ = $1; }
    | inclusive_or_expression BITWISE_OR_OPERATOR exclusive_or_expression {
        if ($1->isConstVal && $3->isConstVal) $$->isConstVal = 1;
        int rhsPointerLevel = $3->pointerLevel;
        int lhsPointerLevel = $1->pointerLevel;
        if (rhsPointerLevel || lhsPointerLevel) {
            raiseError("Invalid operands to binary '|' — bitwise operations require integral types, but found pointer operand(s) (LHS pointer level: " + 
                       to_string(lhsPointerLevel) + ", RHS pointer level: " + to_string(rhsPointerLevel) + ")", yylineno);
        } else {
            $$ = createNode(NODE_INCLUSIVE_OR_EXPRESSION, $2 , $1, $3);
            $$->isLValue = false;
            if (($1->typeSpecifier == 3 || $1->typeSpecifier == 4) &&
                ($3->typeSpecifier == 3 || $3->typeSpecifier == 4) &&
                (isTypeCompatible($1->typeSpecifier, $3->typeSpecifier, "|"))) {
                $$->typeSpecifier = max($1->typeSpecifier, $3->typeSpecifier);
                typeCastFunction($1, $3, false);
                string temp = irGen.newTemp();
                helper = new TreeNode(OTHERS);
                helper->typeSpecifier = $$->typeSpecifier;
                helper->value = temp;
                helper->offset = offsetStack.top();
                offsetStack.top() += 4;
                insertSymbol(temp,helper);
                irGen.emit(TACOp::BIT_OR, temp, $1->tacResult, $3->tacResult);
                $$->tacResult = temp;
            } else {
                raiseError("Incompatible Type: " + to_string($1->typeSpecifier) + " and " + 
                           to_string($3->typeSpecifier), yylineno);
            }
        }
    }
    ;

logical_and_expression
    : inclusive_or_expression { 
        $$ = $1; 
    }
    | logical_and_expression {
        if (!$1->isLogical) {
            backpatchNode* curr = $1->trueList;
            backpatchNode* next = Backpatch::addToBackpatchList(curr, irGen.currentInstrIndex);
            $1->trueList = next;
            curr = $1->falseList;
            next = Backpatch::addToBackpatchList(curr, irGen.currentInstrIndex + 1);
            $1->falseList = next;
            irGen.emit(TACOp::NE, "", $1->tacResult, "0", true);
            irGen.emit(TACOp::oth, "", "", "", true);
        }
    } LOGICAL_AND_OPERATOR M inclusive_or_expression { 
        int rhsPointerLevel = $5->pointerLevel;
        int lhsPointerLevel = $1->pointerLevel;
        if ($1->isConstVal && $5->isConstVal) $$->isConstVal = 1;
        $$ = createNode(NODE_LOGICAL_AND_EXPRESSION, $3, $1, $4); 
        $$->isLValue = false;
        $$->isLogical = true;
        if (isTypeCompatible($1->typeSpecifier, $5->typeSpecifier, "&&")) {
            $$->typeSpecifier = 3;
            typeCastFunction($1, $5, true);
            if (!$5->isLogical) {
                backpatchNode* curr = $5->trueList;
                backpatchNode* next = Backpatch::addToBackpatchList(curr, irGen.currentInstrIndex);
                $5->trueList = next;
                curr = $5->falseList;
                next = Backpatch::addToBackpatchList(curr, irGen.currentInstrIndex + 1);
                $5->falseList = next;
                irGen.emit(TACOp::NE, "", $5->tacResult, "0", true);
                irGen.emit(TACOp::oth, "", "", "", true);
            }
            string temp = irGen.newTemp();
            helper = new TreeNode(OTHERS);
            helper->typeSpecifier = $$->typeSpecifier;
            helper->value = temp;
            helper->offset = offsetStack.top();
            offsetStack.top() += 4;
            insertSymbol(temp,helper);
            $$->tacResult = temp; 
            Backpatch::backpatch($1->trueList, $4->tacResult);
            $$->trueList = $5->trueList;
            $$->falseList = Backpatch::mergeBackpatchLists($1->falseList, $5->falseList);
        } else {
            raiseError("Incompatible Type: " + to_string($1->typeSpecifier) + " and " + 
                       to_string($5->typeSpecifier), yylineno);
        }
    }
    ;

logical_or_expression
    : logical_and_expression { $$ = $1; }
    | logical_or_expression {
        if (!$1->isLogical) {
            backpatchNode* curr = $1->trueList;
            backpatchNode* next = Backpatch::addToBackpatchList(curr, irGen.currentInstrIndex);
            $1->trueList = next;
            curr = $1->falseList;
            next = Backpatch::addToBackpatchList(curr, irGen.currentInstrIndex + 1);
            $1->falseList = next;
            irGen.emit(TACOp::NE, "", $1->tacResult, "0", true);
            irGen.emit(TACOp::oth, "", "", "", true);
        }
    } LOGICAL_OR_OPERATOR M logical_and_expression { 
        int rhsPointerLevel = $5->pointerLevel;
        int lhsPointerLevel = $1->pointerLevel;
        if ($1->isConstVal && $5->isConstVal) $$->isConstVal = 1;
        $$ = createNode(NODE_LOGICAL_OR_EXPRESSION, $3, $1, $5); 
        $$->isLValue = false;
        $$->isLogical = true;
        if (isTypeCompatible($1->typeSpecifier, $5->typeSpecifier, "||")) {
            $$->typeSpecifier = 3;
            typeCastFunction($1, $5, true);
            if (!$5->isLogical) {
                backpatchNode* curr = $5->trueList;
                backpatchNode* next = Backpatch::addToBackpatchList(curr, irGen.currentInstrIndex);
                $5->trueList = next;
                curr = $5->falseList;
                next = Backpatch::addToBackpatchList(curr, irGen.currentInstrIndex + 1);
                $5->falseList = next;
                irGen.emit(TACOp::NE, "", $5->tacResult, "0", true);
                irGen.emit(TACOp::oth, "", "", "", true);
            }
            string temp = irGen.newTemp();
            helper = new TreeNode(OTHERS);
            helper->typeSpecifier = $$->typeSpecifier;
            helper->value = temp;
            helper->offset = offsetStack.top();
            offsetStack.top() += 4;
            insertSymbol(temp,helper);
            $$->tacResult = temp; 
            Backpatch::backpatch($1->falseList, $4->tacResult);
            $$->falseList = $5->falseList;
            $$->trueList = Backpatch::mergeBackpatchLists($1->trueList, $5->trueList);
        } else {
            raiseError("Incompatible Type: " + to_string($1->typeSpecifier) + " and " + 
                       to_string($5->typeSpecifier), yylineno);
        }
    }
    ;

M
    : {
        $$ = new TreeNode(OTHERS);
        $$->tacResult = to_string(irGen.currentInstrIndex);
    }
    ;

assignment_expression
    : logical_or_expression { 
        $$ = $1; 
    }
    | unary_expression assignment_operator assignment_expression { 
        $$ = createNode(NODE_ASSIGNMENT_EXPRESSION, $2->value, $1, $3);
        int rhsPointerLevel = $3->pointerLevel;
        int lhsPointerLevel = $1->pointerLevel;
        if(((lhsPointerLevel == 1 && rhsPointerLevel == 1)&&($1->typeSpecifier != $3->typeSpecifier)) && ($3->typeSpecifier != 9)){
        raiseError("Incompatible pointer types in assignment — LHS is of type '" + typeName($1->typeSpecifier) + "*', RHS is of type '" + typeName($3->typeSpecifier) + "*'", yylineno); 
        }
        else if ((rhsPointerLevel != lhsPointerLevel)) {
            raiseError("Incompatible types in compound assignment — pointer levels do not match (LHS has level " + 
                       to_string(lhsPointerLevel) + ", RHS has level " + to_string(rhsPointerLevel) + ")", yylineno);
        } else {
            if (!$1->isLValue) {
                raiseError("Left operand of assignment must be an L-value", yylineno);
            }
            if ($1->isConst) {
                raiseError("Left operand of assignment is constant", yylineno);
            }
            string op = $2->value;
            if (op == "=") {
                if($3->typeSpecifier == 9 && $1->pointerLevel == 1){
                }
                else if($3->typeSpecifier == 9 && $1->pointerLevel == 0){
                    raiseError("Null pointer should be assigned to pointer but LHS in non-pointerType", yylineno);
                }
                else if (isTypeCompatible($1->typeSpecifier, $3->typeSpecifier, op)) {
                    $$->typeSpecifier = $1->typeSpecifier;
                    if ($1->typeSpecifier != $3->typeSpecifier) {
                        string temp = irGen.newTemp();
                        helper = new TreeNode(OTHERS);
                        helper->typeSpecifier = $$->typeSpecifier;
                        helper->value = temp;
                        helper->offset = offsetStack.top();
                        offsetStack.top() += 4;
                        insertSymbol(temp,helper);
                        irGen.emit(TACOp::TYPECAST, temp, typeCastInfo($1->typeSpecifier, $3->typeSpecifier), $3->tacResult);
                        $3->tacResult = temp;
                    }
                } else {
                    raiseError("Incompatible types in assignment: " + to_string($1->typeSpecifier) + " and " + 
                               to_string($3->typeSpecifier), yylineno);
                }
            } else {
                if ($1->typeSpecifier < 0 || $1->typeSpecifier > 6) { 
                    raiseError("Compound assignment requires numeric type, got " + 
                               to_string($1->typeSpecifier), yylineno);
                }
                if (isTypeCompatible($1->typeSpecifier, $3->typeSpecifier, op)) {
                    $$->typeSpecifier = $1->typeSpecifier;
                    if ($1->typeSpecifier != $3->typeSpecifier) {
                        string temp = irGen.newTemp();
                        helper = new TreeNode(OTHERS);
                        helper->typeSpecifier = $$->typeSpecifier;
                        helper->value = temp;
                        helper->offset = offsetStack.top();
                        offsetStack.top() += 4;
                        insertSymbol(temp,helper);
                        irGen.emit(TACOp::TYPECAST, temp, typeCastInfo($1->typeSpecifier, $3->typeSpecifier), $3->tacResult);
                        $3->tacResult = temp;
                    }
                } else {
                    raiseError("Incompatible types in compound assignment: " + to_string($1->typeSpecifier) + " and " + 
                               to_string($3->typeSpecifier), yylineno);
                }
            }
            string opr = $2->value;
            if ($3->trueList || $3->falseList) {
                Backpatch::backpatch($3->trueList, to_string(irGen.currentInstrIndex));
                Backpatch::backpatch($3->falseList, to_string(irGen.currentInstrIndex + 1));
                if ($2->value == "=") {
                    irGen.emit(TACOp::ASSIGN, $1->tacResult, "1", "");
                } else {
                    irGen.emit(assignToOp(opr[0]), $1->tacResult, $1->tacResult, "1");
                }
                if ($2->value == "=") {
                    irGen.emit(TACOp::ASSIGN, $1->tacResult, "0", "");
                } else {
                    irGen.emit(assignToOp(opr[0]), $1->tacResult, $1->tacResult, "0");
                }
            } else {
                if ($2->value == "=") {
                    irGen.emit(TACOp::ASSIGN, $1->tacResult, $3->tacResult, "");
                } else {
                    irGen.emit(assignToOp(opr[0]), $1->tacResult, $3->tacResult, $3->tacResult);
                }
            }
            $$->tacResult = $1->tacResult;
        }
    }
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
    | expression COMMA assignment_expression { $$ = createNode(NODE_EXPRESSION, "", $1, $3); }
    ;

constant_expression
    : logical_or_expression { $$ = $1; $$->type = NODE_CONSTANT_EXPRESSION; }
    ;

single_expression
    : expression {
        $$ = $1;
        if (!$1->isLogical) {
            backpatchNode* curr = $1->trueList;
            backpatchNode* next = Backpatch::addToBackpatchList(curr, irGen.currentInstrIndex);
            $$->trueList = next;
            curr = $1->falseList;
            next = Backpatch::addToBackpatchList(curr, irGen.currentInstrIndex + 1);
            $$->falseList = next;
            irGen.emit(TACOp::NE, "", $1->tacResult, "0", true);
            irGen.emit(TACOp::oth, "", "", "", true);
        }
    }
    ;

declaration
    : declaration_specifiers SEMICOLON {
        $$ = $1;
    }
    | declaration_specifiers init_declarator_list SEMICOLON {
        $$ = createNode(NODE_DECLARATION, "", $1, $2);
        bool isCustom = false;
        for (auto child : $1->children) {
            if (child->type == NODE_STRUCT_SPECIFIER) {
                isCustom = true;
                break;
            }
        }
        if (isCustom) {
            if ($1->children.size() > 1) {
                raiseError("Type Qualifier or Storage Class Specifier is not allowed to be used with struct or union", yylineno);
                isCustom = false;
                break;
            }
            TreeNode* newDeclSpec = createNode(NODE_DECLARATION_SPECIFIERS, "", $1->children[0]->children[1]);
            $1->children[0]->children[1]->type = NODE_TYPE_SPECIFIER;
            addDeclarators(newDeclSpec, $2);
            $1->children[0]->children[1]->type = NODE_IDENTIFIER;
            delete newDeclSpec;
        } else {
            addDeclarators($1, $2);
        }
    }
    ;

declaration_specifiers
    : storage_class_specifier { 
        $$ = createNode(NODE_DECLARATION_SPECIFIERS, "", $1); 
    }
    | storage_class_specifier declaration_specifiers { 
        $$ = createNode(NODE_DECLARATION_SPECIFIERS, "", $1);
        for (auto child : $2->children) {
            $$->addChild(child);
        }
    }
    | type_specifier { 
        $$ = createNode(NODE_DECLARATION_SPECIFIERS, "", $1);
    }
    | type_specifier declaration_specifiers { 
        $$ = createNode(NODE_DECLARATION_SPECIFIERS, "", $1);
        for (auto child : $2->children) {
            $$->addChild(child);
        }
    }
    | type_qualifier { 
        $$ = createNode(NODE_DECLARATION_SPECIFIERS, "", $1); 
    }
    | type_qualifier declaration_specifiers { 
        $$ = createNode(NODE_DECLARATION_SPECIFIERS, "", $1);
        for (auto child : $2->children) {
            $$->addChild(child);
        }
    }
    ;

init_declarator_list
    : init_declarator { 
        $$ = createNode(NODE_DECLARATOR_LIST, "", $1); 
    }
    | init_declarator_list COMMA init_declarator { 
        $$ = $1;
        $$->children.push_back($3);
    }
    ;

init_declarator
    : declarator { 
        $$ = createNode(NODE_DECLARATOR, "", $1); 
    }
    | declarator ASSIGNMENT_OPERATOR initializer { 
        $$ = createNode(NODE_DECLARATOR, $2, $1, $3);   
    }
    ;

storage_class_specifier
    : KEYWORD_STATIC { 
        $$ = $1; 
        $$->type = NODE_STORAGE_CLASS_SPECIFIER; 
    }
    ;

type_specifier
    : struct_type_specifier { 
        $$ = $1; 
    }
    | struct_specifier { 
        $$ = $1; 
    }
    ;

struct_type_specifier
    : KEYWORD_VOID { 
        $$ = $1; 
        $$->type = NODE_TYPE_SPECIFIER; 
    }
    | KEYWORD_CHAR { 
        $$ = $1; 
        $$->type = NODE_TYPE_SPECIFIER; 
    }
    | KEYWORD_INT { 
        $$ = $1; 
        $$->type = NODE_TYPE_SPECIFIER; 
    }
    | KEYWORD_LONG { 
        $$ = $1;
        $$->type = NODE_TYPE_SPECIFIER; 
    }
    | KEYWORD_FLOAT { 
        $$ = $1; 
        $$->type = NODE_TYPE_SPECIFIER; 
    }
    | KEYWORD_DOUBLE { 
        $$ = $1; 
        $$->type = NODE_TYPE_SPECIFIER; 
    }
    | TYPE_NAME { 
        $$ = $1; 
        $$->type = NODE_TYPE_SPECIFIER; 
    }
    ;

struct_specifier
    : KEYWORD_STRUCT ID {
        string varName = $2->value;
        classOrStructOrUnion.insert(varName);
        auto checkDuplicate = [&](const string &name) {
            for (const auto &entry : currentTable->symbolTable) {
                if (entry.first == name) {
                    raiseError("Duplicate declaration of '" + name + "'", yylineno);
                    return true;
                }
            }
            return false;
        };
        if (!checkDuplicate(varName)) {
            insertSymbol(varName, $2);
            $2->typeCategory = 4;
            $2->typeSpecifier = 20;
        }
        enterScope();
    } LBRACE struct_declaration_list RBRACE {
        $$ = createNode(NODE_STRUCT_SPECIFIER, "", $1, $2, $5);
        $2->symbolTable = currentTable->symbolTable;
        $2->totalOffset = offsetStack.top();
        exitScope();
    }
    ;

struct_declaration_list
    : struct_declaration { 
        $$ = createNode(NODE_STRUCT_DECLARATION_LIST, "", $1); 
    }
    | struct_declaration_list struct_declaration { 
        $$ = $1;
        $$->children.push_back($2);
    }
    ;

struct_declaration
    : specifier_qualifier_list struct_declarator_list SEMICOLON {
        $$ = createNode(NODE_STRUCT_DECLARATION, "", $1, $2);
        addDeclarators($1, $2);
    }
    ;

specifier_qualifier_list
    : struct_type_specifier specifier_qualifier_list { 
        $$ = $2; 
        $2->addChild($1);
    }
    | struct_type_specifier { 
        $$ = createNode(NODE_SPECIFIER_QUALIFIER_LIST, "", $1); 
    }
    | type_qualifier specifier_qualifier_list { 
        $$ = $2; 
        $2->addChild($1); 
    }
    | type_qualifier { 
        $$ = createNode(NODE_SPECIFIER_QUALIFIER_LIST, "", $1); 
    }
    ;

struct_declarator_list
    : declarator { 
        TreeNode* temp = createNode(NODE_DECLARATOR, "", $1);
        $$ = createNode(NODE_STRUCT_DECLARATOR_LIST, "", temp); 
    }
    | struct_declarator_list COMMA declarator { 
        $$ = $1;
        TreeNode* temp = createNode(NODE_DECLARATOR, "", $3);
        $$->children.push_back(temp);
    }
    ;

type_qualifier
    : KEYWORD_CONST { 
        $$ = $1; 
        $$->type = NODE_TYPE_QUALIFIER; 
    }
    ;

declarator
    : pointer direct_declarator { 
        TreeNode* lastPointer = $1;
        while (!lastPointer->children.empty() && lastPointer->children[0]->type == NODE_POINTER) {
            lastPointer = lastPointer->children[0];
        }
        lastPointer->addChild($2);
        $$ = $1;
        $$->pointerLevel++;
    }
    | direct_declarator { 
        $$ = $1; 
    }
    ;

direct_declarator
    : ID { 
        $$ = $1;
        $$->tacResult = $1->value;
    }
    | LPAREN declarator RPAREN { 
        $$ = $2;
    }
    | direct_declarator LBRACKET INTEGER RBRACKET { 
        $$ = createNode(ARRAY, "", $1, $3); 
    }
    | direct_declarator LBRACKET RBRACKET { 
        $$ = createNode(ARRAY, "", $1); 
    }
    | direct_declarator LPAREN parameter_list RPAREN { 
        $$ = createNode(NODE_DECLARATOR, "", $1, $3); 
    }
    | direct_declarator LPAREN RPAREN { 
        $$ = createNode(NODE_DECLARATOR, "", $1); 
    }
    ;

pointer
    : MULTIPLY_OPERATOR { 
        $$ = createNode(NODE_POINTER, $1); 
    }
    | MULTIPLY_OPERATOR pointer{
        $$ = createNode(NODE_POINTER,$1,$2);
    }
    ;


parameter_list
    : parameter_declaration { 
        $$ = createNode(NODE_PARAMETER_LIST, "", $1); 
    }
    | parameter_list COMMA parameter_declaration { 
        $$ = $1;
        $$->children.push_back($3);
    }
    ;

parameter_declaration
    : declaration_specifiers declarator { 
        $$ = createNode(NODE_PARAMETER_DECLARATION, "", $1, $2); 
    }
    | declaration_specifiers { 
        $$ = $1; 
    }
    ;

initializer
    : assignment_expression { 
        $$ = $1; 
    }
    | LBRACE initializer_list RBRACE { 
        $$ = $2;
    }
    | LBRACE initializer_list COMMA RBRACE { 
        $$ = $2; 
    }
    ;

initializer_list
    : initializer { 
        $$ = createNode(NODE_INITIALIZER_LIST, "", $1); 
    }
    | initializer_list COMMA initializer { 
        $$ = $1;
        $$->children.push_back($3);
    }
    ;

statement
    : labeled_statement { 
        $$ = $1; 
    }
    | compound_statement { 
        $$ = $1;
    }
    | expression_statement { 
        $$ = $1; 
    }
    | selection_statement { 
        $$ = $1;
        Backpatch::backpatch($1->nextList, to_string(irGen.currentInstrIndex)); 
    }
    | iteration_statement { 
        $$ = $1;
        Backpatch::backpatch($1->nextList, to_string(irGen.currentInstrIndex)); 
    }
    | jump_statement { 
        $$ = $1; 
    }
    | io_statement { 
        $$ = $1;
    }
    ;

io_statement
    : KEYWORD_PRINTF LPAREN STRING RPAREN SEMICOLON {
        $3->tacResult = $3->value;
        $$ = createNode(NODE_IO_STATEMENT, "", $1, $3);  
        if (!checkFormatSpecifiers($3->value, {})) {
            raiseError("Format string in printf has specifiers but no arguments provided", yylineno);
            $$ = nullptr;
        } else {
            string temp = irGen.newTemp();
            irGen.emit(TACOp::PARAM, $3->tacResult);
            irGen.emit(TACOp::CALL, temp, "printf", "1");   
            $$->tacResult = temp;
        }
    }
    | KEYWORD_PRINTF LPAREN STRING COMMA argument_expression_list RPAREN SEMICOLON {
        $3->tacResult = $3->value;     
        $$ = createNode(NODE_IO_STATEMENT, "", $1, $3, $5);          
        vector<int> types = typeExtract($5);
        if (!checkFormatSpecifiers($3->value, types)) {
            raiseError("Type mismatch between format specifiers and arguments in printf", yylineno);
            $$ = nullptr;
        } else {
            irGen.emit(TACOp::PARAM, $3->tacResult);
            int paramCount = 1;
            for (auto* arg : $5->children) {
                if (arg->trueList || arg->falseList) {
                    Backpatch::backpatch(arg->trueList, to_string(irGen.currentInstrIndex));
                    Backpatch::backpatch(arg->falseList, to_string(irGen.currentInstrIndex + 1));
                    irGen.emit(TACOp::NE, "", arg->tacResult, "0", true);
                    irGen.emit(TACOp::oth, "", "", "", true);
                }
                irGen.emit(TACOp::PARAM, arg->tacResult);
                paramCount++;
            }
            string temp = irGen.newTemp();
            irGen.emit(TACOp::CALL, temp, "printf", to_string(paramCount));
            $$->tacResult = temp;   
        }
    }
    | KEYWORD_SCANF LPAREN STRING COMMA argument_expression_list RPAREN SEMICOLON {
        $3->tacResult = $3->value;
        $$ = createNode(NODE_IO_STATEMENT, "", $1, $3, $5); 
        vector<int> types = typeExtract($5);
        if (!checkFormatSpecifiers($3->value, types)) {
            raiseError("Type mismatch between format specifiers and arguments in scanf", yylineno);
            $$ = nullptr;
        } else {
            bool check = true;
            for (auto* arg : $5->children) {
                if (!arg->isLValue || arg->pointerLevel < 1) {
                    raiseError("scanf argument must be an l-value pointer", yylineno);
                    check = false;
                    break;
                }
            }
            if (check) {
                irGen.emit(TACOp::PARAM, $3->tacResult);
                int paramCount = 1;
                for (auto* arg : $5->children) {
                    if (arg->trueList || arg->falseList) {
                        Backpatch::backpatch(arg->trueList, to_string(irGen.currentInstrIndex));
                        Backpatch::backpatch(arg->falseList, to_string(irGen.currentInstrIndex + 1));
                        irGen.emit(TACOp::NE, "", arg->tacResult, "0", true);
                        irGen.emit(TACOp::oth, "", "", "", true);
                    }
                    irGen.emit(TACOp::PARAM, arg->tacResult);
                    paramCount++;
                }
                string temp = irGen.newTemp();
                
                irGen.emit(TACOp::CALL, temp, "scanf", to_string(paramCount));
                $$->tacResult = temp;   
            }
        }
    }
    ;

labeled_statement
    : ID {
        if (labelToBeDefined.top().find($1->value) != labelToBeDefined.top().end()) {
            Backpatch::backpatch(labelToBeDefined.top()[$1->value], to_string(irGen.currentInstrIndex));
            labelToBeDefined.top().erase($1->value);
        }
        $1->typeCategory = 7;
        $1->typeSpecifier = 9;
        $1->tacResult = to_string(irGen.currentInstrIndex);
        insertSymbol($1->value, $1);
        irGen.emit(TACOp::LABEL, $1->value);
    } COLON statement {
        $$ = createNode(NODE_LABELED_STATEMENT, "", $1, $4);
    }
    | KEYWORD_CASE constant_expression COLON M statement {
        if (inSwitch.empty()) {
            raiseError("case statement must be inside a switch statement", yylineno);
        }
        if (case_id.top().find($2->value) != case_id.top().end()) {
            raiseError("Duplicate case label '" + $2->value + "' detected in switch statement", yylineno);
        }
        if ($2->typeSpecifier != 1 && $2->typeSpecifier != 2 && $2->typeSpecifier != 3 && $2->typeSpecifier != 4) {
            raiseError("Case expression must be of an integral or char type, found type " + to_string($2->typeSpecifier), yylineno);
        }
        if (switch_type != $2->typeSpecifier) {
            string temp = irGen.newTemp();
            helper = new TreeNode(OTHERS);
            helper->typeSpecifier = switch_type;
            helper->value = temp;
            helper->offset = offsetStack.top();
            offsetStack.top() += 4;
            insertSymbol(temp, helper);
            irGen.emit(TACOp::TYPECAST, temp, typeCastInfo(switch_type, $2->typeSpecifier), $2->tacResult); 
            $2->tacResult = temp;
        }
        if ($2->isConstVal == 0) {
            raiseError("Case value '" + $2->value + "' is not a constant expression", yylineno);
        }
        case_id.top().insert($2->value);
        $$ = $5;
        $$->switchList = Backpatch::addToBackpatchList(nullptr, stoi($4->tacResult), $2->tacResult);
    }
    | KEYWORD_DEFAULT COLON M statement {
        if (inSwitch.empty()) {
            raiseError("default case must be inside a switch statement", yylineno);
        } else if (inSwitch.top()) {
            raiseError("Multiple default cases in switch statement", yylineno);
        } else {
            inSwitch.pop();
            inSwitch.push(true);
        }
        $$ = $4;
        $$->continueList = Backpatch::addToBackpatchList(nullptr, stoi($3->tacResult));
    }
    ;

compound_statement
    : LBRACE { 
        enterScope(); 
    } RBRACE { 
        $$ = createNode(NODE_COMPOUND_STATEMENT, ""); 
        exitScope();
    }
    | LBRACE { 
        enterScope(); 
    } block_item_list RBRACE {
        $$ = $3; 
        exitScope(); 
    }
    ;

block_item_list
    : block_item { 
        $$ = $1;
    }
    | block_item_list block_item { 
        $$ = $1; 
        $$->children.push_back($2);
        $$->continueList = Backpatch::mergeBackpatchLists($1->continueList, $2->continueList);
        $$->breakList = Backpatch::mergeBackpatchLists($1->breakList, $2->breakList);
        $$->switchList = Backpatch::mergeBackpatchLists($1->switchList, $2->switchList);
        $$->goToList = Backpatch::mergeBackpatchLists($1->goToList, $2->goToList);
    }
    ;

block_item
    : declaration {
        $$ = $1;
    }
    | statement {
        $$ = $1;
    }
    ;

expression_statement
    : SEMICOLON {
        $$ = createNode(NODE_EXPRESSION_STATEMENT, "");
    }
    | expression SEMICOLON {
        $$ = $1;
    }
    ;

selection_statement
    : KEYWORD_IF LPAREN single_expression RPAREN M statement N %prec NO_ELSE {
        Backpatch::backpatch($3->trueList, $5->tacResult); 
        backpatchNode* merged = Backpatch::mergeBackpatchLists($3->falseList, $7->nextList); 
        $$->nextList = Backpatch::mergeBackpatchLists(merged, $6->nextList);
        $$->goToList = $6->goToList;
        $$->breakList = $6->breakList;
        $$->continueList = $6->continueList;                
    }
    | KEYWORD_IF LPAREN single_expression RPAREN M statement N KEYWORD_ELSE M statement {
        Backpatch::backpatch($3->trueList, $5->tacResult); 
        Backpatch::backpatch($3->falseList, $9->tacResult);
        backpatchNode* merged = Backpatch::mergeBackpatchLists($6->nextList, $7->nextList);
        $$->nextList = Backpatch::mergeBackpatchLists(merged, $10->nextList);
        $$->goToList = Backpatch::mergeBackpatchLists($6->goToList, $10->goToList);
        $$->breakList = Backpatch::mergeBackpatchLists($6->breakList, $10->breakList);
        $$->continueList = Backpatch::mergeBackpatchLists($6->continueList, $10->continueList);
    }
    | KEYWORD_SWITCH {
        switchStack.push(irGen.currentInstrIndex);
        irGen.emit(TACOp::oth, "", "", "", true);
    } LPAREN expression RPAREN {
        enterScope(); 
        inLoop++; 
        inSwitch.push(false); 
        case_id.push({});  
        switch_type = $4->typeSpecifier;
    } statement {
        if ($4->typeSpecifier == 1 || $4->typeSpecifier == 2 || $4->typeSpecifier == 3 || $4->typeSpecifier == 4) {
            $$->nextList = Backpatch::addToBackpatchList($$->nextList, irGen.currentInstrIndex);
            irGen.emit(TACOp::oth, "", "", "", true);
            irGen.tacCode[switchStack.top()].result = to_string(irGen.currentInstrIndex);
            switchStack.pop();
            backpatchNode* curr = $7->switchList;
            $$->nextList = Backpatch::mergeBackpatchLists($$->nextList, $7->breakList);
            $$->goToList = $7->goToList;
            while (curr) {
                irGen.emit(TACOp::EQ, to_string(curr->index), $4->tacResult, curr->exp, true);
                curr = curr->next;
            }
            if ($7->continueList) {
                irGen.emit(TACOp::oth, to_string($7->continueList->index), "", "", true);
            }
            exitScope();
            inLoop--;
            inSwitch.pop();
            case_id.pop();
        } else {
            raiseError("Switch expression must be of an integral or char type, found type " + to_string($4->typeSpecifier), yylineno);
            $$ = nullptr;
        }
    }
    ;

iteration_statement
    : M KEYWORD_WHILE LPAREN single_expression RPAREN {
        enterScope(); 
        inLoop++;
    } M statement {
        Backpatch::backpatch($4->trueList, $7->tacResult);
        Backpatch::backpatch($8->nextList, $1->tacResult);
        irGen.emit(TACOp::oth, $1->tacResult, "", "", true);
        Backpatch::backpatch($8->continueList, $1->tacResult);
        $$->nextList = Backpatch::mergeBackpatchLists($8->breakList, $4->falseList);
        $$->goToList = $8->goToList;
        inLoop--;
        exitScope();
    }
    | KEYWORD_DO M {
        enterScope(); 
        inLoop++;
    } statement M {
        inLoop--; 
        exitScope();
    } KEYWORD_WHILE LPAREN single_expression RPAREN {
        Backpatch::backpatch($9->trueList, $2->tacResult);
        Backpatch::backpatch($4->continueList, $5->tacResult);
        $$->nextList = Backpatch::mergeBackpatchLists($4->breakList, $9->falseList);
        $$->goToList = $4->goToList;
    }
    | KEYWORD_FOR LPAREN {
        enterScope();
    } for_init M for_cond M for_inc RPAREN {
        inLoop++;
        irGen.emit(TACOp::oth, $5->tacResult, "", "", true);
    } M statement {
        Backpatch::backpatch($6->trueList, $11->tacResult);            
        Backpatch::backpatch($12->nextList, $7->tacResult);
        Backpatch::backpatch($12->continueList, $7->tacResult);
        $$->nextList = Backpatch::mergeBackpatchLists($12->breakList, $6->falseList);
        $$->goToList = $12->goToList;
        irGen.emit(TACOp::oth, $7->tacResult, "", "", true);
        exitScope();
        inLoop--; 
    }
    |M KEYWORD_UNTIL LPAREN single_expression RPAREN KEYWORD_DO M {
        enterScope(); 
        inLoop++;
    } statement KEYWORD_DONE SEMICOLON {
        inLoop--; 
        exitScope();
        Backpatch::backpatch($4->falseList, $7->tacResult);
        Backpatch::backpatch($9->continueList, $1->tacResult);
        $$->nextList = Backpatch::mergeBackpatchLists($9->breakList, $4->trueList);
        $$->goToList = $10->goToList;
    }

for_init
    : expression_statement {
        $$ = $1;
    }
    | declaration {
        $$ = $1;
    }
    ;

for_cond
    : expression_statement {
        $$ = $1;
    }
    ;

for_inc
    : expression {
        $$ = $1;
    }
    | expression_statement {
        $$ = $1;
    }
    ;

jump_statement
    : KEYWORD_GOTO ID SEMICOLON {
        $$ = createNode(NODE_JUMP_STATEMENT, "", $1, $2);
        TreeNode* labelNode = lookupSymbol($2->value, true);
        if (!labelNode) {
            backpatchNode* newList = Backpatch::addToBackpatchList(nullptr, irGen.currentInstrIndex);
            labelToBeDefined.top()[$2->value] = Backpatch::mergeBackpatchLists(labelToBeDefined.top()[$2->value], newList);
            irGen.emit(TACOp::oth, "", "", "", true);
        } else {
            irGen.emit(TACOp::GOTO, labelNode->tacResult);
        }
    }
    | KEYWORD_CONTINUE SEMICOLON {
        if (inLoop <= 0) {
            raiseError("continue statement must be inside a loop", yylineno);
        } else if (!inSwitch.empty()) {
            raiseError("continue statement cannot be used inside a switch statement", yylineno);
        } else {
            $$ = createNode(NODE_JUMP_STATEMENT, "", $1);
            $$->continueList = Backpatch::addToBackpatchList(nullptr, irGen.currentInstrIndex);
            irGen.emit(TACOp::oth, "", "", "", true);
        }
    }
    | KEYWORD_BREAK SEMICOLON {
        if (inLoop <= 0) {
            raiseError("break statement must be inside a loop or switch", yylineno);
        } else {
            $$ = createNode(NODE_JUMP_STATEMENT, "", $1);
            $$->breakList = Backpatch::addToBackpatchList(nullptr, irGen.currentInstrIndex);
            irGen.emit(TACOp::oth, "", "", "", true);
        }
    }
    | KEYWORD_RETURN SEMICOLON {
        if (!inFunc) {
            raiseError("return statement must be inside a function", yylineno);
        } else if (expectedReturnType != -1) {
            raiseError("Expected return expression in non-void function", yylineno);
        } else {
            $$ = createNode(NODE_JUMP_STATEMENT, "", $1);
            irGen.emit(TACOp::RETURN, "");
        }
    }
    | KEYWORD_RETURN expression SEMICOLON {
        if (!inFunc) {
            raiseError("return statement must be inside a function", yylineno);
        } else if (expectedReturnType == -1) {
            raiseError("Return statement with value in void function", yylineno);
        } else if (!isTypeCompatible(expectedReturnType, $2->typeSpecifier, "=")) {
            raiseError("Type mismatch in return statement: expected type " + to_string(expectedReturnType) + ", got type " + to_string($2->typeSpecifier), yylineno);
        } else {
            $$ = createNode(NODE_JUMP_STATEMENT, "", $1, $2);
            if (expectedReturnType != $2->typeSpecifier) {
                string temp = irGen.newTemp();
                helper = new TreeNode(OTHERS);
                helper->typeSpecifier = expectedReturnType;
                helper->value = temp;
                helper->offset = offsetStack.top();
                offsetStack.top() += 4;
                insertSymbol(temp, helper);
                irGen.emit(TACOp::TYPECAST, temp, typeCastInfo(expectedReturnType, $2->typeSpecifier), $2->tacResult);
                irGen.emit(TACOp::RETURN, temp);
            } else {
                irGen.emit(TACOp::RETURN, $2->tacResult);
            }
        }
    }
    ;

translation_unit
    : external_declaration {
        $$ = $1; 
    }
    | translation_unit external_declaration {
        $$ = createNode(NODE_TRANSLATION_UNIT, "", $1, $2);
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

compound_statement_func
    : LBRACE RBRACE {
        $$ = createNode(NODE_COMPOUND_STATEMENT, "");
    }
    | LBRACE block_item_list RBRACE {
        $$ = $2;
    }
    ;

function_definition
    : declaration_specifiers declarator {
        addFunction($1, $2);
        inFunc = true;
    } compound_statement_func {
        $$ = createNode(NODE_FUNCTION_DEFINITION, "" , $1, $2, $4);
        inFunc = false;
        exitScope();
        expectedReturnType = -1;
    }
    ;

%%

void yyerror(const char *s) {
    extern char *yytext;
    extern int yylineno;
    cerr << "Error: " << s << " at '" << yytext << "' on line " << yylineno << endl;
}


vector<TACInstruction> parser(int argc, char **argv)
{
    if (argc < 2)
    {
        cout << "Usage: " << argv[0] << " <input_file>" << endl;
        return {};
    }

    yyin = fopen(argv[1], "r");
    if (!yyin)
    {
        cout << "Error opening file" << endl;
        return {};
    }

    currentTable = new Table();
    tableStack.push(currentTable);
    offsetStack.push(0);
    labelToBeDefined.push({});
    allTables.push_back(currentTable);

    mkdir("output", 0777);
    mkdir("error", 0777);
    mkdir("symTab", 0777);

    string inputPath(argv[1]);
    string base = inputPath.substr(inputPath.find_last_of("/\\") + 1);
    string baseName = base.substr(0, base.find_last_of('.'));
    string outName = "output/" + baseName + ".3ac";
    string errName = "error/" + baseName + ".err";
    string symTabName = "symTab/" + baseName + ".txt";
    
    ofstream err(errName);
    ofstream out(outName);
    ofstream sym(symTabName);
    
    streambuf *coutbuf = cout.rdbuf();
    cerr.rdbuf(err.rdbuf());
    if(!err)
    {
        cout << "Error opening error file: " << errName << endl;
        return {};
    }else if (!out)
    {
        cout << "Error opening output file: " << outName << endl;
        return {};
    }else if(!sym){
        cout << "Error opening symtab file: " << symTabName << endl;
        return {};
    }

    yyparse();
    fclose(yyin);

    cout.rdbuf(sym.rdbuf());
    printAllTables();
    cout.rdbuf(coutbuf);

    cout.rdbuf(out.rdbuf());
    irGen.printTAC();
    cout.rdbuf(coutbuf);
    return irGen.tacCode;
}
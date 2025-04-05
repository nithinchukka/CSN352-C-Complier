// ast.h or tac.h
#ifndef TAC_H
#define TAC_H

#include <bits/stdc++.h>
using namespace std;
enum class TACOp
{
    ASSIGN,
    ADD,
    SUB,
    MUL,
    DIV,
    MOD,
    INDEX,
    LABEL,
    GOTO,
    IF_EQ,
    IF_NE,
    LSHFT,
    RSHFT,
    LT,
    GT,
    LE,
    GE,
    EQ,
    NE,
    BIT_AND,
    BIT_OR,
    BIT_XOR,
    AND,
    OR,
    XOR,
    PRINT,
    RETURN,
    CALL,
    TYPECAST
};

struct TACInstruction
{
    TACOp op;
    string result;
    optional<string> operand1;
    optional<string> operand2;
    int storageClass;
    vector<int> dimensions;

    TACInstruction(TACOp operation, const string &res,
                   const optional<string> &op1 = nullopt,
                   const optional<string> &op2 = nullopt,
                   int type = 0, const vector<int> &dims = {})
        : op(operation), result(res), operand1(op1), operand2(op2),
          storageClass(type), dimensions(dims) {}

    string toString() const
    {
        string str;
        switch (op)
        {
        case TACOp::ASSIGN:
            str = result + " = " + (operand1 ? *operand1 : "");
            break;
        case TACOp::ADD:
            str = result + " = " + *operand1 + " + " + *operand2;
            break;
        case TACOp::SUB:
            str = result + " = " + *operand1 + " - " + *operand2;
            break;
        case TACOp::MUL:
            str = result + " = " + *operand1 + " * " + *operand2;
            break;
        case TACOp::DIV:
            str = result + " = " + *operand1 + " / " + *operand2;
            break;
        case TACOp::MOD:
            str = result + " = " + *operand1 + " % " + *operand2;
            break;
        case TACOp::LSHFT:
            str = result + " = " + *operand1 + " << " + *operand2;
            break;
        case TACOp::RSHFT:
            str = result + " = " + *operand1 + " >> " + *operand2;
            break;
        case TACOp::LT:
            str = result + " = " + *operand1 + " < " + *operand2;
            break;
        case TACOp::GT:
            str = result + " = " + *operand1 + " > " + *operand2;
            break;
        case TACOp::LE:
            str = result + " = " + *operand1 + " <= " + *operand2;
            break;
        case TACOp::GE:
            str = result + " = " + *operand1 + " >= " + *operand2;
            break;
        case TACOp::EQ:
            str = result + " = " + *operand1 + " == " + *operand2;
            break;
        case TACOp::NE:
            str = result + " = " + *operand1 + " != " + *operand2;
            break;
        case TACOp::BIT_AND:
            str = result + " = " + *operand1 + " & " + *operand2;
            break;
        case TACOp::BIT_OR:
            str = result + " = " + *operand1 + " | " + *operand2;
            break;
        case TACOp::BIT_XOR:
            str = result + " = " + *operand1 + " ^ " + *operand2;
            break;
        case TACOp::AND:
            str = result + " = " + *operand1 + " && " + *operand2;
            break;
        case TACOp::OR:
            str = result + " = " + *operand1 + " || " + *operand2;
            break;
        case TACOp::XOR:
            str = result + " = " + *operand1 + " ^ " + *operand2;
            break;
        case TACOp::PRINT:
            str = "print " + result;
            break;
        case TACOp::INDEX:
            str = result + " = " + *operand1 + "[" + *operand2 + "]";
            break;
        case TACOp::LABEL:
            str = result + ":";
            break;
        case TACOp::GOTO:
            str = "goto " + result;
            break;
        case TACOp::IF_EQ:
            str = "if " + *operand1 + " == " + *operand2 + " goto " + result;
            break;
        case TACOp::IF_NE:
            str = "if " + *operand1 + " != " + *operand2 + " goto " + result;
            break;
        case TACOp::RETURN:
            str = "return " + result;
            break;
        case TACOp::CALL:
            str = result + " = call " + *operand1 + "(" + (operand2 ? *operand2 : "") + ")";
            break;
        case TACOp::TYPECAST:
            str = result + " = " + *operand1 + "(" + *operand2 + ")";
            break;
        default:
            str = "Unknown";
            break;
        }
        if (!dimensions.empty())
        {
            str += " [dims: ";
            for (int d : dimensions)
                str += to_string(d) + " ";
            str += "]";
        }
        return str;
    }
};

struct CodeGenerator
{
    vector<TACInstruction> tacCode;
    int tempCounter = 0;
    int labelCounter = 0;
    int currentInstrIndex = 0;
    ofstream out;

    CodeGenerator()
    {
        out.open("tac");
    }

    string newTemp()
    {
        return "t" + to_string(tempCounter++);
    }

    string newLabel()
    {
        return "L" + to_string(labelCounter++);
    }

    int emit(TACOp op, const string &result,
             const optional<string> &op1 = nullopt,
             const optional<string> &op2 = nullopt,
             int storageClass = 0, const vector<int> &dims = {})
    {
        tacCode.emplace_back(op, result, op1, op2, storageClass, dims);
        return currentInstrIndex++;
    }

    vector<int> makeList(int instructionIndex)
    {
        return {instructionIndex};
    }

    vector<int> merge(const vector<int> &list1, const vector<int> &list2)
    {
        vector<int> result = list1;
        result.insert(result.end(), list2.begin(), list2.end());
        return result;
    }

    void backpatch(const vector<int> &list, const string &label)
    {
        for (int index : list)
        {
            if (index >= 0 && index < tacCode.size())
            {
                TACInstruction &instr = tacCode[index];
                // Update the result field (jump target) with the label
                if (instr.op == TACOp::GOTO || instr.op == TACOp::IF_EQ || instr.op == TACOp::IF_NE)
                {
                    instr.result = label;
                }
            }
        }
    }

    void printTAC()
    {
        for (const auto &instr : tacCode)
        {
            // cout << instr.toString() << "\n";
            out << instr.toString() << "\n";
        }
    }
};
#endif
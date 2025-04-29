#include <bits/stdc++.h>
#include "../inc/tac.h"
#include "../inc/treeNode.h"
using namespace std;

vector<set<TreeNode *>> registerDescriptor(16);
map<TreeNode *, set<TreeNode *>> addressDescriptor;
vector<TreeNode *> regMap = {
    new TreeNode(REGISTER, "rsp"),
    new TreeNode(REGISTER, "rbp"),
    new TreeNode(REGISTER, "rax"),
    new TreeNode(REGISTER, "rdx"),
    new TreeNode(REGISTER, "rbx"),
    new TreeNode(REGISTER, "rcx"),
    new TreeNode(REGISTER, "rsi"),
    new TreeNode(REGISTER, "rdi"),
    new TreeNode(REGISTER, "r8"),
    new TreeNode(REGISTER, "r9"),
    new TreeNode(REGISTER, "r10"),
    new TreeNode(REGISTER, "r11"),
    new TreeNode(REGISTER, "r12"),
    new TreeNode(REGISTER, "r13"),
    new TreeNode(REGISTER, "r14"),
    new TreeNode(REGISTER, "r15")};

vector<string> asmOutput;

void emitFuncExit()
{
    asmOutput.push_back("    mov rsp, rbp");
    asmOutput.push_back("    pop " + regMap[1]->value);
    asmOutput.push_back("    ret");
}

void emitFuncEntry(int totalSize)
{
    asmOutput.push_back("    push " + regMap[1]->value);
    asmOutput.push_back("    mov " + regMap[1]->value + ", " + regMap[0]->value);
    asmOutput.push_back("    sub " + regMap[0]->value + ", " + to_string(totalSize));
}

void emitNormalSysExit()
{
    asmOutput.push_back("    mov rax, 60");
    asmOutput.push_back("    xor rdi, rdi");
    asmOutput.push_back("    syscall");
}

void emitCode(const string &code)
{
    asmOutput.push_back(code);
}

void emitStart()
{
    emitCode("    .intel_syntax noprefix");
    emitCode("    .text");
    emitCode("    .global _start");
    emitCode("    .global main");
    emitCode("_start:");
    emitCode("    call main");
    emitCode("    mov rax, 60");
    emitCode("    xor rdi, rdi");
    emitCode("    syscall");
}

string baseAdressing(TreeNode *var)
{
    if (lookupSymbol(var->value, true, false))
    {
        return "[rip + " + var->value + "]";
    }
    if (var->paramCount > 0)
    {
        return "[" + regMap[1]->value + " + " + to_string(var->paramCount * 8 + 8) + "]";
    }
    return "[" + regMap[1]->value + " - " + to_string(var->offset) + "]";
}

int getSize(int typeSpec)
{ // string
    switch (typeSpec)
    {
    case 1: // char
        return 1;
    case 3: // int
        return 4;
    case 4: // long
        return 8;
    case 6: // float
        return 4;
    case 7: // double
        return 8;
    case 9:
        return 8; // pointer

    default:
        return -1; // Invalid type
    }
}

unordered_map<TACOp, string> conditionalMapping = {
    {TACOp::EQ, "je"},
    {TACOp::NE, "jne"},
    {TACOp::LE, "jle"},
    {TACOp::LT, "jl"},
    {TACOp::GE, "jge"},
    {TACOp::GT, "jg"},
};

string getRegisterBySize(const string &reg, int typeSpec)
{
    int size = getSize(typeSpec);
    if (size == -1)
    {
        return ""; // Invalid typeSpec, return empty
    }

    if (size != 1 && size != 2 && size != 4 && size != 8)
    {
        return ""; // Unsupported size, return empty
    }

    const map<string, map<int, string>> standardRegisterMap = {
        {"rax", {{8, "rax"}, {4, "eax"}, {2, "ax"}, {1, "al"}}},
        {"rbx", {{8, "rbx"}, {4, "ebx"}, {2, "bx"}, {1, "bl"}}},
        {"rcx", {{8, "rcx"}, {4, "ecx"}, {2, "cx"}, {1, "cl"}}},
        {"rdx", {{8, "rdx"}, {4, "edx"}, {2, "dx"}, {1, "dl"}}},
        {"rsi", {{8, "rsi"}, {4, "esi"}, {2, "si"}, {1, "sil"}}},
        {"rdi", {{8, "rdi"}, {4, "edi"}, {2, "di"}, {1, "dil"}}},
        {"rbp", {{8, "rbp"}, {4, "ebp"}, {2, "bp"}, {1, "bpl"}}},
        {"rsp", {{8, "rsp"}, {4, "esp"}, {2, "sp"}, {1, "spl"}}}};

    auto it_reg = standardRegisterMap.find(reg);
    if (it_reg != standardRegisterMap.end())
    {
        const auto &sizeMap = it_reg->second;
        auto it_size = sizeMap.find(size);
        if (it_size != sizeMap.end())
        {
            return it_size->second; // Found matching size variant
        }
        else
        {
            return ""; // Size variant not found
        }
    }

    bool isNumberedReg = false;
    // Check if reg is something like r8, r9, r10–r15
    if (reg.length() >= 2 && reg[0] == 'r' && isdigit(reg[1]))
    {
        if ((reg.length() == 2 && reg[1] >= '8' && reg[1] <= '9') ||
            (reg.length() == 3 && reg[1] == '1' && isdigit(reg[2]) && reg[2] >= '0' && reg[2] <= '5'))
        {
            isNumberedReg = true;
        }
    }

    if (isNumberedReg)
    {
        switch (size)
        {
        case 8:
            return reg; // 64-bit register
        case 4:
            return reg + "d"; // 32-bit register
        case 2:
            return reg + "w"; // 16-bit register
        case 1:
            return reg + "b"; // 8-bit register
        default:
            return "";
        }
    }

    return ""; // Not a standard or numbered register
}

string getGOTOLabel(int target, const vector<pair<int, int>> &basicBlocks)
{
    for (int i = 0; i < basicBlocks.size(); ++i)
    {
        if (basicBlocks[i].first == target)
            return ".L" + to_string(i);
    }
    return "";
}

string getWordPTR(int typeSpec)
{
    switch (typeSpec)
    {
    case 1: // char
        return "BYTE PTR";
    case 2: // short
        return "WORD PTR";
    case 3: // int
        return "DWORD PTR";
    case 4: // long
        return "QWORD PTR";
    case 6: // float
        return "DWORD PTR";
    case 7: // double
        return "QWORD PTR";
    default:
        return "";
    }
}

void spillAllRegisters()
{
    for (int i = 4; i < registerDescriptor.size(); i++)
    {
        for (TreeNode *var : registerDescriptor[i])
        {
            if (addressDescriptor.count(var))
            {
                emitCode("    mov " + getWordPTR(var->typeSpecifier) + " " + baseAdressing(var) + ", " + getRegisterBySize(regMap[i]->value, var->typeSpecifier));
                addressDescriptor[var].erase(regMap[i]);
                if (addressDescriptor[var].empty())
                    addressDescriptor.erase(var);
            }
        }
        registerDescriptor[i].clear();
    }
    addressDescriptor.clear(); // Clear address descriptor
}

int checkAddressDescriptor(TreeNode *arg)
{
    for (int i = 4; i < registerDescriptor.size(); i++)
    {
        if (registerDescriptor[i].find(arg) != registerDescriptor[i].end())
            return i;
    }
    return -1;
}

int findEmptyRegister()
{
    for (int i = 4; i < registerDescriptor.size(); i++)
    {
        if (registerDescriptor[i].empty())
            return i;
    }
    return -1;
}

int evictAndAssignRegister(const unordered_set<string> &liveVars, int regY = -1, int regZ = -1)
{
    // Step 1: Find a register with all dead variables
    for (int i = 4; i < registerDescriptor.size(); ++i)
    {
        if (i == regY || i == regZ)
            continue;
        bool allDead = true;
        for (TreeNode *var : registerDescriptor[i])
        {
            if (!(var->value[0] == '#' && liveVars.find(var->value) == liveVars.end()))
            {
                allDead = false;
                break;
            }
        }
        if (allDead)
        {
            for (TreeNode *var : registerDescriptor[i])
            {
                if (addressDescriptor.count(var))
                    addressDescriptor.erase(var);
            }
            registerDescriptor[i].clear();
            return i;
        }
    }

    // Step 2: Find a register where all variables are in memory or other registers
    for (int i = 4; i < registerDescriptor.size(); ++i)
    {
        if (i == regY || i == regZ)
            continue;
        bool safe = true;
        for (TreeNode *var : registerDescriptor[i])
        {
            bool inMemOrReg = false;
            if (addressDescriptor.count(var) && addressDescriptor[var].size() > 1)
                inMemOrReg = true;
            if (!inMemOrReg)
            {
                safe = false;
                break;
            }
        }
        if (safe)
        {
            for (TreeNode *var : registerDescriptor[i])
                addressDescriptor[var].erase(regMap[i]);
            registerDescriptor[i].clear();
            return i;
        }
    }

    // Step 3: Spill a register (skip rsp, rbp, rip, rax, rdi)
    int regToSpill = -1;
    for (int i = 4; i < registerDescriptor.size(); ++i)
    {
        if (i != regY && i != regZ)
        {
            regToSpill = i;
            break;
        }
    }

    if (regToSpill == -1)
        return -1;

    // Spill variables in regToSpill
    for (TreeNode *var : registerDescriptor[regToSpill])
    {
        if (addressDescriptor.count(var))
        {
            bool inMemory = addressDescriptor[var].size() > 1;
            if (!inMemory)
            {
                emitCode("    mov " + getWordPTR(var->typeSpecifier) + " " + baseAdressing(var) + ", " + getRegisterBySize(regMap[regToSpill]->value, var->typeSpecifier));
            }
            addressDescriptor[var].erase(regMap[regToSpill]);
            if (addressDescriptor[var].empty())
                addressDescriptor.erase(var);
        }
    }
    registerDescriptor[regToSpill].clear();

    return regToSpill;
}

int fetchRegForImmediate(const unordered_set<string> &liveVars, int regX = -1)
{
    int reg = findEmptyRegister();
    if (reg == -1)
        reg = evictAndAssignRegister(liveVars, regX);
    return reg;
}

struct RegInfo
{
    int reg = -1;
    bool loadReq = false;
};

vector<RegInfo> getRegister(const TACInstruction &instr, const unordered_set<string> &liveVars)
{
    string arg1 = instr.operand1;
    string arg2 = instr.operand2;
    string result = instr.result;
    if (instr.op == TACOp::GOTO || instr.op == TACOp::oth || instr.op == TACOp::LABEL ||
        instr.op == TACOp::CALL || instr.op == TACOp::PRINT || instr.op == TACOp::SCAN ||
        instr.op == TACOp::CALL2 || instr.op == TACOp::IF_EQ || instr.op == TACOp::IF_NE ||
        instr.op == TACOp::RETURN || instr.op == TACOp::ENDFUNC || instr.op == TACOp::STARTFUNC || instr.op == TACOp::PARAM)
        return {};

    RegInfo regX, regY, regZ;
    // Assign register if not immediate value
    if (instr.opNode1 != nullptr)
    {
        regY.reg = checkAddressDescriptor(instr.opNode1); // return if already present
        if (regY.reg == -1)
        {
            regY.loadReq = true;
            regY.reg = findEmptyRegister(); // find an empty register

            if (regY.reg == -1)
                regY.reg = evictAndAssignRegister(liveVars); // use eviction
            registerDescriptor[regY.reg].insert(instr.opNode1);
            addressDescriptor[instr.opNode1].insert(regMap[regY.reg]);
        }
    }

    // Assign register if not immediate value
    if (instr.opNode2 != nullptr)
    {
        regZ.reg = checkAddressDescriptor(instr.opNode2);
        if (regZ.reg == -1)
        {
            regZ.loadReq = true;
            regZ.reg = findEmptyRegister();
            if (regZ.reg == -1)
                regZ.reg = evictAndAssignRegister(liveVars, regY.reg);
            registerDescriptor[regZ.reg].insert(instr.opNode2);
            addressDescriptor[instr.opNode2].insert(regMap[regZ.reg]);
        }
    }

    // Assign register if not immediate value
    if (instr.resNode != nullptr)
    {
        regX.reg = checkAddressDescriptor(instr.resNode);
        if (regX.reg == -1) // try to assign y or z
        {
            // if (arg1.size() && arg1[0] == '#' && liveVars.find(arg1) == liveVars.end() && regY.reg != -1)
            // {
            //     regX.reg = regY.reg;
            //     registerDescriptor[regX.reg].erase(instr.opNode1);
            //     registerDescriptor[regX.reg].insert(instr.resNode);
            //     addressDescriptor[instr.opNode1].erase(regMap[regX.reg]);
            // }
            // else if (arg2.size() && arg2[0] == '#' && liveVars.find(arg2) == liveVars.end() && regZ.reg != -1)
            // {
            //     regX.reg = regZ.reg;
            //     registerDescriptor[regX.reg].erase(instr.opNode2);
            //     registerDescriptor[regX.reg].insert(instr.resNode);
            //     addressDescriptor[instr.opNode2].erase(regMap[regX.reg]);
            // }
            if (regX.reg == -1)
            {
                regX.reg = findEmptyRegister();
                if (regX.reg == -1)
                    regX.reg = evictAndAssignRegister(liveVars, regY.reg, regZ.reg);
                registerDescriptor[regX.reg].insert(instr.resNode);
                addressDescriptor[instr.resNode].insert(regMap[regX.reg]);
            }
        }
    }
    return {regX, regY, regZ};
}

void generateCodeForBasicBlock(const vector<TACInstruction> &tacCode, const vector<unordered_set<string>> &liveness, const vector<pair<int, int>> &basicBlocks, int blockNo)
{
    emitCode(".L" + to_string(blockNo) + ":"); // emit label block start
    for (int i = basicBlocks[blockNo].first; i <= basicBlocks[blockNo].second; ++i)
    {
        const TACInstruction &instr = tacCode[i];
        unordered_set<string> liveVars = liveness[i];
        vector<RegInfo> regs = getRegister(instr, liveVars);
        if (!regs.empty())
        {
            RegInfo regX = regs[0];
            RegInfo regY = regs[1];
            RegInfo regZ = regs[2];
            if (regY.loadReq) // load if required
            {
                emitCode("    mov " + getRegisterBySize(regMap[regY.reg]->value, instr.opNode1->typeSpecifier) + ", " + getWordPTR(instr.opNode1->typeSpecifier) + " " + baseAdressing(instr.opNode1));
            }
            if (regZ.loadReq)
            {
                emitCode("    mov " + getRegisterBySize(regMap[regZ.reg]->value, instr.opNode2->typeSpecifier) + ", " + getWordPTR(instr.opNode1->typeSpecifier) + " " + baseAdressing(instr.opNode2));
            }
            if (instr.isGoto) // handle statements containing goto
            {
                string target = getGOTOLabel(stoi(instr.result), basicBlocks);
                if (instr.op == TACOp::oth)
                {
                    emitCode("    jmp " + target);
                }
                else
                {
                    if (instr.opNode1 && instr.opNode2)
                        emitCode("    cmp " + getRegisterBySize(regMap[regY.reg]->value, instr.opNode1->typeSpecifier) + ", " + getRegisterBySize(regMap[regZ.reg]->value, instr.opNode2->typeSpecifier));
                    else if (instr.opNode1)
                    {
                        emitCode("    cmp " + getRegisterBySize(regMap[regY.reg]->value, instr.opNode1->typeSpecifier) + ", " + instr.operand2);
                    }
                    else if (instr.opNode2)
                    {
                        emitCode("    cmp " + instr.operand2 + ", " + getRegisterBySize(regMap[regZ.reg]->value, instr.opNode2->typeSpecifier));
                    }
                    else
                    {
                        int reg = fetchRegForImmediate(liveVars, regX.reg);
                        emitCode("    mov " + getRegisterBySize(regMap[reg]->value, 3) + ", " + instr.operand1);
                        emitCode("    cmp " + getRegisterBySize(regMap[reg]->value, 3) + ", " + instr.operand2);
                    }
                    // another jump??
                    emitCode("    " + conditionalMapping[instr.op] + " " + target);
                    // emitCode("    jmp " + getGOTOLabel(stoi(instr.result) + 1, basicBlocks));
                }
            }
            else if (instr.op == TACOp::ASSIGN) // handle assign
            {
                if (instr.opNode1)
                {
                    if (regX.reg != regY.reg)
                        emitCode("    mov " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + getRegisterBySize(regMap[regY.reg]->value, instr.opNode1->typeSpecifier));
                }
                else
                {
                    emitCode("    mov " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + instr.operand1);
                }
            }
            else if (instr.op == TACOp::ADD) // handle add
            {
                // both operands are variables
                if (instr.opNode1 && instr.opNode2)
                {
                    emitCode("    mov " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + getRegisterBySize(regMap[regY.reg]->value, instr.opNode1->typeSpecifier));
                    emitCode("    add " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + getRegisterBySize(regMap[regZ.reg]->value, instr.opNode2->typeSpecifier));
                }
                // y is variable, z is immediate
                else if (instr.opNode1)
                {
                    emitCode("    mov " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + getRegisterBySize(regMap[regY.reg]->value, instr.opNode1->typeSpecifier));
                    emitCode("    add " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + instr.operand2);
                }
                // y is immediate, z is variable
                else if (instr.opNode2)
                {
                    emitCode("    mov " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + instr.operand1);
                    emitCode("    add " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + getRegisterBySize(regMap[regZ.reg]->value, instr.opNode2->typeSpecifier));
                }
                // both operands are immediate
                else
                {
                    emitCode("    mov " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + instr.operand1);
                    emitCode("    add " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + instr.operand2);
                }
            }
            else if (instr.op == TACOp::SUB) // handle sub
            {
                if (instr.opNode1 && instr.opNode2)
                {
                    emitCode("    mov " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + getRegisterBySize(regMap[regY.reg]->value, instr.opNode1->typeSpecifier));
                    emitCode("    sub " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + getRegisterBySize(regMap[regZ.reg]->value, instr.opNode2->typeSpecifier));
                }
                else if (instr.opNode1)
                {
                    emitCode("    mov " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + getRegisterBySize(regMap[regY.reg]->value, instr.opNode1->typeSpecifier));
                    emitCode("    sub " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + instr.operand2);
                }
                else if (instr.opNode2)
                {
                    emitCode("    mov " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + instr.operand1);
                    emitCode("    sub " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + getRegisterBySize(regMap[regZ.reg]->value, instr.opNode2->typeSpecifier));
                }
                else
                {
                    emitCode("    mov " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + instr.operand1);
                    emitCode("    sub " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + instr.operand2);
                }
            }
            else if (instr.op == TACOp::MUL) // handle mul
            {
                if (instr.opNode1 && instr.opNode2)
                {
                    emitCode("    mov " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + getRegisterBySize(regMap[regY.reg]->value, instr.opNode1->typeSpecifier));
                    emitCode("    imul " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + getRegisterBySize(regMap[regZ.reg]->value, instr.opNode2->typeSpecifier));
                }
                else if (instr.opNode1)
                {
                    emitCode("    mov " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + getRegisterBySize(regMap[regY.reg]->value, instr.opNode1->typeSpecifier));
                    emitCode("    imul " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + instr.operand2);
                }
                else if (instr.opNode2)
                {
                    emitCode("    mov " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + instr.operand1);
                    emitCode("    imul " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + getRegisterBySize(regMap[regZ.reg]->value, instr.opNode2->typeSpecifier));
                }
                else
                {
                    emitCode("    mov " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + instr.operand1);
                    emitCode("    imul " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + instr.operand2);
                }
            }
            else if (instr.op == TACOp::DIV) // handle div
            {
                // both operands are variables, div stores res in rax
                // and remainder in rdx
                // rax = dividend, rdx = remainder
                if (instr.opNode1 && instr.opNode2)
                {
                    emitCode("    mov " + getRegisterBySize(regMap[2]->value, instr.opNode1->typeSpecifier) + ", " + getRegisterBySize(regMap[regY.reg]->value, instr.opNode1->typeSpecifier));
                    emitCode("    cdq");
                    emitCode("    idiv " + getRegisterBySize(regMap[regZ.reg]->value, instr.opNode2->typeSpecifier));
                    emitCode("    mov " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + getRegisterBySize(regMap[2]->value, instr.resNode->typeSpecifier));
                }
                // y is variable, z is immediate
                else if (instr.opNode1)
                {
                    emitCode("    mov " + getRegisterBySize("rax", instr.opNode1->typeSpecifier) + ", " + getRegisterBySize(regMap[regY.reg]->value, instr.opNode1->typeSpecifier));
                    emitCode("    cdq");
                    int reg = fetchRegForImmediate(liveVars, regX.reg);
                    emitCode("    mov " + getRegisterBySize(regMap[reg]->value, 3) + ", " + instr.operand2);
                    emitCode("    idiv " + getRegisterBySize(regMap[reg]->value, 3));
                    emitCode("    mov " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + getRegisterBySize("rax", instr.resNode->typeSpecifier));
                }
                // y is immediate, z is variable
                else if (instr.opNode2)
                {
                    emitCode("    mov " + getRegisterBySize("rax", instr.resNode->typeSpecifier) + ", " + instr.operand1);
                    emitCode("    cdq");
                    emitCode("    idiv " + getRegisterBySize(regMap[regZ.reg]->value, instr.opNode2->typeSpecifier));
                    emitCode("    mov " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + getRegisterBySize("rax", instr.resNode->typeSpecifier));
                }
                // both operands are immediate
                else
                {
                    emitCode("    mov " + getRegisterBySize("rax", instr.resNode->typeSpecifier) + ", " + instr.operand1);
                    emitCode("    cdq");
                    int reg = fetchRegForImmediate(liveVars, regX.reg);
                    emitCode("    mov " + getRegisterBySize(regMap[reg]->value, 3) + ", " + instr.operand2);
                    emitCode("    idiv " + getRegisterBySize(regMap[reg]->value, 3));
                    emitCode("    mov " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + getRegisterBySize("rax", instr.resNode->typeSpecifier));
                }
            }
            else if (instr.op == TACOp::BIT_AND) // handle bitwise and
            {
                if (instr.opNode1 && instr.opNode2)
                {
                    emitCode("    mov " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + getRegisterBySize(regMap[regY.reg]->value, instr.opNode1->typeSpecifier));
                    emitCode("    and " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + getRegisterBySize(regMap[regZ.reg]->value, instr.opNode2->typeSpecifier));
                }
                else if (instr.opNode1)
                {
                    emitCode("    mov " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + getRegisterBySize(regMap[regY.reg]->value, instr.opNode1->typeSpecifier));
                    emitCode("    and " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + instr.operand2);
                }
                else if (instr.opNode2)
                {
                    emitCode("    mov " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + instr.operand1);
                    emitCode("    and " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + getRegisterBySize(regMap[regZ.reg]->value, instr.opNode2->typeSpecifier));
                }
                else
                {
                    emitCode("    mov " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + instr.operand1);
                    emitCode("    and " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + instr.operand2);
                }
            }
            else if (instr.op == TACOp::BIT_OR) // handle bitwise or
            {
                if (instr.opNode1 && instr.opNode2)
                {
                    emitCode("    mov " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + getRegisterBySize(regMap[regY.reg]->value, instr.opNode1->typeSpecifier));
                    emitCode("    or " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + getRegisterBySize(regMap[regZ.reg]->value, instr.opNode2->typeSpecifier));
                }
                else if (instr.opNode1)
                {
                    emitCode("    mov " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + getRegisterBySize(regMap[regY.reg]->value, instr.opNode1->typeSpecifier));
                    emitCode("    or " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + instr.operand2);
                }
                else if (instr.opNode2)
                {
                    emitCode("    mov " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + instr.operand1);
                    emitCode("    or " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + getRegisterBySize(regMap[regZ.reg]->value, instr.opNode2->typeSpecifier));
                }
                else
                {
                    emitCode("    mov " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + instr.operand1);
                    emitCode("    or " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + instr.operand2);
                }
            }
            else if (instr.op == TACOp::BIT_NOT) // handle bitwise not
            {
                if (instr.opNode1)
                {
                    emitCode("    mov " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + getRegisterBySize(regMap[regY.reg]->value, instr.opNode1->typeSpecifier));
                    emitCode("    not " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier));
                }
                else
                {
                    emitCode("    mov " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + instr.operand1);
                    emitCode("    not " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier));
                }
            }
            else if (instr.op == TACOp::XOR) // handle bitwise xor
            {
                if (instr.opNode1 && instr.opNode2)
                {
                    emitCode("    mov " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + getRegisterBySize(regMap[regY.reg]->value, instr.opNode1->typeSpecifier));
                    emitCode("    xor " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + getRegisterBySize(regMap[regZ.reg]->value, instr.opNode2->typeSpecifier));
                }
                else if (instr.opNode1)
                {
                    emitCode("    mov " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + getRegisterBySize(regMap[regY.reg]->value, instr.opNode1->typeSpecifier));
                    emitCode("    xor " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + instr.operand2);
                }
                else if (instr.opNode2)
                {
                    emitCode("    mov " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + instr.operand1);
                    emitCode("    xor " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + getRegisterBySize(regMap[regZ.reg]->value, instr.opNode2->typeSpecifier));
                }
                else
                {
                    emitCode("    mov " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + instr.operand1);
                    emitCode("    xor " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + instr.operand2);
                }
            }
            else if (instr.op == TACOp::LSHFT) // handle left shift
            {
                if (instr.opNode1 && instr.opNode2)
                {
                    emitCode("    mov " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + getRegisterBySize(regMap[regY.reg]->value, instr.opNode1->typeSpecifier));
                    emitCode("    shl " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + getRegisterBySize(regMap[regZ.reg]->value, instr.opNode2->typeSpecifier));
                }
                else if (instr.opNode1)
                {
                    emitCode("    mov " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + getRegisterBySize(regMap[regY.reg]->value, instr.opNode1->typeSpecifier));
                    emitCode("    shl " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + instr.operand2);
                }
                else if (instr.opNode2)
                {
                    emitCode("    mov " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + instr.operand1);
                    emitCode("    shl " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + getRegisterBySize(regMap[regZ.reg]->value, instr.opNode2->typeSpecifier));
                }
                else
                {
                    emitCode("    mov " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + instr.operand1);
                    emitCode("    shl " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + instr.operand2);
                }
            }
            else if (instr.op == TACOp::RSHFT) // handle right shift
            {
                if (instr.opNode1 && instr.opNode2)
                {
                    emitCode("    mov " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + getRegisterBySize(regMap[regY.reg]->value, instr.opNode1->typeSpecifier));
                    emitCode("    shr " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + getRegisterBySize(regMap[regZ.reg]->value, instr.opNode2->typeSpecifier));
                }
                else if (instr.opNode1)
                {
                    emitCode("    mov " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + getRegisterBySize(regMap[regY.reg]->value, instr.opNode1->typeSpecifier));
                    emitCode("    shr " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + instr.operand2);
                }
                else if (instr.opNode2)
                {
                    emitCode("    mov " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + instr.operand1);
                    emitCode("    shr " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + getRegisterBySize(regMap[regZ.reg]->value, instr.opNode2->typeSpecifier));
                }
                else
                {
                    emitCode("    mov " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + instr.operand1);
                    emitCode("    shr " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + instr.operand2);
                }
            }
            else if (instr.op == TACOp::MOD) // handle mod
            {
                //remainder is stored in rdx
                if (instr.opNode1 && instr.opNode2)
                {
                    emitCode("    mov " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + getRegisterBySize(regMap[regY.reg]->value, instr.opNode1->typeSpecifier));
                    emitCode("    cdq");
                    emitCode("    idiv " + getRegisterBySize(regMap[regZ.reg]->value, instr.opNode2->typeSpecifier));
                    emitCode("    mov " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + getRegisterBySize("rdx", instr.resNode->typeSpecifier));
                }
                else if (instr.opNode1)
                {
                    emitCode("    mov " + getRegisterBySize("rax", instr.opNode1->typeSpecifier) + ", " + getRegisterBySize(regMap[regY.reg]->value, instr.opNode1->typeSpecifier));
                    emitCode("    cdq");
                    int reg = fetchRegForImmediate(liveVars, regX.reg);
                    emitCode("    mov " + getRegisterBySize(regMap[reg]->value, 3) + ", " + instr.operand2);
                    emitCode("    idiv " + getRegisterBySize(regMap[reg]->value, 3));
                    emitCode("    mov " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + getRegisterBySize("rdx", instr.resNode->typeSpecifier));
                }
                else if (instr.opNode2)
                {
                    emitCode("    mov " + getRegisterBySize("rax", instr.resNode->typeSpecifier) + ", " + instr.operand1);
                    emitCode("    cdq");
                    emitCode("    idiv " + getRegisterBySize(regMap[regZ.reg]->value, instr.opNode2->typeSpecifier));
                    emitCode("    mov " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + getRegisterBySize("rdx", instr.resNode->typeSpecifier));
                }
                else
                {
                    emitCode("    mov " + getRegisterBySize("rax", instr.resNode->typeSpecifier) + ", " + instr.operand1);
                    emitCode("    cdq");
                    int reg = fetchRegForImmediate(liveVars, regX.reg);
                    emitCode("    mov " + getRegisterBySize(regMap[reg]->value, 3) + ", " + instr.operand2);
                    emitCode("    idiv " + getRegisterBySize(regMap[reg]->value, 3));
                    emitCode("    mov " + getRegisterBySize(regMap[regX.reg]->value, instr.resNode->typeSpecifier) + ", " + getRegisterBySize("rdx", instr.resNode->typeSpecifier));
                }
            }
        }
        else
        {
            if (instr.isGoto) // if jump or goto
            {
                string target = getGOTOLabel(stoi(instr.result), basicBlocks);
                emitCode("    jmp " + target);
            }
            else if (instr.op == TACOp::STARTFUNC) // start function 
            {
                emitCode(instr.result + ":");
                emitFuncEntry(instr.resNode->totalOffset);
            }
            else if (instr.op == TACOp::ENDFUNC) // end func
            {
                spillAllRegisters();
                emitFuncExit();
            }
            else if (instr.op == TACOp::RETURN) // return value in a func
            {
                if (instr.result != "") // if return exists
                    if (!instr.resNode) // if immediate value
                        emitCode("    mov " + regMap[2]->value + ", " + instr.result);
                    else // if variable
                    {
                        int reg = checkAddressDescriptor(instr.resNode);
                        if (reg == -1)
                        {
                            reg = fetchRegForImmediate(liveVars, -1);
                            registerDescriptor[reg].insert(instr.resNode);
                            addressDescriptor[instr.resNode].insert(regMap[reg]);
                            emitCode("    mov " + getRegisterBySize(regMap[reg]->value, instr.resNode->typeSpecifier) + ", " + getWordPTR(instr.resNode->typeSpecifier) + " " + baseAdressing(instr.resNode));
                        }
                        emitCode("    mov " + getRegisterBySize(regMap[2]->value, instr.resNode->typeSpecifier) + ", " + getRegisterBySize(regMap[reg]->value, instr.resNode->typeSpecifier));
                    }
                emitFuncExit();
                spillAllRegisters(); // save all registers before returning
            }
            else if (instr.op == TACOp::CALL2 || instr.op == TACOp::CALL)
            {
                spillAllRegisters(); // safe all registers before calling
                emitCode("    call " + instr.operand1);
                emitCode("    add rsp, " + to_string(8 * instr.opNode1->paramCount));
                if (instr.resNode)
                {
                    int reg = fetchRegForImmediate(liveVars, -1);
                    registerDescriptor[reg].insert(instr.resNode);
                    addressDescriptor[instr.resNode].insert(regMap[reg]);
                    emitCode("    mov " + getRegisterBySize(regMap[reg]->value, instr.resNode->typeSpecifier) + ", " + getRegisterBySize("rax", instr.resNode->typeSpecifier));
                }
            }
            else if (instr.op == TACOp::PARAM)
            {
                if (!instr.resNode) // push immediate value to stack
                {
                    int reg = fetchRegForImmediate(liveVars, -1);
                    emitCode("    mov " + getRegisterBySize(regMap[reg]->value, 4) + ", " + instr.result);
                    emitCode("    push " + getRegisterBySize(regMap[reg]->value, 4));
                }
                else // push variable to stack
                {
                    int reg = checkAddressDescriptor(instr.resNode);
                    if (reg == -1)
                    {
                        reg = fetchRegForImmediate(liveVars, -1);
                        registerDescriptor[reg].insert(instr.resNode);
                        addressDescriptor[instr.resNode].insert(regMap[reg]);
                        emitCode("    mov " + getRegisterBySize(regMap[reg]->value, instr.resNode->typeSpecifier) + ", " + getWordPTR(instr.resNode->typeSpecifier) + " " + baseAdressing(instr.resNode));
                    }
                    emitCode("    push " + getRegisterBySize(regMap[reg]->value, 4));
                }
            }
        }
    }
}

void addDataSection(const vector<TACInstruction> &globalVars)
{
    asmOutput.push_back("    .data");
    for (auto instr : globalVars)
    {
        TreeNode *curr_node = lookupSymbol(instr.result, true, false);
        if (curr_node->typeCategory == 0)
        {
            if (curr_node->typeSpecifier == 1)
            {
                asmOutput.push_back(instr.result + ":");
                asmOutput.push_back("    .byte  " + instr.operand1);
            }
            else if (curr_node->typeSpecifier == 2)
            {
                asmOutput.push_back(instr.result + ":");
                asmOutput.push_back("    .word  " + (instr.operand1));
            }
            else if (curr_node->typeSpecifier == 3)
            {
                asmOutput.push_back(instr.result + ":");
                asmOutput.push_back("    .long  " + (instr.operand1));
            }
            else if (curr_node->typeSpecifier == 4)
            {
                asmOutput.push_back(".globl " + instr.result);
                asmOutput.push_back(instr.result + ":");
                asmOutput.push_back("    .long " + (instr.operand1));
            }
            else if (curr_node->typeSpecifier == 6)
            {
                // handle float
            }
            else if (curr_node->typeSpecifier == 7)
            {
                asmOutput.push_back(instr.result + ":");
                asmOutput.push_back("    .quad  " + instr.operand1);
            }
        }
        else

            if (curr_node->typeCategory == 1)
        {
            // handle array
        }
    }
}
void markLeaders(const vector<TACInstruction> &tacCode, vector<bool> &leaderList)
{
    if (tacCode.empty())
        return;
    leaderList.assign(tacCode.size(), false);
    leaderList[0] = true;// the first instruction is always a leader
    for (int i = 0; i < tacCode.size(); i++)
    {
        TACOp op = tacCode[i].op;
        if (op == TACOp::GOTO || op == TACOp::oth || op == TACOp::IF_EQ || op == TACOp::IF_NE)
        {
            try
            {
                int lineNo = stoi(tacCode[i].result);
                if (lineNo < tacCode.size())
                {
                    leaderList[lineNo] = true;// mark the target of the GOTO as a leader
                }
            }
            catch (const invalid_argument &ia)
            {
                cerr << "Warning: Cannot determine leader from non-integer GOTO target '" << tacCode[i].result << "'" << endl;
            }
            if (i + 1 < tacCode.size())
            {
                leaderList[i + 1] = true;// mark the next instruction as a leader
            }
        }
    }
}

vector<pair<int, int>> createBasicBlocks(const vector<TACInstruction> &tacCode)
{
    vector<bool> leaderList;
    markLeaders(tacCode, leaderList);
    vector<pair<int, int>> basicBlocks;
    if (tacCode.empty())
        return basicBlocks;

    int start = -1;
    for (int i = 0; i < tacCode.size(); i++)
    {
        if (leaderList[i])
        {
            if (start != -1)
            {
                basicBlocks.push_back({start, i - 1});
            }
            start = i;
        }
    }
    if (start != -1)
    {
        basicBlocks.push_back({start, tacCode.size() - 1});
    }

    return basicBlocks;
}

vector<unordered_set<string>> livenessInfo(const vector<TACInstruction> &tacCode, const vector<pair<int, int>> &basicBlocks)
{
    unordered_set<string> liveVars;
    int n = tacCode.size();
    vector<unordered_set<string>> liveInfo(n);
    for (int i = basicBlocks.size() - 1; i >= 0; i--)
    {
        liveVars.clear();

        int start = basicBlocks[i].first;
        int end = basicBlocks[i].second;

        // Process the basic block in reverse order
        for (int j = end; j >= start; j--)
        {
            liveInfo[j] = liveVars;
            // Update liveVars based on the current instruction
            TACInstruction inst = tacCode[j];
            string arg1 = inst.operand1;
            string arg2 = inst.operand2;
            string result = inst.result;

            if (inst.op == TACOp::GOTO || inst.op == TACOp::oth || inst.op == TACOp::LABEL || inst.op == TACOp::CALL || inst.op == TACOp::PRINT || inst.op == TACOp::SCAN || inst.op == TACOp::CALL2)
                continue;

            liveVars.erase(result);

            if (inst.opNode1 != nullptr && arg1[0] == '#')
                liveVars.insert(arg1);

            if (inst.opNode2 != nullptr && arg2[0] == '#')
                liveVars.insert(arg2);
        }
    }

    return liveInfo;
}

extern pair<vector<TACInstruction>, vector<TACInstruction>> parser(int argc, char **argv);

int main(int argc, char **argv)
{
    auto helper = parser(argc, argv);
    vector<TACInstruction> tacCode = helper.second;
    vector<TACInstruction> global_vars = helper.first;
    vector<pair<int, int>> basicBlocks = createBasicBlocks(tacCode);
    addDataSection(global_vars);
    // for(int i = 0; i < basicBlocks.size(); ++i)
    // {
    //     cout << "Basic Block " << i << ": " << basicBlocks[i].first << " to " << basicBlocks[i].second << endl;
    // }
    vector<unordered_set<string>> liveness = livenessInfo(tacCode, basicBlocks);

    addressDescriptor.clear();
    for (int i = 0; i < registerDescriptor.size(); ++i)
        registerDescriptor[i].clear();

    emitStart();

    for (int i = 0; i < basicBlocks.size(); ++i)
    {
        generateCodeForBasicBlock(tacCode, liveness, basicBlocks, i);
    }

    // emitNormalSysExit();
    string inputPath(argv[1]);
    string base = inputPath.substr(inputPath.find_last_of("/\\") + 1);
    string baseName = base.substr(0, base.find_last_of('.'));
    string outName = "output/asm/" + baseName + ".s";
    ofstream asmOut(outName);
    if (!asmOut)
    {
        cerr << "Error: Could not open output file " << outName << endl;
        return 1;
    }
    for (const auto &line : asmOutput)
    {
        asmOut << line << endl;
    }
    return 0;
}
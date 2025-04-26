#include <bits/stdc++.h>
#include "../inc/tac.h"
#include "../inc/treeNode.h"
using namespace std;

TreeNode *lookupSymbol(string symbol, bool arg = false);

using namespace std;

vector<unordered_set<string>> registerDescriptor(16);
unordered_map<string, unordered_set<string>> addressDescriptor;

int checkAddressDescriptor(const string &arg)
{
    for (int i = 0; i < registerDescriptor.size(); i++)
    {
        if (registerDescriptor[i].count(arg))
            return i;
    }
    return -1;
}

int findEmptyRegister()
{
    for (int i = 0; i < registerDescriptor.size(); i++)
    {
        if (registerDescriptor[i].empty())
            return i;
    }
    return -1;
}

int evictAndAssignRegister(const string &argToLoad, const string &res, const unordered_set<string> &liveVars, int regY = -1, int regZ = -1)
{
    for (int i = 0; i < registerDescriptor.size(); ++i)
    {
        if (i == regY || i == regZ)
            continue;
        bool allDead = true;
        for (const string &var : registerDescriptor[i])
        {
            if (!(var.rfind("#t", 0) == 0 && liveVars.find(var) == liveVars.end()))
            {
                allDead = false;
                break;
            }
        }
        if (allDead)
        {
            cout << "\t# Evicting dead temps from R" << i << " for " << argToLoad << endl;
            for (const string &var : registerDescriptor[i])
            {
                if (addressDescriptor.count(var))
                {
                    // clear register from address descriptor
                }
            }
            registerDescriptor[i].clear();
            return i;
        }
    }

    for (int i = 0; i < registerDescriptor.size(); ++i)
    {
        if (i == regY || i == regZ)
            continue;
        bool safe = true;
        for (const string &var : registerDescriptor[i])
        {
            bool inMemOrReg = false;
            if (addressDescriptor.count(var))
            {
                for (const string &loc : addressDescriptor[var])
                {
                    // remove if present in another reg or memory loc
                    if (true)
                    {
                        inMemOrReg = true;
                        break;
                    }
                }
            }
            if (!inMemOrReg)
            {
                safe = false;
                break;
            }
        }
        if (safe)
        {
            cout << "\t# Evicting R" << i << " (vars safe elsewhere) for " << argToLoad << endl;
            for (const string &var : registerDescriptor[i])
            {
                if (addressDescriptor.count(var))
                {
                    // remove from address descriptor
                }
            }
            registerDescriptor[i].clear();
            return i;
        }
    }

    int regToSpill = -1;
    for (int i = 0; i < registerDescriptor.size(); i++)
    {
        if (i != regY && i != regZ)
        {
            regToSpill = i;
            break;
        }
    }

    cout << "\t# Spilling R" << regToSpill << " for " << argToLoad << endl;

    for (const string &var : registerDescriptor[regToSpill])
    {
        bool toSpill = true;
        if (var.rfind("#t", 0) == 0 && liveVars.find(var) == liveVars.end())
        {
            toSpill = false;
        }

        if (toSpill)
        {
            bool hasMemLOC = false;
            if (addressDescriptor.count(var))
            {
                for (const string &loc : addressDescriptor[var])
                {
                    // if addr descriptor has memory loc remove register i;
                    // break;
                }
            }

            if (!hasMemLOC)
            {
                // fetch and store in memory location
            }
            else
            {
                cout << "\t# " << var << " in R" << regToSpill << " already has memory location, no ST needed for spill." << endl;
            }
        }
        if (addressDescriptor.count(var))
        {
            // remove from address descriptor
        }
    }
    registerDescriptor[regToSpill].clear();

    return regToSpill;
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
        instr.op == TACOp::RETURN)
        return {};

    RegInfo regX, regY, regZ;

    // check for immediate values, empty values and all temp and user defined symbols are stored in symbol table;
    if (!lookupSymbol(arg1, true))
    {
        regY.reg = checkAddressDescriptor(arg1);
        if (regY.reg == -1)
        {
            regY.loadReq = true;
            regY.reg = findEmptyRegister();
            if (regY.reg == -1)
            {
                regY.reg = evictAndAssignRegister(arg1, result, liveVars);
            }
        }
    }

    if (!lookupSymbol(arg2, true))
    {
        regZ.reg = checkAddressDescriptor(arg2);
        if (regZ.reg == -1)
        {
            regZ.loadReq = true;
            regZ.reg = findEmptyRegister();
            if (regZ.reg == -1)
            {
                regZ.reg = evictAndAssignRegister(arg2, result, liveVars, regY.reg);
            }
        }
    }

    regX.reg = checkAddressDescriptor(result);
    if (regX.reg == -1)
    {
        if (arg1.rfind("#t", 0) == 0 && liveVars.find(arg1) == liveVars.end() && regY.reg != -1)
        {
            cout << "\t# Reusing R" << regY.reg << " (dead temp " << arg1 << ") for result " << result << endl;
            regX.reg = regY.reg;
            registerDescriptor[regX.reg].erase(arg1);
            if (addressDescriptor.count(arg1))
            {
                // erase register from address descriptor of arg1
            }
        }
        else if (arg2.rfind("#t", 0) == 0 && liveVars.find(arg2) == liveVars.end() && regZ.reg != -1 && regZ.reg != regY.reg)
        {
            cout << "\t# Reusing R" << regZ.reg << " (dead temp " << arg2 << ") for result " << result << endl;
            regX.reg = regZ.reg;
            registerDescriptor[regX.reg].erase(arg2);
            if (addressDescriptor.count(arg2))
            {
                // erase register from address descriptor of arg1
            }
        }
    }
    return {regX, regY, regZ};
}

void generateCodeForBasicBlock(const vector<TACInstruction> &tacCode, const vector<unordered_set<string>> &liveness, int start, int end)
{
    for (int i = start; i <= end; ++i)
    {
        const TACInstruction &instr = tacCode[i];
        // cout << "\n# TAC: " << i + 1 << ": " << instr.toString() << endl;
        unordered_set<string> liveVars = liveness[i];
        vector<RegInfo> regs = getRegister(instr, liveVars);

        if (!regs.empty())
        {
            RegInfo regX = regs[0];
            RegInfo regY = regs[1];
            RegInfo regZ = regs[2];

            string arg1 = instr.operand1;
            string arg2 = instr.operand2;
            string result = instr.result;
        }
        else
        {
        }
    }
}

void markLeaders(const vector<TACInstruction> &tacCode, vector<bool> &leaderList)
{
    if (tacCode.empty())
        return;
    leaderList.assign(tacCode.size(), false);
    leaderList[0] = true;
    for (int i = 0; i < tacCode.size(); i++)
    {
        TACOp op = tacCode[i].op;
        if (op == TACOp::GOTO || op == TACOp::oth || op == TACOp::IF_EQ || op == TACOp::IF_NE)
        {
            try
            {
                int lineNo = stoi(tacCode[i].result);
                if (lineNo > 0 && lineNo <= tacCode.size())
                {
                    leaderList[lineNo - 1] = true;
                }
            }
            catch (const std::invalid_argument &ia)
            {
                cerr << "Warning: Cannot determine leader from non-integer GOTO target '" << tacCode[i].result << "'" << endl;
            }
            if (i + 1 < tacCode.size())
            {
                leaderList[i + 1] = true;
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
    string tempLabel = "#t";
    for (int i = basicBlocks.size() - 1; i >= 0; i--)
    {
        liveVars.clear();

        int start = basicBlocks[i].first;
        int end = basicBlocks[i].second;

        for (int j = end; j >= start; j--)
        {
            liveInfo[j] = liveVars;

            TACInstruction inst = tacCode[j];
            string arg1 = inst.operand1;
            string arg2 = inst.operand2;
            string result = inst.result;

            if (inst.op == TACOp::GOTO || inst.op == TACOp::oth || inst.op == TACOp::LABEL || inst.op == TACOp::CALL || inst.op == TACOp::PRINT || inst.op == TACOp::SCAN || inst.op == TACOp::CALL2)
                continue;

            liveVars.erase(result);

            if (arg1.substr(0, 2) == tempLabel && !lookupSymbol(arg1, true))
                liveVars.insert(arg1);

            if (arg2.substr(0, 2) == tempLabel && !lookupSymbol(arg2, true))
                liveVars.insert(arg2);
        }
    }

    return liveInfo;
}

extern vector<TACInstruction> parser(int argc, char **argv);

int main(int argc, char **argv)
{

    vector<TACInstruction> tacCode = parser(argc, argv);

    vector<pair<int, int>> basicBlocks = createBasicBlocks(tacCode);
    // cout << "--- Basic Blocks ---" << endl;
    // for (const auto &block : basicBlocks)
    // {
    //     cout << "Block: " << block.first + 1 << " - " << block.second + 1 << endl;
    // }
    // cout << "--------------------" << endl
    //      << endl;

    vector<unordered_set<string>> liveness = livenessInfo(tacCode, basicBlocks);

    addressDescriptor.clear();
    for (int i = 0; i < registerDescriptor.size(); ++i)
        registerDescriptor[i].clear();

    for (const auto &block : basicBlocks)
    {
        generateCodeForBasicBlock(tacCode, liveness, block.first, block.second);
    }

    return 0;
}
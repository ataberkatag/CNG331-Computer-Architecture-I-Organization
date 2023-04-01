// MIPS_Assembler.cpp : 
// MIPS_Assembler


#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <string.h>
#include <stdlib.h>
#include <bitset>
#include <iomanip>

#define DATA_MEMORY_START 0x10010000
#define INSTRUCTION_MEMORY_START 0x400000
using namespace std;


struct label {
    char name[100];
    int32_t address; //32-bit adress is defined.
};
struct instructions{
    string name;
    char type;
    unsigned char opcode;
    unsigned char funct;
};

// Define all instruction here
instructions inst[] = {
    {"add ",'R',0,32 }, {"addi ",'I',8,NULL},{"addiu ",'I',9,NULL},{"addu ",'R',0,33},{"and ",'R',0,36},
    {"andi ",'I',12,NULL}, {"beq ",'I',4,NULL}, {"bne ",'I',5,NULL},{"jalr ",'R',0,9},{"jr ",'R',0,8},{"j ",'J',2,NULL},
    {"jal ",'J',3,NULL},{"lb ",'I',32,NULL},{"lbu ",'I',36,NULL},{"lui ",'I',15,NULL},{"lw ",'I',35,NULL},{"mul ",'R',28,2},{"nor ",'R',0,39},
    {"or ",'R',0,37},{"ori ",'I',13,NULL},{"slt ",'R',0,42},{"sltu ",'R',0,43},{"slti ",'I',10,NULL},{"sltiu ",'I',11,NULL},{"sll ",'R',0,0},
    {"sllv ",'R',0,4},{"sra ",'R',0,3},{"srl ",'R',0,2},{"srlv ",'R',0,6},{"sb ",'I',40,NULL},{"sw ",'I',43,NULL},{"sub ",'R',0,34},{"subu ",'R',0,35},
    {"xor ",'R',0,38},{"xori ",'I',14,NULL},{"move ",'R',0,33},{"sgt ",'R',0,42}
};
unsigned char inst_count = 38; // Please update if you enter new instruction

// Define all instruction here for interactive mode
instructions inter_inst_list[] = {
    {"add ",'R',0,32 }, {"addi ",'I',8,NULL},{"addiu ",'I',9,NULL},{"addu ",'R',0,33},{"and ",'R',0,36},
    {"andi ",'I',12,NULL},{"jalr ",'R',0,9},{"jr ",'R',0,8},
    {"lb ",'I',32,NULL},{"lbu ",'I',36,NULL},{"lui ",'I',15,NULL},{"lw ",'I',35,NULL},{"mul ",'R',28,2},{"nor ",'R',0,39},
    {"or ",'R',0,37},{"ori ",'I',13,NULL},{"slt ",'R',0,42},{"sltu ",'R',0,43},{"slti ",'I',10,NULL},{"sltiu ",'I',11,NULL},{"sll ",'R',0,0},
    {"sllv ",'R',0,4},{"sra ",'R',0,3},{"srl ",'R',0,2},{"srlv ",'R',0,6},{"sb ",'I',40,NULL},{"sw ",'I',43,NULL},{"sub ",'R',0,34},{"subu ",'R',0,35},
    {"xor ",'R',0,38},{"xori ",'I',14,NULL},{"move ",'R',0,33},{"sgt ",'R',0,42}
};
unsigned char inter_inst_count = 33; // Please update if you enter new instruction



const char* registers[] = {
    "$zero",
    "$at",
    "$v0",
    "$v1",
    "$a0",
    "$a1",
    "$a2",
    "$a3",
    "$t0",
    "$t1",
    "$t2",
    "$t3",
    "$t4",
    "$t5",
    "$t6",
    "$t7",
    "$s0",
    "$s1",
    "$s2",
    "$s3",
    "$s4",
    "$s5",
    "$s6",
    "$s7",
    "$t8",
    "$t9",
    "$k0",
    "$k1",
    "$gp",
    "$sp",
    "$fp",
    "$ra"
};


// Global variables
label label_list[100];
int labelindex = 0;

int32_t instruction_memory_address[500];
int instr_index = 0;


int32_t datasection[1000];
int datasectionindex = 0;


///File writing file position
streampos cursor;

//Functions
void scanLabels_data(fstream& inFile); //does not close file
void scanLabels_text(fstream& inFile); //does not close file
void remove_comments(); // automaticlly generate from pre-defined file
void insert_macros(fstream& inFile); // closes the file
void define_datasection(fstream& inFile); //does not close file
string remove_whitespace(string str);
string chartobinary(string info); 
void assembleLine(fstream& inFile, fstream& inFile3);  //does not close file
void insert_labeladresses(fstream& inFile); // closes the file

void converterR(string opcode, string rs, string rt, string rd, string shampt, string function, fstream& inFile3); // Generate Binary for R type instruction
void converterI(string opcode, string rs, string rt, string constant, fstream& inFile3); // Generate Binary for I type instruction
void converterJ(string opcode, string address, fstream& inFile3, string pc_address); // Generate Binary for J type instruction

void gethexfrombin(fstream& inFile); // Generate object.o in Hex from binary file


string i_converterI(string opcode, string rs, string rt, string constant);
void i_gethexfrombin(string bin);



int main()
{

    remove_comments();
    fstream inFile;
    fstream inFile3;
    inFile.open("C:\\Users\\90531\\Desktop\\pureassembly.txt", ios::in);
    scanLabels_data(inFile);
    insert_macros(inFile);
    inFile.open("C:\\Users\\90531\\Desktop\\pureassembly.txt", ios::in);
    scanLabels_text(inFile);
    define_datasection(inFile);
    insert_labeladresses(inFile);
    inFile.open("C:\\Users\\90531\\Desktop\\pureassembly.txt", ios::in);
    inFile3.open("C:\\Users\\90531\\Desktop\\pureassembly3.txt", ios::out);
    assembleLine(inFile, inFile3);
    inFile.close();
    inFile.open("C:\\Users\\90531\\Desktop\\pureassembly3.txt", ios::in);
    gethexfrombin(inFile);

    cout << "### Assemble: mips_object.o is generated successfully." << endl;
    

    /// 
    /// Interactive mode
    /// 
    /// 
    string inter_inst;
    string i_rd;
    string i_rs;
    string i_rt;
    string imm;
    string i_shamt;
    string i_op;
    string i_func;
    size_t dollar_pos = 0;
    size_t comma_pos = 0;
    int count_reg=0;
    cout << "\t--- Interactive mode is active ---" << endl;

    while(1)
  {
    cout << "Enter instruction:";
    getline(cin,inter_inst);
    //
    // addi $s1, $s1, -17
    // addi $t1,$t2, 25
    // ori  $s1,$s2, 10
    //
    for (int i = 0; i < inter_inst_count + 1; i++)
    {
        if (inter_inst.find(inter_inst_list[i].name) != string::npos)
        {
            i_op = to_string(inter_inst_list[i].opcode);
            i_func = to_string(inter_inst_list[i].funct);
            if (inter_inst_list[i].type == 'I')
            {
                inter_inst = remove_whitespace(inter_inst);
                dollar_pos = inter_inst.find_first_of("$");
                comma_pos = inter_inst.find_first_of(",");
                i_rt = inter_inst.substr(dollar_pos, comma_pos - dollar_pos);
                dollar_pos = inter_inst.find_first_of("$", dollar_pos + 1);
                comma_pos = inter_inst.find_first_of(",", comma_pos + 1);
                //cout << line << endl;
                i_rs = inter_inst.substr(dollar_pos, comma_pos - dollar_pos);
                imm = inter_inst.substr(comma_pos + 1, inter_inst.length() - (comma_pos + 1));
                cout << "0x";
                i_gethexfrombin(i_converterI(i_op, i_rs, i_rt, imm));
                break;
            }   
        }
        if (i == inter_inst_count)
        {
            cout << "The interactive mode does not support assembler directives or instruction labels !" << endl;
            break;
        }
    } 
  }
}

string remove_whitespace(string temp) {

    temp.erase(std::remove(temp.begin(), temp.end(), ' '), temp.end());
    return temp;
}

string chartobinary(string info) { // Take decimal string, print binary string
    int bin = 0;
    stringstream convert(info);
    convert >> bin;
    std::string binary = std::bitset<32>(bin).to_string(); //to binary
    return binary;
}

void remove_comments(){

    ifstream inFile;
    ofstream outFile;
    inFile.open("C:\\Users\\90531\\Desktop\\assemblycodes.s");
    outFile.open("C:\\Users\\90531\\Desktop\\pureassembly.txt");

    string line, word, ExtractedLine;
    istringstream iss;

if (!inFile) {
    cerr << "Unable to open file assemblycodes.txt";
    exit(1);   // call system to stop
}
if (!outFile) {
    cerr << "Unable to open file pureassembly.txt";
    exit(1);   // call system to stop
}


while (getline(inFile, line)) {
    iss.clear();
    iss.str(line);
    getline(iss, ExtractedLine, '#');
    iss.ignore(INT_MAX, '\n');
    if (!ExtractedLine.empty()) {
        outFile << ExtractedLine << endl;
    }
}
inFile.close();
outFile.close();
}

void scanLabels_data(fstream &inFile) 
{
    string line;
    if (inFile.is_open())
 {
    int datasizecnt = 0;
    int instruction_count = 0;

    ////////////////// Find labels inside data section
        while(getline(inFile,line))
        {
            if (strstr(line.c_str(),".data") != NULL) //Find .data section
            {
                break;
            }
        }
        while (getline(inFile, line)) 
        {
            // Labels inside .data section.
            if (strstr(line.c_str(),":") != NULL)
            {
                label newLabel;
                char temp[100];
                strcpy(temp, line.c_str());
                strcpy(newLabel.name , strtok(temp,":"));
                newLabel.address = DATA_MEMORY_START + (datasizecnt)*4;
                datasizecnt++;
                label_list[labelindex++]=newLabel;
            }
        }
        inFile.clear();   // Restart reading line by line
        inFile.seekg(0); 
        //////////////////
    }
}

void insert_macros(fstream &inFile) {
    fstream inFile2;
    inFile2.open("C:\\Users\\90531\\Desktop\\pureassembly2.txt", ios::out);

    string line;
    if (inFile.is_open()) {
        while (getline(inFile, line)) {
            if (line.find("la") != string::npos)
            {
                for (int i = 0; i < labelindex; i++) {
                    if (line.find(label_list[i].name) != string::npos) {
                        size_t pos = line.find("la");
                        if (pos != string::npos) {
                            line.replace(line.begin() + pos, line.begin() + pos + sizeof("la"), "lui ");
                            size_t pos3 = line.find(label_list[i].name);

                            inFile2 << line << endl;
                        }
                        pos = line.find("lui");
                        if (pos != string::npos) {
                            line.replace(line.begin() + pos, line.begin() + pos + sizeof("lui"), "ori ");
                            pos = line.find("$");
                            size_t pos2 = line.find(",");
                            char hold_reg[20];
                            size_t length = line.copy(hold_reg, pos2 - pos, pos);
                            hold_reg[length] = '\0';
                            line.insert(pos2 + 1 ," ");
                            line.insert(pos2 + 2 , hold_reg);
                            line.insert(pos2 + 2 + length, ",");
                            inFile2 << line << endl;
                        }

                    }

                }
            }
            else inFile2 << line << endl;

        }
    }
    inFile.close();
    inFile2.close();
    remove("C:\\Users\\90531\\Desktop\\pureassembly.txt");
    rename("C:\\Users\\90531\\Desktop\\pureassembly2.txt","C:\\Users\\90531\\Desktop\\pureassembly.txt");
}

void scanLabels_text(fstream& inFile) {
    string line;
    int instruction_count = 0;
    if (inFile.is_open())
    {
        ////////////////// Find labels inside text section
        while (getline(inFile, line))
        {
            if (strstr(line.c_str(), ".text") != NULL) //Find .text section
            {
                break;
            }
        }
        while (getline(inFile, line))
        {
            if (strstr(line.c_str(), ".data") != NULL) //If the scanner reach the .data section, break !
            {
                break;
            }
            // Labels inside .text section.
            if (strstr(line.c_str(), ":") != NULL)
            {
                label newLabel;
                char temp[100];
                strcpy(temp, line.c_str());
                strcpy(newLabel.name, strtok(temp, ":"));
                newLabel.address = INSTRUCTION_MEMORY_START + (instruction_count* 4);
                label_list[labelindex++] = newLabel;
            }
            else 
            {
                  instruction_count++;
            }

        }
        inFile.clear();   // Restart reading line by line
        inFile.seekg(0);
        ////////////////// 
    }
      
}

void define_datasection(fstream& inFile) {
    int count = 0;
    if (inFile.is_open())
    {
        string line;
        while (getline(inFile, line)) // find .data section
        {
            if (strstr(line.c_str(), ".data") != NULL) {
                break;
            }
        }
        while (getline(inFile, line)) {
            if (strstr(line.c_str(), ".text") != NULL) // Scan until .text directive
            { 
                break;
            }
            if (strstr(line.c_str(), ".word") != NULL) 
            { // find .word directives
                //datasection[datasectionindex++] = immToInt(three);
                line = remove_whitespace(line); 
                // find and remove .word from line for now
                size_t pos = line.find(".word"); 
                if (pos != string::npos) {
                    string word = ".word";
                    line.erase(pos,sizeof("word"));
                    std::string::size_type sz;
                    int decimal = std::stoi (line,&sz);
                    datasection[datasectionindex] = decimal;
                    datasectionindex++;
                }
                    
               
                    
                
             

            }
        }
        inFile.clear();   // Restart reading line by line
        inFile.seekg(0);
    }
    else cout << "Unable to open file\n";
}

void insert_labeladresses(fstream& inFile) {
    string line;
    fstream inFile2;
    inFile2.open("C:\\Users\\90531\\Desktop\\pureassembly2.txt", ios::out);
    if (inFile.is_open())
    {
        ////////////////// Find labels inside text section
        while (getline(inFile, line))
        {
            if (strstr(line.c_str(), ".text") != NULL) //Find .text section
            {
                break;
            }
        }
        while (getline(inFile, line))
        {
            //line = remove_whitespace(line);
            
            if (strstr(line.c_str(), ".data") != NULL) //If the scanner reach the .data section, break !
            {
                break;
            }
            for(int i=labelindex-1;i>=0;i--)
            {
               
                if (line.find(label_list[i].name) != string::npos)
                {
                    size_t pos = line.find(':');
                    if (pos != string::npos)
                    {
                        line.clear();
                    }
                    else
                    {
                        
                        pos = line.find(label_list[i].name);
                        string temp = to_string(label_list[i].address);
                        line.replace(pos,temp.length()+5, temp);


                    }
                    
                }
                
            }
            
     
        if (!line.empty()) {
                inFile2 << line << endl;
          }
            
        }

    }
    inFile.close();
    inFile2.close();
    remove("C:\\Users\\90531\\Desktop\\pureassembly.txt");
    rename("C:\\Users\\90531\\Desktop\\pureassembly2.txt","C:\\Users\\90531\\Desktop\\pureassembly.txt");
}

void assembleLine(fstream& inFile, fstream& inFile3) {
        string line;
        size_t dollar_pos = 0;
        size_t comma_pos = 0;
        size_t bracket_pos1 = 0;
        size_t bracket_pos2 = 0;

    if (inFile.is_open())
    {
        while (getline(inFile, line))
        {
            //cout << instr_index << endl;
            instruction_memory_address[instr_index] = INSTRUCTION_MEMORY_START + instr_index*4;
           // cout << instruction_memory_address[instr_index] << endl;
            for (int i = 0; i < inst_count; i++) 
            {

                if (line.find(inst[i].name) != string::npos) { // Find the instruction word  strstr(line.c_str(), inst[i].name.c_str())
                    string rd="0";
                    string rt= "0";
                    string rs = "0";
                    string immediate = "0";
                    string shamt = "0";
                    string label_address = "0";
                    string funct = "0";
                    string opcode = "0";
                    opcode = to_string(inst[i].opcode);
                    funct = to_string(inst[i].funct);
                    if (inst[i].type == 'R')
                    {
                        

                        if ( (inst[i].name == "sll ") || (inst[i].name == "sra ") || (inst[i].name == "srl "))
                        {
                            //shift operation needs shamt, rs=0. inputs: rd,rt,shamt.
                            dollar_pos = line.find_first_of("$");
                            comma_pos = line.find_first_of(",");
                            rd = line.substr(dollar_pos, comma_pos - dollar_pos);
                            dollar_pos = line.find_first_of("$", dollar_pos + 1);
                            comma_pos = line.find_first_of(",", comma_pos + 1);
                            rt = line.substr(dollar_pos, comma_pos - dollar_pos);
                            shamt = line.substr(comma_pos+2,line.length()-(comma_pos+3));
                            //cout << rd << rt << shamt << endl;
                            //cout << shamt <<"test"<<endl;
                            // Outputs of instruction = rd,rs,shamt
                            converterR(opcode, rs, rt, rd, shamt, funct, inFile3);

                            continue;
                        }
 
                        else if((inst[i].name == "move "))
                        {
                            dollar_pos = line.find_first_of("$");
                            comma_pos = line.find_first_of(",");
                            rd = line.substr(dollar_pos, comma_pos - dollar_pos);
                            rs = "$zero";
                            dollar_pos = line.find_first_of("$", dollar_pos + 1);
                            rt = line.substr(dollar_pos, line.length() - dollar_pos);
                           // cout << rt <<"test"<<endl;
                            converterR(opcode, rs, rt, rd, shamt, funct, inFile3);

                            continue;
                        }
                        else if ((inst[i].name == "jr "))
                        { // rs
                            dollar_pos = line.find_first_of("$");
                            rs = line.substr(dollar_pos, line.length() - dollar_pos);
                            //cout << rd << "test";
                            converterR(opcode, rs, rt, rd, shamt, funct,inFile3);
                            continue;
                        }
                        else if ((inst[i].name == "sgt ")) 
                        {
                            //// R-type with 3-register
                            dollar_pos = line.find_first_of("$");
                            comma_pos = line.find_first_of(",");
                            rd = line.substr(dollar_pos, comma_pos - dollar_pos);
                            //cout << rd <<", ";
                            dollar_pos = line.find_first_of("$", dollar_pos + 1);
                            comma_pos = line.find_first_of(",", comma_pos + 1);
                            rt = line.substr(dollar_pos, comma_pos - dollar_pos);
                            //cout << rs << ", ";
                            dollar_pos = line.find_first_of("$", dollar_pos + 1);
                            comma_pos = line.find_first_of(",", comma_pos + 1);
                            rs = line.substr(dollar_pos, comma_pos - dollar_pos);
                            // cout << rt << endl;
                            // Outputs of instruction = rd,rs,rt
                            converterR(opcode, rs, rt, rd, shamt, funct, inFile3);

                            continue;

                        }

                        //// R-type with 3-register
                        dollar_pos = line.find_first_of("$");
                        comma_pos = line.find_first_of(",");
                        rd = line.substr(dollar_pos, comma_pos - dollar_pos);
                        //cout << rd <<", ";
                        dollar_pos = line.find_first_of("$",dollar_pos+1);
                        comma_pos = line.find_first_of(",",comma_pos+1);
                        rs = line.substr(dollar_pos, comma_pos - dollar_pos);
                        //cout << rs << ", ";
                        dollar_pos = line.find_first_of("$", dollar_pos + 1);
                        comma_pos = line.find_first_of(",", comma_pos + 1);
                        rt = line.substr(dollar_pos, comma_pos - dollar_pos);
                        // cout << rt << endl;
                        // Outputs of instruction = rd,rs,rt
                        converterR(opcode, rs, rt, rd, shamt, funct, inFile3);

                        continue;
                    }
                    else if (inst[i].type == 'I')
                    {
                        if ((inst[i].name == "beq ") || (inst[i].name == "bne "))
                        {
                            dollar_pos = line.find_first_of("$");
                            comma_pos = line.find_first_of(",");
                            rs = line.substr(dollar_pos, comma_pos - dollar_pos);
                            dollar_pos = line.find_first_of("$", dollar_pos + 1);
                            comma_pos = line.find_first_of(",", comma_pos + 1);
                            rt = line.substr(dollar_pos, comma_pos - dollar_pos);
                            immediate = line.substr(comma_pos + 2, line.length() - (comma_pos + 2));                        
                            //outputs rs,rt,immediate
                            std::string::size_type sz;   // alias of size_t
                            int i_immediate = stoi(immediate, &sz);
                            immediate = to_string((i_immediate - (instruction_memory_address[instr_index] + 4)) / 4);
                            converterI(opcode,rs,rt,immediate,inFile3);
                            continue;
                        }
                        else if ((inst[i].name == "lb ") || (inst[i].name == "lbu ") || (inst[i].name == "lw ") || (inst[i].name == "sb ") || (inst[i].name == "sw "))
                        {
                            line=remove_whitespace(line);
                            dollar_pos = line.find_first_of("$");
                            comma_pos = line.find_first_of(",");
                            bracket_pos1 = line.find_first_of("(");
                            bracket_pos2 = line.find_first_of(")");

                            rt = line.substr(dollar_pos, comma_pos - dollar_pos);
                            immediate = line.substr(comma_pos+1, bracket_pos1 - (comma_pos+1));
                            dollar_pos = line.find_first_of("$",dollar_pos+1);
                            rs = line.substr(dollar_pos, bracket_pos2 - dollar_pos);
                            //cout << rt << immediate << rs << "test" << endl;
                            converterI(opcode, rs, rt, immediate, inFile3);
                            continue;
                        }                   
                        else if((inst[i].name == "lui "))
                        {
                            line = remove_whitespace(line);
                            dollar_pos = line.find_first_of("$");
                            comma_pos = line.find_first_of(",");
                            rt = line.substr(dollar_pos, comma_pos - dollar_pos);
                            immediate = line.substr(comma_pos + 1, line.length() - (comma_pos + 1));
                            //cout << rt << immediate << "test" << endl;
                            int16_t upperbits;
                            std::string::size_type sz;   // alias of size_t
                            int i_immediate = std::stoi(immediate, &sz);
                            upperbits = (i_immediate >> 16);
                            immediate = to_string(upperbits);
                            //cout <<"lui:" <<" "<< rs << " " << rt << " " <<" " << immediate << endl;
                            converterI(opcode, rs, rt, immediate, inFile3);

                            continue;

                        }
                        else if ((inst[i].name == "ori "))
                        {
                            line = remove_whitespace(line);
                            dollar_pos = line.find_first_of("$");
                            comma_pos = line.find_first_of(",");
                            rt = line.substr(dollar_pos, comma_pos - dollar_pos);
                            dollar_pos = line.find_first_of("$", dollar_pos + 1);
                            comma_pos = line.find_first_of(",", comma_pos + 1);
                            //cout << line << endl;
                            rs = line.substr(dollar_pos, comma_pos - dollar_pos);
                            immediate = line.substr(comma_pos+1, line.length() - (comma_pos + 1));
                            //cout << rt<< rs << immediate << "test" << endl;
                            int16_t lowerbits;
                            std::string::size_type sz;   // alias of size_t
                            int i_immediate = std::stoi(immediate, &sz);
                            lowerbits = (i_immediate);
                            immediate = to_string(lowerbits);
                            //cout << "ori:" << " " << rs << " " << rt << " " << " " << immediate << endl;
                            converterI(opcode, rs, rt, immediate, inFile3);

                            continue;          
                        }
                        else 
                        {
                            line = remove_whitespace(line);
                            dollar_pos = line.find_first_of("$");
                            comma_pos = line.find_first_of(",");
                            rt = line.substr(dollar_pos, comma_pos - dollar_pos);
                            dollar_pos = line.find_first_of("$", dollar_pos + 1);
                            comma_pos = line.find_first_of(",", comma_pos + 1);
                            //cout << line << endl;
                            rs = line.substr(dollar_pos, comma_pos - dollar_pos);
                            immediate = line.substr(comma_pos + 1, line.length() - (comma_pos + 1));
                            //cout << rt<< rs << immediate << "test" << endl;
                            converterI(opcode, rs, rt, immediate, inFile3);

                            continue;
                        }
                    }
                    else if (inst[i].type == 'J')
                    {
                        size_t space_pos = line.find_first_of(" ");
                        label_address = line.substr(space_pos + 1, line.length() - (space_pos + 1));
                        //cout << label_address << "test" << endl;
                        converterJ(opcode,label_address,inFile3,to_string(instruction_memory_address[instr_index]));

                        continue;
                    }
                    
                }

                
            }
            
            instr_index++;
        }
        inFile.clear();   // Restart reading line by line
        inFile.seekg(0);
        ////////////////// 
    }
    
}

void converterR(string opcode, string rs, string rt, string rd, string shampt, string function,fstream& inFile3) {
    string line;
    int op, shampt1, function1, i = 0;
    const char* zeroControl = "0";
    stringstream convertop(opcode);
    convertop >> op;
    stringstream convertshampt(shampt);
    convertshampt >> shampt1;
    stringstream convertfun(function);
    convertfun >> function1;
    opcode = bitset<6>(op).to_string();
    const char* rs1 = rs.c_str();
    const char* rt1 = rt.c_str();
    const char* rd1 = rd.c_str();
    while (i < 32) {
        if (strcmp(registers[i], rs1) == 0 || strcmp(zeroControl, rs1) == 0) {
            rs = bitset<5>(i).to_string();
        }
        if (strcmp(registers[i], rt1) == 0 || strcmp(zeroControl, rt1) == 0) {
            rt = bitset<5>(i).to_string();
        }
        if (strcmp(registers[i], rd1) == 0 || strcmp(zeroControl, rd1) == 0) {
            rd = bitset<5>(i).to_string();
        }
        i++;
    }
    shampt = bitset<5>(shampt1).to_string();
    function = bitset<6>(function1).to_string();
    //cout << opcode << rs << rt << rd << shampt << function << endl;
    line = opcode + rs + rt + rd + shampt + function;
    inFile3 << line << endl;
}

void converterI(string opcode, string rs, string rt, string constant,fstream& inFile3) {
    string line;
    int op, constant1, i = 0;
    const char* zeroControl = "0";
    stringstream convertop(opcode);
    convertop >> op;
    stringstream convertshampt(constant);
    convertshampt >> constant1;
    opcode = bitset<6>(op).to_string();
    const char* rs1 = rs.c_str();
    const char* rt1 = rt.c_str();
    while (i < 32) {
        if (strcmp(registers[i], rs1) == 0 || strcmp(zeroControl, rs1) == 0) {
            rs = bitset<5>(i).to_string();
        }
        if (strcmp(registers[i], rt1) == 0 || strcmp(zeroControl, rt1) == 0) {
            rt = bitset<5>(i).to_string();
        }
        i++;
    }
    constant = bitset<16>(constant1).to_string();
    if ((constant1 == 255) || (constant1 == -127))
    {
        // Give an error
    }
    else {
        line = opcode + rs + rt + constant;
        inFile3 << line << endl;
    }
    
}

void converterJ(string opcode, string address, fstream& inFile3, string pc_address) {
    string line;
    int op, adress, i = 0, pc_adress;
    stringstream convertpc(pc_address);
    convertpc >> pc_adress;
    stringstream convertop(opcode);
    convertop >> op;
    stringstream convertshampt(address);
    convertshampt >> adress;
    adress = adress / 4;
    address = bitset<22>(adress).to_string();
    opcode = bitset<6>(op).to_string();
    pc_address = bitset<32>(pc_adress).to_string();
    pc_address = pc_address.substr(0, 4);
    line = opcode + pc_address + address;
    inFile3 << line << endl;
}

string i_converterI(string opcode, string rs, string rt, string constant) {
    string line;
    int op, constant1, i = 0;
    const char* zeroControl = "0";
    stringstream convertop(opcode);
    convertop >> op;
    stringstream convertshampt(constant);
    convertshampt >> constant1;
    opcode = bitset<6>(op).to_string();
    const char* rs1 = rs.c_str();
    const char* rt1 = rt.c_str();
    while (i < 32) {
        if (strcmp(registers[i], rs1) == 0 || strcmp(zeroControl, rs1) == 0) {
            rs = bitset<5>(i).to_string();
        }
        if (strcmp(registers[i], rt1) == 0 || strcmp(zeroControl, rt1) == 0) {
            rt = bitset<5>(i).to_string();
        }
        i++;
    }
    constant = bitset<16>(constant1).to_string();
    if ((constant1 == 255) || (constant1 == -127))
    {
        //Give an error
    }
    else {
        line = opcode + rs + rt + constant;
        return line;
    }

}

void i_gethexfrombin(string bin) {

        string binToHex, tmp = "0000";
        for (size_t j = 0; j < bin.size(); j += 4) 
        {
            tmp = bin.substr(j, 4);
            if (!tmp.compare("0000")) binToHex += "0";
            else if (!tmp.compare("0001")) binToHex += "1";
            else if (!tmp.compare("0010")) binToHex += "2";
            else if (!tmp.compare("0011")) binToHex += "3";
            else if (!tmp.compare("0100")) binToHex += "4";
            else if (!tmp.compare("0101")) binToHex += "5";
            else if (!tmp.compare("0110")) binToHex += "6";
            else if (!tmp.compare("0111")) binToHex += "7";
            else if (!tmp.compare("1000")) binToHex += "8";
            else if (!tmp.compare("1001")) binToHex += "9";
            else if (!tmp.compare("1010")) binToHex += "A";
            else if (!tmp.compare("1011")) binToHex += "B";
            else if (!tmp.compare("1100")) binToHex += "C";
            else if (!tmp.compare("1101")) binToHex += "D";
            else if (!tmp.compare("1110")) binToHex += "E";
            else if (!tmp.compare("1111")) binToHex += "F";
            else continue;
        }
   
        cout << binToHex << endl;
}

void gethexfrombin(fstream& inFile) {

    fstream outFile;
    string bin;
    outFile.open("C:\\Users\\90531\\Desktop\\mips_object.o",ios::out);
    while (getline(inFile, bin)) {
        string binToHex, tmp = "0000";
        for (size_t j = 0; j < bin.size(); j += 4) {
            tmp = bin.substr(j, 4);
            if (!tmp.compare("0000")) binToHex += "0";
            else if (!tmp.compare("0001")) binToHex += "1";
            else if (!tmp.compare("0010")) binToHex += "2";
            else if (!tmp.compare("0011")) binToHex += "3";
            else if (!tmp.compare("0100")) binToHex += "4";
            else if (!tmp.compare("0101")) binToHex += "5";
            else if (!tmp.compare("0110")) binToHex += "6";
            else if (!tmp.compare("0111")) binToHex += "7";
            else if (!tmp.compare("1000")) binToHex += "8";
            else if (!tmp.compare("1001")) binToHex += "9";
            else if (!tmp.compare("1010")) binToHex += "A";
            else if (!tmp.compare("1011")) binToHex += "B";
            else if (!tmp.compare("1100")) binToHex += "C";
            else if (!tmp.compare("1101")) binToHex += "D";
            else if (!tmp.compare("1110")) binToHex += "E";
            else if (!tmp.compare("1111")) binToHex += "F";
            else continue;
        }
        outFile << binToHex << endl;
    }
    outFile.close();
}

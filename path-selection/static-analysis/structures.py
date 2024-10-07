from dataclasses import dataclass,field
from architectures import *

# Definitions
SUPPORTED_ARCHITECTURES = ['elf32-msp430','armv8-m33']

TEXT_PATTERN = ['Disassembly of section .text:',
                'Disassembly of section']

NODE_TYPES = ['cond','uncond','call','ret']

class bcolors:
    BLUE = '\033[94m'
    GREEN = '\033[92m'
    RED = '\033[91m'
    YELLOW = '\033[93m'
    END = '\033[0m'


class AssemblyInstruction:
    def __init__(self,addr,instr,arg,comment):
        self.addr           = addr
        self.instr       = instr
        self.arg          = arg 
        self.comment           = comment

    def __repr__(self) -> str:
        string = ''
        string += f'Address: {self.addr} Instruction: {self.instr} Argument: {self.arg} Comment: {self.comment}'
        return string+'\n'
    
class AssemblyFunction:
    def __init__(self,start_addr,end_addr,instrs):
        self.start_addr = start_addr # start addr of the function
        self.end_addr   = end_addr # end addr of the function
        self.instr_list = instrs # list of instrs in the function

    def __repr__(self) -> str:
        string = ''
        string += f'Start Address: {self.start_addr} End Address: {self.end_addr}\n'
        return string+'\n'

# Data Structures
class CFLogNode:
    def __init__(self, src_addr, dest_addr):
        self.src_addr     = src_addr
        self.dest_addr    = dest_addr 
        self.loop_count   = None      

    def __repr__(self) -> str:
        string = ''
        string += f'Source Address: {self.src_addr}\tDestination Address: {self.dest_addr}'
        return string+'\n'

class CFGNode:
    def __init__(self, start_addr, end_addr):
        self.start_addr     = start_addr
        self.end_addr       = end_addr
        self.type           = None
        self.instrs         = 0
        self.instr_addrs    = []
        self.successors     = []  
        self.adj_instr      = None        
        self.visitIdx       = 0

    def __repr__(self) -> str:
        string = ''
        string += f'Start Address: {self.start_addr}\tEnd Address: {self.end_addr}\tType: {self.type}\t# of Instructions: {self.instrs}\tAdjacent Address: {self.adj_instr}'
        #string += f'Instruction List: {self.instr_addrs}\n'
        string += f'\tSuccessors: {self.successors}\n'
        return string+'\n\n'

    def add_successor(self,node):
        self.successors.append(node)

    def add_instruction(self, instr_addr):
        self.instr_addrs.append(instr_addr)
        self.instrs += 1

class CFG:
    def __init__(self):
        self.head = None
        self.nodes = {} #node start addr is key, node obj is value
        self.func_nodes = {}
        self.num_nodes = 0 #number of nodes in the node dictionary
        self.label_addr_map = {}
        self.arch = MSP430()

    #Currently just prints all nodes, not just successors of cfg.head
    def __repr__(self)-> str:
        string = ''
        if self.num_nodes > 0:
            string += f'Total # of nodes: {self.num_nodes}\n'
            print(self.nodes)
        else:
            string += 'Empty CFG'

        return string+'\n\n'

    # Method to add a node to the CFG's dictionary of nodes
    def add_node(self,node,func_addr):
        # add node to dict of all nodes
        self.nodes[node.start_addr] = node
        # Add node to function nodes if there is >1 node
        self.func_nodes[func_addr] = [self.nodes[func_addr]]
        if node.start_addr != func_addr:
            self.func_nodes[func_addr].append(node)
        # Increment the number of nodes
        self.num_nodes += 1


###### Speculation data structures
class Speculator:
    def __init__(self, start_addr, end_addr):
        self.start_addr = start_addr #start address of speculation range
        self.end_addr = end_addr #end address of speculation range
        self.nodes = {} # nodes within speculation range
        self.forward_funcs = []
        self.empty_funcs = []
        self.loop_funcs = []
        self.segments = {}
        self.program_subpaths = {}
        self.func_metadata = {}
        self.loop_metadata = {}
        self.max_bytes = 128

    def __repr__(self) -> str:
        string = f'Start Address: {self.start_addr} End Address: {self.end_addr}\n'
        string += "Nodes:\n"
        for node in self.nodes:            
            string += str(self.nodes[node].start_addr)+": "+str(self.nodes[node].successors)+"\n"
        return string

    def subpath_toString(self, sp):
        if len(sp) == 1:
            # is loop
            return sp[0].end_addr[2:]+sp[0].start_addr[2:]
        else:
            i = 1
            s = "\""+sp[0].end_addr[2:]
            while i < len(sp):
                s += sp[i].start_addr[2:]+"\", "
                if i+1 < len(sp):
                    s += "\""+sp[i].end_addr[2:]
                i += 1
            return s

class Segment:
    def __init__ (self, start_addr):
        self.func = ""
        self.start_addr = start_addr
        self.internal = []
        self.end_addrs = []
        self.subpaths = {}
        # self.loop = False #default to false, if True is set during find_segments

    def __repr__(self)-> str:
        s = f"\tStart addr: {self.start_addr}\n"
        s += "\tInternal Nodes: \n"
        for node in self.internal:
            s += f"\t\t{node.start_addr},  {node.end_addr}\n"
        s += f"\tEnd addrs: {self.end_addrs}\n"
        # s += f"\tLoop: {self.loop}\n"
        return s
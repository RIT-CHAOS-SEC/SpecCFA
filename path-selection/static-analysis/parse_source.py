from utils import get_all_files,read_file,set_arch
from structures import *
import pathlib
import re


# All the information will be here
ASSEMBLY_FUNCTIONS = {} #start_addr:end_addr of all funcs found
ASSEMBLY_LABEL_MAPPING = {}
DATA_OBJECTS_ADDR = {}
DATA_OBJECTS_NAME = {}
INCLUDES = {} # we use dict to maintain insertion order + not add dublicate header files
SOURCE_BLOCK = []
INSTR_BLOCK = []
ALL_INSTRUCTIONS = []
UNDEFINED_OBJS = set()
CURRENT_LABEL = ''

def parse_nodes(arch,cfg):
    global ASSEMBLY_FUNCTIONS
    global ALL_INSTRUCTIONS

    br_instrs = arch.conditional_br_instrs + arch.unconditional_br_instrs + arch.call_instrs + arch.return_instrs
    node = CFGNode(None,None)
    current_function_addr = None

    # iterating over indexes so that we can grab adj instrs as well
    for i in range(len(ALL_INSTRUCTIONS)):
        # add addr if first addr of node
        if not node.start_addr:
            node.start_addr = ALL_INSTRUCTIONS[i].addr
        #add instruction to node
        node.add_instruction(ALL_INSTRUCTIONS[i])
        #check for br instr, if found create node
        if ALL_INSTRUCTIONS[i].instr in br_instrs:
            node.end_addr = ALL_INSTRUCTIONS[i].addr
            if ALL_INSTRUCTIONS[i].instr in arch.conditional_br_instrs:
                node.type = 'cond'
            elif ALL_INSTRUCTIONS[i].instr in arch.unconditional_br_instrs:
                node.type = 'uncond'
            elif ALL_INSTRUCTIONS[i].instr in arch.call_instrs:
                node.type = 'call'
            elif ALL_INSTRUCTIONS[i].instr in arch.return_instrs:
                node.type = 'ret'

            #add node to cfg dict
            if node.start_addr in ASSEMBLY_FUNCTIONS:
                cfg.add_node(node,node.start_addr)
                current_function_addr = node.start_addr # begin to add nodes to func
            else:
                try:
                    if node.end_addr == ASSEMBLY_FUNCTIONS[current_function_addr]:
                        cfg.add_node(node,current_function_addr) 
                    else:
                        cfg.add_node(node)
                except:
                    cfg.add_node(node)

            #add adj instrs to prev nodes 
            if i+1 < len(ALL_INSTRUCTIONS): # bounds check
                node.adj_instr = ALL_INSTRUCTIONS[i+1].addr
                #create a new node
                node = CFGNode(node.adj_instr,node.adj_instr)                
    return cfg

def update_successors(cfg):
    nodes_to_add = []
    for node_addr,node in cfg.nodes.items():
        if node.type == "cond":
            node.add_successor(clean_comment(node.instrs[-1].comment))
            if node.adj_instr:
                node.add_successor(node.adj_instr)
        elif node.type == "uncond":
            #first try to parse address from the arg
            a = clean_comment(node.instrs[-1].args[0])
            if a:
                node.add_successor(a)
            else:
                a = clean_comment(node.instrs[-1].comment)
                # If none (i.e addr is relative), parse the address from the comment
                if a:
                    node.add_successor(a)
        elif node.type == "call":
            br_dest = clean_comment(node.instrs[-1].args[0])
            node.add_successor(br_dest)
            # Locate the node at the end of the branching destination function
            # If the cfg.func_nodes[br_dest] doesnt exist, we need to 
            # find the function that DOES exist, whose start and end node wrap 
            # the address of this instruction
            try:
                eof_node = cfg.func_nodes[br_dest][-1] # this will get last function node if it returns
            except KeyError:
                eof_node = None

            if eof_node:
                cfg.nodes[eof_node.start_addr].add_successor(node.adj_instr)
                
                # Update the node successors with the correct start node

        # Add check to make sure all branching destinations are existing nodes
        # If not, create a new node
        for succ_addr in node.successors:
            if succ_addr is not None and succ_addr not in cfg.nodes:
                # This should prob be optimized
                for _,n in cfg.nodes.items():
                    if succ_addr >= n.start_addr and succ_addr <= n.end_addr:
                        new_node = CFGNode(succ_addr,n.end_addr)
                        new_node.type = n.type
                        new_node.successors = n.successors  
                        new_node.adj_instr = n.adj_instr 
                        new_node.instrs = n.instrs

                        stop = False
                        for i in n.instrs:
                            if i.addr != succ_addr and not stop:
                                new_node.instrs = new_node.instrs[1:]
                            else:
                                stop = True
                        new_node.num_instrs = len(new_node.instrs)
                        break
                nodes_to_add.append(new_node)
    for a in nodes_to_add:
        #should I be directly accessing struct members? probably not
        if a.start_addr not in cfg.nodes: # check for dupes
            cfg.nodes[a.start_addr] = a
            cfg.num_nodes +=1
    return cfg

def create_cfg(arch, lines):
    global ASSEMBLY_LABEL_MAPPING
    # Instantiate CFG object
    cfg = CFG()

    # parse the data objects
    arch,cfg = parse_data_objects(cfg,lines)
    
    # Parse nodes in each function
    cfg = parse_nodes(arch,cfg)

    # Update the successors of all generated nodes 
    cfg = update_successors(cfg)

    # Add map of labels to memory addrs to the cfg struct
    cfg.label_addr_map = ASSEMBLY_LABEL_MAPPING
    
    return cfg

def filter_disassembly(assembly_lines):
    # used to filer listing file to only the disassembly of .text section
    # Filter the 'Disassembly of section .text:' region
    ## Filter the beginning
    beg_id = 0
    while(assembly_lines[beg_id].find(TEXT_PATTERN[0])<0) :
        beg_id = beg_id+1
    ## Filter the end
    end_id = beg_id+1
    while(assembly_lines[end_id].find(TEXT_PATTERN[1])<0):
        end_id = end_id+1
    return assembly_lines[beg_id:end_id]

def clean_comment(comment):
    """
    This function attempts to extract a memory address from a given comment.
    """
    if comment is None:
        return comment
    comment = comment.split(' ')
    for c in comment:
        if '0x' in c:
            return c.strip('ghijklmnopqrstuvwyz!@#$%^&*(),<>/?.')

def is_mem_addr(s):
    if s is None:
        return False
    elif ':' in s:
        s = s.split(':')
    return not set(s[0]) - set("ABCDEFabcdef0123456789")

def parse_h(lines):
    pass

def check_line_type(line, l):
    '''
    Returns: arch, sym_table, label, instr, source, section, other
    '''
    if line is None or line == '':
        return None
    if 'file format' in line and len(l) == 4:
        return 'arch'
    elif line == 'SYMBOL TABLE:':
        return 'sym_table'
    elif '<' in line and '>' in line and len(l) == 2 and is_mem_addr(l[0]): 
        return 'label'
    elif 'Disassembly of section' in line and len(l)==4:
        return 'section'
    elif ':' in l[0] and is_mem_addr(l[0]):
        return 'instr'
    else:
        # Using as a catch all unless we can know a line is source
        # objdump has --source-comment flag, but not supported by msp430-objdump :(
        return 'source'
    
def parse_symbol_table(table):
    # Extract variables/objects from the symbol table
    # This is any objects in the .data or .bss section
    # with size >0
    for line in table:
        l = line.split()
        a = l[0].lstrip('0')
        while len(a) < 4: # pad address with 0's
            a = '0' + a
        addr = '0x' + a
        l = l[1:]
        # get rid of irrelevant fields
        while True:
            if '.' not in l[0] and '*' not in l[0]:
                l = l[1:]
            else:
                break
        section = l[0]
        hex_size = l[1].lstrip('0')
        if hex_size:
            size = int(hex_size,16)
        else:
            size = 0
        name = l[2]
        if (section == '.bss' or section == '.data') and size:
            obj = DataObj(size=size, base_addr=addr,name=name)
            # Update global data structures
            DATA_OBJECTS_ADDR[obj.base_addr] = obj
            DATA_OBJECTS_NAME[obj.name] = obj

def parse_label(l):
    global CURRENT_LABEL
    global SOURCE_BLOCK
    global INSTR_BLOCK
    global ALL_INSTRUCTIONS
    #print('Parsing Label...')
    label = l[1][1:-2]
    addr = '0x'+ l[0].lstrip('0')
    # Update global data structs
    ASSEMBLY_LABEL_MAPPING[label] = addr
    CURRENT_LABEL = label
    # Clear source and Instruction blocks
    SOURCE_BLOCK = []
    INSTR_BLOCK = []

def parse_instruction(arch, line):
    global CURRENT_LABEL
    # Separate Comments from command
    c = line.split(';')
    if len(c)>1:
        comment = c[1]
    else:
        comment = ''

    c = c[0].split('\t')
    # Remove if there is no instruction in the line
    if len(c) <= 2:
        return
    
    # Find memory address
    addr = '0x' + c[0].replace(' ','').replace(':','')
    
    # Find instruction
    if len(c) > 2:
        instr = c[2]
    else:
        instr = ''

    # Find instr argument
    a = ''
    args = []
    for arg_s in c[3:]:
        a+=arg_s
    a = a.replace('\t','').replace(' ','')
    args = a.split(',')

    # Add any functions to global struct
    if instr in arch.return_instrs:
        ASSEMBLY_FUNCTIONS[ASSEMBLY_LABEL_MAPPING[CURRENT_LABEL]] = addr

    i = AssemblyInstruction(addr,instr.replace(' ',''),args,comment)
    
    # Add to instruction list
    ALL_INSTRUCTIONS.append(i)
    INSTR_BLOCK.append(i)

def parse_define(arch, name,line):
    # This logic should be reviewed.
    # Can we assume pointers to data types have same
    # bounds as the data types themselves? 
    l = line.split(')')
    for k,v in arch.data_types.items():
        if k in l[0]:
            return DataObj(name=name,size=v,base_addr=l[1].strip())
    return None

def parse_source(arch,line,l):
    if l[0] == '#include':
        INCLUDES.setdefault(l[1])
    elif l[0] == '#define':
        if '//' in l[-1] or '/*' in l[-1]: # ensure split is not comment
                l = l[:-1]
        if len(l)>3: # check for non-constants
            name = l[1]
            remainder = ' '.join(l[2:]) # remove #define and name
            obj = parse_define(arch, name, remainder)
            # if obj is found in the define, then add it to global struct
            if obj:
                DATA_OBJECTS_ADDR[obj.base_addr] = obj
                DATA_OBJECTS_NAME[obj.name] = obj
    # Handle Comments ---------------------------------------
    elif line[0] == '/' and line[1] == '/': # do nothing for comments
        pass
    elif line[0] == '/' and line[1] == '*': 
        if line[-1] == '/' and line[-2] == '*':
            return False
        else:
            #Set the block comment flag to true
            return True
    elif line[-1] == '/' and line[-2] == '*':
            return False
    # --------------------------------------------------------
    # Add the source line to global list
    else:
        SOURCE_BLOCK.append(line)

def parse_initialization(arch, s_line):
    global DATA_OBJECTS_NAME
    global DATA_OBJECTS_ADDR
    global INSTR_BLOCK
    
    a = s_line.split('=')
    left = a[0].rstrip(' ')
    size = 1 # initialize size to 1
    # check for pointers and arrays
    if '*' in left:
        #TODO
        pass
    elif '[' in left:
        # update size multiplier
        tmp = left.split('[')
        left = tmp[0]
        size = int(tmp[1][:-1])
    
    right = a[1].lstrip(' ') # TODO: We can use right to tell if func is called to map params to registers
    # split line and filter out empty strings
    d = list(filter(None, left.split(' '))) 
    # name is in the context of the current label (function)
    name = d.pop() + '.' + CURRENT_LABEL
    # check for signed/unsigned bc they have no impact on object size
    if d[0] == 'signed' or d[0] == 'unsigned':
        d = d[1:]
    datatype = ' '.join(d)
    size *= arch.data_types[datatype] # ensure size is updated
    # create new data type obj
    # if varname already exists, update counter and name
    counter = 0
    suffix = ''
    while name+suffix in DATA_OBJECTS_NAME:
        counter += 1
        suffix = '.' + str(counter)
    #update name 
    name += suffix

    #get the offset of the stack pointer where the base address will be
    for i in INSTR_BLOCK:
        #i = INSTR_BLOCK.pop()
        if arch.stack_pointer in i.args[-1] and len(i.args) == 2:
            o = i.args[-1].split('(')
            offset = o[0]
            break
        else:
            offset = None
    obj = DataObj(size=size, base_addr_offset=offset,name=name)
    # Update global data structure
    DATA_OBJECTS_NAME[obj.name] = obj
    if obj.base_addr:
        DATA_OBJECTS_ADDR[obj.base_addr] = obj

def get_data_type(s_line):
    # split line and filter out empty strings
    s = list(filter(None, s_line.split(' '))) 
    # check for data type
    if s[0] == 'signed' or s[0] == 'unsigned': # this has no effect on bound size
        s = s[1:]
    return s[0]

def get_clean_source_line():
    global SOURCE_BLOCK
    c = ['']
    # Get useful source line
    # Check for single bracket
    while c[0] == '':
        if len(SOURCE_BLOCK)>0:
            raw_s_line = SOURCE_BLOCK.pop()
            if ';' not in raw_s_line:
                c = raw_s_line.split('{') # split comments
            else:
                break
        else:
            return 'NULL'
    if ';' in raw_s_line: # line is code
        l = raw_s_line.split(';') # split comments
        return l[0]
    else:
        return raw_s_line
    
def parse_block(arch):
    global CURRENT_LABEL
    global SOURCE_BLOCK
    global INSTR_BLOCK
    global UNDEFINED_OBJS
    #print("parsing block...")
    s_line = get_clean_source_line() 

    # Check for for loop initialization
    if 'for(' in s_line: #data obj can be assigned in for loop
        s_line = s_line[4:]
        if s_line.strip() == '': # Add a tmp line to continue w parsing
            s_line = '= NULL'
    if '=' in s_line and 'while' not in s_line and '!=' not in s_line and '|=' not in s_line and '&=' not in s_line and '==' not in s_line and '^=' not in s_line: #check for initialization statement
        d_type = get_data_type(s_line)
        # split arrays
        d_type = d_type.split('[')[0]
        if d_type in arch.data_types.keys():
        # check for assignment operator, then we have a normal assignment
            parse_initialization(arch,s_line)
        else: # we assume declare statement is directly above
            s_line_declaration = get_clean_source_line() 
            d_type2 = get_data_type(s_line_declaration)
            if d_type2 in arch.data_types.keys():
                s_line = d_type2 + ' ' + s_line
                parse_initialization(arch,s_line)
            else:
                if d_type + '.' + CURRENT_LABEL not in DATA_OBJECTS_NAME:
                    if d_type not in DATA_OBJECTS_NAME: #Check for global vars
                        UNDEFINED_OBJS.add(d_type)  
    #Clear blocks
    SOURCE_BLOCK = []
    INSTR_BLOCK = []

def parse_data_objects(cfg,lines,arch=None):
    global SOURCE_BLOCK
    global UNDEFINED_OBJS
    global DATA_OBJECTS_ADDR
    global DATA_OBJECTS_NAME

    # we currently only care about .text section
    #lines = filter_disassembly(lines)

    # Initialize symbol table
    sym_table = []

    # Initialize block comment flag
    comment_flag = False

    # Initialize last line type
    last_line_type = None
    for line in lines:
        # strip leading spaces
        line = line.lstrip(' ')

        # Handle symbol table creation
        # Line type hasn't been updated for the new line yet
        if last_line_type == 'sym_table':
            if TEXT_PATTERN[1] not in line:
                sym_table.append(line)
                continue
            parse_symbol_table(sym_table)
            last_line_type = None

        #TODO: May not need this anymore
        # split line and filter out empty strings
        l = list(filter(None, line.split(' '))) 
        line_type = check_line_type(line,l)
        if line_type == 'arch': 
                # Attempt to detect the architecture type if not provided
                if arch is None:
                    arch = set_arch(l[-1])
        elif line_type == 'sym_table': 
                #symbol table creation is handled automatically
                pass
        elif line_type == 'label':
                # Will parse label and set global variable for instrs to be added to this label
                parse_label(l)
        elif line_type == 'source':
            pass
                # Check if we should Parse block 
                #if last_line_type == 'instr':
                #    parse_block(arch)
                    # Add this line to new Source Block
                #    SOURCE_BLOCK.append(line)
                #elif not comment_flag:
                #    comment_flag = parse_source(arch,line,l)
        elif line_type == 'instr':
                parse_instruction(arch,line)
        
        # Save current line type
        last_line_type = line_type
    # TODO: parse all undefined objs
    #print(UNDEFINED_OBJS) 
    #cfg.data_objects_addr = DATA_OBJECTS_ADDR 
    #cfg.data_objects_name = DATA_OBJECTS_NAME

    return arch, cfg

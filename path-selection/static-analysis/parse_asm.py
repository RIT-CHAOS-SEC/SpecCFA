from structures import *
from utils import *

def parse_asm_functions(arch,assembly_lines):
    '''
        Description:
            Read a file generated by the command: msp430-objdump -d <executable_file_name> and fill the AssemblyFunction struct
        Input:
            assembly_lines: lines of the <executable_file> generated by .readlines() 
        Output: 
            AssemblyFunction struct
    '''

    # All the information will be here
    assembly_functions = {}
    assembly_functions_name_mapping = {}
    instructions = []

    # Filter the 'Disassembly of section .text:' region
    ## Filter the beginning

    beg_id = 0
    while(assembly_lines[beg_id].find(TEXT_PATTERN[0])<0) :
        beg_id = beg_id+1

    ## Filter the end     
    end_id = beg_id+1
    while(assembly_lines[end_id].find(TEXT_PATTERN[1])<0 and end_id < len(assembly_lines)-1):
        end_id = end_id+1

    if end_id < len(assembly_lines)-1:
        assembly_lines = assembly_lines[beg_id:end_id]
    else:
        assembly_lines = assembly_lines[beg_id:]

    # Parse each line
    for line in assembly_lines:
        s = line.split(' ')
        # Attempt to detect the architecture type if not provided
        if 'file format' in line:
            if arch is None:
                arch = set_arch(s[-1])
            
        # Extract assembly labels and addresses 
        elif '<' in line and '>' in line and len(s) == 2: 
            label = s[1][1:-2]
            addr = '0x'+ s[0].lstrip('0')
            assembly_functions_name_mapping[label] = addr
        # Else parse 
        elif line != '' and ':' in line: 
            # Separate Comments from command
            c = line.split(';')
            if len(c)>1:
                comment = c[1]
            else:
                comment = ''

            c = c[0].split('\t')
            # Remove if there is no instruction in the line
            if len(c) <= 2:
                continue
            
            # Find memory address
            addr = '0x' + c[0].replace(' ','').replace(':','')
            
            # Find instruction
            if len(c) > 2:
                instr = c[2]
            else:
                instr = ''

            # Find instr argument
            arg = ''
            for arg_s in c[3:]:
                arg+=arg_s

            # Add information to the struct and add to instr list
            instructions.append(AssemblyInstruction(addr,instr.replace(' ',''),arg.replace('\t',''),comment))
    
    done = False

    faddrs = []
    for n, a in assembly_functions_name_mapping.items():
        faddrs.append(a) 

    # Parse instructions into functions
    f = AssemblyFunction(instructions[0].addr, instructions[-1].addr, [])
    assembly_functions[f.start_addr] = f
    debugFile = open('debugFuncs.log', 'w')
    while not done: 
        for i in range(1, len(instructions)): 
            # print(instructions[i].addr)
            
            #### Detect functions as instructions in between addrs from label_map
            # Not a return -- Check if this is the last instr of the file

            if instructions[i].addr in faddrs:
                print("-------------", file=debugFile)
                print("Detected "+str(instructions[i].addr), file=debugFile)
                print("-------------", file=debugFile)
                print("Before change:", file=debugFile)
                print("\tassembly_functions[f.start_addr].end_addr: "+str(assembly_functions[f.start_addr].end_addr), file=debugFile)
                print("--", file=debugFile)
                assembly_functions[f.start_addr].end_addr = instructions[i-1].addr

                assembly_functions[f.start_addr].instr_list = instructions[:i]
                print("After change:", file=debugFile)
                print("\tassembly_functions[f.start_addr].end_addr: "+str(assembly_functions[f.start_addr].end_addr), file=debugFile)
                print("\tassembly_functions[f.start_addr].instr_list: "+str([inst.addr for inst in assembly_functions[f.start_addr].instr_list]), file=debugFile)
                print("-------------", file=debugFile)

                f = AssemblyFunction(instructions[i].addr, instructions[-1].addr, [])

                instructions = instructions[i:] # remove func instrs from list
                assembly_functions[f.start_addr] = f
                #print(instructions)
                
                break

            elif instructions[i] == instructions[-1]:
                done = True
        
        # Add any instrs not in func to extra "func" to be parsed as nodes
        print(len(instructions), file=debugFile)
        if len(instructions) <= 1 or done:
            assembly_functions[f.start_addr].end_addr = instructions[-1].addr
            assembly_functions[f.start_addr].instr_list = instructions
            print("reached outer else", file=debugFile)
            done = True

    debugFile.close()
    return arch,assembly_functions,assembly_functions_name_mapping

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
        
def parse_nodes(arch,assembly_functions,cfg):
    br_instrs = arch.conditional_br_instrs + arch.unconditional_br_instrs + arch.call_instrs + arch.return_instrs

    for func_addr,func in assembly_functions.items():
        node = CFGNode(func.start_addr,func.end_addr)

        # iterating over indexes so that we can grab adj instrs as well
        for i in range(len(func.instr_list)):

            #add instruction to node
            # print(f"func.instr_list[i]: {func.instr_list[i]}")
            node.add_instruction(func.instr_list[i])
            
            #check for br instr, if found create node

            ret_via_pop = (func.instr_list[i].instr == "pop" and "pc" in func.instr_list[i].arg) # check for ret via pop

            if ret_via_pop or func.instr_list[i].instr in br_instrs:
                node.end_addr = func.instr_list[i].addr
                if func.instr_list[i].instr in arch.conditional_br_instrs:
                    node.type = 'cond'
                elif func.instr_list[i].instr in arch.unconditional_br_instrs:
                    node.type = 'uncond'
                elif func.instr_list[i].instr in arch.call_instrs:
                    node.type = 'call'
                elif (func.instr_list[i].instr in arch.return_instrs) or ret_via_pop:
                    node.type = 'ret'
            
                #add node to cfg dict

                cfg.add_node(node,func_addr)
                # print(f"adding node: {node.start_addr}")

                #add adj instrs to prev nodes 
                if i+1 < len(func.instr_list): # bounds check
                    node.adj_instr = func.instr_list[i+1].addr
                    #create a new node
                    # print(f"starting next node: {node.adj_instr}")
                    node = CFGNode(node.adj_instr,node.adj_instr)                
        
    return cfg

def update_successors(cfg, arch):

    nodes_to_add = []
    for node_addr,node in cfg.nodes.items():
        if node.type == "cond":
            node.add_successor(clean_comment(node.instr_addrs[-1].comment))
            if node.adj_instr:
                node.add_successor(node.adj_instr)
        elif node.type == "uncond":
            if arch.arch_type == 'elf32-msp430':
                #first try to parse address from the arg
                a = clean_comment(node.instr_addrs[-1].arg)
                if a:
                    node.add_successor(a)
                else:
                    a = clean_comment(node.instr_addrs[-1].comment)
                    # If none (i.e addr is relative), parse the address from the comment
                    if a:
                        node.add_successor(a)
            if arch.arch_type == "armv8-m33":
                a = "0x"+node.instr_addrs[-1].arg.split(' ')[0]
                node.add_successor(a)

        elif node.type == "call":
            br_dest = ""
            if arch.arch_type == 'elf32-msp430':
                br_dest = clean_comment(node.instr_addrs[-1].arg)
            elif arch.arch_type == "armv8-m33":
                br_dest = "0x"+node.instr_addrs[-1].arg.split(' ')[0]

            node.add_successor(br_dest)
            # Locate the node at the end of the branching destination function
            # If the cfg.func_nodes[br_dest] doesnt exist, we need to 
            # find the function that DOES exist, whose start and end node wrap 
            # the address of this instruction
            try:
                eof_node = cfg.func_nodes[br_dest][-1]
            except KeyError:

                prev_key = list(cfg.func_nodes.keys())[0]
                for n in cfg.func_nodes.keys():
                    if n < br_dest:
                        prev_key = n
                    else:
                        break

                # Prev key should point to the function our br_dest is in 
                nodes_list = list(cfg.nodes.keys()) 

                for i in range(cfg.num_nodes):
                    if nodes_list[i] == br_dest:
                        cfg.func_nodes[br_dest]= [cfg.nodes[nodes_list[i]],cfg.func_nodes[prev_key][-1]]
                        
                        popped_node = cfg.func_nodes[prev_key].pop() # Remove last node
                        
                        append_node = cfg.nodes[nodes_list[i-1]]
                        cfg.func_nodes[prev_key].append(cfg.nodes[nodes_list[i-1]])
                        

                # store last key value in a variable 
                # check if curr value is less than target addr
                # if its less update previous value, and iterate till curr is > target
                #then previous key is the one we want

                #Sort new func_dict. Note: This seems expensive, do we need to re-sort?
                k = list(cfg.func_nodes.keys())
                k.sort()
                cfg.func_nodes = {x: cfg.func_nodes[x] for x in k}

                eof_node = cfg.func_nodes[br_dest][-1]

            if eof_node.type == 'ret':
                cfg.nodes[eof_node.start_addr].add_successor(node.adj_instr)
                
                # Update the node successors with the correct start node

        # Add check to make sure all branching destinations are existing nodes
        # If not, create a new node
        for succ_addr in node.successors:
            if succ_addr is not None and succ_addr not in cfg.nodes:
                # This should prob be optimized
                for _,n in cfg.nodes.items():
                    # print("("+str(n.start_addr)+","+str(n.end_addr)+")")
                    if succ_addr >= n.start_addr and succ_addr <= n.end_addr:
                        # if succ_addr == '0xe168':
                        #     print("!!!!")
                        #     print(succ_addr)
                        #     print("!!!!")
                        new_node = CFGNode(succ_addr,n.end_addr)
                        new_node.type = n.type
                        new_node.successors = n.successors  
                        new_node.adj_instr = n.adj_instr 
                        new_node.instr_addrs = n.instr_addrs

                        stop = False
                        for i in n.instr_addrs:
                            if i.addr != succ_addr and not stop:
                                new_node.instr_addrs = new_node.instr_addrs[1:]
                            else:
                                stop = True
                        new_node.instrs = len(new_node.instr_addrs)
                
                nodes_to_add.append(new_node)
    
    for a in nodes_to_add:
        #should I be directly accessing struct members? probably not
        if a.start_addr not in cfg.nodes: # check for dupes
            cfg.nodes[a.start_addr] = a
            cfg.num_nodes +=1
    return cfg
       
def create_cfg(arch, lines):
    # Instantiate CFG object
    cfg = CFG()

    # Parse functions objdump file 
    #Detect the arch of the binary if not provided 
    arch,assembly_functions,label_addr_map = parse_asm_functions(arch,lines)

    # for item in assembly_functions.items():
    #     print(item)

    # for f in assembly_functions:
    #     print(f)

    # Add map of labels to memory addrs to the cfg struct
    cfg.label_addr_map = label_addr_map

    # Parse nodes in each function
    cfg = parse_nodes(arch,assembly_functions,cfg)

    #Update the successors of all generated nodes 
    cfg = update_successors(cfg, arch)

    ##  print("------------- CFG Nodes ---------------")
    ##  for key in cfg.nodes.keys():
    ##      print("key = "+str(key))
    ##      for inst in cfg.nodes[key].instr_addrs:
    ##          print("\t"+str(inst))
    ##  

    return cfg, assembly_functions
    

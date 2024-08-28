import sys
import argparse

def arg_parser():
    '''
    Parse the arguments of the program
    Return:
        object containing the arguments
    '''
    parser = argparse.ArgumentParser()
    parser.add_argument('--infile', type=str, required=True,
                        help='input assembly file name (.s)')
    parser.add_argument('--dir', type=str, default='./',
                        help='directory of input/output files')
    parser.add_argument('--outfile', type=str, default='instrumented_app',
                        help='output file name (.s)')
    
    args = parser.parse_args()
    return args

def debug_print(string, file):
	if file.name == "debug.s":
		print(string, file=file)

def instrment_asm(directory, input_file, output_file):
	# directory = "./example_tz/NonSecure/Debug/Assembly/"
	# file = "application.s"
	
	infile_name = directory+input_file

	outfile_name = directory+output_file
	# outfile_name = "debug.s"

	app_entry_func = 'test_application'

	ret_instrs    = ['bx', 'bxeq']
	call_instrs			  = ['bl', 'blx']
	conditional_br_instrs = ['beq','bne','bhs','blo','bhi','bls','bgt','blt','bge','ble','bcs','bcc','bmi','bpl','bvs','bvc']

	conditional_dests = []
	trampoline = "SECURE"
	trampoline_cond_br = "SECURE_log_cond_br"
	trampoline_call = "SECURE_log_call"
	trampoline_ret = "SECURE_log_ret"

	offset = 0

	infile = open(infile_name, "r")
	lines = infile.readlines()
	infile.close()

	count = 0
	for x in lines:
		parsed  = x.split('\t')
		if len(parsed) > 1:
			inst = parsed[1]
			if '.' not in inst:
				if inst in ret_instrs:
					print(inst)
					count += 1
				elif inst in call_instrs:
					print(inst)
					count += 1
				elif inst in conditional_br_instrs:
					print(inst)
					count += 1
				elif inst =='pop':
					arg = parsed[2]
					if 'pc' in arg:
						print(inst+arg)
						count += 1
	print("Total branching instructions: "+str(count))

	outfile = open(outfile_name, "w")

	lines = [x.replace('\n','') for x in lines if x != '\n']

	last_push = ""

	i = 0
	case = 0
	# first pass -- instrument calls and returns, and cond.branch not taken
	while i < len(lines):
		x = lines[i]
		i += 1
		parsed = x.split('\t')
		if "test_application" in x:
			x = x.replace("test_application", "application")

		if "application.c" in x:
			continue

		# if '@' in x or ".file" in x:
		# 	continue 

		if trampoline in x:
			print(x, file=outfile)
			case = 1

		# Assembly line is an instruction
		elif len(parsed) > 2:
			inst = parsed[1]
			args = parsed[2]
			
			detect_cond_branch = (inst in conditional_br_instrs)
			detect_ret_inst = (inst in ret_instrs)
			detect_ret_via_pop = (inst == 'pop') and ('pc' in args)
			detect_call_inst = (inst in call_instrs)

			if detect_call_inst:
				case = 2
				debug_print("------ instrumenting call ("+inst+" "+args+")", file=outfile)
				if inst == 'bl': # direct call, use ldr
					case = 3
					print("\tldr\tr10, ="+args, file=outfile)
				elif inst == 'blx': # indirect call, can use mov
					case = 4
					print("\tmov\tr10, "+args, file=outfile)
				print("\tbl\t"+trampoline_call, file=outfile)

			elif detect_cond_branch:
				case = 5
				debug_print("------ instrument cond branch not taken ("+inst+") "+args, file=outfile)
				conditional_dests.append(args)
				print(x, file=outfile)
				print("\tbl\t"+trampoline_cond_br, file=outfile)

			# # 	debug_print("------ ", file=outfile)
			elif detect_ret_via_pop:
				case = 6
				#Instrument before return
				debug_print("------ instrumenting ret via pop ("+inst+") "+args, file=outfile)
				print(("\tpop\t"+args).replace("pc", "lr"), file=outfile)
				print("\tb\t"+trampoline_ret, file=outfile)
				
			# 	debug_print("------ ", file=outfile)
			else:
				case = 7
				print(x, file=outfile)
		else:
			case = 8
			print(x, file=outfile)

	print("------------------")
	print("Conditional br destinations: "+str(conditional_dests))
	print("------------------")

	outfile.close()

	infile = open(outfile_name, "r")
	lines = infile.readlines()
	infile.close()

	outfile = open(outfile_name, "w")

	lines = [x.replace('\n','') for x in lines if x != '\n']

	i = 0
	# second pass -- instrument cond.branch taken
	while i < len(lines):
		x = lines[i]
		i += 1
		parsed = x.split('\t')
		
		if ".file" in x or 'nop' in x:
			continue 
		elif len(parsed) == 1 and parsed[0].split(":")[0] in conditional_dests:
			debug_print("------ instrumenting cond branch dest ("+x+")", file=outfile)
			print(x, file=outfile)
			print("\tbl\t"+trampoline_cond_br, file=outfile)
		else:
			print(x, file=outfile)
	outfile.close()

if __name__ == '__main__':
	args = arg_parser()

	instrment_asm(args.dir, args.infile, args.outfile)
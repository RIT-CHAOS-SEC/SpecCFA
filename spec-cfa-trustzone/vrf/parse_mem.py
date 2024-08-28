SECURE_FLASH_START = 0x0c0001f8
SECURE_FLASH_END = 0x0c016fd6 #C01702E
# actual stop = 	   0x0c017038
SECURE_FLASH_SIZE = SECURE_FLASH_END-SECURE_FLASH_START+2

NSC_FLASH_START = 0x0c03e000
NSC_FLASH_END =	0x0c03e03e
NSC_FLASH_SIZE = NSC_FLASH_END-NSC_FLASH_START+2

NONSECURE_FLASH_START = 0x080401f8
NONSECURE_FLASH_END = 0x08040c84
NONSECURE_FLASH_SIZE = NONSECURE_FLASH_END-NONSECURE_FLASH_START+2

SEC_WORLD = 0
NSC = 1
NS_WORLD = 2

def parse_mem(token):
	filepath = ""
	mem = []
	if token == SEC_WORLD or token == NSC:
		filepath = "objects/Secure.mem"
	else:
		filepath = "objects/NonSecure.mem"

	print("------------ Parsing "+str(filepath)+" --------------")
	mem = read_mem(filepath)

	if token == SEC_WORLD:
		mem = mem[:SECURE_FLASH_SIZE]
	if token == NSC:
		mem = mem[SECURE_FLASH_SIZE:]

	mem_chunks = []
	blake2b_blocksize = 128
	for i in range(0, len(mem), blake2b_blocksize):
		chunk = mem[i:i+blake2b_blocksize]
		mem_chunks.append(b''.join([string_to_int(x).to_bytes(1, byteorder='big') for x in chunk]))
		# mem_chunks.append(chunk)
	return mem_chunks

def read_mem(filepath):
	with open(filepath, 'r') as fp:
		lines = fp.readlines()

	# strip '\n' and swap endianess
	for i in range(0, len(lines), 2):
		l0 = lines[i].strip()
		l1 = lines[i+1].strip()
		lines[i] = l1
		lines[i+1] = l0

	return lines

def string_to_int(s):
	int_vals = [ord(s[0]),ord(s[1])]
	
	for i in range(0, 2):
		int_vals[i] -= 0x30
		if int_vals[i] >= 0x30:
			int_vals[i] -= 0x27

	return 16*int_vals[0]+int_vals[1]

if __name__ == '__main__':
	blake2b_blocksize = 128

	print("SECURE_FLASH_START: "+str(hex(SECURE_FLASH_START)))
	print("SECURE_FLASH_END: "+str(hex(SECURE_FLASH_END)))
	print("SECURE_FLASH_SIZE: "+str(hex(SECURE_FLASH_SIZE)))
	print()
	print("NSC_FLASH_START: "+str(hex(NSC_FLASH_START)))
	print("NSC_FLASH_END: "+str(hex(NSC_FLASH_END)))
	print("NSC_FLASH_SIZE: "+str(hex(NSC_FLASH_SIZE)))
	print()
	print("NONSECURE_FLASH_START: "+str(hex(NONSECURE_FLASH_START)))
	print("NONSECURE_FLASH_END: "+str(hex(NONSECURE_FLASH_END)))
	print("NONSECURE_FLASH_SIZE: "+str(hex(NONSECURE_FLASH_SIZE)))
	print()

	mem_tokens = [NS_WORLD] #SEC_WORLD, NSC, 
	for token in mem_tokens:
		mem_chunks = parse_mem(token)
		print("Total: ")
		print(len(mem_chunks))
		print()
		print("First: ("+str(len(mem_chunks[0]))+")")
		print([hex(x) for x in mem_chunks[0]])
		print()
		print("Last: ("+str(len(mem_chunks[len(mem_chunks)-1]))+")")
		print([hex(x) for x in mem_chunks[len(mem_chunks)-1]])
		print()
		addr = NONSECURE_FLASH_START
		for chunk in mem_chunks:
			addr+=len(chunk)
			print(hex(addr))
	print("-------------------------------------------------")
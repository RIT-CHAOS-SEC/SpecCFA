import sys

def read_mem(filepath):
	with open(filepath, 'r') as fp:
		lines = fp.readlines()
	return lines

def write_mem(filepath, lines):
	with open(filepath, 'w') as fp:
		for l in lines:
			fp.write("%s" % l)

if __name__ == '__main__':
	lines = read_mem(sys.argv[1])
	for j in range(0, len(lines)):
		l = lines[j]
		if ".word" in l:
			# print(l)
			# print(l.split())
			# print(l.split()[1])
			s = " "
			ll = l.split()
			for i in range(0, len(ll)):
				if i == 1:
					s += ll[i][4:8]+ll[i][0:4]
				else:
					s += ll[i]
				s += '\t'
			s += '\n'
			# print(s)

			lines[j] = s

	# for l in lines:
		# print(l)
	write_mem(sys.argv[1]+"2", lines)

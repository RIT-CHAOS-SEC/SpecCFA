import sys

'''
Given the log as a list (raw_data) and the maximum number of transitions (max_k)
determine all possible subpaths with length 2 up to max_k

Returns a list (data) with all subpaths
Subpaths are formated as a string: "A-B" denotes transition A followed by transition B
'''
def get_data(raw_data, max_k):
	k = max_k
	data = []
	# start at k=max_k and continue until k=2.
	while k >= 2:
		# maximum index of raw_data depends on current k being tested
		bound = len(raw_data)-(k-1)
		for i in range(0, bound):
			# reset string after each k iterations
			sub_data = ""
			
			# add each transition to the current subpath string
			for j in range(i, i+k):
				sub_data = sub_data+raw_data[j]
				
				# add '-' after all of them except for the last one
				if(j != (i+k)-1):
					sub_data = sub_data+"-"

			# append subpath to the list
			data.append(sub_data)
		k -= 1

	return data

'''
Given a list of all subpaths of length (2, max_length), determine the rate at which it occurs
Return a dictionary that maps {subpath : rate}
'''
def get_rates(data, total_cflog_data):
	total_cflog_bytes = 4 * total_cflog_data

	rates = {}
	# Iterate through the list and count unique subpaths
	for i in range(0, len(data)):
		# add supath to dict if it hasn't been added
		if data[i] not in rates:
			rates[data[i]] = 1
		# if it has been added, increment a counter
		else:
			rates[data[i]] = rates[data[i]] + 1

	# after counts have been determine, calculate rate based on the length of the subpath
	for key in rates:
		
		# subpath bytes is determined by the length of the subpath and its count
		subpath_bytes = rates[key]*4*len(key.split('-'))

		# final rate is determined by dividing the bytes of the subpath by the bytes of the logs
		# compute as a percentage with 5 sig digits
		rates[key] = round(100*subpath_bytes/total_cflog_bytes, 5)

	return rates

'''
Function to find non-overlapping paths

-- Sorts path-rates dict in decreasing order (largest rates first)
-- Initializes an empty dict (selected_paths)
-- Iterates through path_dict.
-- If path contains any previously added path, select the one with the higher rate
-- Else, compare their rates and keep only the path with the higher rate.
'''
def find_subpaths(paths_dict, threshold):
    # sort paths by decreasing rate
    sorted_paths = sorted(paths_dict.items(), key=lambda x: x[1], reverse=True)
    selected_paths = {}
    for path, rate in sorted_paths:
    	nodes = path.split("-")
    	if rate >= threshold and nodes[0] != nodes[-1]:
	        # check if path contains any selected path
	        contains_path = False
	        for selected_path in selected_paths:
	            if selected_path in path:
	                contains_path = True
	                # if path contains a previously selected path, keep the one with a larger rate
	                if rate > paths_dict[selected_path]:
	                    selected_paths.pop(selected_path)
	                    selected_paths[path] = rate
	                break
	        # if path does not contain any selected path, add it to selected paths
	        if not contains_path:
	            # check if path is a subset of any selected path
	            subset_path = False
	            for selected_path in selected_paths:
	                if path in selected_path:
	                    subset_path = True
	                    break
	            # if path is not a subset of any selected path, add it to selected paths
	            if not subset_path:
	                selected_paths[path] = rate
    # sort selected paths by decreasing rate
    selected_paths = sorted(selected_paths.items(), key=lambda x: x[1], reverse=True)
    return [path for path, rate in selected_paths]

####################################################################

if __name__ == '__main__':
	if len(sys.argv) < 2:
		print("ERROR: Not enough arguments")
		print("")
		print("How to run:")
		print("---- inspectLogs.py [MAX_LENGTH] [MIN_FREQ]")
		print("---- \t MAX_LENGTH: (int) maximum length subpath to consider")
		print("---- \t MIN_FREQ: (int) minimum subpath frequency to consider")
		print("---- ")
		print("---- \t Example: Consider subpaths up to 4 transitions that occur at most 5\% of the time in previous logs: ")
		print("---- \t inspectLogs.py 4 5 ")
	else:

		### Get raw data from file ###
		f = open("all.cflog")
		raw_data = []
		for x in f:
			raw_data.append(x.replace("\n",""))
		f.close()
		total_cflog_data = len(raw_data)
		

		### Get rates of unique sets of k transisions ###
		total = len(raw_data)
		
		max_k = int(sys.argv[1])

		try:
			threshold = int(sys.argv[2])
		except IndexError:
			threshold = 0

		is_dup = True

		print("--- Searching for up to k="+str(max_k)+" transitions that repeat more than threshold="+str(threshold)+"% times ---")

		print("\t processing data...")
		data = get_data(raw_data,max_k)

		# print("data: ")
		# for d in data[:20]:
		# 	print(d)
		# print(".\n.\n.")
		# for d in data[len(data)-20:]:
		# 	print(d)
		# print()
		print("\t detecting rates...")
		rates = get_rates(data, total_cflog_data)

		# print("rates: ")
		# count = 0
		# for r in rates.keys():
		# 	print(r+" : "+str(rates[r]))
		# 	count += 1
		# 	if count == 20:
		# 		break
		# print()
		
		print("\t finding subpaths...")
		subpaths = find_subpaths(rates, threshold)
		print()
		print("--------------------- Subpaths ---------------------")
		for sp in subpaths:
			print(sp+" : "+str(rates[sp]))
		print()
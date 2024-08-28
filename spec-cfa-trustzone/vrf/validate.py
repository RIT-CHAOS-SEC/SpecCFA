import sys

def validate_optimized(subpaths, baseline, optimized):
    unoptimized = []
    i = 0
    while i < len(optimized):
        if optimized[i].startswith('1111'):
            # subpath id
            subpath = subpaths[optimized[i]][:]
            if i + 1 < len(optimized) and optimized[i+1].startswith('ffff'):
                # parse counter
                count = int(optimized[i+1][4:], 16)
                subpath *= count
                i += 1
            unoptimized.extend(subpath)
        else:
            # keep element as-is
            unoptimized.append(optimized[i])
        i += 1
    
    # Replace subpath ids in the baseline list
    baseline = [subpaths[subpath] if subpath.startswith('1111') else subpath for subpath in baseline]
    
    return unoptimized == baseline, unoptimized

def main(app, num_sp):
    # Set directories
    BASE_CFLOG_DIR = f"../cflogs/{app}/baseline/"
    SPEC_CFLOG_DIR = f"../cflogs/{app}/{num_sp}/"



    # Initialize subpath dict with key as id and elt as list(subpath)
    subpaths = {}

    subpaths["11110000"] = ['80406ca']
    # subpaths["11110001"] = ['8040258', '80403a2', '804036a', '8040372', '8040390', '8040238']
    # subpaths["11110002"] = ['80402b2','804031e']
    # subpaths["11110003"] = ['804031e', '80402b2', '80402d2', '80402e0', '80402fc', '8040314', '804031e', '804032e']
    # subpaths["11110004"] = ['8040338','8040362','804039e', '80403d4'] # '8040338', '8040362', '804039e', '80403d4'
    # subpaths["11110005"] = ['8040390', '804026c', '8040238']
    # subpaths["11110006"] = ['8040258', '8040284', '8040238']
    # subpaths["11110007"] = ['8040258', '8040296', '8040238']


    # Counter ID
    counter_id = "0000"

    #--------------------------------------------------
    # Read baseline cflogs into one list
    #--------------------------------------------------
    print("----------")
    print("Processing unoptimized logs")
    baseline_cflog = []
    more_cflogs = True
    log_num = 0
    while more_cflogs:
    	try:
    		file_path = BASE_CFLOG_DIR+str(log_num)+".cflog"
    		f = open(file_path)
    		print("\tProcessing \'"+file_path+"\'")
    		for x in f:
    			elt = x.replace("\n","")
    			# if elt[:4] != "dffe" and len(elt) == 8:
    			baseline_cflog.append(elt)
    		log_num += 1
    	except FileNotFoundError:
    		more_cflogs = False

    print("Total CF entries without Speculation = "+str(len(baseline_cflog)))
    #--------------------------------------------------

    #--------------------------------------------------
    # Read spec-cfa cflogs into one list
    #--------------------------------------------------
    print(" ")
    print("Processing optimized logs")
    spec_cflog = []
    more_cflogs = True
    log_num = 0
    while more_cflogs:
    	file_path = SPEC_CFLOG_DIR+str(log_num)+".cflog"
    	try:
    		f = open(file_path)
    		print("\tProcessing \'"+file_path+"\'")
    		for x in f:
    			elt = x.replace("\n","")
    			# if elt[:4] != "dffe" and len(elt) == 8:
    			spec_cflog.append(elt)
    		log_num += 1
    	except FileNotFoundError:
    		more_cflogs = False

    print("Total CF entries with Speculation = "+str(len(spec_cflog)))
    print("----------")
    ratio = len(spec_cflog)/len(baseline_cflog)
    savings = 1 - ratio
    print("CF-Log size compared to baseline: "+str(round(100*ratio, 3))+"%")
    print("CF-Log storage reduction compared to baseline: "+str(round(100*savings, 3))+"%")
    #--------------------------------------------------

    # for i in range(0, len(baseline_cflog)):
    # 	print(baseline_cflog[i])

    result, unoptimized = validate_optimized(subpaths, baseline_cflog, spec_cflog)
    print(result)
    # print(i)
    # print(unoptimized[i])
    # print(j)
    # print(baseline_cflog[j])

    # for u in unoptimized:
    	# print(u)
    #--------------------------------------------------
    # Write all lists to files for debugging
    #--------------------------------------------------
    with open('../cflogs/validate/baseline.cflog', 'w') as f:
        for line in baseline_cflog:
            f.write(f"{line}\n")

    with open('../cflogs/validate/spec.cflog', 'w') as f:
        for line in spec_cflog:
            f.write(f"{line}\n")

    with open('../cflogs/validate/rebuilt.cflog', 'w') as f:
        for line in unoptimized:
            f.write(f"{line}\n")


if __name__ == '__main__':
    if len(sys.argv) != 3:
        print("How to run: validate.py [app] [num_sp]")
    else:
        app = sys.argv[1]
        num_sp = sys.argv[2]
        main(app, num_sp)
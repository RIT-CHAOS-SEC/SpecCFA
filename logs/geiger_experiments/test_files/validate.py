def validate_optimized(subpaths, baseline, optimized):
    unoptimized = []
    i = 0
    while i < len(optimized):
        if optimized[i].startswith('1111'):
            # subpath id
            subpath = subpaths[optimized[i]][:]
            if i + 1 < len(optimized) and optimized[i+1].startswith('0000'):
                # parse counter
                count = int(optimized[i+1], 16)
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



# Set directories
BASE_CFLOG_DIR = "../logs/geiger_baseline/"
SPEC_CFLOG_DIR = "../logs/"

# Initialize subpath dict with key as id and elt as list(subpath)
subpaths = {}

subpaths["11110001"] = ["e19ae288", "e28ae28c", "e28ee29a", "e2b4e2b6", "e2b8e2ba", "e2c2e168"]
subpaths["11110002"] = ["e202e1b6", "e1e8e206", "e208e254", "e276e278", "e27ae27c", "e284e168", "e18ce196", "e19ae288", "e28ae290", "e294e13c", "e166e298", "e298e2d2", "e2d2e1ea", "e1f4e168", "e18ce18e", "e190e192", "e19ae1f8", "e1fae2d6", "e2e2e07c", "e07ee080", "e082e0b4"]
subpaths["11110003"] = ["e0bee078", "e078e236", "e24ce0fa", "e13ae250", "e250e1fc"]
subpaths["11110004"] = ["e18ce196","e19ae2c6", "e2c8e2ce", "e2cee19c", "e1a6e13c","e166e1aa","e1aee0ce","e0f8e1b2","e1b4e2d2","e2d2e1ea","e1f4e168","e18ce196","e19ae1f8","e1fae2d6","e2e2e07c","e07ee084","e084e2e4","e2eee168","e18ce18e","e190e192","e19ae2f2","e2f6e088","e08ae08c"]
subpaths["11110005"] = ["e202e1b6",'e1e8e206','e208e254','e276e280','e284e168','e18ce18e','e190e192','e19ae288','e28ae290','e294e13c','e166e298','e298e2d2','e2d2e1ea','e1f4e168','e18ce18e','e190e192','e19ae1f8','e1fae2d6','e2e2e07c','e07ee080','e082e0b4']
subpaths["11110006"] = ['e19ae2c6','e2c8e2ce','e2cee19c','e1a6e13c','e166e1aa','e1aee0ce','e0f8e1b2','e1b4e2d2','e2d2e1ea','e1f4e168','e18ce196','e19ae1f8','e1fae2d6','e2e2e07c','e07ee084','e084e2e4','e2eee168']
subpaths["11110007"] = ['e202e1b6','e1e8e206','e208e254','e276e278','e27ae27c','e284e168','e18ce18e','e190e192']
subpaths["11110008"] = ['e202e1b6','e1e8e206','e208e254','e276e280','e284e168','e18ce196']


# Counter ID
counter_id = "0000"

#--------------------------------------------------
# Read baseline cflogs into one list
#--------------------------------------------------
print("----------")
print("Processing unoptimized logs")
baseline_cflog = []
more_cflogs = True
log_num = 1
while more_cflogs:
	try:
		file_path = BASE_CFLOG_DIR+str(log_num)+".cflog"
		f = open(file_path)
		print("\tProcessing \'"+file_path+"\'")
		for x in f:
			elt = x.replace("\n","")
			if elt[:4] != "dffe" and len(elt) == 8:
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
log_num = 1
while more_cflogs:
	file_path = SPEC_CFLOG_DIR+str(log_num)+".cflog"
	try:
		f = open(file_path)
		print("\tProcessing \'"+file_path+"\'")
		for x in f:
			elt = x.replace("\n","")
			if elt[:4] != "dffe" and len(elt) == 8:
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
with open('baseline.cflog', 'w') as f:
    for line in baseline_cflog:
        f.write(f"{line}\n")

with open('spec.cflog', 'w') as f:
    for line in spec_cflog:
        f.write(f"{line}\n")

with open('rebuilt.cflog', 'w') as f:
    for line in unoptimized:
        f.write(f"{line}\n")


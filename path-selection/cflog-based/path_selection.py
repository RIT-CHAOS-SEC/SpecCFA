import argparse
import math
import os
import random

from functools import cmp_to_key


def check_path(parser, path):
    """
    Check if the supplied path is a valid path in the system
    Args:
        argparse.ArgumentParser parser - parser that is fetching the path
        str path - The file path read in by parser
    Returns:
        The path if it exists on the system, otherwise triggers an argparse error
    """
    if not os.path.exists(path):
        parser.error(f"Directory {path} does not exist!")
    else:
        return path
        

def parse_args():
    """
    Parse in command line input
    Returns:
        The parsed command line arguments
    """
    
    parser = argparse.ArgumentParser()
    
    parser.add_argument("-d", "--directory", type=lambda x: check_path(parser, x), default=".", help="Path to the log file directory. Defaults to current directory")
    parser.add_argument("-m", "--max", type=int, default=None, help="The maximum length of subpaths to compute. If not specified subpaths of all possible lengths will be checked")
    parser.add_argument("-o", "--output", type=str, default=None, help="The name of an output file to save the resulting subpaths to")
    parser.add_argument("-p", "--partial", action="store_true", help="If selected the larger region represented by partially overlapping regions will be compared against current results to see if it is better than the existing selection")
    parser.add_argument("-n", "--num_paths", type=int, default=None, help="The number of subpaths to display. Required for the minimize algorithm")
    parser.add_argument("-a", "--architecture", type=str, choices=["msp", "arm"], default="msp", help="The architecture of the log file. Indicative of which specCFA version is being run and how the log files are formatted")

    subparsers = parser.add_subparsers(help="selection algorithms", dest="algo", required=True)
    list_parser = subparsers.add_parser("list", help="Lists all possibles subpaths from highest frequency to lowest")
    list_parser.add_argument("version", type=str, choices=["all", "unique"], help="How to chose subpaths. All lists all subpathes including overlapping paths. Unique lists only paths that arent overlapping")
    list_parser.add_argument("-l", "--lower", type=int, default=-1, help="The minimum subpath length to search through")
    list_parser.add_argument("-u", "--upper", type=int, default=None, help="The maximum subpath length to search through")
    
    select_parser = subparsers.add_parser("select", help="Selects best subpaths with respect to blockmem size")
    select_parser.add_argument("-b", "--block_mem_size", type=int, default=128, help="The size of blockmem in bytes")
    
    minimize_parser = subparsers.add_parser("minimize", help="Selects best subpaths while trying to minimize the size of blockmem")
    minimize_parser.add_argument("-t", "--threshold", type=float, default=5.0, help="How large an increase in savings is needed to justify an increase in block mem size. Default: 5.0")
    minimize_parser.add_argument("-u", "--upper", type=int, default=None, help="The maximum subpath length to search through")

    lucky_parser = subparsers.add_parser("lucky", help="Selects random subpaths")
    
    
    return parser.parse_args()
 
    
def load_logs(root, version):
    """
    Loads the previous logs used to make the subpath selections
    Args:
        str root - The path of the directory containing the log files
        str version - Which architecture ( and by proxy log type) we are working with
    Returns:
        previous_logs - a dictionary mapping each log to the entries it contains
        master_log - a string representation of the overall combined log entries
    """

    previous_logs = dict()
    master_log = []
    
    files = os.listdir(root)
   
    file_order = []
    for i in range(len(files)):
        file_order.append((int(files[i].split(".")[0]), i))
    file_order.sort()
    
    for log, index in file_order:
        
        if version == "arm" and log == 0:
            continue
            
        name = files[index]
        if name.endswith(".cflog"):
            path = os.path.join(root, name)
            fp = open(path, "r")
            temp = fp.readlines()
            fp.close()
            if version == "msp":
                temp = temp [1:-2]

            previous_logs[name] = temp
            master_log.extend([entry.strip() for entry in temp])
            
    return previous_logs, master_log   
 
    
def count_singles(database, log):
    """
    Determines all unique entries and how often they occur in the log
    Args:
        dict(int, dict(str, float)) database - dictionary mapping lengths, subpaths, how often they occur in the log, and the percentage of log that is
        list(str) log - The control flow log being parsed
    Returns:
        The updated database with the counts for each single entry
    """
    entries = set()
    entries.update(log)
    database[1] = {}
    length = len(log)
    
    for entry in entries:
        frequency = 0
        consecutive = 1
        max_consecutive = 1
        counting = 0
        for other_entry in log:
            
            if not counting and other_entry == entry:
                counting = 1
                frequency += 1
            elif counting and other_entry != entry:
                max_consecutive = max(max_consecutive, consecutive)
                counting = 0
            elif counting:
                consecutive += 1
                frequency += 1
        
        if max_consecutive > 1:
            database[1][entry] = (frequency/length)*100
    
    return database


def brute_force_subpaths(database, log, upper_bound):
    """
    Determines all possible subpaths in the log, how often they occur, and the percentage of the total log they represent
    Args:
        dict(int, dict(str, float)) - dictionary mapping lengths, subpaths, how often they occur, and the percentage of the total log 
        list(str) log - The control flow log being parsed
        int upper_bound - the largest size subpath to calculate
    Returns:
        The updated database of possible subpaths
    """
    
    # apply restrictions if wanted
    length = len(log)
        
    if upper_bound is not None:
        stop = upper_bound
    else:
        stop = length
    
    # for all desired sizes
    for size in range(2, stop+1):
        print(f"\t{size}/{stop}") # remove later or at least clean up
        subdict = dict()
        for i in range(length+1-size):
            subpath = " ".join(log[i:i+size])
            if subpath in subdict:
                continue
            else:
                subdict[subpath] = 1
                j = i+size
                while (j <= length-size):
                    if subpath == " ".join(log[j:j+size]):
                        subdict[subpath] += 1
                        j += size
                    else:
                        j += 1
                subdict[subpath] = ((subdict[subpath] *size)/length)*100
        database[size] = subdict
        
    return database
    
    
def process_log(log, upper_bound):
    """
    Create a dictionary of all possible subpaths in the log file
    Args:
        list(str) log - the control flow log to parse
        int upper_bound - the maximum subpath size
    Returns:
        The dictionary of all parsed subpaths
    """
    subpaths = dict()
    
    subpaths = count_singles(subpaths, log)
    subpaths = brute_force_subpaths(subpaths, log, upper_bound)
    
    return subpaths


def detect_partial(database, path_one, path_two):
    """
    Determine if partial overlap is valid
    Args:
        dict(int, dict(str, float) database - the dictionary of log subpaths
        list(str) path_one - the first subpath
        list(str) path_two - the second subpath
    Returns:
        Combined - the larger combined path if the subpaths partially overlap and the combined path appears in the database 
        False - otherwise
    """
    index = -1
    str_two = " ".join(path_two)
    for i in range(len(path_one)-1, -1, -1):
        sub_str_one = " ".join(path_one[i:])
        if not (sub_str_one in str_two):
            break
        index=i
    
    combined = path_one[:index] 
    combined.extend(path_two[:])  # Build larger combined path
    combined_len = len(combined)
    if (combined_len in database) and (" ".join(combined) in database[combined_len]): # Check if larger path is a valid subpath
        return (combined, combined_len, database[combined_len][" ".join(combined)])  # If so return combined path and let policy figure out how to handle it
    elif not (combined_len in database):
        return True
    else:
        return False 
                  
                  
def detect_overlap(database, path_one, path_two):
    """
    Detect if two subpaths overlap
    Args:
        dict(int, dict(str, float) database - the dictionary of log subpaths
        list(str) path_one - the first subpath to compare
        list(str) path_two - the second subpath to compare
    Returns:
        True - if one path completely overlaps the other i.e. nested paths
        False - if the paths don't overlap at all
        Combined - the larger combined path if the subpaths partially overlap and the combined path appears in the database 
    """
    length_one = len(path_one)
    length_two = len(path_two)
    
    # Check which subpath is larger 
    if length_one <= length_two:
        if "".join(path_one) in "".join(path_two):  # Check if smaller path is contained in the larger 
            return True
        
        if path_one[0] in path_two: # Check overlap at the end of larger region
            temp = detect_partial(database, path_two, path_one)
            if temp != False:
                return temp
            
        if path_one[-1] in path_two: # Check if overlap at the start of the larger region 
            return detect_partial(database, path_one, path_two)
        else: # otherwise no overlap
            return False
    
    else:  # repeated for other orientation
        if "".join(path_two) in "".join(path_one):
            return True
        
        if path_two[0] in path_one:
            temp = detect_partial(database, path_one, path_two)
            if temp != False:
                return temp
            
        if path_two[-1] in path_one:
            return detect_partial(database, path_two, path_one)
        else:
            return False


def path_comparison_freq(path_a, path_b):
    """
    A comparator for paths. First sorts paths based on their frequency then by their size
    Args:
        (str, int, float) path_a - the first subpath being compared
        (str, int, float) path_b - the second subpath being compared
    Returns:
        Negative value - if path_a is less than path_b 
        0 - if the paths are equal 
        Positive value - if path_a is greater than path_b 
    """
    if path_a[2] != path_b[2]: # if frequency isn't the same
        return path_a[2] - path_b[2] # higher frequency wins
    
    if path_a[1] != path_b[1]: # if lengths aren't the same
        return path_b[1] - path_a[1] # lowest length wins
    
    if path_a[0] != path_b[0]: # lexicographical default for deterministic behavior
        return path_a[0] < path_b[0]
        
    return 0 # otherwise they are equal... im not sure how this could happen

def fetch_subpaths(database, lower_bound, upper_bound):
    """
    Retrives subset of subpaths for greedy algorithms
    Args:
        dict(int, dict(str, float)) database - the subpath dictionary
        int lower_bound - the minimum path size to select
        int upper_bound - the maximum path size to select 
    Returns
        A list of the matching subpaths represented by the tuple (path, size, frequency)
    """
    paths = []
    if lower_bound is not None:
        start = max(lower_bound, 1)
    else:
        start = 1
    
    if upper_bound is not None:
       stop = min(upper_bound+1, len(database.keys())+1)
    else:
       stop = len(database.keys())+1
       
    for i in range(start, stop):
        for key, value in database[i].items():
            paths.append((key.split(), i, value))
    return paths
    
    
def display_paths(paths):
    """
    Builds the output string that is either displayed to std.out or is written to a file
    Args:
        list((list(str), int, float)) paths - A list of subpath tuple representations
    Returns:
        A string representing the results based on the supplied list
    """
    total_size = 0
    total_freq = 0.0
    output_string = f"{len(paths)} Calculated Subpaths\n_______________________________\n"
    for path in paths:
        output_string += f"\t{path[2]} - {' '.join(path[0])}\n"
        total_freq += path[2]
        total_size += path[1]
    output_string += f"\tTotal Frequency: {total_freq}\n\tTotal Size: {(4*total_size) + len(paths)*2}\n"
    return output_string


def list_all(database, lower_bound, upper_bound, max_paths):
    """
    Lists all possible subpaths 
    Args:
        dict(int, dict(str, float)) database - the subpath dictionary
        int lower_bound - the minimum size of paths that can be selected
        int upper_bound - the maximum size of paths that can be selected
        int max_paths - the maximum number of paths to select
    Returns:
        A list of subpaths
    """
    paths =  fetch_subpaths(database, lower_bound, upper_bound)    
    paths = sorted(paths, key=cmp_to_key(path_comparison_freq), reverse=True)
    return paths[:max_paths]
    

def list_unique(database, lower_bound, upper_bound, max_paths, partial):
    """
    Lists all possible subpaths that don't overlap 
    Args:
        dict(int, dict(str, float)) database - the subpath dictionary
        int lower_bound - the minimum size of paths that can be selected
        int upper_bound - the maximum size of paths that can be selected
        int max_paths - the maximum number of paths to select
        bool partial - whether to do additional checks on partially overlapping regions
    Returns:
        A list of subpaths
    """
    paths = fetch_subpaths(database, lower_bound, upper_bound)
    paths = sorted(paths, key=cmp_to_key(path_comparison_freq), reverse=True)
    
    results = [] 
    for path in paths:
        sentinel = 1
        for i in range(len(results)):
            overlap = detect_overlap(database, path[0], results[i][0])
            if partial and isinstance(overlap, tuple):
                sentinel = 0
                if overlap[2] > results[i][2]:
                    results[i] = overlap 
                break
            elif overlap != False:
                sentinel = 0
                break
       
        if sentinel:
            results.append(path)
       
        if len(results) == max_paths:
            break
           
    if partial:
        results = sorted(results, key=cmp_to_key(path_comparison_freq), reverse=True)
   
    return results

def select_paths(database, mem_size, max_paths, partial):
    """
    Select the best path until blockmem is full
    Args:
        dict(int, dict(str, float)) database - the dictionary of cflog subpaths
        int mem_size - the size of block mem in bytes
        int max_paths - the maximum number of paths to select
        bool partial - whether to perform extra checks on partially overlapping regions
    Returns
        A list of subpaths
    """
    results = []
    size_remaining = mem_size
    
    upper_bound = math.floor((mem_size -1)/2)
    paths = fetch_subpaths(database, None, upper_bound)
    paths = sorted(paths, key=cmp_to_key(path_comparison_freq), reverse=True)
    
    for path in paths:
        path_size = (path[1]*4)+2
        if path_size > size_remaining:
            continue
       
        sentinel = 1
        for i in range(len(results)):
            overlap = detect_overlap(database, path[0], results[i][0])
            if partial and isinstance(overlap, tuple):
               sentinel = 0
               size_difference = ((4*overlap[1])+2) - ((4*results[i][1])+2) 
               if size_difference <= size_remaining and overlap[2] > results[i][2]:
                   results[i] = overlap
                   size_remaining -= size_difference
               break
            if overlap != False:
                sentinel = 0
                break
       
        if sentinel:
            results.append(path)
            size_remaining -= path_size
        
        if max_paths is not None and len(results) == max_paths:
            break

    if partial:
        results = sorted(results, key=cmp_to_key(path_comparison_freq), reverse=True)
        
    return results
           

def path_comparison_size(path_a, path_b):
    """
    A comparator for paths. First sorts paths based on their size then by their frequency
    Args:
        (str, int, float) path_a - the first subpath being compared
        (str, int, float) path_b - the second subpath being compared
    Returns:
        Negative value - if path_a is less than path_b 
        0 - if the paths are equal 
        Positive value - if path_a is greater than path_b 
    """
    if path_a[1] != path_b[1]: # if size isn't the same
        return path_b[1] - path_a[1] # smaller size wins
    
    if path_a[2] != path_b[2]: # if frequencies aren't the same
        return path_a[2] - path_b[2] # higher frequency wins
    
    if path_a[0] != path_b[0]: # lexicographical default for deterministic behavior
        return path_a[0] < path_b[0]
        
    return 0 # otherwise they are equal... im not sure how this could happen        

def minimize(database, upper_bound, max_paths, threshold):
    """
    Chooses paths to maximize log reduction with the smallest blocksize possible
    Args:
        dict(int, dict(str, float)) - the dictionary of possible log subpaths
        int upper_bound - the upper limit of subpath lengths to check
        int max_paths - the number of paths to choose
        float threshold - the improvement over overlapping paths to replace a subpath in the results
    Returns:
        a list of selected subpaths
    """

    paths = fetch_subpaths(database, None, upper_bound)
    paths = sorted(paths, key=cmp_to_key(path_comparison_size), reverse=True)

    results = []
    start = 0
    while ((len(results) < max_paths) and start < len(paths)):
        path = paths[start]
        sentinel = 1
        for j in range(len(results)):
            overlap = detect_overlap(database, path[0], results[j][0])
            if overlap != False:
                sentinel = 0
                break
    
        if sentinel:
            results.append(path)
        start += 1

    if start == len(paths):
        return results
    
    visited = set()  # make a set of previously selected paths for ease of check later 
    visited.update("".join(result[0]) for result in results)

    for path in paths[start:]:
        overlapped = []
        overlapped_freq = 0.0
        for i in range(len(results)):  # detec all results the new path overlaps with and tally the combined frequency
            overlap = detect_overlap(database, path[0], results[i][0])
            if overlap != False:
                overlapped.append(i)
                overlapped_freq += results[i][2]
            
        
        if overlapped != []: # if the path overlaps with any results
            if((path[2] - overlapped_freq) > threshold):  # check if new path occurs more frequently then the total of all the results it collides with
                results[overlapped[0]] = path # replace
                visited.add("".join(path[0]))
                restock_idx = max_paths
                for idx in overlapped[1:]: # evict overlapped regions
                    results[idx] = ("a", -1, -1)
                
                for idx in overlapped[1:]:  # refill results with new non overlapping paths
                    while restock_idx < len(paths):
                        sentinel = 1
                        new_path = paths[restock_idx]
                        restock_idx += 1
                        if "".join(new_path[0]) in visited: # skip previously selected paths
                            continue
                        
                        for i in range(len(results)):
                            overlap = detect_overlap(database, new_path[0], results[i][0])
                            if overlap != False:
                                sentinel = 0
                                break
                        
                        if sentinel:
                            results[idx] = new_path
                            visited.add("".join(new_path[0]))
                            break
        
        else: # if no overlap simply compare against least occuring selected path
            if ((path[2] - results[-1][2]) > threshold):
                results[-1] = path
        
        results = sorted(results, key=cmp_to_key(path_comparison_freq), reverse=True) # resort by frequency each round

    return results

def lucky(database, max_paths):
    """
    Chooses paths randomly. Shuffles the list of all subpaths and hands you the top N
    Args:
        dict(int, dict(str, float)) - the dictionary of possible log subpaths
        int max_paths - the number of paths to choose
    Returns:
        a list of 'selected' subpaths
    """
    paths = fetch_subpaths(database, None, None)
    random.shuffle(paths)  # Roll the dice

    results = [] 
    for path in paths: # And choose the first N non-overlapping paths
        sentinel = 1
        for i in range(len(results)):
            overlap = detect_overlap(database, path[0], results[i][0])
            if overlap != False:
                sentinel = 0
                break
       
        if sentinel:
            results.append(path)
       
        if len(results) == max_paths:
            break

    return results
      
def main():

    # data loading
    args = parse_args()
    print(f"Fetching logs from {args.directory}: ", end="")
    previous, master = load_logs(args.directory, args.architecture)
    print("COMPLETE")
    
    print("\nParsing logs for subpaths (This may take a while)")
    subpath_dict = process_log(master, args.max)

    print("\nCalculating appropriate subpaths: ", end="")
    results = []
    if args.algo == "list":
        if args.version == "all":
            results = list_all(subpath_dict, args.lower, args.upper, args.num_paths)
        elif args.version == "unique":
            results = list_unique(subpath_dict, args.lower, args.upper, args.num_paths, args.partial)
    elif args.algo == "select":
        results = select_paths(subpath_dict, args.block_mem_size, args.num_paths, args.partial)
    elif args.algo == "minimize":
        if args.num_paths is None:
            print("\nERROR: --num_paths is required for the minimize algorithm")
            exit(-1)
        results = minimize(subpath_dict, args.upper, args.num_paths, args.threshold)
    elif args.algo == "lucky":
        results = lucky(subpath_dict, args.num_paths)
    
    print("COMPLETE")
    output_string = display_paths(results)
    if args.output is not None:
        with open(args.output, "w") as output_file:
            output_file.write(output_string)
    else:
        print(f"\n{output_string}")
    

if __name__ == "__main__":
    main()

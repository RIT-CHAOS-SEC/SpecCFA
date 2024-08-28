import numpy as np


def extract_non_overlapping_paths(paths_dict):
    # sort paths by decreasing rate
    sorted_paths = sorted(paths_dict.items(), key=lambda x: x[1], reverse=True)
    selected_paths = {}
    for path, rate in sorted_paths:
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


if __name__ == '__main__':

    # example input dictionary
    path_rates = {
        "A-C": 1.0,
        "B-E": 2.0,
        "C-F": 1.5,
        "D-F": 3.0,
        "E-F": 2.0,
        "B-D-C-F": 4.0,
    }


    print("Extracting non-overlapping paths")
    subpaths = extract_non_overlapping_paths(path_rates)
    print(subpaths)
    total_rate = 0
    for x in subpaths:
        total_rate += path_rates[x]
    print("total_rate: "+str(total_rate))
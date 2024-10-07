from architectures import *
from os.path import exists
import pickle

def setup_debug():
    debugFile = open("debug.log", "w")
    print("Debugging\n", file=debugFile)
    print("-----------------------", file=debugFile)
    debugFile.close()

def debug_print(msg):
    debugFile = open("debug.log", "a")
    print(msg, file=debugFile)
    debugFile.close()    

def read_file(file):
    '''
    This function receive the .s file name and read its lines.
    Return : 
        List with the lines of the assembly as strings
    '''
    #assert file.endswith('.s')
    if not(exists(file)) :
        raise NameError(f'File {file} not found !!')
    with open(file,'r') as f :
        lines = f.readlines()
    # Get rid of empty lines
    lines = [x.replace('\n','') for x in lines if x != '\n']

    # ARM: Get rid of ".word" lines
    lines = [x for x in lines if ".word" not in x]

    return lines

def set_arch(arch):
    if arch == 'elf32-msp430':
        return MSP430() 
    elif arch == 'armv8-m33':
        return ARMv8M33() 
    else: 
        return None

def load(filename):
    f = open(filename,'rb')
    obj = pickle.load(f)
    f.close()
    return obj

def dump(obj, filename):
    filename = open(filename, 'wb')
    pickle.dump(obj, filename)
    filename.close()


def get_init_challenge(chal_size):
    challenge = []
    for i in range(0, chal_size):
        challenge.append(0)
    return challenge

def get_next_challenge(prev_chal, chal_size, report_num):
    if report_num == 0:
        new_chal = []
        for i in range(0, chal_size):
            new_chal.append((65+i).to_bytes(1,byteorder='big'))
        new_chal = b''.join(new_chal)
        return new_chal
    else:
        new_chal = (prev_chal[0]+1).to_bytes(1,byteorder='big')+prev_chal[1:]
        return new_chal

def swap_endianess(a):
    if type(a) == type(b'\x00'):
        i = 0
        swp = []
        while i < len(a):
            swp.append(a[i+1].to_bytes(1,byteorder='big'))
            swp.append(a[i].to_bytes(1,byteorder='big'))
            i += 2
        return b''.join(swp)

    if type(a) == type([]):
        i = 0
        while i < len(a):
            tmp = a[i]
            a[i] = a[i+1]
            a[i+1] = tmp
            i += 2
        return a


def detect_intersect(alst, blst, first=0):
    if alst[0] in blst:
        count = 0
        aidx = 0
        counting = False
        for b in blst:
            if b == alst[aidx]:
                count += 1
                counting = True
                aidx += 1
            elif b != alst[aidx] and counting:
                counting = False
        return count
    elif alst[-1] in blst:
        count = 0
        aidx = len(alst)-1
        counting = False
        for bidx in range(1, len(blst)+1):
            b = blst[len(blst)-bidx]
            if b == alst[aidx]:
                count += 1
                counting = True
                aidx -= 1
            elif b != alst[aidx] and counting:
                counting = False
        return count
    elif first == 0:
        return detect_intersect(blst, alst, 1)
    else:
        return 0

def custom_sort(dictionary, hex_ranges):
    def key_function(item):
        # Extract the numerical value from the dictionary key
        num_value = int(item[1][0], 16)
        ranges = [(int(start, 16), int(end, 16)) for start, end in hex_ranges]

        # Find the first range that contains the numerical value
        for i, r in enumerate(ranges):
            if r[0] <= num_value <= r[1]:
                return i  # Return the index of the first range

        # If no range is found, return a very high value
        return float('inf')

    # Sort the dictionary items using the custom key function
    sorted_dict = sorted(dictionary.items(), key=key_function)

    return dict(sorted_dict)

if __name__ == '__main__':
    # # middle, last
    # alst = ['a', 'b', 'e', 'f', 'g']
    # blst = ['c', 'd', 'e', 'f']
    # total = detect_intersect(alst, blst)
    # print(total)

    # # front, last
    # alst = ['a', 'b', 'e', 'f', 'g']
    # blst = ['c', 'd', 'a', 'b']
    # total = detect_intersect(alst, blst)
    # print(total)

    # # last, last
    # alst = ['z', 'a', 'b', 'e', 'f', 'g']
    # blst = ['c', 'd', 'f', 'g']
    # total = detect_intersect(alst, blst)
    # print(total)

    # # middle, middle
    # alst = ['f', 'a', 'b', 'e', 'g']
    # blst = ['c', 'a', 'b', 'z']
    # total = detect_intersect(alst, blst)
    # print(total)

    # # middle, front
    # alst = ['f', 'a', 'b', 'e', 'g']
    # blst = ['a', 'b', 'z', 'c']
    # total = detect_intersect(alst, blst)
    # print(total)

    # # front, front
    # alst = ['a', 'b', 'e', 'g']
    # blst = ['a', 'b', 'z', 'c']
    # total = detect_intersect(alst, blst)
    # print(total)

    # Example usage:
    my_dict = {
        'A1': ['0x50', '0x55'],
        'B1': ['0x30', '0x40'],
        'C1': ['0x5', '0x15'],
        'D1': ['0x25', '0x35'],
    }

    my_ranges = [('0x0', '0x20'), ('0x21', '0x45')]

    result = custom_sort(my_dict, my_ranges)
    for r in result:
        print(r)
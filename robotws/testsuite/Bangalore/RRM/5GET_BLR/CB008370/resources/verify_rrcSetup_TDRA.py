import os
import re

lookup3 = 'pdsch-TimeDomainAllocationList setup'
lookup4 = 'prb-BundlingType staticBundling :'
TDRA_8370 = [97, 98, 70, 56, 83, 55, 27, 41, 43]


def check_rrcsetup_msg_tdra(file_name, stamp):
    path = file_name
    print(file_name)
    line_list3 = []
    line_list4 = []
    with open(path, "r") as myFile:
        for num, line in enumerate(myFile, 1):
            if lookup3 in line:
                line_list3.append(num)
            elif lookup4 in line:
                line_list4.append(num)
    print(line_list3)
    print(line_list4)

    loop = 1
    for (i, j) in zip(line_list3, line_list4):
        with open(file_name, "r") as myFile:
            with open("RrcSetup_MSG_TDRA.txt", "a+") as f:
                f.writelines(myFile.readlines()[i:j])
                f.close()
                dst = "RrcSetup_MSG_" + str(stamp) + str(loop) + ".txt"
                loop = loop + 1
                print("\nDST ", dst, os.getcwd())
                os.rename("RrcSetup_MSG_TDRA.txt", dst)
    myFile.close()


def validate_tdra(file_name, flag):
    pattern = "startSymbolAndLength"
    file = open(file_name, "r")
    tdra_list = []
    for line in file:
        if re.search(pattern, line):
            tdra_list.append(line)
    print(tdra_list)
    res = [int(sub.split('startSymbolAndLength ')[1]) for sub in tdra_list]
    print("The list after Extracting numbers : " + str(res))
    print("List", res)
    if any(x in TDRA_8370 for x in res):
        print("Duplicates found.")
        if int(flag) == 1:
            print("8370 SLIV found")
            return True
        else:
            return False
    else:
        print("No duplicates found.")
        if int(flag) == 0:
            print("NO 8370 related SLIV found")
            return True
        else:
            return False

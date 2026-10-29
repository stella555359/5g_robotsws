import os
import re
import itertools

lookup1 = 'criticalExtensions rrcReconfiguration :'
lookup3 = 'message c1 : rrcSetup :'
lookup4 = 'message c1 : rrcSetupComplete :'
line_list1 = []
line_list2 = []
line_list3 = []
line_list4 = []


def check_reconfig_msg(file_name, flag):
    path = file_name
    if (int(flag) > 0):
        lookup2 = 'message c1 : rrcReconfigurationComplete :'
    else:
        lookup2 = 'Successfully reconfigured dual connectivity'
    with open(path, "r") as myFile:
        for num, line in enumerate(myFile, 1):
            if lookup1 in line:
                line_list1.append(num)
            elif lookup2 in line:
                line_list2.append(num)
#    print(line_list1)
#    print(line_list2)
    loop = 1
    for (i, j) in zip(line_list1, line_list2):
        with open(path, "r") as myFile:
            with open("Reconfig_MSG.txt", "a+") as f:
                f.writelines(myFile.readlines()[i:j])
                f.close()
                dst = "Reconfig_MSG_"+str(loop) + ".txt"
                loop = loop + 1
                print("\nDST ", dst, os.getcwd())
                os.rename("Reconfig_MSG.txt", dst)
    myFile.close()


def check_rrcsetup_msg(file_name):
    path = file_name
#    path = r'/opt/iphy/latest/egate_console.log'
    with open(path, "r") as myFile:
        for num, line in enumerate(myFile, 1):
            if lookup3 in line:
                line_list3.append(num)
            elif lookup4 in line:
                line_list4.append(num)
#    print(line_list3)
#    print(line_list4)

    loop = 1
    for (i, j) in zip(line_list3, line_list4):
        with open(file_name, "r") as myFile:
            with open("RrcSetup_MSG.txt", "a+") as f:
                f.writelines(myFile.readlines()[i:j])
                f.close()
                dst = "RrcSetup_MSG_"+str(loop) + ".txt"
                loop = loop + 1
                print("\nDST ", dst, os.getcwd())
                os.rename("RrcSetup_MSG.txt", dst)
    myFile.close()

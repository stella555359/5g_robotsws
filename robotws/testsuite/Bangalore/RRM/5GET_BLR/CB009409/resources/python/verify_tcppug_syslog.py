import re
import sys
import pkgutil
import subprocess
import importlib

TCP_PUG_UE_ELIG = 'TCP PUG Ue Eligibility Check Passed'
search_term = 'TCP PUG Ue Eligibility Check Passed'
Enter_RampUp = 'entering state: pugRampupInitialWaitState'
CS1_Entry = 'CS1 Entry for TCP PUG'
TCPBOOSTPUG = 'TCPBOOSTPUG'
Expire_Rampup = 'Rampup duration expire, moving to stable'
Enter_Stable = 'entering state: pugStableState'
search_term_8 = 'entering state: pugIdleState'
search_term_3 = 'entering state: pugRampupState'
file1 = open("TCPBOOSTPUG.txt", "w")  # TCPBOOSTPUG logs
file4 = open("ramup.csv", "w")
file5 = open("stable.csv", "w")
list = []


def install_package(package):
    try:
        subprocess.call(['pip', 'install', '-U', 'numpy', package])
    except Exception as e:
        raise (AssertionError("Error installing package " + str(e)))


def is_pandas_installed():
    return bool(pkgutil.find_loader('pandas'))


def install_and_import_pandas():
    print("pandas library installation")
    if not is_pandas_installed():
        install_package('pandas')
    return importlib.import_module('pandas')


def tcppug_syslog(syslog_file):
    # Get all TCPBOOSTPUG logs
    copy_line = 0
    file1 = open("TCPBOOSTPUG.txt", "w")  # TCPBOOSTPUG logs
    for line in open(syslog_file, 'r'):
        if re.search(TCPBOOSTPUG, line):
            #        print (line)
            file1.writelines(line)
            if line is None:
                print('no matches found')
    file1.close()

    file2 = open("rampup.txt", "w")
    file3 = open("stable.txt", "w")
    with open('TCPBOOSTPUG.txt') as myFile:
        for num, line in enumerate(myFile, 1):
            if Enter_RampUp in line:
                print('found Enter_RampUp at line:', num)
                copy_line = 1
            elif Expire_Rampup in line:
                print('found Expire_Rampup at line:', num)
                copy_line = 2
            elif Enter_Stable in line:
                print('found Enter_Stable at line:', num)
                copy_line = 3
            if copy_line == 1 or copy_line == 2:
                file2.writelines(line)
                if copy_line == 2:
                    copy_line = 0
            elif copy_line == 3:
                file3.writelines(line)
    file2.close()
    file3.close()

    # Count PUG in ramup duration
    file4 = open("ramup.csv", "w")
    for line in open('rampup.txt', 'r'):
        if re.search(CS1_Entry, line):
            #        print (/line)
            phoneNumRegex = re.compile(r'Time:.*NrCell:')
            x = phoneNumRegex.search(line)
            print(re.split('Time:', x.group()))
            # print(x.group())
            # file4.writelines(x.group())
            file4.writelines(re.split('Time:', x.group()))
            file4.writelines("\n")
    file1.close()
    file4.close()

    install_and_import_pandas()
#    input_file = 'ramup.csv'
    import pandas as pd
    data = pd.read_csv("ramup.csv", header=None)
    # print(data)
    data.rename(columns={0: 'SFN_slot'}, inplace=True)
    data[['SFN', 'slot']] = data['SFN_slot'].str.split('/', expand=True)
    # print(data)
    output_path = "output_rampup.csv"
    data.to_csv(output_path, index=False)

    # Count
    print("Ramp_up", data['SFN_slot'].count())
    list.append(data['SFN_slot'].count().tolist())

    # Stable_Duration
    file5 = open("stable.csv", "w")
    for line in open('stable.txt', 'r'):
        if re.search(CS1_Entry, line):
            #        print (line)
            phoneNumRegex = re.compile(r'Time:.*NrCell:')
            x = phoneNumRegex.search(line)
            print(re.split('Time:', x.group()))
            # print(x.group())
            file5.writelines(re.split('Time:', x.group()))
            file5.writelines("\n")
    # file1.close()
    file5.close()

    data = pd.read_csv("stable.csv", header=None)
    # print(data)
    data.rename(columns={0: 'SFN_slot'}, inplace=True)
    data[['SFN', 'slot']] = data['SFN_slot'].str.split('/', expand=True)
    # print(data)
    output_path = "output_stable.csv"
    data.to_csv(output_path, index=False)

    # Count
    print("Stable:", data['SFN_slot'].count())
    Stable_count = data['SFN_slot'].count()
    list.append(Stable_count.tolist())
    print(list)
    return list

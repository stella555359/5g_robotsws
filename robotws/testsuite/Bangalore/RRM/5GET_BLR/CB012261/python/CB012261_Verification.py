import subprocess
import pkgutil
import importlib
import os


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


def is_tkinter_installed():
    return bool(pkgutil.find_loader('tkinter'))


def install_and_import_tkinter():
    print("tkinter library installation")
    if not is_tkinter_installed():
        install_package('tkinter')
    return importlib.import_module('tkinter')


def merge_multiple_csv(filepath, dire):
    pd = install_and_import_pandas()
    df_list = []
    csv_file_list = sorted(os.listdir(filepath))
    print("csv file", csv_file_list)

    for i in range(0, len(csv_file_list)):
        if 'output_'+dire+'_formated_' + str(i) + '.csv' in csv_file_list:
            file = 'output_'+dire+'_formated_' + str(i) + '.csv'
            print('file', file)
            df_list.append(pd.read_csv(os.path.join(filepath, file), low_memory=False))
            os.remove(os.path.join(filepath, file))
    df = pd.concat(df_list, ignore_index=True)
    filename = 'output_' + dire + '_formated.csv'
    df.to_csv(os.path.join(filepath, filename), index=False)


def syslog_search(filename, search_strings):

    try:
        with open(filename, 'r') as file:
            lines = file.readlines()
        wrn_results = []
        err_results = []
        for line in lines:
            for search_string in search_strings:
                if search_string in line:
                    if search_string == 'WRN/':
                        wrn_results.append(line)
                    elif search_string == 'ERR/':
                        err_results.append(line)

        # Export results to CSV file
        directory_path, file_path = os.path.split(filename)
        txt_file_path = os.path.join(directory_path, 'filtered_syslog.txt')
        print("txt_file_path: ", txt_file_path)
        with open(txt_file_path, 'w') as filtered_syslog:
            if wrn_results:
                filtered_syslog.write('Results for \'WRN/\':\n')
                for line in wrn_results:
                    filtered_syslog.write(line.strip() + '\n')
            else:
                filtered_syslog.write('No \'WRN/\' results found.\n')

            if err_results:
                filtered_syslog.write('Results for \'ERR/\':\n')
                for line in err_results:
                    filtered_syslog.write(line.strip() + '\n')
            else:
                filtered_syslog.write('No \'ERR/\' results found.\n')

    except FileNotFoundError:
        print("File not found:", filename)


def Verify_2prb_CB012261(
        file_path,
        celltype,
        pucchFormat,
        prachFormat,
        frame_structure,
        cell_id,
        ulBW,
        prachPrbOffset,
        msg1Fdm,
        CB012261_flag):
    pd = install_and_import_pandas()
    directory_path, filename = os.path.split(file_path)
    print("directory_path: ", directory_path)

    # Read the CSV file
    col = [
        'type',
        'timeStamp',
        'sfn',
        'slot',
        'rnti',
        'physCellId',
        'numOfPrb',
        'startPrb',
        'SLIV',
        'dciFormat',
        'requiredPrb',
        'rrmMaxNumPrbUl',
        'searchSpaceId',
        'searchSpaceType',
        'startCce',
        'tbSize',
        'txNumber',
        'currentUeDataRate']
    ws = pd.read_csv(file_path, low_memory=False, usecols=col)
    df = pd.DataFrame()
    # Filter TTI trace
    if celltype == 'TDD':
        if frame_structure == "3_7":
            df = ws[(ws['type'] == 'ulFdSchedData') & (ws['physCellId']
                                                       == cell_id) & ((ws['slot'] == 8) | (ws['slot'] == 9))]
            frame_structure = 'TDD_3_7'
        elif frame_structure == "1_4":
            df = ws[(ws['type'] == 'ulFdSchedData') & (ws['physCellId'] == cell_id) & (
                (ws['slot'] == 9) | (ws['slot'] == 19)) & (ws['sfn'] % 2 == 1)]
            frame_structure = 'TDD_1_4'
        elif frame_structure == "td_lte":
            df = ws[(ws['type'] == 'ulFdSchedData') & (ws['physCellId'] == cell_id) &
                    (ws['slot'] == 19) & (ws['sfn'] % 8 != 6) & (ws['sfn'] % 8 != 7)]
            frame_structure = 'td_lte'
        elif frame_structure == "UL_MIMO":
            df = ws[(ws['type'] == 'ulFdSchedData') & (ws['physCellId'] == cell_id) & (
                 (ws['slot'] == 19)) & (ws['sfn'] % 2 == 1)]
            frame_structure = 'UL_MIMO'
        elif frame_structure == "semi_1_4":
            df = ws[(ws['type'] == 'ulFdSchedData') & (ws['physCellId'] == cell_id) & (
                 (ws['slot'] == 19)) & (ws['sfn'] % 2 == 1)]
            frame_structure = 'semi_1_4'

    else:
        # FDD part
        if frame_structure == "0_12":
            df = ws[(ws['type'] == 'ulFdSchedData') & (ws['physCellId']
                                                       == cell_id) & (ws['slot'] == 1) & (ws['sfn'] % 2 == 1)]
            frame_structure = 'FDD_0_12'
        elif frame_structure == "1_42":
            df = ws[(ws['type'] == 'ulFdSchedData') & (ws['physCellId'] == cell_id) & (
                (ws['slot'] == 7) | (ws['slot'] == 8) | (ws['slot'] == 9)) & (ws['sfn'] % 2 == 1)]
            frame_structure = 'FDD_1_42'
        elif frame_structure == "0_13":
            df = ws[(ws['type'] == 'ulFdSchedData') & (ws['physCellId'] == cell_id) & (
                (ws['slot'] == 4)) & (ws['sfn'] % 2 == 1)]
            frame_structure = 'FDD_0_13'
        elif frame_structure == "DSS":
            df = ws[(ws['type'] == 'ulFdSchedData') & (ws['physCellId'] == cell_id) & (
                (ws['slot'] == 1)) & (ws['sfn'] % 2 == 1)]
            frame_structure = 'DSS'

    df.to_csv(
        directory_path +
        "/UL_modified_ttitrace_" +
        frame_structure +
        "_Cell_" +
        str(cell_id) +
        '.csv')
    nbrOfPrbPerRachOccasion = 0
    if celltype == 'TDD':
        if prachFormat == 'longprach':
            nbrOfPrbPerRachOccasion = 3
        elif prachFormat == 'shortprach':
            nbrOfPrbPerRachOccasion = 12
    elif celltype == 'FDD':
        nbrOfPrbPerRachOccasion = 6

    print(
        "nbrOfPrbPerRachOccasion for prachFormat = " +
        prachFormat +
        " & celltype = " +
        celltype +
        " is :",
        nbrOfPrbPerRachOccasion)
    LAbovePrach = ulBW - prachPrbOffset - (nbrOfPrbPerRachOccasion * msg1Fdm)
    LBelowPrach = prachPrbOffset
    print("LAbovePrach:", LAbovePrach)
    print("LBelowPrach:", LBelowPrach)
    FeatEnabled = max(LAbovePrach, LBelowPrach)
    Featdisabled = max(LAbovePrach - 2, LBelowPrach - 2)
    print("FeatEnabled:", FeatEnabled)
    print("Featdisabled:", Featdisabled)

    # Calculate MaxNumOfPrb
    MaxNumOfPrb = df['numOfPrb'].max()
    print("MaxNumOfPrb:", MaxNumOfPrb)

    # Check condition 1
    CB012261 = CB012261_flag
    if CB012261 == "Enabled" and pucchFormat == 'longpucch':
        if MaxNumOfPrb == FeatEnabled:
            print("MaxNumOfPrb is equal to FeatEnabled")
        else:
            print("MaxNumOfPrb is not equal to FeatEnabled")
            return 'Fail'
    elif CB012261 == "Enabled" and pucchFormat == 'shortpucch':
        if MaxNumOfPrb == Featdisabled:
            print("MaxNumOfPrb is equal to FeatEnabled")
        else:
            print("MaxNumOfPrb is not equal to FeatEnabled")
            return 'Fail'
    elif CB012261 == "Disabled":
        if MaxNumOfPrb == Featdisabled:
            print("MaxNumOfPrb is equal to Featdisabled")
        else:
            print("MaxNumOfPrb is not equal to Featdisabled")
            return 'Fail'

    # Check condition 2
    startPrb_values = df['startPrb']
    prach_upperBoundary = prachPrbOffset + nbrOfPrbPerRachOccasion - 1
    print("prach_upperBoundary: ", prach_upperBoundary)
    for val in startPrb_values:
        if LBelowPrach <= val <= prach_upperBoundary:
            with open(directory_path + "/FAIL_logs_startPrb_is_in_PRACH_region_Cell_" + str(cell_id) + ".csv",
                      "a") as f:  # "a" is to append to csv
                f.write(
                    "FAIL--> startPrb :" +
                    str(val) +
                    " is in the PRACH region (" +
                    str(LBelowPrach) +
                    " & " +
                    str(prach_upperBoundary) +
                    ")\n")  # Add newline character
            return 'Fail'
        else:
            with open(directory_path + "/PASS_logs_startPrb_not_in_PRACH_region_Cell_" + str(cell_id) + ".csv",
                      "a") as f:  # "a" is to append to csv
                f.write(
                    "PASS--> startPrb :" +
                    str(val) +
                    " is not in the PRACH region (" +
                    str(LBelowPrach) +
                    " & " +
                    str(prach_upperBoundary) +
                    ")\n")  # Add newline character
    return 'Pass'


def Filter_TTitrace(
        file_path,
        dir,
        cell_id,
        column):
    col = column
    pd = install_and_import_pandas()
    directory_path, filename = os.path.split(file_path)
    print("directory_path: ", directory_path)
    ws = pd.read_csv(file_path, low_memory=False, usecols=col)
    df = ws[(ws['type'] == 'ulFdSchedData') & (ws['physCellId']
                                               == cell_id)]
    df.to_csv(
        directory_path +
        "/" + dir + "_modified_ttitrace_" +
        str(cell_id) +
        '.csv')

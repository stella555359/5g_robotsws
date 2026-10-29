# import pandas as pd
import subprocess
import pkgutil
import importlib


def install_package(package):
    try:
        subprocess.call(['pip', 'install', '-U', 'numpy', package])
    except Exception as e:
        raise (AssertionError("Error installing package " + str(e)))


def is_pandas_installed():
    return bool(pkgutil.find_loader('pandas'))


def install_and_import_pandas():
    if not is_pandas_installed():
        install_package('pandas')
    return importlib.import_module('pandas')


def check_msg2_sib1_osi(csv_file):
    pd = install_and_import_pandas()
    df = pd.read_csv(csv_file, low_memory=False)
    a = df[df["DlData_DciInfoL1sw.rachStatus"] == "0,2"]
    a = a.reset_index(drop=True)
    count1 = 0
    count2 = 0
    count3 = 0
    for i in range(a.index.max()):
        i_sfn = a.loc[i, "3gpp.sfn"]
        i_slot = a.loc[i, "3gpp.slot"]
        i_col = a.loc[i, "_ws.col.number"]

        for j in range(df.index.max()):
            if df.loc[j, "_ws.col.number"] in range(i_col - 10, i_col + 10) and \
                    df.loc[j, "3gpp.sfn"] == i_sfn and df.loc[j, "3gpp.slot"] == i_slot:
                if df.loc[j, "nr-rrc.c1"] == 1:
                    count1 += 1
                if df.loc[j, "nr-rrc.c1"] == 0:
                    count2 += 1
                if df.loc[j, "DlData_PdschGrantL1sw.rachStatus"] == 0:
                    startprb_0 = df.loc[j, "DlData_PdschGrantL1sw.startPrb"]
                    numofprb_0 = df.loc[j, "DlData_PdschGrantL1sw.numOfPrb"]
                if df.loc[j, "DlData_PdschGrantL1sw.rachStatus"] == 2:
                    startprb_2 = df.loc[j, "DlData_PdschGrantL1sw.startPrb"]
                    numofprb_2 = df.loc[j, "DlData_PdschGrantL1sw.numOfPrb"]

        if startprb_0+numofprb_0 == startprb_2 or startprb_2+numofprb_2 == startprb_0:
            count3 += 1
    if count1 >= 1 and count2 >= 1 and count3 == count1+count2:
        result = 'True'
    else:
        result = 'False'
    print(count1, count2, count3, result)
    return result


if __name__ == '__main__':
    check_msg2_sib1_osi("5GBipL2L1_filtering_off.csv")

import csv
import os
import subprocess
import pkgutil
import importlib
import time
from datetime import datetime
import math


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


def check_adaptive_retrans(file_name, CellId):
    rntilist = getblerrntilist(file_name, CellId)
    count = 0
    for rnti in rntilist:
        print("checking rnti:", rnti)
        status = rnti_adaptive_retrans(file_name, CellId, rnti)
        print(f"rnti: {rnti} adaptive retransmission status is {status}")
        if status is False:
            count += 1
    if count == 0:
        return True
    else:
        return False


def rnti_adaptive_retrans(file_name, CellId, rnti):
    flag = 0
    path = os.path.dirname(file_name)
    fp = open(os.path.join(path, "adaptive.txt"), 'a')
    dlHarqProcessTable = [[], [], [], [], [], [], [], [], [], [], [], [], [], [], [], []]
    with open(file_name) as csv_file:
        csv_reader = csv.DictReader(csv_file)
        header = csv_reader.fieldnames
        for line in csv_reader:
            if ('type' in header and line['type'] == 'dlFdSchedData') and\
               ('physCellId' in header and line['physCellId'] == CellId) and\
               ('rnti' in header and line['rnti'] == rnti):
                dlHarqProcessIndex = int(float(line["dlHarqProcessIndex"]))
                dlHarqProcessTable[dlHarqProcessIndex].append(line)
    for harqProcessId in range(0, 16):
        lastxnum = 1
        dummy = {}
        print(f"harqProcessId: {harqProcessId}", file=fp)
        for dlFdSchedEvents in dlHarqProcessTable[harqProcessId]:
            sfn = dlFdSchedEvents["sfn"]
            slot = dlFdSchedEvents["slot"]
            rrmDlUsedMcs = int(float(dlFdSchedEvents["rrmDlUsedMcs"]))
            numOfPrb = int(float(dlFdSchedEvents["numOfPrb"]))
            tbSize = dlFdSchedEvents["tbSize"]
            txnumber = int(float(dlFdSchedEvents["txNumber"]))
            adaptRetxStatus = dlFdSchedEvents["adaptRetxStatus"]
            print(f"rnti {rnti} sfn:{sfn}/slot:{slot}, harqid:{harqProcessId}, txnumber:{txnumber}, "
                  f"tbSize:{tbSize}, adaptRetxStatus:{adaptRetxStatus}", file=fp)
            if txnumber > lastxnum:
                lastxnum += 1
                dummy.update({txnumber: {"status": adaptRetxStatus, "nofprb": numOfPrb, "usedmcs": rrmDlUsedMcs}})
            if txnumber < lastxnum:
                status = checkadaptive(dummy, fp)
                if status is False:
                    flag += 1
                print(status, file=fp)
                dummy.clear()
                dummy.update({txnumber: {"status": adaptRetxStatus, "nofprb": numOfPrb, "usedmcs": rrmDlUsedMcs}})
            if txnumber == lastxnum:
                dummy.update({txnumber: {"status": adaptRetxStatus, "nofprb": numOfPrb, "usedmcs": rrmDlUsedMcs}})
            lastxnum = txnumber
    if flag == 0:
        return True
    else:
        return False


def checkadaptive(dummy, filename):
    status = True
    default = {}
    print(dummy, file=filename)
    reservedmsc = [28, 29, 30, 31]
    txid = list(dummy.keys())
    if 1 in txid:
        for i in dummy:
            if dummy[i]["status"] == "NOTACTIVATE":
                default.update({"nofprb": dummy[i]["nofprb"], "usedmcs": dummy[i]["usedmcs"]})
    else:
        print("there is no initial transmission information so checking further", file=filename)
        return status
    for ele in dummy:
        if dummy[ele]["status"] == "APPLY":
            if dummy[ele]["nofprb"] > default["nofprb"]:
                print("retransmission taking more prb than initial transmission", file=filename),
                print(f"initial transmission prb:{default['nofprb']} retransmission prb:{dummy[ele]['nofprb']}",
                      file=filename)
                status = False
            if dummy[ele]["usedmcs"] not in reservedmsc:
                print(f"reserved mcs is not used, used mcs is {dummy[ele]['usedmcs']}", file=filename)
                print(f"used mcs: {dummy[ele]['usedmcs']}, may used initial mcs {default['usedmcs']}", file=filename)
                if dummy[ele]["usedmcs"] != default['usedmcs']:
                    print(f"initial mcs is not used, used mcs is {dummy[ele]['usedmcs']}", file=filename)
                    status = False
    return status


def getblerrntilist(file_name, CellId):
    rnti = []
    with open(file_name) as csv_file:
        csv_reader = csv.DictReader(csv_file)
        header = csv_reader.fieldnames
        for line in csv_reader:
            if ('type' in header and line['type'] == 'dlFdSchedData') and\
               ('physCellId' in header and line['physCellId'] == CellId) and\
               ('txNumber' in header and line['txNumber'] != '1.0'):
                rnti.append((line['rnti']))
    return list(set(rnti))


def check_randomization_multi_bwp(file_name, CellId, bwpdict):
    pd = install_and_import_pandas()
    path = os.path.dirname(file_name)
    fp = open(os.path.join(path, "randamization.txt"), 'a')
    pd.set_option('display.max_rows', None)
    pd.set_option('display.max_columns', None)
    pd.set_option('display.width', None)
    pd.set_option('display.max_colwidth', None)
    bwplist = list(bwpdict.keys())
    df_list = []
    df = pd.read_csv(file_name, low_memory=False)
    df = df[['type', 'timeStamp', 'sfn', 'slot', 'rnti', 'physCellId',
             'numOfPrb', 'startPrb', 'dciFormat', 'cellBwpId']]
    df = df[(df['type'] == 'dlFdSchedData') & (df['physCellId'] == 50) & (df['rnti'] != '65535')]
    df = df.astype({"sfn": "int", "slot": "int", 'rnti': "int", 'physCellId': "int",
                    'numOfPrb': "int", 'startPrb': "int", 'cellBwpId': "int"})
    for sfn, slot in zip(df.sfn, df.slot):
        asfn = str(sfn) + '-' + str(slot)
        df_list.append(asfn)
    df.insert(2, "asfn", df_list, True)
    prev_asfn = 0
    randomflag = 0
    perslot = 0
    rat1 = True
    for asfn in df.asfn:
        if prev_asfn != asfn:
            df1 = df[df['asfn'] == asfn]
            perslot += 1
            print(f"======================{asfn}=============================", file=fp)
            print(df1, file=fp)
            usedprb = startprb = endprb = tempend = totalprb = 0
            temprand = True
            for cellbwp in bwpdict:
                df1_new = df1[df1['cellBwpId'] == cellbwp]
                df1_new = df1_new.sort_values(by=['startPrb']).reset_index()
                col = df1_new.shape[0]
                if col > 0:
                    startprb = df1_new['startPrb'].min()
                    df1_new['endPrb'] = df1_new['startPrb'] + df1_new['numOfPrb'] - 1
                    endprb = df1_new['endPrb'].max()
                    totalprb = df1_new['numOfPrb'].sum()
                rat1_alloc_bitmap = [0] * bwpdict[bwplist[2]][1]
                if totalprb + usedprb == bwpdict[cellbwp][1]:
                    print(f"all prb are used in cellbwp {cellbwp} no randomization will trigger", file=fp)
                else:
                    if col >= 1:
                        if cellbwp == bwplist[0] and (0 == startprb and totalprb == bwpdict[bwplist[0]][1]):
                            print("start prb is 0, in small bwp and all resource used", file=fp)
                            temprand = False
                        if cellbwp == bwplist[1] and bwpdict[bwplist[0]][1] == tempend+1 == startprb:
                            print("no randamization between small to midium", file=fp)
                            temprand = False
                        if cellbwp == bwplist[2] and bwpdict[bwplist[1]][1] == tempend+1 == startprb:
                            print("no randamization between midium to large", file=fp)
                            temprand = False
                    else:
                        print("No Ues are scheduled in cellbwp", cellbwp, file=fp)
                tempend = endprb
                if col > 1:
                    if 'DL_11' in set(list(df1_new.dciFormat)) and len(set(list(df1_new.dciFormat))) == 1:
                        large_bwp_psa1_region = rat1_alloc_bitmap[0:]
                        large_bwp_psa2_region = []
                        result = rat1_allocation_without_randomization(df1_new, large_bwp_psa1_region,
                                                                       large_bwp_psa2_region,
                                                                       rat1bitmap=rat1_alloc_bitmap)
                        if result == 'Fail':
                            rat1 = False
                usedprb += totalprb
                print(f"cellbwp:{cellbwp}, startprb:{startprb}, endprb:{endprb}, allocatedprb:{totalprb}", file=fp)
            print(f"randamization triggered in {asfn} is {temprand}", file=fp)
            if temprand is True:
                randomflag += 1
        prev_asfn = asfn
    perentage = randomflag/perslot * 100
    print(perentage, "randamization triggered")
    if perentage > 50:
        randomflag = True
    else:
        randomflag = False
    return randomflag and rat1


def rat1_allocation_without_randomization(df, psa1, psa2, rat1bitmap=None, filename=None):
    if len(psa1) >= len(psa2):
        print("As size of both Sub-Areas are same, Allocation will start from bottom PRB. In our code it will be PSA1",
              file=filename)
        for i in range(len(df['startPrb'].index)):
            x = df.iloc[i]['startPrb']
            y = df.iloc[i]['numOfPrb']
            psa1[x: y] = [1] * y
        expectedallocation = [1] * df['numOfPrb'].sum()
        allocatedprb = psa1[df.iloc[0]['startPrb']: df.iloc[0]['startPrb'] + df['numOfPrb'].sum()]
        if allocatedprb == expectedallocation and len(allocatedprb) <= len(psa1):
            print("========RAT1 Allocation happend continuously in PSA1========", file=filename)
            print(df, file=filename)
            print('After Allocation', psa1, file=filename)
            print('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n', file=filename)
        else:
            print("========RAT1 Allocation discontinuous large_bwp_psa1_region========", file=filename)
            print(df, file=filename)
            print("After allocation large_bwp_psa1_region", psa1, file=filename)
            print('###############-FAIL-######################\n', file=filename)
            return 'Fail'

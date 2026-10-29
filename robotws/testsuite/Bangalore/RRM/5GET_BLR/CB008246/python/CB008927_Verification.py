import subprocess
import pkgutil
import importlib
import os
import time
from datetime import datetime
import math
# import pandas as pd


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


def verify_rat1_alocation(filepath, *physcellid):
    pd = install_and_import_pandas()
    df = pd.read_csv(filepath, low_memory=False)
    df1 = df[(df['type'] == 'dlFdSchedData') & (df['physCellId'].isin(physcellid)) & (df['dciFormat'] == 'DL_11')]
    print("Get rat0Bitmap Values", df1.rat0Bitmap.unique())
    if 0 in df1.rat0Bitmap.unique():
        return 'Pass'
    else:
        return 'Fail'


def merge_multiple_csv(filepath, dire):
    pd = install_and_import_pandas()
    df_list = []
    csv_file_list = sorted(os.listdir(filepath))
    print("csv file", csv_file_list)

    for i in range(0, len(csv_file_list)):
        if 'output_' + dire + '_formated_' + str(i) + '.csv' in csv_file_list:
            file = 'output_' + dire + '_formated_' + str(i) + '.csv'
            print('file', file)
            df_list.append(pd.read_csv(os.path.join(filepath, file), low_memory=False))
            os.remove(os.path.join(filepath, file))
    df = pd.concat(df_list, ignore_index=True)
    filename = 'output_' + dire + '_formated.csv'
    df.to_csv(os.path.join(filepath, filename), index=False)


class AutoDict(dict):
    def __missing__(self, k):
        self[k] = AutoDict()
        return self[k]


def validation_of_rat1_allocation(filepath, cellid, celltype, initial_bwp, ded_bwp,
                                  ssb_start_position, prbrandom=False,
                                  prbblank=False, blankprblowedgedl=0, blankprbhighedgedl=0):
    pd = install_and_import_pandas()
    pd.set_option('display.max_rows', 20)
    pd.set_option('display.max_columns', 20)
    pd.set_option('display.width', None)
    pd.set_option('display.max_colwidth', 50)

    df = pd.read_csv(filepath, low_memory=False)
    xx = ''
    yy = ''
    asfn = ''
    count = 0
    q = []
    for sfn, slot in zip(df.sfn, df.slot):
        if xx != 0 and sfn == 0:
            count += 1
        if xx != str(sfn) or yy != str(slot):
            asfn = str(count) + '-' + str(sfn) + '-' + str(slot)
            q.append(asfn)
        xx = sfn
        yy = slot
    df.insert(2, "asfn", q, True)
    df2 = df[['type', 'timeStamp', 'asfn', 'sfn', 'slot', 'rnti', 'physCellId', 'numOfPrb', 'startPrb', 'dciFormat']]

    df_filtered = df2[((df2['type'] == 'dlPagingOrSibSchedData') | (df2['type'] == 'dlFdSchedData'))
                      & (df2['physCellId'] == cellid)]

    df_filtered = df_filtered.astype({"sfn": "int", "slot": "int", 'rnti': "int",
                                      'physCellId': "int", 'numOfPrb': "int", 'startPrb': "int"})
    path = os.path.dirname(filepath)
    log_file = 'print_log_' + str(datetime.now()).replace(':', '-').replace(' ', '_') + '.log'
    fp = open(os.path.join(path, log_file), 'a')
    prev_asfn = 0
    for asfn in df_filtered.asfn:
        if prev_asfn != asfn:
            df1 = df_filtered[df_filtered['asfn'] == asfn]
            df1_new = df1.sort_values(by=['startPrb']).reset_index()
            df1_new['endPrb'] = df1_new['startPrb'] + df1_new['numOfPrb'] - 1
            sfn = df1_new['sfn'].unique()
            slot = df1_new['slot'].unique()
            rat1_alloc_bitmap = [0] * ded_bwp[1]
            rat1_alloc_bitmap_ = [i for i in range(ded_bwp[1])]
            startprb = ded_bwp[0]
            endprb = ded_bwp[1]

            if prbblank:
                if blankprblowedgedl > 0 and blankprbhighedgedl == 0:
                    rat1_alloc_bitmap[:blankprblowedgedl] = [255] * blankprblowedgedl
                    startprb = blankprblowedgedl
                elif blankprblowedgedl == 0 and blankprbhighedgedl > 0:
                    rat1_alloc_bitmap[-blankprbhighedgedl:] = [255] * blankprbhighedgedl
                    endprb = ded_bwp[1] - blankprbhighedgedl
                elif blankprblowedgedl > 0 and blankprbhighedgedl > 0:
                    rat1_alloc_bitmap[:blankprblowedgedl] = [255] * blankprblowedgedl
                    rat1_alloc_bitmap[-blankprbhighedgedl:] = [255] * blankprbhighedgedl
                    startprb = blankprblowedgedl
                    endprb = ded_bwp[1] - blankprbhighedgedl

            if celltype == 'FDD' and sfn % 2 == 0 and slot == 0:
                rat1_alloc_bitmap[ssb_start_position:ssb_start_position + 20] = \
                    [255] * len(rat1_alloc_bitmap[ssb_start_position:ssb_start_position + 20])
                large_bwp_psa1_region = rat1_alloc_bitmap[startprb:ssb_start_position]
                large_bwp_psa2_region = rat1_alloc_bitmap[ssb_start_position + 20:endprb]

            elif 'dlFdSchedData' in set(df1_new['type']) and 'dlPagingOrSibSchedData' not in set(df1_new['type']):
                if 'DL_10_MSG2' in list(df1_new.dciFormat) or 'DL_10_MSG4' in list(df1_new.dciFormat) or \
                        'DL_10_FORCE' in list(df1_new.dciFormat):
                    large_bwp_psa1_region = rat1_alloc_bitmap[startprb:initial_bwp[0]]
                    large_bwp_psa2_region = rat1_alloc_bitmap[initial_bwp[0]:endprb]
                    if df1_new.iloc[0]['startPrb'] != float(initial_bwp[0]):
                        print("With DL_10 only scheduled with DL_11 rat1 allocation not started from"
                              " start prb-{0} of Coreset0".format(initial_bwp[0]), file=fp)
                        return 'Fail'
                    else:
                        print("========Success with DL_10 only========", file=fp)
                        print(df1_new, file=fp)
                        print('=====================================\n', file=fp)

                elif 'DL_11' in list(df1_new.dciFormat):
                    large_bwp_psa1_region = rat1_alloc_bitmap[startprb:endprb]
                    large_bwp_psa2_region = []
                    print("========dlFdSchedData only========", file=fp)
                    print(df1_new, file=fp)
                    print('=====================================\n', file=fp)

                else:
                    print("========dlFdSchedData with DL_10========", file=fp)
                    print(df1_new, file=fp)
                    print('=====================================\n', file=fp)

            elif 'dlFdSchedData' in set(df1_new['type']) and 'dlPagingOrSibSchedData' in set(df1_new['type']):
                cc_list = ['DL_10_SIB1', 'DL_10_OSI', 'DL_10_PAGING']
                df_cc = df1_new[(df1_new['dciFormat'].isin(cc_list)) & (initial_bwp[0] <= df1_new['startPrb'])]
                large_bwp_psa1_region = rat1_alloc_bitmap[startprb:df_cc.iloc[0]['startPrb']]
                large_bwp_psa2_region = rat1_alloc_bitmap[df_cc.iloc[0]['startPrb'] + df_cc.iloc[0]['numOfPrb']:endprb]
                print("===========dlFdSchedData with dlPagingOrSibSchedData===========", file=fp)
                print(df1_new, file=fp)
                df1_new = df1_new[df1_new['type'] != 'dlPagingOrSibSchedData']
                print('=====================================\n', file=fp)

            elif 'dlFdSchedData' not in set(df1_new['type']) and 'dlPagingOrSibSchedData' in set(df1_new['type']):
                continue
            else:
                print("comination not included", file=fp)
                print(df1_new, file=fp)
                print('=====================================\n', file=fp)

            if not prbrandom:
                result = rat1_allocation_without_randomization_mono(df1_new, large_bwp_psa1_region,
                                                                    large_bwp_psa2_region,
                                                                    rat1bitmap=rat1_alloc_bitmap, filename=fp)
                if result == "Fail":
                    return "Fail"
            else:
                continue
        prev_asfn = asfn
    fp.close()
    return 'Pass'


def rat1_allocation_without_randomization_mono(df, psa1, psa2, rat1bitmap=None, filename=None):
    dummy = ''
    for dci in df.dciFormat:
        if dci != dummy:
            df1 = df[df['dciFormat'] == dci]
            for i in range(len(df1['startPrb'].index)):
                x = df1.iloc[i]['startPrb']
                y = df1.iloc[i]['numOfPrb']
                if rat1bitmap[x] == 0:
                    rat1bitmap[x: x + y] = [1] * y
                else:
                    print("PRB Overlapping", df1, file=filename)
            expectedallocation = [1] * df1['numOfPrb'].sum()
            allocatedprb = rat1bitmap[df1.iloc[0]['startPrb']: df1.iloc[0]['startPrb'] + df1['numOfPrb'].sum()]
            if len(psa1) >= len(psa2):
                print("As size of both Sub-Areas are same, Allocation will "
                      "start from bottom PRB. In our code it will be PSA1",
                      file=filename)
                if allocatedprb == expectedallocation and len(allocatedprb) <= len(psa1):
                    print("========RAT1 Allocation happend continuously in PSA1========", file=filename)
                    print(df1, file=filename)
                    print('After Allocation', rat1bitmap, file=filename)
                    print('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n', file=filename)
                else:
                    print("========RAT1 Allocation discontinuous large_bwp_psa1_region========", file=filename)
                    print(df1, file=filename)
                    print("After allocation large_bwp_psa1_region", rat1bitmap, file=filename)
                    print('###############-FAIL-######################\n', file=filename)
                    return 'Fail'
            elif len(psa2) > len(psa1):
                if allocatedprb == expectedallocation and len(allocatedprb) <= len(psa2):
                    print("========RAT1 Allocation happend continuously in PSA2========", file=filename)
                    print(df1, file=filename)
                    print('psa2 allocatedprb', rat1bitmap, file=filename)
                    print('**********************************\n', file=filename)
                else:
                    print("========RAT1 Allocation discontinuous large_bwp_psa2_region========", file=filename)
                    print(df1, file=filename)
                    print('falied psa2 allocatedprb', rat1bitmap, file=filename)
                    print('***************-FAIL-*******************\n', file=filename)
                    return 'Fail'
        dummy = dci


def validation_of_rat1_allocation_generalised(filepath, cellid, celltype, initial_bwp, ded_bwp,
                                              ssb_start_position, prbrandom=False, sibrandomisation=False,
                                              prbblank=False, blankprblowedgedl=0, blankprbhighedgedl=0):
    pd = install_and_import_pandas()
    pd.set_option('display.max_rows', 20)
    pd.set_option('display.max_columns', 20)
    pd.set_option('display.width', None)
    pd.set_option('display.max_colwidth', 50)

    df = pd.read_csv(filepath, low_memory=False)
    xx = ''
    yy = ''
    asfn = ''
    count = 0
    q = []
    for sfn, slot in zip(df.sfn, df.slot):
        if xx != 0 and sfn == 0:
            count += 1
        if xx != str(sfn) or yy != str(slot):
            asfn = str(count) + '-' + str(sfn) + '-' + str(slot)
            q.append(asfn)
        xx = sfn
        yy = slot
    df.insert(2, "asfn", q, True)
    df2 = df[['type', 'timeStamp', 'asfn', 'sfn', 'slot', 'rnti',
              'physCellId', 'numOfPrb', 'startPrb', 'dciFormat', 'cellBwpId']]

    df_filtered = df2[((df2['type'] == 'dlPagingOrSibSchedData') | (df2['type'] == 'dlFdSchedData'))
                      & (df2['physCellId'] == cellid)]

    df_filtered = df_filtered.astype({"sfn": "int", "slot": "int", 'rnti': "int",
                                      'physCellId': "int", 'numOfPrb': "int", 'startPrb': "int"})
    path = os.path.dirname(filepath)
    log_file = 'print_log_' + str(datetime.now()).replace(':', '-').replace(' ', '_') + '.log'
    fp = open(os.path.join(path, log_file), 'a')
    prev_asfn = 0
    for asfn in df_filtered.asfn:
        if prev_asfn != asfn:
            df1 = df_filtered[df_filtered['asfn'] == asfn]
            df1_new = df1.sort_values(by=['startPrb']).reset_index()
            df1_new['endPrb'] = df1_new['startPrb'] + df1_new['numOfPrb'] - 1
            sfn = df1_new['sfn'].unique()
            slot = df1_new['slot'].unique()
            sch_bwp = df1_new['cellBwpId'].dropna()
            psa = AutoDict()
            ded_bwp = {float(k): v for k, v in ded_bwp.items()}
            startprb = ded_bwp[list(ded_bwp.keys())[-1]][0]
            totalnumofprb = ded_bwp[list(ded_bwp.keys())[-1]][1]
            endprb = startprb + totalnumofprb
            flag_dl10_sib = 0
            pagingflag = 0
            rat1_alloc_bitmap = []
            for i in range(0, startprb + totalnumofprb):
                if i < startprb:
                    rat1_alloc_bitmap.insert(i, 'NU')
                else:
                    rat1_alloc_bitmap.append('U')

            if prbblank:
                if blankprblowedgedl > 0 and blankprbhighedgedl == 0:
                    set_bitmap(rat1_alloc_bitmap, 0, blankprblowedgedl, 255)
                    startprb = blankprblowedgedl
                    totalnumofprb = len(rat1_alloc_bitmap[blankprblowedgedl:])
                elif blankprblowedgedl == 0 and blankprbhighedgedl > 0:
                    set_bitmap(rat1_alloc_bitmap, len(rat1_alloc_bitmap) - 1, -blankprbhighedgedl, 255)
                    endprb = len(rat1_alloc_bitmap) - blankprbhighedgedl
                    totalnumofprb = len(rat1_alloc_bitmap[:-blankprbhighedgedl])
                elif blankprblowedgedl > 0 and blankprbhighedgedl > 0:
                    set_bitmap(rat1_alloc_bitmap, 0, blankprblowedgedl, 255)
                    set_bitmap(rat1_alloc_bitmap, len(rat1_alloc_bitmap) - 1, -blankprbhighedgedl, 255)
                    startprb = blankprblowedgedl
                    endprb = len(rat1_alloc_bitmap) - blankprbhighedgedl
                    totalnumofprb = len(rat1_alloc_bitmap[blankprblowedgedl:-blankprbhighedgedl])
            if celltype == 'FDD' and sfn % 2 == 0 and slot == 0:
                set_bitmap(rat1_alloc_bitmap, ssb_start_position, 21, 255)
                ssb_end_position = ssb_start_position + 21
                for i in sch_bwp:
                    if i == float(0):
                        psa[i]['psa1'] = [initial_bwp[0], len(rat1_alloc_bitmap[initial_bwp[0]:ssb_start_position])]
                        set_bitmap(rat1_alloc_bitmap, initial_bwp[0],
                                   len(rat1_alloc_bitmap[initial_bwp[0]:ssb_start_position]), 'x')
                        psa[i]['psa2'] = [ssb_end_position, len(rat1_alloc_bitmap[ssb_end_position:sum(initial_bwp)])]
                        set_bitmap(rat1_alloc_bitmap, ssb_end_position,
                                   len(rat1_alloc_bitmap[ssb_end_position:sum(initial_bwp)]), 'y')

                    elif i in ded_bwp.keys() and i != list(ded_bwp.keys())[-1]:
                        # psa1
                        psa[i]['psa1'] = [ded_bwp[i][0], len(rat1_alloc_bitmap[ded_bwp[i][0]:ssb_start_position])]
                        set_bitmap(rat1_alloc_bitmap, ded_bwp[i][0],
                                   len(rat1_alloc_bitmap[ded_bwp[i][0]:ssb_start_position]), 'x')
                        # psa2
                        if ded_bwp[i][1] < endprb:
                            psa[i]['psa2'] = [ssb_end_position, len(rat1_alloc_bitmap[ssb_end_position:ded_bwp[i][1]])]
                            set_bitmap(rat1_alloc_bitmap, ssb_end_position,
                                       len(rat1_alloc_bitmap[ssb_end_position:ded_bwp[i][1]]), 'y')
                        else:
                            psa[i]['psa2'] = [ssb_end_position, len(rat1_alloc_bitmap[ssb_end_position:endprb])]
                            set_bitmap(rat1_alloc_bitmap, ssb_end_position,
                                       len(rat1_alloc_bitmap[ssb_end_position:endprb]), 'y')
                    else:
                        psa[i]['psa1'] = [startprb, len(rat1_alloc_bitmap[startprb:ssb_start_position])]
                        set_bitmap(rat1_alloc_bitmap, startprb,
                                   len(rat1_alloc_bitmap[startprb:ssb_start_position]), 'x')
                        psa[i]['psa2'] = [ssb_end_position, len(rat1_alloc_bitmap[ssb_end_position:endprb])]
                        set_bitmap(rat1_alloc_bitmap, ssb_end_position,
                                   len(rat1_alloc_bitmap[ssb_end_position:endprb]), 'y')

            elif 'dlFdSchedData' in set(df1_new['type']) and 'dlPagingOrSibSchedData' not in set(df1_new['type']):
                if 'DL_10_MSG2' in list(df1_new.dciFormat) or 'DL_10_MSG4' in list(df1_new.dciFormat):
                    for i in sch_bwp:
                        if i == 0:
                            psa[i]['psa1'] = initial_bwp
                            set_bitmap(rat1_alloc_bitmap, initial_bwp[0], initial_bwp[1], 'x')
                            psa[0]['psa2'] = [0, 0]

                        elif i in ded_bwp.keys() and i != list(ded_bwp.keys())[-1]:
                            psa[i]['psa1'] = [ded_bwp[i][0], len(rat1_alloc_bitmap[startprb:initial_bwp[0]])]
                            set_bitmap(rat1_alloc_bitmap, ded_bwp[i][0],
                                       len(rat1_alloc_bitmap[startprb:initial_bwp[0]]), 'x')
                            if ded_bwp[i][1] < endprb:
                                psa[i]['psa2'] = [initial_bwp[0], len(rat1_alloc_bitmap[initial_bwp[0]:ded_bwp[i][1]])]
                                set_bitmap(rat1_alloc_bitmap, initial_bwp[0],
                                           len(rat1_alloc_bitmap[initial_bwp[0]:ded_bwp[i][1]]), 'y')
                            else:
                                psa[i]['psa2'] = [initial_bwp[0], len(rat1_alloc_bitmap[initial_bwp[0]:endprb])]
                                set_bitmap(rat1_alloc_bitmap, initial_bwp[0],
                                           len(rat1_alloc_bitmap[initial_bwp[0]:endprb]), 'y')
                        else:
                            psa[i]['psa1'] = [startprb, len(rat1_alloc_bitmap[startprb:initial_bwp[0]])]
                            set_bitmap(rat1_alloc_bitmap, startprb,
                                       len(rat1_alloc_bitmap[startprb:initial_bwp[0]]), 'x')
                            psa[i]['psa2'] = [initial_bwp[0], len(rat1_alloc_bitmap[initial_bwp[0]:endprb])]
                            set_bitmap(rat1_alloc_bitmap, initial_bwp[0],
                                       len(rat1_alloc_bitmap[initial_bwp[0]:endprb]), 'y')
                elif 'DL_11' in list(df1_new.dciFormat) and len(set(list(df1_new.dciFormat))) == 1:
                    for i in sch_bwp:
                        if i in ded_bwp.keys() and i != list(ded_bwp.keys())[-1]:
                            if ded_bwp[i][1] < endprb:
                                psa[i]['psa1'] = [ded_bwp[i][0], ded_bwp[i][1]]
                                psa[i]['psa2'] = [0, 0]
                                set_bitmap(rat1_alloc_bitmap, ded_bwp[i][0], ded_bwp[i][1], 'x')
                            else:
                                psa[i]['psa1'] = [ded_bwp[i][0], len(rat1_alloc_bitmap[ded_bwp[i][0]:endprb])]
                                psa[i]['psa2'] = [0, 0]
                                set_bitmap(rat1_alloc_bitmap, ded_bwp[i][0],
                                           len(rat1_alloc_bitmap[ded_bwp[i][0]:endprb]), 'x')
                        else:
                            psa[i]['psa1'] = [startprb, len(rat1_alloc_bitmap[startprb:endprb])]
                            psa[i]['psa2'] = [0, 0]
                            set_bitmap(rat1_alloc_bitmap, startprb, len(rat1_alloc_bitmap[startprb:endprb]), 'x')
                    print("========DL_11 only========", file=fp)
                    print(df1_new, file=fp)
                    print('=====================================\n', file=fp)
                else:
                    print("========dlFdSchedData with DL_10========", file=fp)
                    print(df1_new, file=fp)
                    print('=====================================\n', file=fp)
            elif 'dlFdSchedData' in set(df1_new['type']) and 'dlPagingOrSibSchedData' in set(df1_new['type']):
                cc_list = ['DL_10_SIB1', 'DL_10_OSI', 'DL_10_PAGING']
                df_cc = df1_new[(df1_new['dciFormat'].isin(cc_list)) & (initial_bwp[0] <= df1_new['startPrb'])]
                if 'DL_10_PAGING' in df_cc['dciFormat']:
                    pagingflag = 1
                aa = df_cc.iloc[0]['startPrb'] + df_cc.iloc[0]['numOfPrb']
                for i in sch_bwp:
                    if i == float(0):
                        psa[i]['psa1'] = [initial_bwp[0],
                                          len(rat1_alloc_bitmap[initial_bwp[0]:df_cc.iloc[0]['startPrb']])]
                        set_bitmap(rat1_alloc_bitmap, initial_bwp[0],
                                   len(rat1_alloc_bitmap[initial_bwp[0]:df_cc.iloc[0]['startPrb']]), 'x')
                        psa[i]['psa2'] = [aa, len(rat1_alloc_bitmap[aa:sum(initial_bwp)])]
                        set_bitmap(rat1_alloc_bitmap, aa, len(rat1_alloc_bitmap[aa:sum(initial_bwp)]), 'y')
                        flag_dl10_sib = 1
                    elif i in ded_bwp.keys() and i != list(ded_bwp.keys())[-1]:
                        psa[i]['psa1'] = [ded_bwp[i][0],
                                          len(rat1_alloc_bitmap[ded_bwp[i][0]:df_cc.iloc[0]['startPrb']])]
                        set_bitmap(rat1_alloc_bitmap, ded_bwp[i][0],
                                   len(rat1_alloc_bitmap[ded_bwp[i][0]:df_cc.iloc[0]['startPrb']]), 'x')
                        if ded_bwp[i][1] < endprb:
                            psa[i]['psa2'] = [aa, len(rat1_alloc_bitmap[aa:ded_bwp[i][1]])]
                            set_bitmap(rat1_alloc_bitmap, aa, len(rat1_alloc_bitmap[aa:ded_bwp[i][1]]), 'y')
                        else:
                            psa[i]['psa2'] = [initial_bwp[0], len(rat1_alloc_bitmap[aa:endprb])]
                            set_bitmap(rat1_alloc_bitmap, aa, len(rat1_alloc_bitmap[aa:endprb]), 'y')
                    else:
                        psa[i]['psa1'] = [startprb, len(rat1_alloc_bitmap[startprb:df_cc.iloc[0]['startPrb']])]
                        set_bitmap(rat1_alloc_bitmap, startprb,
                                   len(rat1_alloc_bitmap[startprb:df_cc.iloc[0]['startPrb']]), 'x')
                        psa[i]['psa2'] = [aa, len(rat1_alloc_bitmap[aa:endprb])]
                        set_bitmap(rat1_alloc_bitmap, aa, len(rat1_alloc_bitmap[aa:endprb]), 'y')
                print("===========dlFdSchedData with dlPagingOrSibSchedData===========", file=fp)
                print(df1_new, file=fp)
                df1_new = df1_new[df1_new['type'] != 'dlPagingOrSibSchedData']
                print('=====================================\n', file=fp)
            elif 'dlFdSchedData' not in set(df1_new['type']) and 'dlPagingOrSibSchedData' in set(df1_new['type']):
                continue
            else:
                print("combination not included", file=fp)
                print(df1_new, file=fp)
                print('=====================================\n', file=fp)
            if prbrandom is False:
                for bwpid in psa:
                    if bwpid == 0:
                        psa1 = psa[bwpid]['psa1'][1]
                        psa2 = psa[bwpid]['psa2'][1]
                        ww = df1_new[df1_new['cellBwpId'] == bwpid]
                        result = rat1_allocation_without_randomization(ww, psa1, psa2, flag_dl10_sib,
                                                                       rat1bitmap=rat1_alloc_bitmap, filename=fp)
                        if result == "Fail":
                            return "Fail"
                    else:
                        df_1 = df1_new[df1_new['cellBwpId'] == bwpid]
                        dummy = ''
                        psa1 = psa[bwpid]['psa1'][1]
                        psa2 = psa[bwpid]['psa2'][1]
                        for dci in set(list(df_1.dciFormat)):
                            if dci == 'DL_10_FORCE':
                                flag_dl10_sib = 1
                            else:
                                flag_dl10_sib = 0
                            df_2 = df_1[df_1['dciFormat'] == dci]
                            result = rat1_allocation_without_randomization(df_2, psa1, psa2, flag_dl10_sib,
                                                                           rat1bitmap=rat1_alloc_bitmap, filename=fp)
                            if result == "Fail":
                                return "Fail"
            else:
                if len(ded_bwp.keys()) == 1:
                    result = rat1_allocation_with_randomization_monobwp(df1_new, psa, sibrandomisation, endprb,
                                                                        pagingflag, flag_dl10_sib,
                                                                        rat1bitmap=rat1_alloc_bitmap,
                                                                        filename=fp)
                    if result == "Fail":
                        return "Fail"
                else:
                    pass
        prev_asfn = asfn
    fp.close()
    return 'Pass'


def rat1_allocation_without_randomization(df, psa1, psa2, flag_dl10_sib=0, rat1bitmap=None, filename=None):
    if psa1 >= psa2:
        print("As size of both Sub-Areas are same, Allocation will start from bottom PRB. In our code it will be PSA1",
              file=filename)
        for i in range(len(df['startPrb'].index)):
            a = df.iloc[i]['startPrb']
            b = df.iloc[i]['numOfPrb']
            if rat1bitmap[a] == 'x' and rat1bitmap.index('x') == a and flag_dl10_sib == 0:
                set_bitmap(rat1bitmap, a, b, 1)
                print("psa-1 rat1bitmap after allocation \n", rat1bitmap, file=filename)
            elif rat1bitmap[a] == 'x' and (rat1bitmap.index('x') == a or rat1bitmap.index('x') != a) \
                    and flag_dl10_sib == 1:
                set_bitmap(rat1bitmap, a, b, 1)
                print("psa-1 rat1bitmap after allocation \n", rat1bitmap, file=filename)
            else:
                print("psa-1 rat1bitmap improper allocation \n", rat1bitmap, file=filename)
                print("psa-1 PRB Overlapping", df, file=filename)
                return "Fail"
        expectedallocation = [1] * df['numOfPrb'].sum()
        allocatedprb = rat1bitmap[df.iloc[0]['startPrb']:df.iloc[0]['startPrb'] + df['numOfPrb'].sum()]
        if allocatedprb == expectedallocation and len(allocatedprb) <= psa1:
            print("RAT1 Allocation happend continuously in PSA1 \n", file=filename)
            print(df, file=filename)
            print('psa1 allocatedprb', allocatedprb, file=filename)
            print('psa1 expected allocation', expectedallocation, file=filename)
            print('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^', file=filename)
        else:
            print("RAT1 Allocation discontinuous large_bwp_psa1_region \n", file=filename)
            print(df, file=filename)
            print("psa1 rat1bitmap Failed", rat1bitmap)
            print('start prb', df.iloc[0]['startPrb'], 'numOfPrb', df['numOfPrb'].sum(), file=filename)
            print("psa1 allocatedprb", allocatedprb, file=filename)
            print('psa1 expected allocation', expectedallocation, file=filename)
            print('###############-FAIL-######################', file=filename)
            return 'Fail'
    else:
        for i in range(len(df['startPrb'].index)):
            c = df.iloc[i]['startPrb']
            d = df.iloc[i]['numOfPrb']
            if rat1bitmap[c] == 'y' and rat1bitmap.index('y') == c and flag_dl10_sib == 0:
                set_bitmap(rat1bitmap, c, d, 1)
                print("psa-2 rat1bitmap after allocation \n", rat1bitmap, file=filename)
            elif rat1bitmap[c] == 'y' and (rat1bitmap.index('y') == c or rat1bitmap.index('y') != c) \
                    and flag_dl10_sib == 1:
                set_bitmap(rat1bitmap, c, d, 1)
                print("psa-2 rat1bitmap after allocation \n", rat1bitmap, file=filename)
            else:
                print("psa-2 rat1bitmap improper allocation \n", rat1bitmap, file=filename)
                print("psa-2 PRB Overlapping", df, file=filename)
                return "Fail"
        expectedallocation = [1] * df['numOfPrb'].sum()
        allocatedprb = rat1bitmap[df.iloc[0]['startPrb']: df.iloc[0]['startPrb'] + df['numOfPrb'].sum()]
        if allocatedprb == expectedallocation and len(allocatedprb) <= psa2:
            print("RAT1 Allocation happend continuously in PSA2 \n", file=filename)
            print(df, file=filename)
            print('psa2 allocatedprb', allocatedprb, file=filename)
            print('psa2 expected allocation', expectedallocation, file=filename)
            print('**********************************', file=filename)
        else:
            print("RAT1 Allocation discontinuous large_bwp_psa2_region \n", file=filename)
            print(df, file=filename)
            print('falied psa2 allocatedprb', allocatedprb, file=filename)
            print('falied psa2 expected allocation', allocatedprb, file=filename)
            print('***************-FAIL-*******************', file=filename)
            return 'Fail'


def rat1_allocation_with_randomization_monobwp(df, psa, sibrandomisation, endprb, pagingflag, flag_dl10_sib,
                                               rat1bitmap=None, filename=None):
    sfn = df['sfn'].unique()[0]
    slot = df['slot'].unique()[0]
    physcellid = df['physCellId'].unique()[0]
    if len(psa.keys()) == 1:
        key = list(psa.keys())[0]
        psa1 = psa[key]['psa1'][1]
        psa2 = psa[key]['psa2'][1]
        selected_psa = ''
        if (sibrandomisation is False or pagingflag == 1) and flag_dl10_sib == 1:
            if key == 0:
                if psa1 >= psa2:
                    selected_psa = list(psa[key].keys())[0]
                    psa1endprb = sum(psa[key]['psa1'])
                    result = rat1_continuous_allocation(df, selected_psa, psa1endprb, rat1bitmap, filename)
                    if result == 'Fail':
                        return 'Fail'
                else:
                    selected_psa = list(psa[key].keys())[1]
                    psa2endprb = sum(psa[key]['psa2'])
                    result = rat1_continuous_allocation(df, selected_psa, psa2endprb, rat1bitmap, filename)
                    if result == 'Fail':
                        return 'Fail'
        else:
            if psa1 >= psa2:
                rrmFirstAvailablePrb = psa[key]['psa1'][0]
                reservedprb = df['numOfPrb'].sum()
                rrmRemainingPrb = psa1 - reservedprb
                selected_psa = list(psa[key].keys())[0]
                psa1endprb = sum(psa[key]['psa1'])
                if reservedprb < psa1:
                    startprb = rat1_startprbrandomize(sfn, slot, physcellid, rrmFirstAvailablePrb, rrmRemainingPrb)
                    if startprb == df.iloc[0]['startPrb']:
                        result = rat1_continuous_allocation(df, selected_psa, psa1endprb, rat1bitmap, filename)
                        if result == 'Fail':
                            return 'Fail'
                else:
                    result = rat1_continuous_allocation(df, selected_psa, psa1endprb, rat1bitmap, filename)
                    if result == 'Fail':
                        return 'Fail'
            else:
                rrmFirstAvailablePrb = psa[key]['psa2'][0]
                reservedprb = df['numOfPrb'].sum()
                rrmRemainingPrb = psa2 - reservedprb
                selected_psa = list(psa[key].keys())[1]
                psa2endprb = sum(psa[key]['psa2'])
                if reservedprb < psa2:
                    startprb = rat1_startprbrandomize(sfn, slot, physcellid, rrmFirstAvailablePrb, rrmRemainingPrb)
                    if startprb == df.iloc[0]['startPrb']:
                        result = rat1_continuous_allocation(df, selected_psa, psa2endprb, rat1bitmap, filename)
                        if result == 'Fail':
                            return 'Fail'
                else:
                    result = rat1_continuous_allocation(df, selected_psa, psa2endprb, rat1bitmap, filename)
                    if result == 'Fail':
                        return 'Fail'

    else:
        # Coreset & Large BWP will be scheduled together in Slot

        keys = list(psa.keys())
        keys.sort()
        if len(keys) > 0:
            psa1_0 = psa[keys[0]]['psa1'][1]
            psa2_0 = psa[keys[0]]['psa2'][1]
            psa1_1 = psa[keys[1]]['psa1'][1]
            psa2_1 = psa[keys[1]]['psa2'][1]

            psa1endprb_0 = sum(psa[keys[0]]['psa1'])
            psa2endprb_0 = sum(psa[keys[0]]['psa2'])

            psa1endprb_1 = sum(psa[keys[1]]['psa1'])
            psa2endprb_1 = sum(psa[keys[1]]['psa2'])

            selected_psa_0 = ''
            selected_psa_1 = ''
            rrmFirstAvailablePrb_0 = ''
            rrmFirstAvailablePrb_1 = ''
            df0 = df[df['cellBwpId'] == 0.0]
            df1 = df[df['cellBwpId'] == 1.0]
            total_reservedprb = df['numOfPrb'].sum()
            reservedprb0 = df0['numOfPrb'].sum()
            reservedprb1 = df1['numOfPrb'].sum()
            exclusive_area_psa11 = len(rat1bitmap[psa[keys[1]]['psa1'][0]:psa[keys[0]]['psa1'][0]])
            exclusive_area_psa12 = len(rat1bitmap[psa1endprb_0:psa2endprb_1])
            exclusive_area_psa21 = 0
            exclusive_area_psa22 = len(rat1bitmap[psa2endprb_0:psa2endprb_1])

            overlapprb_psa1 = ''
            overlapprb_psa2 = ''

            if total_reservedprb < psa1endprb_1 or total_reservedprb < psa2endprb_1:
                # Randomisation might happen if there were enough PRBs available
                if (sibrandomisation is False or pagingflag == 1) and flag_dl10_sib == 1:
                    # No Randomisation will happen in Coreset
                    if psa1_0 >= psa2_0:
                        selected_psa_0 = list(psa[0.0].keys())[0]
                        result = rat1_continuous_allocation(df0, selected_psa_0, psa1endprb_0, rat1bitmap, filename)
                        if result == 'Fail':
                            return 'Fail'
                        else:
                            rat1bitmap = result
                            if psa1_1 >= psa2_1:
                                rrmFirstAvailablePrb_1 = psa[keys[1]]['psa1'][0]
                                selected_psa_1 = list(psa[1.0].keys())[0]
                                leftoverprb = len(rat1bitmap[rrmFirstAvailablePrb_1:df0.iloc[0]['startPrb']])
                                endprb = df0.iloc[0]['startPrb']
                            else:
                                rrmFirstAvailablePrb_1 = df0.iloc[0]['startPrb'] + df0['numOfPrb'].sum()
                                selected_psa_1 = list(psa[1.0].keys())[1]
                                leftoverprb = len(rat1bitmap[rrmFirstAvailablePrb_1:psa2endprb_1])
                                endprb = psa2endprb_1
                    else:
                        selected_psa_0 = list(psa[0.0].keys())[1]
                        result = rat1_continuous_allocation(df0, selected_psa_0, psa2endprb_0, rat1bitmap, filename)
                        if result == 'Fail':
                            return 'Fail'
                        else:
                            rat1bitmap = result
                            if psa1_1 >= psa2_1:
                                rrmFirstAvailablePrb_1 = psa[keys[1]]['psa1'][0]
                                selected_psa_1 = list(psa[1.0].keys())[0]
                                leftoverprb = len(rat1bitmap[rrmFirstAvailablePrb_1:psa1endprb_1])
                                endprb = psa1endprb_1
                            else:
                                rrmFirstAvailablePrb_1 = df0.iloc[0]['startPrb'] + df0['numOfPrb'].sum()
                                selected_psa_1 = list(psa[1.0].keys())[1]
                                leftoverprb = len(rat1bitmap[rrmFirstAvailablePrb_1:psa2endprb_1])
                                endprb = psa2endprb_1

                    if reservedprb1 < leftoverprb:
                        remainingprb_1 = leftoverprb - reservedprb1
                        startprb1 = rat1_startprbrandomize(sfn, slot, physcellid, rrmFirstAvailablePrb_1,
                                                           remainingprb_1)
                        if startprb1 == df1.iloc[0]['startPrb']:
                            result = rat1_continuous_allocation(df1, selected_psa_1, endprb, rat1bitmap, filename)
                            if result == 'Fail':
                                return 'Fail'
                        else:
                            print("{0} randomisation not working\n".format(selected_psa_1), file=filename)
                            print(df1, file=filename)
                            print("==========Large BWP {0} FAIL========= \n".format(selected_psa_1), file=filename)
                            return 'Fail'
                    else:
                        result = rat1_continuous_allocation(df1, selected_psa_1, endprb, rat1bitmap, filename)
                        if result == 'Fail':
                            return 'Fail'
                else:
                    # Randomisation will happen in Coreset
                    if psa1_0 >= psa2_0 and psa1_1 >= psa2_1:
                        if reservedprb1 <= exclusive_area_psa11:
                            overlapprb_psa1 = 0
                        else:
                            overlapprb_psa1 = reservedprb1 - exclusive_area_psa11

                        selected_psa_0 = list(psa[0.0].keys())[0]
                        selected_psa_1 = list(psa[1.0].keys())[0]
                        # calculate remaining PRB for Coreset in psa1
                        rrmFirstAvailablePrb_0 = psa[keys[0]]['psa1'][0]
                        remainingprb_0 = psa1_0 - overlapprb_psa1 - reservedprb0
                        startprb0 = rat1_startprbrandomize(sfn, slot, physcellid, rrmFirstAvailablePrb_0,
                                                           remainingprb_0)
                        if startprb0 == df0.iloc[0]['startPrb']:
                            result = rat1_continuous_allocation(df0, selected_psa_0, psa1endprb_0, rat1bitmap, filename)
                            if result == 'Fail':
                                return 'Fail'
                            else:
                                rat1bitmap = result
                        else:
                            print("psa1 randomisation not working\n", file=filename)
                            print(df0, file=filename)
                            print("==========Coreset PSA1 FAIL========= \n", file=filename)
                            return 'Fail'

                        # calculate remaining PRB for Large BWP in psa1
                        rrmFirstAvailablePrb_1 = psa[keys[1]]['psa1'][0]
                        remainingprb_1 = len(rat1bitmap[rrmFirstAvailablePrb_1:startprb0]) - reservedprb1
                        startprb1 = rat1_startprbrandomize(sfn, slot, physcellid, rrmFirstAvailablePrb_1,
                                                           remainingprb_1)
                        if startprb1 == df1.iloc[0]['startPrb']:
                            result = rat1_continuous_allocation(df1, selected_psa_1, startprb0, rat1bitmap, filename)
                            if result == 'Fail':
                                return 'Fail'
                            else:
                                rat1bitmap = result
                        else:
                            print("psa1 randomisation not working\n", file=filename)
                            print(df1, file=filename)
                            print("==========Large BWP PSA1 FAIL========= \n", file=filename)
                            return 'Fail'
                    ###################################################################################################
                    elif psa1_0 >= psa2_0 and psa2_1 > psa1_1:
                        if reservedprb1 <= exclusive_area_psa12:
                            overlapprb_psa2 = 0
                        else:
                            overlapprb_psa2 = reservedprb1 - exclusive_area_psa12
                        selected_psa_0 = list(psa[0.0].keys())[0]
                        selected_psa_1 = list(psa[1.0].keys())[1]
                        # calculate remaining PRB for Coreset in psa1
                        rrmFirstAvailablePrb_0 = psa[keys[0]]['psa1'][0]
                        remainingprb_0 = psa1_0 - overlapprb_psa2 - reservedprb0
                        startprb0 = rat1_startprbrandomize(sfn, slot, physcellid, rrmFirstAvailablePrb_0,
                                                           remainingprb_0)
                        if startprb0 == df0.iloc[0]['startPrb']:
                            print("Randomisation Happend in {0} of Coreset".format(selected_psa_0), file=filename)
                            result = rat1_continuous_allocation(df0, selected_psa_0, psa1endprb_0, rat1bitmap, filename)
                            if result == 'Fail':
                                return 'Fail'
                            else:
                                rat1bitmap = result
                        else:
                            print("psa1 randomisation not working\n", file=filename)
                            print(df0, file=filename)
                            print("==========Coreset PSA1 FAIL========= \n", file=filename)
                            return 'Fail'
                        # calculate remaining PRB for Large BWP in psa1
                        rrmFirstAvailablePrb_1 = startprb0 + reservedprb0
                        remainingprb_1 = len(rat1bitmap[rrmFirstAvailablePrb_1:psa2endprb_1]) - reservedprb1
                        startprb1 = rat1_startprbrandomize(sfn, slot, physcellid, rrmFirstAvailablePrb_1,
                                                           remainingprb_1)
                        if startprb1 == df1.iloc[0]['startPrb']:
                            print("Randomisation Happend in {0} of Large BWP".format(selected_psa_1), file=filename)
                            result = rat1_continuous_allocation(df1, selected_psa_1, psa2endprb_1, rat1bitmap, filename)
                            if result == 'Fail':
                                return 'Fail'
                            else:
                                rat1bitmap = result
                        else:
                            print("psa2 randomisation not working\n", file=filename)
                            print(df1, file=filename)
                            print("==========Large BWP PSA2 FAIL========= \n", file=filename)
                            return 'Fail'
                    ###################################################################################################

                    elif psa2_0 > psa1_0 and psa2_1 > psa1_1:
                        if reservedprb1 <= exclusive_area_psa22:
                            overlapprb_psa2 = 0
                        else:
                            overlapprb_psa2 = reservedprb1 - exclusive_area_psa22

                        selected_psa_0 = list(psa[0.0].keys())[1]
                        selected_psa_1 = list(psa[1.0].keys())[1]
                        rrmFirstAvailablePrb_0 = psa[keys[0]]['psa2'][0]
                        remainingprb_0 = psa2_0 - overlapprb_psa2 - reservedprb0
                        # calculate remaining PRB for Coreset in psa2
                        rrmFirstAvailablePrb_0 = psa[keys[0]]['psa2'][0]
                        remainingprb_0 = psa2_0 - overlapprb_psa2 - reservedprb0
                        startprb0 = rat1_startprbrandomize(sfn, slot, physcellid, rrmFirstAvailablePrb_0,
                                                           remainingprb_0)
                        if startprb0 == df0.iloc[0]['startPrb']:
                            result = rat1_continuous_allocation(df0, selected_psa_0, psa2endprb_0, rat1bitmap, filename)
                            if result == 'Fail':
                                return 'Fail'
                            else:
                                rat1bitmap = result
                        else:
                            print("psa2 randomisation not working\n", file=filename)
                            print(df0, file=filename)
                            print("==========Coreset PSA2 FAIL========= \n", file=filename)
                            return 'Fail'
                            # calculate remaining PRB for Large BWP in psa2
                        rrmFirstAvailablePrb_1 = startprb0 + reservedprb0
                        remainingprb_1 = len(rat1bitmap[rrmFirstAvailablePrb_1:psa2endprb_1]) - reservedprb1
                        startprb1 = rat1_startprbrandomize(sfn, slot, physcellid, rrmFirstAvailablePrb_1,
                                                           remainingprb_1)
                        if startprb1 == df1.iloc[0]['startPrb']:
                            result = rat1_continuous_allocation(df1, selected_psa_1, psa2endprb_1, rat1bitmap, filename)
                            if result == 'Fail':
                                return 'Fail'
                            else:
                                rat1bitmap = result
                        else:
                            print("psa1 randomisation not working\n", file=filename)
                            print(df1, file=filename)
                            print("==========Large BWP PSA2 FAIL========= \n", file=filename)
                            return 'Fail'
                    ####################################################################################################
                    elif psa2_0 > psa1_0 and psa1_1 >= psa2_1:
                        selected_psa_0 = list(psa[0.0].keys())[1]
                        selected_psa_1 = list(psa[1.0].keys())[0]
                        # calculate remaining PRB for Coreset in psa2
                        rrmFirstAvailablePrb_0 = psa[keys[0]]['psa2'][0]
                        remainingprb_0 = psa2_0 - reservedprb0
                        startprb0 = rat1_startprbrandomize(sfn, slot, physcellid, rrmFirstAvailablePrb_0,
                                                           remainingprb_0)
                        if startprb0 == df0.iloc[0]['startPrb']:
                            result = rat1_continuous_allocation(df0, selected_psa_0, psa2endprb_0, rat1bitmap, filename)
                            if result == 'Fail':
                                return 'Fail'
                            else:
                                rat1bitmap = result
                        else:
                            print("psa2 randomisation not working\n", file=filename)
                            print(df0, file=filename)
                            print("==========Coreset PSA2 FAIL========= \n", file=filename)
                            return 'Fail'
                            # calculate remaining PRB for Large BWP in psa2
                        rrmFirstAvailablePrb_1 = psa[keys[1]]['psa1'][0]
                        remainingprb_1 = len(rat1bitmap[rrmFirstAvailablePrb_1:psa1endprb_1]) - reservedprb1
                        startprb1 = rat1_startprbrandomize(sfn, slot, physcellid, rrmFirstAvailablePrb_1,
                                                           remainingprb_1)
                        if startprb1 == df1.iloc[0]['startPrb']:
                            result = rat1_continuous_allocation(df1, selected_psa_1, psa2endprb_1, rat1bitmap, filename)
                            if result == 'Fail':
                                return 'Fail'
                            else:
                                rat1bitmap = result
                        else:
                            print("psa1 randomisation not working\n", file=filename)
                            print(df1, file=filename)
                            print("==========Large BWP PSA1 FAIL========= \n", file=filename)
                            return 'Fail'
                    else:
                        print("unknown combination need to check \n")
                        print(df)
                        print("======================================")
            else:
                # No Randomisation will happen due to lack of free PRB
                if psa1_0 >= psa2_0:
                    selected_psa_0 = list(psa[0.0].keys())[0]
                    result = rat1_continuous_allocation(df0, selected_psa_0, psa1endprb_0, rat1bitmap, filename)
                    if result == 'Fail':
                        return 'Fail'
                    else:
                        rat1bitmap = result
                        if psa1_0 >= psa2_0:
                            selected_psa_1 = list(psa[1.0].keys())[0]
                            result = rat1_continuous_allocation(df1, selected_psa_1, psa1endprb_0, rat1bitmap, filename)
                            if result == 'Fail':
                                return 'Fail'
                            else:
                                rat1bitmap = result
                        else:
                            selected_psa_1 = list(psa[1.0].keys())[1]
                            result = rat1_continuous_allocation(df1, selected_psa_1, psa1endprb_0, rat1bitmap, filename)
                            if result == 'Fail':
                                return 'Fail'
                            else:
                                rat1bitmap = result
                else:
                    selected_psa_0 = list(psa[0.0].keys())[1]
                    result = rat1_continuous_allocation(df0, selected_psa_0, psa2endprb_0, rat1bitmap, filename)
                    if result == 'Fail':
                        return 'Fail'
                    else:
                        rat1bitmap = result
                        if psa1_0 >= psa2_0:
                            selected_psa_1 = list(psa[1.0].keys())[0]
                            result = rat1_continuous_allocation(df1, selected_psa_1, psa1endprb_0, rat1bitmap, filename)
                            if result == 'Fail':
                                return 'Fail'
                            else:
                                rat1bitmap = result
                        else:
                            selected_psa_1 = list(psa[1.0].keys())[1]
                            result = rat1_continuous_allocation(df1, selected_psa_1, psa1endprb_0, rat1bitmap, filename)
                            if result == 'Fail':
                                return 'Fail'
                            else:
                                rat1bitmap = result
        else:
            pass


def rat1_continuous_allocation(df, selcted_psa, endprb, rat1bitmap, filename):
    for i in range(len(df['startPrb'].index)):
        a = df.iloc[i]['startPrb']
        b = df.iloc[i]['numOfPrb']
        set_bitmap(rat1bitmap, a, b, 1)
        try:
            if a + b == df.iloc[i + 1]['startPrb']:
                print("RAT1 Allocation happend continuously in PSA1\n", file=filename)
                print(df, file=filename)
                print("{0} rat1bitmap after allocation \n".format(selcted_psa), rat1bitmap, file=filename)
                print("==========={0}-Success=============== \n".format(selcted_psa), file=filename)
            else:
                print("RAT1 Allocation is Discontinuous in {0}\n".format(selcted_psa), file=filename)
                print(df, file=filename)
                print("{0} rat1bitmap after allocation \n".format(selcted_psa), rat1bitmap, file=filename)
                print("=============={0}-FAIL==================== \n".format(selcted_psa), file=filename)
                return "Fail"
        except IndexError:
            if a + b <= endprb:
                print("Either Single UE Scheduled or Last UE PRB allocation on {0}\n"
                      .format(selcted_psa), file=filename)
                print(df, file=filename)
                print("{0} rat1bitmap after allocation \n".format(selcted_psa), rat1bitmap, file=filename)
                print("==========={0}-Success=============== \n".format(selcted_psa), file=filename)
            else:
                print('########################\n', file=filename)
                print(df, file=filename)
                print("=============={0}-FAIL==================== \n".format(selcted_psa), file=filename)
                return "Fail"
    return rat1bitmap


def set_bitmap(rat1bitmap, startPrb, numOfPrb, value):
    if numOfPrb < 0:
        stepsize = -1
    else:
        stepsize = 1
    for i in range(startPrb, startPrb + numOfPrb, stepsize):
        rat1bitmap[i] = value


def rat1_startprbrandomize(sfn, slot, physcellid, rrmFirstAvailablePrb, rrmRemainingPrb):
    stepSize = 4
    rrmScheduledXSfn = (sfn * 10 + slot)
    primeLarge = 997
    pciSmall = (physcellid % 24) + 1
    randomStep = ((rrmScheduledXSfn + 1 + pciSmall) * primeLarge) % (math.ceil(rrmRemainingPrb / stepSize) + 1)
    randomStartPrb = ''
    if rrmRemainingPrb < stepSize:
        randomStartPrb = rrmFirstAvailablePrb
    else:
        randomStartPrb = rrmFirstAvailablePrb + min(randomStep * stepSize, rrmRemainingPrb)
    return randomStartPrb


def SAS_verification(filename, quota_data, cellbwp):
    pd = install_and_import_pandas()
    # Read the input CSV file
    output_df = pd.read_csv(filename, low_memory=False)
    filt = (output_df['type'] == 'dlFdSchedData') | (output_df['type'] == 'dlSliceData') | (
                output_df['type'] == 'dlPagingOrSibSchedData')
    ws = output_df.loc[
        filt, ['type', 'timeStamp', 'sfn', 'slot', 'rnti', 'physCellId', 'tbSize', 'numOfPrb', 'startPrb', 'dciFormat',
               'rat0Bitmap', 'dciFormat', 'numOfSymbols', 'pdcchStartSymbol', "dlRGData[0].resourceGroupId",
               "dlRGData[0].rrmRGHighInstShare", "dlRGData[0].rrmRGLowInstShare", "dlRGData[0].rrmRGAvgHighShare",
               "dlRGData[0].rrmRGAvgLowShare", "dlRGData[0].rrmRGTargetShareTemp", "dlRGData[0].rrmRGWeightInterm",
               "dlRGData[0].rrmRGWeight", "dlRGData[0].rrmRGLowBufferSlots", "dlRGData[1].resourceGroupId",
               "dlRGData[1].rrmRGHighInstShare", "dlRGData[1].rrmRGLowInstShare", "dlRGData[1].rrmRGAvgHighShare",
               "dlRGData[1].rrmRGAvgLowShare", "dlRGData[1].rrmRGTargetShareTemp", "dlRGData[1].rrmRGWeightInterm",
               "dlRGData[1].rrmRGWeight", "dlRGData[1].rrmRGLowBufferSlots", "dlRGData[2].resourceGroupId",
               "dlRGData[2].rrmRGHighInstShare", "dlRGData[2].rrmRGLowInstShare", "dlRGData[2].rrmRGAvgHighShare",
               "dlRGData[2].rrmRGAvgLowShare", "dlRGData[2].rrmRGTargetShareTemp", "dlRGData[2].rrmRGWeightInterm",
               "dlRGData[2].rrmRGWeight", "dlRGData[2].rrmRGLowBufferSlots", "numberOfRGs", "rrmAvailablePrbsForSas",
               "rrmRGUnusedShare"
               ]]
    filt2 = (output_df['type'] == 'dlSliceData')
    ws = ws.loc[filt2]

    # Define the quota and bandwidth information
    bandwidth = cellbwp
    df = pd.DataFrame(quota_data)

    # Function for calculating target share
    def calculate_target_share(row):
        numerator = row['MaxQuota'] - row['MinQuota']
        denominator = df['MaxQuota'] - df['MinQuota']
        denominator_sum = denominator.sum()
        min_quota_sum = df['MinQuota'].sum()

        target_share = row['MinQuota'] + (numerator / denominator_sum) * (100 - min_quota_sum)
        return target_share / 100  # Convert percentage to decimal
    # Apply the formula to calculate target share for each resource group
    df['TargetShare'] = df.apply(calculate_target_share, axis=1)
    print(df)

    # List of rrmRGAvgLowShare columns to check
    rrm_avg_low_share_columns = ["dlRGData[0].rrmRGAvgLowShare", "dlRGData[1].rrmRGAvgLowShare",
                                 "dlRGData[2].rrmRGAvgLowShare"]
    rrm_avg_low_share_columns = ws[rrm_avg_low_share_columns]

    # Looping through each rrmRGAvgLowShare column
    for i, column_name in enumerate(rrm_avg_low_share_columns):
        # Extract the rrmRGAvgLowShare column
        rrm_avg_low_share_column = rrm_avg_low_share_columns[column_name]

        # Find the maximum value in the column
        max_value = rrm_avg_low_share_column.max()

        # Determine the target_share based on resource group index
        if i == 0:
            target_share = df['TargetShare'].iloc[0]
        elif i == 1:
            target_share = df['TargetShare'].iloc[1]
        elif i == 2:
            target_share = df['TargetShare'].iloc[2]
        else:
            print(f"Unsupported resource group index: {i}")
            continue

        # Compare with target_share within +-5%
        if target_share * 0.95 <= max_value <= target_share * 1.05:
            print(f"RRG{i + 1}: Pass")
            print(max_value, "is within range +-5% range of the calculated target share", df['TargetShare'].iloc[i])
        else:
            print(f"RRG{i + 1}: Fail")
            return 'Fail'

    # Calculate the sum of the rrmRGAvgLowShare of all 3 RGs
    rrm_avg_low_share_sum = rrm_avg_low_share_columns
    rrm_avg_low_share_sum["SumOfLowAvgShare"] = rrm_avg_low_share_sum.sum(axis=1)
    print("Sum of columns:")
    print(rrm_avg_low_share_sum)

    rrm_avg_low_share_sum = rrm_avg_low_share_sum["SumOfLowAvgShare"]

    # Find the maximum value in the column
    max_value = rrm_avg_low_share_sum.max()
    print("Max of rrm_avg_low_share_sum:")
    print(max_value)

    # Compare the max value equals 100% or -2%
    if 0.98 <= max_value <= 1.0:
        print("sum of all Low Avg shares sum to 100% : Pass")
    else:
        print("sum of all Low Avg shares doesn't sum to 100% : Fail")
        return 'Fail'
    return 'Pass'

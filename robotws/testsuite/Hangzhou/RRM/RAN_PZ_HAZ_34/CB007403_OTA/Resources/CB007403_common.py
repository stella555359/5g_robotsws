# -*- coding: utf-8 -*
import re
import copy
import datetime
import linecache
import random
import pprint
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')


def Check_LTE_Cell_ID(cell_id):
    cell_id = cell_id.strip()
    LTE_btsid = eval(cell_id)//256
    LTE_lcrid = eval(cell_id) % 256
    return LTE_btsid, LTE_lcrid


def get_tput_from_syslog(syslog_path=None, sourceCellList=[], targetCellList=[], sourcePCI=None, targetPCI=None,
                         alias='DL'):
    with open(syslog_path, 'r') as f:
        lines = f.readlines()
        tputDataDic = {}
        timeRe = re.compile(r'\d{2}:\d{2}:\d{2}')
        dlCellidRe = re.compile(r'nrCellId (\d+)')
        ulCellidRe = re.compile(r'nrCellIdentity (\d+)')
        for line in lines:
            if ('DataPdu' in line) and ('nrCellId' in line) and alias.upper() == 'DL':
                cellid = dlCellidRe.search(line).group(1)
                if cellid in targetCellList or cellid in sourceCellList:
                    lineTime = timeRe.search(line).group(0)
                    tputDataDic.setdefault(lineTime, {})
                    dlTp = int(line.split('DataPdu: ')[1].split('|')[0]) * 8 / 1024 / 1024
                    dlTp = 0 if int(dlTp) <= 1 else int(dlTp)
                    tputDataDic[lineTime][cellid] = str(dlTp)
                    if cellid in sourceCellList:
                        tputDataDic[lineTime]['source_pci'] = sourcePCI
                        tputDataDic[lineTime]['source_tput'] = tputDataDic[lineTime].get('source_tput', 0) + dlTp
                    if cellid in targetCellList:
                        tputDataDic[lineTime]['target_pci'] = targetPCI
                        tputDataDic[lineTime]['target_tput'] = tputDataDic[lineTime].get('target_tput', 0) + dlTp

            if ('UlCounterUpdate' in line) and ('nrCellIdentity' in line) and alias.upper() == 'UL':
                cellid = ulCellidRe.search(line).group(1)
                if cellid in targetCellList or cellid in sourceCellList:
                    lineTime = timeRe.search(line).group(0)
                    tputDataDic.setdefault(lineTime, {})
                    ulTp = int(line.split(' Bytes received')[0].split('UL: ')[1]) * 8 / 1024 / 1024
                    ulTp = 0 if int(ulTp) <= 1 else int(ulTp)
                    tputDataDic[lineTime][cellid] = str(ulTp)
                    if cellid in sourceCellList:
                        tputDataDic[lineTime]['source_pci'] = sourcePCI
                        tputDataDic[lineTime]['source_tput'] = tputDataDic[lineTime].get('source_tput', 0) + ulTp
                    if cellid in targetCellList:
                        tputDataDic[lineTime]['target_pci'] = targetPCI
                        tputDataDic[lineTime]['target_tput'] = tputDataDic[lineTime].get('target_tput', 0) + ulTp
    tputData = sorted(tputDataDic.items(), key=lambda x: x[0])
    print('\n'.join("{}".format(i) for i in tputData))
    return tputData


def get_source_tput_avg(tputDataDic=None):
    tput_list = \
        [value.get('source_tput', '') for key, value in tputDataDic if value.get('source_tput', '') != '']
    return sum(tput_list) / len(tput_list)


def get_720_counter_from_syslog(syslog_path, celllist=None, alias='DL'):
    tputDataDic = get_tput_from_syslog(syslog_path=syslog_path, sourceCellList=celllist, alias=alias)
    scells_count = 0
    if alias.upper() == 'DL':
        waitStart, waitEnd = True, False
        celllist = celllist[:4]
        i = 0
        for time, value in tputDataDic:
            i += 1
            tputlist = [value.get(x, '') for x in celllist]
            if (tputlist == ['0', '0', '0', '0'] or i == len(tputDataDic)) and waitEnd:
                end = time
                scells_count += getSeconds(start, end)
                waitStart, waitEnd = True, False
            if '0' not in tputlist and waitStart and tputlist != ['', '', '', '']:
                start = time
                waitStart, waitEnd = False, True

    if alias.upper() == 'UL':
        waitStart, waitEnd = True, False
        celllist = celllist[:2]
        i = 0
        for time, value in tputDataDic:
            i += 1
            tputlist = [int(value.get(x, 0)) for x in celllist]
            if (tputlist == [0, 0] or i == len(tputDataDic)) \
                    and waitEnd and [value.get(x, '') for x in celllist] != ['', '']:
                end = time
                scells_count += getSeconds(start, end)
                waitStart, waitEnd = True, False
                # print('ul', start, end,'=',getSeconds(start, end))
            if sum(tputlist) > 11 and waitStart:
                start = time
                waitStart, waitEnd = False, True
    return scells_count


def getSeconds(time1, time2):
    start_time = datetime.datetime.strptime(time1, '%H:%M:%S')
    end_time = datetime.datetime.strptime(time2, '%H:%M:%S')
    return (end_time - start_time).seconds


def dealThptData(targe_Tput, mylist=None, dataLength=10, reverse=False):
    while 0 in mylist:
        mylist.remove(0)
    while '' in mylist:
        mylist.remove('')
    for index in range((len(mylist)-1)):
        diff = mylist[index] + mylist[index+1] - targe_Tput
        if abs(diff) <= 6:
            mylist[index] = targe_Tput
            mylist[index+1] = targe_Tput
    starti = 1
    dataLength = dataLength if len(mylist) > dataLength else len(mylist)
    if reverse:
        checkList = mylist[(-1-dataLength):-1]
    else:
        checkList = mylist[starti:(starti+dataLength)]
    print(checkList)
    return float(sum(checkList))/len(checkList)


def check_ho_tput(
        tputDataDic=None,
        source_excpted=100,
        target_excpted=100,
        pass_rate=0.5,
        gap_seconds=2,
        is_lte_ho=False):
    newList = []
    for time, value in tputDataDic:
        source_pci, target_pci = value.get('source_pci', ''), value.get('target_pci', '')
        source_tput, target_tput = value.get('source_tput', ''), value.get('target_tput', '')
        newList.append([time, source_pci, target_pci, source_tput, target_tput])
    # print '\n'.join(['{}'.format(i) for i in newList])
    # print '\n'.join([str(i) for i in newList])
    startRow, endRow = 0, len(newList)
    for i in range(0, len(newList)):
        for j in range(0, 5):
            if newList[i][j] == '':
                newList[i][j] = newList[i - 1][j] if i != 0 else newList[i + 1][j]
    for i in range(0, len(newList)):
        if str(newList[i][3]) and str(newList[i][4]):
            if newList[i][3] > 0 or newList[i][4] > 0:
                startRow = i
                break
    for i in range(len(newList) - 1, -1, -1):
        if str(newList[i][3]) and str(newList[i][4]):
            if newList[i][3] > 0 or newList[i][4] > 0:
                endRow = i
                break
    # for i in range(startRow, endRow + 1):
        # The number of consecutive overlaps cannot exceed 3
        # if not is_lte_ho:
        #     if newList[i][3] != 0 and newList[i][4] != 0:
        #         tput_on_two_cell_count = 0
        #         for x in range(i, endRow + 1):
        #             if newList[x][3] != 0 and newList[x][4] != 0:
        #                 tput_on_two_cell_count += 1
        #                 if tput_on_two_cell_count > 3:
        #                     return False
        #             else:
        #                 break
        # continuous zero traffic cannot exceed gap_seconds
        # if newList[i][3] == 0 and newList[i][4] == 0:
        #     tput_on_two_cell_count = 0
        #     for x in range(i, endRow + 1):
        #         if newList[x][3] != 0 and newList[x][4] != 0:
        #             tput_on_two_cell_count += 1
        #             if tput_on_two_cell_count > gap_seconds:
        #                 return False
        #         else:
        #             break
    # compare with attach tput
    y = True
    source_t = dealThptData(targe_Tput=source_excpted, mylist=[x[3] for x in newList])
    target_t = dealThptData(targe_Tput=target_excpted, mylist=[x[4] for x in newList], reverse=True)
    if float(source_excpted) == 0:
        source_excpted = 1
    if float(target_excpted) == 0:
        target_excpted = 1
    if float(source_t) / float(source_excpted) < pass_rate:
        print('tput on source cell was downgrade')
        y = False
    if float(target_t) / float(target_excpted) < pass_rate:
        print('tput on target cell was downgrade')
        y = False
    return y

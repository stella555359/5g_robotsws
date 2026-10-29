import sys
import csv
import re
import os
from collections import OrderedDict


class CsvReader(object):
    def __init__(self):
        self.strultrace, self.strdltrace = '_ul.csv', '_dl.csv'
        self.STR_UL_crcResult = "ulHarqRxData.crcResult"
        self.STR_DL_ackNack = "dlHarqRxDataArray.ackNack"

    def common_get_ttitrace_reader(self, filename):
        list_ttitrace = []
        with open(filename, 'r') as file1:
            data = csv.reader(file1)
            for Row_of_date in data:
                list_ttitrace.append(Row_of_date)
        return list_ttitrace

    def Insert_OneLine_In_Csv_Top(self, csvName):
        list_ttitrace = self.common_get_ttitrace_reader(filename=csvName)
        csvNameNew = os.path.dirname(csvName) + '/New' + os.path.basename(csvName)
        with open(csvNameNew, 'w', newline='') as f2:
            csvWriter = csv.writer(f2)
            csvWriter.writerow("Insert One Row")
            for line in list_ttitrace:
                csvWriter.writerow(line)
        return csvNameNew

    def Insert_between(self, lista, listb):
        newList = []
        for i in range(0, len(lista)):
            instr = listb if type(listb) is str else listb[i]
            newList += [lista[i], instr]
        return newList

    def Return_Table_Content_to_Format(self, filename):
        csvContent = filename + os.linesep
        with open(filename, newline='') as csvfile:
            csvreader = csv.reader(csvfile, delimiter=',')
            headers = next(csvreader)
            csvContent += ' '.join([f"{header:30}" for header in headers]) + os.linesep
            csvContent += ' '.join(['-' * 30 for _ in headers]) + os.linesep
            for row in csvreader:
                csvContent += ' '.join([f"{item:30}" for item in row]) + os.linesep
            return csvContent

    def common_get_ttitrace_file_list(self, filepath):
        filelist, strTrace = [], '.csv'
        files = os.listdir(filepath)
        for f in files:
            if (f.endswith(strTrace) and (re.search(self.strultrace, f) or re.search(self.strdltrace, f))):
                filelist.append("%s%s" % (filepath, f))
        return filelist

    def common_get_column_value_to_List(self, Ttitrace, ColumnName, converter):
        csvNameNew = self.Insert_OneLine_In_Csv_Top(Ttitrace)
        with open(csvNameNew, 'r') as f:
            f.readline()
            dictr = csv.DictReader(f)
            vList = []
            for line in dictr:
                if ColumnName in line and line[ColumnName] != "":
                    vList.append(converter(line[ColumnName]))
        os.remove(csvNameNew)
        return vList


class GetSlotPatternFromBip(object):
    def __init__(self):
        self.TddFrameStructure11160ms = \
            ['D', 'D', 'D', 'S', 'U', 'U', 'D', 'D', 'D', 'D', 'D', 'D', 'D', 'S', 'U', 'U', 'D', 'D', 'D', 'D']
        self.TddFrameStructure11163ms = \
            ['D', 'D', 'D', 'D', 'D', 'D', 'D', 'S', 'U', 'U', 'D', 'D', 'D', 'D', 'D', 'D', 'D', 'S', 'U', 'U']
        self.TddFrameStructure1208 = \
            ['D', 'D', 'D', 'S', 'U', 'D', 'D', 'D', 'S', 'U', 'D', 'D', 'D', 'S', 'U', 'D', 'D', 'D', 'S', 'U']
        self.TddFrameStructure1070 = \
            ['D', 'D', 'D', 'S', 'U', 'D', 'D', 'S', 'U', 'U', 'D', 'D', 'D', 'S', 'U', 'D', 'D', 'S', 'U', 'U']
        self.avrPeriodSfn = 16
        self.slotNumOneSfn = 20
        self.reader = CsvReader()

    def Judge_TddFrameStructure(self, TddFrameStructureIn):
        if '1116' in TddFrameStructureIn and '0ms' in TddFrameStructureIn:
            TddFrameStructure = self.TddFrameStructure11160ms
        elif '1116' in TddFrameStructureIn and '3ms' in TddFrameStructureIn:
            TddFrameStructure = self.TddFrameStructure11163ms
        elif '1208' in TddFrameStructureIn:
            TddFrameStructure = self.TddFrameStructure1208
        elif '1070' in TddFrameStructureIn:
            TddFrameStructure = self.TddFrameStructure1070
        else:
            print('Please input a valid TddFrameStructure!!!')
        return TddFrameStructure

    def Create_SlotPattern_From_TddFrameStructure(self, TddFrameStructure):
        SlotPatternDict = OrderedDict()
        for sfn in range(0, self.avrPeriodSfn):
            SlotPatternDict[sfn] = {}
            for slot in range(0, self.slotNumOneSfn):  # tdd slots
                SlotPatternDict[sfn][slot] = {}
                SlotPatternDict[sfn][slot]['SlotType'] = TddFrameStructure[slot]
                SlotPatternDict[sfn][slot]['PRB'] = {}
                SlotPatternDict[sfn][slot]['BLER'] = {}
        return SlotPatternDict

    def Get_SSB_slot_from_Bip_Csv(self, csvName, SlotPatternDict):
        with open(csvName, 'r') as f:
            f.readline()
            dictr = csv.DictReader(f)
            for line in dictr:
                if 'MIB' in line['_ws.col.info']:
                    sfn = int(line['3gpp.sfn']) % self.avrPeriodSfn
                    slot = int(line['3gpp.slot'])
                    numOfPrbSSB = 20 if int(line['nr-rrc.ssb_SubcarrierOffset']) == 0 else 21
                    SlotPatternDict[sfn][slot]['SlotType'] = 'SSB'
                    SlotPatternDict[sfn][slot]['PRB']['SSB'] = numOfPrbSSB
        return SlotPatternDict

    def Get_CsiRs_slot_from_Bip_Csv(self, csvName, SlotPatternDict):
        regPrb = r'(\d+),'
        with open(csvName, 'r') as f:
            f.readline()
            dictr = csv.DictReader(f)
            for line in dictr:
                if 'dldata_csirssendreql1sw' in line['_ws.col.info'] and (
                        '0' in line['DlData_CsiRsResourceL1sw_t.trsInfo']
                        or '1' in line['DlData_CsiRsResourceL1sw_t.trsInfo']):
                    sfn = int(line['3gpp.sfn']) % self.avrPeriodSfn
                    slot = int(line['3gpp.slot'])
                    startPrb = re.match(regPrb, line['DlData_CsiRsResourceL1sw_t.startPrb']).group(1)
                    numOfPrb = re.match(regPrb, line['DlData_CsiRsResourceL1sw_t.numOfPrb']).group(1)
                    if '0' in line['DlData_CsiRsResourceL1sw_t.trsInfo']:
                        SlotPatternDict[sfn][slot]['PRB']['Cb'] = int(numOfPrb)
                    else:
                        SlotPatternDict[sfn][slot]['SlotType'] = 'TRS'
        return SlotPatternDict

    def Get_SIB_slot_from_Bip_Csv(self, csvName, SlotPatternDict):
        with open(csvName, 'r') as f:
            f.readline()
            dictr = csv.DictReader(f)
            for line in dictr:
                if 'dldata_pdschsendreql1sw' in line['_ws.col.info']:
                    sfn = int(line['3gpp.sfn']) % self.avrPeriodSfn
                    slot = int(line['3gpp.slot'])
                    SlotPatternDict[sfn][slot]['SlotType'] = 'SIB/OSI'
                    SlotPatternDict[sfn][slot]['PRB']['SIB/OSI'] = int(line['DlData_PdschGrantL1sw.numOfPrb'])
        return SlotPatternDict

    def Update_SlotPattern_From_Bip_csv(self, csvBIP, TddFrameStructureIn):
        TddFrameStructure = self.Judge_TddFrameStructure(TddFrameStructureIn)
        SlotPatternDict = self.Create_SlotPattern_From_TddFrameStructure(TddFrameStructure)
        csvNameBIPNew = self.reader.Insert_OneLine_In_Csv_Top(csvBIP)
        SlotPatternDict = self.Get_SSB_slot_from_Bip_Csv(csvNameBIPNew, SlotPatternDict)
        SlotPatternDict = self.Get_CsiRs_slot_from_Bip_Csv(csvNameBIPNew, SlotPatternDict)
        SlotPatternDict = self.Get_SIB_slot_from_Bip_Csv(csvNameBIPNew, SlotPatternDict)
        os.remove(csvNameBIPNew)
        return SlotPatternDict


class UpdateSlotPatternFromL2TTi(object):
    def __init__(self):
        self.reader = CsvReader()
        self.SPFromBip = GetSlotPatternFromBip()

    def Get_FD_schedule_fromm_ttitrace(self, csvName, physCellId):
        FdPrbDict = OrderedDict()
        with open(csvName, 'r') as f:
            f.readline()
            dictr = csv.DictReader(f)
            for line in dictr:
                if line['physCellId'] == physCellId and line['dlFdSchedData.dciFormat'] != '':
                    timeStamp = line['timeStamp'][:-5]
                    if timeStamp not in FdPrbDict:
                        FdPrbDict[timeStamp] = {}
                    sfn = int(line['sfn']) % self.SPFromBip.avrPeriodSfn
                    if sfn not in FdPrbDict[timeStamp]:
                        FdPrbDict[timeStamp][sfn] = {}
                    slot = int(line['slot'])
                    if slot not in FdPrbDict[timeStamp][sfn]:
                        FdPrbDict[timeStamp][sfn][slot] = {}
                    if 'PRB' not in FdPrbDict[timeStamp][sfn][slot]:
                        FdPrbDict[timeStamp][sfn][slot]['PRB'], FdPrbDict[timeStamp][sfn][slot]['TBS'] = 0, 0
                        FdPrbDict[timeStamp][sfn][slot]['BufferNotFull'] = 'N'
                        FdPrbDict[timeStamp][sfn][slot]['BLER'] = {}
                    FdPrbDict[timeStamp][sfn][slot]['PRB'] += int(float(line['dlFdSchedData.numOfPrb']))
                    if float(line['dlFdSchedData.tbSize']) / 8 >= float(line['dlFdSchedData.rrmBufferedDataDlTotal']):
                        FdPrbDict[timeStamp][sfn][slot]['BufferNotFull'] = 'Y'
                    if line['dlFdSchedData.ackNack'] == 'ACK':
                        FdPrbDict[timeStamp][sfn][slot]['TBS'] += int(float(line['dlFdSchedData.tbSize']))
                    for harq in ['ACK', 'NACK', 'DTX']:
                        if harq not in FdPrbDict[timeStamp][sfn][slot]['BLER']:
                            FdPrbDict[timeStamp][sfn][slot]['BLER'][harq] = 0
                        if line['dlFdSchedData.ackNack'] == harq:
                            FdPrbDict[timeStamp][sfn][slot]['BLER'][harq] += 1
        return FdPrbDict

    def Update_FD_schedule_to_SlotPattern(self, FdPrbDict, SlotPatternDict, ignoreNotFullBuffer):
        for timeStamp in FdPrbDict:
            if timeStamp not in [min(FdPrbDict), max(FdPrbDict)]:
                for sfn in FdPrbDict[timeStamp]:
                    for slot in FdPrbDict[timeStamp][sfn]:
                        if 'FD' not in SlotPatternDict[sfn][slot]['PRB']:
                            SlotPatternDict[sfn][slot]['PRB']['FD'] = []
                            for harq in ['ACK', 'NACK', 'DTX']:
                                SlotPatternDict[sfn][slot]['BLER'][harq] = 0
                        if ignoreNotFullBuffer == 'N':
                            SlotPatternDict[sfn][slot]['PRB']['FD'].append(FdPrbDict[timeStamp][sfn][slot]['PRB'])
                        elif ignoreNotFullBuffer == 'Y':
                            if FdPrbDict[timeStamp][sfn][slot]['BufferNotFull'] == 'N':
                                SlotPatternDict[sfn][slot]['PRB']['FD'].append(FdPrbDict[timeStamp][sfn][slot]['PRB'])
                        else:
                            print('Please enter right value of "ignoreNotFullBuffer" in [Y, N]. ')
                        for harq in FdPrbDict[timeStamp][sfn][slot]['BLER']:
                            SlotPatternDict[sfn][slot]['BLER'][harq] += FdPrbDict[timeStamp][sfn][slot]['BLER'][harq]
        for sfn in SlotPatternDict:
            for slot in SlotPatternDict[sfn]:
                if 'FD' in SlotPatternDict[sfn][slot]['PRB'] and SlotPatternDict[sfn][slot]['PRB']['FD'] == []:
                    del SlotPatternDict[sfn][slot]['PRB']['FD']
                for item in SlotPatternDict[sfn][slot]['PRB']:
                    for prb in ['minPRB', 'maxPRB', 'avrPRB']:
                        if prb not in SlotPatternDict[sfn][slot]:
                            SlotPatternDict[sfn][slot][prb] = 0
                    prbNum = SlotPatternDict[sfn][slot]['PRB'][item]
                    SlotPatternDict[sfn][slot]['maxPRB'] += max(prbNum) if type(prbNum) is list else prbNum
                    SlotPatternDict[sfn][slot]['minPRB'] += min(prbNum) if type(prbNum) is list else prbNum
                    SlotPatternDict[sfn][slot]['avrPRB'] += int(sum(prbNum) / len(prbNum)) if type(
                        prbNum) is list else prbNum
        return SlotPatternDict

    def Update_SlotPattern_From_L2TTi(self, csvTtitrace, SlotPatternDict, physCellId, ignoreNotFullBufferSliot):
        # print('SlotPattern from BIP:--> ', SlotPatternDict)
        csvTtitraceNew = self.reader.Insert_OneLine_In_Csv_Top(csvTtitrace)
        FdPrbDict = self.Get_FD_schedule_fromm_ttitrace(csvTtitraceNew, physCellId)
        os.remove(csvTtitraceNew)
        # print('FD schedule from Ttitrace:--> ', FdPrbDict)
        SlotPatternDict = self.Update_FD_schedule_to_SlotPattern(FdPrbDict, SlotPatternDict, ignoreNotFullBufferSliot)
        # print('SlotPattern update:--> ', SlotPatternDict)
        return SlotPatternDict, FdPrbDict


class Generate_Summary_To_New_Csv(object):
    def __init__(self):
        self.SlotPatternFromBip = GetSlotPatternFromBip()
        self.SlotPatternFromTTi = UpdateSlotPatternFromL2TTi()
        self.reader = CsvReader()

    def Create_csv_for_Tput_form_Dict(self, csvNameTtitrace, FdPrbDict, physCellId):
        csvNameNew = os.path.dirname(csvNameTtitrace) + '/Cell' + physCellId + '_DL_Tput_and_Bler.csv'
        with open(csvNameNew, 'w', newline='') as f:
            csvWriter = csv.writer(f)
            Header = ['timeStamp', 'Tput(Mbits/S)', 'Bler']
            csvWriter.writerow(Header)
            tbsList, blerList = [], []
            for timeStamp in FdPrbDict:
                if timeStamp not in [min(FdPrbDict), max(FdPrbDict)]:
                    line, TBS, blerDict = [timeStamp], 0, {'ACK': 0, 'NACK': 0, 'DTX': 0}
                    for sfn in FdPrbDict[timeStamp]:
                        for slot in FdPrbDict[timeStamp][sfn]:
                            TBS += FdPrbDict[timeStamp][sfn][slot]['TBS']
                            for harq in blerDict:
                                blerDict[harq] += FdPrbDict[timeStamp][sfn][slot]['BLER'][harq]
                    tput = TBS * 10 / 1000 / 1000
                    ack, nack, dtx = blerDict['ACK'], blerDict['NACK'], blerDict['DTX']
                    bler = sum([nack, dtx]) / sum([ack, nack, dtx])
                    line.append(tput), line.append(bler)
                    tbsList.append(tput), blerList.append(bler)
                    csvWriter.writerow(line)
            avrTput, avrBler = sum(tbsList) / len(tbsList), sum(blerList) / len(blerList)
            avr = ['average', avrTput, avrBler]
            csvWriter.writerow(avr)
        csvTputContent = self.reader.Return_Table_Content_to_Format(csvNameNew)
        return csvNameNew, avrTput, avrBler, csvTputContent

    def Update_csv_for_Bler_form_Dict(self, csvNameTtitrace, SlotPatternDict):
        with open(csvNameTtitrace, 'a', newline='') as f:
            csvWriter = csv.writer(f)
            csvWriter.writerow(os.linesep)
            csvWriter.writerow(["Detail Bler per xSFN per Slot: "])
            Header = list(SlotPatternDict[0])
            newHeader = self.reader.Insert_between(Header, "")
            newHeader.insert(0, 'SFN/Slot')
            csvWriter.writerow(newHeader)
            for sfn in SlotPatternDict:
                slotPattern, line = [], []
                for slot in SlotPatternDict[sfn]:
                    slotPattern.append(SlotPatternDict[sfn][slot]['SlotType'])
                    if 'BLER' in SlotPatternDict[sfn][slot] and len(SlotPatternDict[sfn][slot]['BLER']) > 0:
                        numACK = SlotPatternDict[sfn][slot]['BLER']['ACK']
                        numNACK = SlotPatternDict[sfn][slot]['BLER']['NACK']
                        numDTX = SlotPatternDict[sfn][slot]['BLER']['DTX']
                        if sum([numACK, numNACK, numDTX]) > 0:
                            blerSlot = sum([numNACK, numDTX]) / sum([numACK, numNACK, numDTX])
                        line.append(blerSlot)
                    else:
                        line.append('')
                newLine = self.reader.Insert_between(line, slotPattern)
                newLine.insert(0, sfn)
                csvWriter.writerow(newLine)

    def Create_csv_for_avrPRB_form_Dict(self, csvNameTtitrace, SlotPatternDict, physCellId):
        csvNameNew = os.path.dirname(csvNameTtitrace) + '/Cell' + physCellId + '_DL_PRB.csv'
        with open(csvNameNew, 'w', newline='') as f:
            csvWriter = csv.writer(f)
            Header0 = ["average PRB per xSFN : "]
            csvWriter.writerow(Header0)
            Header = list(SlotPatternDict[0])
            newHeader = self.reader.Insert_between(Header, "SlotType")
            newHeader.insert(0, "SFN/Slot")
            csvWriter.writerow(newHeader)
            for sfn in SlotPatternDict:
                slotPattern, line = [], []
                for slot in SlotPatternDict[sfn]:
                    slotPattern.append(SlotPatternDict[sfn][slot]['SlotType'])
                    if 'avrPRB' in SlotPatternDict[sfn][slot]:
                        line.append(SlotPatternDict[sfn][slot]['avrPRB'])
                    else:
                        line.append('')
                newLine = self.reader.Insert_between(line, slotPattern)
                newLine.insert(0, sfn)
                csvWriter.writerow(newLine)
        return csvNameNew

    def Get_PrbDict_for_diff_slotType(self, SlotPatternDict):
        PrbDictOnSlotType = OrderedDict()
        for sfn in SlotPatternDict:
            for slot in SlotPatternDict[sfn]:
                if len(SlotPatternDict[sfn][slot]['PRB']) > 0:
                    if 'FD' in SlotPatternDict[sfn][slot]['PRB']:
                        SlotType = SlotPatternDict[sfn][slot]['SlotType']
                        if SlotType not in PrbDictOnSlotType:
                            PrbDictOnSlotType[SlotType] = []
                        rbList, typeList = [0, 0, 0], ['SSB', 'Cb', 'SIB/OSI']
                        for index, type in enumerate(typeList):
                            if type in SlotPatternDict[sfn][slot]['PRB']:
                                rbList[index] = SlotPatternDict[sfn][slot]['PRB'][type]
                        for rbNum in SlotPatternDict[sfn][slot]['PRB']['FD']:
                            PrbDictOnSlotType[SlotType].append(sum(rbList, rbNum))
        return PrbDictOnSlotType

    def Update_csv_for_FRB_on_SlotType(self, csvNameTtitrace, FdPrbDict):
        with open(csvNameTtitrace, 'a', newline='') as f:
            csvWriter = csv.writer(f)
            csvWriter.writerow(os.linesep)
            csvWriter.writerow(["PRB on different SlotType : "])
            Header = ['SlotType', 'Scheduled PRB list(not include those slots '
                                  'which are BufferNotFull when setting "ignoreNotFullBufferSlot=Y"']
            csvWriter.writerow(Header)
            for slotType in FdPrbDict:
                line = [slotType, set(FdPrbDict[slotType])]
                csvWriter.writerow(line)

    def Update_csv_for_FD_Schedule_form_Dict(self, csvNameTtitrace, FdPrbDict, SlotPatternDict):
        with open(csvNameTtitrace, 'a', newline='') as f:
            csvWriter = csv.writer(f)
            csvWriter.writerow(os.linesep)
            csvWriter.writerow(["Detail FD Schedule : "])
            Header = ['timestamp', 'sfn', 'slot', 'SSB', 'Cb', 'SIB/OSI', 'FD', 'Total',
                      'TBS', 'BufferNotFull', 'ACK', 'NACK', 'DTX']
            csvWriter.writerow(Header)
            for timestamp in FdPrbDict:
                if timestamp not in [min(FdPrbDict), max(FdPrbDict)]:
                    for sfn in FdPrbDict[timestamp]:
                        for slot in FdPrbDict[timestamp][sfn]:
                            line = [timestamp, sfn, slot]
                            for rbType in Header[3:6]:
                                if rbType in SlotPatternDict[sfn][slot]['PRB']:
                                    line.append(SlotPatternDict[sfn][slot]['PRB'][rbType])
                                else:
                                    line.append(0)
                            for item in FdPrbDict[timestamp][sfn][slot]:
                                if type(FdPrbDict[timestamp][sfn][slot][item]) not in [str, int]:
                                    for item1 in FdPrbDict[timestamp][sfn][slot][item]:
                                        line.append(FdPrbDict[timestamp][sfn][slot][item][item1])
                                else:
                                    line.append(FdPrbDict[timestamp][sfn][slot][item])
                            line.insert(7, sum(line[3:7]))
                            csvWriter.writerow(line)

    def Generate_Summary_Csv_For_reference(self, bipCsv, Ttitrace, FrameType, physCellId, ignoreNotFullBufferSliot):
        SlotPatternDict = self.SlotPatternFromBip.Update_SlotPattern_From_Bip_csv(bipCsv, FrameType)
        SlotPatternDict, FdPrbDict = self.SlotPatternFromTTi.Update_SlotPattern_From_L2TTi(
            Ttitrace, SlotPatternDict, physCellId, ignoreNotFullBufferSliot)
        csvTput, avrTput, avrBler, csvTputContent = self.Create_csv_for_Tput_form_Dict(Ttitrace, FdPrbDict, physCellId)
        self.Update_csv_for_Bler_form_Dict(csvTput, SlotPatternDict)
        csvPrb = self.Create_csv_for_avrPRB_form_Dict(Ttitrace, SlotPatternDict, physCellId)
        PrbDictOnSlotType = self.Get_PrbDict_for_diff_slotType(SlotPatternDict)
        self.Update_csv_for_FRB_on_SlotType(csvPrb, PrbDictOnSlotType)
        self.Update_csv_for_FD_Schedule_form_Dict(csvPrb, FdPrbDict, SlotPatternDict)
        return PrbDictOnSlotType, csvTputContent


class Log_Check(object):
    def __init__(self):
        self.reader = CsvReader()
        self.Summary = Generate_Summary_To_New_Csv()

    def Check_PrbNum_Should_as_Expected_on_SlotType(self, PrbDictOnSlotType, prbExpression, percent, slotType):
        p = ""
        reg = r"([><=]+)(\d+)"
        legalOperators = [">", "<", "==", "!=", ">=", "<="]
        try:
            operator, prbNum = re.search(reg, prbExpression).group(1), re.search(reg, prbExpression).group(2)
        except AttributeError:
            p = 'Input prbExpression err...'
            return False, 'False --> ' + p
        if operator in legalOperators:
            if slotType in PrbDictOnSlotType:
                if slotType in PrbDictOnSlotType:
                    count = 0
                    for value in PrbDictOnSlotType[slotType]:
                        if eval(str(value) + operator + prbNum):
                            count += 1
                    percentCur = count / len(PrbDictOnSlotType[slotType])
                    p = 'Expect: slotType={}, PRB{}; percent>={} --> Schedule Summary: {} in {}, percent: {}.' \
                        .format(slotType, prbExpression, percent, count, len(PrbDictOnSlotType[slotType]), percentCur)
                    if percentCur >= float(percent):
                        return True, 'True --> ' + p
                else:
                    p = 'Please enter a valid slotType in: [ SSB, SIB/OSI, TRS, D, S ] '
                return False, 'False --> ' + p
            else:
                p = 'Expect: slotType={}, PRB{}; percent>={} --> Schedule Summary: {} in {}, percent: {}.' \
                    .format(slotType, prbExpression, percent, 0, 0, 0)
                return False, 'False --> ' + p
        else:
            p = 'ERR: operators check Fail, please enter valid operators in : {}'.format(legalOperators)
            return False, 'False --> ' + p

    def Verify_PrbNum_Percentage_as_expected(
            self, bipCsv, Ttitrace, FrameType, physCellId, ignoreNotFullBufferSliot, slotType, prbExpression, percent):
        PrbDictOnSlotType, csvTputContent = self.Summary.Generate_Summary_Csv_For_reference(
            bipCsv, Ttitrace, FrameType, physCellId, ignoreNotFullBufferSliot)
        rst, p = self.Check_PrbNum_Should_as_Expected_on_SlotType(PrbDictOnSlotType, prbExpression, percent, slotType)
        return rst, p

    def Verify_Column_Average_Value_Should_In_Range(self, Ttitrace, ColumnName, minValue, maxValue):
        rst = False
        vList = self.reader.common_get_column_value_to_List(Ttitrace, ColumnName, float)
        avr = sum(vList) / len(vList)
        if avr >= float(minValue) and avr <= float(maxValue):
            rst = True
        p = 'Check result: {}; Avrage value is: {}, should in : [{} - {}]'.format(rst, avr, minValue, maxValue)
        return rst, p

    def Summary_harq_info_bler_rate_in_file(self, filename, rate):
        retString = ''
        if (re.search(self.reader.strultrace, filename)):
            crcName, ackValue, nackValue, dtxValue = self.reader.STR_UL_crcResult, "OK", "NOK", "DTX"
        elif (re.search(self.reader.strdltrace, filename)):
            crcName, ackValue, nackValue, dtxValue = self.reader.STR_DL_ackNack, "ACK", "NACK", "DTX"
        harqList = self.reader.common_get_column_value_to_List(filename, crcName, str)
        countsHarqACK, countsHarqNACK, countsHarqDTX \
            = harqList.count(ackValue), harqList.count(nackValue), harqList.count(dtxValue)
        countsHarqTotal = sum([countsHarqNACK, countsHarqDTX, countsHarqACK])
        result = False if ((float(countsHarqNACK + countsHarqDTX) / countsHarqTotal) > float(rate)) else True
        # retString += "=== %s ===" % os.path.basename(filename) + '\r\n'
        retString += "=== %s ===" % filename + '\r\n'
        retString += "  HARQ check result: %s | Totol : %d | NACK : %d | DTX : %d" % \
                     (result, countsHarqTotal, countsHarqNACK, countsHarqDTX) + '\r\n'
        retString += "  NACK/DTX error percent: %.3f" % (
                float(countsHarqNACK + countsHarqDTX) / countsHarqTotal) + '\r\n'
        print(retString)
        return retString


def Generate_Summary_Csv(bipCsv, Ttitrace, FrameType, physCellId, ignoreNotFullBufferSliot):
    PrbDictOnSlotType, csvTputContent = Generate_Summary_To_New_Csv().Generate_Summary_Csv_For_reference(
        bipCsv, Ttitrace, FrameType, physCellId, ignoreNotFullBufferSliot)
    return PrbDictOnSlotType, csvTputContent


def Check_PrbNum_Should_as_Expected_on_SlotType(PrbDictOnSlotType, prbExpression, percent, slotType):
    r, p = Log_Check().Check_PrbNum_Should_as_Expected_on_SlotType(PrbDictOnSlotType, prbExpression, percent, slotType)
    return r, p


def Verify_Column_Average_Value_Should_In_Range(Ttitrace, ColumnName, minValue, maxValue):
    r, p = Log_Check().Verify_Column_Average_Value_Should_In_Range(Ttitrace, ColumnName, minValue, maxValue)
    return r, p


def Summary_harq_info_bler_rate_in_path(path, rate):
    filelist = CsvReader().common_get_ttitrace_file_list(path)
    print("**********Expect bler is not higher than: %.3f **********" % (float(rate)) + '\r\n')
    ret = ""
    for filename in filelist:
        print("filename: ", filename)
        ret = ret + Log_Check().Summary_harq_info_bler_rate_in_file(filename, rate)
    return ret


if __name__ == '__main__':
    # path = "C:\\jiangliyun\\5G\\2024_E2E_Testing\\Features\\CB008927\\log\\
    # CB008927_19_ST_AP\\0419\\CB008927_19_ST_gscn-7854_siTargetRate_0\\ttitrace\\"
    # retString = Summary_harq_info_bler_rate_in_path(path, 0.1)

    check = Log_Check()
    rst, p = check.Verify_PrbNum_Percentage_as_expected(
        "./bip_gnb.csv", './output_dl.csv', '1208', '50', "Y", "SIB/OSI", '==273', '0.95')
    print(p)
    rst, p = check.Verify_Column_Average_Value_Should_In_Range(
        './output_dl.csv', 'dlSliceData.dlRGData[0].rrmRGLowInstShare', 0.3, 0.6)
    print(p)
    # # rst, p = check.Verfify_Column_Average_Value_Should_In_Range(
    # #     './output_dl.csv', 'dlSliceData.dlRGData[1].rrmRGLowInstShare', 0.4, 0.7)

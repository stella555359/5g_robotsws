import json
import re
import os
import datetime

from statistics import mean, pstdev


def convertToDict(file):
    input_file_fd = open(file, 'r')
    return json.loads(input_file_fd.readline())


def myFnGetNrCellCounter(countersData, MRBTS, NRBTS, NRCELL, Meas, counterList, measPeriod):
    extract = {}
    for cellId in NRCELL:
        nrCellId = "NRCELL-" + str(cellId)
        extract[nrCellId] = {}
        for counterId in counterList:
            extract[nrCellId][counterId] = countersData['BTS'][MRBTS][NRBTS][nrCellId][Meas][counterId][measPeriod]
    return extract


def csiRsPoolGroupReportPeriod(cellList, csiRsReportPeriod, csiRsGroups):
    csiRsInfo = {}
    for item in csiRsGroups:
        index = cellList.index(str(item['lcrId']))
        csiRsInfo[item['csirsPoolingGroupId']] = {"lcrId": item['lcrId'], "csiRsReportPeriod": csiRsReportPeriod[index]}
    return csiRsInfo


def compareValue(tput1, tput2, errorOk):
    if min(int(tput1), int(tput2)) > max(int(tput1), int(tput2)) * (100-errorOk)/100:
        return "OK"
    else:
        return "notOK"


def writeCsiRsConfigTrs(file, config):
    input_file_fd = open(file, 'a')
    input_file_fd.write("\n*************\nTRS Config\n*************\n")
    for data in config:
        input_file_fd.write("\n\tcsirsPoolingGroupId " + str(data['csirsPoolingGroupId']) + "\n")
        for data2 in data['csirsTrackingResourceSet']:
            input_file_fd.write("\t\tssbIndex " + str(data2['ssbIndex']) + "\n")
            for data3 in data2['csirsTrackingResource']:
                input_file_fd.write("\t\t\t" + str(data3) + "\n")
    input_file_fd.close()


def writeCsiRsConfigCellSpe(file, config, csirsGroups):
    mapping = {}
    for data in csirsGroups:
        mapping[data['cell']] = data['csirsPoolingGroupId']
    print(mapping)
    input_file_fd = open(file, 'a')
    # input_file_fd.write("\n***********************\nCell Specific Config\n***********************\n")
    for data in config:
        input_file_fd.write(
            "\n\tcellId " + str(data['cellId']) + " / csiRsGroup " + str(mapping[data['cellId']]) + "\n")
        for data2 in data['resource_set']:
            input_file_fd.write("\t\tresource_set\n")
            # input_file_fd.write("\t\t" + str(data2) + "\n")
            for data3 in data2['res']:
                input_file_fd.write("\t\t\t" + str(data3) + "\n")
            # input_file_fd.write("\tresource_set " + str(data['resource_set']) + "\n")
    input_file_fd.close()


def tputStat(file, stats):

    tputByRun = []
    for value in stats:
        print(value)
        sum = 0
        for cle in value.keys():
            sum += value[cle][0]
        tputByRun.append(round(sum, 2))
    input_file_fd = open(file, 'a')
    input_file_fd.write("\tResult:" + str(tputByRun) + "\n")
    input_file_fd.write(
        "\tAverage: " + str(round(mean(tputByRun), 2)) + ", Ecart Type: " + str(round(pstdev(tputByRun), 2)))
    input_file_fd.close()

    return round(mean(tputByRun), 2)


file = "/tmp/result.txt"
stats = [
    {'101': [1207.458, 0.0, 26.545, 0], '103': [1224.437, 0.0, 26.694, 0], '105': [1091.964, 0.61, 26.429, 0]},
    {'101': [1222.46, 0.0, 26.599, 0], '103': [1179.56, 0.0, 26.785, 0], '105': [1108.246, 0.0, 26.654, 0]},
    {'101': [1446.622, 0.62, 26.192, 0], '103': [1084.513, 0.97, 26.5, 0], '105': [904.97, 0.39, 26.387, 0]},
    {'101': [1483.509, 0.0, 26.553, 0], '103': [1108.692, 0.42, 26.646, 0], '105': [894.498, 0.87, 26.291, 0]},
    {'101': [1488.352, 0.0, 26.572, 0], '103': [1082.365, 0.24, 26.591, 0], '105': [915.784, 0.0, 26.833, 0]},
    {'101': [1473.285, 0.0, 26.527, 0], '103': [1093.078, 0.07, 26.598, 0], '105': [898.213, 1.1, 26.245, 0]},
    {'101': [1487.02, 0.0, 26.56, 0], '103': [1060.049, 0.27, 26.591, 0], '105': [898.968, 0.63, 26.377, 0]},
    {'101': [1401.642, 0.97, 25.817, 0], '103': [1155.906, 0.82, 26.372, 0], '105': [893.352, 1.3, 25.945, 0]},
    {'101': [1488.183, 0.0, 26.557, 0], '103': [1119.938, 0.0, 26.558, 0], '105': [904.479, 0.45, 26.51, 0]},
    {'101': [1309.877, 0.0, 26.575, 0], '103': [1186.005, 0.3, 26.504, 0], '105': [1035.91, 0.14, 26.53, 0]}]
tputStat(file, stats)


# ########################################################################################################
# ########################################################################################################

class csiRsCellSpec:

    def __init__(self):

        # en tete et numero de colonne a extraire
        self.csiRsSchedData_hfn_field = "hfnTickCount"
        self.csiRsSchedData_hfn = None
        self.csiRsSchedData_sfn_field = "sfn"
        self.csiRsSchedData_sfn = None
        self.csiRsSchedData_slot_field = "slot"
        self.csiRsSchedData_slot = None
        self.csiRsSchedData_pci_field = "physCellId"
        self.csiRsSchedData_pci = None
        self.csiRsSchedData_startSymb_field = "startSymbol"
        self.csiRsSchedData_startSymb = None

        self.first_csiRsSchedData = True   # Au premier msg, on recherche les index des champs

        self.data = {}
        self.output = {}

    def closeFileFilter(self):
        self.file_filtered_fd.close()

    def findPos_csiRsSchedData(self, fields):
        offset_value = int(len(fields) / 2)
        self.csiRsSchedData_hfn = fields.index(self.csiRsSchedData_hfn_field) + offset_value
        self.csiRsSchedData_sfn = fields.index(self.csiRsSchedData_sfn_field) + offset_value
        self.csiRsSchedData_slot = fields.index(self.csiRsSchedData_slot_field) + offset_value
        self.csiRsSchedData_pci = fields.index(self.csiRsSchedData_pci_field) + offset_value
        self.csiRsSchedData_startSymb = fields.index(self.csiRsSchedData_startSymb_field) + offset_value
        self.first_csiRsSchedData = False

    def addData(self, fields):
        sfn = fields[self.csiRsSchedData_sfn]
        hfn = fields[self.csiRsSchedData_hfn]
        slot = fields[self.csiRsSchedData_slot]
        pci = fields[self.csiRsSchedData_pci]
        startSymb = fields[self.csiRsSchedData_startSymb]

        vslot = int(hfn) * 1024 * 20 + int(sfn) * 20 + int(slot)
        if not (vslot in self.data[pci]):
            self.data[pci][vslot] = [1, [int(startSymb)]]
        else:
            self.data[pci][vslot][0] = self.data[pci][vslot][0] + 1
            if not (int(startSymb) in self.data[pci][vslot][1]):
                self.data[pci][vslot][1].append(int(startSymb))

    def addMsg(self, current_line):
        current_line = current_line.replace("\n", "").replace(" ", "")
        fields = current_line.split(":")[1].split(",")
        if self.first_csiRsSchedData:
            self.findPos_csiRsSchedData(fields)
        if not (fields[self.csiRsSchedData_pci] in self.data):
            self.data[fields[self.csiRsSchedData_pci]] = {}
        self.addData(fields)

    def final(self):
        for pci in self.data:
            for vslot in self.data[pci]:
                if not (pci in self.output):
                    self.output[pci] = self.data[pci][vslot]
                if self.data[pci][vslot][0] > self.output[pci][0]:
                    self.output[pci][0] = self.data[pci][vslot][0]
                    if self.output[pci][1] != self.data[pci][vslot][1]:
                        self.output[pci][1] = ["NA", "NA"]


def checkRefSignal(input_file, result_file, maxCsirsNumber):

    print(maxCsirsNumber)
    status = True
    input_file_fd = open(input_file, 'r')
    result_file_fd = open(result_file, 'a')
    csiRsSchedData = csiRsCellSpec()
    while 1:
        buffer_in = input_file_fd.readline()
        if buffer_in == "":
            break
        if buffer_in.find("ERROR") == -1:
            if re.match(r'csiRsSchedData', buffer_in):
                csiRsSchedData.addMsg(buffer_in)
    input_file_fd.close()
    csiRsSchedData.final()
    dico = sorted(csiRsSchedData.output.items(), key=lambda t: t[0])
    print(dico)

    result_file_fd.write("\n\tCell Specific CSI-RS for UEs on each cell\n")
    result_file_fd.write("\t\tMax cell-specific CSI-RS configured {}\n".format(maxCsirsNumber))
    result_file_fd.write("\t\tFrom TTI traces\n")
    for data in dico:
        result_file_fd.write("\t\t\tCell: {}, {} resources configured in total on symbols {}\n".format(
            data[0], data[1][0], data[1][1])
        )

    if len(dico) != len(maxCsirsNumber):
        print("Wrong cell number")
        result_file_fd.close()
        return False
    index = 0
    for pci in dico:
        if pci[1][0] != 2*int(maxCsirsNumber[index]):
            print("Max RS not configured. PCI: {}".format(pci[0]))
            status = False
        index += 1
    result_file_fd.close()
    return status

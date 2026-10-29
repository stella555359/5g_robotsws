import json
import os
import csv
import time
import math


class AutoDict(dict):
    def __missing__(self, k):
        self[k] = AutoDict()
        return self[k]


def find_by_key(data, target):
    if isinstance(data, dict):
        for k, v in data.items():
            if k == target:
                yield v
            else:
                for child_val in find_by_key(v, target):
                    yield child_val
    elif isinstance(data, list):
        for item in data:
            for item_val in find_by_key(item, target):
                yield item_val


def ConvertPcapToJson(PcapFile, filters):
    path, File = os.path.split(PcapFile)
    JsonFile = File.split('.')[0] + '_' + filters + '.json'
    NewJsonPath = os.path.join(path, JsonFile)
    cmd = 'tshark -2 -R ' + filters + ' -r ' + PcapFile + ' -T json --no-duplicate-keys > ' + NewJsonPath
    print('cmd', cmd)
    os.system(cmd)
    time.sleep(5)
    return NewJsonPath


def ReadJsonFile(JsonFile):
    jsonData = ''
    with open(JsonFile) as fd:
        jsonData = json.loads(fd.read())
    return jsonData


def create_csv_file(filePath, event, data, *header):
    dummy = []
    mul = len(data[1][0])
    custom_data = []
    for i in range(len(data[1]) * mul):
        dummy.append(event)
    data.insert(0, dummy)
    for i in range(len(header) + 1):
        custom_data.append([])
    mmm = custom_data
    for pkt in data[1:]:
        indx = 1
        for attr in pkt:
            for attr_val in attr:
                custom_data[indx].append(attr_val)
            indx = indx + 1
        for attr in pkt:
            for i in range(len(attr)):
                custom_data[0].append(event)
            break
    idx = 0
    newData = {}
    for item in header:
        newData[item] = custom_data[idx]
        idx += 1
    CsvFile = filePath.replace('json', 'csv')
    with open(CsvFile, "w", newline='') as outfile:
        writerfile = csv.writer(outfile)
        writerfile.writerow(newData.keys())
        writerfile.writerows(zip(*newData.values()))
    time.sleep(5)
    return CsvFile


def get_values(json_file, event, *args):
    value = []
    z = ReadJsonFile(json_file)
    for i in range(len(z)):
        value.append([])
        for attr in args[1:]:
            x = list(find_by_key(z[i], attr))
            if len(x) == 0:
                x.append(0)
            value[i].append(x)
        for item in value[i][:4]:
            if len(item) < len(value[i][3]):
                for j in range(len(item), len(value[i][3])):
                    item.append(item[0])
    return create_csv_file(json_file, event, value, *args)


def merge_file(file1, file2):
    fp1 = open(file1, "a")
    fp2 = open(file2)
    next(fp2)
    for line in fp2:
        fp1.write(line)
    fp1.close()
    fp2.close()


def cal_total_target_load_pdcch(chBw, targetload):
    pdcchload = int((chBw * targetload) / 100)
    sizeofcce = int(pdcchload / 6)
    aggrlevel = []
    if sizeofcce > 16:
        update(aggrlevel, sizeofcce, 16, pdcchload)
    elif sizeofcce <= 16:
        aggrlevel.append(16)
    return sum(aggrlevel) * 6


def update(aggr, val, div, total_prb):
    reminder = val % div
    qutionet = int(val / div)
    for i in range(qutionet):
        aggr.append(div)
    remained_prb = total_prb - ((qutionet * div) * 6)
    if remained_prb > 5:
        total_possible_cce = int(remained_prb / 6)
        if total_possible_cce > 8:
            update(aggr, total_possible_cce, 8, remained_prb)
        elif total_possible_cce > 4:
            update(aggr, total_possible_cce, 4, remained_prb)
        elif total_possible_cce >= 2:
            update(aggr, total_possible_cce, 2, remained_prb)
        elif total_possible_cce == 1:
            aggr.append(1)


def get_max_prb(pdschtargetload, pdcchtargetload):
    lst = [pdschtargetload, pdcchtargetload]
    return max(lst)


# =====================================================================================================================

class Read_Store_Data:

    def __init__(self, file_name, event, cellid, *arg):
        self.data = AutoDict()
        self.event = event
        self.cellid = cellid
        self.arg = arg
        self.file_name = file_name
        self.read_file(self.file_name)

    def read_file(self, file_name):
        with open(self.file_name) as csv_file:
            self.csv_reader = csv.DictReader(csv_file)
            self.header = self.csv_reader.fieldnames
            self.update_sfn_slot()

    def update_sfn_slot(self):
        sfn = ''
        slot = ''
        rnti = ''
        asfn = ''
        count = 0
        for line in self.csv_reader:
            if line['type'] == self.event and line[self.arg[0]] == str(self.cellid):
                if sfn != '0' and line[self.arg[1]] == '0':
                    count += 1
                if sfn != line[self.arg[1]] or slot != line[self.arg[2]] or rnti != line[self.arg[3]]:
                    asfn = str(count) + '-' + line[self.arg[1]] + '-' + line[self.arg[2]]
                    x = []
                    for item in self.arg[4:]:
                        x.append(line[item])
                    l_key = self.data[asfn].keys()
                    if line[self.arg[3]] in l_key:
                        tmp = []
                        for ii in self.data[asfn][line[self.arg[3]]]:
                            if isinstance(ii, list):
                                tmp.append(ii)
                            else:
                                tmp.append(self.data[asfn][line[self.arg[3]]])
                                break
                        tmp.append(x)
                        self.data[asfn][line[self.arg[3]]] = tmp
                    else:
                        self.data[asfn][line[self.arg[3]]] = x
                sfn = line[self.arg[1]]
                slot = line[self.arg[2]]
        # print(self.data)


def check_random(rat0bit):
    bitmap = []
    rat0bit = int(float(rat0bit))
    for i in range(64):
        bitmap.append(rat0bit >> i & 1)
    bit_1_count = bitmap.count(1)
    is_conti = 1
    first_1_bit = bitmap.index(1)
    count_1 = 0
    if bit_1_count > 1:
        for i in range(first_1_bit, 64):
            if count_1 == bit_1_count:
                break
            if i == first_1_bit:
                prev_indx_1 = i
                nxt_indx_1 = i
            if bitmap[i] == 1:
                count_1 += 1
                nxt_indx_1 = i
                if nxt_indx_1 - prev_indx_1 > 1:
                    is_conti = 0
                    break
                prev_indx_1 = nxt_indx_1
    #    print("is_contigiuous", is_conti)
    return is_conti


def cal_num_of_pdsch(chBW, ConfigType, nbrOfBlankedPRBsHighEdgeDL=0, nbrOfBlankedPRBsLowEdgeDL=0):
    config_1 = {2: [1, 36], 4: [37, 72], 8: [73, 144], 16: [145, 275]}
    config_2 = {4: [1, 36], 8: [37, 72], 16: [73, 275]}
    rbgsize = 0
    if ConfigType == 1:
        for key in config_1:
            if config_1[key][0] <= chBW <= config_1[key][1]:
                rbgsize = key
    elif ConfigType == 2:
        for key in config_2:
            if config_2[key][0] <= chBW <= config_2[key][1]:
                rbgsize = key
    rat0bitmap = [rbgsize for i in range(chBW//rbgsize)]
    rat0bitmap.append(chBW % rbgsize)
    if nbrOfBlankedPRBsHighEdgeDL != 0 or nbrOfBlankedPRBsLowEdgeDL != 0:
        x = 0
        y = 0
        if nbrOfBlankedPRBsHighEdgeDL - rat0bitmap[-1] <= 0:
            rat0bitmap = rat0bitmap[:-1]
        else:
            y = math.ceil((nbrOfBlankedPRBsHighEdgeDL - rat0bitmap[-1])/rbgsize)
            rat0bitmap = rat0bitmap[:-1-y]
        x = math.ceil(nbrOfBlankedPRBsLowEdgeDL/rbgsize)
        rat0bitmap = rat0bitmap[x:]
        usablepdsch = len(rat0bitmap) * rbgsize
    else:
        usablepdsch = chBW
    return chBW, usablepdsch, rat0bitmap


def cal_total_target_load(chBW, usablepdsch, rat0bitmap, targetload):
    load = math.ceil((chBW * targetload)/100)
    numofpdsch = 0
    if len(set(rat0bitmap)) == 2:
        a = load // rat0bitmap[0]
        b = load % rat0bitmap[0]
        if b == 0:
            numofpdsch = a * rat0bitmap[0]
        elif b <= rat0bitmap[-1]:
            numofpdsch = a * rat0bitmap[0] + rat0bitmap[-1]
        elif b > rat0bitmap[-1]:
            numofpdsch = math.ceil(load / rat0bitmap[0]) * rat0bitmap[0]
    else:
        numofpdsch = math.ceil(load / rat0bitmap[0]) * rat0bitmap[0]
    if targetload == 100:
        numofpdsch = usablepdsch
    return numofpdsch


def get_pdsch_on_ssb(file):
    usablepdschonssb = 0
    with open(file) as fd:
        f = fd.readlines()
    for line in f:
        if 'Usable PRB count' in line:
            print(line)
            usablepdschonssb = int(line.split('Usable PRB count:')[-1].split(',')[0])
            break
            # return pdschonssb
    return usablepdschonssb


def cal_total_target_load_ssb(totaltargetload, usablepdschonssb, pdschrealrnti, rat0bitmap):
    pdschdummyssb = 0
    if totaltargetload - pdschrealrnti >= 0:
        # pdschdummyssb = (totaltargetload - (pdschrealrnti + (20 * beam)))
        pdschdummyssb = (totaltargetload - pdschrealrnti)
        a = math.ceil(pdschdummyssb / max(rat0bitmap)) * max(rat0bitmap)
        if a >= usablepdschonssb:
            pdschdummyssb = usablepdschonssb
        else:
            pdschdummyssb = a
    return pdschdummyssb


def cal_total_target_load_non_ssb(totaltargetload, usablepdsch, pdschrealrnti, rat0bitmap):
    pdschdummy = 0
    if totaltargetload - pdschrealrnti >= 0:
        pdschdummy = math.ceil((totaltargetload - pdschrealrnti) / max(rat0bitmap)) * max(rat0bitmap)
        if pdschdummy >= usablepdsch:
            pdschdummy = usablepdsch
    return pdschdummy


def validate_pdsch(data, crnti, usablepdsch, rat0bitmap, TargetTotalLoad, mcs, mcsTable,
                   maxpdschinslot=4, pdschonssb=0, beam=1):
    flag = 0
    for asfn in data:
        sfn = int(asfn.split('-')[1])
        slot = int(asfn.split('-')[2])
        TotalPrbUsedReal = 0
        TotalPrbUsedDummy = 0

        # Find Dummy RNTI on Slot
        DummyRnti = set(data[asfn].keys()) - set(crnti)
        RealRnti = set(data[asfn].keys()) - DummyRnti
        print('asfn', data[asfn])
        # Calculate PRB load Consumed by Real Rnti
        if len(crnti) != 0:
            TotalPrbUsedReal = sum([int(data[asfn][i][0]) for i in RealRnti])

        # Calculate PRB load Consumed by Dummy Rnti
        if len(DummyRnti) != 0:
            TotalPrbUsedDummy = sum([int(data[asfn][i][0]) for i in DummyRnti])
            flag = 1
        else:
            # print("Dummy RNTI is not scheduled on SFN-{0} Slot-{1}".format(sfn, slot))
            flag = 0

        # Check for SSB Slot modulo of 2 is applicable for beamset_1 & 2 with combination of
        # frame structure 1:4, 3:7, 4:6(tdLte)
        if sfn % 2 == 0 and slot == 0:
            TotalPrbUsedReal = TotalPrbUsedReal + 20 * beam
            PrbUsedDummy = cal_total_target_load_ssb(TargetTotalLoad, pdschonssb, TotalPrbUsedReal, rat0bitmap)
        else:
            PrbUsedDummy = cal_total_target_load_non_ssb(TargetTotalLoad, usablepdsch, TotalPrbUsedReal, rat0bitmap)

        if flag == 1:
            if PrbUsedDummy == TotalPrbUsedDummy and len(RealRnti) != 0:
                for item in DummyRnti:
                    rat0Bitmap = check_random(data[asfn][item][1])
                    if int(float(data[asfn][item][2])) == mcs \
                            and int(float(data[asfn][item][3])) == mcsTable \
                            and (rat0Bitmap == 0 or rat0Bitmap == 1):
                        # print("expected behaviour with dummy rnti scheduled with real rnti")
                        print("Dummy RNTI-{0} is scheduled on SFN-{1} Slot-{2} with numOfPrb-{3}".
                              format(DummyRnti, sfn, slot, TotalPrbUsedDummy))
            elif '65535' in data[asfn].keys():
                print("SI broadcast happend on SFN-{} Slot-{}. No validation performed".format(sfn, slot))
            elif PrbUsedDummy == TotalPrbUsedDummy and len(RealRnti) == 0:
                for item in DummyRnti:
                    rat0Bitmap = check_random(data[asfn][item][1])
                    if int(float(data[asfn][item][2])) == mcs \
                            and int(float(data[asfn][item][3])) == mcsTable \
                            and (rat0Bitmap == 0 or rat0Bitmap == 1):
                        print("Leg-1 Dummy RNTI-{0} is scheduled on SFN-{1} Slot-{2} with numOfPrb-{3}".
                              format(DummyRnti, sfn, slot, TotalPrbUsedDummy))
            # added due to ssb slot inconsistency
            elif (PrbUsedDummy > TotalPrbUsedDummy or PrbUsedDummy < TotalPrbUsedDummy) and \
                    (len(RealRnti) == 0 or len(RealRnti) != 0):
                for item in DummyRnti:
                    rat0Bitmap = check_random(data[asfn][item][1])
                    if int(float(data[asfn][item][2])) == mcs \
                            and int(float(data[asfn][item][3])) == mcsTable \
                            and (rat0Bitmap == 0 or rat0Bitmap == 1):
                        print("Leg-2 Dummy RNTI-{0} is scheduled on SFN-{1} Slot-{2} with numOfPrb-{3}".
                              format(DummyRnti, sfn, slot, TotalPrbUsedDummy))
            else:
                print("Unexpected Behaviour for SFN-{0} Slot-{1}".format(sfn, slot))
                return 'Fail'
        elif flag == 0:
            if TotalPrbUsedReal >= TargetTotalLoad:
                print("No Dummy RNTI will be scheduled on SFN-{0} Slot-{1} as "
                      "no of TotalPrbUsedReal-{2} >= TargetTotalLoad-{3}"
                      .format(sfn, slot, TotalPrbUsedReal, TargetTotalLoad))
            elif TotalPrbUsedReal < TargetTotalLoad and len(RealRnti) == maxpdschinslot:
                print("No Dummy RNTI will be scheduled on SFN-{0} Slot-{1} as "
                      "no of real UE shceduled-{2} in slot reaches max-{3}"
                      .format(sfn, slot, len(RealRnti), maxpdschinslot))
            elif TargetTotalLoad == 0:
                print("No Dummy RNTI will be scheduled on SFN-{0} Slot-{1} as "
                      "targetTotalLoadSectorBeam-{2}".format(sfn, slot, TargetTotalLoad))
            elif '65535' in data[asfn].keys():
                print("SI broadcast happend on SFN-{} Slot-{}. No validation performed".format(sfn, slot))
            else:
                print("Unexpected Scenario SFN-{0} Slot-{1}".format(sfn, slot))
        else:
            print("Feature not working SFN-{0} Slot-{1}".format(sfn, slot))
            return 'Fail'
    return 'Pass'


def validate_pdcch(data, crnti, chbw, targetload):
    # Calculate total target load on pdcch in terms of prb
    targetloadpdcch = int(chbw * targetload / 100)

    for asfn in data:

        sfn = int(asfn.split('-')[1])
        slot = int(asfn.split('-')[2])
        TotalPdcchUsedReal = 0
        TotalPdcchUsedDummy = 0

        # Find Dummy RNTI on Slot
        DummyRnti = set(data[asfn].keys()) - set(crnti)
        RealRnti = set(data[asfn].keys()) - DummyRnti

        # Calculate PRB load Consumed by Real Rnti
        for rnti in data[asfn].keys():
            a = 0
            for item in data[asfn][rnti]:
                if isinstance(item, list):
                    a += int(float(item[0])) * int(float(item[1]))
                else:
                    a = int(float(data[asfn][rnti][0])) * int(float(data[asfn][rnti][1]))
            if rnti in RealRnti:
                TotalPdcchUsedReal += a
            else:
                TotalPdcchUsedDummy += a
        if targetloadpdcch - (TotalPdcchUsedReal * 6) > 0:
            if len(DummyRnti) != 0 and TotalPdcchUsedDummy > 0:
                print('SFN-', sfn, 'Slot', slot, 'DummyRnti', DummyRnti, 'RealRnti', RealRnti,
                      'TotalPdcchUsedReal', TotalPdcchUsedReal, 'TotalPdcchUsedDummy', TotalPdcchUsedDummy)
            else:
                print("Unexpected Scenario SFN-{0} Slot-{1}".format(sfn, slot))
                return 'Fail'
        else:
            print('SFN-', sfn, 'Slot', slot, 'RealRnti', RealRnti, 'TotalPdcchUsedReal', TotalPdcchUsedReal)
    return 'Pass'


def validation_of_pdsch(filename, event, cellid, arg, crnti, chbw, ConfigType,
                        targetload, mcs, mcsTable, usablepdschonssb,
                        maxpdschinslot=4, nbrOfBlankedPRBsHighEdgeDL=0,
                        nbrOfBlankedPRBsLowEdgeDL=0, beam=1):
    chBW, usablepdsch, rat0bitmap = cal_num_of_pdsch(chbw, ConfigType,
                                                     nbrOfBlankedPRBsHighEdgeDL,
                                                     nbrOfBlankedPRBsLowEdgeDL)

    numofpdsch = cal_total_target_load(chBW, usablepdsch, rat0bitmap, targetload)
    print('chBW-', chBW, 'usablepdsch-', usablepdsch, 'rat0bitmap-', rat0bitmap, 'numofpdsch-', numofpdsch)
    x = Read_Store_Data(filename, event, cellid, *arg)
    result = validate_pdsch(x.data, crnti, usablepdsch, rat0bitmap, numofpdsch,
                            mcs, mcsTable, maxpdschinslot=maxpdschinslot,
                            pdschonssb=usablepdschonssb, beam=beam)
    return result


def validation_of_pdcch(filename, event, cellid, crnti, chbw, targetload, arg):
    y = Read_Store_Data(filename, event, cellid, *arg)
    result = validate_pdcch(y.data, crnti, chbw, targetload)
    return result

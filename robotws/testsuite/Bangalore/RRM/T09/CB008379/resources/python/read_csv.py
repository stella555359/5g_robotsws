import csv


class AutoDict(dict):
    def __missing__(self, k):
        self[k] = AutoDict()
        return self[k]


def check_num_of_rnti_per_slot(direction, expected_rnti_per_slot, file_name):
    dummy = AutoDict()
    count = 0
    with open(file_name) as csv_file:
        csv_reader = csv.DictReader(csv_file)
        header = csv_reader.fieldnames

        for line in csv_reader:
            if 'type' in header and (line['type'] == 'ulFdSchedData' or line['type'] == 'dlFdSchedData'):
                try:
                    dummy[line['sfn']][line['slot']] += 1
                except TypeError:
                    dummy[line['sfn']][line['slot']] = 1
            elif 'asfn' in header:
                try:
                    dummy[line['asfn']][line['sfn']][line['slot']] += 1
                except TypeError:
                    dummy[line['asfn']][line['sfn']][line['slot']] = 1
    for key1 in dummy:
        for key2 in dummy[key1]:
            if isinstance(dummy[key1][key2], dict):
                for key3 in dummy[key1][key2]:
                    if dummy[key1][key2][key3] == expected_rnti_per_slot and direction == 'ul':
                        print("The Max UE achieved in sfn-%s slot-%s \n" % (key2, key3))
                        count += 1
                    elif dummy[key1][key2][key3] == expected_rnti_per_slot and direction == 'dl':
                        print("The Max UE achieved in sfn-%s slot-%s" % (key2, key3))
                        count += 1
            else:
                if dummy[key1][key2] == expected_rnti_per_slot and direction == 'ul':
                    print("The Max UE achieved in sfn-%s slot-%s" % (key1, key2))
                    count += 1
                elif dummy[key1][key2] == expected_rnti_per_slot and direction == 'dl':
                    print("The Max UE achieved in sfn-%s slot-%s" % (key1, key2))
                    count += 1
    return 'Pass' if count >= 1 else 'Fail'


def check_cqi_from_ttitrace(file_name):
    dummy = AutoDict()
    with open(file_name) as csv_file:
        csv_reader = csv.DictReader(csv_file)
        header = csv_reader.fieldnames

        for line in csv_reader:
            if 'csiReport.cqi' in header and (len(line['csiReport.cqi'].strip()) != 0) and line['dtx'] != 'DTX':
                for i in range(16):
                    if i == int(float(line['csiReport.cqi'])):
                        try:
                            dummy[i] += 1
                        except TypeError:
                            dummy[i] = 1
    return dummy


def check_bwpid_per_rnti(file_name, rnti, bwpid):
    dummy = AutoDict()
    with open(file_name) as csv_file:
        csv_reader = csv.DictReader(csv_file)
        header = csv_reader.fieldnames
        print("header is ", header)
        for line in csv_reader:
            if line['type'] == 'ulFdSchedData' or line['type'] == 'dlFdSchedData' and line['rnti'] == rnti:
                try:
                    if int(float(line['cellBwpId'])) != dummy[line['rnti']][-1]:
                        dummy[line['rnti']].append(int(float(line['cellBwpId'])))
                except TypeError:
                    dummy[line['rnti']] = [int(float(line['cellBwpId']))]
        print(dummy)
        for key in dummy:
            if len(dummy[key]) == 1:
                if bwpid in dummy[key]:
                    return 'pass'


def check_num_of_acsi_on_pusch_per_slot(expected_acsi_per_slot, file_name):
    dict_acsi = AutoDict()
    recv_acsi_on_pusch = []
    count_expected_acsi_per_slot = 0

    with open(file_name, 'r') as csv_file:
        csv_reader = csv.DictReader(csv_file)
        header = csv_reader.fieldnames
        for line in csv_reader:
            if (line['type'] == 'ulFdSchedData' and str(int(float(line['csiRequestSize']))) == '1' and
                    str(int(float(line['csiTriggerId']))) == '1'):
                try:
                    dict_acsi[line['sfn']][line['slot']] += 1
                except TypeError:
                    dict_acsi[line['sfn']][line['slot']] = 1

            elif ('asfn' and 'csiRequestSize' and 'csiTriggerId' in header and line['csiRequestSize'] == '1' and
                  line['csiTriggerId'] == '1' and line['numOfCsiBits'] == '5'):
                try:
                    dict_acsi[line['sfn']][line['slot']] += 1
                except TypeError:
                    dict_acsi[line['sfn']][line['slot']] = 1

            elif ('asfn' and 'cqi' and 'ri' in header and line['cqi'] == '15' and line['ri'] == '1' and
                  line['numOfUciCsiPart1Bits'] == '5'):
                try:
                    dict_acsi[line['sfn']][line['slot']] += 1
                except TypeError:
                    dict_acsi[line['sfn']][line['slot']] = 1

    for key in dict_acsi:
        for keys in dict_acsi[key]:
            if dict_acsi[key][keys] == expected_acsi_per_slot:
                print("SFN-%s SLOT-%s where expected no of ACSI %s captured" % (key, keys, expected_acsi_per_slot))
                count_expected_acsi_per_slot += 1
            else:
                recv_acsi_on_pusch.append(dict_acsi[key][keys])

    if count_expected_acsi_per_slot >= 1:
        return 'Pass', expected_acsi_per_slot
    else:
        print("Maximum number of ACSI on PUSCH captured in logs %s" % (max(recv_acsi_on_pusch)))
        return 'Fail', max(recv_acsi_on_pusch)

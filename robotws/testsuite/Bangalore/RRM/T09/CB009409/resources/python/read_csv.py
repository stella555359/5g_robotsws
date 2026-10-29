import csv


class AutoDict(dict):
    def __missing__(self, k):
        self[k] = AutoDict()
        return self[k]


def check_ultcpboostgrant(file_name):
    dummy = AutoDict()
    pug_count = 0
    with open(file_name) as csv_file:
        csv_reader = csv.DictReader(csv_file)
        header = csv_reader.fieldnames

        for line in csv_reader:
            if 'type' in header and (line['type'] == 'ulPreSchedData' and
                                     line['csListEvent'] == 'ENTRYULTCPBOOSTGRANT'):
                try:
                    dummy[line['sfn']] += 1
                except TypeError:
                    dummy[line['sfn']] = 1

        pug_count = len(dummy)
        print("Total ULTCPBOOSTGRANT  = ", pug_count)

    return 'Pass' if pug_count >= 1 else 'Fail'


def check_resReqClassPrio(file_name):
    dummy1 = AutoDict()
    prio_count = 0
    with open(file_name) as csv_file:
        csv_reader = csv.DictReader(csv_file)
        header = csv_reader.fieldnames

        for line in csv_reader:
            if 'type' in header and (line['type'] == 'ulTdSchedSubcellData' and
                                     str(int(float(line['resReqClassPrio']))) == '26'):
                try:
                    dummy1[line['sfn']] += 1
                except TypeError:
                    dummy1[line['sfn']] = 1

        prio_count = len(dummy1)
        print("Total resReqClassPrio  = ", prio_count)

    return 'Pass' if prio_count >= 1 else 'Fail'


def check_multiUEultcpboostgrant(file_name, ue_rnti):
    dummy = AutoDict()
    pug_count = 0
    with open(file_name) as csv_file:
        csv_reader = csv.DictReader(csv_file)
        header = csv_reader.fieldnames

        for line in csv_reader:
            if 'type' in header and (line['type'] == 'ulPreSchedData' and
                                     line['rnti'] == ue_rnti and
                                     line['csListEvent'] == 'ENTRYULTCPBOOSTGRANT'):
                try:
                    dummy[line['sfn']] += 1
                except TypeError:
                    dummy[line['sfn']] = 1

        pug_count = len(dummy)
        print("Total ULTCPBOOSTGRANT  = ", pug_count)

    return 'Pass' if pug_count >= 1 else 'Fail'


def check_multiUEresReqClassPrio(file_name, ue_rnti):
    dummy1 = AutoDict()
    prio_count = 0
    with open(file_name) as csv_file:
        csv_reader = csv.DictReader(csv_file)
        header = csv_reader.fieldnames

        for line in csv_reader:
            if 'type' in header and (line['type'] == 'ulTdSchedSubcellData' and
                                     line['rnti'] == ue_rnti and
                                     str(int(float(line['resReqClassPrio']))) == '26'):
                try:
                    dummy1[line['sfn']] += 1
                except TypeError:
                    dummy1[line['sfn']] = 1

        prio_count = len(dummy1)
        print("Total resReqClassPrio  = ", prio_count)

    return 'Pass' if prio_count >= 1 else 'Fail'

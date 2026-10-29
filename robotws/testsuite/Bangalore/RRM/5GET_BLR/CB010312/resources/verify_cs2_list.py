import csv


class AutoDict(dict):
    def __missing__(self, k):
        self[k] = AutoDict()
        return self[k]


def check_cs2_list_DL_10312_on(file_name):
    cs1List = []
    cs2List = []
    dummy = AutoDict()
    with open(file_name) as csv_file:
        csv_reader = csv.DictReader(csv_file)
        header = csv_reader.fieldnames
        print(header)
        for line in csv_reader:
            if 'type' in header and line['type'] == 'dlTdSchedSubcellData':
                try:
                    cs1List.append(int(float(line['cs1Size'])))
                    cs2List.append(int(float(line['cs2Size'])))
                except Exception:
                    pass
        print(cs1List[100])
        print(cs2List[100])
    Check = True
    if not cs2List[100] <= 25:
        Check = False
    return Check


def check_cs2_list_UL_10312_on(file_name):
    cs1List = []
    cs2List = []
    dummy = AutoDict()
    with open(file_name) as csv_file:
        csv_reader = csv.DictReader(csv_file)
        header = csv_reader.fieldnames
        print(header)
        for line in csv_reader:
            if 'type' in header and line['type'] == 'ulTdSchedSubcellData':
                try:
                    cs1List.append(int(float(line['cs1Size'])))
                    cs2List.append(int(float(line['cs2Size'])))
                except Exception:
                    pass
        print(cs1List[100])
        print(cs2List[100])
    Check = True
    if not cs2List[100] <= 25:
        Check = False
    return Check


def check_cs2_list_DL_10312_off(file_name):
    cs1List = []
    cs2List = []
    dummy = AutoDict()
    with open(file_name) as csv_file:
        csv_reader = csv.DictReader(csv_file)
        header = csv_reader.fieldnames
        print(header)
        for line in csv_reader:
            if 'type' in header and line['type'] == 'dlTdSchedSubcellData':
                try:
                    cs1List.append(int(float(line['cs1Size'])))
                    cs2List.append(int(float(line['cs2Size'])))
                except Exception:
                    pass
        print(cs1List[100])
        print(cs2List[100])
    Check = True
    if not cs2List[100] > 25:
        Check = False
    return Check


def check_cs2_list_UL_10312_off(file_name):
    cs1List = []
    cs2List = []
    dummy = AutoDict()
    with open(file_name) as csv_file:
        csv_reader = csv.DictReader(csv_file)
        header = csv_reader.fieldnames
        print(header)
        for line in csv_reader:
            if 'type' in header and line['type'] == 'ulTdSchedSubcellData':
                try:
                    cs1List.append(int(float(line['cs1Size'])))
                    cs2List.append(int(float(line['cs2Size'])))
                except Exception:
                    pass
        print(cs1List[100])
        print(cs2List[100])
    Check = True
    if not cs2List[100] > 25:
        Check = False
    return Check

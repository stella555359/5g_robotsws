import csv


class AutoDict(dict):
    def __missing__(self, k):
        self[k] = AutoDict()
        return self[k]


def check_rnti_bwpid(file_name, rnti, flag):
    dummy = AutoDict()
    with open(file_name) as csv_file:
        csv_reader = csv.DictReader(csv_file)
        header = csv_reader.fieldnames
        # print(header)
        if flag == 'False':
            flag = False
        for line in csv_reader:
            if 'type' in header and line['type'] == 'ulFdSchedData' \
                    or line['type'] == 'dlFdSchedData':
                try:
                    if flag:
                        dummy[line['rnti']].append(int(float(line['bwpId'])))
                    else:
                        dummy[line['rnti']].append(int(float(line['cellBwpId'])))
                except Exception:
                    if flag:
                        dummy[line['rnti']] = [int(float(line['bwpId']))]
                    else:
                        dummy[line['rnti']] = [int(float(line['cellBwpId']))]
    Check = True
    for key in rnti:
        try:
            cellbwp = list(set(dummy.get(key)))
            if len(cellbwp) != 1:
                Check = False
            elif cellbwp[0] != int(rnti[key]):
                print("rnti:", key, rnti[key], "is not matching with cellBwpId", cellbwp[0])
                Check = False
            elif cellbwp[0] == int(rnti[key]):
                print("rnti:", key, rnti[key], "is matching with cellBwpId", cellbwp[0])
        except Exception:
            rntikey = dummy.keys()
            for i in rntikey:
                if i == str(65535):
                    continue
                cellbwp = list(set(dummy.get(i)))
                if len(cellbwp) != 1:
                    Check = False
                elif cellbwp[0] != int(rnti[key]):
                    print("rnti:", i, rnti[key], "is not matching with cellBwpid", cellbwp[0])
                    Check = False
                elif cellbwp[0] == int(rnti[key]):
                    print("rnti:", i, rnti[key], "is matching with cellBwpid", cellbwp[0])
    return Check

import csv


class AutoDict(dict):
    def __missing__(self, k):
        self[k] = AutoDict()
        return self[k]


def check_rnti_bwpid(file_name, rnti):
    dummy = AutoDict()
    with open(file_name) as csv_file:
        csv_reader = csv.DictReader(csv_file)
        header = csv_reader.fieldnames
        # print(header)
        for line in csv_reader:
            if 'type' in header and line['type'] == 'ulFdSchedData' \
                    or line['type'] == 'dlFdSchedData':
                try:
                    dummy[line['rnti']].append(int(float(line['cellBwpId'])))
                except Exception:
                    dummy[line['rnti']] = [int(float(line['cellBwpId']))]

    Check = True
    for key in rnti:
        try:
            cellbwp = list(set(dummy.get(key)))
            if len(cellbwp) != 1:
                Check = False
            elif cellbwp[0] != int(rnti[key]):
                print(
                    "rnti:",
                    key,
                    rnti[key],
                    "is not matching with cellBwpId",
                    cellbwp[0])
                Check = False
            elif cellbwp[0] == int(rnti[key]):
                print(
                    "rnti:",
                    key,
                    rnti[key],
                    "is matching with cellBwpId",
                    cellbwp[0])
        except Exception:
            rntikey = dummy.keys()
            for i in rntikey:
                if i == str(65535):
                    continue
                cellbwp = list(set(dummy.get(i)))
                if len(cellbwp) != 1:
                    Check = False
                elif cellbwp[0] != int(rnti[key]):
                    print(
                        "rnti:",
                        i,
                        rnti[key],
                        "is not matching with cellBwpid",
                        cellbwp[0])
                    Check = False
                elif cellbwp[0] == int(rnti[key]):
                    print(
                        "rnti:",
                        i,
                        rnti[key],
                        "is matching with cellBwpid",
                        cellbwp[0])
    return Check


def check_blankedprb(file_name, start_prb=None, end_prb=None, CellId='52'):
    startprb = []
    numofprb = []
    endprb = []
    status = True
    with open(file_name) as csv_file:
        csv_reader = csv.DictReader(csv_file)
        header = csv_reader.fieldnames
        for line in csv_reader:
            if ('type' in header and line['type'] == 'dlFdSchedData') and\
               ('physCellId' in header and line['physCellId'] == CellId):
                startprb.append(int(float(line['startPrb'])))
                numofprb.append(int(float(line['numOfPrb'])))
        if start_prb is None:
            blanked_startprb = [0]
        else:
            blanked_startprb = list(range(start_prb[0], start_prb[1]+1))
        if end_prb is None:
            blanked_endprb = [0]
        else:
            blanked_endprb = list(range(end_prb[0], end_prb[1]+1))
        for prb in range(len(numofprb)):
            endprb.append(numofprb[prb]-1+startprb[prb])
        startprb = list(set(startprb))
        print("start prb: ", startprb)
        endprb = list(set(endprb))
        print("end prb: ", endprb)
        for prb in blanked_endprb:
            if prb in endprb:
                print(prb, "is used in endprb")
                status = False
        for prb in blanked_startprb:
            if prb in startprb:
                print(prb, "is used in startprb")
                status = False
    return status

import csv


class AutoDict(dict):
    def __missing__(self, k):
        self[k] = AutoDict()
        return self[k]


def check_numoflayer(file_name, rnti):
    dummy = AutoDict()
    print("RNTI", rnti)
    with open(file_name) as csv_file:
        csv_reader = csv.DictReader(csv_file)
        header = csv_reader.fieldnames
        # print(header)
        for line in csv_reader:
            if 'type' in header and line['type'] == 'dlFdSchedData':
                try:
                    dummy[line['rnti']].append(((line['numOfLayers'])))
                except Exception:
                    dummy[line['rnti']] = [((line['numOfLayers']))]

    Check = False
    for key in rnti:
        print("IN FOR LOOP")
        try:
            cellbwp = list(set(dummy.get(key)))
            if len(cellbwp) != 1:
                print("Morethan one numOfLayers- for CRNTI")
                Check = False
            elif cellbwp[0] != rnti[key]:
                print("numOfLayers of rnti:", key, " is ", cellbwp[0], "is not matching")
                Check = False
            else:
                print("numOfLayers of rnti:", key, " is ", cellbwp[0], "is matching ")
                Check = True
        except Exception:
            rntikey = dummy.keys()
            for i in rntikey:
                if i == str(65535):
                    continue
                cellbwp = list(set(dummy.get(i)))
                if len(cellbwp) != 1:
                    print("Morethan one numOfLayers- for CRNTI")
                    Check = False
                elif cellbwp[0] != 'RANK1':
                    print("numOfLayers is not matching, received rank is ", cellbwp[0])
                    Check = False
                else:
                    print("numOfLayers is matching for rnti:", i)
                    Check = True
    return Check

import csv

list_srs = []
unique_list = []


class AutoDict(dict):
    def __missing__(self, k):
        self[k] = AutoDict()
        return self[k]


def check_srsbeam_switch(file_name, rnti_1, beam):
    dummy = AutoDict()
    print("RNTI", rnti_1)
    rnti = [0]
    with open(file_name) as csv_file:
        csv_reader = csv.DictReader(csv_file)
        header = csv_reader.fieldnames
#      print(header)
        for line in csv_reader:
            if 'type' in header and line['type'] == 'srsSwitchMeasData':
                try:
                    dummy[line['rnti']].append((line['srsSwitchMeas']))
                except Exception:
                    dummy[line['rnti']] = [(line['srsSwitchMeas'])]

    resp = False
    for key in rnti:
        try:
            srsbeam = list(set(dummy.get(key)))
            print("srsbeam", srsbeam)
            print("x", srsbeam[0]['srsState'])
            if srsbeam[0] == 'SBSRS' and beam == 'SBToWB':
                print("srsBeam of rnti:", key, " is ", srsbeam[0], "is matching")
                resp = True
            elif (srsbeam[0] == 'WBSRS' or srsbeam[0] == 'WBSRS') and beam == 'WBToSB':
                print("srsBeam of rnti:", key, " is ", srsbeam[0], "is matching")
                resp = True
            else:
                print("srsBeam of rnti:", key, " is ", srsbeam[0], "is not matching ")
                resp = False
        except Exception:
            rntikey = dummy.keys()
            for i in rntikey:
                srsbeam = list(set(dummy.get(i)))
                # print("srsbeam_0", srsbeam[0])
                # print("srsbeam_1", srsbeam[1])
                for d in srsbeam:
                    list_srs.append(d[34:51])
                for x in list_srs:
                    if x not in unique_list:
                        unique_list.append(x)
                print("Unique", unique_list)
                if beam == 'SBToWB':
                    element = "'srsState': 'WBSRS'"
                    print("In IF", element)
                    if element in unique_list:
                        print("srsBeam is matching", unique_list)
                        resp = True
                elif beam == 'WBToSB':
                    element = "'srsState': 'SBSRS'"
                    print("In IF", element)
                    if element in unique_list:
                        print("srsBeam is matching", unique_list)
                        resp = True
                else:
                    print("srsBeam of rnti:", key, " is ", "is not matching ")
                    resp = False
    return resp

import csv


class AutoDict(dict):
    def __missing__(self, k):
        self[k] = AutoDict()
        return self[k]


def Check_Entrygrant(file_name, Ues_list):
    dummy = []
    status = True
    with open(file_name) as csv_file:
        csv_reader = csv.DictReader(csv_file)
        header = csv_reader.fieldnames
        for line in csv_reader:
            if ('type' in header and line['type'] == 'ulPreSchedData') and\
               ('csListEvent' in header and line['csListEvent'] == 'ENTRYULGRANTFORRLCSTATUSPDU') and\
               ('highestClassPriority' in header and line['highestClassPriority'] == '19.0'):
                try:
                    dummy.append(int(float(line['rnti'])))
                except Exception:
                    dummy.append(int(float(line['rnti'])))
        dummy = list(set(dummy))
        for i in Ues_list:
            if int(i) not in dummy:
                print(i, "UE is not present in list")
                status = False
        return status


def Check_TCPBoost(file_name, Ues_list):
    dummy = []
    status = True
    with open(file_name) as csv_file:
        csv_reader = csv.DictReader(csv_file)
        header = csv_reader.fieldnames
        print(header)
        for line in csv_reader:
            if ('type' in header and line['type'] == 'ulPreSchedData') and\
               ('csListEvent' in header and line['csListEvent'] == 'ENTRYULTCPBOOSTGRANT') and\
               ('highestClassPriority' in header and line['highestClassPriority'] == '16.0'):
                try:
                    dummy.append(int(float(line['rnti'])))
                except Exception:
                    dummy.append(int(float(line['rnti'])))
        dummy = list(set(dummy))
        for i in Ues_list:
            if int(i) not in dummy:
                print(i, "UE is not present in list")
                status = False
        return status


def check_respReqClassPrio(file_name, rntilist2):
    status = True
    dummy = AutoDict()
    dummy1 = AutoDict()
    with open(file_name) as csv_file:
        csv_reader = csv.DictReader(csv_file)
        header = csv_reader.fieldnames
        print(header)
        for line in csv_reader:
            if ('ulPreSchedData.csListEvent' in header and
                    line['ulPreSchedData.csListEvent'] == 'ENTRYULGRANTFORRLCSTATUSPDU'):
                try:
                    dummy[line['rnti']].append(int(float(line['ulTdSchedSubcellData.resReqClassPrio'])))
                except Exception:
                    dummy[line['rnti']] = [int(float(line['ulTdSchedSubcellData.resReqClassPrio']))]
            if ('ulPreSchedData.csListEvent' in header and
                    line['ulPreSchedData.csListEvent'] == 'ENTRYULTCPBOOSTGRANT'):
                try:
                    dummy1[line['rnti']].append(int(float(line['ulTdSchedSubcellData.resReqClassPrio'])))
                except Exception:
                    dummy1[line['rnti']] = [int(float(line['ulTdSchedSubcellData.resReqClassPrio']))]
        for key in rntilist2:
            prio = list(set(dummy.get(key)))
            print(prio)
            prio1 = list(set(dummy1.get(key)))
            print(prio1)
            if prio1[0] < prio[0]:
                status = False
        return status

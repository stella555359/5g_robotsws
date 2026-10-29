import csv


class AutoDict(dict):
    def __missing__(self, k):
        self[k] = AutoDict()
        return self[k]


def Check_dlallocatedprb(file_name, PhycellidandAllocatedPRB, subcell):
    dummy = AutoDict()
    with open(file_name) as csv_file:
        csv_reader = csv.DictReader(csv_file)
        header = csv_reader.fieldnames
        for line in csv_reader:
            if 'type' in header and line['type'] == 'dlAllocatedPooledResourcesData':
                try:
                    dummy[line['physCellId']].append(int(float(line['numAllocCellPrbDl'])))
                except Exception:
                    dummy[line['physCellId']] = [int(float(line['numAllocCellPrbDl']))]
    Check = True
    Total_subcells = 0
    for keys in PhycellidandAllocatedPRB:
        if int(PhycellidandAllocatedPRB[keys][1]) == 100:
            c4 = int(PhycellidandAllocatedPRB[keys][0]) * 273
            allocatedprbsubcells = list(set(dummy.get(keys)))
            subcells = int(allocatedprbsubcells[0]) // 273
            Total_subcells += subcells
        elif int(PhycellidandAllocatedPRB[keys][1]) == 80:
            c4 = int(PhycellidandAllocatedPRB[keys][0]) * 217
            allocatedprbsubcells = list(set(dummy.get(keys)))
            subcells = int(allocatedprbsubcells[0]) // 217
            Total_subcells += subcells
        elif int(PhycellidandAllocatedPRB[keys][1]) == 60:
            c4 = int(PhycellidandAllocatedPRB[keys][0]) * 162
            allocatedprbsubcells = list(set(dummy.get(keys)))
            subcells = int(allocatedprbsubcells[0]) // 162
            Total_subcells += subcells
        allocatedprb = list(set(dummy.get(keys)))
        if c4 != allocatedprb[0]:
            print("cell{} expected PRB {} is not matching with allocated PRB {}".format(keys, c4, allocatedprb[0]))
        else:
            print("cell{} expected PRB {} is matching with allocated PRB {}".format(keys, c4, allocatedprb[0]))
    print("Total Subcells allocated:", Total_subcells)
    if Total_subcells < subcell:
        Check = False
    return Check


def Check_ulallocatedprb(file_name, PhycellidandAllocatedPRB):
    dummy = AutoDict()
    with open(file_name) as csv_file:
        csv_reader = csv.DictReader(csv_file)
        header = csv_reader.fieldnames
        for line in csv_reader:
            if 'type' in header and line['type'] == 'ulAllocatedPooledResourcesData':
                try:
                    dummy[line['physCellId']].append(int(float(line['numAllocCellPrbUl'])))
                except Exception:
                    dummy[line['physCellId']] = [int(float(line['numAllocCellPrbUl']))]
    Check = True
    temp = 0
    for keys in PhycellidandAllocatedPRB:
        allocatedprb = list(set(dummy.get(keys)))
        print("cell{} is allocated with PRB {}".format(keys, allocatedprb[0]))
        if keys == "51":
            continue
        temp += allocatedprb[0]
    if temp != 819:
        Check = False
    return Check


def Check_minprballocation(file_name, PhycellidandminPRB):
    dummy = AutoDict()
    with open(file_name) as csv_file:
        csv_reader = csv.DictReader(csv_file)
        header = csv_reader.fieldnames
        for line in csv_reader:
            if 'type' in header and line['type'] == 'dlAllocatedPooledResourcesData':
                try:
                    dummy[line['physCellId']].append(int(float(line['allocStreamPrbMinDl'])))
                except Exception:
                    dummy[line['physCellId']] = [int(float(line['allocStreamPrbMinDl']))]
    Check = True
    for keys in PhycellidandminPRB:
        allocatedprb = list(set(dummy.get(keys)))
        if allocatedprb[0] == PhycellidandminPRB[keys]:
            print("cell{} expected PRB {} is not matching with allocated PRB {}".format(keys,
                                                                                        PhycellidandminPRB[keys] * 4,
                                                                                        allocatedprb[0]))
            Check = False
        else:
            print("cell{} expected PRB {} is matching with allocated PRB {}".format(keys, PhycellidandminPRB[keys] * 4,
                                                                                    allocatedprb[0]))
    return Check

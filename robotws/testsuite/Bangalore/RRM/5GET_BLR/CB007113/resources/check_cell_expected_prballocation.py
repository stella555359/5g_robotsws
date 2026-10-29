import csv


class AutoDict(dict):
    def __missing__(self, k):
        self[k] = AutoDict()
        return self[k]


def check_ulexpectedprb(file_name, cellid, minprb, maxprb, expectedprb):
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
    allocated_ulprb_cell = list(set(dummy.get(cellid)))
    print(allocated_ulprb_cell)
    expectedprb = int(expectedprb)
    poscount = 0
    threshold1 = int(expectedprb - (expectedprb * 0.05))
    threshold2 = int((expectedprb * 0.05) + expectedprb)
    if threshold1 < int(minprb):
        threshold1 = int(minprb)
    if threshold2 > int(maxprb):
        threshold2 = int(maxprb)
    for index in range(len(allocated_ulprb_cell)):
        if allocated_ulprb_cell[index] <= int(maxprb):
            if allocated_ulprb_cell[index] >= int(threshold1) and allocated_ulprb_cell[index] <= int(threshold2):
                print("PRB forCell{} {} in range of {} and {}".format(cellid, allocated_ulprb_cell[index],
                                                                      threshold1, threshold2))
                poscount = poscount + 1
            else:
                print("RBforCell{} {} not in range".format(cellid, allocated_ulprb_cell[index]))
                continue
    values_in_range = (poscount / len(allocated_ulprb_cell)) * 100
    if values_in_range >= 75:
        Check = True
        print("{} % of values are in good range".format(values_in_range))
    else:
        Check = False
        print("only {} % of values are in good range".format(values_in_range))
    return Check


def check_dlexpectedprb(file_name, cellid, minprb, maxprb, expectedprb):
    dummy = AutoDict()
    print("Function Enter")
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
    allocated_dlprb_cell = list(set(dummy.get(cellid)))
    print(allocated_dlprb_cell)
    expectedprb = int(expectedprb)
    poscount = 0
    threshold1 = int(expectedprb - (expectedprb * 0.05))
    threshold2 = int((expectedprb * 0.05) + expectedprb)
    if threshold1 < int(minprb):
        threshold1 = int(minprb)
    if threshold2 > int(maxprb):
        threshold2 = int(maxprb)
    for index in range(len(allocated_dlprb_cell)):
        if allocated_dlprb_cell[index] <= int(maxprb):
            if allocated_dlprb_cell[index] >= int(threshold1) and allocated_dlprb_cell[index] <= int(threshold2):
                print("PRB forCell{} {} in range of {} and {}".format(cellid, allocated_dlprb_cell[index],
                                                                      threshold1, threshold2))
                poscount = poscount + 1
            else:
                print("RBforCell{} {} not in range".format(cellid, allocated_dlprb_cell[index]))
                continue
    values_in_range = (poscount / len(allocated_dlprb_cell)) * 100
    if values_in_range >= 75:
        Check = True
        print("{} % of values are in good range".format(values_in_range))
    else:
        Check = False
    return Check

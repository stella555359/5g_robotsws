import csv


class AutoDict(dict):
    def __missing__(self, k):
        self[k] = AutoDict()
        return self[k]


def check_ulallocatedprb(file_name, cellid, threshold1, threshold2, weightage=75):
    dummy = AutoDict()
    rrmbuffer = []
    print("Checking numAllocCellPrbUl is in range from TTI logs:... ")
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
    Count = 0
    allocated_ulprb_cell = list(set(dummy.get(cellid)))
    for index in range(len(allocated_ulprb_cell)):
        if allocated_ulprb_cell[index] >= int(threshold1) and allocated_ulprb_cell[index] <= int(threshold2):
            print("PRB forCell{} {} inrng of {}&{}".format(cellid, allocated_ulprb_cell[index], threshold1, threshold2))
            Count = Count+1
        else:
            print("RBforCell{} {}notin rngof {}&{}".format(cellid, allocated_ulprb_cell[index], threshold1, threshold2))
            continue
    if Count <= ((weightage * len(allocated_ulprb_cell)) / 100):
        Check = False
    return Check


def check_dlallocatedprb(file_name, cellid, threshold1, threshold2, weightage=75):
    dummy = AutoDict()
    rrmbuffer = []
    print("Checking numAllocCellPrbDl is in range from TTI logs:...")
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
    Count = 0
    allocated_dlprb_cell = list(set(dummy.get(cellid)))
    for index in range(len(allocated_dlprb_cell)):
        if allocated_dlprb_cell[index] >= int(threshold1) and allocated_dlprb_cell[index] <= int(threshold2):
            print("PRB forCell{} {} inrng of {}&{}".format(cellid, allocated_dlprb_cell[index], threshold1, threshold2))
            Count = Count + 1
        else:
            print("RBforCell{} {}notin rngof {}&{}".format(cellid, allocated_dlprb_cell[index], threshold1, threshold2))
            continue
    if Count <= ((weightage * len(allocated_dlprb_cell)) / 100):
        Check = False
    return Check

import csv


class AutoDict(dict):
    def __missing__(self, k):
        self[k] = AutoDict()
        return self[k]


def check_ulallocatedprb(file_name, cellid, threshold1, threshold2):
    dummy = AutoDict()
    rrmbuffer = []
    print("Function Enter")
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
    for index in range(len(allocated_ulprb_cell)):
        if allocated_ulprb_cell[index] >= int(threshold1) and allocated_ulprb_cell[index] <= int(threshold2):
            print("PRB forCell{} {} inrng of {}&{}".format(cellid, allocated_ulprb_cell[index], threshold1, threshold2))
        else:
            Check = False
            print("RBforCell{} {}notin rngof {}&{}".format(cellid, allocated_ulprb_cell[index], threshold1, threshold2))
            break
    return Check


def check_dlallocatedprb(file_name, cellid, threshold1, threshold2):
    dummy = AutoDict()
    rrmbuffer = []
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
    for index in range(len(allocated_dlprb_cell)):
        if allocated_dlprb_cell[index] >= int(threshold1) and allocated_dlprb_cell[index] <= int(threshold2):
            print("PRB forCell{} {} inrng of {}&{}".format(cellid, allocated_dlprb_cell[index], threshold1, threshold2))
        else:
            Check = False
            print("RBforCell{} {}notin rngof {}&{}".format(cellid, allocated_dlprb_cell[index], threshold1, threshold2))
            break
    return Check

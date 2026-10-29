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
            if 'type' in header and line['type'] == 'ulFdSchedData':
                try:
                    rrmbuffer.append(int(float(line['rrmBufferedDataUlTotal_bytes'])))
                except Exception:
                    rrmbuffer.append(int(float(line['rrmBufferedDataUlTotal_bytes'])))
    Check = True
    allocated_ulprb_cell = list(set(dummy.get(cellid)))
    for index in range(len(allocated_ulprb_cell)):
        if allocated_ulprb_cell[index] >= int(threshold1) and allocated_ulprb_cell[index] <= int(threshold2):
            print("PRB forCell{} {} inrng of {}&{}".format(cellid, allocated_ulprb_cell[index], threshold1, threshold2))
        else:
            Check = False
            print("RBforCell{} {}notin rngof {}&{}".format(cellid, allocated_ulprb_cell[index], threshold1, threshold2))
            break
    cond = False
    for index in range(len(rrmbuffer)):
        if rrmbuffer[index] > 150000:
            cond = False
    if cond is False:
        print("cell{} validation successful value greater than 150000 not present".format(cellid))
    else:
        print("cell{} validation FAILED value greater than 150000 present".format(cellid))
    return Check

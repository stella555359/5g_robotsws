import csv


class AutoDict(dict):
    def __missing__(self, k):
        self[k] = AutoDict()
        return self[k]


def check_cells_in_csiRsPoolingGroup(file_name, NumExp_cells):
    dummy = AutoDict()
    print("Function Enter")
    CSIRS_Slot_list = ['3', '6', '8']
    with open(file_name) as csv_file:
        csv_reader = csv.DictReader(csv_file)
        header = csv_reader.fieldnames
        for line in csv_reader:
            if 'type' in header and line['type'] == 'csiRsSchedData':
                try:
                    dummy[line['slot']].append(int(float(line['physCellId'])))
                except Exception:
                    dummy[line['slot']] = [int(float(line['physCellId']))]
    Check = True
    print(dummy)
    for keys in CSIRS_Slot_list:
        print(keys)
        physcells_in_CSI_group = list(set(dummy.get(keys)))
        print("Cells in CSI_RS_pooling_group with slot id {} is/are {}".format(keys, physcells_in_CSI_group))
        if len(physcells_in_CSI_group) == NumExp_cells:
            print("Nu of cells in group with slot id {} is {}".format(keys, len(physcells_in_CSI_group)))
        else:
            Check = False
            print("Nu of cells in group with slot id {} is {} ".format(keys, len(physcells_in_CSI_group)))
            break
    return Check

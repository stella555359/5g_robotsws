import csv


class AutoDict(dict):
    def __missing__(self, k):
        self[k] = AutoDict()
        return self[k]


def has_zab_privilege(file_name):
    dummy = AutoDict()
    no_zab = []
    with open(file_name) as csv_file:
        csv_reader = csv.DictReader(csv_file)
        header = csv_reader.fieldnames
        for line in csv_reader:
            if 'type' in header and line['type'] == 'dlAllocatedPooledResourcesData':
                try:
                    dummy[line['physCellId']].append(int(float(line['hasZabPrivilege'])))
                except Exception:
                    dummy[line['physCellId']] = [int(float(line['hasZabPrivilege']))]
    no_zab = []
    cells_with_zab = []
    for keys in list(dummy.keys()):
        zab_privilege1 = list(set(dummy.get(('{}'.format(keys)))))
        if len(zab_privilege1) >= 1:
            if 1 in zab_privilege1:
                cells_with_zab.append(keys)
                print("cell {} has ZAB value {}".format(keys, zab_privilege1[0]))
            else:
                print("cell {} has ZAB value {}".format(keys, zab_privilege1[0]))
                no_zab.append(keys)
        else:
            print(keys, zab_privilege1)
            print("Invalid scenario")
    print("List of cells with ZAB privilege: ", cells_with_zab)
    print("List of cells without ZAB privilege: ", no_zab)
    return cells_with_zab, no_zab

# Press Ctrl+F8 to toggle the breakpoint.
import csv


class AutoDict(dict):
    def __missing__(self, k):
        self[k] = AutoDict()
        return self[k]


# noinspection PyBroadException
def check_prballocation(file_name):
    dummy = AutoDict()
    with open(file_name) as csv_file:
        csv_reader = csv.DictReader(csv_file)
        header = csv_reader.fieldnames
#        row_count=0
        for line in csv_reader:
            if 'type' in header and line['type'] == 'ulAllocatedPooledResourcesData':
                try:
                    dummy[line['physCellId']].append(int(float(line['numAllocCellPrbUl'])))
                except Exception:
                    dummy[line['physCellId']] = [int(float(line['numAllocCellPrbUl']))]
    print(dummy)
    output_subpool_one = {}
    for key in dummy.keys():
        if key in ["50", "52", "54"]:
            factor = 2 if key == "50" or key == "54" else 4 if key == "52" else 1
            modified_list = [value * factor for value in dummy[key][:10]]
            output_subpool_one[key] = modified_list
    print(f"subpool 1 : {output_subpool_one}")
    output_list = [sum(x) for x in zip(*output_subpool_one.values())]
    check_list = []
    print(output_list)
    for MinUlPrb in output_list:
        if 848 >= MinUlPrb:
            if MinUlPrb > 288:
                check_list.append(True)
            else:
                check_list.append(False)
                return False
        else:
            check_list.append(False)
            return False

    output_subpool_zero = {}
    for key in dummy.keys():
        if key in ["51", "53", "55"]:
            factor = 4 if key == "51" or key == "55" else 2 if key == "53" else 1
            modified_list = [value * factor for value in dummy[key][:10]]
            output_subpool_zero[key] = modified_list
    print(f"subpoll 0: {output_subpool_zero}")
    output_list = [sum(x) for x in zip(*output_subpool_zero.values())]
    check_list = []
    print(output_list)
    for MinUlPrb in output_list:
        if 1060 >= MinUlPrb:
            if MinUlPrb > 360:
                check_list.append(True)
            else:
                check_list.append(False)
                return False
        else:
            check_list.append(False)
            return False
    return True

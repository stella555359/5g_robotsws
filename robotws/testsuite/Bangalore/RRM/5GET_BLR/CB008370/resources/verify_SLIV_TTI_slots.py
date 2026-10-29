

import csv
from collections import Counter


def check_numbers_in_sliv(csv_file, numbers, physCellId=None):
    value = []
    with open(csv_file, 'r') as file:
        reader = csv.DictReader(file)
        for row in reader:
            try:
                if physCellId is not None and int(row["physCellId"]) != physCellId:
                    continue
                sliv_value = row["SLIV"].strip()
                if sliv_value:
                    value.append(int(float(sliv_value)))
            except ValueError:
                pass
    value_as_number_1 = list(value)
    counter = Counter(value_as_number_1)
    repeated_items = [(item, count) for item, count in counter.items() if count > 1]
    repet_dict = dict((x, y) for x, y in repeated_items)
    print(repet_dict)
    found = False
    for number in numbers:
        if number in repet_dict.keys():
            # print("THE SLIV", number, "is present, and it occurs in", repet_dict[number], "slots.")
            print(f"THE special PDSCH SLIV {number} corresponding to the PCI{physCellId} is present, "
                  f"and it occurs in {repet_dict[number]} slots out of total {len(value)} slots, kudos tester!!")
            found = True
        else:
            print(f'sorry special PDSCH SLIV {number} is not found corresponding to the PCI{physCellId}')
    return found


if __name__ == '__main__':
    a = "/home/ute/logs/Logs/20240508_195240533683.CA_case/ttitrace_streaming/output_dl_formated.csv"
    b = [98, 85, 57, 70, 56, 43, 27, 41, 55, 83, 97]
    c = 53  # replace with your physCellId value
    print(check_numbers_in_sliv(a, b, c))

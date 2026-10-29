import csv


def Slot_3_6_8_Muting_for_Zab_cells(file_name, ZAB_cells, Exp_SLIV):
    value = []
    print("Function Enter")
    Slot_list_1 = ['3', '6']
    # count = 0
    with open(file_name) as csv_file:
        csv_reader = csv.DictReader(csv_file)
        header = csv_reader.fieldnames
        for line in csv_reader:
            # count += 1
            if 'type' in header and line['type'] == 'dlFdSchedData':
                # print('Filtering dlFdSchedData')
                if 'physCellId' in header and line['physCellId'] in ZAB_cells:
                    # print('Filtering physCellId for Zab cell')
                    if 'sfn' in header and int(float(line['sfn'])) % 2 == 0:
                        # print('Filtering even SFN')
                        if 'slot' in header and line['slot'] in Slot_list_1:
                            print('Filtering slot 3 and 6 in even SFN for ZAB cells')
                            sliv_value = line["SLIV"].strip()
                            if sliv_value:
                                value.append(str(int(float(sliv_value))))
                    else:
                        if 'slot' in header and line['slot'] == '8':
                            print('Filtering slot 8 in Odd SFN for ZAB cells')
                            sliv_value = line["SLIV"].strip()
                            if sliv_value:
                                value.append(str(int(float(sliv_value))))
            # if count == 3000:
            #     break
    Check = True
    print(value)
    print('number of slots muting expected :::')
    print(len(value))
    sliv_lst = list(dict.fromkeys(value))
    print(sliv_lst)
    for i in sliv_lst:
        if i in Exp_SLIV:
            continue
        else:
            Check = False
    return Check

import csv


def validate_randomization(file_name, uernti, fddflag=True, flag=False):
    slot_list = []
    sfn_list = []
    start_prb = []
    num_of_prb = []
    rnti = []
    cell_id = []
    bitmap = []
    # if fddflag:
    #     maxslot = 9
    # else:
    #     maxslot = 19
    with open(file_name) as csv_file:
        csv_reader = csv.DictReader(csv_file)
        header = csv_reader.fieldnames
        for line in csv_reader:
            if 'type' in header and line['type'] == 'dlFdSchedData':
                if int(line['rnti']) == 65535:
                    continue
                try:
                    slot_list.append(int((line['slot'])))
                    sfn_list.append(int((line['sfn'])))
                    rnti.append(int(line['rnti']))
                    num_of_prb.append(int(float(line['numOfPrb'])))
                    start_prb.append(int(float(line['startPrb'])))
                    cell_id.append(int(float(line['physCellId'])))
                    bitmap.append(int(float(line['rat0Bitmap'])))
                except Exception:
                    pass
        print(len(slot_list), len(sfn_list), len(num_of_prb), len(start_prb), len(bitmap))
        print(set(rnti))
        status = True
        length = len(slot_list)
        for i in range(length-1):
            if str(rnti[i]) in uernti:
                if sfn_list[i] == sfn_list[i+1] and slot_list[i] == slot_list[i+1] and\
                   num_of_prb[i] == num_of_prb[i+1]:
                    if cell_id[i] != cell_id[i+1]:
                        if flag:
                            check = check_rat0bitmap(num_of_prb[i], bitmap[i])
                            if not check:
                                status = False
                        if bitmap[i] != bitmap[i+1]:
                            print("Condition is matching")
                            print(sfn_list[i], slot_list[i], num_of_prb[i])
                        else:
                            print("Failed---->Same Bitmap allocation")
                            print(sfn_list[i], slot_list[i], num_of_prb[i])
                            status = False
                    else:
                        print("cells is same")
                elif (sfn_list[i] == sfn_list[i+1]) and (slot_list[i+1] == slot_list[i]+1) and \
                     (num_of_prb[i] == num_of_prb[i+1]):
                    print("adjacent slot==============>")
                    if cell_id[i] == cell_id[i+1]:
                        if flag:
                            check = check_rat0bitmap(num_of_prb[i], bitmap[i])
                            if not check:
                                status = False
                        if bitmap[i] != bitmap[i+1]:
                            print("Condition is matching")
                            print(sfn_list[i], slot_list[i], num_of_prb[i])
                        else:
                            print("Failed---->Same Bitmap allocation")
                            print(sfn_list[i], slot_list[i], num_of_prb[i])
                            status = False
                    else:
                        print("cells not is same")
    return status


def check_rat0bitmap(num_of_prb, bitmap):
    status = True
    count = 0
    temp1 = round(num_of_prb / 16)
    temp = format(bitmap, "016b")
    for j in range(len(temp) - 1):
        if temp[j] == '1' and temp[j + 1] == '1':
            count += 1
        else:
            count = 0
        if temp1 == count:
            status = False
            print("rat0bit map is matched")
    return status

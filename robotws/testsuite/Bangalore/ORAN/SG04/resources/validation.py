import csv


def MCS_MIN(a):
    res = [ele for ele in a if ele.strip('0')]
    b = sorted(res)
    b = [ele for ele in b if int(ele) > 19]
    #    b=[x for x in a if x >= 19]
    c = min(b)
    print(b)
    print(c)
    if int(c) > 19:
        return True


def value(a):
    res = [ele for ele in a if ele.strip()]
    b = MCS_MIN(res)
    return b


def QAM_validation(a):
    a = [ele for ele in a if ele.strip('')]
    res = [ele for ele in a if ele.strip('0')]
    return res


def verify_Biplog(Bip_csv_file, column_name, count_match):
    data = []
    rep = []
    input_file = open(Bip_csv_file, 'r')
    file = csv.DictReader(input_file)
    print("Checking columns :", column_name)
    print("Checking repetition count :", count_match)
    for col in file:
        temp = []
        for val in column_name:
            temp.append(col[val])
        data.append(temp)
    print(data)
    b = all_same(data)
    print(b)
    return b


def all_same(items):
    if items[0] == ['4']:
        return all(x == items[0] for x in items)
    return False


def tput_validation(val_1, val_2):
    tput_1 = val_1['UE_1'][1]
    tput_2 = val_2['UE_1'][1]
    print(float(tput_1))
    print(float(tput_2))
    if float(tput_2) > float(tput_1) and (tput_2 - tput_1) > 20:
        return True
    return False

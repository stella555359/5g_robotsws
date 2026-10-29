import csv


class AutoDict(dict):
    def __missing__(self, k):
        self[k] = []
        return self[k]


def check_rnti_bwpid_CNI72167(file_name, rnti_list, flag=False):
    dummy = AutoDict()
    with open(file_name) as csv_file:
        csv_reader = csv.DictReader(csv_file)
        header = csv_reader.fieldnames
        for line in csv_reader:
            if line['rnti'] == '65535' or line['rnti'] not in rnti_list:
                continue
            if 'type' in header and (line['type'] == 'ulFdSchedData' or line['type'] == 'dlFdSchedData'):
                try:
                    if line['bwpId'] != '' and flag:
                        dummy[line['rnti']].append(int(float(line['bwpId'])))
                    elif line['cellBwpId'] != '' and not flag:
                        dummy[line['rnti']].append(int(float(line['cellBwpId'])))
                except ValueError:
                    print(f"Could not convert '{line['bwpId']}' or '{line['cellBwpId']}' to float.")
    one_count = 0
    two_count = 0
    for key in dummy:
        cellbwp = list(set(dummy[key]))
        if len(cellbwp) == 1:
            if cellbwp[0] == 1:
                one_count += 1
                print(f"rnti: {key} has cellbwpid: 1")
            elif cellbwp[0] == 2:
                two_count += 1
                print(f"rnti: {key} has cellbwpid: 2")
        else:
            print(f"rnti: {key} has more than one cellbwpid: {cellbwp}")
    if one_count == 0:
        print("No rnti with cellbwpid 1")

    # Check if all rntis in rnti_list are present in dummy
    all_rntis_present = True
    for rnti in rnti_list:
        if rnti not in dummy:
            print(f"rnti: {rnti} not found in CSV file")
            all_rntis_present = False

    return all_rntis_present and one_count == 1 and two_count == len(dummy) - 1


# if __name__ == '__main__':
#    a = "C:\\SHEKHZ\\5g L2\\5GC000937\\New folder (2)\\2nd_PDU\\output_dl_formated.csv"
#    b = ['1217', '33065', '31225', '29385', '27545', '59393']
#    b = ['1217', '33065', '31225', '29385', '27545', '59393', '25705', '57553']
#    c = False
#    print(check_rnti_bwpid(a, b))

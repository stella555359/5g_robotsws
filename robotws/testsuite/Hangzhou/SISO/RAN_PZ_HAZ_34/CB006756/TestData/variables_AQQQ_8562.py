import csv
import math

tput_define = {
    1: {
        'dl_exp': 200,
        'dl_tp': '300M',
        'ul_exp': 30,
        'ul_tp': '50M',
        'ue_index': 0
    },
}


ue_list = [0, 1]
ue_list_1 = [1]
ue_list_0 = [0]


peak_info = {
    '1': {
           'dl_exp': 300,
           'dl_tp': '350M',
           'ul_exp': 20,
           'ul_tp': '100M'
    },
    '2': {
           'dl_exp': 300,
           'dl_tp': '350M',
           'ul_exp': 20,
           'ul_tp': '100M'
    }
}


# AQQQ doesn't support VSWR/RTWP
def get_AQQQ_CSV_content(file):
    with open(file, 'r', newline='', encoding='utf-8') as f:
        reader = csv.reader(f)
        result = list(reader)
        lenth_csv = len(result)
        for i in range(lenth_csv):
            if 'RSSI (dBm)' in result[i]:
                RSSI_index1 = i
                RSSI_index2 = list(result[i]).index('RSSI (dBm)')
                RSSI = result[RSSI_index1][RSSI_index2]
                print(RSSI)
            if 'ETP (mW)' in result[i]:
                ETP_index1 = i
                ETP_index2 = list(result[i]).index('ETP (mW)')
                ETP = result[ETP_index1][ETP_index2]
    f.close()
    RSSI_content = result[RSSI_index1 + 2:ETP_index1 - 1]
    ETP_content = result[ETP_index1 + 2:]
    RSSI_value = []
    ETP_value = []

    for i in range(len(RSSI_content)):
        if 'RMOD-1/RMOD_R-1(AQQQ)' in RSSI_content[i]:
            index2 = list(RSSI_content[i]).index('RMOD-1/RMOD_R-1(AQQQ)')
            RSSI_data = RSSI_content[i][index2 + 3:]
            for j in RSSI_data:
                RSSI_value.append(j)
    RSSI_value_dict = dict(RSSI=RSSI_value)
    for i in range(len(ETP_content)):
        if 'RMOD-1/RMOD_R-1(AQQQ)' in ETP_content[i]:
            index3 = list(ETP_content[i]).index('RMOD-1/RMOD_R-1(AQQQ)')
            ETP_data = ETP_content[i][index3 + 3:]
            for j in ETP_data:
                ETP_value.append(j)
    length_etp_value = len(ETP_value)
    # print("ETP value:", ETP_value)
    # print("ETP value length:", length_etp_value)
    if ETP_value[length_etp_value - 1] == '':
        ETP_value.remove(ETP_value[length_etp_value - 1])
    etp_value_dict = dict(ETP=ETP_value)
    integer_RSSI = []
    character_RSSI = []
    print(type(RSSI_value))
    for i in RSSI_value:
        if i == '-':
            character_RSSI.append(i)
        else:
            integer_RSSI.append(i)
    print(character_RSSI)
    print(integer_RSSI)
    lenth_integer_RSSI = len(integer_RSSI)
    lenth_char_RSSI = len(character_RSSI)
    lenth_RSSI_value = len(RSSI_value)
    print(lenth_integer_RSSI)
    print(lenth_char_RSSI)
    print(lenth_RSSI_value)
    return \
        RSSI_value, RSSI_value_dict, ETP_value, etp_value_dict, lenth_RSSI_value, lenth_char_RSSI, \
        lenth_integer_RSSI, integer_RSSI, character_RSSI


def judge_value(list):
    list1 = list
    result = []
    for i in list1:
        if i != '-':
            j = float(i)
            if j < 0 or j > 0:
                status = 'true'
        else:
            status = 'false'
        result.append(status)
    if 'false' in result:
        judge_result = 'False'
    else:
        judge_result = 'True'
    return judge_result


def get_integer(number):
    a1 = round(number)
    number_integer = a1
    return number_integer

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


def get_AHPF_CSV_content(file):
    with open(file, 'r', newline='', encoding='utf-8') as f:
        reader = csv.reader(f)
        result = list(reader)
        lenth_csv = len(result)
        for i in range(lenth_csv):
            if '\ufeffVSWR' in result[i]:
                VSWR_index1 = i
                VSWR_index2 = list(result[i]).index('\ufeffVSWR')
                VSWR = result[VSWR_index1][VSWR_index2]
                # print(VSWR)
            if 'RTWP (dBm)' in result[i]:
                RTWP_index1 = i
                RTWP_index2 = list(result[i]).index('RTWP (dBm)')
                RTWP = result[RTWP_index1][RTWP_index2]
                # print(RTWP)
            if 'RSSI (dBm)' in result[i]:
                RSSI_index1 = i
                RSSI_index2 = list(result[i]).index('RSSI (dBm)')
                RSSI = result[RSSI_index1][RSSI_index2]
                # print(RSSI)
            if 'ETP (mW)' in result[i]:
                ETP_index1 = i
                ETP_index2 = list(result[i]).index('ETP (mW)')
                ETP = result[ETP_index1][ETP_index2]
                # print(ETP)
    f.close()
    VSWR_content = result[VSWR_index1 + 2:RTWP_index1 - 1]
    RTWP_content = result[RTWP_index1 + 2:RSSI_index1 - 1]
    RSSI_content = result[RSSI_index1 + 2:ETP_index1 - 1]
    ETP_content = result[ETP_index1 + 2:]
    VSWR_value = []
    RTWP_value = []
    RSSI_value = []
    ETP_value = []
    RMOD_1_ETP = []
    for i in range(len(VSWR_content)):
        if 'RMOD-1/RMOD_R-1(AHPF)' in VSWR_content[i]:
            if 'n28' in VSWR_content[i]:
                index = list(VSWR_content[i]).index('n28')
                VSWR_data = VSWR_content[i][index + 1:]
                for j in VSWR_data:
                    VSWR_value.append(j)
        VSWR_value_dict = dict(VSWR=VSWR_value)
    # print(VSWR_value_dict)
    for i in range(len(RTWP_content)):
        if 'RMOD-1/RMOD_R-1(AHPF)' in RTWP_content[i]:
            index1 = list(RTWP_content[i]).index('RMOD-1/RMOD_R-1(AHPF)')
            RTWP_data = RTWP_content[i][index1 + 3:]
            for j in RTWP_data:
                RTWP_value.append(j)
        # if 'RMOD-2/RMOD_R-2(AHPF)' in RTWP_content[i]:
        #     index11 = list(RTWP_content[i]).index('RMOD-2/RMOD_R-2(AHPF)')
        #     RTWP_data = RTWP_content[i][index11 + 3:]
        #     for k in RTWP_data:
        #         RTWP_value.append(k)
        # if 'RMOD-3/RMOD_R-3(AHPF)' in RTWP_content[i]:
        #     index12 = list(RTWP_content[i]).index('RMOD-3/RMOD_R-3(AHPF)')
        #     RTWP_data = RTWP_content[i][index12 + 3:]
        #     for a in RTWP_data:
        #         RTWP_value.append(a)
    RTWP_value_dict = dict(RTWP=RTWP_value)
    # print(RTWP_value_dict)
    for i in range(len(RSSI_content)):
        if 'RMOD-1/RMOD_R-1(AHPF)' in RSSI_content[i]:
            index2 = list(RSSI_content[i]).index('RMOD-1/RMOD_R-1(AHPF)')
            RSSI_data = RSSI_content[i][index2 + 3:]
            for j in RSSI_data:
                RSSI_value.append(j)
        # if 'RMOD-2/RMOD_R-2(AHPF)' in RSSI_content[i]:
        #     index21 = list(RSSI_content[i]).index('RMOD-2/RMOD_R-2(AHPF)')
        #     RSSI_data = RSSI_content[i][index21 + 3:]
        #     for k in RSSI_data:
        #         RSSI_value.append(k)
        # if 'RMOD-3/RMOD_R-3(AHPF)' in RSSI_content[i]:
        #     index22 = list(RSSI_content[i]).index('RMOD-3/RMOD_R-3(AHPF)')
        #     RSSI_data = RSSI_content[i][index22 + 3:]
        #     for a in RSSI_data:
        #         RSSI_value.append(a)
    RSSI_value_dict = dict(RSSI=RSSI_value)
    # print(RSSI_value_dict)
    for i in range(len(ETP_content)):
        if 'RMOD-1/RMOD_R-1(AHPF)' in ETP_content[i]:
            RMOD_1_ETP.append(ETP_content[i])
            index3 = list(ETP_content[i]).index('RMOD-1/RMOD_R-1(AHPF)')
            ETP_data = ETP_content[i][index3 + 3:]
            for j in ETP_data:
                ETP_value.append(j)
        # if 'RMOD-2/RMOD_R-2(AHPF)' in ETP_content[i]:
        #     index31 = list(ETP_content[i]).index('RMOD-2/RMOD_R-2(AHPF)')
        #     ETP_data = ETP_content[i][index31 + 2:]
        #     for k in ETP_data:
        #         ETP_value.append(k)
        # if 'RMOD-3/RMOD_R-3(AHPF)' in ETP_content[i]:
        #     index32 = list(ETP_content[i]).index('RMOD-3/RMOD_R-3(AHPF)')
        #     ETP_data = ETP_content[i][index32 + 2:]
        #     for a in ETP_data:
        #         ETP_value.append(a)
    ETP_list_length = len(RMOD_1_ETP)
    lenth_ETP_value = len(ETP_value)
    if ETP_value[lenth_ETP_value - 1] == '':
        ETP_value.remove(ETP_value[lenth_ETP_value - 1])
    ETP_value_dict = dict(ETP=ETP_value)
    # print(ETP_value_dict)
    integer_RSSI = []
    character_RSSI = []
    integer_VSWR = []
    integer_RTWP = []
    character_RTWP = []
    print(type(RSSI_value))
    for i in RSSI_value:
        if i == '-':
            character_RSSI.append(i)
        else:
            integer_RSSI.append(i)
    lenth_integer_RSSI = len(integer_RSSI)
    print(lenth_integer_RSSI)
    for i in VSWR_value:
        if i != '-':
            integer_VSWR.append(i)
    for i in RTWP_value:
        if i == '-':
            character_RTWP.append(i)
        else:
            integer_RTWP.append(i)
    lenth_integer_VSWR = len(integer_VSWR)
    lenth_integer_RTWP = len(integer_RTWP)
    return \
        VSWR_value, VSWR_value_dict, RTWP_value, RTWP_value_dict, RSSI_value, RSSI_value_dict, ETP_value, \
        ETP_value_dict, lenth_integer_RSSI, lenth_integer_VSWR, lenth_integer_RTWP, integer_VSWR, integer_RTWP, \
        integer_RSSI, character_RTWP, character_RSSI, ETP_list_length


# AQQQ doesn't support VSWR/RTWP
def get_AQQQ_CSV_content(file):
    with open(file, 'r', newline='', encoding='utf-8') as f:
        reader = csv.reader(f)
        result = list(reader)
        # print(result)
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
                # print(ETP)
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
    # print(RSSI_value_dict)

    for i in range(len(ETP_content)):
        if 'RMOD-1/RMOD_R-1(AQQQ)' in ETP_content[i]:
            index3 = list(ETP_content[i]).index('RMOD-1/RMOD_R-1(AQQQ)')
            ETP_data = ETP_content[i][index3 + 2:]
            for j in ETP_data:
                ETP_value.append(j)
    length_etp_value = len(ETP_value)
    if ETP_value[length_etp_value - 1] == '':
        ETP_value.remove(ETP_value[length_etp_value - 1])
    etp_value_dict = dict(ETP=ETP_value)
    # print(etp_value_dict)
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
    # return RSSI_value, RSSI_value_dict, ETP_value, etp_value_dict


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
    # print(result)
    if 'false' in result:
        judge_result = 'False'
    else:
        judge_result = 'True'
    # print(judge_result)
    return judge_result


def get_integer(number):
    a1 = round(number)
    # a11 = list(a1)
    # number_integer = int(a11[1])
    number_integer = a1
    return number_integer

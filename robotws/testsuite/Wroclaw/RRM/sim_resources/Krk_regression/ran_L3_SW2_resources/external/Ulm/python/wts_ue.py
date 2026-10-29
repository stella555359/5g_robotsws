import re


def obtain_new_ip(ue_id, wts_extract='4.7.254.208'):
    extract_octets = re.compile(r"^(\d{1,3}\.\d{1,3}\.\d{1,3}\.)(\d{1,3})$")
    octets = extract_octets.match(wts_extract).groups()
    """first 3 octets concatenated with the last octet + ue_id
    This increments IP address by 1 for each UE"""
    return octets[0] + str((int(octets[1]))+(int(ue_id)-1))


def obtain_new_imsi(ue_id, imsi_extract='250:555:21645400'):
    split_imsi = re.compile(r"^(\d{1,3}\:\d{1,3}\:)(\d+)$")
    mcc_mnc_tac = split_imsi.match(imsi_extract).groups()
    return mcc_mnc_tac[0] + str((int(mcc_mnc_tac[1]))+(int(ue_id)-1))


def obtain_new_suci(ue_id, suci_extract='0:311:489:0000:0:0:021645400'):
    split_suci = re.compile((r"^(\d{1,3}\:\d{1,3}\:\d{1,3}\:\d{1,4}\:\d{1,3}\:\d{1,3}\:)(\d+)$"))
    split_values = split_suci.match(suci_extract).groups()
    return split_values[0] + str((int(split_values[1]))+(int(ue_id)-1)).zfill(9)


def get_start_ue_id(mode, start_ue_id):
    if str(mode) == 'NSA' and str(start_ue_id) == '':
        return 12
    elif str(mode) == 'NSA' and str(start_ue_id) != '':
        return start_ue_id
    elif str(mode) == 'SA' and str(start_ue_id) == '':
        return 111
    elif str(mode) == 'SA' and str(start_ue_id) != '':
        return start_ue_id


def generate_list_of_ue_ids(start_ue_id, number_of_ues):
    list_ue_ids = range(int(start_ue_id), int(start_ue_id) + int(number_of_ues), 1)
    return list_ue_ids


def check_number_of_ues(number_of_ues):
    if int(number_of_ues) > 1:
        return 'PROCEED'
    else:
        return 'EXIT'

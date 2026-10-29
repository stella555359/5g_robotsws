import re


def obtain_new_ip(ue_id, wts_extract='4.7.254.208'):
    extract_octets = re.compile(r"^(\d{1,3}\.\d{1,3}\.\d{1,3}\.)(\d{1,3})$")
    octets = extract_octets.match(wts_extract).groups()
    """first 3 octets concatenated with the last octet + ue_id
    This increments IP address by 1 for each UE"""
    return octets[0] + str((int(octets[1]))+int(ue_id-1))


def obtain_new_imsi(ue_id, imsi_extract='250:555:21645400'):
    split_imsi = re.compile(r"^(\d{1,3}\:\d{1,3}\:)(\d+)$")
    mcc_mnc_tac = split_imsi.match(imsi_extract).groups()
    return mcc_mnc_tac[0] + str((int(mcc_mnc_tac[1]))+int(ue_id-1))

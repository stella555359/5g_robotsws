import re
from robot.libraries.BuiltIn import BuiltIn


def obtain_new_ip(ue_id, wts_extract='4.7.254.208'):
    extract_octets = re.compile(r"^(\d{1,3}\.\d{1,3}\.\d{1,3}\.)(\d{1,3})$")
    octets = extract_octets.match(wts_extract).groups()
    """first 3 octets concatenated with the last octet + ue_id
    This increments IP address by 1 for each UE
    Note: supported only till last octet reaches 255. Will be enhanced this in future"""
    return octets[0] + str((int(octets[1])) + int(ue_id - 1))


def obtain_new_imsi(ue_id, imsi_extract='250:555:21645400'):
    split_imsi = re.compile(r"^(\d{1,3}\:\d{1,3}\:)(\d+)$")
    mcc_mnc_tac = split_imsi.match(imsi_extract).groups()
    return mcc_mnc_tac[0] + str((int(mcc_mnc_tac[1])) + int(ue_id - 1))


def obtain_new_suci(ue_id, suci_extract='0:311:489:0000:0:0:021645400'):
    split_suci = re.compile((r"^(\d{1,3}\:\d{1,3}\:\d{1,3}\:\d{1,4}\:\d{1,3}\:\d{1,3}\:)(\d+)$"))
    split_values = split_suci.match(suci_extract).groups()
    return split_values[0] + str((int(split_values[1])) + (int(ue_id) - 1)).zfill(9)


def generate_list_of_ue_ids(start_ue_id, number_of_ues):
    list_ue_ids = list(range(int(start_ue_id), int(start_ue_id) + int(number_of_ues), 1))
    return list_ue_ids


def prepare_custom_egate_command(bearer, ue, **kwargs):
    command = 'trf_data_start id={} ue={} '.format(bearer, ue)
    for key, value in kwargs.items():
        command += key + '=' + str(value) + ' '
    return command


def fetch_UL_DLmindelay_values_from_syslog_output(syslog_output):
    parts = syslog_output.split()
    data = {}
    for i in range(len(parts) - 1):
        if parts[i] in ['t12Min', 't34Min']:
            try:
                data[parts[i]] = int(parts[i + 1])
            except ValueError:
                data[parts[i]] = None  # In case the value is not an integer
    return data.get('t12Min'), data.get('t34Min')


def verify_if_syslog_and_ui_values_match(syslog_output, ul_min_delay_ui, dl_min_delay_ui):
    t12_syslog, t34_syslog = fetch_UL_DLmindelay_values_from_syslog_output(syslog_output)
    if t34_syslog == ul_min_delay_ui and t12_syslog == dl_min_delay_ui:
        print("Syslog and UI values match")
    else:
        print("Syslog and UI values do not match")
        print(f"ulMinDelay in gNB syslog: {t34_syslog}, ulMinDelay in gNB UI: {ul_min_delay_ui}")
        print(f"dlMinDelay in gNB syslog: {t12_syslog}, dlMinDelay in gNB UI: {dl_min_delay_ui}")


def extract_faults(alarm_data):
    fault_dict = {}
    for alarm in alarm_data:
        fault_id = alarm.get("faultId")
        fault_name = alarm.get("faultName")
        if fault_id is not None and fault_name is not None:
            fault_dict[fault_id] = fault_name
    return fault_dict


def find_additional_alarms(before_alarms, after_alarms):
    IGNORE_FAULT_IDS = {
        4654, 4655, 61524, 7300, 61649, 7523,
        7107, 7304, 4592, 61652, 7305, 4681,
        4334, 4657, 4641, 62001, 7308}
    additional_faults = {
        fault_id: fault_name
        for fault_id, fault_name in after_alarms.items()
        if fault_id not in before_alarms and fault_id not in IGNORE_FAULT_IDS
    }
    if additional_faults:
        BuiltIn().log("Additional alarms found: {}".format(additional_faults), "ERROR")
    return additional_faults

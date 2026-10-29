import re
import datetime
from taf.config.wts import wts
import logging


DEFAULT_SA_UE_START = 1
DEFAULT_NSA_UE_START = 11


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
    if start_ue_id:
        return start_ue_id
    elif str(mode) == 'NSA':
        return 101
    elif str(mode) == 'SA':
        return 1


def get_data_from_line(data_string, regex="[0-9]{1,12}"):
    throughput = re.search(pattern=regex, string=data_string[25:]).group()
    return int(throughput)


def get_traffic_from_egate_output(output, only_average=False):
    ue_dict = {}
    output_array = output.split("\n")
    for line_content in output_array:
        if "UE" in line_content:
            current_ue_id = re.search(pattern="UE [0-9]{0,3}", string=line_content).group().replace(" ", "_")
            current_direction = re.search(pattern="[U,D]L L3 stats",
                                          string=line_content).group().replace(" L3 stats", "")
            ue_dict.setdefault(current_ue_id,
                               {"UL": {
                                    "Average_Throughput": 0,
                                    "Current_Throughput": 0},
                                "DL": {
                                    "Average_Throughput": 0,
                                    "Current_Throughput": 0}})
            ue_dict.setdefault("timestamp", datetime.datetime.utcnow().strftime("%d.%m.%Y %H:%M:%S.%f"))
        if "Average data rate" in line_content:
            ue_dict[current_ue_id][current_direction]["Average_Throughput"] = get_data_from_line(line_content)
        if "Last data rate" in line_content:
            ue_dict[current_ue_id][current_direction]["Current_Throughput"] = get_data_from_line(line_content)
    if len(ue_dict) == 0:
        return "No Data Found In Output"
    if only_average:
        for key, value in ue_dict.items():
            if "UE" in key:
                if value["UL"]["Average_Throughput"] > value["DL"]["Average_Throughput"]:
                    return value["UL"]["Average_Throughput"]
                else:
                    return value["DL"]["Average_Throughput"]
    return ue_dict


def generate_list_of_ue_ids(start_ue_id, number_of_ues):
    list_ue_ids = list(range(int(start_ue_id), int(start_ue_id) + int(number_of_ues), 1))
    return list_ue_ids


def clean_up_basic_cfg(path_to_basic_cfg, path_to_destination_file):
    global wtsobj
    wtsobj = wts()
    load_basic_cfg(path_to_basic_cfg)
    default_nsa, default_sa = _get_default_nsa_sa_ue_ids()
    _delete_additionally_predefined_sansa_ues(default_sa, default_nsa)
    save_modified_basic_cfg(path_to_destination_file)


def configure_nsa_sa_ues_in_basic_cfg(path_to_basic_cfg, modified_file_path, start_nsa_id=0,
                                      start_sa_id=0, number_of_required_nsa_ues=0,
                                      number_of_required_sa_ues=0):
    if number_of_required_sa_ues and not start_sa_id:
        start_sa_id = get_start_ue_id(mode='SA', start_ue_id=start_sa_id)
    if number_of_required_nsa_ues and not start_nsa_id:
        start_nsa_id = get_start_ue_id(mode='NSA', start_ue_id=start_nsa_id)
    nsa_sa_ues_configured = {"NSA": [start_nsa_id], "SA": [start_sa_id]}
    global wtsobj
    wtsobj = wts()
    load_basic_cfg(path_to_basic_cfg)
    default_nsa, default_sa = _get_default_nsa_sa_ue_ids()
    if number_of_required_nsa_ues:
        _change_nsa_ue_id_in_reference_file(start_nsa_ue_id=start_nsa_id, basic_cfg_reference_nsa_ue=default_nsa)
        configure_nsa_ues_in_basic_cfg(desired_nsa_ue_id_start=start_nsa_id,
                                       number_of_nsa_ues=number_of_required_nsa_ues,
                                       nsa_sa_ues_configured=nsa_sa_ues_configured)
        _delete_reference_ue_if_different_from_start_id(start_ue_id=start_nsa_id,
                                                        basic_cfg_reference_nsa_ue=default_nsa)
    if number_of_required_sa_ues:
        _change_sa_ue_id_in_reference_file(start_sa_ue_id=start_sa_id, basic_cfg_reference_sa_ue=default_sa)
        configure_sa_ues_in_basic_cfg(desired_sa_ue_id_start=start_sa_id,
                                      number_of_sa_ues=number_of_required_sa_ues,
                                      nsa_sa_ues_configured=nsa_sa_ues_configured)
        _delete_reference_ue_if_different_from_start_id(start_ue_id=start_sa_id,
                                                        basic_cfg_reference_sa_ue=default_sa)
    save_modified_basic_cfg(modified_file_path)
    return nsa_sa_ues_configured


def load_basic_cfg(path_to_basic_cfg):
    wtsobj.load_wts_cfg(path_to_basic_cfg)


def save_modified_basic_cfg(modified_file_path):
    wtsobj.save_wts_cfg(file_path=modified_file_path)


def _delete_additionally_predefined_sansa_ues(basic_cfg_reference_sa_ue, basic_cfg_reference_nsa_ue):
    """Deletes preconfigured UEs from basic configuration file
    Retains the reference NSA and SA UEs defined in variables self.basic_cfg_reference_nsa_ue
    self.basic_cfg_reference_sa_ue respectively"""
    predefined_ues = wtsobj.find_all(command="set_ue")
    for ue_command in predefined_ues:
        ue_id = re.search(r"set_ue\ssimulated\sid=(\d+)", ue_command)
        if (int(basic_cfg_reference_sa_ue) != int(ue_id.group(1)) and "suci" in ue_command) or \
                (int(basic_cfg_reference_nsa_ue) != int(ue_id.group(1)) and "imsi" in ue_command):
            logging.info("Deleting UE %s from Basic config file" % ue_id.group(1))
            wtsobj.delete(command=str("set_ue simulated id=%s" % ue_id.group(1)))
            wtsobj.delete(command=str("set_bearer id=2 ue=%s" % ue_id.group(1)))
            wtsobj.delete(command=str("ue_param id=%s" % ue_id.group(1)))
            wtsobj.delete(command=str("set_pdu_gateway id=%s" % ue_id.group(1)))


def _delete_reference_ue_if_different_from_start_id(start_ue_id,
                                                    basic_cfg_reference_sa_ue=0, basic_cfg_reference_nsa_ue=0):
    if (basic_cfg_reference_nsa_ue and int(basic_cfg_reference_nsa_ue) != start_ue_id):
        logging.info("Deleting UE %s from Basic config file" % basic_cfg_reference_nsa_ue)
        wtsobj.delete(command=str("set_ue simulated id=%s" % basic_cfg_reference_nsa_ue))
        wtsobj.delete(command=str("set_bearer id=2 ue=%s" % basic_cfg_reference_nsa_ue))
        wtsobj.delete(command=str("ue_param id=%s" % basic_cfg_reference_nsa_ue))
        wtsobj.delete(command=str("set_pdu_gateway id=%s" % basic_cfg_reference_nsa_ue))
    if (basic_cfg_reference_sa_ue and int(basic_cfg_reference_sa_ue) != start_ue_id):
        wtsobj.delete(command=str("set_ue simulated id=%s" % basic_cfg_reference_sa_ue))
        wtsobj.delete(command=str("ue_param id=%s" % basic_cfg_reference_sa_ue))
        wtsobj.delete(command=str("set_pdu_gateway id=%s" % basic_cfg_reference_sa_ue))


def _get_default_nsa_sa_ue_ids():
    nsa_ue_id = wtsobj.find_all_by_parameter(parameter="id", parameter_filter="dual_conn=eutra_nr")
    sa_ue_id = wtsobj.find_all_by_parameter(parameter="id", parameter_filter="mode=nr")
    nsa_ue_ids = []
    sa_ue_ids = []
    for item_nsa in nsa_ue_id:
        if "ue_nr_capabilities" not in item_nsa:
            continue
        ue_id_nsa = re.search(r"(id=)(\d+)", item_nsa)
        nsa_ue_ids.append(int(ue_id_nsa.groups()[1]))
    for item_sa in sa_ue_id:
        ue_id_sa = re.search(r"(id=)(\d+)", item_sa)
        sa_ue_ids.append(int(ue_id_sa.groups()[1]))
    nsa_ue_ids.sort(), sa_ue_ids.sort()
    if not sa_ue_ids:
        sa_ue_ids = [0]
    if not nsa_ue_ids:
        nsa_ue_ids = [0]
    return (nsa_ue_ids[0], sa_ue_ids[0])


def _get_sa_reference_parameters(reference_id):
    ref_ue_nat_ip = wtsobj.get_parameter(str("set_pdu_gateway id=%s" % reference_id), "ue_nat_ip")
    ref_suci = wtsobj.get_parameter(str("set_ue simulated id=%s" % reference_id),  "suci")
    return ref_ue_nat_ip, ref_suci


def _align_basic_cfg_file():
    """This is a workaround to align the basic config of certain files
    wher PDN_IP1 and PDN_IP2 are used in contrast to the basic config file where
    only one PDN_IP us defined"""
    """ Look for set PDN_IP1 and replace it with set PDN_IP"""
    set_commands = wtsobj.find_all("set")
    set_pdn_ip_commands = []
    for command in set_commands:
        if "PDN_IP1" in command:
            set_pdn_ip_commands.append(command)
            wtsobj.insert(command.replace("PDN_IP1", "PDN_IP"), "after", "set PGW_ADDR=\"4.7.254.207\"")
            wtsobj.delete(command)
    """ Look for PDN_IP1 usage in other commands and replace it with set PDN_IP"""
    try:
        pdn_ip_uses = wtsobj.find_all_by_parameter("ip", "ip=$PDN_IP1")
        wtsobj.modify(pdn_ip_uses[0], "ip=$PDN_IP")
    except IndexError:
        logging.info("No commands found with variable name $PDN_IP")


def _change_nsa_ue_id_in_reference_file(start_nsa_ue_id, basic_cfg_reference_nsa_ue):
    """Replaces the reference NSA UE id related parameters in basic config with
    given ue_id (start_nsa_ue_id)"""
    _align_basic_cfg_file()
    start_nsa_ue_id = get_start_ue_id(mode="NSA",  start_ue_id=start_nsa_ue_id)
    wtsobj.modify(command="set_ue simulated id=%s" % basic_cfg_reference_nsa_ue,
                  modification="id=%s" % start_nsa_ue_id)
    wtsobj.modify(command="ue_param id=%s dual_conn=eutra_nr" % basic_cfg_reference_nsa_ue,
                  modification="id=%s" % start_nsa_ue_id)
    wtsobj.modify(command="set_bearer ip=$PDN_IP ue=%s" % basic_cfg_reference_nsa_ue,
                  modification="id=2 ue=%s" % start_nsa_ue_id)
    ref_ue_nat_ip, _ = _get_sa_reference_parameters(basic_cfg_reference_nsa_ue)
    """To be checked if the PDU Gateway is needed for NSA UE"""
    if ref_ue_nat_ip and start_nsa_ue_id:
        ip = obtain_new_ip(ue_id=start_nsa_ue_id, wts_extract=ref_ue_nat_ip)
        wtsobj.modify(command="set_pdu_gateway id=%s" % basic_cfg_reference_nsa_ue,
                      modification="id=%s ue_nat_ip=%s" % (start_nsa_ue_id, ip))


def _change_sa_ue_id_in_reference_file(start_sa_ue_id, basic_cfg_reference_sa_ue):
    """Replaces the reference SA UE id related parameters in basic config with
    given ue_id (start_sa_ue_id)"""
    start_sa_ue_id = get_start_ue_id(mode="SA",  start_ue_id=start_sa_ue_id)
    wtsobj.modify(command="set_ue simulated id=%s" % basic_cfg_reference_sa_ue,
                  modification="id=%s" % start_sa_ue_id)
    wtsobj.modify(command="ue_param id=%s" % basic_cfg_reference_sa_ue,
                  modification="id=%s" % start_sa_ue_id)
    ref_ue_nat_ip, _ = _get_sa_reference_parameters(basic_cfg_reference_sa_ue)
    if ref_ue_nat_ip and start_sa_ue_id:
        ip = obtain_new_ip(ue_id=start_sa_ue_id, wts_extract=ref_ue_nat_ip)
        wtsobj.modify(command="set_pdu_gateway id=%s" % basic_cfg_reference_sa_ue,
                      modification="id=%s ue_nat_ip=%s" % (start_sa_ue_id, ip))


def configure_nsa_ues_in_basic_cfg(desired_nsa_ue_id_start, number_of_nsa_ues, nsa_sa_ues_configured):
    """Configures required NSA UEs in the basic config file"""
    default_bearer = 2
    pdn = wtsobj.get_parameter(command='set', parameter='PDN_IP')
    octetList = list(re.findall(r"(\d+).(\d+).(\d+).(\d+)", pdn)[0])
    octetList[-1] = str(int(octetList[-1])-100) if int(octetList[-1]) > 100 else octetList[-1]
    pdn = ".".join(octetList)
    imsi = wtsobj.get_parameter(command=str("set_ue simulated id=%s" % desired_nsa_ue_id_start),
                                parameter='imsi')
    logging.info("Reference PDN IP: %s" % pdn)
    logging.info("Reference IMSI IP: %s" % imsi)
    for nsa_ue in range(desired_nsa_ue_id_start + 1, (desired_nsa_ue_id_start + number_of_nsa_ues)):
        new_imsi = obtain_new_imsi(ue_id=nsa_ue, imsi_extract=imsi)
        new_ip = obtain_new_ip(ue_id=nsa_ue, wts_extract=pdn)
        wtsobj.delete(command=str("set_ue simulated id=%s" % nsa_ue))
        wtsobj.delete(command=str("ue_param id=%s" % nsa_ue))
        wtsobj.delete(command=str("set_bearer id=%s ue=%s" % (default_bearer, nsa_ue)))
        wtsobj.clone_and_modify(command=str("set_ue simulated id=%s" % desired_nsa_ue_id_start),
                                modification=str("id=%s" % nsa_ue) + " " + str("imsi=%s" % new_imsi),
                                location='after',
                                reference=str("ue_param id=%s" % desired_nsa_ue_id_start))
        wtsobj.clone_and_modify(command=str("ue_param id=%s dual_conn=eutra_nr" % desired_nsa_ue_id_start),
                                modification=str("id=%s" % (nsa_ue)),
                                location='after',
                                reference=str("set_ue simulated id=%s" % nsa_ue))
        wtsobj.clone_and_modify(command=str("set_bearer id=%s ue=%s" % (default_bearer, desired_nsa_ue_id_start)),
                                modification=str("id=%s ue=%s ip=%s" % (default_bearer, nsa_ue, new_ip)),
                                location='before',
                                reference=str("uec_param id=%s" % 1))

        nsa_sa_ues_configured["NSA"].append(nsa_ue)
        logging.info("Configuring NSA UE id: %s with PDN IP: %s and IMSI: %s" % (nsa_ue, new_ip, new_imsi))


def configure_sa_ues_in_basic_cfg(desired_sa_ue_id_start, number_of_sa_ues, nsa_sa_ues_configured):
    ref_ue_nat_ip, ref_suci = _get_sa_reference_parameters(desired_sa_ue_id_start)
    for ue_id in range(desired_sa_ue_id_start + 1, (desired_sa_ue_id_start + number_of_sa_ues)):
        suci = obtain_new_suci(ue_id=ue_id, suci_extract=ref_suci)
        ip = obtain_new_ip(ue_id=ue_id, wts_extract=ref_ue_nat_ip)
        command = str('set_ue simulated id=%s' % desired_sa_ue_id_start)
        modification = str("id=%s suci=%s" % (ue_id, suci))
        wtsobj.delete(command=str("set_ue simulated id=%s" % ue_id))
        wtsobj.delete(command=str("ue_param id=%s" % ue_id))
        wtsobj.delete(command=str("set_pdu_gateway id=%s" % ue_id))
        wtsobj.clone_and_modify(command=command,
                                modification=modification,
                                location='after',
                                reference=str("set_ue simulated id=%s" % desired_sa_ue_id_start))
        wtsobj.clone_and_modify(command=str("ue_param id=%s" % desired_sa_ue_id_start),
                                modification=str("id=%s" % (ue_id)),
                                location='after',
                                reference=str("ue_param id=%s" % desired_sa_ue_id_start))
        wtsobj.clone_and_modify(command=str("set_pdu_gateway id=%s" % desired_sa_ue_id_start),
                                modification=str("id=%s ue_nat_ip=%s" % (ue_id, ip)),
                                location='after',
                                reference=str("set_pdu_gateway id=%s" % desired_sa_ue_id_start))
        nsa_sa_ues_configured["SA"].append(ue_id)
    wtsobj.modify(command="set_nwslice id=1", modification="ue=all")

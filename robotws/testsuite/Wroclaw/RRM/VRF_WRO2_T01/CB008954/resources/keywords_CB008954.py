from robot.api import logger
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.log_helper import LogHelper
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.matchers import PcapMessageMatcher


bwp_template = {
    "L_100MHz": {'273'},
    "M_80MHz": {'273', '217'},
    "S_50MHz": {'273', '133'}
}


def execute_manual_step(info):
    logger.console(f"\n{info} | TYPE 'ok' PRESS ENTER: ")
    if input().lower() == 'ok':
        return True
    else:
        assert False, f"__Oops! Something went wrong!"


def log_finder(pcap_file, tfilter, message_name_pattern, message_type_pattern):
    """
    Log Finder taken from WRO6. Search through pcap directly without creating pdml file.
    """
    with LogHelper() as lh:
        finder = lh.add_pcap(pcap_file_path=pcap_file, tshark_filter=tfilter, lua=None)
        return finder.find_all(PcapMessageMatcher(message_name_pattern, message_type_pattern=message_type_pattern))


def check_if_bwp_is_correct(bwp, pcap_file):
    """
    For each UE attach depended on choosen BWP profile it is required that value of carrierBandwidth
    (F1AP) will be equal to specific configuration (e.g.: for Large = 273; for Medium =  ; for Small = 51).
    These values are matched in scf under parameter 'cRbSizeDl' in specific BWP_PROFILE-* with prefix 'n' (n273)

    Protocol: f1ap, Info: UEContextModificationResponse, message: carrierBandwidth
    Values: Large = {273}, Medium = {273, }, Small = {273, 51}
    """
    relevant_frames = log_finder(pcap_file, 'f1ap', 'UEContextModificationResponse', message_type_pattern='empty')
    for frame in relevant_frames:
        bwp_config_dedicated = frame.find('carrierBandwidth')
        if bwp_config_dedicated:
            break
    bwp_set = set()
    for element in bwp_config_dedicated:
        bwp_set.add((element['val']))
    if bwp_set == bwp_template[bwp]:
        logger.info(f"__OK! carrierBandwidth value for {bwp} is equal {bwp_set}")
        logger.console(f"__OK! carrierBandwidth value for {bwp} is equal {bwp_set}")
        return True
    else:
        assert False, f"__NOK! carrierBandwidth value for {bwp} (correct value: {bwp_template[bwp]})" \
                      f"is equal {bwp_set}"


def merge_dicts(*dict_args):
    merged_dict = {}
    for d in dict_args:
        logger.info(d)
        merged_dict.update(d)
    logger.info(merged_dict)
    return merged_dict

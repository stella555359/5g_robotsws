from robot.api import logger
from testsuite.Wroclaw.RRM.resources.log.helper import LogHelper
from testsuite.Wroclaw.RRM.resources.log.log import blog
from testsuite.Wroclaw.RRM.resources.log.matchers import PcapMessageMatcher as pm
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.color_log import write_mixed_line
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.utilities import is_release_higher
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.cloud.aic_utilities import is_cloudran_tl

DL_PDSCHSENDREQ = 'dldata_pdschsendreql1sw'
UL_PUSCHRECREQ = 'uldata_puschreceivereq'
DL_PDSCHGRANT = 'DlData_PdschGrantL1sw'

SHARK_OPTIONS = [('-o', 'swe.call_mac_nr:TRUE')]
PDSCH_REQ_FILTER = f"{DL_PDSCHSENDREQ} && 3gpp.subcellid && !(3gpp.rnti == 65535) && {DL_PDSCHGRANT}.rachStatus==0"
PUSCH_REQ_FILTER = f"{UL_PUSCHRECREQ} && 3gpp.subcellid"


def dl_data_scheduled_on_pcell_and_scells(pcap_file, scells='', pcell_id=1):
    if not isinstance(scells, list):
        scells = scells.split(',')
    pcell_msg = [
        pm(f'{DL_PDSCHSENDREQ}*', name_line_pattern='empty')
        .containing('dmrsScramblingSequenceInt*', f'*{pcell_id}')
    ]
    scells_msg = [
        pm(f'{DL_PDSCHSENDREQ}*', name_line_pattern='empty', tag=f'PdschSendReq_{cell_id}')
        .containing('dmrsScramblingSequenceInt*', f'*{cell_id}')
        for cell_id in scells
    ]
    messages = pcell_msg + scells_msg
    logger.info(messages, also_console=True)
    return _verify_messages(pcap_file, messages, shark_filter=PDSCH_REQ_FILTER)


def ul_data_scheduled_on_pcell_and_scells(pcap_file, scells='', pcell_id=1):
    if not isinstance(scells, list):
        scells = scells.split(',')
    pcell_msg = [
        pm(f'{UL_PUSCHRECREQ}*', name_line_pattern='empty', tag=f'puschreceivereq_{pcell_id}')
        .containing('dmrsScramblingSequenceInt*', f'*{pcell_id}')
    ]
    scells_msg = [
        pm(f'{UL_PUSCHRECREQ}*', name_line_pattern='empty', tag=f'puschreceivereq_{cell_id}')
        .containing('dmrsScramblingSequenceInt*', f'*{cell_id}')
        for cell_id in scells
    ]
    messages = pcell_msg + scells_msg
    return _verify_messages(pcap_file, messages, shark_filter=PUSCH_REQ_FILTER)


def dl_data_is_scheduled_on_pcell(pcap_file, pcell_id=1):
    pcell = [
        pm(f'{DL_PDSCHSENDREQ}*', name_line_pattern='empty', tag='PdschSendReq_PCELL')
        .containing('dmrsScramblingSequenceInt*', f'*{pcell_id}')
    ]
    return _verify_messages(pcap_file, pcell, shark_filter=PDSCH_REQ_FILTER)


def dl_data_is_scheduled_on_exact_number_of_scells(pcap_file, num_of_scells, possible_scells):
    possible_scells = [str(cell_id) for cell_id in possible_scells.split(',')]
    finder = bip_finder(pcap_file, shark_filter=PDSCH_REQ_FILTER)
    scells_msgs = [
        pm(f'{DL_PDSCHSENDREQ}*', name_line_pattern='empty', tag=f'PdschSendReq_{cell_id}')
        .containing('dmrsScramblingSequenceInt*', f'*{cell_id}') for cell_id in possible_scells
    ]
    found_msgs = finder.find_all(scells_msgs, forget_matcher_on_hit=True)
    blog(len(found_msgs))
    if len(found_msgs) < int(num_of_scells):
        write_mixed_line(f"TPUT {num_of_scells} SCELLS: [", " NOK ", "]", 'red')
        raise AssertionError("At least one message is missing!")
    elif len(found_msgs) > int(num_of_scells):
        write_mixed_line(f"TPUT {num_of_scells} SCELLS: [", " NOK ", "]", 'red')
        raise AssertionError(f"At least one message was found, but should not exist: {','.join(found_msgs.keys())}")
    write_mixed_line(f"DL TPUT {num_of_scells} SCELLS: [", " OK ", "]")


def dl_data_is_not_scheduled_on_scells(pcap_file, scells):
    finder = bip_finder(pcap_file, shark_filter=PDSCH_REQ_FILTER)
    scells = [str(cell_id) for cell_id in scells.split(',')]
    scells_msgs = [
        pm(f'{DL_PDSCHSENDREQ}*', name_line_pattern='empty', tag=f'PdschSendReq_{cell_id}')
        .containing('dmrsScramblingSequenceInt*', f'*{cell_id}') for cell_id in scells
    ]
    found_msgs = finder.find_all(scells_msgs, forget_matcher_on_hit=True)
    blog(found_msgs)
    assert not found_msgs, f"At least one message was found, but should not exist: {','.join(found_msgs.keys())}"


def ul_data_is_not_scheduled_on_scells(pcap_file, scells):
    finder = bip_finder(pcap_file, shark_filter=PUSCH_REQ_FILTER)
    scells = [str(cell_id) for cell_id in scells.split(',')]
    scells_msgs = [
        pm(f'{UL_PUSCHRECREQ}*', name_line_pattern='empty', tag=f'puschreceivereq_{cell_id}')
        .containing('dmrsScramblingSequenceInt*', f'*{cell_id}') for cell_id in scells
    ]
    found_msgs = finder.find_all(scells_msgs, forget_matcher_on_hit=True)
    blog(found_msgs)
    assert not found_msgs, f"At least one message was found, but should not exist: {','.join(found_msgs.keys())}"


def _verify_messages(pcap_file, messages=None, shark_filter=None):

    finder = bip_finder(pcap_file, shark_filter)
    found_msgs = finder.find_all(messages, forget_matcher_on_hit=True)
    msgs_to_find = [m.tag for m in messages]
    blog(msgs_to_find)
    missing_msgs = set(msgs_to_find) - set(found_msgs.keys())
    assert len(found_msgs) == len(messages), \
        f"At least one message is missing! Missing messages: {','.join(missing_msgs)}"
    return found_msgs


def ul_data_is_scheduled_on_pcell(pcap_file, pcell_id=1):
    pcell = [
        pm(f'{UL_PUSCHRECREQ}*', name_line_pattern='empty', tag='PuschReceiveReq_0')
        .containing('dmrsScramblingSequenceInt*', f'*{pcell_id}')
    ]
    messages = _verify_messages(pcap_file, pcell, shark_filter=PUSCH_REQ_FILTER)
    write_mixed_line("UL TPUT PCELL: [", " OK ", "]")
    return messages


def bip_finder(pcap_file, shark_filter):
    with LogHelper() as lh:
        finder = lh.add_pcap(
            pcap_file_path=pcap_file, lua=None, shark_filter=shark_filter,
            ts_output_data_file_path=None, clean_up_tmp_file=False
        )
    return finder

import time
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.DeltaStore import DeltaStore
from testsuite.Wroclaw.RRM.VRF_WRO2_T05.classical.regression.common_keywords.common_kw \
    import generated_pcap_data_for_attach
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.scf_tools.scf_manager import ScfManager
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.matchers import PcapMessageMatcher as PM
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.log_helper import LogHelper
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils import AdminUtils
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.common import get_cell_dist
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog

au = AdminUtils()


def change_256_QAM_value(cells_used_in_tc, param_val='true'):
    param_val = str(param_val).lower()
    scf_name = 'pre_enable_scf_file.xml' if param_val == 'true' else 'pre_disable_scf_file.xml'
    au.download_current_scf(file_name=scf_name)

    ds = DeltaStore()
    ds.initialise_delta_store()
    for cell in cells_used_in_tc:
        ds.add_param_to_delta(get_cell_dist(cell), 'actDl256Qam', param_val)
        ds.add_param_to_delta(get_cell_dist(cell), 'actUl256Qam', param_val)

    ds.validate_scf()
    delta = ds.collect_delta_store()
    ds.perform_delta_recommissioning(delta_file=delta)

    blog('Sleeping for 40 seconds')
    time.sleep(40)
    blog(f'256 QAM for DL/UL have been set to {param_val}')


def check_256_qam(cells_used_in_tc):
    mrbts_id, nrbts_id = au.get_bts_ids()
    with ScfManager() as Scf:
        vals = [(Scf.get_all_values_from_scf(dist_name=f'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-{cell}',
                                             p_name='actDl256Qam'))[0] for cell in cells_used_in_tc]
        blog('Param is', vals)
        return all(val.lower() == 'true' for val in vals)


def check_actMultipleDedicatedBWPs():
    mrbts_id, nrbts_id = au.get_bts_ids()
    with ScfManager() as Scf:
        return bool(Scf.get_all_values_from_scf(dist_name=f'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}',
                                                p_name='actMultipleDedicatedBWPs')[0])


def get_attach_type(pcap_path=None):
    pcap_msgs = generated_pcap_data_for_attach(pcap_path)
    blog('pcap_Data:', pcap_msgs)
    attach_sa_msg = [['', '', '1', ''], ['', '', '', '1']]
    attach_nsa_msg = [['27', '', '', ''], ['28', '1', '', ''], ['30', '1', '', '']]

    attach_sa_failed = any(msg not in pcap_msgs for msg in attach_sa_msg)
    attach_nsa_failed = any(msg not in pcap_msgs for msg in attach_nsa_msg)

    if not attach_sa_failed:
        return "SA"
    elif not attach_nsa_failed:
        return "NSA"
    else:
        return "FAIL"


def verify_attach_type_from_pcap(pcap_path, attach_type="SA"):
    # type can be NSA, SA, FAIL
    result = get_attach_type(pcap_path)
    blog('Attach status:', result)
    assert result == attach_type, f'Attach status: {result}, should be {attach_type}'


def verify_bwp_profile(pcap_path, ids):
    # ids_50mhz = ['4', '5', '6', '7', '8']
    # ids_30mhz = ['9', '10', '11', '12', '13']
    with LogHelper() as lh:
        finder = lh.add_pcap(pcap_file_path=pcap_path, tshark_filter='f1ap')
        pcap_msg = finder.find_next(PM('UEContextSetupResponse',
                                       message_type_pattern='empty'))
        result = pcap_msg.find('searchSpaceId')

        assert all(element['val'] in ids for element in result), 'IDs not matching desired BWP profile.'

    blog('UE attached to correct BWP profiles')

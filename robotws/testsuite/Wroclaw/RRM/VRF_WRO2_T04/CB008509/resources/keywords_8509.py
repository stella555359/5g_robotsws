import os
import json
from robot.api import logger
from jinja2 import Template
from operator import gt, ge, eq
from taf.sbts.oam.coam.admin import admin as taf_admin
from collections import defaultdict
from testsuite.Wroclaw.RRM.resources.preconditions_py import mrbts_id, nrbts_id
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.admin_session import AdminSession
from testsuite.Wroclaw.RRM.resources.pcap_verification.tsharkWithLuaVerifier import get_all_frames
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.mcs.mcs_parsing import is_valid_mcs_c_rnti
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.mcs.PuschFrame import PdschFrame
from testsuite.Wroclaw.RRM.resources.rrm_fixture import get_robot_variable
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.utilities import get_robot_output_dir
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.utilities import is_release_higher


DELTA_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)))
DL_PDSCHSENDREQ = 'dldata_pdschsendreql1sw' if is_release_higher('25R2') else 'dldata_pdschsendreq'
DLDATA_FILTER = f'{DL_PDSCHSENDREQ} && 3gpp.rnti != 65535'
DUMMY_LOAD_MCS = 28


def load_delta_template(filename):
    delta_filepath = os.path.join(DELTA_DIR, filename)
    with open(delta_filepath) as f:
        return Template(f.read())


def start_generate_dummy_load(cell_id, target_load, type='PDSCH+PDCCH+TRS+SSB'):
    template = load_delta_template('start_load.jinja2')
    delta = template.render(mrbts_id=mrbts_id, nrbts_id=nrbts_id, cell_id=cell_id, target_load=target_load, type=type)
    with AdminSession() as admin:
        admin.perform_delta_recommissioning(delta_file=delta)


def stop_generate_dummy_load(cell_id):
    template = load_delta_template('stop_load.jinja2')
    delta = template.render(mrbts_id=mrbts_id, nrbts_id=nrbts_id, cell_id=cell_id)
    with AdminSession() as admin:
        admin.perform_delta_recommissioning(delta_file=delta)


def get_pdsch_frames_from_pcap(pcap_file, ts_filter=DLDATA_FILTER):
    frames = get_all_frames(pcap_file=pcap_file, lua_attached=False, ts_filter=ts_filter)
    pdsch_frames = [PdschFrame(frame) for frame in frames]
    return pdsch_frames


def get_rnti_frames(pcap_file):
    frames = get_pdsch_frames_from_pcap(pcap_file, ts_filter=DLDATA_FILTER)
    asd = [frame for frame in frames if frame.rnti and is_valid_mcs_c_rnti(frame.rnti)]
    return asd


def get_real_ue_rnti(pcap_file):
    frames = get_rnti_frames(pcap_file)
    rntis = [*set([frame.rnti for frame in frames if frame.scrambling_int != 0])]
    if len(rntis) != 1:
        raise AssertionError("Incorrect number of Real UE RNTIs! RNTIs: {}".format(rntis))
    return rntis[0]


def get_al_rnti(pcap_file):
    frames = get_rnti_frames(pcap_file)
    rntis = [*set([frame.rnti for frame in frames if frame.scrambling_int == 0 and frame.mcs == DUMMY_LOAD_MCS])]
    if len(rntis) != 1:
        raise AssertionError("Incorrect number of AL RNTIs! RNTIs: {}".format(rntis))
    return rntis[0]


def get_number_of_pdsch_for_real_ue(pcap_file):
    try:
        ue_rnti = get_real_ue_rnti(pcap_file)
    except AssertionError:
        return 0
    return len(list(filter(lambda x: x.rnti == ue_rnti, get_rnti_frames(pcap_file))))


def get_number_of_pdsch_for_al(pcap_file):
    try:
        al_rnti = get_al_rnti(pcap_file)
    except AssertionError:
        return 0
    return len(list(filter(lambda x: x.rnti == al_rnti, get_rnti_frames(pcap_file))))


def assert_ARTIFICIAL_LOAD_counters_have_value_0(cell_id=103):
    counters = get_robot_variable("${COUNTERS_8509}")
    assert (counters[f'NRCELL-{cell_id}']['M55308C00043'],
            counters[f'NRCELL-{cell_id}']['M55308C00044'],
            counters[f'NRCELL-{cell_id}']['M55308C00045']) == (0, 0, 0)


def assert_DL_SLOTS_BELOW_TGT_LOAD_has_correct_value(operator='==', expected_value=None, cell_id=103):
    counters = get_robot_variable("${COUNTERS_8509}")
    _assert_counter_has_correct_value(counters[f'NRCELL-{cell_id}']['M55308C00043'], operator, value=expected_value)


def assert_DL_SLOTS_ARTIFICIAL_LOAD_has_correct_value(operator='==', expected_value=None, cell_id=103):
    counters = get_robot_variable("${COUNTERS_8509}")
    _assert_counter_has_correct_value(counters[f'NRCELL-{cell_id}']['M55308C00044'], operator, value=expected_value)


def assert_DL_PRB_ARTIFICIAL_LOAD_has_correct_value(operator='==', expected_value=None, cell_id=103):
    counters = get_robot_variable("${COUNTERS_8509}")
    _assert_counter_has_correct_value(counters[f'NRCELL-{cell_id}']['M55308C00045'], operator, value=expected_value)


def assert_TRS_SLOTS_has_correct_value(operator='==', expected_value=None, cell_id=103):
    counters = get_robot_variable("${COUNTERS_8509}")
    _assert_counter_has_correct_value(counters[f'NRCELL-{cell_id}']['M55308C00046'], operator, value=expected_value)


def _assert_counter_has_correct_value(counter_value, operator, value):
    operators = {'>': gt, '>=': ge, '==': eq}
    assert operator in operators, 'Unexpected operator! Allowed: {}'.format(operators.keys())
    comp = operators[operator]
    assert comp(counter_value, int(value)), \
        "Counter has incorrect value: {}, but expected is: {}{}".format(counter_value, operator, value)


def get_counters_values_for_cell(counter_list, bts_ip='192.168.255.129', mrbts=mrbts_id, nrbts=nrbts_id):
    def get_last_counter_value(counter_values):
        return counter_values[max(counter_values, key=int)]
    counters_per_cell = defaultdict(dict)
    admin = taf_admin()
    admin.setup_admin(bts_host=bts_ip)
    try:
        all_counters = admin.get_pm_counters(','.join(counter_list))
        cell_counters = all_counters.get('BTS').get('CELLS')
        if not cell_counters:
            cell_counters = all_counters.get('BTS').get(f'MRBTS-{mrbts}').get(f'NRBTS-{nrbts}')
        for cell, counters in cell_counters.items():
            logger.debug("Getting counters for cell: {}".format(cell))
            counters = {counter: values for d in counters.values() for counter, values in d.items()
                        if counter in counter_list}
            logger.debug("Cell counters: {}".format(counters))
            for counter, values in counters.items():
                logger.debug("counter: {}".format(counter))
                logger.debug("val: {}".format(values))
                counters_per_cell[cell][counter] = get_last_counter_value(values)
        logger.debug("COUNTERS: {}".format(counters_per_cell))
    finally:
        admin.teardown_admin()
    return counters_per_cell


def perform_rf_diagnostic_test(cells, load=None):
    if not isinstance(cells, list):
        cells = [int(cell) for cell in cells.split(',')]
    suffix = f"with load={load}" if load else 'without load'
    logger.info(f"\nPerforming RF diagnostic test {suffix}. Cell IDs: {cells}", also_console=True)

    with AdminSession() as admin:
        admin.start_rf_diagnostic_test(
                                 force_act_remote_rf_diag=True,
                                 cells=cells,
                                 cell_type='NR',
                                 rf_power_error_high_threshold=8.0,
                                 rf_power_error_low_threshold=-8.0,
                                 tx_antenna_vswr_high_threshold=3.0,
                                 rx_antenna_rtwp_low_threshold=-110.0,
                                 rx_antenna_rtwp_high_threshold=-30.0,
                                 rx_antenna_rssi_low_threshold=-110.0,
                                 rx_antenna_rssi_high_threshold=-30.0)

        results = admin.save_rf_diagnostic_test_results()[-1]
        output_filepath = os.path.join(get_robot_output_dir(), f'rf_diag_load_{load}.txt')
        with open(output_filepath, 'w') as f:
            json.dump(results, f, indent=4, sort_keys=True)
        return json.dumps(results, sort_keys=True)


def assert_pdbm_is_higher_during_dummy_load(rf_diag_res_wo_load, rf_diag_res_with_load):
    pdbm_without_load = json.loads(rf_diag_res_wo_load)['results']["fwdETPdBm"]
    expected_pdbm = round(1.5 * pdbm_without_load, 1)
    pdbm_with_load = json.loads(rf_diag_res_with_load)['results']["fwdETPdBm"]
    logger.info(f"\nPdbm without load: {pdbm_without_load}", also_console=True)
    logger.info(f"Expected Pdbm with load: {expected_pdbm}", also_console=True)
    logger.info(f"Current Pdbm with load: {pdbm_with_load}", also_console=True)
    assert pdbm_with_load > expected_pdbm

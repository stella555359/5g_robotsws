import json
from robot.api import logger
from testsuite.Wroclaw.RRM.resources.pcap_verification.tsharkWithLuaVerifier import get_all_frames
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.mcs.PuschFrame import PuschFrame
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.mcs.mcs_parsing import mcs_filter, get_frames_for_rntis_mapping, \
    get_mcs_table, get_mcs_average
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.admin_session import AdminSession


def get_all_cells_distnames():
    with AdminSession() as admin:
        return sorted([cell['id']['configuration'] for cell in admin.get_cell_list()['cells']['nr']])


def set_256qam_activation_state_for_all_cells(direction, state):
    """
    It's faster than performing each parameter commissioning one by one.
    :param direction:   should be "ul" or "dl"
    :param state:       should be "true" or "false"
    """

    direction = direction.lower()
    if direction not in ['ul', 'dl']:
        logger.error("Direction should be a string 'ul' or 'dl'")

    state = state.lower()
    if state not in ['false', 'true']:
        logger.error("Direction should be a string 'true' or 'false'")

    delta_list = []
    for distname in get_all_cells_distnames():
        delta_list.append(create_delta(distname=distname,
                                       parameter_name='act{}256Qam'.format(direction.title()),
                                       parameter_value=state))

    with AdminSession() as admin:
        delta = json.dumps(delta_list)
        admin.perform_delta_recommissioning(delta_file=delta)


def create_delta(distname, parameter_name, parameter_value):
    parameter_delta = {
        "distName": distname,
        "operation": "update",
        "parameters": [
            {
                "parameterName": parameter_name,
                "value": parameter_value,
                "operation": "update"
            }
        ]
    }
    return parameter_delta


def verify_mcs_in_bip_logs(pcap_file, exp_mod, l_bound64=1, u_bound64=28, mcs_table_only=False):
    """
    Check mcs average and qam mod table.
    :param pcap_file:       File path to the pcap file collected by bip mirroring sh
    :param exp_mod:         Exp qam mod table, possible values: 64, 256
    :param l_bound64:       lowest acceptable mcs average value for 64 mod
    :param u_bound64:       highest acceptable mcs average value for 64 mod
    :param mcs_table_only:  If set, boolean flag indicates qam mod table should be checked only
    """
    frames = get_all_frames(pcap_file=pcap_file, lua_attached=False, ts_filter=mcs_filter)
    mcs_frames = [PuschFrame(frame) for frame in frames]

    frames_for_rnti = get_frames_for_rntis_mapping(mcs_frames)

    for rnti in frames_for_rnti.keys():
        if len(frames_for_rnti[rnti]) < 50:
            del frames_for_rnti[rnti]

    rntis_count = len(frames_for_rnti.keys())
    if rntis_count != 2:
        print('Found {} RNTIs. Should have found 2.'.format(rntis_count))

    ue_frames = list(frames_for_rnti.values())[0]

    assert get_mcs_table(ue_frames) == '{}QAM'.format(exp_mod), 'Modulation for first UE should be {}QAM'.format(
        exp_mod)
    if mcs_table_only:
        return

    exp_avg_bounds = {'256': [20, 27],
                      '64': [l_bound64, u_bound64], }
    assert exp_avg_bounds[exp_mod][0] <= get_mcs_average(ue_frames) <= exp_avg_bounds[exp_mod][1], \
        'Wrong MCS for UE'


def verify_mcs_counters(connection):
    """
    Check if counters related to 256qam MCS success are present on BTS and are greater than 0.
    :param connection:      OAM admin connection instance
    """
    # successful any: scout.nsn-rdnet.net/kpis-templates/155/
    exp_counters = {'success_any': ['M55302C1402{}'.format(i) for i in range(8)], }
    with AdminSession() as admin:
        counters_dict = admin.get_counters_info(connection=connection, timeout=60)
    c_validator = CountersValidator()
    c_validator.check_counters_dict(counters_dict, exp_counters)

    assert c_validator.any_counter_presence, "None of expected counters: {} is present/greater than 0 on BTS".format(
        exp_counters['success_any'])


class CountersValidator:
    """Verify counters dict returned from OAM admin"""
    def __init__(self):
        self.any_counter_presence = False

    def check_counters_dict(self, counters_dict, exp_counters):
        """
        Browse counters dict recursively for expected counters.
        If any expected counter found, then check if contains any non-zero value.
        :param counters_dict:           Counters dict returned from OAM admin
        :param exp_counters:            List of expected counters
        :return:
        """
        for counter in counters_dict:
            if counter in exp_counters['success_any']:
                logger.console("Counter: " + str(counter) + "is present on BTS")
                any_counter_presence = self.check_if_counters_are_non_zero(counter_dict=counters_dict[counter])
                if any_counter_presence:
                    logger.console("Counter: " + str(counter) + " contains non-zero value: {}".format(
                        counters_dict[counter]))
                    self.any_counter_presence = True
            else:
                if isinstance(counters_dict[counter], dict):
                    self.check_counters_dict(counters_dict[counter], exp_counters)

    @staticmethod
    def check_if_counters_are_non_zero(counter_dict):
        """
        Check counter dict values
        :param counter_dict:    Dictionary with counter values associated to single counter
                                in main counters dict
        :return:                True if any value is > 0
        """
        for _key in counter_dict:
            try:
                val = int(counter_dict[_key])
                if val > 0:
                    return True
            except Exception:
                pass
        return False


def compare_tput_values(first_value, second_value):
    assert first_value < second_value, "256QAM tput {} is not greater than 64QAM tput {}".format(second_value,
                                                                                                 first_value)

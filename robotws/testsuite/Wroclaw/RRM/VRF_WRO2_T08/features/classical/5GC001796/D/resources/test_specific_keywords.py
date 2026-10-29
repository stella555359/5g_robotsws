import testsuite.Wroclaw.RRM.resources.rrm_fixture as fixture
import testsuite.Wroclaw.RRM.resources.scf_verification.scf_verifier as scfv
import testsuite.Wroclaw.RRM.resources.tti_verification.csv_verification as ttiv
from testsuite.Wroclaw.RRM.resources.common.file_helper import get_files_filepaths
from testsuite.Wroclaw.RRM.resources.log.helper import LogHelper
from testsuite.Wroclaw.RRM.resources.log.matchers import PcapMessageMatcher as pm
from testsuite.Wroclaw.RRM.resources.log.matchers import SyslogMessageMatcher as sm

slots_per_sfn = 10


def setup_preconditions_for_ini_mcs():
    param_dict = {'actDl256Qam': 'true', 'ullaIniMcs': '18', 'actEnhancedLinkAdaptation': 'true'}
    scfv.setup_and_check_preconditions_in_scf(param_dict)


def check_that_sinr_is_averaged_based_on_pusch(tti_filepath, percent_margin_of_mismatch=5):
    pusch_data = ttiv.process_needed_messages(tti_filepath, ['ulPuschReceiveRespPsData'])
    raw_avg_data = ttiv.process_needed_messages(tti_filepath, ['ulLaAverageSinr'])
    srs_data = ttiv.process_needed_messages(tti_filepath, ['ulSrsReceiveRespPs'])
    num_pusch_messages = len(pusch_data)
    assert num_pusch_messages > 100, "Way too few ({}) ulPuschReceiveRespPsData messages in provided tti trace"\
        .format(num_pusch_messages)
    assert len(raw_avg_data) > 100, "Way too few ({}) ulLaAverageSinr messages in tti trace".format(len(raw_avg_data))
    assert len(srs_data) == 0, "srsReceiveRespPs messages are present in logs"
    avg_data = ttiv.filter_list_of_dicts('rrmInstSinrRank', 'RANK_SINGLE_TX', raw_avg_data)
    assert len(raw_avg_data) == len(avg_data), "Found ul sample with rank different than 'RANK_SINGLE_TX'"
    mismatch_count = 0
    count = 0
    for pusch_msg in pusch_data:
        if pusch_msg['dtx'] == '0':
            if not find_ulLaAverageSinr_corresponding_to_given_ulPuschReceiveRespPsData(avg_data, pusch_msg):
                mismatch_count += 1
            assert mismatch_count * 100 / num_pusch_messages < percent_margin_of_mismatch, \
                "Too many ulPuschReceiveRespPsData messages does not have their corresponding ulLaAverageSinr" \
                " messages\nNumber of pusch messages: {}\nAllowed margin of mismatch: {}"\
                .format(num_pusch_messages, percent_margin_of_mismatch)
        count += 1
        if not count % 1000:
            fixture.run_robot_keyword('log_to_console', "Processed {} messages.".format(count))


def find_ulLaAverageSinr_corresponding_to_given_ulPuschReceiveRespPsData(avg_data, pusch_msg, range=200):
    avg_msgs = ttiv.filter_list_of_dicts('rrmInstSinr', pusch_msg['sinr_[0]'], avg_data)
    avg_msg = _determine_nearest_neighbour_message(avg_msgs, pusch_msg, range)
    return avg_msg


def _determine_nearest_neighbour_message(candidates, message, max_distance=200):
    best_candidate = None
    best_score = 999999
    for msg in candidates:
        score = abs(message['line_number'] - msg['line_number'])
        if score < best_score and score <= max_distance:
            best_score = score
            best_candidate = msg
    return best_candidate


def change_actEnhancedLinkAdaptation_parameter(bool_string):
    dist_name = 'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}'.format(
        mrbts_id=fixture.get_robot_variable('${tl.gnbs[0].instance_id}'),
        nrbts_id=fixture.get_robot_variable('${tl.gnbs[0].global_bts_id}'))
    with fixture.webUI.WebUIOperations() as coam:
        coam.perform_parameter_recommissioning(dist_name=dist_name,
                                               parameter='actEnhancedLinkAdaptation',
                                               operation='update',
                                               skip_parameter_relation_errors=False,
                                               value=bool_string)
        fixture.webUI.wait_for_all_cells_on_air_state()


def change_ullainimcs(value):
    dist_path = 'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-'.format(
        mrbts_id=fixture.get_bts_id(),
        nrbts_id=fixture.get_robot_variable('${tl.gnbs[0].global_bts_id}'))
    dist_names = [dist_path + '1', dist_path + '2', dist_path + '3']
    with fixture.webUI.WebUIOperations() as coam:
        for dist_name in dist_names:
            coam.perform_parameter_recommissioning(dist_name=dist_name,
                                                   parameter='ullaIniMcs',
                                                   operation='update',
                                                   value=value,
                                                   skip_parameter_relation_errors=False,
                                                   timeout=900)
        fixture.webUI.wait_for_all_cells_on_air_state()


# TODO: This function is related to subfeature C. To be removed.
def end_of_pause_analyze(tti_path):
    list_of_msg = ttiv.process_needed_messages(tti_path, ['ulLaDeltaSinr'])
    number_of_nok = 0
    previous_value_pause = None
    for message in list_of_msg:
        crcFb = message['crcFb']
        rrmPauseUeInUlScheduling = message['rrmPauseUeInUlScheduling']
        print(message['rnti'], rrmPauseUeInUlScheduling, previous_value_pause, crcFb, number_of_nok)
        if crcFb == 'NOK' or crcFb == 'DTX':
            if rrmPauseUeInUlScheduling == '1':
                print('pauza'+60*'*\n')
                break
            number_of_nok += 1
            if number_of_nok == 75:
                assert rrmPauseUeInUlScheduling == '1' and rrmPauseUeInUlScheduling != previous_value_pause

        else:
            number_of_nok = 0

        previous_value_pause = rrmPauseUeInUlScheduling


def check_value_of_act_enhanced_link_adaptation_in_syslog(expected_value):
    with LogHelper() as lh:
        syslog = lh.add_syslog(get_files_filepaths('/tmp/btslog2/', pattern='SYSLOG_*.LOG'))
        msg = syslog.find_next(sm('*"actEnhancedLinkAdaptation":{}*'.format(str(expected_value))))
        assert msg is not None, 'No sign of actEnhancedLinkAdaptation message or incorrect value.'


def check_value_of_act_enhanced_link_adaptation_in_pcap(pcap_path, value):
    with LogHelper() as lh:
        pcap1 = lh.add_pcap(pcap_path, lua=True)
        msg = pcap1.find_next(pm('UserSetupReq').containing('actEnhancedLinkAdaptation*', value))
        assert msg is not None


def check_if_used_mcs_is_higher_than_init(tti_path, la_ini_mcs=18):
    ul_fd_sched_data = ttiv.process_needed_messages(tti_path, ['ulFdSchedData'])
    margin_percent = 5
    nok_counter = 0
    for message in ul_fd_sched_data:
        used_mcs = message['rrmUlUsedMcs']

        if float(used_mcs) < la_ini_mcs:
            nok_counter += 1

    error = nok_counter * 100 / len(ul_fd_sched_data)
    fixture.log_message(message='error: ' + str(error))
    assert error <= margin_percent, 'mcs are not incremented during LA.'


def check_if_used_mcs_is_correct_if_feature_off(tti_path, la_ini_mcs=18):
    ul_fd_sched_data = ttiv.process_needed_messages(tti_path, ['ulFdSchedData'])
    for message in ul_fd_sched_data:
        used_mcs = int(message['rrmUlUsedMcs'])
        proposed_mcs = int(message['rrmUlProposedMcs'])
        if proposed_mcs == 255:
            continue
        assert used_mcs == la_ini_mcs, 'MCS is not equal to init MCS, even though LA is turned off.' \
                                       ' Used mcs = {}, Expected mcs = {}'.format(used_mcs, la_ini_mcs)
        break

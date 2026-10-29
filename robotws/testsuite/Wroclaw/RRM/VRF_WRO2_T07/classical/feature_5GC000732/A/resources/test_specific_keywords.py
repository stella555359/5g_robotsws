from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.common.file_helper import get_filepaths
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.log_helper import LogHelper
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.matchers import \
    SyslogMessageMatcher as Sm, PcapMessageMatcher
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.pm_counters import check_counter_equals_x
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.update_helpers import get_sw_version


@logged_keyword
def analyse_732_A_1(sctp_logs, btslog_dir):
    blog('Start F1AP logs analysis...')
    gnb_cu_ue_id = analyse_f1ap_732_A_1(sctp_logs)
    blog('F1AP analysed successfully.')
    blog('Start btslog analysis....')
    analyse_btslog_732_A_1(btslog_dir, gnb_cu_ue_id)
    blog('Syslog analysed successfully.')


@logged_keyword
def analyse_f1ap_732_A_1(log_file):
    with LogHelper() as lh:
        finder = lh.add_pcap(pcap_file_path=log_file, tshark_filter='f1ap')

        msg = finder.find_next(PcapMessageMatcher('UEContextSetupResponse', message_type_pattern='empty'))
        assert msg is not None, 'UEContextSetupResponse could not be found.'

        gnb_cu_ue_id = str(msg.find('GNB-CU-UE-F1AP-ID').first()['val'])
        blog('found gNB_CU_UE_ID: {}'.format(gnb_cu_ue_id))
        return gnb_cu_ue_id


@logged_keyword
def analyse_btslog_732_A_1(btslog_dir, gnb_cu_ue_id):
    analyse_simple_reestablishment(btslog_dir, gnb_cu_ue_id)


def analyse_simple_reestablishment(btslog_dir, gnb_cu_ue_id):
    sw_version = get_sw_version()
    if "SBTS00" in sw_version:
        from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.common_regular_expressions \
            import RegularExpressionsTrunk as RegularExpressions
    elif "22R4" in sw_version:
        from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.common_regular_expressions \
            import RegularExpressions22R4 as RegularExpressions
    elif "22R3" in sw_version:
        from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.common_regular_expressions \
            import RegularExpressions22R3 as RegularExpressions
    elif "22R2" in sw_version:
        from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.common_regular_expressions \
            import RegularExpressions22R2 as RegularExpressions
    else:
        assert False, "Regular expressions not found for this SW version: {}".format(sw_version)

    with LogHelper() as lh:
        syslog = lh.add_syslog(get_filepaths(btslog_dir, pattern='SYSLOG_*.LOG'))

        msg_1 = syslog.find_one(Sm(RegularExpressions.REE_REQUEST_REGEX, regex_engine='re'),
                                assert_msg='No sign of RrcReestablishmentRequest in syslog.')
        blog('FOUND: {}'.format(msg_1))

        msg_2 = syslog.find_one(Sm(RegularExpressions.REE_COMPLETE_REGEX),
                                assert_msg='No sign of RRCReestablishmentComplete in syslog.')
        blog('FOUND: {}'.format(msg_2))

        syslog.find_next(Sm(RegularExpressions.REE_COMPLETE_REGEX))

        msg_3 = syslog.find_next(Sm(RegularExpressions.RRC_RECONFIG_COMPLETE))
        assert msg_3 is not None, 'No sign of 1st RRCReconfigurationComplete in syslog.'
        blog('FOUND: {}'.format(msg_3))

        msg_4 = syslog.find_next(Sm(RegularExpressions.RRC_RECONFIG_COMPLETE))
        assert msg_4 is not None, 'No sign of 2nd RRCReconfigurationComplete in syslog.'
        blog('FOUND: {}'.format(msg_4))

        msg_5 = syslog.find_next(Sm(RegularExpressions.UE_CONTEXT_MOD_RESPONSE.format(gnb_cu_ue_id), regex_engine='re'))
        assert msg_5 is not None, 'No sign of correct UeContextModificationResponse in syslog.'
        blog('FOUND: {}'.format(msg_5))


@logged_keyword
def analyse_PM_counters_732_A_3(pi_dir):
    blog('Start PM counters analysis....')
    check_counter_equals_x(pi_dir, 'M55124C00505', ['1', '2', '3'], 1)
    check_counter_equals_x(pi_dir, 'M55124C00512', ['1', '2', '3'], 1)
    check_counter_equals_x(pi_dir, 'M55127C00503', ['1'], 1)
    check_counter_equals_x(pi_dir, 'M55127C00512', ['1'], 1)
    blog('PM counters analysed successfully.')

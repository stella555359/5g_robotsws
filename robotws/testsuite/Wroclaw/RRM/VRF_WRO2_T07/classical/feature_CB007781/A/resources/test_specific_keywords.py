from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.attach_verification import get_attached_rntis
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.log_helper import LogHelper
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.matchers import PcapMessageMatcher, TTIMessageMatcher

TP_COUNTER_THRESHOLD = '100'
TP_TRANSIENT_STATE = ['1', '3']
TP_ON_STATE = '2'


def analyse_7781_logs(sctp_logs, tti_logs):
    blog('Start logs analysis for CB007781...')
    attached_rntis = get_attached_rntis(sctp_logs)
    blog('Start F1AP logs analysis...')
    analyse_f1ap_7781(sctp_logs)
    blog('F1AP logs analysis finished.')
    blog('Start TTI logs analysis...')
    analyse_tti_7781(tti_logs, attached_rntis)
    blog('TTI logs analysis finished.')
    blog('Logs analysis for CB007781 finished.')


def analyse_f1ap_7781(log_file):
    with LogHelper() as lh:
        finder = lh.add_pcap(pcap_file_path=log_file, tshark_filter='f1ap')
        msg = finder.find_exactly(2,
                                  PcapMessageMatcher('UEContextModificationRequired', message_type_pattern='empty'),
                                  assert_msg='Invalid number of UEContextModificationRequired messages in f1ap logs.')
        tp_flag_enable = msg[0].find('transformPrecoder').first()['val']
        tp_flag_disable = msg[1].find('transformPrecoder').first()['val']

    blog('tp_enable_flag: ' + str(tp_flag_enable))
    blog('tp_disable_flag: ' + str(tp_flag_disable))
    assert 'enable' in tp_flag_enable and 'disable' in tp_flag_disable, \
        'Transform precoder is not turned on/off correctly.'


def analyse_tti_7781(tti_logs, rntis):
    with LogHelper() as lh:
        tti_finder = lh.add_tti(log_files=tti_logs)
        all_ulFdSchedData = tti_finder.find_all(TTIMessageMatcher('ulFdSchedData').containing(
            key_pattern='rnti', val_pattern=rntis[-1], regex_engine='re'))

    for msg in all_ulFdSchedData:
        pusch_tp_state = msg['puschTPstate']
        dci_format = msg['dciFormat']

        if pusch_tp_state in TP_TRANSIENT_STATE:
            assert dci_format == 'UL_00_FORCE', \
                'Invalid dciFormat during transient phase. Expected: UL_00_FORCE. Current: {}'.format(dci_format)

    assert any(msg['puschTPstate'] == TP_ON_STATE for msg in all_ulFdSchedData), \
        'Transform precoder was never turned on.'

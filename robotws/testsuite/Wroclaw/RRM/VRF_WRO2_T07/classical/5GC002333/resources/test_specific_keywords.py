from testsuite.Wroclaw.RRM.resources.log.matchers import SyslogMessageMatcher as sm
from testsuite.Wroclaw.RRM.resources.common.file_helper import get_files_filepaths
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.log_helper import LogHelper, log_finder


scf_params_K_3 = {'srbInactivityTimerSA': '60', 'drbInactivityTimerSA': '100'}

scf_params_K_4 = {'srbInactivityTimerSA': '60', 'drbInactivityTimerSA': '100'}

scf_params_K_5 = {'maxNumOfNonGBRBearersSA': '1', 'srbInactivityTimerSA': '300', 'drbInactivityTimerSA': '400'}

scf_params_J_1 = {'maxNumOfRrcSA': '1', 'srbInactivityTimerSA': '300', 'drbInactivityTimerSA': '400'}


def check_gnb_cu_rrc_rejection():
    with LogHelper() as lh:
        syslog = lh.add_syslog(get_files_filepaths('/tmp/btslog2/', pattern='SYSLOG_*.LOG'))
        msg = syslog.find_next(sm('*Max NonGbrBearers capacity already reached*'))
        assert msg is not None, 'no sign of CU rejection found.'


def check_gnb_du_rrc_rejection():
    with LogHelper() as lh:
        syslog = lh.add_syslog(get_files_filepaths('/tmp/btslog2/', pattern='SYSLOG_*.LOG'))
        msg = syslog.find_next(sm('*Admission Fail! exceed the max number*of sa users*'))
        assert msg is not None, 'no sign of DU rejection found.'


def check_if_release_complete_exists(pcap_file):
    relevant_frames = log_finder(pcap_file, 'f1ap.F1AP_PDU==1', 'UEContextReleaseComplete')
    for frame in relevant_frames:
        release_complete = frame.find('UEContextReleaseComplete*')
        if release_complete:
            return
    assert False, 'No UEContextReleaseComplete found. UE is not released.'


def check_if_rrc_reject_exists(pcap_file):
    relevant_frames = log_finder(pcap_file, 'f1ap.radioNetwork', 'radioNetwork')
    for frame in relevant_frames:
        release_complete = frame.find('radioNetwork*')
        if release_complete.first()['val'] == 'no-radio-resources-available (8)':
            return
    assert False, 'No RRC Reject found. DU rejection not properly handled.'

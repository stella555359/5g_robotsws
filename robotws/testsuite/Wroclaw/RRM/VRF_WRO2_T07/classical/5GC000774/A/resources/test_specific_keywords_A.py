from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api import admin_api
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog
from testsuite.Wroclaw.RRM.resources.decorators import logged_keyword
from testsuite.Wroclaw.RRM.resources.log.helper import LogHelper
from testsuite.Wroclaw.RRM.resources.log.matchers import SyslogMessageMatcher
from testsuite.Wroclaw.RRM.resources.common.file_helper import get_files_filepaths
import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.pm_counters as pmc
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.attenuator import Attenuator
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config import tl
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.testline_preparation import get_sw_release_name

scf_params_rohc_a = {'actRohc': 'true', 'maxCidAllowed': '2', 'miNrNGCC': '5min', 'actNrpmqapProfiles': 'true'}
scf_params_rohc_maxCid_1 = {'actRohc': 'true', 'maxCidAllowed': '1'}
swconfig_flags_rohc = {'0x5a0604': ('1', 'rdDebugRohc')}
atten = Attenuator(with_initialisation=True)
CONDITIONAL_RELEASE_24R2 = int('SBTS24R2'[4:].replace('R', ''))


@logged_keyword
def check_intra_handover_vonr(log_path):
    found_ho = check_intra_handover(log_path)
    # TODO: FIND CONTEXT REESTABLISHMENT
    # context_reset_after_ho = found_ho.find_all(SyslogMessageMatcher(r'*TODO: FIND CONTEXT REESTABLISHMENT*'))
    # assert context_reset_after_ho is not None, 'no sign of context reestablishment after HO.'
    check_rohc_reset_and_initialization(log_path)


@logged_keyword
def check_inter_handover_vonr(log_path):
    found_ho = check_inter_handover(log_path)
    # TODO: FIND CONTEXT REESTABLISHMENT
    context_reset_after_ho = found_ho.find_all(SyslogMessageMatcher(r'*TODO: FIND CONTEXT REESTABLISHMENT*'))
    # assert context_reset_after_ho is not None, 'no sign of context reestablishment after HO.'
    check_rohc_reset_and_initialization(log_path)


@logged_keyword
def check_intra_handover(log_path):
    with LogHelper() as lh:
        syslog = lh.add_syslog(get_files_filepaths(log_path, pattern='SYSLOG_*.LOG'))
        msg = syslog.find_next(SyslogMessageMatcher('*Update UE context after intra-DU handover*'))
        assert msg is not None, 'no sign of Intra-gNB Handover found.'
        return syslog


@logged_keyword
def check_inter_handover(log_path):
    with LogHelper() as lh:
        syslog = lh.add_syslog(get_files_filepaths(log_path, pattern='SYSLOG_*.LOG'))
        handover_start = syslog.find_next(SyslogMessageMatcher('*Triggering sa Mode Inter DU/gnb Handover*'))
        handover_end = syslog.find_next(SyslogMessageMatcher('*ueAddCause:HANDOVER*'))

        assert handover_start is not None, 'no sign of Inter-gNB Handover trigger.'
        assert handover_end is not None, 'no sign of Inter-gNB Handover completion.'
        return syslog


@logged_keyword
def check_inter_handover_max_cid_allowed_changed_1_to_2(source_logs, target_logs):
    # on source BTS
    check_rohc_for_max_cid_allowed_1(source_logs)

    # on target BTS
    check_inter_handover(target_logs)
    check_rohc_for_max_cid_allowed_2(target_logs)


@logged_keyword
def check_inter_handover_max_cid_allowed_changed_2_to_1(source_logs, target_logs):
    # on source BTS
    check_rohc_for_max_cid_allowed_2(source_logs)

    # on target BTS
    check_inter_handover(target_logs)
    check_rohc_for_max_cid_allowed_1(target_logs)


@logged_keyword
def check_rohc_for_max_cid_allowed_1(log_path):
    with LogHelper() as lh:
        syslog = lh.add_syslog(get_files_filepaths(log_path, pattern='SYSLOG_*.LOG'))

        msg = syslog.find_next(SyslogMessageMatcher('*Packet is UDP-compressible*Using profile 0x0002*'))
        assert msg is None, 'UDP packets are sent using inappropriate profile.'

        syslog.reset_generator()
        msg = syslog.find_next(SyslogMessageMatcher('*Successfully created ROHC packet cid=1 profile=0*'))
        assert msg is not None, 'UDP packets are sent using inappropriate profile.'

        syslog.reset_generator()
        msg = syslog.find_next(SyslogMessageMatcher('*Successfully created ROHC packet cid=1 profile=2*'))
        assert msg is None, 'UDP packets are sent using inappropriate profile.'


@logged_keyword
def check_rohc_for_max_cid_allowed_2(log_path):
    with LogHelper() as lh:
        syslog = lh.add_syslog(get_files_filepaths(log_path, pattern='SYSLOG_*.LOG'))
        msg = syslog.find_next(
            SyslogMessageMatcher(
                '*Packet is UDP-compressible*Context profile differs from the best profile, mapping to uncompressed*'))
        assert msg is None, 'UDP packets are sent using inappropriate profile.'

        syslog.reset_generator()
        msg = syslog.find_next(SyslogMessageMatcher('*Successfully created ROHC packet cid=1 profile=0*'))
        assert msg is None, 'UDP packets are sent using inappropriate profile.'

        syslog.reset_generator()
        msg = syslog.find_next(SyslogMessageMatcher('*Successfully created ROHC packet cid=1 profile=2*'))
        assert msg is not None, 'UDP packets are sent using inappropriate profile.'


@logged_keyword
def check_rohc_reset_and_initialization(log_path):
    found_ho = check_intra_handover(log_path)
    transition_to_so_state = found_ho.find_all(
        SyslogMessageMatcher(
            r'(Transit to SO state\(U mode\)) | (move context from IR to SO state)', regex_engine='re'))
    assert transition_to_so_state is not None, 'No transition to SO state after ROHC reset.'
    blog('transition_to_so_state')
    blog(transition_to_so_state)

    found_ho.reset_generator()
    transition_to_o_mode = found_ho.find_all(SyslogMessageMatcher(r'*mode transition to O-mode*'))
    assert transition_to_o_mode is not None, 'No transition to O mode after ROHC reset.'
    blog('transition_to_o_mode')
    blog(transition_to_o_mode)


@logged_keyword
def check_gnb_side_rohc_decompressor(log_path):
    with LogHelper() as lh:
        syslog = lh.add_syslog(get_files_filepaths('/tmp/btslog2/', pattern='SYSLOG_*.LOG'))
        if admin_api.assign_release_version() >= '23R1':
            msg = syslog.find_next(SyslogMessageMatcher('*ROHC*decompressed*snReparseAttempt*'))
        else:
            msg = syslog.find_next(SyslogMessageMatcher('*INF/ROHC*IR packet *profile*'))
        assert msg is not None, 'no sign of ROHC decompressor at gNB-side found.'

        transition_to_so_state = syslog.find_all(
            SyslogMessageMatcher(
                r'(Transit to SO state\(U mode\)) | (move context from IR to SO state)', regex_engine='re'))
        assert transition_to_so_state is not None, 'No transition to SO state after ROHC reset.'
        blog('transition_to_so_state')
        blog(transition_to_so_state)

        transition_to_o_mode = syslog.find_all(SyslogMessageMatcher(r'*mode transition to O-mode*'))
        assert transition_to_o_mode is not None, 'No transition to O mode after ROHC reset.'
        blog('transition_to_o_mode')
        blog(transition_to_o_mode)


@logged_keyword
def check_ue_side_rohc_decompressor(log_path):
    with LogHelper() as lh:
        ue_log = lh.add_syslog(log_path)
        msg = ue_log.find_next(SyslogMessageMatcher('*0x1362  RoHC Decompressor*'))
        assert msg is not None, 'no sign of ROHC decompressor at UE-side found.'


@logged_keyword
def get_and_verify_counters(counter_dir, counter_ids):
    value_dict = pmc.get_relevant_pm_counters(pi_dir=counter_dir, counter_ids=counter_ids)
    if not value_dict:
        raise KeyError('dict is empty, there is no such counters collected on bts')
    return value_dict


@logged_keyword
def check_Voice_Counters_incremented(counters, target_counter_values=None):
    M55125C09517_numbers = [1]
    M55125C09518_numbers = [1]
    if not target_counter_values:
        target_counter_values = [1, 2]
    verify_counter(counters, M55125C09517_numbers, "M55125C09517", target_counter_values)
    verify_counter(counters, M55125C09518_numbers, "M55125C09517", target_counter_values)


@logged_keyword
def verify_counter(counters, scell_numbers, counter, target_counter_values):
    values = [counters[counter][cell][-2] for cell in counters[counter] if int(cell) in
              scell_numbers]
    assert len(set(values)) == 1 and values[0] in target_counter_values, \
        "Not all values in {} counter are increased".format(counter)


@logged_keyword
def stop_call():
    atten.gradually_increase_attenuation(init_value=0, max_value=90, step=1, interval=0.1,
                                         ports=[tl.nr_cell_1_ports], attenuator_id=1)


@logged_keyword
def verify_counter_8200(counters, cell, counter1, counter2, counter3, counter4):
    bts_sw_release = int(get_sw_release_name()[4:8].replace('R', ''))
    if bts_sw_release > CONDITIONAL_RELEASE_24R2:
        assert [counters[counter1][cell][-1]] == [counters[counter2][cell][-1]] and \
               [counters[counter3][cell][-1]] == [counters[counter4][cell][-1]], \
               blog("PMQAP and 5QI-1 counters not equal")
    else:
        blog("correction for PMQAP counters not implemented in this SW")

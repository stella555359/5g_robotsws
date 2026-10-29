from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.log_helper import LogHelper
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.matchers import TTIMessageMatcher, PcapMessageMatcher
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.classical.feature_CB008238.A.resources.test_specific_keywords import pairwise, \
    check_highest_class_prio_for_rnti, DTX_OPTIMIZED_DRB_TRAFFIC_CLASS
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.testline_preparation import get_sw_release_name
from testsuite.Wroclaw.RRM.resources.scf_verification import scf_verifier

scf_params_b1 = {'actPdschAtSsbSlots': 'true', 'actPdschRmCsirsForTracking': 'true', 'actMicroDTX': 'true',
                 'actDtxOptimizedScheduler': 'true', 'dtxDelaySinceLastScheduling': '0',
                 'dtxMaxRetentionDelay': '40', 'dtxPrbThreshold': '80', 'maxNumOfRrcSA': '275',
                 'maxNumOfRrcCGRPSA': '275'}

scf_params_b2 = {'actPdschAtSsbSlots': 'false', 'actPdschRmCsirsForTracking': 'false', 'actMicroDTX': 'true',
                 'actDtxOptimizedScheduler': 'true', 'dtxDelaySinceLastScheduling': '0',
                 'dtxMaxRetentionDelay': '10', 'dtxPrbThreshold': '80', 'maxNumOfRrcSA': '275',
                 'maxNumOfRrcCGRPSA': '275'}

scf_params_b4 = {'actPdschAtSsbSlots': 'false', 'actPdschRmCsirsForTracking': 'false', 'actMicroDTX': 'true',
                 'actDtxOptimizedScheduler': 'true', 'dtxDelaySinceLastScheduling': '0',
                 'dtxMaxRetentionDelay': '30', 'dtxPrbThreshold': '80', 'maxNumOfRrcSA': '275',
                 'maxNumOfRrcCGRPSA': '275'}

DL_DRB_DTX_CLASS = ['15', '18']
DL_DRB_DTX_CLASS_Trunk = ['19']
EMPTY_BUFFER_CLASS = ['19', '22', '23', '28', '31']
DEPRIORITIZED_VOIP_CLASS = ['15', '20', '28']
UE_SCHEDULED_IN_SIGNALLING_SLOT = 'SCHEDONSIBORPAGING'
EXIT_NULL_BUFFER = 'EXITNULLBUFFER'

EXPECTED_PERCENT_OF_SSB_WITH_PDSCH = 50
ERROR_MARGIN_FOR_INVALID_PRIO_14 = 7
DRB_SCHEDULED_WITH_VONR_THRESHOLD = 1
CONDITIONAL_RELEASE_25R1 = int('SBTS25R1'[4:].replace('R', ''))


def check_sched_on_sib_or_paging_slots(tti_logs):
    blog('Check "dlDtxOptimEvent" in the "dlDtxOptimData" event in TTI...')
    with LogHelper() as lh:
        tti_finder = lh.add_tti(log_files=tti_logs)
        sched_on_sib_or_paging = tti_finder.find_all(TTIMessageMatcher('dlDtxOptimData').containing(
            key_pattern='dlDtxOptimEvent', val_pattern=UE_SCHEDULED_IN_SIGNALLING_SLOT, regex_engine='re'))

        assert sched_on_sib_or_paging is not None, 'No scheduling on signalling slots was found'
        blog('dlDtxOptimData analysed successfully.')


def check_prio_14_is_assigned_correctly_after_prio_18(tti_logs, rntis):
    blog('Check that "dlDrbDtx" (prio 14) class is not assigned directly after an empty buffer class.')
    for rnti in rntis:
        check_prio_14_is_assigned_correctly_for_rnti(tti_logs, rnti)
    blog('dlDrbDtx analysed successfully.')


def check_prio_14_is_assigned_correctly_for_rnti(tti_logs, rnti):
    blog('Checking "dlDrbDtx" class for RNTI {}...'.format(rnti))
    with LogHelper() as lh:
        tti_finder = lh.add_tti(log_files=tti_logs)
        tti_matcher = TTIMessageMatcher('dlPreSchedData'). \
            containing(key_pattern='rnti', val_pattern=rnti, regex_engine='re')
        relevant_dlPreSchedData = tti_finder.find_all(tti_matcher)
    blog(f'Found {len(relevant_dlPreSchedData)} dlPreSchedData messages for RNTI {rnti}')
    for i, msg in enumerate(relevant_dlPreSchedData[:20]):
        blog(f"[{i}] rnti={msg.get('rnti')} "
             f"prio={msg.get('highestClassPriority')} "
             f"event={msg.get('csListEvent')}")
    empty_buffers = 0
    bad_msgs = 0
    for prev, current in pairwise(relevant_dlPreSchedData):
        if prev['highestClassPriority'] in EMPTY_BUFFER_CLASS and prev['csListEvent'] == EXIT_NULL_BUFFER:
            empty_buffers += 1
            if current['highestClassPriority'] in DL_DRB_DTX_CLASS or\
                    current['highestClassPriority'] == DL_DRB_DTX_CLASS_Trunk:
                bad_msgs += 1

    try:
        actual_error = 100 * float(bad_msgs) / empty_buffers
    except ZeroDivisionError:
        raise Exception('no messages with prio 18 have been found!')
    blog('Error for "dlDrbDtx" (prio 14) class check: {}%'.format(actual_error))

    assert actual_error <= ERROR_MARGIN_FOR_INVALID_PRIO_14, \
        'EMPTY BUFFER DOES NOT RESET MAX RETENTION TIMER. Expected error: {}%. Current error: {}%'.format(
            ERROR_MARGIN_FOR_INVALID_PRIO_14, actual_error)
    blog('"dlDrbDtx" class check for RNTI {} finished successfully.'.format(rnti))


def check_pdsch_at_ssb_slots(l1l2_logs, rntis):
    blog('Check whether scheduling occurs on SSB slots, even when "dlDrbDtx" class is not assigned.')
    with LogHelper() as lh:
        finder = lh.add_pcap(pcap_file_path=l1l2_logs,
                             tshark_filter='dldata_ssblocksendreq || dldata_pdschsendreq')

        pdsch_send_req_matcher = PcapMessageMatcher('dldata_pdschsendreq', message_type_pattern='empty'). \
            containing(key_pattern='*rnti*', value_pattern='*{}*'.format(rntis[0])). \
            containing(key_pattern='*slot*', value_pattern='*0*')
        ssb_matcher = PcapMessageMatcher('dldata_ssblocksendreq', message_type_pattern='empty'). \
            containing(key_pattern='*subcellId*', value_pattern='*0*')
        all_ssb = finder.find_all(ssb_matcher)
        all_pdsch_send_req = finder.find_all(pdsch_send_req_matcher)
        pdsch_on_ssb_slot = 0
        for ssb in all_ssb:
            ssb_sfn = ssb.find('*sfn*').first()['val']
            for idx, pdsch in enumerate(all_pdsch_send_req):
                pdsch_sfn = pdsch.find('*sfn*').first()['val']
                if pdsch_sfn == ssb_sfn:
                    pdsch_on_ssb_slot += 1
                    del all_pdsch_send_req[idx]
                    break
        try:
            ssb_with_pdsch_percent = 100 * float(pdsch_on_ssb_slot) / len(all_ssb)
        except ZeroDivisionError:
            raise Exception('no SSB messages have been found!')
        blog('Occurrence of Pdsch at SSB slot: {}%'.format(ssb_with_pdsch_percent))

        blog('L1L2 analysed successfully.')


def check_optimized_dtx_interaction_with_vonr(tti_logs, tput_ue_rnti, vonr_ue_rnti):
    blog('Checking optimized DTX interaction with VoNR...')
    check_drb_throughput_ue(tti_logs, tput_ue_rnti)
    check_vonr_ue(tti_logs, vonr_ue_rnti)

    check_drb_throughput_is_scheduled_with_vonr(tti_logs, [tput_ue_rnti, vonr_ue_rnti])


def check_drb_throughput_ue(tti_logs, tput_ue_rnti):
    check_highest_class_prio_for_rnti(tti_logs, tput_ue_rnti)
    check_prio_14_is_assigned_correctly_for_rnti(tti_logs, tput_ue_rnti)


def check_vonr_ue(tti_logs, vonr_ue_rnti):
    with LogHelper() as lh:
        tti_finder = lh.add_tti(log_files=tti_logs)
        tti_matcher = TTIMessageMatcher('dlPreSchedData'). \
            containing(key_pattern='rnti', val_pattern=vonr_ue_rnti, regex_engine='re')
        relevant_dlPreSchedData = tti_finder.find_all(tti_matcher)

    assert any(msg['highestClassPriority'] in DEPRIORITIZED_VOIP_CLASS for msg in relevant_dlPreSchedData), \
        'No "deprioritizedVoip" (prio 15) class could be found for VoNR-UE'
    assert all(
        msg['highestClassPriority'] != DL_DRB_DTX_CLASS or DL_DRB_DTX_CLASS_Trunk for msg in relevant_dlPreSchedData), \
        '"dlDrbDtx" (prio 14) class was incorrectly found for VoNR-UE'
    assert all(msg['highestClassPriority'] != DTX_OPTIMIZED_DRB_TRAFFIC_CLASS for msg in relevant_dlPreSchedData), \
        '"dtxOptimizedDrbTraffic" (prio 17) class was incorrectly found for VoNR-UE'


def check_drb_throughput_is_scheduled_with_vonr(tti_logs, tput_and_vonr_rntis):
    blog('Checking whether DRB traffic is scheduled with VoNR data...')
    with LogHelper() as lh:
        tti_finder = lh.add_tti(log_files=tti_logs)
        tti_matcher = TTIMessageMatcher('dlPreSchedData'). \
            containing(key_pattern='rnti', val_pattern='|'.join(tput_and_vonr_rntis), regex_engine='re')
        relevant_dlPreSchedData = tti_finder.find_all(tti_matcher)

    scheduled_with_vonr = 0
    voip_class_count = 0
    latest_drb_prio = None
    for msg_0, msg_1, msg_2 in threewise(relevant_dlPreSchedData):
        prio_0 = msg_0['highestClassPriority']
        prio_1 = msg_1['highestClassPriority']
        prio_2 = msg_2['highestClassPriority']
        if msg_0['rnti'] == tput_and_vonr_rntis[0]:
            latest_drb_prio = prio_0
        if prio_0 in DEPRIORITIZED_VOIP_CLASS and latest_drb_prio in DTX_OPTIMIZED_DRB_TRAFFIC_CLASS:
            voip_class_count += 1
            if prio_1 in EMPTY_BUFFER_CLASS and prio_2 in EMPTY_BUFFER_CLASS:
                scheduled_with_vonr += 1

    try:
        percent_scheduled_with_vonr = 100 * float(scheduled_with_vonr) / (voip_class_count + scheduled_with_vonr)
    except ZeroDivisionError:
        raise Exception('Did not find any VoIP class in TTI logs.')

    blog('Occurrence of scheduling with VoNR: {}%'.format(percent_scheduled_with_vonr))
    assert percent_scheduled_with_vonr >= DRB_SCHEDULED_WITH_VONR_THRESHOLD, \
        'Not enough DRB packets scheduled along VoNR data. Expected occurrence: {}. Current occurrence: {}'.format(
            DRB_SCHEDULED_WITH_VONR_THRESHOLD, percent_scheduled_with_vonr)

    blog('DRB is correctly scheduled along VoNR data.')


def threewise(iterable):
    return [(iterable[idx], iterable[idx + 1], iterable[idx + 2]) for idx in range(len(iterable) - 2)]


def check_preconditions_in_scf_8238(params_to_check=None):
    bts_sw_release = int(get_sw_release_name()[4:8].replace('R', ''))
    if bts_sw_release >= CONDITIONAL_RELEASE_25R1:
        params_to_check['actPdschAllocAroundSsb'] = 'false'
    scf_verifier.setup_and_check_preconditions_in_scf(params_to_check)
    blog("Preconditions fulfilled")

from testsuite.Krakow.RRM.RAN_PZ.resources.log.helper import LogHelper
from testsuite.Krakow.RRM.RAN_PZ.resources.log.matchers import PcapMessageMatcher as Matcher
from taf.internal.sbts.admin.exceptions import AdminApiProcedureTimeoutException
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations as GnbBbu
from taf.rfrl.bts.devices.du.pm_counters import GnbPmCounter, PmCounterOutputGetter
from taf.rfrl.bts.devices.du.commissioning import GnbCommissioning
from taf.rfrl.utilities.robot.general import get_builtin_value
from moler.util.moler_test import MolerTest
from datetime import datetime
import re

current_lua = True
HO_SUCCEEDED_MSG = r'.*?CellNeighbourStatusUpdateIndProcedure.cpp:\d+.*(Received NeighbourStatusUpdateInd| ' \
                   r'with.*status.*hoSucceeded.*)( with status hoSucceeded| .*Received NeighbourStatusUpdateInd)'
GNB_CHANGE_RESULT_MSG = r'.*?SgNbChangeEventHandler.cpp:\d+' \
                        r'.*?PCMD - Change sgNbChangeResult' \
                        r'.*?setting from : SgNbChangeResult:success to : SgNbChangeResult:success'
GNB_CHANGE_CONFIRM_MSG = r'.*?MessageHandler.hpp:\d+ Received response of type messages::x2ap::SgNBChangeConfirm'
SRB3_ACTIVE_MSG = r'.*?SgnbAdditionProcedure.cpp:\d+.*SRB3 is activated.*'
SRB3_INACTIVE_MSG = r'.*?SgnbAdditionProcedure.cpp:\d+.*SRB3 is not activated.*'
MAX_NUM_NRREL_MSG = r'.*?MeasurementReport(HandleService|HandlerServiceNsa).cpp:\d+ UE: ueIdCu:\d+, ' \
                    r'maximum number of (NrRels|NRRELs) reached: 0'
START_PCI_RESOLUTION_MSG = r'.*?ConcreteUeNsaLogMessage.cpp:\d+.*?StartPciResolutionNSA for PhyCellId:'
RL_FAILURE_MSG = r'.*?SgnbModificationRequestService.cpp:\d+' \
                 r'.*?Start UE initiated RadioLinkFailure handling with failureType.*?, isIntraDu false'
SGNB_RELEASE_CONFIRM_MSG = r'.*?SgnbReleaseRequiredProcedure.cpp:\d+ Received X2AP SgnbReleaseConfirm msg*'
SGNB_INITIATED_ACTIONS_MSG = r'.*?SgnbReleaseSgnbInitiatedActions.cpp:\d+' \
                             r'.*?Leaving sgnbReleaseRequiredProcedure with Completed status'
NRREL_REMOVAL_MSG = r'.*?AutomaticNeighbourRelationRemovalProcedure.cpp:\d+' \
                    r'.*?AutomaticNeighbourRelationRemovalProcedure:' \
                    r'.*?Removing 2 (NrRels|NRRELs) and 0 (NrAdjNrCells|NRADNRCELLs)(| due to expired idleTimeAllowed)'
NRADJNRCELL_REMOVAL_MSG = r'.*?AutomaticNeighbourRelationRemovalProcedure.cpp:\d+' \
                    r'.*?AutomaticNeighbourRelationRemovalProcedure:' \
                    r'.*?Removing 0 (NrRels|NRRELs) and 2 (NrAdjNrCells|NRADNRCELLs)(| due to expired idleTimeAllowed)'
FREQ_A3A5_MSG = r'.*?MeasurementReport(HandleService|HandlerServiceNsa)\.cpp:\d+\s\w+FreqA3(|A4)A5'
RECEIVED_NRCGI = r'.*?MeasurementReport(HandleService|HandlerServiceNsa).cpp:\d+.*Received\s{}NrcgiReport\s' \
                 r'with\sMeasId:\s\d+.*'
UE_HO_TRIGGER = r'.*?ConditionalMessageDispatcher\.hpp:\d+\sueIdCu:\d+\sConditionalMessageHandler\sis\screated\sfor' \
                r'\smessages::internal::StartMenbHandoverWithoutSCGChange'
ADDED_RELATION_CP = r'.*?Relation\sfrom\sNRCELL\s\[.*]\sto\scell\s\[.*]\shas\schanged\sto\sConfirmed'
HO_SUCCEEDED_CP = r'.*?ConcreteCplaneClSender\.cpp:\d+\s(nonStandaloneAndStandalone,\s|)\"ssbFrequency\":.*>(\d+)<' \
                  r'.*\s\"cellIndividualSsbRsrpOffset\":\s\"--\",\s\"cellIndividualSsbRsrqOffset\":\s\"--\",\s' \
                  r'\"plmnNsaList\":.*MCC:\s\d+,\sMNC:\s\d+.*,\s\"physCellId\":\s.*>(\d+)<.*,\s\"nrRefType\":\s' \
                  r'(\"|)nrAdjNrCell(\"|),\s\"status\":\s(\"|)hoSucceeded(\"|)'
UL_PROACTIVE_GRANT_DISABLED = r'.*?UlProGrantType\schange:.*Rnti:\d+.\sNONSKIPPABLE->DISABLED'


def _check_active_sw():
    bbu = GnbBbu()
    active_sw = bbu.get_bts_sw_release_name()
    MolerTest.info('Active gNB SW release: {}'.format(active_sw))
    return active_sw


def get_empty_list():
    return []


def _file_reader(filename):
    with open(filename, 'r') as f:
        for line in f:
            yield line


def _find_pattern_in_syslog(pattern_string, syslog):
    pattern = re.compile(pattern_string, re.IGNORECASE)
    found_pattern = False
    for line in _file_reader(syslog):
        if pattern.match(line):
            found_pattern = True
            MolerTest.info('Pattern found in syslog: "{}"'.format(line))
            break
    if not found_pattern:
        raise ValueError('Not found pattern: "{}" in syslog: "{}"'.format(pattern_string, syslog))


def verify_handover_milestone_msgs_in_syslog(syslog_path, freq_type, check_grant):
    milestone_msgs = [RECEIVED_NRCGI.format(freq_type), UE_HO_TRIGGER, ADDED_RELATION_CP]
    sw = _check_active_sw()
    if sw == 'SBTS22R2':
        milestone_msgs.remove(UE_HO_TRIGGER)
        MolerTest.info('Detected active "{}" gNB SW. Pattern verification skipped: "{}"'.format(sw, UE_HO_TRIGGER))
    if check_grant:
        milestone_msgs.insert(0, UL_PROACTIVE_GRANT_DISABLED)
        MolerTest.info('Added verification of UL Proactive Grant to handover milestones.')
    for milestone in milestone_msgs:
        _find_pattern_in_syslog(milestone, syslog_path)


def verify_measurement_a3a5_in_syslog(syslog_path):
    _find_pattern_in_syslog(FREQ_A3A5_MSG, syslog_path)


def confirm_srb3(syslog_path, require_srb3):
    found_srb3_pattern = False
    if require_srb3:
        srb3_pattern = re.compile(SRB3_ACTIVE_MSG)
    else:
        srb3_pattern = re.compile(SRB3_INACTIVE_MSG)

    for line in _file_reader(syslog_path):
        if srb3_pattern.match(line):
            found_srb3_pattern = True
            MolerTest.info('SRB3 pattern found in syslog: "{}"'.format(line))
            break
    if not found_srb3_pattern:
        raise ValueError('Not found SRB3 pattern: "{}" in syslog: "{}"'.format(srb3_pattern, syslog_path))


def confirm_handover_succeeded(syslog_path):
    for pattern in [HO_SUCCEEDED_MSG, GNB_CHANGE_RESULT_MSG, GNB_CHANGE_CONFIRM_MSG]:
        _find_pattern_in_syslog(pattern, syslog_path)


@MolerTest.raise_background_exceptions()
def confirm_handover_failed(syslog_path):
    max_num_nrrel_pattern = re.compile(MAX_NUM_NRREL_MSG)
    start_pci_resolution_pattern = re.compile(START_PCI_RESOLUTION_MSG)
    max_num_nrrel = False
    for line in _file_reader(syslog_path):
        if max_num_nrrel_pattern.match(line):
            max_num_nrrel = True
            MolerTest.info('Found "Maximum number of NrRels reached" pattern in syslog: "{}"'.format(line))
        if start_pci_resolution_pattern.match(line):
            raise ValueError('Found "START PCI RESOLUTION" pattern in syslog: "{}"'.format(line))
    if not max_num_nrrel:
        raise ValueError('Not found required pattern: "{}" in syslog: "{}"'.format(max_num_nrrel_pattern, syslog_path))


@MolerTest.raise_background_exceptions()
def get_params_for_nrrel_object(nrradjnrcell_id):
    no_change_releases = ['SBTS22R2', 'SBTS22R3', 'SBTS22R4', 'SBTS23R1', 'SBTS23R2']
    sw_tag = _check_active_sw()
    parameter = [
        {"parameterName": "cellIndividualSsbRsrpOffset", "operation": "update", "value": "0dB"},
        {"parameterName": "cellIndividualSsbRsrqOffset", "operation": "update", "value": "0dB"},
        {"parameterName": "gNbId", "operation": "update", "value": "50832"},
        {"parameterName": "gNbIdLength", "operation": "update", "value": "22"},
        {"parameterName": "lcrId", "operation": "update", "value": "{}".format(nrradjnrcell_id[-1])},
        {"parameterName": "removeNotAllowed", "operation": "update", "value": "false"},
        {"parameterName": "handoverAllowedSA", "operation": "update", "value": "allowed"},
        {"parameterName": "gnbPlmn", "operation": "update", "value": [{"mcc": 540, "mnc": 1, "mncLength": 2}]}
    ]
    if sw_tag not in no_change_releases[:2]:
        nr_dc_allowed = {"parameterName": "nrDcAllowed", "operation": "update", "value": "false"}
        parameter.append(nr_dc_allowed)
        MolerTest.info('nrDcAllowed added to parameter list')
    if sw_tag not in no_change_releases[:4]:
        handover_red_cap = {"parameterName": "handoverAllowedSARedCap", "operation": "update", "value": "forbidden"}
        parameter.append(handover_red_cap)
        MolerTest.info('handoverAllowedSARedCap added to parameter list')
    if sw_tag not in no_change_releases:
        rpl_cell_for_ps_cell = {"parameterName": "isRplCellForPSCell", "operation": "update", "value": "false"}
        parameter.append(rpl_cell_for_ps_cell)
    return parameter


def get_params_for_nradjnrcell_object(nrradjnrcell_id):
    no_change_releases = ['SBTS22R2', 'SBTS22R3', 'SBTS22R4', 'SBTS23R1', 'SBTS23R2', 'SBTS23R3']
    sw_tag = _check_active_sw()
    parameter = [
        {"parameterName": "gNbId", "operation": "update", "value": "50832"},
        {"parameterName": "gNbIdLength", "operation": "update", "value": "22"},
        {"parameterName": "lcrId", "operation": "update", "value": "{}".format(nrradjnrcell_id[-1])},
        {"parameterName": "nrarfcn", "operation": "update", "value": "2058027"},
        {"parameterName": "physCellId", "operation": "update", "value": "6{}".format(nrradjnrcell_id[-1])},
        {"parameterName": "cellDepType", "operation": "update", "value": "NSA"},
        {"parameterName": "gnbPlmn", "operation": "update", "value": [{"mcc": 540, "mnc": 1, "mncLength": 2}]}
    ]
    if sw_tag not in no_change_releases:
        cell_reserved = {"parameterName": "cellReservedForOperatorUse", "operation": "update", "value": "notReserved"}
        parameter.append(cell_reserved)
    return parameter


def get_params_for_idletimefornrnbremoval():
    parameter = [
        {"parameterName": "idleTimeForNrNbRemoval", "operation": "update", "value": "2"},
    ]
    return parameter


def get_removal_fire_times(syslog_path, removal_auto):
    fires = []
    auto_remove_on_timer_pattern = "Timer rdNeighRemovalEvaluationTime fired, " \
                                   "creating AutomaticNeighbourRelationRemovalProcedure."
    auto_remove_off_timer_pattern = "Timer rdNeighRemovalEvaluationTime fired. " \
                                    "ActAutoNrNbRemoval was disabled in last cycle, " \
                                    "AutomaticNeighbourRelationRemovalProcedure skipped."
    timestamp_pattern = re.compile(r'\s(\d\d:\d\d:\d\d)\.\d+\s')

    if removal_auto:
        timer_pattern = auto_remove_on_timer_pattern
    else:
        timer_pattern = auto_remove_off_timer_pattern

    for line in _file_reader(syslog_path):
        if timer_pattern in line:
            match_timestamp = re.search(timestamp_pattern, line)
            fires.append(match_timestamp.group(1)) if match_timestamp else MolerTest.warning(
                'Timestamp pattern "{}" not found in syslog line "{}"'.format(timestamp_pattern, line))

    MolerTest.info("Timer rdNeighRemovalEvaluationTime fired message timestamps: '{}'".format(fires))
    return fires


def count_fires(syslog_path, auto_removal):
    return len(get_removal_fire_times(syslog_path, auto_removal))


def check_time_difference(syslog_path, auto_removal):
    fires = get_removal_fire_times(syslog_path, auto_removal)
    if len(fires) == 0:
        return False
    prev = datetime.strptime(fires[0], "%H:%M:%S")
    for fire in fires[1:]:
        fire = datetime.strptime(fire, "%H:%M:%S")
        assert (fire - prev).seconds == 3600  # 60 minutes
        prev = fire
    return True


def confirm_nrrel_removed(syslog_path):
    found_pattern = False
    nrrel_removal_pattern = re.compile(NRREL_REMOVAL_MSG, re.IGNORECASE)
    for line in _file_reader(syslog_path):
        if nrrel_removal_pattern.match(line):
            found_pattern = True
            MolerTest.info('Found NrRel Removal pattern in syslog: "{}"'.format(line))
            break
    if not found_pattern:
        raise ValueError('Not found NrRel Removal pattern: "{}" in syslog: "{}"'.format(nrrel_removal_pattern,
                                                                                        syslog_path))


def confirm_nradjnrcell_removed(syslog_path):
    found_pattern = False
    nradjnrcell_removal_pattern = re.compile(NRADJNRCELL_REMOVAL_MSG, re.IGNORECASE)
    for line in _file_reader(syslog_path):
        if nradjnrcell_removal_pattern.match(line):
            found_pattern = True
            MolerTest.info('Found NrRels and NrAdjNrCells Removal pattern in syslog: "{}"'.format(line))
            break
    if not found_pattern:
        raise ValueError('Not found NrRels and NrAdjNrCells Removal pattern: "{}"'
                         ' in syslog: "{}"'.format(nradjnrcell_removal_pattern, syslog_path))


@MolerTest.raise_background_exceptions()
def confirm_drx_setup_and_nrcgi_report(pcap, lua=None):
    msgs = {'SgNBModificationRequired': ['measConfigSN', 'reportType: reportCGI'],
            'SgNBModificationRequest': ['measGapConfig: release (0)'],
            'SgNBModificationConfirm': ['RRCReconfigurationComplete'],
            'UEContextModificationRequest': ['measGapConfig: release (0)', 'Item 2: id-DRXCycle',
                                             'RRCReconfigurationCompleteIndicator'],
            'UEContextModificationResponse': ['cellGroupId', 'mac-CellGroupConfig'],
            'SgNBModificationRequestAcknowledge': ['measConfig']}
    with LogHelper() as lh:
        finder = lh.add_pcap(
            pcap_file_path=pcap, lua=lua, shark_filter='',
            ts_output_data_file_path=None, clean_up_tmp_file=False
        )
        for msg_type in msgs.keys():
            storage = finder.find_all([Matcher(msg_type, name_line_pattern='empty')], output='tag_list')
            for pattern in msgs[msg_type]:
                found = [msg for msg in storage if repr(msg).find(pattern) != -1]
                if found:
                    MolerTest.info('Found "{}" messages containing pattern "{}"\n'
                                   '"{}"'.format(msg_type, pattern, [found[0] if len(found) > 1 else found]))
                else:
                    MolerTest.error('Not found pattern "{}" among captured "{}" messages in pcap file "{}"'
                                    ''.format(pattern, msg_type, pcap), raise_exception=True)


def _extract_counter_data(counter_ids, counters_values):
    counter_storage = list()
    for counter_id in counter_ids:
        counter_dict = dict()
        counter_dict["id"] = counter_id
        time_stamps = list(counters_values[counter_id].keys())
        time_stamps.sort()
        recent_timestamp = time_stamps[-1]  # Handover interval
        counter_dict["interval"] = recent_timestamp
        recent_value = int(counters_values[counter_id][recent_timestamp])
        if recent_value > 0:
            counter_dict["value"] = recent_value
        else:
            MolerTest.error("NR CGI Report counter '{}' value verification failed. Counter value within Handover "
                            "interval '{}' should be greater than 0. {}".format(counter_id, recent_timestamp,
                                                                                counters_values[counter_id]),
                            raise_exception=True)
        counter_storage.append(counter_dict)
    return counter_storage


def count_nrcgi_reports_received_in_syslog(syslog_path):
    nrcgi_pattern = re.compile(
        r'Received\s\w+NrcgiReport\swith\sMeasId:\s\d+\n.*NrcgiReportValidator.cpp:\d+\sChecking\splmn\s:'
        r'\sPlmnIdentity\(MCC:\s\d+,\sMNC:\s\d+\),\sis\sit\snew\?\s=\strue', re.DOTALL)
    with open(syslog_path, 'r') as f:
        syslog = f.read()
        found_nrcgi = re.findall(nrcgi_pattern, syslog)
    if found_nrcgi:
        MolerTest.info("NR CGI Reports Received found in syslog: {}".format(found_nrcgi))
        return len(found_nrcgi)
    else:
        MolerTest.error("Not found Received NR CGI Reports during HO in syslog: '{}'".format(syslog_path),
                        raise_exception=True)


def verify_nrcgi_report_received_counter(syslog_path, nrcgi_received_data):
    reports_from_counter = nrcgi_received_data["value"]
    reports_from_syslog = count_nrcgi_reports_received_in_syslog(syslog_path)
    if int(reports_from_counter) == int(reports_from_syslog):
        MolerTest.info("Success. '{}' NR CGI Report Received counter value: '{}' is equal to number of reports from"
                       " syslog: '{}'. Syslog path: '{}'".format(nrcgi_received_data["id"], reports_from_counter,
                                                                 reports_from_syslog, syslog_path))
    else:
        MolerTest.error(
            "Verification failed. '{}' NR CGI Report Received counter value: '{}' is not equal to number of reports "
            "from syslog: '{}'. Syslog path: '{}'".format(nrcgi_received_data["id"], reports_from_counter,
                                                          reports_from_syslog, syslog_path), raise_exception=True)


def get_nr_cgi_report_counters(max_counter_attempts, counter_ids, bts_id, du_id):
    gnb_pm_counters = GnbPmCounter()
    gnb_pm_counters.wait_for_next_pm_period(interval="15min", delay=90)
    serving_cell_counters = None

    for _ in range(max_counter_attempts):
        try:
            all_counters = gnb_pm_counters.get_counter(f"{counter_ids[0]},{counter_ids[1]}")
            serving_cell_counters = PmCounterOutputGetter(pm_counter_output=all_counters).get_cell_counters(
                cell_id=get_builtin_value("GNB_CELL_ID"), cell_type='NR', bts_id=bts_id, du_id=du_id)["NRRCC"]
            return serving_cell_counters
        except AdminApiProcedureTimeoutException:
            MolerTest.warning(f"AdminApiProcedureTimeoutException in attempt of get '{counter_ids}' counters")

    if not serving_cell_counters:
        raise ValueError(f"Failed to retrieve serving cell counters after {max_counter_attempts} attempts")


@MolerTest.raise_background_exceptions()
def verify_nr_cgi_report_counters(syslog_path, max_counter_attempts=3, bts_id=0, du_id=0):
    counter_ids = ["M55124C05001", "M55124C05002"]
    counters_values = get_nr_cgi_report_counters(max_counter_attempts, counter_ids, bts_id, du_id)
    MolerTest.info("Observed '{}' counter values for serving cell: '{}'".format(counter_ids, counters_values))
    counter_storage = _extract_counter_data(counter_ids, counters_values)
    nrcgi_cfg_sent = counter_storage[0]
    nrcgi_received = counter_storage[1]
    if nrcgi_cfg_sent["interval"] == nrcgi_received["interval"]:
        MolerTest.info("Analyzed NR CGI Report counters '{}' come from same interval '{}'".format(
            counter_ids, nrcgi_cfg_sent["interval"]))
        verify_nrcgi_report_received_counter(syslog_path=syslog_path, nrcgi_received_data=nrcgi_received)
        if nrcgi_cfg_sent["value"] >= nrcgi_received["value"]:
            MolerTest.info("Verification passed. M55124C05001 NR CGI Report Config Sent counter value: '{}' "
                           "is greater than or equal to M55124C05002 NR CGI Report Received counter value: '{}'"
                           " in Handover interval".format(nrcgi_cfg_sent["value"], nrcgi_received["value"]))
        else:
            MolerTest.error("Verification failed. M55124C05001 NR CGI Report Config Sent counter value: '{}' is lower "
                            "than M55124C05002 NR CGI Report Received counter value: '{}' in Handover interval '{}'"
                            "".format(nrcgi_cfg_sent["value"], nrcgi_received["value"], counter_storage),
                            raise_exception=True)
    else:
        MolerTest.error("Interval verification failed. Handover interval identifier should be the same for both "
                        "NR CGI Report counters '{}'".format(counter_storage), raise_exception=True)


def set_max_number_allowed_neighbour_relations(max_relations="20000", bts_id=0, du_id=0, timeout=180):
    GnbCommissioning().perform_parameter_recommissioning(dist_name="MRBTS-{}/NRBTS-{}",
                                                         parameter="maxNumNrAnrMoiAllowed", operation="update",
                                                         value=max_relations, bts_id=bts_id, du_id=du_id,
                                                         timeout=timeout)

from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.syslog_verify import *
from ute_syslog.exception import ParsingFailed
from datetime import datetime
from time import time
from suite_specific_keywords import get_test_prefix


def _handle_verify_syslog_for_number_of_msg(regex, number_of_messages):
    number_of_messages = int(number_of_messages)
    if number_of_messages == 1:
        verify_syslog(regex)
    else:
        verify_syslog_for_given_number_of_msg(regex_to_match=regex, number_of_messages=number_of_messages)


def verify_syslog_ANR_and_NRCGI_report_status_true():
    release = BuiltIn().get_variable_value("${RELEASE}")
    if release == "SBTS22R1" or release == "SBTS22R2":
        regex_string = r'ConcreteAnrPrecondition.*SA ANR enabled:false, UE NRCGI report supported:true'
    else:
        regex_string = r'ConcreteAnrPrecondition.*SA NR ANR enabled:\s*false, UE NRCGI report supported:\s*true'
    verify_syslog(regex_string)


def verify_syslog_NRRELs_max_allowed():
    release = BuiltIn().get_variable_value("${RELEASE}")
    if release == "SBTS22R1" or release == "SBTS22R2":
        verify_syslog(r'ConcreteAnrPrecondition.cpp.*NrRels size:1, max allowed:1')
    else:
        verify_syslog(r'ConcreteAnrPrecondition.cpp.*NRRELs and NRRELEs: 1, max allowed: 1')


def verify_syslog_ANR_and_NRCGI_report_status_false():
    verify_syslog(r'ConcreteAnrPrecondition.cpp.*SA ANR enabled:true, UE NRCGI report supported:false')


def verify_syslog_no_pci_candidate_found():
    release = BuiltIn().get_variable_value("${RELEASE}")
    if release == "SBTS22R1" or release == "SBTS22R2":
        regex_string = r'ConcreteAnrPciSelector.cpp.*Could not select pci: No candidate found'
    else:
        regex_string = r'ConcreteAnrPciSelector.*No candidate found'
    verify_syslog(regex_string)


def verify_syslog_anr_preconditions_not_met():
    release = BuiltIn().get_variable_value("${RELEASE}")
    if release == "SBTS22R1" or release == "SBTS22R2":
        regex_string = r'ConcreteAnrPciSelector.cpp.*Could not select pci: Anr preconditions not met'
    else:
        regex_string = r'ConcreteAnrPciSelector.*NR ANR preconditions not met'
    verify_syslog(regex_string)


def verify_syslog_RRCReconfigurationComplete_timeout():
    pattern = ("Response.*<messages::nr_rrc::RRCReconfigurationComplete, "
               "messages::nr_rrc::ProtocolError> has not been received in time")
    verify_syslog(pattern)


def verify_syslog_active_procedure_set_to_rrcReestablishment():
    verify_syslog(r'ActiveProcedure set to rrcReestablishment')


def verify_syslog_NRCGI_measurement_report_timeout(pci="51"):
    verify_syslog(r'NRCGI measurement report timeout for.*PhyCellId.*{}.*'.format(pci))


def verify_syslog_unable_to_fetch_valid_nrcgi_report():
    verify_syslog(r'NrcgiMeasHandlerSA.cpp.*Unable to fetch any valid nrcgi report')


def verify_syslog_for_error_in_measurement_report():
    verify_syslog(r'No valid MeasResultNr found in MeasurementReport')


def verify_syslog_ANR_PCI_resolution_success_for_PCI(number_of_messages=1, pci="51"):
    release = BuiltIn().get_variable_value("${RELEASE}")
    if release == "SBTS22R3":
        regex = r'PCI resolution finished with success (for|and) PhyCellId.*{}'.format(pci)
    else:
        # since FB2319 status: 0 == Completed
        regex = r'PCI resolution procedure for PCI PhyCellId.*{}.*finished.*status.*(0|ok)'.format(pci)
    _handle_verify_syslog_for_number_of_msg(regex, number_of_messages)


def verify_syslog_stopping_PCI_resolution_for_PCI(number_of_messages=1, pci="51"):
    regex = r'Stopping PCI resolution procedure for PhyCellId.*{}.*, ueIdCu'.format(pci)
    _handle_verify_syslog_for_number_of_msg(regex, number_of_messages)


def verify_syslog_ho_to_cell_51_failed_because_of_mrl_restricted():
    verify_syslog(r'HoTriggeringListener.*Could not trigger HO for PhyCellId:.*51.*reason.*NRCGI.*is MRL restricted')


def verify_syslog_ho_completed(number_of_messages=1):
    regex = r'Indicate procedure done, procedure: intraGnbHandover, transactionId.*status: Completed'
    _handle_verify_syslog_for_number_of_msg(regex, number_of_messages)


def verify_syslog_pci_identified(number_of_messages=1):
    release = BuiltIn().get_variable_value("${RELEASE}")
    if release == "SBTS22R1" or release == "SBTS22R2":
        regex = r'Received NeighbourStatusUpdateInd with status pciIdentified'
    else:
        regex = r'with.*status.*pciIdentified.*Received NeighbourStatusUpdateInd'
    _handle_verify_syslog_for_number_of_msg(regex, number_of_messages)


def verify_syslog_pci_confirmed(number_of_messages=1):
    release = BuiltIn().get_variable_value("${RELEASE}")
    if release == "SBTS22R1" or release == "SBTS22R2":
        regex = r'Received NeighbourStatusUpdateInd with status pciConfirmed'
    else:
        regex = r'with.*status.*pciConfirmed.*Received NeighbourStatusUpdateInd'
    _handle_verify_syslog_for_number_of_msg(regex, number_of_messages)


def verify_syslog_ho_succeeded(number_of_messages=1):
    release = BuiltIn().get_variable_value("${RELEASE}")
    if release == "SBTS22R1" or release == "SBTS22R2":
        regex = r'Received NeighbourStatusUpdateInd with status hoSucceeded'
    else:
        regex = r'with.*status.*hoSucceeded.*Received NeighbourStatusUpdateInd'
    _handle_verify_syslog_for_number_of_msg(regex, number_of_messages)


def verify_syslog_ho_failed(number_of_messages=1):
    release = BuiltIn().get_variable_value("${RELEASE}")
    if release == "SBTS22R1" or release == "SBTS22R2":
        regex = r'Received NeighbourStatusUpdateInd with status hoFailed'
    else:
        regex = r'with.*status.*hoFailed.*Received NeighbourStatusUpdateInd'
    _handle_verify_syslog_for_number_of_msg(regex, number_of_messages)


def verify_syslog_no_neighbour_cell_allowed(number_of_messages=1):
    regex = r'No NeighbourCell is allowed by HRL or MRL/PLMN based filtering rule'
    _handle_verify_syslog_for_number_of_msg(regex, number_of_messages)


def verify_syslog_pci_status_set_to_recheck():
    verify_syslog(r'HoFailedCounter reached the threshold. PCI status set to recheck')


def verify_syslog_replacing_pci_51_with_60():
    verify_syslog(r'Replacing PhyCellId.*51.*with PhyCellId.*60.*for ueIdCu')


def verify_syslog_starting_pci_resolution_for_pci_60():
    verify_syslog(r'Starting PCI resolution procedure for PhyCellId: <LOG_SCRAM_11>60</LOG_SCRAM_11>, ueIdCu')


def verify_syslog_ignoring_new_pci_resolution():
    verify_syslog(r'Ignoring new PCI resolution req for PhyCellId.*51.*and ueIdCu.*previous '
                  'PhyCellId.*51.*processing continues')


def verify_syslog_no_print_for_pci_status_set_to_recheck():
    verify_if_no_such_message_in_syslog_occurred(r'HoFailedCounter reached the threshold. PCI status set to recheck')


def verify_syslog_object_creation_failed_reason_gnbIdLength():
    verify_syslog(r'Anr object creation failed, reason: Could not obtain gnbIdLength for NRCGI{NRCellIdentity: 2051')


def verify_syslog_no_free_ids_for_provided_prefix_available():
    verify_syslog(r'No free IDs for provided prefix available - \'MRBTS-1/NRBTS-1/NRADJNRCELL-\'')


def verify_syslog_no_valid_TAC_found_in_cgi_info():
    # verify_syslog(r'PlmnIdentityInfo [[:digit:]]+ did not contain TAC')
    release = BuiltIn().get_variable_value("${RELEASE}")
    if release == "SBTS22R1" or release == "SBTS22R2":
        verify_syslog(r'Unable to process NrcgiReport for ueIdCu:[[:digit:]]+, '
                      'reason: Unable to obtain TAC from first PlmnIdentityInfo')
    else:
        verify_syslog(r'Unable to process NRCGI Report, reason: Unable to obtain TAC from PlmnIdentityInfo')


def verify_syslog_aborting_ho_triggering():
    verify_syslog(r'Selected target NRCellIdentity: .* has status 1 - aborting HO triggering')


def verify_syslog_duplicated_PLMN_found_in_SA_mode():
    release = BuiltIn().get_variable_value("${RELEASE}")
    if release == "SBTS22R1" or release == "SBTS22R2":
        verify_syslog(r'Unable to process NrcgiReport for ueIdCu:.*, reason: '
                      'Plmn duplication detected in cgiInfo for PlmnIdentity')
    else:
        verify_syslog(r'Unable to process NrcgiReport, reason: '
                      'Plmn duplication detected in cgiInfo for PlmnIdentity')


def verify_syslog_for_timer_rdNeighRemovalEvaluationTime_fired(number_of_messages=1):
    regex = r'Timer rdNeighRemovalEvaluationTime fired'
    _handle_verify_syslog_for_number_of_msg(regex, number_of_messages)


def establish_baseline_for_periodic_removal_cycle():
    test_prefix = get_test_prefix()
    ta5g_syslog = BuiltIn().get_library_instance('ta5g_syslog')
    timer_regexp = r'Timer rdNeighRemovalEvaluationTime fired'
    try:
        ta5g_syslog.wait_for_specified_message_in_syslog(
            msg_regexp=timer_regexp,
            timeout=BuiltIn().get_variable_value("${PERIODIC_REMOVAL_CYCLE_DURATION}") * 60,
            alias=BuiltIn().get_variable_value("${SYSLOG_ALIAS}")
        )
    except ParsingFailed:
        if test_prefix == "1085_C_001":
            logger.warn("Cannot find print [{}]. Flag actSaUeBasedAnrNr might be off. "
                        "For 1085-C TC001 this is expected."
                        .format(timer_regexp))
        else:
            raise
    start_of_cycle = time()
    logger.info("Periodic removal cycle starts at {}".format(datetime.fromtimestamp(int(start_of_cycle))),
                also_console=True)
    return start_of_cycle


def verify_syslog_PCI_duplicate_detection():
    verify_syslog(r'The number of duplicated PCIs is: 2. measResultNR.physCellId = PhyCellId:.*'
                  r'<LOG_SCRAM_11>401</LOG_SCRAM_11>')


def verify_inter_gNB_HO():
    verify_syslog(r'Inter gNB handover completed with status Completed')


def verify_PCI_identified_with_specific_NRCI(source_nrci="16385", target_nrci="4097"):
    verify_syslog(r'\[Update for inter-GNB relation from source cell:{} '
                  r'to target cell:{} with PhyCellId:<LOG_SCRAM_11>401</LOG_SCRAM_11> with'
                  r' ssbFrequency: 636576 with new status: pciIdentified\] Creating new relation.'
                  .format(source_nrci, target_nrci))

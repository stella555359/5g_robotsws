"""
Keywords related to CB008490 verification

:copyright:     Nokia Networks
:author:        Piotr Brzezicki
:maintainer:    Piotr Brzezicki
:contact:       piotr.brzezicki@nokia.com
:team:          VRF_KRK_T06
"""
import logging
import time
from datetime import datetime
from typing import Tuple, Dict

from taf.rfrl.bts.alarms.classical_alarms_definition import CLASSICAL_FAULT_7311
from taf.rfrl.bts.devices.du.alarm_verification import GnbAlarmVerification
from taf.rfrl.bts.devices.du.cell_operations import GnbCellOperations
from taf.rfrl.bts.devices.du.commissioning import GnbCommissioning
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from taf.rfrl.bts.devices.du.logs_collecting.basic_logs import GnbLog
from taf.rfrl.utilities.general import wait_till_succeeds
from taf.rfrl.utilities.logger import custom_logger as logger
from taf.rfrl.utilities.parsers.pcap_checker import VerificationError
from taf.rfrl.utilities.robot.decorators import log_as_robot_keyword
from taf.rfrl.utilities.robot.general import (get_builtin_value, import_resource_to_robot_framework_namespace,
                                              set_robot_test_variable)
from taf.rfrl.procedures.resources.python.scout.exceptions import ReportCalculationNotFinished
from taf.rfrl.procedures.resources.python.scout.scout_comparator.ScoutComparator import ScoutComparator

from .commissioning import (commission_deltas, check_bts_for_list_parameter_value_and_configure_if_needed,
                            check_bts_for_parameter_value_and_configure_if_needed, perform_bts_delta_commissioning)
from .common import RfAttenuator, Misc, run_and_warn_on_exception
from .variables.delta import (MRBTS_NRBTS_SCELL4, MRBTS_NRBTS_SCELL5, MRBTS_NRBTS_SCELL6, MRBTS_NRBTS_SCELL7,
                              DD_200_INACTIVITY_TIMERS_MN, DD_200_INACTIVITY_TIMERS_SN,
                              DD_200_NRHOIF_A4_THRESHOLD, DD_200_FR2_CELL_LOW_POWER, DD_200_FR2_CELL_NORMAL_POWER,
                              MN_DD_200_ROLLBACK, SN_DD_200_ROLLBACK,
                              DISABLE_UE_BEAM_FAILURE_RECOVERY_FALSE, DISABLE_UE_BEAM_FAILURE_RECOVERY_TRUE,
                              DISABLE_UE_BEAM_FAILURE_RECOVERY_DEL, ACT_RRC_RECONFIG_AT_BEAM_SWITCH_TRUE,
                              ACT_RRC_RECONFIG_AT_BEAM_SWITCH_FALSE)
from .bts_logs import start_utf_logs_collection, stop_utf_logs_collection, collect_snapshots_in_parallel
from .pcap.collecting import gather_pcap_from
from .pcap.verifier import (verify_native_nrcell_band, verify_sn_initiated_partial_reset,
                            verify_nrdc_release_and_reestablishment, verify_sn_terminated_pdu_session_release)
from .pm_counters import wait_for_next_pm_counters_interval
from .ue import (stop_dl_tcp_data_transfer_for_ue, attach_nrdc_ue, wait_a_moment_for_nrdc_call_establishment,
                 start_and_verify_dl_and_ul_data_transfer, detach_nrdc_ue,
                 trigger_sn_terminated_offloaded_pdu_session_release)
from .variables.common import RUN_COMMON_STEPS, NUM_BTS_DEVICES, T09SK030_RU_DATA

import_resource_to_robot_framework_namespace('taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot')


@log_as_robot_keyword
def wait_for_btses_to_be_onair() -> None:
    """
    Waits until both BTSes are reachable and all their cells are on air.

    :return: None
    """
    du_oper = GnbDuOperations()
    for bts_id in range(NUM_BTS_DEVICES):
        du_oper.wait_unitl_connection_via_admin_is_possible(bts_id=bts_id, timeout=600)
    logger.log_info_to_console('Wait for GNB0 and GNB1 to be on air')
    for bts_id in range(NUM_BTS_DEVICES):
        Misc().wait_for_all_cells_to_be_onair(bts_id=bts_id, timeout=600)


@log_as_robot_keyword
def verify_that_as_encryption_is_disabled_on_gnb(bts_id: int = 0) -> None:
    """Verifies that AS (Access Stratum) encryption is disabled on a gNB.

    This function checks the cipherPrefL parameters to ensure that nea0 (Null Encryption Algorithm)
    is enabled, and other encryption algorithms (nea1_128, nea2_128, nea3_128) are disabled,
    which is necessary for RRC message verification in PCAP.

    :param bts_id: The ID of the BTS (Base Transceiver Station) to check. Defaults to 0.
    """
    try:
        result = GnbCommissioning().get_parameters_by_dist_name(dist_name="MRBTS-{}/NRBTS-{}",
                                                                parameter_list=['cipherPrefL'],
                                                                bts_id=bts_id)
        logging.info(f'Get parameters results: {result}')
        nea = result['parameters']['cipherPrefL'][0]
        assert nea.get('nea0', 0) > 0, "nea0 (Null Encryption Algorithm) should be enabled (value > 0)."
        assert nea.get('nea1_128', 0) == 0, "nea1_128 should be disabled (value 0)."
        assert nea.get('nea2_128', 0) == 0, "nea2_128 should be disabled (value 0)."
        assert nea.get('nea3_128', 0) == 0, "nea3_128 should be disabled (value 0)."
        logger.log_info_to_console(f'AS Encryption disabled on bts_id={bts_id} -> '
                                   f'NR-RRC msgs verification is possible in PCAP')
    except AssertionError as e:
        logger.log_warn_to_console(f'AS Encryption checking failed with {e} exception')
    except Exception as e:
        logger.log_warn_to_console(f'Exception {e} occurred when checking if AS encryption is disabled')


@log_as_robot_keyword
def verify_that_as_encryption_is_disabled_to_allow_rrc_messages_verification() -> None:
    """Ensures that AS encryption is disabled on the gNB to facilitate RRC message verification.
    """
    verify_that_as_encryption_is_disabled_on_gnb(bts_id=0)
    verify_that_as_encryption_is_disabled_on_gnb(bts_id=1)


@log_as_robot_keyword
def enable_data_split_to_mn_if_needed() -> None:
    """
    Enables NRDC data split on SN gNB by setting:
    - NRDRB.nrDcDrbParam.dlDataSplitBufBldUpThreshNrDc = 0
    - NRDRB.nrDcDrbParam.dlNumOfCongOrGainDddsNrDc = 1
    """
    dist_name = "MRBTS-{}/NRBTS-{}/NRDRB-2"
    param = 'nrDcDrbParam'
    list_params = ['dlDataSplitBufBldUpThreshNrDc', 'dlNumOfCongOrGainDddsNrDc']
    expected_values = [0, 1]

    check_bts_for_list_parameter_value_and_configure_if_needed(dist_name=dist_name,
                                                               param=param,
                                                               list_params=list_params,
                                                               expected_values=expected_values,
                                                               bts_id=1)


@log_as_robot_keyword
def configure_as_encryption_on_mn_and_sn_gnbs(enable: bool = True) -> None:
    """
    Configures AS encryption on both MN and SN gNBs.
    When enable=True sets nea0 + nea1_128 + nea2_128 + nea3_128.
    When enable=False disables nea1_128, nea2_128, nea3_128 (nea0 kept enabled).
    """
    dist_name = "MRBTS-{}/NRBTS-{}"
    param = 'cipherPrefL'
    list_params = ['nea0', 'nea1_128', 'nea2_128', 'nea3_128']
    expected_values = [1, 3, 4, 2] if enable else [1, 0, 0, 0]

    for bts_id in range(NUM_BTS_DEVICES):
        check_bts_for_list_parameter_value_and_configure_if_needed(dist_name=dist_name,
                                                                   param=param,
                                                                   list_params=list_params,
                                                                   expected_values=expected_values,
                                                                   bts_id=bts_id)


@log_as_robot_keyword
def enable_zero_pm_counters_suppression() -> None:
    """
    Enables Zero PM Counters Suppression by setting
      PMMNL.actZeroCounterSuppression = ['NR PMQAP sum Counters', 'NR non-PMQAP sum Counters'] on MN gNB
      PMMNL.actZeroCounterSuppression = ['NR non-PMQAP sum Counters'] on SN gNB
    This allows better KPIs Comparison on Scout
    """
    dist_name = "MRBTS-{}/MNL-1/MNLENT-1/PMMNL-1"
    param = 'actZeroCounterSuppression'
    mn_expected_value = ['NR PMQAP sum Counters', 'NR non-PMQAP sum Counters']
    sn_expected_value = ['NR non-PMQAP sum Counters']
    check_bts_for_parameter_value_and_configure_if_needed(dist_name=dist_name, parameter_name=param,
                                                          expected_value=mn_expected_value, bts_id=0)
    check_bts_for_parameter_value_and_configure_if_needed(dist_name=dist_name, parameter_name=param,
                                                          expected_value=sn_expected_value, bts_id=1)


@log_as_robot_keyword
def generate_and_verify_scout_nrdc_report(
        scout_mn_bts_name: str,
        scout_sn_bts_name: str,
        mn_template_id: str,
        sn_template_id: str,
        reference_start_time: datetime,
        reference_end_time: datetime,
        current_start_time: datetime,
        current_end_time: datetime,
        first_period_description: str,
        second_period_description: str,
        alpha: str
) -> None:
    """
    Generates Scout Compare Reports for MN and SN gNBs and validates them

    :param scout_mn_bts_name:
    :param scout_sn_bts_name:
    :param mn_template_id:
    :param sn_template_id:
    :param reference_start_time:
    :param reference_end_time:
    :param current_start_time:
    :param current_end_time:
    :param first_period_description:
    :param second_period_description:
    :param alpha:
    :return: None
    """
    scout_comparator = ScoutComparator()
    mn_report_id = scout_comparator.trigger_report_generation(scout_tl_name=scout_mn_bts_name,
                                                              template_id=mn_template_id,
                                                              reference_start_time=reference_start_time,
                                                              reference_end_time=reference_end_time,
                                                              current_start_time=current_start_time,
                                                              current_end_time=current_end_time,
                                                              first_period_description=first_period_description,
                                                              second_period_description=second_period_description,
                                                              alpha=alpha)

    sn_report_id = scout_comparator.trigger_report_generation(scout_tl_name=scout_sn_bts_name,
                                                              template_id=sn_template_id,
                                                              reference_start_time=reference_start_time,
                                                              reference_end_time=reference_end_time,
                                                              current_start_time=current_start_time,
                                                              current_end_time=current_end_time,
                                                              first_period_description=first_period_description,
                                                              second_period_description=second_period_description,
                                                              alpha=alpha)

    for report_id in [mn_report_id, sn_report_id]:
        wait_params = {
            'func': scout_comparator.validate_report,
            'exception_to_catch': ReportCalculationNotFinished,
            'interval': 30,
            'timeout': 300,
            'report_id': report_id
        }
        wait_till_succeeds(**wait_params)


@log_as_robot_keyword
def verify_nrcell_bands(cell_id: int, native_band: str, alternative_band: str | None = None) -> None:
    """KW verifies NR Cell configured bands

    :param cell_id: Cell identified by NRCELL.nrCellId
    :param native_band: band number e.g. '78' to be compared with NRCELL.freqBandIndicatorNR
    :param alternative_band: band number e.g. '77' (optional) which presence will be checked in
                             NRCELL.nrConnectModeProfileDN -> NRCONNECTMODE_PROFILE.multiFreqBandIndicatorNR
    """
    cell_params = GnbCellOperations().get_cell_parameters(cell_id=cell_id)
    logging.debug(f'NRCELL-{cell_id} parameters: {cell_params}')

    verify_native_nrcell_band(cell_params, native_band)

    if alternative_band:
        verify_alternative_nrcell_band(cell_params, alternative_band)


@log_as_robot_keyword
def verify_alternative_nrcell_band(cell_params: Dict, alternative_band: str) -> None:
    """KW verifies NR Cell configured bands

    :param cell_params: cell parameters dictionary
    :param alternative_band: band number e.g. '77' (optional) which presence will be checked in
                             NRCELL.nrConnectModeProfileDN -> NRCONNECTMODE_PROFILE.multiFreqBandIndicatorNR
    """
    cell_nrconnectmodeprofiledn = cell_params['nrConnectModeProfileDN']

    cell_oper = GnbCellOperations()
    dist_name = cell_oper.adjust_dist_name("MRBTS-{}/NRBTS-{}", bts_id=0, du_id=0)
    dist_name = f'{dist_name}/{cell_nrconnectmodeprofiledn}'
    logging.debug(f'Trying to get params for object: {dist_name}')
    profile_params = cell_oper.admin.get_parameter_by_distname(dist_name=dist_name,
                                                               connection=cell_oper.rest_alias.format(0, 0))
    logging.debug(f'{dist_name} parameters: {profile_params}')
    alt_bands = profile_params[0]['parameters']['multiFreqBandIndicatorNR']

    msg = f'Expecting that \'{alternative_band}\' band is present in ' \
          f'{dist_name}.multiFreqBandIndicatorNR = {alt_bands}'
    logging.debug(msg)
    if int(alternative_band) not in alt_bands:
        raise VerificationError(msg)


@log_as_robot_keyword
def nrdc_kpi_scenario_with_pm_intervals() -> Tuple[datetime, datetime]:
    """
    NRDC related scenario for KPI gathering which is executed between PM intervals. KW returns PM intervals
    start and end time
    :return: PM interval start and end time
    """
    if RUN_COMMON_STEPS:
        start_utf_logs_collection()
    start_time = wait_for_next_pm_counters_interval(interval='5min', delay=0)
    end_time = start_time  # Initialize with a valid datetime value

    try:
        for i in range(1, 7):
            logger.log_banner_to_console(f'NRDC KPI Scenario loop {i}')
            nrdc_kpi_scenario()
            end_time = Misc().get_now_datetime()
            wait_for_next_pm_counters_interval(interval='5min', delay=0)
    finally:
        if RUN_COMMON_STEPS:
            stop_utf_logs_collection()
            collect_snapshots_in_parallel()

    return start_time, end_time


@log_as_robot_keyword
def configure_csirsnumberwithinreportperiod_set1_on_aeqp_cell(value: str = "1", bts_id: int = 0) -> None:
    """
    Configure NRCELL.periodicCsiAcquisition.csirsNumberWithinReportPeriod_Set1 = 1
    :param value: Value to configure csirsNumberWithinReportPeriod_Set1
    :param bts_id: BTS ID
    """
    gnb_alarm = GnbAlarmVerification()
    run_and_warn_on_exception(gnb_alarm.allow_alarm)(alarm=[CLASSICAL_FAULT_7311], bts_id=bts_id)

    delta = [
        {"distName": "MRBTS-{}/NRBTS-{}/NRCELL-20",
         "operation": "update",
         "parameters": [{"parameterName": "periodicCsiAcquisition",
                         "value": [{"csiReportPeriodicity": "slots320",
                                    "csirsNumberWithinReportPeriod_Set1": value,
                                    "csirsPower": "8",
                                    "maxCsirsNumber": "4",
                                    "scramblingIdStep": "3"}],
                         "operation": "update"}
                        ]
         }
    ]
    logger.log_info_to_console(f"[bts_id={bts_id}] Configuring csirsNumberWithinReportPeriod_Set1 = {value} "
                               f"on AEQP Cell")
    perform_bts_delta_commissioning(delta=delta, bts_id=bts_id, wait_onair=True)
    run_and_warn_on_exception(gnb_alarm.disallow_alarm)(alarm=[CLASSICAL_FAULT_7311], bts_id=bts_id)


@log_as_robot_keyword
def configure_actcdrx_for_aeqp_cell(value: str = "true", bts_id: int = 0) -> None:
    """
    Configure actCDrx for AEQP Cell

    :param value: Value to configure actcdrx
    :param bts_id: BTS ID
    """
    acttcpboostpug_value = "allUes" if value == "true" else "disabled"
    delta = [
        {"distName": "MRBTS-{}/NRBTS-{}/NRCELL-20",
         "operation": "update",
         "parameters": [{"parameterName": "actCDrx",
                         "value": value,
                         "operation": "update"},
                        {"parameterName": "actTcpBoostPug",
                         "value": acttcpboostpug_value,
                         "operation": "update"}
                        ]
         }
    ]
    logger.log_info_to_console(f"[bts_id={bts_id}] Configuring actCDrx = {value} on AEQP Cell")
    perform_bts_delta_commissioning(delta=delta, bts_id=bts_id, wait_onair=False)


@log_as_robot_keyword
def configure_4_sn_cells_with_ue_plmn(supported: bool = False) -> None:
    """
    Configure 4 SN cells with UE supported or not supported PLMN
    :param supported: bool to decide if UE supported or not PLMN to be configured
    """
    gnb_alarm = GnbAlarmVerification()
    run_and_warn_on_exception(gnb_alarm.allow_alarm)(alarm=[CLASSICAL_FAULT_7311], bts_id=0)

    logger.log_info_to_console(f"[bts_id=1] Configure 4 SN cells with UE supported={supported} PLMN")

    ue_supported_plmn = "NRPLMN-1"
    ue_supported_tracking_area = "TRACKINGAREA-0"

    ue_not_supported_plmn = "NRPLMN-2"
    ue_not_supported_tracking_area = "TRACKINGAREA-1"

    if supported:
        plmn = ue_supported_plmn
        tracking_area = ue_supported_tracking_area
    else:
        plmn = ue_not_supported_plmn
        tracking_area = ue_not_supported_tracking_area
    delta = [
        {"distName": f'{cell}/NRPLMNSET_SA-1',
         "operation": "update",
         "parameters": [{"parameterName": "nrPlmnDNList",
                         "value": [plmn],
                         "operation": "update"},
                        {"parameterName": "trackingAreaDN",
                         "value": tracking_area,
                         "operation": "update"}]} for cell in [MRBTS_NRBTS_SCELL4,
                                                               MRBTS_NRBTS_SCELL5,
                                                               MRBTS_NRBTS_SCELL6,
                                                               MRBTS_NRBTS_SCELL7]]
    perform_bts_delta_commissioning(delta=delta, bts_id=1, wait_onair=True)

    run_and_warn_on_exception(gnb_alarm.disallow_alarm)(alarm=[CLASSICAL_FAULT_7311], bts_id=0)


@log_as_robot_keyword
def fr2_cell_lock(scell_id: int = 67, bts_id: int = 1, wait: int = 1) -> None:
    """
    Performs FR2 Cell Lock on SN gNB (default cell_id=67, bts_id=1).

    :param scell_id: Cell ID to be locked.
    :param bts_id: BTS ID where the cell is located.
    :param wait: Time to wait after locking the cell.
    """
    logger.log_info_to_console("FR2 Cell Lock")
    set_robot_test_variable("scell_id", scell_id)
    GnbCellOperations().lock_cell(bts_id=bts_id, cell_id=scell_id)
    time.sleep(wait)


@log_as_robot_keyword
def fr2_cell_unlock(bts_id: int = 1) -> None:
    """
    Performs FR2 Cell Unlock on SN gNB (uses ${scell_id} variable).

    :param bts_id: BTS ID where the cell is located.
    """
    logger.log_info_to_console("FR2 Cell Unlock")
    scell_id = get_builtin_value("scell_id")
    GnbCellOperations().unlock_cell(bts_id=bts_id, cell_id=scell_id)


@log_as_robot_keyword
def eb_200_test_cleanup() -> None:
    """
    Performs EB_200 Test Cleanup: stops DL TCP data transfer for UE and unlocks FR2 cell.
    """
    logger.log_info_to_console("EB_200 Test Cleanup")
    try:
        stop_dl_tcp_data_transfer_for_ue()
        fr2_cell_unlock()
    except Exception as e:
        logger.log_warn_to_console(f'Exception {e} occurred during EB_200 Test Cleanup')


@log_as_robot_keyword
def trigger_and_verify_ng_partial_reset_by_fr2_cell_lock() -> None:
    """
    KW locks FR2 Cell on SN gNB (acting as SCell for NRDC UE) and checks in PCAP F1/E1/XN/NG Reset messages.
    """
    logger.log_info_to_console("Triggering and Verifying NG Partial Reset by FR2 Cell Lock")
    gather_pcap_from(file_name_part="FR2_cell_lock")(fr2_cell_lock)(wait=20)
    verify_sn_initiated_partial_reset()


@log_as_robot_keyword
def trigger_rlf_by_attenuate_pcell_for_short_period_of_time() -> None:
    """
    Performs attenuation and then de-attenuation of RU for a short period of time to trigger RLF.
    """
    logger.log_info_to_console("Trigger RLF By Attenuate PCell For Short Period Of Time")
    RfAttenuator().set_attenuation_for_ru(radio_type="AZQO", value="0dB")
    RfAttenuator().set_attenuation_for_ru(radio_type="AHEH", value="110dB")


@log_as_robot_keyword
def trigger_rlf_and_verify_nrdc_release_and_reestablishment() -> None:
    """
    Checks whether RRC Reestablishment due to RLF was successful on both MY and SN gNBs.
    """
    (gather_pcap_from(file_name_part="RRC_Reestablishment", wait_time=15)
     (trigger_rlf_by_attenuate_pcell_for_short_period_of_time)())
    logger.log_info_to_console("Check RRC reestablishment messages in the pcap files")
    verify_nrdc_release_and_reestablishment()


@log_as_robot_keyword
def configure_srb_and_drb_inactivity_timers_on_mn_and_sn() -> None:
    """
    KW performs delta commissioning and sets SRB and DRB Inactivity timers on both gNBs.
    """
    logger.log_info_to_console("Configure SRB and DRB Inactivity Timers On MN And SN")
    commission_deltas(deltas=[DD_200_INACTIVITY_TIMERS_MN, DD_200_INACTIVITY_TIMERS_SN], wait_onair=False)


@log_as_robot_keyword
def adjust_fr2_cell_power_and_a4_nrdc_threshold_that_a4_measurement_report_wont_be_reported() -> None:
    """
    KW performs delta commissioning to adjust FR2 Cell power and A4 NRDC Threshold that keep UE in cell without
    establishing NRDC.
    """
    logger.log_info_to_console(
        "Adjust FR2 Cell Power And A4 NRDC Threshold That A4 Measurement Report Won't Be Reported")
    commission_deltas(deltas=[DD_200_NRHOIF_A4_THRESHOLD, DD_200_FR2_CELL_LOW_POWER], wait_onair=False)


@log_as_robot_keyword
def adjust_fr2_cell_power_that_nrdc_a4_will_reported() -> None:
    """
    KW performs delta commissioning to adjust FR2 Cell power to be above NRDC A4 threshold.
    """
    logger.log_info_to_console("Adjust FR2 Cell Power That NRDC A4 Will Reported")
    GnbCommissioning().perform_bts_delta_commissioning(delta=DD_200_FR2_CELL_NORMAL_POWER, bts_id=1)


@log_as_robot_keyword
def rollback_dd_200_configuration() -> None:
    """
    KW performs delta commissioning which rollbacks parameter changes done in test case.
    """
    logger.log_info_to_console("Rollback DD_200 configuration")
    commission_deltas(deltas=[MN_DD_200_ROLLBACK, SN_DD_200_ROLLBACK], wait_onair=False)


@log_as_robot_keyword
def configure_disableuebeamfailurerecovery_on_sn_gnb_cells(action: str = "false") -> None:
    """
    Configures or deletes disableUeBeamFailureRecovery on SN gNB cells.
    :param action: "false" -> set to false, "true" -> set to true, "delete" -> remove parameter value.
    """
    delta_map = {
        "false": DISABLE_UE_BEAM_FAILURE_RECOVERY_FALSE,
        "true": DISABLE_UE_BEAM_FAILURE_RECOVERY_TRUE,
        "delete": DISABLE_UE_BEAM_FAILURE_RECOVERY_DEL
    }
    if action not in delta_map:
        logger.log_warn_to_console(f"Unsupported action '{action}' for disableUeBeamFailureRecovery"
                                   f" parameter. Supported actions are: {list(delta_map.keys())}")
        return
    msg_action = "Delete" if action == "delete" else f"Configure disableUeBeamFailureRecovery = {action}"
    logger.log_info_to_console(f"{msg_action} on SN gNB cells")
    perform_bts_delta_commissioning(delta=delta_map[action], bts_id=1, wait_onair=True)


@log_as_robot_keyword
def configure_actrrcreconfigatbeamswitch_on_sn_gnb_cells(value: str = "true") -> None:
    """
    KW performs delta commissioning setting actRrcReconfigAtBeamSwitch on SN gNB.
    :param value: Accepts bool or "true"/"false" (case-insensitive). When true sets actRrcReconfigAtBeamSwitch = true,
     else false.
    :return: None
    """
    val = value.strip().lower()
    if val not in ("true", "false"):
        logger.log_warn_to_console(f"Unsupported enabled value '{value}'. Expected 'true' or 'false'.")
        return

    delta = ACT_RRC_RECONFIG_AT_BEAM_SWITCH_TRUE if val == "true" else ACT_RRC_RECONFIG_AT_BEAM_SWITCH_FALSE
    logger.log_info_to_console(f"Configure actRrcReconfigAtBeamSwitch = {val} on SN gNB cells")
    perform_bts_delta_commissioning(delta=delta, bts_id=1, wait_onair=True)


@log_as_robot_keyword
def nrdc_kpi_scenario() -> None:
    """
    Execute NRDC KPI scenario across multiple RUs.

    :return: None
    """
    ru_data = RuData()
    wait_for_nrdc = 8

    ru_data.use_ru_cell_as_pcell('AEQP')
    attach_nrdc_ue()
    wait_a_moment_for_nrdc_call_establishment(wait_for_nrdc)
    start_and_verify_dl_and_ul_data_transfer()
    detach_nrdc_ue()

    ru_data.use_ru_cell_as_pcell('AZQO')
    attach_nrdc_ue()
    wait_a_moment_for_nrdc_call_establishment(wait_for_nrdc)
    start_and_verify_dl_and_ul_data_transfer()
    detach_nrdc_ue()

    ru_data.use_ru_cell_as_pcell('AHEH')
    attach_nrdc_ue()
    wait_a_moment_for_nrdc_call_establishment(wait_for_nrdc)
    start_and_verify_dl_and_ul_data_transfer(dl_tput='800 Mbits/sec', dl_streams='2',
                                             expected_dl_tput='1400 Mbits/sec')
    detach_nrdc_ue()

    ru_data.use_ru_cell_as_pcell('APHG')
    attach_nrdc_ue()
    wait_a_moment_for_nrdc_call_establishment(wait_for_nrdc)
    start_and_verify_dl_and_ul_data_transfer()
    detach_nrdc_ue()

    ru_data.use_ru_cell_as_pcell('AHPE')
    attach_nrdc_ue()
    wait_a_moment_for_nrdc_call_establishment(wait_for_nrdc)
    start_and_verify_dl_and_ul_data_transfer(dl_tput='800 Mbits/sec', dl_streams='2',
                                             expected_dl_tput='1400 Mbits/sec')
    detach_nrdc_ue()


@log_as_robot_keyword
def trigger_and_verify_sn_terminated_offloaded_pdu_session_release() -> None:
    """
    Trigger and verify SN-terminated offloaded PDU session release.

    :return: None
    """
    logger.log_info_to_console("Trigger SN Terminated (Offloaded) PDU Session Release")
    gather_pcap_from(file_name_part="PDU_release", wait_time=10)(trigger_sn_terminated_offloaded_pdu_session_release)()
    logger.log_info_to_console("Verify SN Terminated PDU Session Release")
    verify_sn_terminated_pdu_session_release()


@log_as_robot_keyword
def verify_ru_cell_is_configured_with_bands(ru_name: str,
                                            native_band: str,
                                            alternative_band: str) -> None:
    """
    KW verifies that AEQP Cell is configured with native n78 and alternative n77 band.
    :param ru_name: RU identifier (e.g. 'AEQP').
    :param native_band: Native band number (e.g. '78').
    :param alternative_band: Alternative band number (e.g. '77').
    :return: None
    """
    logger.log_info_to_console(f"Verifying that {ru_name} Cell is configured with native n{native_band} "
                               f"and alternative n{alternative_band} band")
    ru_name.upper()
    ru_data = RuData()
    ru_data.verify_if_ru_is_in_ru_data(ru_name)

    cell_id = ru_data.ru_data[ru_name]['nrCellId']
    verify_nrcell_bands(cell_id=cell_id, native_band=native_band, alternative_band=alternative_band)


@log_as_robot_keyword
def get_snapshot_if_suite_setup_failed(bts_id: int = 0) -> None:
    """
    Collects an additional snapshot from BTS if suite setup failed and common steps are not skipped.

    :return: None
    """
    suite_setup_passed = get_builtin_value("SUITE_SETUP_STATUS")
    logging.info(f"SUITE_SETUP_STATUS: {suite_setup_passed}")
    if not suite_setup_passed and RUN_COMMON_STEPS:
        logger.log_info_to_console(f"Suite Setup failed -> Additionally collecting Snapshot from bts_id={bts_id}")
        GnbLog().collect_snapshot(bts_id=bts_id, log_dir=get_builtin_value("LOG_PATH") + '/preparation')


class RuData:

    def __init__(self, ru_data=T09SK030_RU_DATA):
        self.ru_data = ru_data

    def verify_if_ru_is_in_ru_data(self, ru_name: str) -> None:
        if ru_name not in self.ru_data:
            raise KeyError(f'{ru_name} must be in {self.ru_data}')

    @log_as_robot_keyword
    def use_ru_cell_as_pcell(self, ru_name: str) -> None:
        """Set attenuation for selected RU so UE can camp on its cell and store used NRCellId as test variable."""
        ru_name = ru_name.upper()
        self.verify_if_ru_is_in_ru_data(ru_name)
        att = self.ru_data[ru_name]['start_attenuation']
        nrcellid = self.ru_data[ru_name]['nrCellIdentity']
        my_att = RfAttenuator()
        my_att.set_maximum_attenuation_for_all_attenuators()
        my_att.set_attenuation_for_ru(radio_type=ru_name, value=att)
        set_robot_test_variable("used_cell_nrcellidentity", nrcellid)
        logger.log_info_to_console(f'Using {ru_name} [{att}] cell (NRCellId: {nrcellid}) as PCell')

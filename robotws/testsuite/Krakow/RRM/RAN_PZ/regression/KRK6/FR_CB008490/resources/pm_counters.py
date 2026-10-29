"""
Keywords related to PM counters checking.

:copyright:     Nokia Networks
:author:        Piotr Brzezicki
:maintainer:    Piotr Brzezicki
:contact:       piotr.brzezicki@nokia.com
:team:          VRF_KRK_T06
"""
import logging
import os
from datetime import datetime
from typing import Optional

from ta5g_pm_counters import counters_checker, PmCountersFile
from taf.rfrl.bts.devices.du.pm_counters import GnbPmCounter
from taf.rfrl.utilities.logger import custom_logger as logger
from taf.rfrl.utilities.robot.decorators import log_as_robot_keyword
from taf.rfrl.utilities.robot.general import get_builtin_value, get_robot_builtin_instance_and_import_if_needed

from testsuite.Krakow.RRM.RAN_PZ.regression.KRK6.FR_CB008490.resources.common import Misc
from testsuite.Krakow.RRM.RAN_PZ.resources.pm_counter_du import PmCounterDu

get_robot_builtin_instance_and_import_if_needed(name=None, library_path='ute_fsmaccess')  # needed by ta5g_pm_counters

tl = get_builtin_value('tl')
PM_INTERVAL_S = '300'


@log_as_robot_keyword
def verify_that_8cc_ca_on_fr2_cells_were_activated_and_deactivated_by_checking_pm_counters() -> None:
    """
    KW checks below PM counters:
     - Number of NR-DC users with 8CC activated in PSCell in SN gNB
     - Number of CA activations/deactivations in SCell in SN gNB

    :return: None
    """
    logger.log_info_to_console('Verify that 8CC CA on FR2 cells were activated and deactivated by checking PM Counters')
    file_path_sn = get_latest_pm_counters_file(bts_id=1)
    moid = f'PLMN-PLMN/MRBTS-{tl.gnbs[1].instance_id}/NRBTS-{tl.gnbs[1].global_bts_id}/NRCELL-60'
    pscell_counters = ['M55308C00110', '1', 'M_NRDC_SN_DU_UE_ACT_SCELL_0_DL',
                       'M55308C00117', '1', 'M_NRDC_SN_DU_UE_ACT_SCELL_7_DL',
                       'M55316C00012', '>1', 'S_NRDC_SN_DU_UE_ACT_SCELL_0_DL',
                       'M55316C00012', '>10', 'S_NRDC_SN_DU_UE_ACT_SCELL_7_DL',
                       'M55316C02000', '>10', 'UE_PSCELL_ACT_SCELL_DL',
                       'M55316C03000', '>10', 'PSCELL_UE_0_ACT_SCELL_DL',
                       'M55316C03007', '>10', 'PSCELL_UE_7_ACT_SCELL_DL',
                       'M55118C00015', '>10', 'UE_PCELL_7_CONF_SCELL_DL_SA',
                       'M55118C00003', '1', 'RRC_RECONF_ADD7DLSCELL_ATT_SA',
                       'M55118C00006', '1', 'RRC_RECONF_ADD7DLSCELL_SUCC_SA',
                       'M55316C05000', '1', 'MAX_PSCELL_UE_0_ACT_SCELL_DL',
                       'M55316C05007', '1', 'MAX_PSCELL_UE_7_ACT_SCELL_DL',
                       'M55156C00029', '1', 'MAX_UE_PCELL_7_CONF_SCEL_DL_SA',
                       'M55138C03506', '1', 'GNB_SCELL_7_ADMI_REQ_SA',
                       'M55138C03509', '1', 'GNB_SCELL_7_ADMI_SUCC_SA',
                       'M55139C03005', '1', 'GNB_DU_SCELL_7_ADMI_REQ_SA',
                       'M55139C03008', '1', 'GNB_DU_SCELL_7_ADMI_SUCC_SA',
                       'M55118C00054', PM_INTERVAL_S, 'DEN_1_SEC_SAMPLE',
                       'M55118C01000', PM_INTERVAL_S, 'SAMPLES_UE_AMOUNTS',
                       'M55316C01002', PM_INTERVAL_S, 'SAMPLES_UL_UE_AMOUNTS',
                       'M55316C01003', PM_INTERVAL_S, 'SAMPLES_DL_UE_AMOUNTS']
    cc = counters_checker()
    cc.verify_last_counters_in_file(*pscell_counters, local_moid=moid, file_path=file_path_sn)

    scell_counters = [
        'M55316C00019', '>0', 'DL_NRDC_SN_DU_ACT_A_SCELL',
        'M55316C00013', '>0', 'DL_NRDC_SN_DU_ACT_S_SCELL',
        'M55316C00022', '>0', 'DL_NRDC_SN_DU_DACT_A_SCELL',
        'M55316C00016', '>0', 'DL_NRDC_SN_DU_DACT_S_SCELL',
        'M55316C00023', '>0', 'DL_NRDC_SN_DU_DACT_A_SCELL_BUF',
        'M55316C00024', '0', 'DL_NRDC_SN_DU_DACT_A_SCELL_RLQ',
        'M55316C00017', '>0', 'DL_NRDC_SN_DU_DACT_S_SCELL_BUF',
        'M55316C00018', '0', 'DL_NRDC_SN_DU_DACT_S_SCELL_RLQ',
        'M55316C09000', '>0', 'SCELL_ACTIVATIONS',
        'M55316C09001', '>0', 'SCELL_DEACT_BUFFER_STATUS',
        'M55316C09002', '0', 'SCELL_DEACT_CHANNEL_STATE',
        'M55118C00020', '>10', 'UE_SCELL_7_CONF_SCELL_DL_SA',
        'M55316C02000', '>10', 'UE_PSCELL_ACT_SCELL_DL',
        'M55118C00054', PM_INTERVAL_S, 'DEN_1_SEC_SAMPLE',
        'M55118C01000', PM_INTERVAL_S, 'SAMPLES_UE_AMOUNTS',
        'M55316C01003', PM_INTERVAL_S, 'SAMPLES_DL_UE_AMOUNTS']

    for i in range(1, 8):
        logger.log_info_to_console(f"Verifying counter for SN-gNB SCell {i}")
        moid = f'PLMN-PLMN/MRBTS-{tl.gnbs[1].instance_id}/NRBTS-{tl.gnbs[1].global_bts_id}/NRCELL-6{i}'
        cc.verify_last_counters_in_file(*scell_counters, local_moid=moid,
                                        file_path=file_path_sn)


@log_as_robot_keyword
def verify_at_least_one_snode_initiated_sn_modifications_was_successful_by_checking_pm_counters() -> None:
    """
    KW checks below PM counters:
     - Number of received and confirmed SNode Modifications in PCell in MN gNB
     - Number of sent and confirmed SNode Modifications in PSCell in SN gNB

    :return: None
    """
    logger.log_info_to_console('Verify that at least one Snode initiated SN modifications was successful '
                               'by checking PM counters')
    counter_dir = get_builtin_value('LOG_PATH') + '/counters'
    file_path_mn = PmCountersFile.get_latest_unpacked_full_pm_counters_file(output_dirpath=counter_dir)
    file_path_sn = get_latest_pm_counters_file(bts_id=1)

    pcell_moid = f'PLMN-PLMN/MRBTS-{tl.gnbs[0].instance_id}/NRBTS-{tl.gnbs[0].global_bts_id}/NRCELL-21'
    mn_pcell_counters = [
        'M55116C00064', '>0', 'IE_NRDC_MN_SNODE_MOD_REQD',
        'M55116C00065', '0', 'IE_NRDC_MN_SNODE_MOD_REF',
        'M55116C00066', '>0', 'IE_NRDC_MN_SNODE_MOD_CONF',
        'M55116C00067', '0', 'IE_NRDC_MN_CU_MOD_REF_OVL'
    ]
    cc = counters_checker()
    cc.verify_last_counters_in_file(*mn_pcell_counters, local_moid=pcell_moid, file_path=file_path_mn)

    pscell_moid = f'PLMN-PLMN/MRBTS-{tl.gnbs[1].instance_id}/NRBTS-{tl.gnbs[1].global_bts_id}/NRCELL-60'
    sn_pscell_counters = [
        'M55116C00061', '>0', 'IE_NRDC_SN_SNODE_MOD_REQD',
        'M55116C00062', '0', 'IE_NRDC_SN_SNODE_MOD_REF',
        'M55116C00063', '>0', 'IE_NRDC_SN_SNODE_MOD_CONF',
        'M55113C02004', '0', 'NF1CC_UE_CTXT_MOD_REF_SENT',
        'M55113C02501', '0', 'SA_UE_CTXT_MOD_FAIL_OVLCP'
    ]
    cc.verify_last_counters_in_file(*sn_pscell_counters, local_moid=pscell_moid, file_path=file_path_sn)

    nrdu_sn_moid = f'PLMN-PLMN/MRBTS-{tl.gnbs[1].instance_id}/NRBTS-{tl.gnbs[1].global_bts_id}/NRDU-1'
    sn_nrdu_counters = [
        'M55117C04002', '>0', 'NF1CD_UE_CTXT_MOD_REQD_SENT',
        'M55117C04004', '>0', 'NF1CD_UE_CTXT_MOD_CONF_RECD',
        'M55117C04005', '0', 'NF1CD_UE_CTXT_MOD_REF_RECD'
    ]
    cc.verify_last_counters_in_file(*sn_nrdu_counters, local_moid=nrdu_sn_moid, file_path=file_path_sn)


@log_as_robot_keyword
def verify_nrdc_user_capacity_counters_for_release_procedure_have_been_incremented_in_mn_and_sn_gnb() -> None:
    """
    KW waits for next PM Period and checks if PM Counters were incremented in MN and SN gNB

    :return: None
    """
    logger.log_info_to_console('Verify that all NRDC user capacity counters for release procedure have been incremented'
                               ' in MN gNB and SN gNB')

    mn_moid = f'PLMN-PLMN/MRBTS-{tl.gnbs[0].instance_id}/NRBTS-{tl.gnbs[0].global_bts_id}/NRCELL-11'
    sn_moid = f'PLMN-PLMN/MRBTS-{tl.gnbs[1].instance_id}/NRBTS-{tl.gnbs[1].global_bts_id}/NRCELL-60'
    cc = counters_checker()
    cc.verify_last_counters_in_file(
        'M55138C00039', '>0', 'SUM_UE_NRDC_MN_CU',
        'M55161C00004', '>0', 'SUM_UE_NRDC_MN_CU_PMQAP',
        'M55156C00005', '>0', 'MAX_UE_NRDC_MN_CU',
        'M55195C00001', '>0', 'MAX_UE_NRDC_MN_CU_PMQAP',
        'M55161C00014', '>0', 'DENOM_CPUE_1SEC_PMQAP',
        local_moid=mn_moid, file_path=get_latest_pm_counter_file(bts_id=0)
    )
    cc.verify_last_counters_in_file(
        'M55138C00040', '>0', 'SUM_UE_NRDC_SN_CU',
        'M55161C00006', '>0', 'SUM_UE_NRDC_SN_CU_PMQAP',
        'M55156C00030', '>0', 'MAX_UE_NRDC_SN_CU',
        'M55195C00002', '>0', 'MAX_UE_NRDC_SN_CU_PMQAP',
        local_moid=sn_moid, file_path=get_latest_pm_counter_file(bts_id=1)
    )


@log_as_robot_keyword
def verify_that_all_nrdc_user_capacity_counters_for_release_procedure_are_equal_to_0_in_mn_gnb_and_sn_gnb() -> None:
    """
    KW waits for next PM Period and checks if PM Counters have value 0 in MN and SN gNB

    :return: None
    """
    logger.log_info_to_console('Verify that all NRDC user capacity counters for release procedure are equal to 0 in'
                               ' MN gNB and SN gNB')
    mn_moid = f'PLMN-PLMN/MRBTS-{tl.gnbs[0].instance_id}/NRBTS-{tl.gnbs[0].global_bts_id}/NRCELL-11'
    sn_moid = f'PLMN-PLMN/MRBTS-{tl.gnbs[1].instance_id}/NRBTS-{tl.gnbs[1].global_bts_id}/NRCELL-60'
    cc = counters_checker()
    cc.verify_last_counters_in_file(
        'M55138C00039', '0', 'SUM_UE_NRDC_MN_CU',
        'M55161C00004', '0', 'SUM_UE_NRDC_MN_CU_PMQAP',
        'M55156C00005', '0', 'MAX_UE_NRDC_MN_CU',
        'M55195C00001', '0', 'MAX_UE_NRDC_MN_CU_PMQAP',
        'M55161C00014', '>0', 'DENOM_CPUE_1SEC_PMQAP',
        local_moid=mn_moid, file_path=get_latest_pm_counter_file(bts_id=0)
    )
    cc.verify_last_counters_in_file(
        'M55138C00040', '0', 'SUM_UE_NRDC_SN_CU',
        'M55161C00006', '0', 'SUM_UE_NRDC_SN_CU_PMQAP',
        'M55156C00030', '0', 'MAX_UE_NRDC_SN_CU',
        'M55195C00002', '0', 'MAX_UE_NRDC_SN_CU_PMQAP',
        local_moid=sn_moid, file_path=get_latest_pm_counter_file(bts_id=1)
    )


def get_latest_pm_counter_file(bts_id: int = 0) -> str:
    """
    Get latest PM counter file for given bts

    :param bts_id: The ID of the BTS (Base Transceiver Station) to check. Defaults to 0.
    :return: path to XML file
    """
    if bts_id == 0:
        counter_dir = get_builtin_value('LOG_PATH') + '/counters'
        return str(PmCountersFile.get_latest_unpacked_full_pm_counters_file(output_dirpath=counter_dir))
    else:
        return get_latest_pm_counters_file(bts_id=1)


@log_as_robot_keyword
def verify_that_m55116c00054_nrdc_mn_snode_uecap_fail_was_incremented() -> None:
    """
    KW waits for next PM Period and checks NRDC_MN_SNODE_UECAP_FAIL PM Counter

    :return: None
    """
    logger.log_info_to_console('Verify that M55116C00054: NRDC_MN_SNODE_UECAP_FAIL was incremented')
    counter_dir = get_builtin_value('LOG_PATH') + '/counters'
    file_path = PmCountersFile.get_latest_unpacked_full_pm_counters_file(output_dirpath=counter_dir)
    moid = f'PLMN-PLMN/MRBTS-{tl.gnbs[0].instance_id}/NRBTS-{tl.gnbs[0].global_bts_id}/NRCELL-20'
    cc = counters_checker()
    cc.verify_last_counters_in_file(
        'M55116C00054', '>1', 'NRDC_MN_SNODE_UECAP_FAIL',
        local_moid=moid, file_path=file_path
    )


@log_as_robot_keyword
def verify_that_gnb_sa_admission_mfbi_succ_and_gnb_sa_du_admission_mfbi_succ_pm_counters_were_incremented() -> None:
    """
    GNB_SA_ADMISSION_MFBI_SUCC and GNB_SA_DU_ADMISSION_MFBI_SUCC PM Counters were incremented
    """
    logger.log_info_to_console('Verify that GNB_SA_ADMISSION_MFBI_SUCC and GNB_SA_DU_ADMISSION_MFBI_SUCC PM Counters'
                               ' were incremented')
    file_path = get_latest_pm_counter_file(bts_id=0)
    moid = f'PLMN-PLMN/MRBTS-{tl.gnbs[0].instance_id}/NRBTS-{tl.gnbs[0].global_bts_id}/NRCELL-20'
    cc = counters_checker()
    cc.verify_last_counters_in_file(
        'M55138C00502', '>0', 'GNB_SA_ADMISSION_MFBI_SUCC',
        'M55139C02002', '>0', 'GNB_SA_DU_ADMISSION_MFBI_SUCC',
        local_moid=moid, file_path=file_path
    )


@log_as_robot_keyword
def wait_for_next_pm_counters_interval(interval: str = '5min', delay: int = 30) -> datetime:
    """
    Wait For Next PM Interval

    :param delay:
    :param interval: PM Interval length
    :return: time of PM interval start in datetime object
    """
    logger.log_info_to_console(f'=== Wait For Next PM Interval: {interval} ===')
    GnbPmCounter().wait_for_next_pm_period(interval=interval, delay=delay)
    return Misc().get_now_datetime()


@log_as_robot_keyword
def get_latest_pm_counters_file(bts_id: int = 0) -> str:
    """
    Get latest XML file for given bts
    :param bts_id: The ID of the BTS (Base Transceiver Station) to check. Defaults to 0.
    :return: path to XML file
    """
    pmdu = PmCounterDu()
    pm_files_path = pmdu.collect_counters(bts_id=bts_id)
    last_pm_file = _get_newest_xml_file_in_directory(pm_files_path)
    if last_pm_file is None:
        raise FileNotFoundError(f"No valid PM counter files found in directory: {pm_files_path}")
    return os.path.join(pm_files_path, last_pm_file)


def _get_newest_xml_file_in_directory(directory_path: str) -> Optional[str]:
    """
    Identifies the newest XML file in a given directory based on its embedded timestamp.
    The filenames are expected to follow the pattern: PM.BTS-XXXXX.YYYYMMDD.HHMMSS.ANY.xml

    :param directory_path: The path to the directory containing the files.
    :return: The filename string (base name, not full path) corresponding to the newest file,
        or None if the directory is empty, does not exist, or no valid XML files are found.
    """
    if not os.path.isdir(directory_path):
        logging.error(f"Error: Directory '{directory_path}' does not exist or is not a directory.")
        return None

    newest_timestamp: Optional[datetime] = None
    newest_filename: Optional[str] = None

    for filename in os.listdir(directory_path):
        full_path = os.path.join(directory_path, filename)
        if os.path.isfile(full_path):
            timestamp = _parse_timestamp_from_filename(filename)
            if timestamp is not None and (newest_timestamp is None or timestamp > newest_timestamp):
                newest_timestamp = timestamp
                newest_filename = filename

    return newest_filename


def _parse_timestamp_from_filename(file_name: str) -> Optional[datetime]:
    """
    Helper function to extract and parse the timestamp from an XML filename.
    Returns a datetime object or None if parsing fails or the format doesn't match.
    Expecting at least 6 parts: PM, BTS-XXXXX, YYYYMMDD, HHMMSS, ANY, xml
    The date part is at index 2 (e.g., '20251002')
    The time part is at index 3 (e.g., '130500')
    :param file_name: filename in format PM.BTS-XXXXX.YYYYMMDD.HHMMSS.ANY.xml
    :return: datetime object or None if parsing fails or the format doesn't match.
    """
    if not (file_name.startswith("PM.BTS-") and file_name.endswith(".ANY.xml")):
        return None

    try:
        parts = file_name.split('.')

        if len(parts) < 6:
            return None

        date_str = parts[2]
        time_str = parts[3]
        timestamp_str = date_str + time_str

        return datetime.strptime(timestamp_str, '%Y%m%d%H%M%S')
    except (IndexError, ValueError):
        return None

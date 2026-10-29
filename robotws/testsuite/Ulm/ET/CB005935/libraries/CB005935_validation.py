# =====================================================================================================[120 characters]
# This is a Python File, which helps to implement the Private Robot Keywords used in VRF ULM 5 for CB005935 Feature
# Team: 'MN RAN RD VRF ULM 5'
# Email: 'OO_MN_RAN_RD_VRF_ULM_5_53245008@internal.nsn.com'
# -----------------------------------------------------------------------------------------------------[120 characters]

import logging
import os
# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn

# TAF & UTE Libraries:
from taf.config.scf import scf

# ET or Feature Specific Libraries:
import pandas as pd

from testsuite.Ulm.ET.L2.libraries.logger import log_begin_end_func_name
from testsuite.Ulm.ET.resources.SQD68.pmc_analysis import (verify_pm_counters, get_pm_counters,
                                                           prepare_for_pm_counter_testing,
                                                           finalise_pm_counter_testing)
from testsuite.Ulm.ET.CB008246.libraries.ttitrace_analysis import (get_expected_new_pmc_values,
                                                                   plot_df_with_scatter)
from testsuite.Ulm.ET.L2.libraries.syslogs_analysis import check_no_fatality_error_in_syslogs


# =====================================================================================================[120 characters]
#   Global Variables
# =====================================================================================================[120 characters]

RED = '\033[31m'
GREEN = '\033[32m'
YELLOW = '\033[33m'
RESET = '\033[0m'
BOLD = '\033[1m'
rbi = BuiltIn()
pmResultFile = None


# =====================================================================================================[120 characters]
#   Keywords
# =====================================================================================================[120 characters]

@log_begin_end_func_name
def verify_qc_test_case(tc_name):
    # -------------------------------------------------------------------------------------------------[120 characters]
    # Generic keyword which makes the common preparation and calls the Test Case specific Validation
    # -------------------------------------------------------------------------------------------------[120 characters]
    rbi.log_to_console(
        BOLD + "\n Verify QC Test Case(s) of CB008246: " + RESET + "~" * 102 + "")
    # rbi.log_to_console(("  "+tc_name[:80]+"   ").ljust(133), no_newline=True)
    tc_verdict = False
    ts_log_dir = rbi.get_variable_value("${ts_log_dir}")
    path_to_syslog_tgz = rbi.get_variable_value("${path_to_syslog_tgz}")
    pmc_csv_file = rbi.get_variable_value(
        "${pm_counters_dir}") + "/pmCounters.csv"
    pmc_index = rbi.get_variable_value("${pmc_index}")
    nrbts_str = rbi.get_variable_value("${nrbts_str}")[0]
    scenario_name = rbi.get_variable_value("${scenario}")
    rntis_for_ue_group = rbi.run_keyword(
        "get_rntis_for_ue_group", scenario_name)
    logging.info("rntis_for_ue_group = %s" % rntis_for_ue_group)
    PCell = 4  # <-- Primary serving cell for Carrier Aggregation
    SCell = 5  # <-- Secondary serving cell for Carrier Aggregation
    rdMinCrcNack = 5  # <-- rdMinCrcNackIndUlEnhanced for PCELL
    rdMinCrcNack_Scell = 7  # <-- rdMinCrcNackIndUlEnhanced for SCELL
    # <-- indicates the number of slots between  PDCCH/DCI and UL Data(PUSCH) transmission
    K2 = 2
    column = -(pmc_index+3)
    logging.info("tc_name = %s" % tc_name)
    logging.info("ts_log_dir = %s" % ts_log_dir)
    logging.info("pmc_csv_file = %s" % pmc_csv_file)
    logging.info("PCell = %s" % PCell)
    logging.info("SCell = %s" % SCell)
    logging.info("column = %s" % column)
    path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_pkl}")
    # --- Plot some usefull Charts: -------------------------------------------------------------------[120 characters]
    plot_for_DL(path_to_ttitrace_pkl, tc_name)
    plot_for_UL(path_to_ttitrace_pkl, tc_name)
    # --- Test Case Specific Part: --------------------------------------------------------------------[120 characters]
    if "CB005935-BB-B2_Single_F+F_UL_2CCs_CA_UE_call_with_NACK_flood_triggered" == tc_name:
        check_points = [verify_SCF_Paramaters(PCell)]  # <--- Common Checkpoint
        check_points.append(verify_SCF_Paramaters(SCell))
        check_points.append(verify_stop_cell_scheduling_existing(
            PCell, 'PCELL', path_to_ttitrace_pkl))
        check_points.append(verify_Nackflood_existing(
            PCell, 'PCELL', path_to_ttitrace_pkl))
        check_points.append(verify_Nackflood_based_on_ttitraces(PCell, 'PCELL', rdMinCrcNack,
                                                                K2, path_to_ttitrace_pkl))
        check_points.append(verify_stop_cell_scheduling_existing(
            SCell, 'SCELL', path_to_ttitrace_pkl))
        check_points.append(verify_Nackflood_existing(
            SCell, 'SCELL', path_to_ttitrace_pkl))
        check_points.append(verify_Nackflood_based_on_ttitraces(SCell, 'SCELL', rdMinCrcNack_Scell,
                                                                K2, path_to_ttitrace_pkl))
        # --------------------------------------------------------------------------------------------[120 characters]
    if "CB005935-ET-BB001_FF_ULCA_IWK_with_overheating_UAI" == tc_name:
        check_points = [verify_SCF_Paramaters(PCell)]  # <--- Common Checkpoint
        check_points.append(verify_SCF_Paramaters(SCell))
        # Inter-freq HO check from source cell-4 to cell-2
        check_points.append(verify_legacy_interfreq_HO_pmc_BB01(
            pmc_csv_file, column, 4, tc_name))
        # RRE checks peer cell (2 times in cell-2 and 3 times in cell-4)
        check_points.append(verify_legacy_RRE_pmc_BB01(
            pmc_csv_file, column, 2, tc_name, 2))
        check_points.append(verify_legacy_RRE_pmc_BB01(
            pmc_csv_file, column, 4, tc_name, 3))
        # OAI checks in all cells during overheating
        for cell in range(1, 7):
            check_points.append(verify_legacy_OAI_pmc_BB01(
                pmc_csv_file, column, cell, tc_name))
        # --------------------------------------------------------------------------------------------[120 characters]
    if "CB005935-ET-C001_FF_ULCA_IWK_with_9059" == tc_name:
        check_points = [verify_SCF_Paramaters(PCell)]  # <--- Common Checkpoint
        check_points.append(verify_SCF_Paramaters(SCell))
        # Scell_suspension_pmc checks in all cells during overheating
        for cell in range(1, 7):
            check_points.append(verify_legacy_Scell_suspension_pmc_C001(
                pmc_csv_file, column, cell, tc_name))
        # ---------------------------------------------------------------------------------------------[120 characters]
    if "CB005935-C-B4_1_Interworking_with_cache_optimized_L2_software_deployment_for_FR1-FDD" == tc_name:
        check_points = [verify_SCF_Paramaters(1)]  # <--- Common Checkpoint
        for cell in range(2, 9):
            check_points.append(verify_SCF_Paramaters(cell))
            check_points.append(verify_dlBLER_pmCounter(
                pmc_csv_file, column, cell))

    # -------------------------------------------------------------------------------------------------[120 characters]
    logging.info("check_points = %s" % check_points)
    tc_verdict = all(check_points)
    logging.info("verify_qc_test_case: tc_verdict = %s" % tc_verdict)
    # IMPORTANT: allows "Robot-TC-Name != QC-TC-Name" case
    rbi.set_test_variable("${TEST NAME}", tc_name)
    rbi.should_be_true(tc_verdict)  # IMPORTANT: keep this line the LAST one


# =====================================================================================================[120 characters]
#   Validation Functions
# =====================================================================================================[120 characters]

@log_begin_end_func_name
def verify_SCF_Paramaters(cell):
    is_SCF_correct = False
    path_to_scf_xml = rbi.get_variable_value("${path_to_scf_xml}")
    distname_nrbts = rbi.get_variable_value("${nrbts_str}")[0]
    nrcell = distname_nrbts + "/NRCELL-%s" % cell
    distname_nrcell_nrrel = distname_nrbts + "/NRCELL-4/NRREL-1"
    distname_nrdu = distname_nrbts + "/NRDU-1"
    distname_nrdrb_rlc_am_1 = distname_nrbts + "/NRDRB_RLC_AM-1"
    distname_nrdrb_rlc_am_2 = distname_nrbts + "/NRDRB_RLC_AM-2"
    try:
        scf = [{'p_name': 'actMultipleDedicatedBWPs', 'value': 'false', 'dist_name': distname_nrbts},
               {'p_name': 'actLteNrDss', 'value': 'false',
                   'dist_name': distname_nrbts},
               {'p_name': 'actFdmScheduling', 'value': 'true',
                   'dist_name': distname_nrbts},
               {'p_name': 'sCellActivationMinDataThreshold',
                   'value': '6000', 'dist_name': nrcell},
               {'p_name': 'sCellActivationLevelUL',
                   'value': '1TTI', 'dist_name': nrcell},
               {'p_name': 'sCellActivationLevel',
                   'value': '1TTI', 'dist_name': nrcell},
               {'p_name': 'pucchModeSelect',
                   'value': 'longPucch', 'dist_name': nrcell},
               {'p_name': 'actIncreasedFdmUsersPerSlot',
                   'value': 'true', 'dist_name': nrcell},
               {'p_name': 'actUlClosedLoopPwrCtrl',
                   'value': 'disabled', 'dist_name': nrcell},
               {'p_name': 'actEnhMultipleDedicatedBWPs',
                   'value': 'false', 'dist_name': nrcell},
               {'p_name': 'actPowerSavingBWP', 'value': 'false', 'dist_name': nrcell},
               {'p_name': 'actPRBBlanking', 'value': 'false', 'dist_name': nrcell},
               {'p_name': 'actK1Opt', 'value': 'intra-gNB', 'dist_name': nrcell},
               {'p_name': 'cellDepType', 'value': 'SA', 'dist_name': nrcell},
               {'p_name': 'actCDrx', 'value': 'false', 'dist_name': nrcell},
               {'p_name': 'timingAdvanceOffset',
                   'value': 'n25600', 'dist_name': nrcell},
               {'p_name': 'increaseK1ULCA',
                   'value': 'K1 not increased', 'dist_name': nrcell},
               {'p_name': 'dlMimoMode',
                   'value': '4x4 or 4x2 Closed Loop Spatial Multiplexing', 'dist_name': nrcell},
               {'p_name': 'nrCellType', 'value': '4DL4UL', 'dist_name': nrcell},
               {'p_name': 'dlToUlContributionRatio',
                   'value': '50', 'dist_name': distname_nrdu},
               {'p_name': 'actConnectedModeMobilityCA',
                   'value': 'true', 'dist_name': distname_nrdu},
               {'p_name': 'ulTReassemblyIBCA', 'value': '40',
                   'dist_name': distname_nrdrb_rlc_am_1},
               {'p_name': 'ulTReassemblyIBCA', 'value': '40',
                   'dist_name': distname_nrdrb_rlc_am_2},
               {'p_name': 'sCellOperationalMode', 'value': 'dlAndUl',
                   'dist_name': distname_nrcell_nrrel},
               {'p_name': 'sCellAdditionMethod', 'value': 'blind', 'dist_name': distname_nrcell_nrrel}]
        is_SCF_correct = verifyParametersInScf(scf, path_to_scf_xml)
    except Exception as e:
        logException("verify_SCF_Paramaters", e)
    logging.info("is_SCF_correct = %s" % is_SCF_correct)
    return is_SCF_correct


@log_begin_end_func_name
def verify_stop_cell_scheduling_existing(cell, celltype, path_to_ttitrace_pkl):
    verify_stop_cell_scheduling_existing = False
    # -------------------------------------------------------------------------------------------------[120 characters]
    path_to_ttitrace_pkl = os.path.dirname(
        path_to_ttitrace_pkl) + "/ttitrace_streaming_ulharq.pkl"
    # -------------------------------------------------------------------------------------------------[120 characters]
    try:
        df = get_df_from_pkl(path_to_ttitrace_pkl, dir='ul')
        lcrId = 'lcrId'
        ueType = 'ulFdSchedData.ueType'
        crcResult = 'ulHarqRxData.crcResult'
        rrmPause = 'ulLaDeltaSinr.rrmPauseUeInUlScheduling'
        df_filtered = df[[lcrId, ueType, crcResult, rrmPause]]
        df_filtered_NONCA_removed = df_filtered.loc[df_filtered[ueType] != 'NONCA']
        df_filtered_cell = df_filtered_NONCA_removed.loc[df_filtered_NONCA_removed[lcrId] == cell]
        df_optimized = df_filtered_cell.iloc[100:-10]
        verify_stop_cell_scheduling_existing = df_optimized[rrmPause].isna(
        ).any()
    except Exception as e:
        logException("verify_stop_cell_scheduling_existing", e)
    logging.info("verify_stop_cell_scheduling_existing = %s" %
                 verify_stop_cell_scheduling_existing)
    return verify_stop_cell_scheduling_existing


@log_begin_end_func_name
def verify_Nackflood_existing(cell, celltype, path_to_ttitrace_pkl):
    verify_Nackflood_existing = False
    # -------------------------------------------------------------------------------------------------[120 characters]
    path_to_ttitrace_pkl = os.path.dirname(
        path_to_ttitrace_pkl) + "/ttitrace_streaming_ulharq.pkl"
    # -------------------------------------------------------------------------------------------------[120 characters]
    try:
        df = get_df_from_pkl(path_to_ttitrace_pkl, dir='ul')
        lcrId = 'lcrId'
        ueType = 'ulFdSchedData.ueType'
        crcResult = 'ulHarqRxData.crcResult'
        rrmPause = 'ulLaDeltaSinr.rrmPauseUeInUlScheduling'
        df_filtered = df[[lcrId, ueType, crcResult, rrmPause]]
        df_filtered_NONCA_removed = df_filtered.loc[df_filtered[ueType] != 'NONCA']
        df_filtered_cell = df_filtered_NONCA_removed.loc[df_filtered_NONCA_removed[lcrId] == cell]
        df_optimized = df_filtered_cell.iloc[100:-10]
        verify_Nackflood_existing = (df_optimized[rrmPause] == 1).any()
    except Exception as e:
        logException("verify_Nackflood_existing", e)
    logging.info("verify_Nackflood_existing = %s" % verify_Nackflood_existing)
    return verify_Nackflood_existing


@log_begin_end_func_name
def verify_Nackflood_based_on_ttitraces(cell, celltype, rdMinCrcNack, K2, path_to_ttitrace_pkl):
    verify_Nackflood = False
    # -------------------------------------------------------------------------------------------------[120 characters]
    path_to_ttitrace_pkl = os.path.dirname(
        path_to_ttitrace_pkl) + "/ttitrace_streaming_ulharq.pkl"
    # -------------------------------------------------------------------------------------------------[120 characters]
    try:
        df = get_df_from_pkl(path_to_ttitrace_pkl, dir='ul')
        lcrId = 'lcrId'
        ueType = 'ulFdSchedData.ueType'
        crcResult = 'ulHarqRxData.crcResult'
        rrmPause = 'ulLaDeltaSinr.rrmPauseUeInUlScheduling'
        txNumber = 'ulFdSchedData.txNumber'
        rrmUlUsedMcs = 'ulFdSchedData.rrmUlUsedMcs'
        # Filtering df and extracting needed columns
        df_filtered_cell = df.loc[df[lcrId] == cell]
        df_filtered_cell = df_filtered_cell.loc[df_filtered_cell[ueType] == celltype]
        df_filtered_cell_notna = df_filtered_cell.loc[df_filtered_cell[txNumber].notna(
        )]
        # empty values will be replaced with 0
        df_filtered_cell_notna[rrmPause] = df_filtered_cell_notna[rrmPause].fillna(
            0)
        df_filtered_cell_notna_cut = df_filtered_cell_notna.iloc[10:-10]
        df_o = df_filtered_cell_notna_cut[[
            crcResult, rrmPause, txNumber, rrmUlUsedMcs]]
        logging.info("df_o = \n%s" % df_o)
        # manipulations on txNumber and crcResult
        df_o.loc[df_o[txNumber] != 1, txNumber] = 0
        df_o.loc[df_o[crcResult] == 'OK', crcResult] = 0
        df_o.loc[df_o[crcResult] == 'NOK', crcResult] = 1
        # adding new_column for verifications, column_shifted_by_K2-1 to ignore last UL grants (K2-1 slots to ignore)
        df_o['new_column'] = df_o[crcResult] * df_o[txNumber]
        df_o['column_shifted_by_K2-1'] = df_o[rrmPause].shift(1-K2)
        # implementing for new_column new calculation Un+1 = (E*C*(1-D)+Un)*C , D not shifted in some exeption
        # C = 'ulHarqRxData.crcResult',D = 'ulLaDeltaSinr.rrmPauseUeInUlScheduling',E = 'ulFdSchedData.txNumber'
        for i in range(len(df_o) - 1):
            if df_o['new_column'].iloc[i] == rdMinCrcNack-1 and df_o['column_shifted_by_K2-1'].iloc[i] == 1:
                U = df_o[txNumber].iloc[i] * \
                    df_o[crcResult].iloc[i] * (1 - df_o[rrmPause].iloc[i])
                df_o['new_column'].iloc[i +
                                        1] = (U + df_o['new_column'].iloc[i]) * df_o[crcResult].iloc[i]
            else:
                U = df_o[txNumber].iloc[i] * df_o[crcResult].iloc[i] * \
                    (1 - df_o['column_shifted_by_K2-1'].iloc[i])
                df_o['new_column'].iloc[i +
                                        1] = (U + df_o['new_column'].iloc[i]) * df_o[crcResult].iloc[i]
        logging.info(
            "df_o after verifications and adding new column = \n%s" % df_o)
        #  verifications of Nackflood and rdMinCrcNack value
        df_o_1 = df_o[df_o[rrmPause] == 1]
        logging.info(
            "new_column of df_o_1 when rrmPauseUeInUlScheduling equal 1 = \n%s" % df_o_1['new_column'])
        #  all values of df_o_1['new_column'] should be equal to rdMinCrcNack
        all_equal_to_rdMinCrcNack = (
            df_o_1['new_column'] == rdMinCrcNack).all()
        verify_Nackflood = all_equal_to_rdMinCrcNack
    except Exception as e:
        logException("verify_Nackflood", e)
    logging.info("verify_Nackflood = %s" % verify_Nackflood)
    return verify_Nackflood


@log_begin_end_func_name
def verify_legacy_interfreq_HO_pmc_BB01(pmc_csv_file, column, cell, tc_name):
    are_pmcs_correct = False
    # ------------------------------------------------------------------------------------------------[120 characters]
    try:
        piids_and_expected_values = {"M55145C00321": 1,  # nbr of interfreq intra-DU HO attempts for SA per PLMN
                                     "M55145C00322": 1,  # nbr of successful interfreq intra-DU HO for SA per PLMN
                                     "M55147C00024": 1}  # nbr of positive interfreq HO after receiving A3 meas
        are_pmcs_correct = verify_pm_counters(pmc_csv_file, column, cell, piids_and_expected_values, tc_name,
                                              threshold_percent=0)
        # --------------------------------------------------------------------------------------------[120 characters]
    except Exception as e:
        logException("verify_legacy_interfreq_HO_pmc_BB01", e)
    logging.info("are_pmcs_correct = %s" % are_pmcs_correct)
    return are_pmcs_correct


@log_begin_end_func_name
def verify_dlBLER_pmCounter(pmc_csv_file, column, cell):
    is_dlBler_correct = False
    # ------------------------------------------------------------------------------------------------[120 characters]
    try:
        reported_bler_values = get_pm_counters(pmc_csv_file, column, cell, [
                                               "M55300C00033", "M55300C00034"])
        InitialBler = reported_bler_values["M55300C00033"]
        SuccesfullBler = reported_bler_values["M55300C00034"]
        BlerPercentage = (SuccesfullBler/InitialBler)*100.0
        is_dlBler_correct = BlerPercentage > 99.9
        logging.info("Bler Percentage = %s" % BlerPercentage)
        # --------------------------------------------------------------------------------------------[120 characters]
    except Exception as e:
        logException("verify_dlBLER_pmCounter", e)
    logging.info("is_dlBler_correct = %s" % is_dlBler_correct)
    return is_dlBler_correct


@log_begin_end_func_name
def verify_legacy_RRE_pmc_BB01(pmc_csv_file, column, cell, tc_name, nbr_of_RRE):
    are_pmcs_correct = False
    # ------------------------------------------------------------------------------------------------[120 characters]
    try:
        piids_and_expected_values = {"M55124C00503": 0,  # nbr of RREs Requests caused by 1='otherFailure'or'spare1'
                                     "M55124C00504": 0,  # nbr of RREs Requests caused by handover failure
                                     "M55124C00505": nbr_of_RRE,  # nbr of RREs Requests caused by 1
                                     "M55124C00510": 0,  # nbr of accepted RREs when reestab cause is reconf failure
                                     "M55124C00511": 0,  # nbr of accepted RREs when reestab cause is handover failure
                                     "M55124C00512": nbr_of_RRE}  # nbr of accepted RREs when reestab cause is 1
        are_pmcs_correct = verify_pm_counters(pmc_csv_file, column, cell, piids_and_expected_values, tc_name,
                                              threshold_percent=0)
        # --------------------------------------------------------------------------------------------[120 characters]
    except Exception as e:
        logException("verify_legacy_RRE_pmc_BB01", e)
    logging.info("are_pmcs_correct = %s" % are_pmcs_correct)
    return are_pmcs_correct


@log_begin_end_func_name
def verify_legacy_OAI_pmc_BB01(pmc_csv_file, column, cell, tc_name):
    are_pmcs_correct = False
    # ------------------------------------------------------------------------------------------------[120 characters]
    try:
        if cell == 2:
            piids_and_expected_values = {"M55118C07501": 7,  # nbr of overall OAI reports received from UE
                                         "M55118C07503": 0,  # nbr of OAI reports requesting 0 SCell to be active
                                         "M55118C07504": 2,  # nbr of OAI reports requesting 1 SCell to be active
                                         "M55118C07505": 0,  # nbr of OAI reports requesting 2 SCells to be active
                                         "M55118C07506": 3,  # nbr of OAI reports requesting 3 SCells to be active
                                         "M55118C07511": 2}  # nbr of OAI reports requesting 4 SCells to be active
        else:
            piids_and_expected_values = {"M55118C07501": 0,  # nbr of overall OAI reports received from UE
                                         "M55118C07503": 0,  # nbr of OAI reports requesting 0 SCell to be active
                                         "M55118C07504": 0,  # nbr of OAI reports requesting 1 SCell to be active
                                         "M55118C07505": 0,  # nbr of OAI reports requesting 2 SCells to be active
                                         "M55118C07506": 0,  # nbr of OAI reports requesting 3 SCells to be active
                                         "M55118C07511": 0}  # nbr of OAI reports requesting 4 SCells to be active
        are_pmcs_correct = verify_pm_counters(pmc_csv_file, column, cell, piids_and_expected_values, tc_name,
                                              threshold_percent=0)
        # --------------------------------------------------------------------------------------------[120 characters]
    except Exception as e:
        logException("verify_legacy_OAI_pmc_BB01", e)
    logging.info("are_pmcs_correct = %s" % are_pmcs_correct)
    return are_pmcs_correct


@log_begin_end_func_name
def verify_legacy_Scell_suspension_pmc_C001(pmc_csv_file, column, cell, tc_name):
    are_pmcs_correct = False
    # ------------------------------------------------------------------------------------------------[120 characters]
    try:
        if cell == 4:
            # Duration for which UL SCell scheduling is suspended
            piids_and_expected_values_1 = {"M55316C00001": 7000}
            piids_and_expected_values_2 = {"M55316C00002": 2,  # Denominator for calculation of avr UL SCell susp time
                                           "M55316C00003": 0,  # Num UL SCell sched susp not supp lch-ToSCellRestriction
                                           "M55316C15006": 0}  # SCELL_UL_SUSPEND_NELGBLDRB_SA
            are_pmcs_correct_1 = verify_pm_counters(pmc_csv_file, column, cell, piids_and_expected_values_1, tc_name,
                                                    threshold_percent=10)
            are_pmcs_correct_2 = verify_pm_counters(pmc_csv_file, column, cell, piids_and_expected_values_2, tc_name,
                                                    threshold_percent=0)
            are_pmcs_correct = are_pmcs_correct_1 and are_pmcs_correct_2
        elif cell == 5:
            piids_and_expected_values = {"M55316C00001": 0,  # Duration for which UL SCell scheduling is suspended
                                         "M55316C00002": 0,  # Denominator for calculation of avr UL SCell susp time
                                         "M55316C00003": 2,  # Num UL SCell sched susp not supp lch-ToSCellRestriction
                                         "M55316C15006": 2}  # SCELL_UL_SUSPEND_NELGBLDRB_SA
            are_pmcs_correct = verify_pm_counters(pmc_csv_file, column, cell, piids_and_expected_values, tc_name,
                                                  threshold_percent=0)
        else:
            piids_and_expected_values = {"M55316C00001": 0,  # Duration for which UL SCell scheduling is suspended
                                         "M55316C00002": 0,  # Denominator for calculation of avr UL SCell susp time
                                         "M55316C00003": 0,  # Num UL SCell sched susp not supp lch-ToSCellRestriction
                                         "M55316C15006": 0}  # SCELL_UL_SUSPEND_NELGBLDRB_SA
            are_pmcs_correct = verify_pm_counters(pmc_csv_file, column, cell, piids_and_expected_values, tc_name,
                                                  threshold_percent=0)
        # --------------------------------------------------------------------------------------------[120 characters]
    except Exception as e:
        logException("verify_legacy_Scell_suspension_pmc_C001", e)
    logging.info("are_pmcs_correct = %s" % are_pmcs_correct)
    return are_pmcs_correct


@log_begin_end_func_name
def plot_for_DL(path_to_ttitrace_pkl, tc_name):
    try:
        path_to_ttitrace_pkl = os.path.dirname(
            path_to_ttitrace_pkl) + "/ttitrace_streaming_dlharq.pkl"
        # ---------------------------------------------------------------------------------------------[120 characters]
        df = get_df_from_pkl(path_to_ttitrace_pkl, dir='dl')
        plot_df_with_scatter(df=df,
                             yaxis_column='dlFdSchedData.laMode',
                             base_location=os.path.dirname(
                                 path_to_ttitrace_pkl),
                             postfix="UL",
                             xaxis_column="timeStamp",
                             title=tc_name,
                             group_by='rnti',
                             second_yaxis_col='dlFdSchedData.ackNack',
                             third_yaxis_col='dlFdSchedAdditionalData.targetBLER',
                             fourth_yaxis_col='dlFdSchedData.txNumber')
        plot_df_with_scatter(df=df,
                             yaxis_column='dlFdSchedData.rrmDlUsedMcs',
                             base_location=os.path.dirname(
                                 path_to_ttitrace_pkl),
                             postfix="DL_Mcs",
                             xaxis_column="timeStamp",
                             title=tc_name,
                             second_yaxis_col='dlFdSchedData.rrmDlProposedMcs',
                             group_by='rnti')
    except Exception as e:
        logException("plot_for_DL", e)


@log_begin_end_func_name
def plot_for_UL(path_to_ttitrace_pkl, tc_name):
    try:
        df = get_df_from_pkl(path_to_ttitrace_pkl, dir='ul')

        logging.info("sw_build = %s" % sw_build)
        if any(x in sw_build for x in ['SBTS25R3', 'SBTS26R1']):
            targetBLER = 'ulFdSchedData.targetBLER'
        else:
            targetBLER = 'ulFdSchedAdditionalData.targetBLER'

        plot_df_with_scatter(df=df,
                             yaxis_column='ulFdSchedData.laMode',
                             base_location=os.path.dirname(
                                 path_to_ttitrace_pkl),
                             postfix="UL",
                             xaxis_column="timeStamp",
                             title=tc_name,
                             group_by='rnti',
                             second_yaxis_col='ulHarqRxData.crcResult',
                             third_yaxis_col=targetBLER,
                             fourth_yaxis_col='ulFdSchedData.txNumber')
        plot_df_with_scatter(df=df,
                             yaxis_column='ulFdSchedData.rrmUlUsedMcs',
                             base_location=os.path.dirname(
                                 path_to_ttitrace_pkl),
                             postfix="UL_Mcs",
                             xaxis_column="timeStamp",
                             title=tc_name,
                             second_yaxis_col='ulFdSchedData.rrmUlProposedMcs',
                             third_yaxis_col='ulFdSchedData.sampledWideBandTbs',
                             group_by='rnti')
    except Exception as e:
        logException("plot_for_UL", e)


# =====================================================================================================[120 characters]
#   Private Functions
# =====================================================================================================[120 characters

@log_begin_end_func_name
def get_df_from_pkl(path_to_pickle, dir):
    global sw_build
    sw_build = rbi.get_variable_value("${sw_build}")
    logging.info("sw_build = %s" % sw_build)
    ackNack = 'dlFdSchedData.ackNack'
    crcResult = 'ulHarqRxData.crcResult'
    txNumber = '{}FdSchedData.txNumber'.format(dir)
    mcsTable = '{}FdSchedData.mcsTable'.format(dir)
    laMode = '{}FdSchedData.laMode'.format(dir)
    if dir == 'dl':
        targetBLER = 'dlFdSchedAdditionalData.targetBLER'
    elif any(x in sw_build for x in ['SBTS25R3', 'SBTS26R1']):
        targetBLER = 'ulFdSchedData.targetBLER'
    else:
        targetBLER = 'ulFdSchedAdditionalData.targetBLER'
    usedMcs = '{}FdSchedData.rrm{}UsedMcs'.format(dir, dir.capitalize())
    proposedMcs = '{}FdSchedData.rrm{}ProposedMcs'.format(
        dir, dir.capitalize())
    isDeltaSinrCalculated = 'ulLaDeltaSinr.isDeltaSinrCalculated'
    crcFb = 'ulLaDeltaSinr.crcFb'
    rrmDeltaSinr = 'ulLaDeltaSinr.rrmDeltaSinr'
    targetBlerType = 'ulLaDeltaSinr.targetBlerType'
    ulUsedMcs = 'ulLaDeltaSinr.ulUsedMcs'
    rrmPauseUeInUlScheduling = 'ulLaDeltaSinr.rrmPauseUeInUlScheduling'
    puschTPstate = 'ulFdSchedData.puschTPstate'
    tpHystCounter = 'ulFdSchedData.tpHystCounter'
    ueType = 'ulFdSchedData.ueType'
    # -------------------------------------------------------------------------------------------------[120 characters]
    df = pd.read_pickle(path_to_pickle)
    if dir == 'dl':
        df = df[['timeStamp', 'sfn', 'slot', 'rnti', 'lcrId', 'physCellId', ackNack, txNumber, mcsTable,
                 laMode, targetBLER, usedMcs, proposedMcs]]
    else:
        df = df[['timeStamp', 'sfn', 'slot', 'rnti', 'lcrId', 'physCellId', crcResult, txNumber, mcsTable,
                 laMode, targetBLER, usedMcs, 'ulFdSchedData.sampledWideBandTbs', proposedMcs, isDeltaSinrCalculated,
                 crcFb, rrmDeltaSinr, targetBlerType, ulUsedMcs, rrmPauseUeInUlScheduling, puschTPstate, tpHystCounter,
                 'ulFdSchedData.rrmAvgSinrTpSwitch', ueType]]
    return df


@log_begin_end_func_name
def verifyParametersInScf(verifyScfList, scfFilePath):
    isPassed = True
    scfObj = scf()
    for parameter in verifyScfList:
        returnedValue = 0
        try:
            scfObj.load_scf(scfFilePath)
            returnedValue = get_scf_value(
                scfObj, parameter["p_name"], parameter["dist_name"])
            aResult = (returnedValue == parameter["value"])
        except Exception as e:
            logException("verifyParametersInScf", e, silent=True)
            aResult = "SCF is NOT available"
            isPassed = False
        else:
            isPassed = (isPassed and aResult)
        logging.info(30*"-" + "> %s == %s (%s)" %
                     (parameter["value"], returnedValue, aResult))
    return isPassed


def get_scf_value(scfObj, pName, distName):
    outString = ""
    logging.info("get_scf_value(): pName = %s" % (pName))
    logging.info("get_scf_value(): outString = %s" % (outString))
    try:
        outString = scfObj.get_value_from_scf(p_name=pName, dist_name=distName)
        outString = "true" if outString == "True" else outString
        outString = "false" if outString == "False" else outString
        logging.info("get_scf_value(): '%s' = '%s' (SCF)" % (pName, outString))
    except Exception as e:
        logException("get_scf_value", e)
    return outString


@log_begin_end_func_name
def logException(functionNameStr, e, silent=False):
    logging.info("%s(): Exception = <%s>" % (functionNameStr, str(e)))
    if not silent:
        rbi.log_to_console(
            "\n" + RED + "  %s: exception happend (see log.html)" % functionNameStr + RESET + "")

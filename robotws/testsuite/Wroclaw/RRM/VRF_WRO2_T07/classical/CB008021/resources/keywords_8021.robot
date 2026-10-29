*** Settings ***
Documentation
...   author: Adrian Jakobik
...   contact: adrian.jakobik@nokia.com
...   This is the ROBOT KEYWORDS file for feature CB008021


Library      taf.ue
Library      taf.sbts.oam.coam.admin    WITH NAME    coam
Library      taf.rfrl.bts.devices.du.pm_counters.GnbPmCounter   WITH NAME      GnbCounter
Library      taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME    gnbcell
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/rue/attach_utils.py
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attenuator_keywords.py
Library      testsuite/Wroclaw/RRM/resources/scf_verification/scf_verifier.py
Library      testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils.AdminUtils
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB008021/resources/test_specific_keywords_8021.py
Library      testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.testline_preparation    WITH NAME    testline_preparation
Resource     testsuite/Wroclaw/RRM/resources/btslog_collecting.robot

Variables    testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB008021/resources/test_specific_keywords_8021.py


*** Keywords ***
UL_INTERFERENCE_AND_NOISE_MEASUREMENT_PRACH_PUCCH_F1
    [Documentation]   Setup for CB008021 testcases using PRACH and PUCCH F1 measurement
	Setup and check preconditions in scf   params_to_check=${prach_pucch_f1_params}
	${pm_periods}=    GnbCounter.Wait for next pm period   interval=${pm_interval_8021}

    Uplink Interference And Noise Measurement    pcap_filename=PRACH_AND_PUCCH
    GnbCounter.Wait for next pm period   interval=${pm_interval_8021}

    ${counters}=    Generate Counters String
    ...    first_counter=${first_counter_set_8021}
    ...    last_counter=${last_counter_set_8021}

    ${counter_dict}=    Get Counters    counter_ids=${counters}
    ${cell_list}=    gnbcell.Get All Cells ID
    ${bts_id}=       gnbcell.Get Global BTS ID

    ${counters_dict_for_cell1}=    Find PM Counters For Cell   ${counter_dict}   ${cell_id_8021_1}   ${pm_periods}
    ${prbs_prach_pucch_f1_cell1}=   Get PRBs From Dict   ${counters_dict_for_cell1}   cell1
    Set Global Variable   ${prbs_prach_pucch_f1_cell1}

    ${counters_dict_for_cell2}=    Find PM Counters For Cell   ${counter_dict}   ${cell_id_8021_2}   ${pm_periods}
    ${prbs_prach_pucch_f1_cell2}=   Get PRBs From Dict   ${counters_dict_for_cell2}   cell2
    Set Global Variable   ${prbs_prach_pucch_f1_cell2}

    ${prbs_prach_pucch_f1_l1l2}=    Get PRB Values For PUSCH
    ...    pcap_file=${LOG_PATH}/CB008021_PRACH_AND_PUCCH_L1L2.pcap
    Set Global Variable   ${prbs_prach_pucch_f1_l1l2}

    ${rssi_prach_pucch_f1}=    Get RSSI
    ...    pcap_file=${LOG_PATH}/CB008021_PRACH_AND_PUCCH_L1L2.pcap
    Set Global Variable   ${rssi_prach_pucch_f1}

    ${sinr_prach_pucch_f1}=    Get SINR
    ...    pcap_file=${LOG_PATH}/CB008021_PRACH_AND_PUCCH_L1L2.pcap
    Set Global Variable   ${sinr_prach_pucch_f1}


UL_INTERFERENCE_AND_NOISE_MEASUREMENT_PRACH_PUCCH_F1_ADDITIONAL_COUNTERS
    [Documentation]   Setup for CB008021 testcases using PRACH and PUCCH F1 measurement
	check_preconditions_8021_A1
	${pm_periods}=    GnbCounter.Wait for next pm period   interval=${pm_interval_8021}

    Uplink Interference And Noise Measurement    pcap_filename=PRACH_AND_PUCCH
    GnbCounter.Wait for next pm period   interval=${pm_interval_8021}

    ${counters}=    Generate Counters String
    ...    first_counter=${first_counter_set_8021}
    ...    last_counter=${last_counter_set_8021}

    ${counters_2}=    Generate Counters String
    ...    first_counter=${first_counter_set_8021_range2}
    ...    last_counter=${last_counter_set_8021_range2}

    ${counter_dict}=    Get Counters    counter_ids=${counters}
    ${counter_dict_2}=  Get Counters    counter_ids=${counters_2}
    ${cell_list}=    gnbcell.Get All Cells ID
    ${bts_id}=       gnbcell.Get Global BTS ID

    ${counters_dict_for_cell1}=    Find PM Counters For Cell   ${counter_dict}   ${cell_id_8021_1}   ${pm_periods}
    ${prbs_prach_pucch_f1_cell1}=   Get PRBs From Dict   ${counters_dict_for_cell1}   cell1
    Set Global Variable   ${prbs_prach_pucch_f1_cell1}

    ${counters_dict_for_cell2}=    Find PM Counters For Cell   ${counter_dict}   ${cell_id_8021_2}   ${pm_periods}
    ${prbs_prach_pucch_f1_cell2}=   Get PRBs From Dict   ${counters_dict_for_cell2}   cell2
    Set Global Variable   ${prbs_prach_pucch_f1_cell2}

    ${counters_dict_for_cell1_range2}=    Find PM Counters For Cell   ${counter_dict_2}   ${cell_id_8021_1}   ${pm_periods}
    ${prbs_prach_pucch_f1_cell1_range2}=   Get PRBs From Dict   ${counters_dict_for_cell1_range2}   cell1_range2
    Set Global Variable   ${prbs_prach_pucch_f1_cell1_range2}

    ${counters_dict_for_cell2_range2}=    Find PM Counters For Cell   ${counter_dict_2}   ${cell_id_8021_2}   ${pm_periods}
    ${prbs_prach_pucch_f1_cell2_range2}=   Get PRBs From Dict   ${counters_dict_for_cell2_range2}   cell2_range2
    Set Global Variable   ${prbs_prach_pucch_f1_cell2_range2}

    ${prbs_prach_pucch_f1_l1l2}=    Get PRB Values For PUSCH
    ...    pcap_file=${LOG_PATH}/CB008021_PRACH_AND_PUCCH_L1L2.pcap
    Set Global Variable   ${prbs_prach_pucch_f1_l1l2}

    ${rssi_prach_pucch_f1}=    Get RSSI
    ...    pcap_file=${LOG_PATH}/CB008021_PRACH_AND_PUCCH_L1L2.pcap
    Set Global Variable   ${rssi_prach_pucch_f1}

    ${sinr_prach_pucch_f1}=    Get SINR
    ...    pcap_file=${LOG_PATH}/CB008021_PRACH_AND_PUCCH_L1L2.pcap
    Set Global Variable   ${sinr_prach_pucch_f1}


CB008021-A_1_FDD_Activation_PM_Counters_for_UL_interference_and_noise_measurements_for_1_enabledWithPRACH_PUCCH_F1
    [Documentation]   This testcase is checking PM counters collection for uplink interference
     ...              and noise measurements for PRACH and PUCCH channel
    Check PRBs    prbs=${prbs_prach_pucch_f1_cell1}
    Check PRBs    prbs=${prbs_prach_pucch_f1_cell2}
    Check If L1l2 Prbs And Counter Prbs Values Are In Range With Additional Counters
     ...   ${prbs_prach_pucch_f1_cell1}
     ...   ${prbs_prach_pucch_f1_cell2}
     ...   ${prbs_prach_pucch_f1_cell1_range2}
     ...   ${prbs_prach_pucch_f1_cell2_range2}
     ...   ${prbs_prach_pucch_f1_l1l2}


CB008021-A_8_FDD_Activation_of_L1_measurements_for_1_enabledWithPRACH_PUCCH_F1
    [Documentation]   This testcase is checking L1 logs for uplink interference
     ...              and noise measurements for PRACH and PUCCH F1 channel
     Check PRBs    prbs=${prbs_prach_pucch_f1_l1l2}
     Check If Value In Range   ${rssi_prach_pucch_f1}    ${rssi_range_start_8021}    ${rssi_range_end_8021}
     Check If Value In Range   ${sinr_prach_pucch_f1}    ${sinr_range_start_8021}    ${sinr_range_end_8021}

CB008021-A_9_Verification_of_scheduled_PRB_values_for_1_enabledWithPRACH_PUCCH_F1
    [Documentation]   This testcase is checking scheduled PRB values for uplink interference
     ...              and noise measurements for PRACH and PUCCH F1 channel
     Check If L1l2 Prbs And Counter Prbs Values Are In Range With Additional Counters
     ...   ${prbs_prach_pucch_f1_cell1}
     ...   ${prbs_prach_pucch_f1_cell2}
     ...   ${prbs_prach_pucch_f1_cell1_range2}
     ...   ${prbs_prach_pucch_f1_cell2_range2}
     ...   ${prbs_prach_pucch_f1_l1l2}

CB008021-A_17_Verification_of_ghost_preambles_DTX_or_DTXes_during_regular_UL_transmission_for_1_enabledWithPRACH_PUCCH_F1
    [Documentation]   This user scenario aims at verification of counter requirements related
     ...              to verification of DTX transmission, when the gNB expects that UL transmission
     ...              from the UE shall happen, but nothing is received (with PRACH AND PUCCH_F1).
     Get Peak Metric
     ...    pcap_file=${LOG_PATH}/CB008021_PRACH_AND_PUCCH_L1L2.pcap


UL_INTERFERENCE_AND_NOISE_MEASUREMENT_WITHOUT_PRACH
    [Documentation]   Setup for CB008021 testcases using interference measurement without PRACH
    Setup and check preconditions in scf   params_to_check=${without_prach_params}

    ${pm_periods}=    GnbCounter.Wait for next pm period   interval=${pm_interval_8021}
    Uplink Interference And Noise Measurement    pcap_filename=WITHOUT_PRACH
    GnbCounter.Wait for next pm period   interval=${pm_interval_8021}

    ${counters}=    Generate Counters String
    ...    first_counter=${first_counter_set_8021}
    ...    last_counter=${last_counter_set_8021}

    ${counter_dict}=    Get Counters    counter_ids=${counters}
    ${cell_list}=    gnbcell.Get All Cells ID
    ${bts_id}=       gnbcell.Get Global BTS ID

    ${counters_dict_for_cell1}=    Find PM Counters For Cell   ${counter_dict}   ${cell_id_8021_1}   ${pm_periods}
    ${prbs_without_prach_cell1}=   Get PRBs From Dict   ${counters_dict_for_cell1}   cell1
    Set Global Variable   ${prbs_without_prach_cell1}

    ${counters_dict_for_cell2}=    Find PM Counters For Cell   ${counter_dict}   ${cell_id_8021_2}   ${pm_periods}
    ${prbs_without_prach_cell2}=   Get PRBs From Dict   ${counters_dict_for_cell2}   cell2
    Set Global Variable   ${prbs_without_prach_cell2}

    ${prbs_without_prach_l1l2}=    Get PRB Values For PUSCH
    ...    pcap_file=${LOG_PATH}/CB008021_WITHOUT_PRACH_L1L2.pcap
    Set Global Variable   ${prbs_without_prach_l1l2}

    ${rssi_without_prach}=    Get RSSI
    ...    pcap_file=${LOG_PATH}/CB008021_WITHOUT_PRACH_L1L2.pcap
    Set Global Variable   ${rssi_without_prach}

    ${sinr_without_prach}=    Get SINR
    ...    pcap_file=${LOG_PATH}/CB008021_WITHOUT_PRACH_L1L2.pcap
    Set Global Variable   ${sinr_without_prach}

CB008021-A_2_FDD_Activation_PM_Counters_for_UL_interference_and_noise_measurements_for_2_enabledWithoutPRACH
    [Documentation]   This testcase is checking PM counters collection for uplink interference
     ...              and noise measurements without PRACH channel
    Check PRBs    prbs=${prbs_without_prach_cell1}
    Check PRBs    prbs=${prbs_without_prach_cell2}

CB008021-A_6_FDD_Activation_of_L1_measurements_for_2_enabledWithoutPRACH
    [Documentation]   This testcase is checking L1 logs for uplink interference
     ...              and noise measurements without PRACH channel
     Check PRBs    prbs=${prbs_without_prach_l1l2}
     Check If Value In Range   ${rssi_without_prach}    ${rssi_range_start_8021}    ${rssi_range_end_8021}
     Check If Value In Range   ${sinr_without_prach}    ${sinr_range_start_8021}    ${sinr_range_end_8021}

CB008021-A_10_Verification_of_scheduled_PRB_values_for_2_enabledWithoutPRACH
    [Documentation]   This testcase is checking scheduled PRB values for uplink interference
     ...              and noise measurements without PRACH channel
     Check If L1L2 PRBs And Counter PRBs Values Are In Range
     ...   ${prbs_prach_pucch_f1_cell1}
     ...   ${prbs_prach_pucch_f1_cell2}
     ...   ${prbs_prach_pucch_f1_l1l2}

CB008021-A_18_Verification_of_ghost_preambles_DTX_or_DTXes_during_regular_UL_transmission_for_2_enabledWithoutPRACH
    [Documentation]   This user scenario aims at verification of counter requirements related
     ...              to verification of DTX transmission, when the gNB expects that UL transmission
     ...              from the UE shall happen, but nothing is received (without PRACH channel).
     Get Peak Metric
     ...    pcap_file=${LOG_PATH}/CB008021_WITHOUT_PRACH_L1L2.pcap


UL_INTERFERENCE_AND_NOISE_MEASUREMENT_WITHOUT_PUCCH
    [Documentation]   Setup for CB008021 testcases using interference measurement without PUCCH
    Setup and check preconditions in scf   params_to_check=${without_pucch_params}

    ${pm_periods}=    GnbCounter.Wait for next pm period   interval=${pm_interval_8021}
    Uplink Interference And Noise Measurement    pcap_filename=WITHOUT_PUCCH
    GnbCounter.Wait for next pm period   interval=${pm_interval_8021}

    ${counters}=    Generate Counters String
    ...    first_counter=${first_counter_set_8021}
    ...    last_counter=${last_counter_set_8021}

    ${counter_dict}=    Get Counters    counter_ids=${counters}
    ${cell_list}=    gnbcell.Get All Cells ID
    ${bts_id}=       gnbcell.Get Global BTS ID

    ${counters_dict_for_cell1}=    Find PM Counters For Cell   ${counter_dict}   ${cell_id_8021_1}   ${pm_periods}
    ${prbs_without_pucch_cell1}=   Get PRBs From Dict   ${counters_dict_for_cell1}   cell1
    Set Global Variable   ${prbs_without_pucch_cell1}

    ${counters_dict_for_cell2}=    Find PM Counters For Cell   ${counter_dict}   ${cell_id_8021_2}   ${pm_periods}
    ${prbs_without_pucch_cell2}=   Get PRBs From Dict   ${counters_dict_for_cell2}   cell2
    Set Global Variable   ${prbs_without_pucch_cell2}

    ${prbs_without_pucch_l1l2}=    Get PRB Values For PUSCH
    ...    pcap_file=${LOG_PATH}/CB008021_WITHOUT_PUCCH_L1L2.pcap
    Set Global Variable   ${prbs_without_pucch_l1l2}

    ${rssi_without_pucch}=    Get RSSI
    ...    pcap_file=${LOG_PATH}/CB008021_WITHOUT_PUCCH_L1L2.pcap
    Set Global Variable   ${rssi_without_pucch}

    ${sinr_without_pucch}=    Get SINR
    ...    pcap_file=${LOG_PATH}/CB008021_WITHOUT_PUCCH_L1L2.pcap
    Set Global Variable   ${sinr_without_pucch}

CB008021-A_3_FDD_Activation_PM_Counters_for_UL_interference_and_noise_measurements_for_3_enabledWithoutPUCCH_F1
    [Documentation]   This testcase is checking PM counters collection for uplink interference
     ...              and noise measurements without PUCCH channel
    Check PRBs    prbs=${prbs_without_pucch_cell1}
    Check PRBs    prbs=${prbs_without_pucch_cell2}

CB008021-A_5_FDD_Activation_of_L1_measurements_for_3_enabledWithoutPUCCH_F1
    [Documentation]   This testcase is checking L1 logs for uplink interference
     ...              and noise measurements for PUCCH channel
     Check PRBs    prbs=${prbs_without_pucch_l1l2}
     Check If Value In Range   ${rssi_without_pucch}    ${rssi_range_start_8021}    ${rssi_range_end_8021}
     Check If Value In Range   ${sinr_without_pucch}    ${sinr_range_start_8021}    ${sinr_range_end_8021}

CB008021-A_11_Verification_of_scheduled_PRB_values_for_3_enabledWithoutPUCCH_F1
    [Documentation]   This testcase is checking scheduled PRB values for uplink interference
     ...              and noise measurements without PUCCH channel
     Check If L1L2 PRBs And Counter PRBs Values Are In Range
     ...   ${prbs_prach_pucch_f1_cell1}
     ...   ${prbs_prach_pucch_f1_cell2}
     ...   ${prbs_prach_pucch_f1_l1l2}

CB008021-A_19_Verification_of_ghost_preambles_DTX_or_DTXes_during_regular_UL_transmission_for_3_enabledWithoutPUCCH_F1
    [Documentation]   This user scenario aims at verification of counter requirements related
     ...              to verification of DTX transmission, when the gNB expects that UL transmission
     ...              from the UE shall happen, but nothing is received (without PUCCH channel).
     Get Peak Metric
     ...    pcap_file=${LOG_PATH}/CB008021_WITHOUT_PUCCH_L1L2.pcap


UL_INTERFERENCE_AND_NOISE_MEASUREMENT_WITHOUT_PUCCH_AND_PRACH
    [Documentation]   Setup for CB008021 testcases using interference measurement without PUCCH and PRACH
    check_preconditions_8021_A4
    ${pm_periods}=    GnbCounter.Wait for next pm period   interval=${pm_interval_8021}
    Uplink Interference And Noise Measurement    pcap_filename=WITHOUT_PUCCH_AND_PRACH
    GnbCounter.Wait for next pm period   interval=${pm_interval_8021}

    ${counters}=    Generate Counters String
    ...    first_counter=${first_counter_set_8021}
    ...    last_counter=${last_counter_set_8021}

    ${counter_dict}=    Get Counters    counter_ids=${counters}
    ${cell_list}=    gnbcell.Get All Cells ID
    ${bts_id}=       gnbcell.Get Global BTS ID

    ${counters_dict_for_cell1}=    Find PM Counters For Cell   ${counter_dict}   ${cell_id_8021_1}   ${pm_periods}
    ${prbs_without_pucch_and_prach_cell1}=   Get PRBs From Dict   ${counters_dict_for_cell1}   cell1
    Set Global Variable   ${prbs_without_pucch_and_prach_cell1}

    ${counters_dict_for_cell2}=    Find PM Counters For Cell   ${counter_dict}   ${cell_id_8021_2}   ${pm_periods}
    ${prbs_without_pucch_and_prach_cell2}=   Get PRBs From Dict   ${counters_dict_for_cell2}   cell2
    Set Global Variable   ${prbs_without_pucch_and_prach_cell2}

    ${prbs_without_pucch_and_prach_l1l2}=    Get PRB Values For PUSCH
    ...    pcap_file=${LOG_PATH}/CB008021_WITHOUT_PUCCH_AND_PRACH_L1L2.pcap
    Set Global Variable   ${prbs_without_pucch_and_prach_l1l2}

    ${rssi_without_pucch_and_prach}=    Get RSSI
    ...    pcap_file=${LOG_PATH}/CB008021_WITHOUT_PUCCH_AND_PRACH_L1L2.pcap
    Set Global Variable   ${rssi_without_pucch_and_prach}

    ${sinr_without_pucch_and_prach}=    Get SINR
    ...    pcap_file=${LOG_PATH}/CB008021_WITHOUT_PUCCH_AND_PRACH_L1L2.pcap
    Set Global Variable   ${sinr_without_pucch_and_prach}

CB008021-A_4_FDD_Activation_PM_Counters_for_UL_interference_and_noise_measurements_for_4_enabledWithoutPRACH_PUCCH_F1
    [Documentation]   This testcase is checking PM counters collection for uplink interference
     ...              and noise measurements without PRACH and PUCCH channel
    Check PRBs    prbs=${prbs_without_pucch_and_prach_cell1}
    Check PRBs    prbs=${prbs_without_pucch_and_prach_cell2}

CB008021-A_7_FDD_Activation_of_L1_measurements_for_4_enabledWithoutPRACH_PUCCH_F1
    [Documentation]   This testcase is checking L1 logs for uplink interference
     ...              and noise measurements with PRACH and PUCCH channel disabled
    Check PRBs    prbs=${prbs_without_pucch_and_prach_l1l2}
    Check If Value In Range   ${rssi_without_pucch_and_prach}    ${rssi_range_start_8021}    ${rssi_range_end_8021}
    Check If Value In Range   ${sinr_without_pucch_and_prach}    ${sinr_range_start_8021}    ${sinr_range_end_8021}

CB008021-A_12_Verification_of_scheduled_PRB_values_for_4_enabledWithoutPRACH_PUCCH_F1
    [Documentation]   This testcase is checking scheduled PRB values for uplink interference
     ...              and noise measurements with PRACH and PUCCH channel disabled
     Check If L1L2 PRBs And Counter PRBs Values Are In Range
     ...   ${prbs_prach_pucch_f1_cell1}
     ...   ${prbs_prach_pucch_f1_cell2}
     ...   ${prbs_prach_pucch_f1_l1l2}

CB008021-A_20_Verification_of_ghost_preambles_DTX_or_DTXes_during_regular_UL_transmission_for_4_enabledWithoutPRACH_PUCCH_F1
    [Documentation]   This user scenario aims at verification of counter requirements related
     ...              to verification of DTX transmission, when the gNB expects that UL transmission
     ...              from the UE shall happen, but nothing is received (without PRACH and PUCCH F1).
     Get Peak Metric
     ...    pcap_file=${LOG_PATH}/CB008021_WITHOUT_PUCCH_AND_PRACH_L1L2.pcap

CB008021_scf_revert
     Setup and check preconditions in scf   params_to_check=${prach_pucch_f1_params_revert}

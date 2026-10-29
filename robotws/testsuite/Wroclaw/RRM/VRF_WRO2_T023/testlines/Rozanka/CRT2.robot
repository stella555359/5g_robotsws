*** Settings ***
Documentation
...   contact: Szymon Startek

Library     taf.sw.reporting_portal
Library     taf.sw.scout  WITH NAME  scout
Library     taf.analyzer.pmcounter
Resource    ../../feature_resources/CB008392/CB008392_A_4TX_Switch_Off_TX_Paths_Verification.robot
Resource    ../../feature_resources/CB007813/CB007813_5G_A_Intra_gNB_inter_freq_HO_10DL10UL_30DL10UL_SA.robot
Resource    ../../feature_resources/CB008911/CB008911__PCMD_records_during_CA_call_SA_3CC_DL.robot
Resource    ../../feature_resources/LTE4750/IWK__LTE_DL_dss_counters__LTE4750.robot
Resource    ../../feature_resources/CB010823/CB010823_CP41_Run_Diagnostic_check_from_WebEM.robot
Resource    ../../feature_resources/CB008541/RRM__CA_SCell_Small_Bwp_Power_Saving_BWP__CB008541-5G-B.robot
Resource    ../../feature_resources/CB011036_CB011037/CB011037_LTE_DSS_cell_TX_paths_switching_off_on_when_LTE1103_and_LTE1203_are_activated.robot
Resource    ../../feature_resources/CB011036_CB011037/CB011036_CB011037_DSS_cells_switch_off_due_to_energy_saving_interaction_with_CB007777.robot
Resource    ../../feature_resources/CB005788_CB010796/CB005788_SR_A_Counters.robot
Resource    ../../feature_resources/CB009237_CB009238/CB009237_CB009238_Multi_UE_NR_DL_data_transfer__high_PDCCH_load_with_low_LTE_load.robot
Resource    ../../feature_resources/CB014612/CB014612_A_eCPRI_UL_scaling_change_for_RF_71_scs_30kHz.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T023/resources/ca_IWK.robot
Resource    ../../resources/attenuator.robot
Variables   testsuite/Wroclaw/RRM/VRF_WRO2_T023/testlines/Rozanka/resources/scenario.py


Suite Setup       CRT2 Suite Setup


*** Variables ***
${CB008392_ACTIVATION_CHECKED}    False                 # Boolean value determining if it was verified whether CB008392 is active.
# Default value: False
${ENERGY_SAVING_ON}               False                 # Boolean value determining if CB008392 is turned on by checking
# if actNrLBRTXPowerSaving=true. Default value: False
${FATAL_ERR}                      False                 # Boolean value determining if execution should be stopped if any test failed.
# Default value: False
${SCOUT_TL_NAME}                  10_16_MRBTS-6104      # Name of TL from SCOUT
${USE_SCOUT_INTERNAL_ID}          False                 # Parameter for 'Request SCF' keyword from taf.sw.scout library


*** Keywords ***
CRT2 Suite Setup
    Log To Console   Common Suite Setup
    Load Attenuation Config And Require Attenuator Setup    ${ABSTRACT_LIB_CONFIG}
    Set Suite Variable  ${CLOUD}                        True

    &{qrxlevmin_lte4750} =  Create Dictionary
    ...  MRBTS-6104/NRBTS-6104/NRCELL-8=-22
    ...  MRBTS-6104/NRBTS-6104/NRCELL-9=-22
    ...  MRBTS-6104/NRBTS-6104/NRCELL-2=-50
    Set Suite Variable  &{QRXLEVMIN_LTE4750}  &{qrxlevmin_lte4750}
    &{qrxlevmin_cb008392} =  Create Dictionary
    ...  MRBTS-6104/NRBTS-6104/NRCELL-8=-50
    ...  MRBTS-6104/NRBTS-6104/NRCELL-9=-50
    ...  MRBTS-6104/NRBTS-6104/NRCELL-2=-22
    Set Suite Variable  &{QRXLEVMIN_CB008392}  &{qrxlevmin_cb008392}
    &{qrxlevmin_cb011036_cb011037} =  Create Dictionary
    ...  MRBTS-6104/NRBTS-6104/NRCELL-8=-50
    ...  MRBTS-6104/NRBTS-6104/NRCELL-9=-22
    ...  MRBTS-6104/NRBTS-6104/NRCELL-2=-22
    Set Suite Variable  &{QRXLEVMIN_CB011036_CB011037}  &{qrxlevmin_cb011036_cb011037}
    &{qrxlevmin_cb007813} =  Create Dictionary
    ...  MRBTS-6104/NRBTS-6104/NRCELL-5=-50
    Set Suite Variable  &{QRXLEVMIN_CB007813}  &{qrxlevmin_cb007813}


Save Original qRxLevMin Values
    &{original_qrxlevmin_values} =  Get qRxLevMin Values of NR Cells  connection=gNB
    Set Test Variable  &{ORIGINAL_QRXLEVMIN_VALUES}  &{original_qrxlevmin_values}


Attenuator Teardown
    Log To Console   Attenuator Teardown
    Set Attenuation For All Cells  100%


*** Test Cases ***
CB008392_A_4TX_Switch_Off_TX_Paths_Verification
    [Setup]  Run Keywords
    ...  Add Configuration ID to Reporting Portal Report
    ...  scout_testline_name=${SCOUT_TL_NAME}
    ...  AND  Set Library Search Order  CB008392_A_4TX_Switch_Off_TX_Paths_Verification  admin
    ...  AND  Run Keyword If  ${CB008392_ACTIVATION_CHECKED} and not ${ENERGY_SAVING_ON}
    ...  Fail  msg=Test not started. Feature CB008392 was checked in previous test and is not active.
    ...  AND  Set Test Variable  ${NR_CELL_ID1}  8
    ...  AND  Set Test Variable  ${NR_CELL_ID2}  9
    ...  AND  Set Test Variable  ${POWER_GROUP_ID1}  1
    ...  AND  Set Test Variable  ${POWER_GROUP_ID2}  2
    ...  AND  Set Test Variable  ${NR_UE_CAPABILITY1}  NOKIA_UE_B1
    ...  AND  Set Test Variable  ${NR_UE_CAPABILITY2}  NOKIA_UE_B3
    ...  AND  Set Test Variable  ${TPUT_ABOVE_MIN_LOAD}  50 Mbits/sec
    ...  AND  Set Test Variable  ${TPUT_BELOW_MIN_LOAD}  5 Mbits/sec
    ...  AND  TC Setup
    ...  AND  Save Original qRxLevMin Values
    ...  AND  Set qRxLevMin Values of NR Cells  ${QRXLEVMIN_CB008392}  connection=gNB
    Run keyword  TC__${TEST_NAME}
    Map Testcase  [1][1.0] RRM__4TX_Switch_Off_TX_Paths_Verification__CB008392
    [Teardown]  Run Keywords
    ...  Set qRxLevMin Values of NR Cells  ${ORIGINAL_QRXLEVMIN_VALUES}  connection=gNB
    ...  AND  TC Teardown
    ...  AND  Attenuator Teardown
    ...  AND  Run Keyword If  ${FATAL_ERR}  Run Keyword If Test Failed  Fatal Error


CB007813_5G_A_Intra_gNB_inter_freq_HO_10DL10UL_30DL10UL_SA
    [Setup]  Run Keywords
    ...  Add Configuration ID to Reporting Portal Report
    ...  scout_testline_name=${SCOUT_TL_NAME}
    ...  AND  Set Library Search Order  CB007813_5G_A_Intra_gNB_inter_freq_HO_10DL10UL_30DL10UL_SA
    ...  AND  Set Test Variable  ${NR_CELL_ID}                5
    ...  AND  Set Test Variable  ${ASYMM_CELL_ATTEN_ALIAS}    GNB_CELL_5
    ...  AND  Set Test Variable  ${SYMM_CELL_ATTEN_ALIAS}     GNB_CELL_6
    ...  AND  Set Test Variable  ${CAPABILITY_NR_UE}          QUALCOMM_UE
    ...  AND  Set Test Variable  ${NR_CALL_CELL_ID}           100007941
    ...  AND  Set Test Variable  ${GNB_ID}                    6104
    ...  AND  Set Test Variable  ${LARGE_BWP_COUNTER}         M55139C02502
    ...  AND  Set Test Variable  ${UE_ALIAS}                  UE_FOR_TA
    ...  AND  Set Test Variable  ${TEST_SPECIFIC_COUNTER_INTERVAL}    5
    ...  AND  TC Setup
    ...  AND  Save Original qRxLevMin Values
    ...  AND  Set qRxLevMin Values of NR Cells  ${QRXLEVMIN_CB007813}  connection=gNB
    Run keyword  TC__${TEST_NAME}
    Map Testcase  [1][1.0] CB007813-5G-A_Intra_gNB_inter_freq_HO_10DL10UL_30DL10UL_SA
    [Teardown]  Run Keywords
    ...  Set qRxLevMin Values of NR Cells  ${ORIGINAL_QRXLEVMIN_VALUES}  connection=gNB
    ...  AND  TC Teardown
    ...  AND  Attenuator Teardown
    ...  AND  Run Keyword If  ${FATAL_ERR}  Run Keyword If Test Failed  Fatal Error


CB008911__PCMD_records_during_CA_call_SA_3CC_DL
    [Setup]  Run Keywords
    ...  Add Configuration ID to Reporting Portal Report
    ...  scout_testline_name=${SCOUT_TL_NAME}
    ...  AND  Set Library Search Order  CB008911__PCMD_records_during_CA_call_SA_3CC_DL
    ...  AND  Set Test Variable  ${NR_PCELL_ID}  1
    ...  AND  Set Test Variable  ${NR_SCELL_ID1}  48
    ...  AND  Set Test Variable  ${NR_SCELL_ID2}  44
    ...  AND  Set Test Variable  ${PCELL_ATTENUATOR_ALIAS}  GNB_CELL_1_FDD_40MHZ
    ...  AND  Set Test Variable  ${SCELL_1_ATTENUATOR_ALIAS}  GNB_CELL_48
    ...  AND  Set Test Variable  ${SCELL_2_ATTENUATOR_ALIAS}  GNB_CELL_44
    ...  AND  Set Test Variable  ${NR_UE_CAPABILITY}  NR_UE_SDX70
    ...  AND  TC Setup
    Run keyword  TC__${TEST_NAME}
    Map Testcase  [1][1.0] ${TEST_NAME}
    [Teardown]  Run Keywords
    ...  TC Teardown
    ...  AND  Attenuator Teardown
    ...  AND  Run Keyword If  ${FATAL_ERR}  Run Keyword If Test Failed  Fatal Error


IWK__LTE_DL_dss_counters__LTE4750
    [Setup]  Run Keywords
    ...  Add Configuration ID to Reporting Portal Report
    ...  scout_testline_name=${SCOUT_TL_NAME}
    ...  AND  Set Library Search Order  IWK__LTE_DL_dss_counters__LTE4750  admin
    ...  AND  Set Test Variable  ${EXP_VAL_C211}        85
    ...  AND  Set Test Variable  ${EXP_VAL_C212}        15
    ...  AND  Set Test Variable  ${LTE_CELL_ID}         2
    ...  AND  Set Test Variable  ${NR_CALL_CELL_ID}     100007938
    ...  AND  Set Test Variable  ${MCC}                 001
    ...  AND  Set Test Variable  ${MNC}                 01
    ...  AND  Set Test Variable  ${LTE_UE_ALIAS}        LTE_LOCKED
    ...  AND  Set Test Variable  ${NR_UE_ALIAS}         NOKIA_UE_B1
    ...  AND  Set Test Variable  ${COUNTER_PERIOD}      15
    ...  AND  TC Setup
    ...  AND  Save Original qRxLevMin Values
    ...  AND  Set qRxLevMin Values of NR Cells  ${QRXLEVMIN_LTE4750}  connection=gNB
    Run keyword  TC__${TEST_NAME}
    Map Testcase  [1][1.0] ${TEST_NAME}
    [Teardown]  Run Keywords
    ...  Set qRxLevMin Values of NR Cells  ${ORIGINAL_QRXLEVMIN_VALUES}  connection=gNB
    ...  AND  TC Teardown
    ...  AND  Attenuator Teardown
    ...  AND  Run Keyword If  ${FATAL_ERR}  Run Keyword If Test Failed  Fatal Error


CB010823_CP41_Run_Diagnostic_check_from_WebEM
    [Setup]  Run Keywords
    ...  Add Configuration ID to Reporting Portal Report
    ...  scout_testline_name=${SCOUT_TL_NAME}
    ...  AND  Set Library Search Order  CB010823_CP41_Run_Diagnostic_check_from_WebEM
    ...  AND  Set Test Variable  ${RMOD_SN}  L1232908043
    ...  AND  TC Setup
    Run keyword  TC__${TEST_NAME}
    Map Testcase  [1][1.0] ${TEST_NAME}
    [Teardown]  Run Keywords
    ...  TC Teardown
    ...  AND  Attenuator Teardown
    ...  AND  Run Keyword If  ${FATAL_ERR}  Run Keyword If Test Failed  Fatal Error


RRM__CA_SCell_Small_Bwp_Power_Saving_BWP__CB008541-5G-B
    [Setup]  Run Keywords
    ...  Add Configuration ID to Reporting Portal Report
    ...  scout_testline_name=${SCOUT_TL_NAME}
    ...  AND  Set Library Search Order  RRM__CA_SCell_Small_Bwp_Power_Saving_BWP__CB008541-5G-B
    ...  AND  Set Test Variable  ${NR_CELL_ID}  48
    ...  AND  Set Test Variable  ${NR_UE_CAPABILITY}  QUALCOMM_UE
    ...  AND  Set Test Variable  ${POWER_SAVING_BWP_ID}    80
    ...  AND  Set Test Variable  ${COUNTER_PERIOD}  5
    ...  AND  Set Test Variable  ${PCELL_ATTENUATOR_ALIAS}  GNB_CELL_48
    ...  AND  Set Test Variable  ${SCELL_ATTENUATOR_ALIAS}  GNB_CELL_1_FDD_40MHZ
    ...  AND  TC Setup
    Run keyword  TC__${TEST_NAME}
    Map Testcase  [1][1.0] RRM__CA_scell_small_bwp_power_saving_bwp__CB008541-5G-B
    [Teardown]  Run Keywords
    ...  TC Teardown
    ...  AND  Attenuator Teardown
    ...  AND  Run Keyword If  ${FATAL_ERR}  Run Keyword If Test Failed  Fatal Error


CB011037_LTE_DSS_cell_TX_paths_switching_off_on_when_LTE1103_and_LTE1203_are_activated
    [Setup]  Run Keywords
    ...  Add Configuration ID to Reporting Portal Report
    ...  scout_testline_name=${SCOUT_TL_NAME}
    ...  AND  Set Library Search Order  CB011037_LTE_DSS_cell_TX_paths_switching_off_on_when_LTE1103_and_LTE1203_are_activated
    ...  AND  Set Test Variable  ${NR_DSS_CELL}  2
    ...  AND  Set Test Variable  ${LTE_DSS_CELL}  2
    ...  AND  Set Test Variable  ${LTE_NON_DSS_CELL}  1
    ...  AND  Set Test Variable  ${NR_POWER_GROUP_ID}  1
    ...  AND  Set Test Variable  ${LTE_UE_CAPABILITY}  LTE_LOCKED
    ...  AND  TC Setup
    Run keyword  TC__${TEST_NAME}
    Map Testcase  [1][1.0] ${TEST_NAME}
    [Teardown]  Run Keywords
    ...  TC Teardown
    ...  AND  Attenuator Teardown
    ...  AND  Run Keyword If  ${FATAL_ERR}  Run Keyword If Test Failed  Fatal Error


CB011036_CB011037_DSS_cells_switch_off_due_to_energy_saving_interaction_with_CB007777
    [Setup]  Run Keywords
    ...  Add Configuration ID to Reporting Portal Report
    ...  scout_testline_name=${SCOUT_TL_NAME}
    ...  AND  Set Library Search Order  CB011036_CB011037_DSS_cells_switch_off_due_to_energy_saving_interaction_with_CB007777
    ...  AND  Set Test Variable  ${NR_DSS_CELL}  2
    ...  AND  Set Test Variable  ${LTE_DSS_CELL}  2
    ...  AND  Set Test Variable  ${LTE_NON_DSS_CELL}  1
    ...  AND  Set Test Variable  ${NR_NON_DSS_CELL}  8
    ...  AND  Set Test Variable  ${NR_POWER_GROUP_ID}  1
    ...  AND  Set Test Variable  ${LTE_POWER_GROUP_ID}  0
    ...  AND  Set Test Variable  ${NR_UE_CAPABILITY}  NOKIA_UE_B1
    ...  AND  Set Test Variable  ${COUNTER_PERIOD}  15
    ...  AND  Set Test Variable  ${NR_CALL_CELL_ID}  100007944
    ...  AND  Set Test Variable  ${RMOD_ID}  2
    ...  AND  Set Test Variable  ${SMOD_ID}  1
    ...  AND  TC Setup
    ...  AND  Save Original qRxLevMin Values
    ...  AND  Set qRxLevMin Values of NR Cells  ${QRXLEVMIN_CB011036_CB011037}  connection=gNB
    Run keyword  TC__${TEST_NAME}
    Map Testcase  [1]${TEST_NAME}
    [Teardown]  Run Keywords
    ...  TC Teardown
    ...  AND  Attenuator Teardown
    ...  AND  Run Keyword If  ${FATAL_ERR}  Run Keyword If Test Failed  Fatal Error


CB005788_SR_A_Counters
    [Setup]  Run Keywords
    ...  Add Configuration ID to Reporting Portal Report
    ...  scout_testline_name=${SCOUT_TL_NAME}
    ...  AND  Set Library Search Order  CB005788_SR_A_Counters
    ...  AND  Set Test Variable  ${NR_CELL_ID}                 10
    ...  AND  Set Test Variable  ${CAPABILITY_NR_UE}           REAL_ANDROID_UE
    ...  AND  Set Test Variable  ${NR_CALL_CELL_ID}            100007946
    ...  AND  Set Test Variable  ${RMOD_ID}                    6
    ...  AND  Set Test Variable  ${BBMODULE_ADRESS}            0x1018
    ...  AND  Set Test Variable  ${RMOD_IP}                    172.22.50.2
    ...  AND  Set Test Variable  ${RU_INDEX}                   4
    ...  AND  Set Test Variable  ${ON_THRESHOLD}                75
    ...  AND  Set Test Variable  ${OFF_THRESHOLD}               72
    ...  AND  Set Test Variable  ${BLANK_TIMER}                60
    ...  AND  Set Test Variable  ${COUNTER_PERIOD}             15
    ...  AND  Set Test Variable  ${REVERT_CHANGES}             False
    ...  AND  TC Setup
    Run keyword  TC__${TEST_NAME}
    Map Testcase  [1][2.0] CNI-119369_parameters_and_counters_hidden_or_deleted_check
    [Teardown]  Run Keywords
    ...  TC Teardown
    ...  AND  Attenuator Teardown
    ...  AND  Run Keyword If  ${FATAL_ERR}  Run Keyword If Test Failed  Fatal Error


CB009237_CB009238_Multi_UE_NR_DL_data_transfer__high_PDCCH_load_with_low_LTE_load
    [Setup]  Run Keywords
    ...  Add Configuration ID to Reporting Portal Report
    ...  scout_testline_name=${SCOUT_TL_NAME}
    ...  AND  Set Library Search Order  CB009237_CB009238_Multi_UE_NR_DL_data_transfer__high_PDCCH_load_with_low_LTE_load
    ...  AND  Set Test Variable  ${NR_DSS_CELL}  2
    ...  AND  Set Test Variable  ${LTE_DSS_CELL}  2
    ...  AND  Set Test Variable  ${LTE_UE_ALIAS}  LTE_LOCKED
    ...  AND  Set Test Variable  ${NR_UE1_ALIAS}  NOKIA_UE_B1
    ...  AND  Set Test Variable  ${NR_UE2_ALIAS}  NR_UE_SDX70
    ...  AND  Set Test Variable  ${NR_UE3_ALIAS}  NOKIA_UE_B1_TWO
    ...  AND  Set Test Variable  ${NR_UE4_ALIAS}  NOKIA_UE_B1_THREE
    ...  AND  TC Setup
    Run keyword  TC__${TEST_NAME}
    Map Testcase  [1][1.0] ${TEST_NAME}
    [Teardown]  Run Keywords
    ...  TC Teardown
    ...  AND  Attenuator Teardown
    ...  AND  Run Keyword If  ${FATAL_ERR}  Run Keyword If Test Failed  Fatal Error


CB014612_A_eCPRI_UL_scaling_change_for_RF_71_scs_30kHz
    [Setup]  Run Keywords
    ...  Add Configuration ID to Reporting Portal Report
    ...  scout_testline_name=${SCOUT_TL_NAME}
    ...  AND  Set Library Search Order  CB014612_A_eCPRI_UL_scaling_change_for_RF_71_scs_30kHz
    ...  AND  Set Test Variable  ${RMOD_SN}  L1232908043
    ...  AND  TC Setup
    TC__CB014612_A_eCPRI_UL_scaling_change_for_RF_71_scs_30kHz
    Map Testcase  [1][1.0] CB014612_A_eCPRI_UL_scaling_change_for_RF_71_scs_30kHz
    [Teardown]  Run Keywords
    ...  TC Teardown
    ...  AND  Run Keyword If  ${FATAL_ERR}  Run Keyword If Test Failed  Fatal Error

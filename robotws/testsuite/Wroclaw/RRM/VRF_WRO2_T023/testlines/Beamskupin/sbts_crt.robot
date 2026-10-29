*** Settings ***
Documentation
...  contact: Szymon Startek

Force Tags        QCD_MN_RAN    QCP_RAN_ST    CRT
Library     taf.sw.reporting_portal
Library     taf.sw.scout  WITH NAME  scout
Resource    ../../feature_resources/CB008133/CB008133_B_interworking_with_5GC001991.robot
Resource    ../../feature_resources/CB008133/CB008133_A_View_Power_Saving_Performance_Management_Counters.robot
Resource    ../../feature_resources/CB008940/CB008940_F4_POST_Interaction_CB008392_Cell_TX_Path_Switch_On_List.robot
Resource    ../../feature_resources/CB008940/CB008940_F5_POST_Interaction_CB008392_Cell_TX_Path_Switch_Off_List.robot
Resource    ../../feature_resources/CB008745/CB008745__LTE_TX_patch_switch_on_off_TL_Beamskupin.robot
Resource    ../../feature_resources/CB008745/CB008745__NR_cell_switch_on_off_TL_Beamskupin.robot
Resource    ../../feature_resources/CB008127/CB008127-E_B1_Selection_of_measurement_profile_based_on_PLMN_NSSAI_slice.robot
Resource    ../../feature_resources/CB008127/CB008127-G_B2_Successful_configuration_of_A2_and_intra-freq_A3_A5_during_SgNBAdditionReq.robot
Resource    ../../feature_resources/CB008127/CB008127-F_B5_Successful_configuration_of_intra-freq_A2_A3_A5_using_meas_profiles_upon_setup_VoNR.robot
Resource    ../../feature_resources/CB008224/CB008224_C_SDL_SCell_Swap_-_SDL_To_SDL_SCell_SA.robot
Resource    ../../feature_resources/CB009919/RRM__Interaction_with_CRG__CB009919-B.robot
Resource    ../../feature_resources/CB009919/RRM__Interaction_with_LTE907_TTI_Bundling__CB009919-B.robot
Resource    ../../feature_resources/CB009919/RRM__UL_256QAM_support_with_channel_quality_monitoring_enabled__CB009919-B.robot
Variables   ../Beamskupin/resources/scenario.py
Resource    ../../resources/attenuator.robot

*** Variables ***
${FATAL_ERR}                      False                # Boolean value determining if execution should be stopped if any test failed.
# Default value: False
${SCOUT_TL_NAME}                  10_16_MRBTS-55014    # Name of TL from SCOUT
${CLOUD}                          False                # Variable ${CLOUD} (bool) should be globally set to either 'True' or 'False'
                                                       # depending on whether the line is in the cloud or not.


*** Keywords ***
Attenuator Setup
    Log To Console   Attenuator Setup
    Load Attenuation Config And Require Attenuator Setup  ${ABSTRACT_LIB_CONFIG}


Attenuator Teardown
    Log To Console   Attenuator Teardown
    Set Attenuation For All Cells  100%


Set qrxlevmin Level
    [Arguments]   ${cell_DN}    ${value}    ${technology}
    [Teardown]  admin.Teardown Admin  connection=qrx_change
    Log To Console  Setting qrxlevmin on ${cell_DN} at ${value}dB
    admin.Setup Admin  alias=qrx_change
    Run Keyword If  '${technology}'=='NR'
    ...    admin.Perform Parameter Recommissioning  ${cell_DN}  qRxLevMin  update
    ...    ${value}  connection=qrx_change
    Run Keyword If  '${technology}'=='LTE'
    ...    admin.Perform Parameter Recommissioning  ${cell_DN}  qrxlevmin  update
    ...    ${value}  connection=qrx_change




*** Test Cases ***
CB008745__NR_cell_switch_on_off
    [Setup]  Run keywords
    ...  Attenuator Setup
    ...  AND  Add Configuration ID to Reporting Portal Report
    ...  scout_testline_name=${SCOUT_TL_NAME}
    ...  AND  Set Library Search Order  CB008745__NR_cell_switch_on_off_TL_Beamskupin
    ...  AND  Set Test Variable  ${LTE_CELL_ID}  83
    ...  AND  Set Test Variable  ${NR_CELL_ID1}  0
    ...  AND  Set Test Variable  ${NR_CELL_ID2}  5
    ...  AND  Set Test Variable  ${POWER_GROUP_ID}  2
    ...  AND  Set Test Variable  ${NR_CELL_ID1_AVG_DL_THROUGHPUT}  300
    ...  AND  Set Test Variable  ${NR_CELL_ID2_AVG_DL_THROUGHPUT}  750
    ...  AND  Set Test Variable  ${NSA_UE_CAPABILITY}  NSA_n78_n77_B1
    ...  AND  Set Test Variable  ${APN}  n26wro
    ...  AND  TC Setup
    TC__CB008745__NR_cell_switch_on_off
    [Teardown]  Run Keywords
    ...       TC Teardown
    ...  AND  Attenuator Teardown
    ...  AND  Run Keyword If  ${FATAL_ERR}  Run Keyword If Test Failed  Fatal Error


CB008745__LTE_TX_patch_switch_on_off
    [Setup]  Run keywords
    ...  Attenuator Setup
    ...  AND  Add Configuration ID to Reporting Portal Report
    ...  scout_testline_name=${SCOUT_TL_NAME}
    ...  AND  Set Library Search Order  CB008745__LTE_TX_patch_switch_on_off_TL_Beamskupin
    ...  AND  Set Test Variable  ${LTE_CELL_ID}  83
    ...  AND  Set Test Variable  ${POWER_GROUP_ID}  0
    ...  AND  Set Test Variable  ${LTE_MIMO_2x2_DL_THROUGHPUT}  95
    ...  AND  Set Test Variable  ${LTE_MIMO_4x4_DL_THROUGHPUT}  165
    ...  AND  Set Test Variable  ${NSA_UE_CAPABILITY}  NSA_n78_B1
    ...  AND  Set Test Variable  ${LTE_ONLY}  False
    ...  AND  Set Test Variable  ${APN}  n26wro
    ...  AND  TC Setup
    TC__CB008745__LTE_TX_patch_switch_on_off
    [Teardown]  Run Keywords
    ...       TC Teardown
    ...  AND  Attenuator Teardown
    ...  AND  Run Keyword If  ${FATAL_ERR}  Run Keyword If Test Failed  Fatal Error


CB008940_F4_POST_Interaction_CB008392_Cell_TX_Path_Switch_On_List
    [Setup]  Run Keywords
    ...  Attenuator Setup
    ...  AND  Set Attenuation   GNB_55014_CELL_2   0dB
    ...  AND  Add Configuration ID to Reporting Portal Report
    ...  scout_testline_name=${SCOUT_TL_NAME}
    ...  AND  Set Library Search Order  CB008940_F4_POST_Interaction_CB008392_Cell_TX_Path_Switch_On_List  admin
    ...  AND  Set Test Variable  ${NR_CELL_ID}  2
    ...  AND  Set Test Variable  ${POWER_GROUP_ID}  4
    ...  AND  Set Test Variable  ${NR_UE_CAPABILITY}  SA_n41
    ...  AND  Set Test Variable  ${APN}  n26wro
    ...  AND  TC Setup
    TC__CB008940_F4_POST_Interaction_CB008392_Cell_TX_Path_Switch_On_List
    Map Testcase  [1]CB008940_F4_POST_Interaction_CB008392_Cell_TX_Path_Switch_On_List
    [Teardown]  Run Keywords
    ...       TC Teardown
    ...  AND  Attenuator Teardown
    ...  AND  Run Keyword If  ${FATAL_ERR}  Run Keyword If Test Failed  Fatal Error


CB008940_F5_POST_Interaction_CB008392_Cell_TX_Path_Switch_Off_List
    [Setup]  Run Keywords
    ...  Attenuator Setup
    ...  AND  Set Attenuation   GNB_55014_CELL_2   0dB
    ...  AND  Add Configuration ID to Reporting Portal Report
    ...  scout_testline_name=${SCOUT_TL_NAME}
    ...  AND  Set Library Search Order  CB008940_F5_POST_Interaction_CB008392_Cell_TX_Path_Switch_Off_List  admin
    ...  AND  Set Test Variable  ${NR_CELL_ID}  2
    ...  AND  Set Test Variable  ${POWER_GROUP_ID}  4
    ...  AND  Set Test Variable  ${NR_UE_CAPABILITY}  SA_n41
    ...  AND  Set Test Variable  ${APN}  n26wro
    ...  AND  TC Setup
    TC__CB008940_F5_POST_Interaction_CB008392_Cell_TX_Path_Switch_Off_List
    Map Testcase  [1]CB008940_F5_POST_Interaction_CB008392_Cell_TX_Path_Switch_Off_List
    [Teardown]  Run Keywords
    ...       TC Teardown
    ...  AND  Attenuator Teardown
    ...  AND  Run Keyword If  ${FATAL_ERR}  Run Keyword If Test Failed  Fatal Error


CB008133_A_View_Power_Saving_Performance_Management_Counters
    [Setup]  Run Keywords
    ...  Attenuator Setup
    ...  AND  Set Attenuation   GNB_55014_CELL_83_ANCHOR   0dB
    ...  AND  Set Attenuation   GNB_55014_CELL_0   0dB
    ...  AND  Add Configuration ID to Reporting Portal Report
    ...  scout_testline_name=${SCOUT_TL_NAME}
    ...  AND  Set Library Search Order  CB008133_A_View_Power_Saving_Performance_Management_Counters  admin
    ...  AND  Set Test Variable  ${NR_CELL_ID}  0
    ...  AND  Set Test Variable  ${CELL_ID_FOR_CALL}  2067027
    ...  AND  Set Test Variable  ${POWER_GROUP_ID}  1
    ...  AND  Set Test Variable  ${NR_UE_CAPABILITY}  NSA_n78_B1
    ...  AND  Set Test Variable  ${CYCLE_COUNT}  5
    ...  AND  Set Test Variable  ${M55601C02001_EXPECTED_VALUE}  5
    ...  AND  Set Test Variable  ${M55601C02002_LOWER_THRESHOLD}  500
    ...  AND  Set Test Variable  ${M55601C02002_HIGHER_THRESHOLD}  600
    ...  AND  Set Test Variable  ${COUNTER_PERIOD}  15
    ...  AND  Set Test Variable  ${TPUT_ABOVE_MAX_LOAD}  400 Mbits/sec
    ...  AND  Set Test Variable  ${TPUT_BELOW_MIN_LOAD}  1 Mbits/sec
    ...  AND  Set Test Variable  ${STATUS_CHECK_DELAY}  40
    ...  AND  TC Setup
    Run keyword  TC__CB008133_A_View_Power_Saving_Performance_Management_Counters
    Map Testcase  [1]CB008133_A_View_Power_Saving_Performance_Management_Counters
    [Teardown]  Run Keywords
    ...       TC Teardown
    ...  AND  Attenuator Teardown
    ...  AND  Run Keyword If  ${FATAL_ERR}  Run Keyword If Test Failed  Fatal Error


CB008133_B_interworking_with_5GC001991
    [Setup]  Run Keywords
    ...  Add Configuration ID to Reporting Portal Report
    ...  scout_testline_name=${SCOUT_TL_NAME}
    ...  AND  Set Library Search Order  CB008133_B_interworking_with_5GC001991  admin
    ...  AND  Set Test Variable  ${NR_CELL_ID}  0
    ...  AND  TC Setup
    TC__CB008133_B_interworking_with_5GC001991
    Map Testcase  [1]CB008133_B_interworking_with_5GC001991
    [Teardown]  Run Keywords
    ...       TC Teardown
    ...  AND  Run Keyword If  ${FATAL_ERR}  Run Keyword If Test Failed  Fatal Error


CB008127-E_B1_Selection_of_measurement_profile_based_on_PLMN_NSSAI_slice
    [Setup]  Run Keywords
    ...  Attenuator Setup
    ...  AND  Set Attenuation   GNB_55014_CELL_3   27dB
    ...  AND  Add Configuration ID to Reporting Portal Report
    ...  scout_testline_name=${SCOUT_TL_NAME}
    ...  AND  Set Library Search Order  CB008127-E_B1_Selection_of_measurement_profile_based_on_PLMN_NSSAI_slice
    ...  AND  Set Test Variable  ${CELL_ID_FOR_CALL}  901349379
    ...  AND  Set Test Variable  ${NR_DL_THROUGHPUT}  150
    ...  AND  Set Test Variable  ${NR_UE_CAPABILITY}  POWER_CLASS_2_SA_n41
    ...  AND  TC Setup
    Run keyword  TC__${TEST_NAME}
    Map Testcase  [1]${TEST_NAME}
    [Teardown]  Run Keywords
    ...       TC Teardown
    ...  AND  Attenuator Teardown
    ...  AND  Run Keyword If  ${FATAL_ERR}  Run Keyword If Test Failed  Fatal Error


CB008127-G_B2_Successful_configuration_of_A2_and_intra-freq_A3_A5_during_SgNBAdditionReq
    [Setup]  Run Keywords
    ...  Attenuator Setup
    ...  AND  Set Attenuation   GNB_55014_CELL_2   60dB
    ...  AND  Set Attenuation   GNB_55014_CELL_3   20dB
    ...  AND  Set Attenuation   GNB_55014_CELL_1   30dB
    ...  AND  Set Attenuation   GNB_55014_CELL_83_ANCHOR   0dB
    ...  AND  Add Configuration ID to Reporting Portal Report
    ...  scout_testline_name=${SCOUT_TL_NAME}
    ...  AND  Set Library Search Order  CB008127-G_B2_Successful_configuration_of_A2_and_intra-freq_A3_A5_during_SgNBAdditionReq
    ...  AND  Set Test Variable  ${CELL_ID_FOR_CALL}  2067027
    ...  AND  Set Test Variable  ${NR_DL_THROUGHPUT}  150
    ...  AND  Set Test Variable  ${NR_UE_CAPABILITY}  POWER_CLASS_2_NSA_n41_B1
    ...  AND  TC Setup
    Run keyword  TC__${TEST_NAME}
    Map Testcase  [1]${TEST_NAME}
    [Teardown]  Run Keywords
    ...       TC Teardown
    ...  AND  Attenuator Teardown
    ...  AND  Run Keyword If  ${FATAL_ERR}  Run Keyword If Test Failed  Fatal Error


CB008127-F_B5_Successful_configuration_of_intra-freq_A2_A3_A5_using_meas_profiles_upon_setup_VoNR
    [Setup]  Run Keywords
    ...  Attenuator Setup
    ...  AND  Set Attenuation   GNB_55014_CELL_2   31dB
    ...  AND  Set Attenuation   GNB_55014_CELL_3   20dB
    ...  AND  Set Attenuation   GNB_55014_CELL_1   44dB
    ...  AND  Add Configuration ID to Reporting Portal Report
    ...  scout_testline_name=${SCOUT_TL_NAME}
    ...  AND  Set Library Search Order  CB008127-F_B5_Successful_configuration_of_intra-freq_A2_A3_A5_using_meas_profiles_upon_setup_VoNR
    ...  admin  ca_IWK  ute_ue
    ...  AND  Set Test Variable  ${CELL_ID_FOR_CALL}  901349379
    ...  AND  Set Test Variable  ${EXP_VAL_M55190C00001}  1
    ...  AND  Set Test Variable  ${EXP_VAL_M55187C00001}  1
    ...  AND  Set Test Variable  ${COUNTER_PERIOD}  5
    ...  AND  Set Test Variable  ${NR_CELL_ID}  3
    ...  AND  Set Test Variable  ${UE_CAPABILITY}  POWER_CLASS_2_SA_n41
    ...  AND  Set Test Variable  ${PHONE_NUMBER}  0105
    ...  AND  Set Test Variable  ${CALL_DURATION}  5
    ...  AND  TC Setup
    Run Keyword  TC__CB008127-F_B5_Successful_configuration_of_intra-freq_A2_A3_A5_using_meas_profiles_upon_setup_VoNR
    Map Testcase  [1]${TEST_NAME}
    [Teardown]  Run Keywords
    ...       TC Teardown
    ...  AND  Attenuator Teardown
    ...  AND  Run Keyword If  ${FATAL_ERR}  Run Keyword If Test Failed  Fatal Error


CB008224_C_SDL_SCell_Swap_-_SDL_To_SDL_SCell_SA
    [Setup]  Run Keywords
    ...  Add Configuration ID to Reporting Portal Report
    ...  scout_testline_name=${SCOUT_TL_NAME}
    ...  AND  Set Library Search Order  CB008224_C_SDL_SCell_Swap_-_SDL_To_SDL_SCell_SA
    ...  AND  Attenuator Setup
    ...  AND  Set Attenuation   GNB_55014_CELL_0   0dB
    ...  AND  Set Attenuation   GNB_55014_CELL_6   0dB
    ...  AND  Set Attenuation   GNB_55014_CELL_7   70dB
    ...  AND  Set Test Variable  ${NR_PCELL_ID}  0
    ...  AND  Set Test Variable  ${NR_SCELL_ID_1}  6
    ...  AND  Set Test Variable  ${NR_SCELL_ID_2}  7
    ...  AND  Set Test Variable  ${ATT_SCELL_1}  GNB_55014_CELL_6
    ...  AND  Set Test Variable  ${ATT_SCELL_2}  GNB_55014_CELL_7
    ...  AND  Set Test Variable  ${CELL_ID_FOR_CALL}  901349376
    ...  AND  Set Test Variable  ${NR_UE_CAPABILITY}  SA_n78_n66
    ...  AND  Set Test Variable  ${MAX_DCAP_LOGS_DELAY}  140
    ...  AND  Set Test Variable  ${APN}  n26wro
    ...  AND  TC Setup
    Run keyword  TC__${TEST_NAME}
    Map Testcase  [1]${TEST_NAME}
    [Teardown]  Run Keywords
    ...       TC Teardown
    ...  AND  Attenuator Teardown


RRM__Interaction_with_CRG__CB009919-B
    [Setup]  Run Keywords
    ...  Add Configuration ID to Reporting Portal Report
    ...  scout_testline_name=${SCOUT_TL_NAME}
    ...  AND  Set Library Search Order  RRM__Interaction_with_CRG__CB009919-B  admin
    ...  AND  Attenuator Setup
    ...  AND  Set Attenuation   GNB_55014_CELL_3   0dB
    ...  AND  Set Test Variable  ${GLOBAL_CELL_ID_LTE}  12
    ...  AND  Set Test Variable  ${CAP_LTE_UE1}  LTE_TRINITY_B41
    ...  AND  Set Test Variable  ${CAP_LTE_UE2}  LTE_TATRA_B41
    ...  AND  Set Test Variable  ${SCF_PATH}  /home/ute/testline_configuration/7_16_UTE5GCLOUDU055/SCF/CB009919.xml
    ...  AND  Set Test Variable  ${REVERT_CHANGES}  True
    ...  AND  Set Test Variable  ${ATTENUATED_CELL}  GNB_55014_CELL_3
    ...  AND  Set Test Variable  ${LOCAL_CONNECTION}  gNB
    ...  AND  Set Test Variable  ${CELL1_PATH}  MRBTS-55014/LNBTS-8074/LNCEL-12/SIB-0
    ...  AND  Set Test Variable  ${CELL1_QRXLEVMIN}  -140
    ...  AND  Set Test Variable  ${CELL2_PATH}  MRBTS-55014/LNBTS-8074/LNCEL-15/SIB-0
    ...  AND  Set Test Variable  ${CELL2_QRXLEVMIN}  -44
    ...  AND  TC Setup
    Run keyword  TC__${TEST_NAME}
    [Teardown]  Run Keywords
    ...  TC Teardown
    ...  AND  Attenuator Teardown
    ...  AND  Map Testcase  [1]${TEST_NAME}


RRM__Interaction_with_LTE907_TTI_Bundling__CB009919-B
    [Setup]  Run Keywords
    ...  Add Configuration ID to Reporting Portal Report
    ...  scout_testline_name=${SCOUT_TL_NAME}
    ...  AND  Set Library Search Order  RRM__Interaction_with_LTE907_TTI_Bundling__CB009919-B  admin
    ...  AND  Attenuator Setup
    ...  AND  Set Attenuation   GNB_55014_CELL_3   0dB
    ...  AND  Set Test Variable  ${GLOBAL_CELL_ID_LTE}  15
    ...  AND  Set Test Variable  ${CAPABILITY_LTE_UE}  LTE_QUALITY_B41
    ...  AND  Set Test Variable  ${SCF_PATH}  /home/ute/testline_configuration/7_16_UTE5GCLOUDU055/SCF/CB009919.xml
    ...  AND  Set Test Variable  ${REVERT_CHANGES}  True
    ...  AND  Set Test Variable  ${ATTENUATION_LEVEL}  55dB
    ...  AND  Set Test Variable  ${ATTENUATED_CELL}  GNB_55014_CELL_3
    ...  AND  Set Test Variable  ${LOCAL_CONNECTION}  gNB
    ...  AND  Set Test Variable  ${CELL1_PATH}  MRBTS-55014/LNBTS-8074/LNCEL-15/SIB-0
    ...  AND  Set Test Variable  ${CELL1_QRXLEVMIN}  -140
    ...  AND  Set Test Variable  ${CELL2_PATH}  MRBTS-55014/LNBTS-8074/LNCEL-12/SIB-0
    ...  AND  Set Test Variable  ${CELL2_QRXLEVMIN}  -44
    ...  AND  TC Setup
    Run keyword  TC__${TEST_NAME}
    [Teardown]  Run Keywords
    ...  TC Teardown
    ...  AND  Attenuator Teardown
    ...  AND  Map Testcase  [1]${TEST_NAME}


RRM__UL_256QAM_support_with_channel_quality_monitoring_enabled__CB009919-B
    [Setup]  Run Keywords
    ...  Add Configuration ID to Reporting Portal Report
    ...  scout_testline_name=${SCOUT_TL_NAME}
    ...  AND  Set Library Search Order  RRM__UL_256QAM_support_with_channel_quality_monitoring_enabled__CB009919-B  admin
    ...  AND  Attenuator Setup
    ...  AND  Set Attenuation   GNB_55014_CELL_3   0dB
    ...  AND  Set Test Variable  ${GLOBAL_CELL_ID_LTE}  12
    ...  AND  Set Test Variable  ${TPUT_DL_BANDWIDTH}  75 Mbits/sec
    ...  AND  Set Test Variable  ${TPUT_UL_BANDWIDTH}  16 Mbits/sec
    ...  AND  Set Test Variable  ${ATTENUATION}  55db
    ...  AND  Set Test Variable  ${CAP_LTE_UE1}  LTE_QUALITY_B41
    ...  AND  Set Test Variable  ${SCF_PATH}  /home/ute/testline_configuration/7_16_UTE5GCLOUDU055/SCF/CB009919.xml
    ...  AND  Set Test Variable  ${REVERT_CHANGES}  True
    ...  AND  Set Test Variable  ${ATTENUATED_CELL}  GNB_55014_CELL_3
    ...  AND  Set Test Variable  ${LOCAL_CONNECTION}  gNB
    ...  AND  Set Test Variable  ${CELL1_PATH}  MRBTS-55014/LNBTS-8074/LNCEL-12/SIB-0
    ...  AND  Set Test Variable  ${CELL1_QRXLEVMIN}  -140
    ...  AND  Set Test Variable  ${CELL2_PATH}  MRBTS-55014/LNBTS-8074/LNCEL-15/SIB-0
    ...  AND  Set Test Variable  ${CELL2_QRXLEVMIN}  -44
    ...  AND  TC Setup
    Run keyword  TC__${TEST_NAME}
    [Teardown]  Run Keywords
    ...       TC Teardown
    ...  AND  Attenuator Teardown
    ...  AND  Map Testcase  [1]${TEST_NAME}

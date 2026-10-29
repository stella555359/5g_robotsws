*** Settings ***
Documentation
...   contact: Oleksandr Kulieshov

Force Tags        QCD_MN_RAN    QCP_RAN_ST    CRT    CLOUD_SRAN_LWG_2ASIL_6ABIA_3AHDB_2FXFC_1FRGU    SBTS00
Library  taf.sw.reporting_portal
Library  taf.sw.scout  WITH NAME  scout
Resource          ../../feature_resources/old_INTER_RAT/INTER_RAT__DSS_GSM_dedicated_and_shared_TRX_LTE_dedicated_and_shared__RP001783.robot
Resource          ../../feature_resources/old_INTER_RAT/INTER_RAT__DSS_HSUPA_Quality_during_generating_GSM_calls__RP002014.robot
Resource          ../../feature_resources/old_INTER_RAT/INTER_RAT__DSS_shared_prbs_counters__RP002546.robot
Resource          ../../feature_resources/old_INTER_RAT/INTER_RAT__DSS_load_increase_low_medium_high__RP002167.robot
Resource          ../../feature_resources/CB008415/RRM_DSS__downlink_resource_sharing_5_MHz_TDD_cell__CB008415-C_B1.robot
Resource          ../../feature_resources/CB005860/IWK__dl_single_user_performance_with_concurrent_lte_and_nr_traffic_10MHz_95__CB005860.robot
Resource          ../../feature_resources/CB005860/IWK__ul_single_user_performance_with_concurrent_lte_and_nr_traffic_10MHz_70__CB005860.robot
Resource          ../../feature_resources/LTE4750/IWK__dl_single_user_sharing_ratio_dynamic_adaptation__LTE4750.robot
Resource          ../../feature_resources/CNI89408/CNI-89408_DSS_NSA_and_SA_Counters_verification.robot
Resource          ../../feature_resources/CB005738_CB007738/CB005738_CB007738_UL_superfast_allocation_improvement.robot
Resource          ${CB005738_CB007738_RESOURCE_PATH}
Resource          ../../resources/ca_IWK.robot
Resource          ../../resources/attenuator.robot

*** Variables ***
${CB005738_CB007738_RESOURCE_PATH}=    SEPARATOR=
...  ../../feature_resources/CB005738_CB007738/
...  CB005738_CB007738_DL_LTE_GBR_data_transfers_with_concurrent_NR_and_LTE_non_GBR_connections_20MHz.robot
${TRUNK_SW}                 True                 # Defining if SW version is for branch or trunk
${FATAL_ERR}                False                # Defining if tests should be stopped after fatal error
${SCOUT_TL_NAME}            10_16_MRBTS-19656    # Name of TL from SCOUT
${ABSTRACT_LIB_CONFIG}      /home/ute/testline_configuration/7_16_UTE5GCLOUDU067/device/ta_ue_config.yaml  # Path to UE config file
${VIRTUALENV_DIR}           /home/ute/test_repo


*** Keywords ***
Attenuator Setup
    Log  \n== Attenuator Setup ==  console=True
    Load Attenuation Config And Require Attenuator Setup  ${ABSTRACT_LIB_CONFIG}

Attenuator Teardown
    Log  \n== Attenuator Teardown ==  console=True
    Set Attenuation For All Cells  100%

Set qrxlevmin Level
    [Arguments]   ${cell_dn}    ${value}    ${technology}
    Log To Console    Setting qrxlevmin on ${cell_dn} at ${value}dB
    admin.Setup Admin    alias=qrx_change
    Run Keyword If  '${technology}'=='NR'
    ...    admin.Perform Parameter Recommissioning    ${cell_dn}    qRxLevMin   update
    ...    ${value}    connection=qrx_change
    Run Keyword If  '${technology}'=='LTE'
    ...    admin.Perform Parameter Recommissioning    ${cell_dn}    qrxlevmin   update
    ...    ${value}    connection=qrx_change
    [Teardown]    admin.Teardown Admin    connection=qrx_change


*** Test Cases ***
INTER_RAT__DSS_GSM_dedicated_and_shared_TRX_LTE_dedicated_and_shared__RP001783
    [Setup]    Run Keywords
    ...           Set Test Variable    ${LTE_CELL_ID}                   13673
    ...    AND    Set Test Variable    ${GSM_CELL_ID}                   1241
    ...    AND    Set Test Variable    ${EXPECTED_NUMOFPRBSALLOC}       18
    ...    AND    Set Test Variable    ${EXPECTED_TOTALPRBAVAIL}        17
    ...    AND    Add Configuration ID to Reporting Portal Report
    ...    scout_testline_name=${SCOUT_TL_NAME}
    ...    AND    Set library Search Order    INTER_RAT__DSS_GSM_dedicated_and_shared_TRX_LTE_dedicated_and_shared__RP001783  admin
    ...    AND    Attenuator Setup
    ...    AND    Set Attenuation For All Cells  100%
    ...    AND    Set Attenuation  RP001783_CB008193  0%
    ...    AND  Set qrxlevmin Level    MRBTS-19656/LNBTS-19656/LNCEL-13691/SIB-0   -44  LTE
    ...    AND    TC Setup
    Map Testcase  [1]INTER_RAT__DSS_GSM_dedicated_and_shared_TRX_LTE_dedicated_and_shared__RP001783
    [Timeout]    14400
    TC__INTER_RAT__DSS_GSM_dedicated_and_shared_TRX_LTE_dedicated_and_shared__RP001783
    [Teardown]    Run Keywords
    ...           TC Teardown
    ...    AND    Set qrxlevmin Level    MRBTS-19656/LNBTS-19656/LNCEL-13691/SIB-0   -120  LTE
    ...    AND    Attenuator Teardown
    ...    AND    Run Keyword If  ${FATAL_ERR}  Run Keyword If Test Failed  Fatal Error


INTER_RAT__DSS_HSUPA_Quality_during_generating_GSM_calls__RP002014
    [Setup]    Run Keywords
    ...           Set Test Variable    ${WCDMA_CELL_ID}             44007
    ...    AND    Set Test Variable    ${CALL_TIME}                 1200
    ...    AND    Set Test Variable    ${NUMBER}                    0666002
    ...    AND    Add Configuration ID to Reporting Portal Report
    ...    scout_testline_name=${SCOUT_TL_NAME}
    ...    AND    Set Library Search Order    INTER_RAT__DSS_HSUPA_Quality_during_generating_GSM_calls__RP002014  admin
    ...    AND    Attenuator Setup
    ...    AND    Set Attenuation For All Cells  100%
    ...    AND    Set Attenuation  RP002014  0%
    ...    AND    TC Setup
    Map Testcase  [1]INTER_RAT__DSS_HSUPA_Quality_during_generating_GSM_calls__RP002014
    [Timeout]    14400
    TC__INTER_RAT__DSS_HSUPA_Quality_during_generating_GSM_calls__RP002014
    [Teardown]    Run Keywords
    ...           TC Teardown
    ...    AND    Attenuator Teardown
    ...    AND    Run Keyword If  ${FATAL_ERR}  Run Keyword If Test Failed  Fatal Error


INTER_RAT__DSS_shared_prbs_counters__RP002546
    [Setup]    Run Keywords
    ...           Set Test Variable    ${LTE_CELL_ID}               13676
    ...    AND    Set Test Variable   ${NUMBER}                     0666002
    ...    AND    Add Configuration ID to Reporting Portal Report
    ...    scout_testline_name=${SCOUT_TL_NAME}
    ...    AND    Set Library Search Order    INTER_RAT__DSS_shared_prbs_counters__RP002546  admin
    ...    AND    Attenuator Setup
    ...    AND    Set Attenuation For All Cells  100%
    ...    AND    Set Attenuation  RP002546_RP002167  0%
    ...    AND    Set Test Variable  ${MCC}  001
    ...    AND    Set Test Variable  ${MNC}  01
    ...    AND    TC Setup
    Map Testcase  [1]INTER_RAT__DSS_shared_prbs_counters__RP002546
    [Timeout]    14400
    TC__INTER_RAT__DSS_shared_prbs_counters__RP002546
    [Teardown]    Run Keywords
    ...           TC Teardown
    ...    AND    Attenuator Teardown
    ...    AND    Run Keyword If  ${FATAL_ERR}  Run Keyword If Test Failed  Fatal Error


INTER_RAT__DSS_load_increase_low_medium_high__RP002167
    [Setup]    Run Keywords
    ...           Set Test Variable    ${LTE_CELL_ID}               13676
    ...    AND    Add Configuration ID to Reporting Portal Report
    ...    scout_testline_name=${SCOUT_TL_NAME}
    ...    AND    Set Library Search Order    INTER_RAT__DSS_load_increase_low_medium_high__RP002167  admin
    ...    AND    Attenuator Setup
    ...    AND    Set Attenuation For All Cells  100%
    ...    AND    Set Attenuation  RP002546_RP002167  0%
    ...    AND    TC Setup
    Map Testcase  [1]INTER_RAT__DSS_load_increase_low_medium_high__RP002167
    [Timeout]    14400
    TC__INTER_RAT__DSS_load_increase_low_medium_high__RP002167
    [Teardown]    Run Keywords
    ...           TC Teardown
    ...    AND    Attenuator Teardown
    ...    AND    Run Keyword If  ${FATAL_ERR}  Run Keyword If Test Failed  Fatal Error


RRM_DSS__downlink_resource_sharing_5_MHz_TDD_cell__CB008415-C_B1
    [Setup]  Run Keywords
    ...  Set Library Search Order  RRM_DSS__downlink_resource_sharing_5_MHz_TDD_cell__CB008415-C_B1  admin
    ...  AND  Attenuator Setup
    ...  AND  Set Attenuation For All Cells  100%
    ...  AND  Set Attenuation  CB008415  0%
    ...  AND  Set Test Variable    ${LTE_CELL_ID}    13679
    ...  AND  Add Configuration ID to Reporting Portal Report
    ...  scout_testline_name=${SCOUT_TL_NAME}
    ...  AND  TC Setup
    Run keyword  TC__${TEST_NAME}
    Map Testcase  [1]RRM_DSS__downlink_resource_sharing_5_MHz_TDD_cell__CB008415-C_B1
    [Teardown]  Run Keywords
    ...         TC Teardown
    ...  AND    Attenuator Teardown
    ...  AND    Run Keyword If  ${FATAL_ERR}  Run Keyword If Test Failed  Fatal Error


IWK__dl_single_user_performance_with_concurrent_lte_and_nr_traffic_10MHz_95__CB005860
    [Setup]  Run Keywords
    ...  Add Configuration ID to Reporting Portal Report
    ...  scout_testline_name=${SCOUT_TL_NAME}
    ...  AND  Set Library Search Order  IWK__dl_single_user_performance_with_concurrent_lte_and_nr_traffic_10MHz_95__CB005860  admin
    ...  AND  Set Test Variable  ${LNRELGNBCELL_ID}  *
    ...  AND  Set Test Variable  ${BLANKED_PUCCH}  8
    ...  AND  Set Test Variable  ${NR_UE_CAPABILITY}  NR_LOCKED_NL
    ...  AND  Set Test Variable  ${LTE_UE_CAPABILITY}  LTE_LOCKED_WL
    ...  AND  Set Test Variable  ${LTE_EXPECTED_DL_TPUT_MBPS}    5
    ...  AND  Set Test Variable  ${NR_EXPECTED_DL_TPUT_MBPS}     70
    ...  AND  Set Test Variable  ${RECOMMISSIONING_TIMEOUT}      600
    ...  AND  Set Test Variable  ${LTE_DL_THROUGHPUT}  50
    ...  AND  Set Test Variable  ${NR_DL_THROUGHPUT}  150
    ...  AND  Set Test Variable  ${LTE_CELL_ID}    13691
    ...  AND  Set Test Variable  ${NR_CELL_ID}    198
    ...  AND  Set Test Variable  ${NR_CALL_CELL_ID}  66650310
    ...  AND  Set Test Variable  ${INTER_RAT_SETUP}    True
    ...  AND  Set Test Variable  ${CONNECTIVITY}    default
    ...  AND  Set Test Variable  ${APN}  n26wro
    ...  AND  Attenuator Setup
    ...  AND  Set Attenuation For All Cells  100%
    ...  AND  Set Attenuation  RP001783_CB008193  0%
    ...  AND  Set qrxlevmin Level    MRBTS-19656/LNBTS-19656/LNCEL-13673/SIB-0   -44  LTE
    ...  AND  TC Setup
    Run keyword  TC__${TEST_NAME}
    Map Testcase  [1]${TEST_NAME}
    [Teardown]  Run Keywords
    ...         TC Teardown
    ...  AND    Set qrxlevmin Level    MRBTS-19656/LNBTS-19656/LNCEL-13673/SIB-0   -130  LTE
    ...  AND    Attenuator Teardown


IWK__ul_single_user_performance_with_concurrent_lte_and_nr_traffic_10MHz_70__CB005860
    [Setup]  Run Keywords
    ...  Add Configuration ID to Reporting Portal Report
    ...  scout_testline_name=${SCOUT_TL_NAME}
    ...  AND  Set Library Search Order  IWK__ul_single_user_performance_with_concurrent_lte_and_nr_traffic_10MHz_70__CB005860  admin
    ...  AND  Set Test Variable  ${LNRELGNBCELL_ID}  *
    ...  AND  Set Test Variable  ${BLANKED_PUCCH}  8
    ...  AND  Set Test Variable  ${LTE_EXPECTED_UL_TPUT_MBPS}    5.5
    ...  AND  Set Test Variable  ${NR_EXPECTED_UL_TPUT_MBPS}     25
    ...  AND  Set Test Variable  ${RECOMMISSIONING_TIMEOUT}      600
    ...  AND  Set Test Variable  ${NR_UE_CAPABILITY}  NR_LOCKED_NL
    ...  AND  Set Test Variable  ${LTE_UE_CAPABILITY}  LTE_LOCKED_WL
    ...  AND  Set Test Variable  ${LTE_UL_THROUGHPUT}  50
    ...  AND  Set Test Variable  ${NR_UL_THROUGHPUT}  50
    ...  AND  Set Test Variable  ${LTE_CELL_ID}    13691
    ...  AND  Set Test Variable  ${NR_CELL_ID}    198
    ...  AND  Set Test Variable  ${NR_CALL_CELL_ID}  66650310
    ...  AND  Set Test Variable  ${INTER_RAT_SETUP}    True
    ...  AND  Set Test Variable  ${CONNECTIVITY}    default
    ...  AND  Set Test Variable  ${APN}  n26wro
    ...  AND  Attenuator Setup
    ...  AND  Set Attenuation For All Cells  100%
    ...  AND  Set Attenuation  RP001783_CB008193  0%
    ...  AND  Set qrxlevmin Level    MRBTS-19656/LNBTS-19656/LNCEL-13673/SIB-0   -44  LTE
    ...  AND  TC Setup
    Run keyword  TC__${TEST_NAME}
    Map Testcase  [1]${TEST_NAME}
    [Teardown]  Run Keywords
    ...         TC Teardown
    ...  AND    Set qrxlevmin Level    MRBTS-19656/LNBTS-19656/LNCEL-13673/SIB-0   -120  LTE
    ...  AND    Attenuator Teardown


IWK__dl_single_user_sharing_ratio_dynamic_adaptation__LTE4750
    [Setup]  Run Keywords
    ...  Add Configuration ID to Reporting Portal Report
    ...  scout_testline_name=${SCOUT_TL_NAME}
    ...  AND  Set Library Search Order  IWK__dl_single_user_sharing_ratio_dynamic_adaptation__LTE4750  admin
    ...  AND  Set Test Variable  ${EXPECTED_M8029C217_STEP3}   7
    ...  AND  Set Test Variable  ${EXPECTED_M8029C217_STEP7}   65
    ...  AND  Set Test Variable  ${EXPECTED_M8029C217_STEP11}  7
    ...  AND  Set Test Variable  ${LTE_CELL_ID}    13692
    ...  AND  Set Test Variable  ${NR_CELL_ID}    199
    ...  AND  Set Test Variable  ${NR_CALL_CELL_ID}    66650311
    ...  AND  Set Test Variable  ${BLANKED_PUCCH}  8
    ...  AND  Set Test Variable  ${NR_UE_CAPABILITY}  NR_LOCKED_NL
    ...  AND  Set Test Variable  ${LTE_UE_CAPABILITY}  LTE_LOCKED_WL
    ...  AND  Set Test Variable  ${LTE_DL_THROUGHPUT}  150
    ...  AND  Set Test Variable  ${NR_DL_THROUGHPUT}  150
    ...  AND  Set Test Variable  ${MCC}  001
    ...  AND  Set Test Variable  ${MNC}  01
    ...  AND  Set Test Variable  ${APN}  n26wro
    ...  AND  Attenuator Setup
    ...  AND  Set Attenuation For All Cells  100%
    ...  AND  Set Attenuation  LTE4750566  0%
    ...  AND  TC Setup
    Run keyword  TC__${TEST_NAME}
    Map Testcase  [1]${TEST_NAME}
    [Teardown]  Run Keywords
    ...         TC Teardown
    ...  AND    Attenuator Teardown

CNI-89408_DSS_NSA_and_SA_Counters_verification
    [Setup]  Run Keywords
    ...  Add Configuration ID to Reporting Portal Report
    ...  scout_testline_name=${SCOUT_TL_NAME}
    ...  AND  Set Library Search Order  CNI-89408_DSS_NSA_and_SA_Counters_verification  admin
    ...  AND  Attenuator Setup
    ...  AND  Set Attenuation For All Cells  100%
    ...  AND  Set Attenuation  CNI-89408  0%
    ...  AND  Set Attenuation  RP002546_RP002167  0%
    ...  AND  Set Test Variable  ${NSA_ANCHOR_CELL_ID}  5031950
    ...  AND  Set Test Variable  ${SA_CELL_ID}   66650312
    ...  AND  Set Test Variable  ${SA_UE_CAP}    NR_LOCKED_SA
    ...  AND  Set Test Variable  ${NSA_UE_CAP}   NR_LOCKED_NSA
    ...  AND  Set Test Variable  ${CONNECTIVITY}    default
    ...  AND  Set Test Variable  ${LNRELGNBCELL_ID}  *
    ...  AND  Set Test Variable  ${BLANKED_PUCCH}  8
    ...  AND  Set Test Variable  ${LTE_CELL_ID}    13693
    ...  AND  Set Test Variable  ${NR_CELL_ID}    200
    ...  AND  Set Test Variable  ${INTER_RAT_SETUP}    True
    ...  AND  Set Test Variable  ${GNB_MPLANE}  10.42.25.246
    ...  AND  TC Setup
    Run keyword  TC__${TEST_NAME}
    Map Testcase  [1]${TEST_NAME}
    [Teardown]  Run Keywords
    ...         TC Teardown
    ...  AND    Attenuator Teardown

CB005738_CB007738_UL_superfast_allocation_improvement
    [Setup]  Run Keywords
    ...  Add Configuration ID to Reporting Portal Report
    ...  scout_testline_name=${SCOUT_TL_NAME}
    ...  AND  Attenuator Setup
    ...  AND  Set Attenuation For All Cells  100%
    ...  AND  Set Attenuation  CNI-89408  0%
    ...  AND  Set Library Search Order  CB005738_CB007738_UL_superfast_allocation_improvement  admin
    ...  AND  Set Test Variable    ${NR_CELL_ID}   66650312
    ...  AND  Set Test Variable    ${GLOBAL_CELL_ID_LTE}  13693
    ...  AND  Set Test Variable    ${GLOBAL_CELL_ID_NR}  200
    ...  AND  Set Test Variable    ${LTE_ID}  19656
    ...  AND  Set Test Variable    ${NR_ID}  4068
    ...  AND  Set Test Variable    ${DSSNR_DIST_NAME_LTE}  MRBTS-${LTE_ID}/LNBTS-${LTE_ID}/LNCEL-${GLOBAL_CELL_ID_LTE}/DSSNR-0
    ...  AND  Set Test Variable    ${NRDSSLTE_DIST_NAME_NR}  MRBTS-${LTE_ID}/NRBTS-${NR_ID}/NRCELL-${GLOBAL_CELL_ID_NR}/NRDSSLTE-1
    ...  AND  Set Test Variable  ${APN}  n26wro
    ...  AND  TC Setup
    Run keyword  TC__${TEST_NAME}
    Map Testcase  [1]${TEST_NAME}
    [Teardown]    Run Keywords
    ...           TC Teardown
    ...    AND    Attenuator Teardown


CB005738_CB007738_DL_LTE_GBR_data_transfers_with_concurrent_NR_and_LTE_non_GBR_connections_20MHz
    [Setup]  Run Keywords
    ...  Add Configuration ID to Reporting Portal Report
    ...  scout_testline_name=${SCOUT_TL_NAME}
    ...  AND  Set Library Search Order  CB005738_CB007738_DL_LTE_GBR_data_transfers_with_concurrent_NR_and_LTE_non_GBR_connections_20MHz
    ...  AND  Attenuator Setup
    ...  AND  Set Attenuation For All Cells  100%
    ...  AND  Set Attenuation  CNI-89408  0%
    ...  AND  Set Test Variable  ${NR_CELL_ID}      200
    ...  AND  Set Test Variable  ${NR_CALL_CELL_ID}     66650312
    ...  AND  Set Test Variable  ${LTE_CELL_ID}    13693
    ...  AND  Set Test Variable  ${PHYS_LTE_CELL_ID}  20
    ...  AND  Set Test Variable  ${LTE_MSISDN}     +555800903300998
    ...  AND  Set Test Variable  ${BLANKED_PUCCH}  8
    ...  AND  Set Test Variable  ${INTER_RAT_SETUP}    True
    ...  AND  Set Test Variable  ${CONNECTIVITY}       default
    ...  AND  Set Test Variable  ${NR_EXPECTED_DL_TPUT_MBPS}  35
    ...  AND  Set Test Variable  ${LTE_EXPECTED_DL_TPUT_MBPS}  35
    ...  AND  Set Test Variable  ${LTE_UE_ALIAS}        LTE_LOCKED_WL
    ...  AND  Set Test Variable  ${NR_UE_ALIAS}         NR_LOCKED_NL
    ...  AND  Set Test Variable  ${APN}  n26wro
    ...  AND  TC Setup
    Run keyword  TC__${TEST_NAME}
    Map Testcase  [1]${TEST_NAME}
    [Teardown]  Run Keywords
    ...       TC Teardown
    ...  AND  Attenuator Teardown

*** Settings ***
Documentation
...   contact: Igor Kleschenok

Library   taf.sw.reporting_portal
Library   taf.sw.scout  WITH NAME  scout
Resource  ../../feature_resources/CB008133/CB008133_A_View_Power_Saving_Performance_Management_Counters.robot
Resource  ../../feature_resources/CB005860/IWK__dl_single_user_performance_with_concurrent_lte_and_nr_traffic_10MHz_95__CB005860_TL_DeLorean.robot
Resource  ../../feature_resources/CNI68378/IWK_CNI-68378_DL_sharing_algorithm_with_NR_UL_load_no_DL_traffic_UL_NR_traffic_DSSp3_TL_DeLorean.robot
Resource  ../../feature_resources/CB008392/CB008392_A_4TX_Switch_Off_TX_Paths_Verification_TL_DeLorean.robot
Resource  ../../feature_resources/CB008224/CB008224_B_SDL_SCell_Addition_-_Blind_Mode_SA.robot
Resource  ../../feature_resources/CB011006/CB011006-A_Successful_UE_attachment_and_traffic_NSA_SA_Mode_ABIQ.robot
Resource  ../../resources/ca_INTER_RAT.robot
Resource  ../../resources/ca_IWK.robot
Resource  ../../resources/attenuator.robot

Variables   ../DeLorean/resources/scenario.py

Suite Setup  Set Suite Variables


*** Variables ***
${SCOUT_TL_NAME}             7_16_UTE5GCLOUDU068_1      # Name of TL from SCOUT
${USE_SCOUT_INTERNAL_ID}     True                       # Parameter for 'Request SCF' keyword from taf.sw.scout library


*** Keywords ***
Set Suite Variables

    ${ftp_iot}=    Create Dictionary    IP=10.42.61.61    username=syslab    password=system
    Set Suite Variable  ${FTP_IOT}    ${ftp_iot}
    ${pc_iot}=    Create Dictionary     IP=10.42.224.204    username=wrodss    password=Ru1eTheAir!dss
    Set Suite Variable  ${PC_IOT}    ${pc_iot}
    ${ftp_catm}=  Create Dictionary     IP=10.42.61.65  username=sran  password=sran
    Set Suite Variable  ${FTP_CATM}  ${ftp_catm}
    Set Suite Variable  ${CLOUD}                        True

Attenuator Setup
    Log To Console   Attenuator Setup
    Reserve Attenuator Resources Using Cells List Specification

Reserve Attenuator Resources Using Cells List Specification
    Load Attenuation Config And Require Attenuator Setup    ${ABSTRACT_LIB_CONFIG}
    Set Attenuation For All Cells  100%

Attenuator Teardown
    Log To Console   Attenuator Teardown
    Set Attenuation For All Cells  100%

Set qrxlevmin Level
    [Arguments]   ${cell_DN}    ${value}    ${technology}
    [Teardown]    admin.Teardown Admin    connection=qrx_change
    Log To Console    Setting qrxlevmin on ${cell_DN} at ${value}dB
    admin.Setup Admin    alias=qrx_change
    Run Keyword If  '${technology}'=='NR'
    ...    admin.Perform Parameter Recommissioning    ${cell_DN}    qRxLevMin   update
    ...    ${value}    connection=qrx_change
    Run Keyword If  '${technology}'=='LTE'
    ...    admin.Perform Parameter Recommissioning    ${cell_DN}    qrxlevmin   update
    ...    ${value}    connection=qrx_change

*** Test Cases ***

CB008133_A_View_Power_Saving_Performance_Management_Counters
    [Setup]  Run Keywords
    ...  Add Configuration ID to Reporting Portal Report
    ...  scout_testline_name=${SCOUT_TL_NAME}
    ...  AND  Attenuator Setup
    ...  AND  Set Attenuation   AQQL_CELLS   0dB
    ...  AND  Set Library Search Order  CB008133_A_View_Power_Saving_Performance_Management_Counters  admin
    ...  AND  Set Test Variable  ${NR_CELL_ID}  1
    ...  AND  Set Test Variable  ${CELL_ID_FOR_CALL}  904429569
    ...  AND  Set Test Variable  ${POWER_GROUP_ID}  1
    ...  AND  Set Test Variable  ${NR_UE_CAPABILITY}  SA_LOCKED
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
    Map Testcase  [1][1.0] ${TEST_NAME}
    [Teardown]  Run Keywords
    ...       TC Teardown
    ...  AND  Attenuator Teardown

IWK__dl_single_user_performance_with_concurrent_lte_and_nr_traffic_10MHz_95__CB005860_TL_DeLorean
    [Setup]  Run Keywords
    ...  Add Configuration ID to Reporting Portal Report
    ...  scout_testline_name=${SCOUT_TL_NAME}
    ...  AND  Attenuator Setup
    ...  AND  Set Attenuation   AHFIB_CELLS   0dB
    ...  AND  Set Attenuation   AHFIB_CELLS   0dB
    ...  AND  Set Library Search Order  IWK__dl_single_user_performance_with_concurrent_lte_and_nr_traffic_10MHz_95__CB005860_TL_DeLorean  admin
    ...  AND  Set Test Variable  ${LTE_CELL_ID}                  5
    ...  AND  Set Test Variable  ${LTE_ANCHOR_CELL_ID}           4
    ...  AND  Set Test Variable  ${LTE_EXPECTED_DL_TPUT_MBPS}    13
    ...  AND  Set Test Variable  ${NR_EXPECTED_DL_TPUT_MBPS}     115
    ...  AND  Set Test Variable  ${RECOMMISSIONING_TIMEOUT}      600
    ...  AND  Set Test Variable  ${LNRELGNBCELL_ID}  1
    ...  AND  Set Test Variable  ${SINGLE_SBTS}  True
    ...  AND  Set Test Variable  ${ENB_ALIAS}  gNB
    ...  AND  Set Test Variable  ${BLANKED_PUCCH}  8
    ...  AND  Set Test Variable  ${NR_UE_CAPABILITY}  SA_LOCKED
    ...  AND  Set Test Variable  ${LTE_DL_THROUGHPUT}  400
    ...  AND  Set Test Variable  ${NR_DL_THROUGHPUT}  400
    ...  AND  Set Test Variable  ${APN}  n26wro
    ...  AND  Set Test Variable  ${LOCAL_ENB_CONNECTION}  False
    ...  AND  Set Test Variable  ${SINGLE_BTS}  True
    ...  AND  Set Test Variable  ${LTE_CELL}  False
    ...  AND  Set Test Variable  ${INTER_RAT_SETUP}    False
    ...  AND  Set Test Variable  ${CONNECTIVITY}    gNB
    ...  AND  TC Setup
    ...  AND  Set qrxlevmin Level    MRBTS-55202/NRBTS-55202/NRCELL-2   -22  NR
    ...  AND  Set qrxlevmin Level    MRBTS-55202/LNBTS-8623/LNCEL-7/SIB-0   -44  LTE
    Run keyword  TC__IWK__dl_single_user_performance_with_concurrent_lte_and_nr_traffic_10MHz_95__CB005860_TL_DeLorean
    Map Testcase  [1][1.0] IWK__dl_single_user_performance_with_concurrent_lte_and_nr_traffic_10MHz_95__CB005860
    [Teardown]  Run Keywords
    ...  TC Teardown
    ...  AND  Set qrxlevmin Level    MRBTS-55202/NRBTS-55202/NRCELL-2   -60  NR
    ...  AND  Set qrxlevmin Level    MRBTS-55202/LNBTS-8623/LNCEL-7/SIB-0   -96  LTE
    ...  AND  Attenuator Teardown

CB008392_A_4TX_Switch_Off_TX_Paths_Verification_TL_DeLorean
    [Setup]  Run Keywords
    ...  Add Configuration ID to Reporting Portal Report
    ...  scout_testline_name=${SCOUT_TL_NAME}
    ...  AND  Attenuator Setup
    ...  AND  Set Attenuation   AHIB_CELLS   10dB
    ...  AND  Set Library Search Order  CB008392_A_4TX_Switch_Off_TX_Paths_Verification_TL_DeLorean  admin
    ...  AND  Set Test Variable  ${NR_CELL_ID}  5
    ...  AND  Set Test Variable  ${POWER_GROUP_ID}  2
    ...  AND  Set Test Variable  ${NR_UE_CAPABILITY}  SA_LOCKED
    ...  AND  Set Test Variable  ${LTE_CELL}  False
    ...  AND  TC Setup
    ...  AND  Set qrxlevmin Level    MRBTS-55202/NRBTS-55202/NRCELL-0   -22  NR
    Run keyword  TC__${TEST_NAME}
    Map Testcase  [1][1.0] RRM__4TX_Switch_Off_TX_Paths_Verification__CB008392
    [Teardown]  Run Keywords
    ...       TC Teardown
    ...  AND  Set qrxlevmin Level    MRBTS-55202/NRBTS-55202/NRCELL-0   -60  NR
    ...  AND  Attenuator Teardown

CB008224_B_SDL_SCell_Addition_-_Blind_Mode_SA
    [Setup]  Run Keywords
    ...  Add Configuration ID to Reporting Portal Report
    ...  scout_testline_name=${SCOUT_TL_NAME}
    ...  AND  Set Library Search Order  CB008224_B_SDL_SCell_Addition_-_Blind_Mode_SA
    ...  AND  Attenuator Setup
    ...  AND  Set Attenuation   AQQL_CELLS   0dB
    ...  AND  Set Attenuation   AHEGHA_CELLS   0dB
    ...  AND  Set Test Variable  ${NR_PCELL_ID}  1
    ...  AND  Set Test Variable  ${NR_SCELL_ID}  7
    ...  AND  Set Test Variable  ${CELL_ID_FOR_CALL}  904429569
    ...  AND  Set Test Variable  ${APN_CONTAINS}  n26wro
    ...  AND  Set Test Variable  ${NR_UE_CAPABILITY}  MTK
    ...  AND  Set Test Variable  ${PROFILE_FILTERS}  Use RnD parameters
    ...  AND  Set Test Variable  ${MAX_DATA_VOLUME_DL}  dlFdSchedAdditionalData.maxDataVolumeDl
    ...  AND  Set Test Variable  ${DELTA_PATH}  /home/ute/MN/UTE/robotws/testsuite/Wroclaw/RRM/VRF_WRO2_T023/testlines/DeLorean/resources/delta.json
    ...  AND  TC Setup
    Run keyword  TC__${TEST_NAME}
    Map Testcase  [1][1.0] TC21_CB008224__B_SDL_SCell_Addition_-_Blind_Mode_SA
    [Teardown]  Run Keywords
    ...       TC Teardown
    ...  AND  Attenuator Teardown

CB008224_B_n75_SDL_SCell_Addition_-_Blind_Mode_SA
    [Setup]  Run Keywords
    ...  Add Configuration ID to Reporting Portal Report
    ...  scout_testline_name=${SCOUT_TL_NAME}
    ...  AND  Set Library Search Order  CB008224_B_SDL_SCell_Addition_-_Blind_Mode_SA
    ...  AND  Attenuator Setup
    ...  AND  Set Attenuation   AHEGC_CELLS   0dB
    ...  AND  Set Attenuation   AHSB_CELLS   0dB
    ...  AND  Set Test Variable  ${NR_PCELL_ID}  3
    ...  AND  Set Test Variable  ${NR_SCELL_ID}  8
    ...  AND  Set Test Variable  ${CELL_ID_FOR_CALL}  904429571
    ...  AND  Set Test Variable  ${APN_CONTAINS}  n26wro
    ...  AND  Set Test Variable  ${NR_UE_CAPABILITY}  MTK
    ...  AND  Set Test Variable  ${PROFILE_FILTERS}  Use RnD parameters
    ...  AND  Set Test Variable  ${MAX_DATA_VOLUME_DL}  dlFdSchedAdditionalData.maxDataVolumeDl
    ...  AND  Set Test Variable  ${DELTA_PATH}
    ...  /home/ute/MN/UTE/robotws/testsuite/Wroclaw/RRM/VRF_WRO2_T023/testlines/DeLorean/resources/delta_AHSB.json
    ...  AND  TC Setup
    ...  AND  Set qrxlevmin Level    MRBTS-55202/NRBTS-55202/NRCELL-6   -22  NR
    Run keyword  TC__CB008224_B_SDL_SCell_Addition_-_Blind_Mode_SA
    Map Testcase  [1][1.0] CB008224__B_n75_SDL_SCell_Addition_-_Blind_Mode_SA
    [Teardown]  Run Keywords
    ...       TC Teardown
    ...  AND  Set qrxlevmin Level    MRBTS-55202/NRBTS-55202/NRCELL-6   -60  NR
    ...  AND  Attenuator Teardown

CB011006-A_B1_Successful_UE_attachment_and_traffic_NSA_Mode_ABIQ
    [Setup]  Run Keywords
    ...  Add Configuration ID to Reporting Portal Report
    ...  scout_testline_name=${SCOUT_TL_NAME}
    ...  AND  Attenuator Setup
    ...  AND  Set Attenuation   AHEGHA_CELLS   0dB
    ...  AND  Set Library Search Order  CB011006-A_Successful_UE_attachment_and_traffic_NSA_SA_Mode_ABIQ
    ...  AND  Set Test Variable  ${NR_CELL_N7}  7
    ...  AND  Set Test Variable  ${NR_UE_CAPABILITY}  NSA
    ...  AND  Set Test Variable  ${ATTACH_CELL_ID}  2207491
    ...  AND  Set Test Variable  ${DURATION}  300
    ...  AND  Set Test Variable  ${PM_COUNER_INTERVAL}  300
    ...  AND  Set Test Variable  ${APN}  n26wro
    ...  AND  Set Test Variable  ${TPUT_DL_256QAM_TRUE}  600Mbits/sec
    ...  AND  Set Test Variable  ${TPUT_UL_256QAM_TRUE}  190Mbits/sec
    ...  AND  Set Test Variable  ${TPUT_DL_256QAM_FALSE}  550Mbits/sec
    ...  AND  Set Test Variable  ${TPUT_UL_256QAM_FALSE}  160Mbits/sec
    ...  AND  Set Test Variable  ${PERFORM_OAM_OPERATIONS}  True
    ...  AND  Set Test Variable  ${RMOD_SERIAL_NUMBER}  BL2344H645V
    ...  AND  TC Setup
    Run keyword  TC__CB011006-A_Successful_UE_attachment_and_traffic_NSA_SA_Mode_ABIQ
    Map Testcase  [1][1.0] ${TEST_NAME}
    [Teardown]  Run Keywords
    ...       TC Teardown
    ...  AND  Attenuator Teardown

CB011006-A_B2_Successful_UE_attachment_and_traffic_SA_Mode_ABIQ
    [Setup]  Run Keywords
    ...  Add Configuration ID to Reporting Portal Report
    ...  scout_testline_name=${SCOUT_TL_NAME}
    ...  AND  Attenuator Setup
    ...  AND  Set Attenuation   AHEGHA_CELLS   0dB
    ...  AND  Set Library Search Order  CB011006-A_Successful_UE_attachment_and_traffic_NSA_SA_Mode_ABIQ
    ...  AND  Set Test Variable  ${NR_CELL_N7}  7
    ...  AND  Set Test Variable  ${NR_UE_CAPABILITY}  MTK
    ...  AND  Set Test Variable  ${ATTACH_CELL_ID}  904429575
    ...  AND  Set Test Variable  ${DURATION}  300
    ...  AND  Set Test Variable  ${PM_COUNER_INTERVAL}  300
    ...  AND  Set Test Variable  ${APN}  n26wro
    ...  AND  Set Test Variable  ${TPUT_DL_256QAM_TRUE}  400Mbits/sec
    ...  AND  Set Test Variable  ${TPUT_UL_256QAM_TRUE}  220Mbits/sec
    ...  AND  Set Test Variable  ${TPUT_DL_256QAM_FALSE}  400Mbits/sec
    ...  AND  Set Test Variable  ${TPUT_UL_256QAM_FALSE}  200Mbits/sec
    ...  AND  Set Test Variable  ${PERFORM_OAM_OPERATIONS}  False
    ...  AND  Set Test Variable  ${RMOD_SERIAL_NUMBER}  BL2344H645V
    ...  AND  TC Setup
    Run keyword  TC__CB011006-A_Successful_UE_attachment_and_traffic_NSA_SA_Mode_ABIQ
    Map Testcase  [1][1.0] ${TEST_NAME}
    [Teardown]  Run Keywords
    ...       TC Teardown
    ...  AND  Attenuator Teardown

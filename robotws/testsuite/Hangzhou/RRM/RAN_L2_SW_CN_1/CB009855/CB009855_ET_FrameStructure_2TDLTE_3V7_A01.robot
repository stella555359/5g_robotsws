*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${FULL_SCF_TDD_9855_3V7}    iphy_file=${3T2F_IPHY}
#...               swconfig_param=${SWCONFIG_PARAM}
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${WTS_CFG_3T3F}
#...               AND    Suite Setup Start WTS And Check OnAir    wts_cfg_file=${WTS_CFG_3T3F}
#Suite Teardown    Common Suite Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    CRT
#...               SBTS00    CN1_SQ6    CB009855
#Resource         ./Resources/CB009855_resource.robot
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#### Suite level ###
#${SWCONFIG_PARAM}               0x590004=4;0x5900a8=1
#${SCF_PATH}                     ${CURDIR}/Config
#${FULL_SCF_TDD_9855_3V7}        Full_SCF_CB009855_A_TDLTE_TDLTE_3V7.xml
#${WTS_CFG_3T3F}                 basic_3T_3F.cfg
#${WTS_LOCAL}                    ${CURDIR}/Resources/wts
#${3T2F_IPHY}                    ${CURDIR}/Resources/wts/iphy_3T_3F.xml
#@{LOG_NAME_LIST}                snapshot    btsLog
#@{LOG_NAME_SUITE_SETUP_ASIK}    snapshot
#### A001 ###
#${DELTA_SCF_A001}               Delta_scf_A001.json
#@{5CC_UE_LIST_001}              2
#@{5CC_SCELL_PCI_001}            51    52    53    54
#@{5CC_SCELL_PCI_LIST_001}       ${5CC_SCELL_PCI_001}
#${5CC_DL_DATA_001}              1700
#${5CC_UL_DATA_001}              200
#${CC_NUM}                       5
#@{5CC_EXP_UL_TPUT_LIST_001}     100    10
#@{5CC_EXP_DL_TPUT_LIST_001}     800    50    250    250    50
#${BIP_PCAP_NAME}                5GBipL2L1_filtering_off.pcap
#${BIP_CSV_NAME}                 5GBipL2L1_filtering_off.csv
#@{BIP_CSV_COLUMN_NAME_001}      3gpp.subcellid    3gpp.sfn    3gpp.slot    UlData_pucchReceiveReqPucchResource_t.nANPucch
#...                             UlData_pucchReceiveReqPucchResource_t.numOfBitsOfUciInformation
#...                             UlData_pucchReceiveRespPsPucchResource_t.crc    UlData_pucchReceiveRespPsPucchResource_t.pucchFormat
#...                             uci.pucch.ucibits    uci.an    uci.sr    uci.ri    uci.pmi1
#...                             UlData_puschReceiveReqGrant_t.numOfUciCsiPart1Bits    UlData_puschReceiveReqGrant_t.numOfUciAckBits
#...                             uci.pusch.part1bits    data.data    uci.primaryBeamIdx    uci.seconderBeamIdx    uci.primaryBeamRSRP
#...                             uci.differentialRSRP    uci.cri    uci.ri    uci.li    uci.pmi1_1    uci.pmi1_2    uci.pmi1_3
#...                             uci.pmi2    uci.cqi    UlData_UePuschReceiveRespPs_t.csiPart1CrcCheck
#${BIP_FILTER_001}               uldata_puschreceivereq||uldata_puschreceiverespps||uldata_puschreceiverespharqd||
#...                             itf_l2_ps_peerctrl_pcellpucchpreallocationind||uldata_pucchreceivereq||
#...                             uldata_pucchreceiverespharqd||uldata_pucchreceiverespps
#${PREFERENCE_NAME_001}          preferences
#@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}
#
##### A008 ############
#
#*** Test Cases ***
#CB009855-ET-A001_Verify_3T2F_DL_CA_With_Harqbit_Lessthan_18_PucchResSet2_SemiStatic7vs3__BlindAct_BF_Disabled_DL_trf
#    [Tags]    Owner_naliu
#    [Setup]    Run Keywords    Clear Egate
#    ...    AND    Test Setup Update GNB    scf_file=${DELTA_SCF_A001}
#    ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${WTS_CFG_3T3F}
#    ...    AND    Suite Setup Start WTS And Check OnAir    wts_cfg_file=${WTS_CFG_3T3F}
#    ...    AND    Common Test Setup
#    SA Multi UE Attach With Scell Blind Addition    ${5CC_UE_LIST_001}    ${5CC_SCELL_PCI_LIST_001}    ${CC_NUM}
#    Override All UE RI For TDD Pcell 4Layer    ${5CC_UE_LIST_001}
#    Trigger DL Then UL Traffic And Collect Logs    ${5CC_UE_LIST_001}    ${5CC_DL_DATA_001}    ${5CC_UL_DATA_001}
#    Verify AN CSI On PUCCH And PUSCH
#    Verify PUCCH Resourset2
#    [Teardown]    Test Teardown Recover Env    scf_file=${scf_test_bak_file}
#
#*** Keywords ***
#
#
#Verify PUCCH Resourset2
#    Save Egate Log    ${TEST_LOG_DIRECTORY}/egate1/
#    Run Keyword And Continue On Failure    ta_a2a.Check Log With Au2anlysis    ${CURDIR}${/}A2A/CB009855_A${/}CB009855_A001_1_RRC_Bip_PUCCH.ini
#    ...    p    save_log_directory=${TEST_LOG_DIRECTORY}/
#
#Verify AN CSI On PUCCH And PUSCH
#    Covert 2BIP To Csv    ${BIP_PCAP_NAME}    ${BIP_CSV_NAME}    ${BIP_FILTER_001}    ${BIP_CSV_COLUMN_NAME_001}
#    ...    ${PREFERENCE_NAME_001}
#    Run Keyword And Continue On Failure    ta_a2a.Check Log With Au2anlysis    ${CURDIR}${/}A2A/CB009855_A${/}CB009855_A001_2_Tti_PUCCH.ini
#    ...    i    save_log_directory=${TEST_LOG_DIRECTORY}/ttitrace_streaming1
#    Run Keyword And Continue On Failure    ta_a2a.Check Log With Au2anlysis    ${CURDIR}${/}A2A/CB009855_A${/}CB009855_A001_3_Tti_NackRatio.ini
#    ...    i    save_log_directory=${TEST_LOG_DIRECTORY}/ttitrace_streaming1
#    Run Keyword And Continue On Failure    ta_a2a.Check Log With Au2anlysis    ${CURDIR}${/}A2A/CB009855_A${/}CB009855_A001_3_Tti_NackRatio.ini
#    ...    i    save_log_directory=${TEST_LOG_DIRECTORY}/ttitrace_streaming2
#    Run Keyword And Continue On Failure    ta_a2a.Check Log With Au2anlysis    ${CURDIR}${/}A2A/CB009855_A${/}CB009855_A001_2_Tti_PUSCH.ini
#    ...    i    save_log_directory=${TEST_LOG_DIRECTORY}/ttitrace_streaming2
#    Run Keyword And Continue On Failure    ta_a2a.Check Log With Au2anlysis    ${CURDIR}${/}A2A/CB009855_A${/}CB009855_A001_1_RRC_Bip_PUCCH.ini
#    ...    i    save_log_directory=${TEST_LOG_DIRECTORY}/Bip1
#    Run Keyword And Continue On Failure    ta_a2a.Check Log With Au2anlysis    ${CURDIR}${/}A2A/CB009855_A${/}CB009855_A001_1_Bip_PUSCH.ini
#    ...    i    save_log_directory=${TEST_LOG_DIRECTORY}/Bip2
#
#Trigger DL Then UL Traffic And Collect Logs
#    [Arguments]    ${5CC_UE_LIST}    ${5CC_DL_DATA}    ${5CC_UL_DATA}
#    SA Multi UE Start DL Traffic    ${5CC_UE_LIST}    ${5CC_DL_DATA}
#    Start Gnb BIP Log
#    Check Multi UE DLCA Cell L1 Tput    ${5CC_UE_LIST_001}    ${5CC_EXP_DL_TPUT_LIST_001}    ${CC_NUM}
#    Start Ttitrace With Streaming Mode
#    Sleep    2s    reason=capture short ttitracelog
#    Stop Ttitrace    l2stream3_ttitrace    ${TEST_LOG_DIRECTORY}/ttitrace_streaming1/
#    Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}/Bip1
#    SA Multi UE Start UL Traffic    ${5CC_UE_LIST}    ${5CC_UL_DATA}
#    Sleep    10s    reason=wait trf stable
#    Start Gnb BIP Log
#    Start Ttitrace With Streaming Mode
#    Sleep    2s    reason=capture short ttitracelog
#    Stop Ttitrace    l2stream3_ttitrace    ${TEST_LOG_DIRECTORY}/ttitrace_streaming2/
#    Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}/Bip2
#    Check Multi UE DLCA Cell L1 Tput    ${5CC_UE_LIST_001}    ${5CC_EXP_DL_TPUT_LIST_001}    ${CC_NUM}
#    Check Multi UE ULCA Cell L1 Tput    ${5CC_UE_LIST_001}    ${5CC_EXP_UL_TPUT_LIST_001}    ${CC_NUM}
#    Decode Ttitrace Log    ${TEST_LOG_DIRECTORY}/ttitrace_streaming1/
#    Decode Ttitrace Log    ${TEST_LOG_DIRECTORY}/ttitrace_streaming2/
#
#Covert 2BIP To Csv
#    [Arguments]    ${bip_file_name}    ${csv_file_name}    ${bip_filter}    ${csv_title_list}    ${PREFERENCE_name}
#    Copy Preference For MCShark    ${CURDIR}/Resource/A001/${PREFERENCE_name}
#    ${BIP_pcap_dir1}    Set Variable    ${TEST_LOG_DIRECTORY}/Bip1/${bip_file_name}
#    ${BIP_pcap_dir2}    Set Variable    ${TEST_LOG_DIRECTORY}/Bip2/${bip_file_name}
#    Convert BIP To CSV By MCShark    ${BIP_pcap_dir1}    ${TEST_LOG_DIRECTORY}/Bip1/${csv_file_name}    ${bip_filter}    ${csv_title_list}
#    Convert BIP To CSV By MCShark    ${BIP_pcap_dir2}    ${TEST_LOG_DIRECTORY}/Bip2/${csv_file_name}    ${bip_filter}    ${csv_title_list}

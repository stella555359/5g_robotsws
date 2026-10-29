*** Settings ***
Documentation    ...
#Suite Setup       Suite Setup Update GNB
#Suite Teardown    Common Suite Teardown    debug
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    SBTS00    CN1_SQ6    CB009855
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#### Suite level ###
#${SCF_PATH}                     ${CURDIR}/Config
#${WTS_CFG_3T3F}                 basic_3T_3F.cfg
#${WTS_LOCAL}                    ${CURDIR}/Resources/wts
#${3T2F_IPHY}                    ${CURDIR}/Resources/wts/iphy_3T_3F.xml
#@{LOG_NAME_LIST}                snapshot    btsLog
#@{LOG_NAME_SUITE_SETUP_ASIK}    snapshot
#### A007 ###
#${FULL_SCF_CB009855_A007}       Full_SCF_CB009855_A_TDLTE_1V4_3V7.xml
#@{5CC_UE_LIST_007}              2
#@{5CC_SCELL_PCI_007}            51    52    53    54
#@{5CC_SCELL_PCI_LIST_007}       ${5CC_SCELL_PCI_007}
#${5CC_DL_DATA_007}              1700
#${5CC_UL_DATA_007}              200
#${CC_NUM}                       5
#@{5CC_EXP_DL_TPUT_LIST_007}     300    50    300    250    50
#@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}
#*** Test Cases ***
#CB009855-ET-A007_Verify_3T2F_DL_CA_With_Harqbit_Greaterthan_18_Diff_FrameStruture_DRX_DL_Trf
#    [Tags]    Owner_fanjin    CRT
#    [Setup]    Run Keywords    Test Setup Update GNB    scf_file=${FULL_SCF_CB009855_A007}    iphy_file=${3T2F_IPHY}
#    ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${WTS_CFG_3T3F}
#    ...    AND    Suite Setup Start WTS And Check OnAir
#    SA Multi UE Attach With Scell Blind Addition    ${5CC_UE_LIST_007}    ${5CC_SCELL_PCI_LIST_007}    ${CC_NUM}
#    Repeated Start Stop DL Traffic And Collect Logs    ${5CC_UE_LIST_007}    ${5CC_DL_DATA_007}
#    Verify AN CSI On PUCCH
#    Verify No DTX During DRX Cycle
#    # [Teardown]    Test Teardown Recover Env    scf_file=${scf_test_bak_file}
#
#*** Keywords ***
#Repeated Start Stop DL Traffic And Collect Logs
#    [Arguments]    ${5CC_UE_LIST}    ${5CC_DL_DATA}
#    SA Multi UE Start DL Traffic    ${5CC_UE_LIST}    ${5CC_DL_DATA}
#    Sleep    5s    reason=wait trf stable
#    Start Gnb BIP Log
#    Check Multi UE DLCA Cell L1 Tput    ${5CC_UE_LIST_007}    ${5CC_EXP_DL_TPUT_LIST_007}    ${CC_NUM}
#    Start Ttitrace With Streaming Mode
#    Sleep    2s    reason=capture short ttitracelog
#    Stop Ttitrace    l2stream3_ttitrace    ${TEST_LOG_DIRECTORY}/ttitrace_streaming1/
#    Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}/Bip1
#    SA Multi UE Stop DL Traffic    ${5CC_UE_LIST}
#    Sleep    2s    reason=wait trf stable
#    Start Gnb BIP Log
#    Start Ttitrace With Streaming Mode
#    SA Multi UE Start DL Traffic    ${5CC_UE_LIST}    ${5CC_DL_DATA}
#    Sleep    2s    reason=capture short ttitracelog
#    Stop Ttitrace    l2stream3_ttitrace    ${TEST_LOG_DIRECTORY}/ttitrace_streaming2/
#    Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}/Bip2
#    Sleep    5s    reason=wait trf stable
#    Check Multi UE DLCA Cell L1 Tput    ${5CC_UE_LIST_007}    ${5CC_EXP_DL_TPUT_LIST_007}    ${CC_NUM}
#    Decode Ttitrace Log    ${TEST_LOG_DIRECTORY}/ttitrace_streaming1/
#    Decode Ttitrace Log    ${TEST_LOG_DIRECTORY}/ttitrace_streaming2/
#
#Verify AN CSI On PUCCH
#    Run Keyword And Continue On Failure    ta_a2a.Check Log With Au2anlysis    ${CURDIR}${/}A2A/CB009855_A${/}A007_Tti_PUCCH.ini
#    ...    i    save_log_directory=${TEST_LOG_DIRECTORY}/ttitrace_streaming2
#
#Verify No DTX During DRX Cycle
#    Run Keyword And Continue On Failure    ta_a2a.Check Log With Au2anlysis    ${CURDIR}${/}A2A/CB009855_A${/}A007_Tti_DTX.ini
#    ...    i    save_log_directory=${TEST_LOG_DIRECTORY}/ttitrace_streaming2
#
#

*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${FULL_SCF_TDD_9855_TDLTE_1V4}    iphy_file=${3T2F_IPHY}
#...               swconfig_param=${SWCONFIG_PARAM}
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${WTS_CFG_3T3F}
#...               AND    Suite Setup Start WTS And Check OnAir    wts_cfg_file=${WTS_CFG_3T3F}
#Suite Teardown    Common Suite Teardown    debug
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    CRT
#...               SBTS00    CN1_SQ6    CB009855
#Resource         ./Resources/CB009855_resource.robot
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#### Suite level ###
#${SWCONFIG_PARAM}               0x590004=4;0x5900a8=1
#${SCF_PATH}                     ${CURDIR}/Config
#${FULL_SCF_TDD_9855_TDLTE_1V4}    Full_SCF_CB009855_A_tdlte_4v1_4v1.xml
#${WTS_CFG_3T3F}                 basic_3T_3F_tdlte_1v4.cfg
#${WTS_LOCAL}                    ${CURDIR}/Resources/wts
#${3T2F_IPHY}                    ${CURDIR}/Resources/wts/iphy_tdlte_1v4.xml
#@{LOG_NAME_LIST}                snapshot    btsLog
#@{LOG_NAME_SUITE_SETUP_ASIK}    snapshot
#@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}
#
#### B1602 #########
#${DELTA_SCF_1602}              Delta_scf_B1602.json
#@{5CC_UE_LIST_1602}             2
#@{5CC_SCELL_PCI_1}             51    52    53    54
#@{SCELL_PHYSICALID_LIST_1602}    ${5CC_SCELL_PCI_1}
#${5CC_DL_TRF_1602}              2000
#${5CC_UL_TRF_1602}              100
#${2CC_DL_TRF_1602}              2000
#${2CC_UL_TRF_1602}              100
#@{5CC_EXP_DL_TPUT_LIST_1602}    100    10    100    100    10
#@{5CC_EXP_UL_TPUT_LIST_1602}    10    10
#${2CC_SCELL_INFO}               ('2', '52', '41')
#${CC_NUM}                       5
#
#*** Test Cases ***
#CB009855-ET-B1602_Verify_3T2F_5CC_UE_IWK_UL_Slot_Muting
#    [Tags]    Owner_naliu
#    [Setup]    Common Test Setup
#    Run Keyword And Continue On Failure    UE Attach and 5CC DLUL Tput Check
#    Run Keyword And Continue On Failure    Start Gnb BIP Log
#    Run Keyword And Continue On Failure    StartAPBip
#    Run Keyword And Continue On Failure    Capture Convert Format Ttitrace With Streaming Mode    1s    ${TEST_LOG_DIRECTORY}/ttitrace_streaming1/
#    Run Keyword And Continue On Failure    Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}/Bip1
#    Run Keyword And Continue On Failure    StopAPBip
#    Run Keyword And Continue On Failure    CollectAPBip    ${TEST_LOG_DIRECTORY}/Bip1/
#    [Teardown]    Common Test Teardown
#
#*** Keywords ***
#
#
#UE Attach and 5CC DLUL Tput Check
#    SA Multi UE Attach With Scell Blind Addition    ${5CC_UE_LIST_1602}    ${SCELL_PHYSICALID_LIST_1602}    ${CC_NUM}
#    Override All UE RI For TDD Pcell 4Layer    ${5CC_UE_LIST_1602}
#    SA Multi UE Start DL And UL Traffic    ${5CC_UE_LIST_1602}    ${5CC_DL_TRF_1602}    ${5CC_UL_TRF_1602}
#    Sleep    5s    reason=stable Tput
#    Check Multi UE DLCA And 2CCULCA L1 Cell tput     ${5CC_UE_LIST_1602}    ${5CC_EXP_UL_TPUT_LIST_1602}
#    ...    ${5CC_EXP_DL_TPUT_LIST_1602}   ${CC_NUM}
#

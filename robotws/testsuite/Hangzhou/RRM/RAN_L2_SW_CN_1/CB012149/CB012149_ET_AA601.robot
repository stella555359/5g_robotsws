*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${FULL_SCF}    iphy_file=${IPHY_FILE}    swconfig_param=${SWCONFIG_PARAM}
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}
#Suite Teardown    Common Suite Teardown
#Force Tags        CLOUD_5G_I_LPQ_AP_LOO    Owner_qiqluo
#...               SBTS00    CB012149    RAN_5G    RAN_5G_TDD    CRT
## Resource        Resources/CB012149_Common.robot
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${SWCONFIG_PARAM}                0x590072=1;0x890001=1;0x890003=1;0x890004=1
#${SCF_PATH}                      ${CURDIR}/Config
#${FULL_SCF}                      CB012149_AA601_scfc.xml
#${IPHY_FILE}                     ${CURDIR}/Resources/wts/iphy_4F_2T_AA.xml
#${WTS_LOCAL}                     ${CURDIR}/Resources/wts
#${WTS_CFG}                       CB012149_AA501_601.cfg
#${4CC_DL_DATA}                   1000
#${4CC_UL_DATA}                   150
#${EXP_DL_TPUT}                   3
#${EXP_UL_TPUT}                   3
#${NON_ULCA_EXP_TPUT}             90
#@{4CC_EXP_DL_TPUT_LIST}          1    1    1    1
#@{2CC_EXP_DL_TPUT_LIST}          1    1
#@{2CC_EXP_UL_TPUT_LIST}          1    1
#@{4CC_UE_LIST}                   10
#@{PCELL_ID_LIST}                 55
#@{1T1F_SCELL_PHYSICALID_1}       54
#@{1T1F_SCELL_PHYSICALID_LIST}    ${1T1F_SCELL_PHYSICALID_1}
#@{2T2F_SCELL_PHYSICALID_LIST}    50    52    53
#${A1THRESHOLD_FDD}               75
#${A1THRESHOLD_TDD}               105
#${A2THRESHOLD_FDD}               36
#
#*** Test Cases ***
#CB012149_ET_AA601_SingleUE_4CC_Scell_Selection_With_UL_Tx_Switching_And_Non_ULCA
#    [Setup]    Run Keywords    Wait Until Keyword Succeeds    300sec    15sec    Verify BTS Is Configured
#    ...    AND    Suite Setup Start WTS And Check OnAir
#    ...    AND    Common Test Setup
#    SA Multi UE Attach With Scell A1 Addition    ${4CC_UE_LIST}    ${PCELL_ID_LIST}    ${1T1F_SCELL_PHYSICALID_LIST}    ${A1THRESHOLD_FDD}    2
#    SA Multi UE Start DL And UL Traffic    ${4CC_UE_LIST}    ${4CC_DL_DATA}    ${4CC_UL_DATA}
#    Sleep    15s    reason=wair for data is stable
#    Check Multi UE DLCA And 2CCULCA L1 Cell Tput    ${4CC_UE_LIST}    ${2CC_EXP_UL_TPUT_LIST}    ${2CC_EXP_DL_TPUT_LIST}    2
#    Trigger A2 Scell Release    ${4CC_UE_LIST[0]}    1    ${A2THRESHOLD_FDD}    54    2
#    Trigger A1 Scell Addition    ${4CC_UE_LIST[0]}    ${A1THRESHOLD_TDD}    ${PCELL_ID_LIST[0]}
#    Check SA All Scell PhysicalID With UE ID    ${4CC_UE_LIST[0]}    ${2T2F_SCELL_PHYSICALID_LIST}    4
#    SA Multi UE Start DL And UL Traffic    ${4CC_UE_LIST}    ${4CC_DL_DATA}    ${4CC_UL_DATA}
#    Sleep    15s    reason=wair for data is stable
#    Check Multi UE DLCA And 2CCULCA L1 Cell Tput    ${4CC_UE_LIST}    ${2CC_EXP_UL_TPUT_LIST}    ${4CC_EXP_DL_TPUT_LIST}    4
#    Capture Convert Format Ttitrace With Streaming Mode    1s
#    SA Multi UE Stop DL And UL Traffic    ${4CC_UE_LIST}
#    [Teardown]    Common Test Teardown
#

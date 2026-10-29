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
#${FULL_SCF}                      CB012149_AA501_scfc.xml
#${IPHY_FILE}                     ${CURDIR}/Resources/wts/iphy_4F_2T_AA.xml
#${WTS_LOCAL}                     ${CURDIR}/Resources/wts
#${WTS_CFG}                       CB012149_AA501_601.cfg
#${3CC_DL_DATA}                   1000
#${3CC_UL_DATA}                   150
#${EXP_DL_TPUT}                   3
#${EXP_UL_TPUT}                   3
#${NON_ULCA_EXP_TPUT}             90
#@{3CC_EXP_DL_TPUT_LIST}          1    1    1
#@{2CC_EXP_UL_TPUT_LIST}          1    1
#@{3CC_UE_LIST}                   6    7    8    9
#@{PCELL_ID_LIST}                 55    55    55    55
#@{1T2F_SCELL_PHYSICALID_1}       51    53
#@{1T2F_SCELL_PHYSICALID_2}       50    51
#@{1T2F_SCELL_PHYSICALID_3}       51    53
#@{1T2F_SCELL_PHYSICALID_4}       50    53
#@{1T2F_SCELL_PHYSICALID_LIST}    ${1T2F_SCELL_PHYSICALID_1}    ${1T2F_SCELL_PHYSICALID_2}
#...                              ${1T2F_SCELL_PHYSICALID_3}    ${1T2F_SCELL_PHYSICALID_4}
#@{2T1F_SCELL_PHYSICALID_1}       52    53
#@{2T1F_SCELL_PHYSICALID_2}       51    52
#@{2T1F_SCELL_PHYSICALID_3}       52    53
#@{2T1F_SCELL_PHYSICALID_4}       51    52
#@{2T1F_SCELL_PHYSICALID_LIST}    ${2T1F_SCELL_PHYSICALID_1}    ${2T1F_SCELL_PHYSICALID_2}
#...                              ${2T1F_SCELL_PHYSICALID_3}    ${2T1F_SCELL_PHYSICALID_4}
#${A1THRESHOLD_FDD}               75
#${A1THRESHOLD_TDD}               105
#${A2THRESHOLD_FDD}               36
#@{L2STREAM_COMPONENT_CONFIG}    &{TTITRACE_CONFIG_L2PS}
#
#*** Test Cases ***
#CB012149_ET_AA501_MultiUE_Scell_Selection_With_ULCA_And_UL_Tx_Switching
#    [Setup]    Run Keywords    Wait Until Keyword Succeeds    300sec    15sec    Verify BTS Is Configured
#    ...    AND    Suite Setup Start WTS And Check OnAir
#    ...    AND    Common Test Setup
#    SA Multi UE Attach With Scell A1 Addition    ${3CC_UE_LIST}    ${PCELL_ID_LIST}    ${1T2F_SCELL_PHYSICALID_LIST}    ${A1THRESHOLD_FDD}    3
#    SA Multi UE Start DL And UL Traffic    ${3CC_UE_LIST}    ${3CC_DL_DATA}    ${3CC_UL_DATA}
#    Sleep    15s    reason=wair for data is stable
#    Check Multi UE DLCA And 2CCULCA L1 Cell Tput    ${3CC_UE_LIST}    ${2CC_EXP_UL_TPUT_LIST}    ${3CC_EXP_DL_TPUT_LIST}    3
#    Trigger A2 Scell Release    ${3CC_UE_LIST[0]}    1    ${A2THRESHOLD_FDD}    51    2
#    Trigger A2 Scell Release    ${3CC_UE_LIST[0]}    2    ${A2THRESHOLD_FDD}    53    3
#    Trigger A2 Scell Release    ${3CC_UE_LIST[1]}    1    ${A2THRESHOLD_FDD}    50    2
#    Trigger A2 Scell Release    ${3CC_UE_LIST[1]}    2    ${A2THRESHOLD_FDD}    51    3
#    Trigger A2 Scell Release    ${3CC_UE_LIST[2]}    1    ${A2THRESHOLD_FDD}    51    2
#    Trigger A2 Scell Release    ${3CC_UE_LIST[2]}    2    ${A2THRESHOLD_FDD}    53    3
#    Trigger A2 Scell Release    ${3CC_UE_LIST[3]}    1    ${A2THRESHOLD_FDD}    50    2
#    Trigger A2 Scell Release    ${3CC_UE_LIST[3]}    2    ${A2THRESHOLD_FDD}    53    3
#    Trigger A1 Scell Addition    ${3CC_UE_LIST[0]}    ${A1THRESHOLD_TDD}    ${PCELL_ID_LIST[0]}
#    Trigger A1 Scell Addition    ${3CC_UE_LIST[1]}    ${A1THRESHOLD_TDD}    ${PCELL_ID_LIST[1]}
#    Trigger A1 Scell Addition    ${3CC_UE_LIST[2]}    ${A1THRESHOLD_TDD}    ${PCELL_ID_LIST[2]}
#    Trigger A1 Scell Addition    ${3CC_UE_LIST[3]}    ${A1THRESHOLD_TDD}    ${PCELL_ID_LIST[3]}
#    SA Multi UE Start DL And UL Traffic    ${3CC_UE_LIST}    ${3CC_DL_DATA}    ${3CC_UL_DATA}
#    Sleep    15s    reason=wair for data is stable
#    Check Multi UE DLCA And 2CCULCA L1 Cell Tput    ${3CC_UE_LIST}    ${2CC_EXP_UL_TPUT_LIST}    ${3CC_EXP_DL_TPUT_LIST}    3
#    Capture Convert Format Ttitrace With Streaming Mode    1s
#    SA Multi UE Stop DL And UL Traffic    ${3CC_UE_LIST}
#    [Teardown]    Common Test Teardown
#

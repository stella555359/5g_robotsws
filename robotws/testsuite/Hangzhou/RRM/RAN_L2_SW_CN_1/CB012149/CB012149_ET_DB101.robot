*** Settings ***
Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${FULL_SCF}    iphy_file=${IPHY_FILE}    swconfig_param=${SWCONFIG_PARAM}
...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}
Suite Teardown    Common Suite Teardown
Force Tags        CLOUD_5G_I_LPQ_AP_LOO    Owner_jshen
...               SBTS00    CB012149    RAN_5G    RAN_5G_TDD    CRT
Resource          ./../CUDU_L2/common_setup_teardown.robot

*** Variables ***
${SWCONFIG_PARAM}               0x590072=1;0x890001=1;0x890003=1;0x890004=1
${SCF_PATH}                     ${CURDIR}/Config
${FULL_SCF}                     CB012149_DB101_scfc.xml
${IPHY_FILE}                    ${CURDIR}/Resources/wts/iphy_4F_2T_AB.xml
${WTS_LOCAL}                    ${CURDIR}/Resources/wts
${WTS_CFG}                      CB012149_DB101.cfg
${2CC_UL_DATA}                  175
${2CC_DL_DATA}                  700
@{2CC_EXP_UL_TPUT_LIST}         90    70
@{2CC_EXP_DL_TPUT_LIST}         300   100
@{2CC_UE_LIST}                  3
@{PCELL_ID_LIST}                52
@{2CC_SCELL_PHYSICALID_1}       54
@{2CC_SCELL_PHYSICALID_LIST}    ${2CC_SCELL_PHYSICALID_1}
${A1THRESHOLD}                  105

*** Test Cases ***
CB012149_ET_DB101_1T_1F_Tx_Switching_UL_Data_Scheduling_With_CB006086_And_5GC002396
    [Setup]    Run Keywords    Wait Until Keyword Succeeds    300sec    15sec    Verify BTS Is Configured
    ...    AND    Suite Setup Start WTS And Check OnAir
    ...    AND    Common Test Setup
    SA Multi UE Attach With Scell A1 Addition    ${2CC_UE_LIST}    ${PCELL_ID_LIST}    ${2CC_SCELL_PHYSICALID_LIST}    ${A1THRESHOLD}    2
    SA Multi UE Start DL And UL Traffic    ${2CC_UE_LIST}    ${2CC_DL_DATA}    ${2CC_UL_DATA}
    Sleep    15s    reason=wair for data is stable
    Check Multi UE DLCA And 2CCULCA L1 Cell Tput    ${2CC_UE_LIST}    ${2CC_EXP_UL_TPUT_LIST}    ${2CC_EXP_DL_TPUT_LIST}    2
    SA Multi UE Stop DL And UL Traffic    ${2CC_UE_LIST}
    [Teardown]    Common Test Teardown


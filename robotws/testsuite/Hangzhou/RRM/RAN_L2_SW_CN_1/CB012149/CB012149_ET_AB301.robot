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
${FULL_SCF}                     CB012149_AB301_scfc.xml
${IPHY_FILE}                    ${CURDIR}/Resources/wts/iphy_4F_2T_AB.xml
${WTS_LOCAL}                    ${CURDIR}/Resources/wts
${WTS_CFG}                      CB012149_AB301.cfg
${4CC_UL_DATA}                  150
@{4CC_EXP_UL_TPUT_LIST}         70    29
@{4CC_UE_LIST}                  3
@{PCELL_ID_LIST}                52
@{4CC_SCELL_PHYSICALID_1}       50    54    55
@{4CC_SCELL_PHYSICALID_LIST}    ${4CC_SCELL_PHYSICALID_1}
${A1THRESHOLD}                  105
@{L2STREAM_COMPONENT_CONFIG}    &{TTITRACE_CONFIG_L2PS}

*** Test Cases ***
CB012149_ET_AB301_1T_3F_UL_Data_UL_Tx_Switching_Single_UE_Peak_Throughput_With_PUSCH_Mapping_TypeA_256QAM
    [Setup]    Run Keywords    Wait Until Keyword Succeeds    300sec    15sec    Verify BTS Is Configured
    ...    AND    Suite Setup Start WTS And Check OnAir
    ...    AND    Common Test Setup
    SA Multi UE Attach With Scell A1 Addition    ${4CC_UE_LIST}    ${PCELL_ID_LIST}    ${4CC_SCELL_PHYSICALID_LIST}    ${A1THRESHOLD}    4
    SA Multi UE Start UL Traffic    ${4CC_UE_LIST}    ${4CC_UL_DATA}
    Sleep    15s    reason=wair for data is stable
    Check Multi UE ULCA Cell L1 tput    ${4CC_UE_LIST}    ${4CC_EXP_UL_TPUT_LIST}    4
    Capture Convert Format Ttitrace With Streaming Mode    1s
    SA Multi UE Stop DL And UL Traffic    ${4CC_UE_LIST}
    [Teardown]    Common Test Teardown


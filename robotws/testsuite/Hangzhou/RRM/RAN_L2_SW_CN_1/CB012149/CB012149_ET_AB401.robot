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
#${SWCONFIG_PARAM}               0x590072=1;0x890001=1;0x890003=1;0x890004=1
#${SCF_PATH}                     ${CURDIR}/Config
#${FULL_SCF}                     CB012149_AB401_scfc.xml
#${IPHY_FILE}                    ${CURDIR}/Resources/wts/iphy_4F_2T_AB.xml
#${WTS_LOCAL}                    ${CURDIR}/Resources/wts
#${WTS_CFG}                      CB012149_AB401_402.cfg
#${3CC_DL_DATA}                  1000
#${3CC_UL_DATA}                  150
#${NONCA_DL_DATA}                200
#${NONCA_UL_DATA}                100
#${NONCA_UE_ID}                  7
#${EXP_DL_TPUT}                  3
#${EXP_UL_TPUT}                  3
#${NON_ULCA_EXP_TPUT}            90
#@{3CC_EXP_DL_TPUT_LIST}         3    3    3
#@{2CC_EXP_UL_TPUT_LIST}         3    3
#@{3CC_UE_LIST}                  6    8
#@{PCELL_ID_LIST}                55    55
#@{3CC_SCELL_PHYSICALID_1}       50    52
#@{3CC_SCELL_PHYSICALID_2}       50    52
#@{3CC_SCELL_PHYSICALID_LIST}    ${3CC_SCELL_PHYSICALID_1}    ${3CC_SCELL_PHYSICALID_2}
#${A1THRESHOLD}                  105
#
#*** Test Cases ***
#CB012149_ET_AB401_2T_1F_UL_Tx_Switching_UE_Mixed_With_Other_Ues_PUSCH_Mapping_TypeB_64QAM
#    [Setup]    Run Keywords    Wait Until Keyword Succeeds    300sec    15sec    Verify BTS Is Configured
#    ...    AND    Suite Setup Start WTS And Check OnAir
#    ...    AND    Common Test Setup
#    SA Multi UE Attach With Scell A1 Addition    ${3CC_UE_LIST}    ${PCELL_ID_LIST}    ${3CC_SCELL_PHYSICALID_LIST}    ${A1THRESHOLD}    3
#    SA Single UE Attach    ${NONCA_UE_ID}
#    SA Multi UE Start DL And UL Traffic    ${3CC_UE_LIST}    ${3CC_DL_DATA}    ${3CC_UL_DATA}
#    SA Start DL Traffic Internal    ${NONCA_UE_ID}    1    ${NONCA_DL_DATA}
#    SA Start UL Traffic Internal    ${NONCA_UE_ID}    1    ${EXP_UL_TPUT}
#    Sleep    15s    reason=wair for data is stable
#    Check CA UE Pcell Scell Cell TPut On Target    ${NONCA_UE_ID}    dl    pcell    0    ${EXP_DL_TPUT}
#    Check CA UE Pcell Scell Cell TPut On Target    ${NONCA_UE_ID}    ul    pcell    0    ${EXP_UL_TPUT}
#    Check Multi UE DLCA And 2CCULCA L1 Cell Tput    ${3CC_UE_LIST}    ${2CC_EXP_UL_TPUT_LIST}    ${3CC_EXP_DL_TPUT_LIST}    3
#    Capture Convert Format Ttitrace With Streaming Mode    1s
#    SA Multi UE Stop DL And UL Traffic    ${3CC_UE_LIST}
#    SA Stop Data Traffic Internal    ${NONCA_UE_ID}    1
#    [Teardown]    Common Test Teardown
#

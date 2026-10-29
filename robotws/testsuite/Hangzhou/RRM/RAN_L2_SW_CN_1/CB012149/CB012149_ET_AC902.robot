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
#${FULL_SCF}                      CB012149_AC802_scfc.xml
#${IPHY_FILE}                     ${CURDIR}/Resources/wts/iphy_4F_2T_AA.xml
#${WTS_LOCAL}                     ${CURDIR}/Resources/wts
#${WTS_CFG}                       CB012149_AC801_802.cfg
#${4CC_DL_DATA}                   800
#${4CC_UL_DATA}                   150
#${NONCA_DL_DATA}                 100
#${NONCA_UL_DATA}                 100
#${EXP_DL_TPUT}                   1
#${EXP_UL_TPUT}                   1
#@{4CC_EXP_DL_TPUT_LIST}          1    1    1    1
#@{2CC_EXP_UL_TPUT_LIST}          1    1
#@{1T3F_UE_LIST}                  6
#@{1T3F_SCELL_PHYSICALID_LIST}    50    51    53
#
#*** Test Cases ***
#CB012149_ET_AC902_UL_Tx_Switching_SingleCAUE_Peak_Throughput_Interworking_With_FDD_A_SRS_PuschMappingTypeA
#    [Setup]    Run Keywords    Wait Until Keyword Succeeds    300sec    15sec    Verify BTS Is Configured
#    ...    AND    Suite Setup Start WTS And Check OnAir
#    ...    AND    Common Test Setup
#    SA 5G CA Attach    ${1T3F_UE_LIST[0]}
#    Check SA All Scell PhysicalID With UE ID    ${1T3F_UE_LIST[0]}    ${1T3F_SCELL_PHYSICALID_LIST}    4
#    SA 5G CA Attach    1    1
#    SA 5G CA Attach    2    1
#    SA Start DL Traffic Internal    ${1T3F_UE_LIST[0]}    1    ${4CC_DL_DATA}
#    SA Start UL Traffic Internal    ${1T3F_UE_LIST[0]}    1    ${4CC_UL_DATA}
#    SA Start DL Traffic Internal    1    1    ${NONCA_DL_DATA}
#    SA Start UL Traffic Internal    1    1    ${NONCA_UL_DATA}
#    SA Start DL Traffic Internal    2    1    ${NONCA_DL_DATA}
#    SA Start UL Traffic Internal    2    1    ${NONCA_UL_DATA}
#    Sleep    15s    reason=wair for data is stable
#    Check Multi UE DLCA And 2CCULCA L1 Cell Tput    ${1T3F_UE_LIST}    ${2CC_EXP_UL_TPUT_LIST}    ${4CC_EXP_DL_TPUT_LIST}    4
#    Check CA UE Pcell Scell Cell TPut On Target    1    dl    pcell    0    ${EXP_DL_TPUT}
#    Check CA UE Pcell Scell Cell TPut On Target    1    u1    pcell    0    ${EXP_UL_TPUT}
#    Check CA UE Pcell Scell Cell TPut On Target    2    dl    pcell    0    ${EXP_DL_TPUT}
#    Check CA UE Pcell Scell Cell TPut On Target    2    u1    pcell    0    ${EXP_UL_TPUT}
#    Capture Convert Format Ttitrace With Streaming Mode    1s
#    [Teardown]    Common Test Teardown
#

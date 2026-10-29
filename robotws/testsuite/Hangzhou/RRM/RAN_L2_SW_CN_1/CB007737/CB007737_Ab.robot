*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${FULL_SCF}    iphy_file=${IPHY_FILE}    swconfig_param=0x580497=1
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}
#...               AND    Suite Setup Start WTS And Check OnAir    enb_id=2    gnb_id=1
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    CRT    RAN_5G_TDD    RAN_5G    Owner_qiqluo
#...               SBTS00    SBTS23R1    SBTS22R4    CN1_SQ6    CB007737
#Resource          Resources/CB007737_Common.robot
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${SCF_PATH}                 ${CURDIR}/Config
#${FULL_SCF}                 CB007737_Ab_scfc.xml
#${IPHY_FILE}                ${CURDIR}/Resources/wts/iphy_4F_2T.xml
#${WTS_LOCAL}                ${CURDIR}/Resources/wts
#${WTS_CFG}                  CB007737_Ab.cfg
#${DL_DATA}                  100
#${UL_DATA}                  10
#${EXP_UL_TPUT}              3
#@{EXP_DL_TPUT_LIST}         3    3    3
#@{CA_UE_LIST}               1    2    3
#@{PCELL_ID_LIST}            50    53    54
#@{SCELL_PHYSICALID_1}       51    54
#@{SCELL_PHYSICALID_2}       50    51
#@{SCELL_PHYSICALID_3}       50    53
#@{SCELL_PHYSICALID_LIST}    ${SCELL_PHYSICALID_1}    ${SCELL_PHYSICALID_2}    ${SCELL_PHYSICALID_3}
#${A1THRESHOLD}              105
#
#*** Test Cases ***
#CB007737_ET_AB14_ABIO_4F2T_MultiUE_Mixcore_3CC_Tput
#    SA Multi UE Attach With Scell A1 Addition    ${CA_UE_LIST}    ${PCELL_ID_LIST}    ${SCELL_PHYSICALID_LIST}    ${A1THRESHOLD}    3
#    SA Multi UE Start DL Traffic    ${CA_UE_LIST}    ${DL_DATA}
#    SA Multi UE Start UL Traffic    ${CA_UE_LIST}    ${UL_DATA}
#    Sleep    20s    reason=Wait For DLUL Transmission
#    Check Multi UE DLCA And ULnonCA L1 Cell Tput    ${CA_UE_LIST}    ${EXP_UL_TPUT}    ${EXP_DL_TPUT_LIST}    3
#    Capture Convert Format Ttitrace With Streaming Mode    1s
#    ta_a2a.Check Log With Au2anlysis    ${CURDIR}${/}A2A/CB007737_Ab${/}CB007737_Ab.ini
#    ...    i    save_log_directory=${test_log_directory}/ttitrace_streaming
#

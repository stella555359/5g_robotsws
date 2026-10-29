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
#${SCF_PATH}                     ${CURDIR}/Config
#${FULL_SCF}                     CB007737_Ac_scfc.xml
#${IPHY_FILE}                    ${CURDIR}/Resources/wts/iphy_4F_2T.xml
#${WTS_LOCAL}                    ${CURDIR}/Resources/wts
#${WTS_CFG}                      CB007737_Ac.cfg
#${DL_DATA}                      100
#${UL_DATA}                      15
#${3CC_DL_DATA}                  400
#${4CC_DL_DATA}                  500
#${EXP_UL_TPUT}                  3
#@{2CC_EXP_DL_TPUT_LIST}         3    3
#@{3CC_EXP_DL_TPUT_LIST}         3    3    3
#@{4CC_EXP_DL_TPUT_LIST}         3    3    3    3
#@{2CC_UE_LIST}                  1    2
#@{3CC_UE_LIST}                  3    4    5
#@{4CC_UE_LIST}                  6
#@{2CC_SCELL_PHYSICALID_1}       52
#@{2CC_SCELL_PHYSICALID_2}       54
#@{3CC_SCELL_PHYSICALID_1}       51    54
#@{3CC_SCELL_PHYSICALID_2}       52    54
#@{3CC_SCELL_PHYSICALID_3}       52    55
#@{4CC_SCELL_PHYSICALID_1}       50    51    53
#@{4CC_SCELL_PHYSICALID_2}       50    51    55
#@{2CC_SCELL_PHYSICALID_LIST}    ${2CC_SCELL_PHYSICALID_1}    ${2CC_SCELL_PHYSICALID_2}
#@{3CC_SCELL_PHYSICALID_LIST}    ${3CC_SCELL_PHYSICALID_1}    ${3CC_SCELL_PHYSICALID_2}    ${3CC_SCELL_PHYSICALID_3}
#@{4CC_SCELL_PHYSICALID_LIST}    ${4CC_SCELL_PHYSICALID_1}
#
#*** Test Cases ***
#CB007737_ET_AC08_ABIO_ABIO_4F2T_MultiUE_LegacyCA_MultiCC_With_Intracore_Tput
#    SA Multi UE Attach With Scell Blind Addition    ${2CC_UE_LIST}    ${2CC_SCELL_PHYSICALID_LIST}    2
#    SA Multi UE Attach With Scell Blind Addition    ${3CC_UE_LIST}    ${3CC_SCELL_PHYSICALID_LIST}    3
#    SA Multi UE Attach With Scell Blind Addition    ${4CC_UE_LIST}    ${4CC_SCELL_PHYSICALID_LIST}    4
#    SA Multi UE Start DL Traffic    ${2CC_UE_LIST}    ${DL_DATA}
#    SA Multi UE Start UL Traffic    ${2CC_UE_LIST}    ${UL_DATA}
#    SA Multi UE Start DL Traffic    ${3CC_UE_LIST}    ${3CC_DL_DATA}
#    SA Multi UE Start UL Traffic    ${3CC_UE_LIST}    ${UL_DATA}
#    SA Multi UE Start DL Traffic    ${4CC_UE_LIST}    ${4CC_DL_DATA}
#    SA Multi UE Start UL Traffic    ${4CC_UE_LIST}    ${UL_DATA}
#    Sleep    20s    reason=Wait For ULDL Transmission
#    Check Multi UE DLCA And ULnonCA L1 Cell Tput    ${2CC_UE_LIST}    ${EXP_UL_TPUT}    ${2CC_EXP_DL_TPUT_LIST}    2
#    Check Multi UE DLCA And ULnonCA L1 Cell Tput    ${3CC_UE_LIST}    ${EXP_UL_TPUT}    ${3CC_EXP_DL_TPUT_LIST}    3
#    Check Multi UE DLCA And ULnonCA L1 Cell Tput    ${4CC_UE_LIST}    ${EXP_UL_TPUT}    ${4CC_EXP_DL_TPUT_LIST}    4
#    Capture Convert Format Ttitrace With Streaming Mode    1s
#    ta_a2a.Check Log With Au2anlysis    ${CURDIR}${/}A2A/CB007737_Ac${/}CB007737_Ac.ini
#    ...    i    save_log_directory=${TEST_LOG_DIRECTORY}/ttitrace_streaming
#

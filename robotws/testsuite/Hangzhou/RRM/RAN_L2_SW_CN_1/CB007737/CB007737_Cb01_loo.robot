*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${FULL_SCF}    iphy_file=${IPHY_FILE}    swconfig_param=${SWCONFIG_PARAM}
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}
#...               AND    Suite Setup Start WTS And Check OnAir    enb_id=2    gnb_id=1
#Suite Teardown    Common Suite Teardown
#Test Setup        Run Keywords    Common Test Setup
#...               AND    Block Cell With Admin    ${LOCKED_CELL}
#...               AND    Unblock Cell With Admin    ${LOCKED_CELL}
#...               AND    Wait Until Keyword Succeeds    2min    10s    Check Egate Log With Message    ${egate_path}    ${CELL_ON_AIR_MESSAGE}    2
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    CRT    RAN_5G_TDD    RAN_5G    Owner_qiqluo
#...               SBTS00    CN1_SQ6    CB007737
#Resource          Resources/CB007737_Common.robot
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${SWCONFIG_PARAM}               0x580497=1;0x580538=1;0x580534=0x6;0x580535=0x6;0x580536=0x4;0x580537=0x4
#${SCF_PATH}                     ${CURDIR}/Config
#${FULL_SCF}                     CB007737_Cb01_scfc_loo.xml
#${IPHY_FILE}                    ${CURDIR}/Resources/wts/iphy_4F_2T_loo.xml
#${WTS_LOCAL}                    ${CURDIR}/Resources/wts
#${WTS_CFG}                      CB007737_Cb01_loo.cfg
#${EGATE_PATH}                   /opt/iphy/latest/egate_console.log
#${LOCKED_CELL}                  MRBTS-1/NRBTS-1/NRCELL-5
#${CELL_ON_AIR_MESSAGE}          eNB 1 cell 5: SystemInformationBlockType1-NR
#${PDU_ID}                       1
#${DL_DATA}                      100
#${UL_DATA}                      50
#${3CC_DL_DATA}                  400
#@{CA_UE_LIST}                   1    2
#@{3CC_SCELL_PHYSICALID_1}       51    54
#@{3CC_SCELL_PHYSICALID_2}       50    54
#@{3CC_SCELL_PHYSICALID_LIST}    ${3CC_SCELL_PHYSICALID_1}    ${3CC_SCELL_PHYSICALID_2}
#${NONCA_START_UE_NUM}           3
#${NONCA_STOP_UE_NUM}            24
#${ENBID}                        2
#${GNBID}                        1
#
#*** Test Cases ***
#CB007737_ET_CB01_ABIO_4F2T_MultiUE_Mixcore_CA_DPA
#    SA Multi UE Attach With Scell Blind Addition    ${CA_UE_LIST}    ${3CC_SCELL_PHYSICALID_LIST}    3
#    Multi NonCA UE Attach With Blind    ${NONCA_START_UE_NUM}    ${NONCA_STOP_UE_NUM}
#    SA Multi UE Start DL Traffic    ${CA_UE_LIST}    ${3CC_DL_DATA}
#    SA Multi UE Start UL Traffic    ${CA_UE_LIST}    ${UL_DATA}
#    Start NonCA Multi SA UE Traffic    ${NONCA_START_UE_NUM}    ${NONCA_STOP_UE_NUM}    dl    ${DL_DATA}
#    Start NonCA Multi SA UE Traffic    ${NONCA_START_UE_NUM}    ${NONCA_STOP_UE_NUM}    ul    ${UL_DATA}
#    Sleep    20s    reason=Wait For ULDL Transmission
#    Capture Convert Format Ttitrace With Streaming Mode    1s
#    ta_a2a.Check Log With Au2anlysis    ${CURDIR}${/}A2A/CB007737_Cb${/}CB007737_Cb01_dl.ini
#    ...    i    save_log_directory=${TEST_LOG_DIRECTORY}/ttitrace_streaming
#    ta_a2a.Check Log With Au2anlysis    ${CURDIR}${/}A2A/CB007737_Cb${/}CB007737_Cb01_ul.ini
#    ...    i    save_log_directory=${TEST_LOG_DIRECTORY}/ttitrace_streaming
#

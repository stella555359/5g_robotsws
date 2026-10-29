*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${FULL_SCF}    iphy_file=${IPHY_FILE}
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}
#...               AND    Suite Setup Start WTS And Check OnAir    enb_id=1    gnb_id=2
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_BLLL_AP_LOO    CRT    RAN_5G_TDD    RAN_5G    Owner_jshen
#...               SBTS00    CN1_SQ6    CB006667
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${SCF_PATH}      ${CURDIR}/config
#${FULL_SCF}      CB006667_HA004_scfc.xml
#${IPHY_FILE}     ${CURDIR}/resources/wts/iphy_4T_2F.xml
#${WTS_LOCAL}     ${CURDIR}/resources/wts
#${WTS_CFG}       CB006667_HA006.cfg
#${EGATE_PATH}    /opt/iphy/latest/egate_console.log
#${PDU_ID}        1
#${DL_DATA}       2
#${UL_DATA}       3
#@{UE_ID_LIST}    1    2    3    4    5    6    7    8    9    10    81    82    83    84    85    86
#${ENBID}         2
#${GNBID}         1
#
#*** Test Cases ***
#CB006667_HA004_NonDBF_CPRI_SA_TDD_FR1_DL_UL_IncreasedFdm_16UEs_LongPucch_60M
#    SA Multi NonCA UE Attach    ${UE_ID_LIST}
#    SA Multi UE Start DL Traffic    ${UE_ID_LIST}    ${DL_DATA}
#    SA Multi UE Start UL Traffic    ${UE_ID_LIST}    ${UL_DATA}
#    Sleep    20s    reason=Wait For ULDL Transmission
#    Capture Convert Format Ttitrace With Streaming Mode    4s
#    ta_a2a.Check Log With Au2anlysis    ${CURDIR}${/}A2A${/}CB006667_HA004_TDD_dl.ini
#    ...    i    save_log_directory=${TEST_LOG_DIRECTORY}/ttitrace_streaming
#    ta_a2a.Check Log With Au2anlysis    ${CURDIR}${/}A2A${/}CB006667_HA004_TDD_ul.ini
#    ...    i    save_log_directory=${TEST_LOG_DIRECTORY}/ttitrace_streaming

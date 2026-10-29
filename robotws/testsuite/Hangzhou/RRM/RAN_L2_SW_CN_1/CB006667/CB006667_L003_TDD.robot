*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${FULL_SCF}    iphy_file=${IPHY_FILE}
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}
#...               AND    Suite Setup Start WTS And Check OnAir    enb_id=1    gnb_id=2
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_BLLL_AP_LOO    CRT    RAN_5G_TDD    RAN_5G    Owner_minmluo
#...               SBTS00    CN1_SQ6    CB006667
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${SCF_PATH}      ${CURDIR}/config
#${FULL_SCF}      CB006667_L003_scfc.xml
#${IPHY_FILE}     ${CURDIR}/resources/wts/iphy_4T_2F.xml
#${WTS_LOCAL}     ${CURDIR}/resources/wts
#${WTS_CFG}       CB006667_HA001_L001.cfg
#${EGATE_PATH}    /opt/iphy/latest/egate_console.log
#${WTS_DIR}       /opt/wts/latest
#${PDU_ID}        1
#${UL_DATA}       3
#@{UE_ID_LIST}    11    12    13    14    15    16    17    18    19    20    21    22    23    24    25    26
#${GNBID}         2
#${BEARER_ID}     2
#${TARGET_CELL_ID}    1
#
#*** Test Cases ***
#CB006667_L003_MultiBeam_eCPRI_NSA_TDD_FR1_UL_IncreasedFdm_16UEs_longPucch_40M_1subcell
#    NSA Multi NonCA UE Attach    ${UE_ID_LIST}       ${TARGET_CELL_ID}
#    NSA Multi UE Start UL Traffic    ${UE_ID_LIST}       ${UL_DATA}
#    Sleep    20s    reason=Wait For ULDL Transmission
#    Capture Convert Format Ttitrace With Streaming Mode    5s
#    ta_a2a.Check Log With Au2anlysis    ${CURDIR}${/}A2A${/}CB006667_L003_TDD_ul.ini
#    ...    i    save_log_directory=${TEST_LOG_DIRECTORY}/ttitrace_streaming
#
#
#*** Keywords ***
#NSA Multi NonCA UE Attach
#    [Arguments]    ${ue_id_list}      ${cell_id}
#    :FOR    ${ue_id}    IN    @{ue_id_list}
#    \    NSA UE Attach    ${ue_id}    ${GNB_ID}    ${cell_id}    ${BEARER_ID}
#
#NSA Multi UE Start UL Traffic
#    [Arguments]    ${ue_id_list}     ${ul_data}   ${trf_id}=1
#    :FOR    ${ue_id}    IN    @{ue_id_list}
#    \    NSA Start UL Traffic    ${ue_id}      ${BEARER_ID}    ${ul_data}    ${trf_id}
#
#NSA UE Attach
#    [Arguments]      ${ue_id}    ${GNB_ID}    ${cell_id}    ${BEARER_ID}
#    NSA LTE Attach    ${ue_id}
#    NSA 5G Attach    ${ue_id}    ${GNB_ID}    ${cell_id}    ${BEARER_ID}
#
#Detach All UE
#    [Arguments]         ${ue_id_list}
#    :FOR    ${ue_id}    IN    @{UE_ID_LIST}
#    \    NSA LTE Detach    ${ue_id}
#
#
#

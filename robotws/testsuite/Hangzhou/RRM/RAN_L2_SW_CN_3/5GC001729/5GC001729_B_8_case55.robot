# *** Settings ***
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    owner_menzheng    SBTS22R2    SBTS22R4    SBTS23R1
# ...   CLOUD_5G_KLL_AP_SA_L1B_ECPRI_CMWV
# Resource    ../resources/KISS/robot/common_resource.robot
# Resource    ../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${GNB_SWCONFIG_NAME}    gnb_swconfig.txt
# ${AP_SWCONFIG_NAME}    ap_swconfig.txt
# ${CONFIG_DIR_PATH}         ${CURDIR}/config
# ${UE_ID}                 1
# ${PDU_ID}           1
# ${GW_ID}            1
# ${SLICE_ID}          1
# ${SCFC_NAME}    SCFC_1729_2CELL_interFre_HO.xml
# ${AIRPHONE_NAME}    IPHY_AEHC.xml
# ${WTS_NAME}    WTS_1729_2CELL_interFre_HO.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${1ST_HO}    ue_measurement_send_nr id\=1 meas_id\=1 event\=A3 srsrp_nr\=11 srsrq_nr\=11 phycell_id\=381 nrsrp_nr\=30 nrsrq_nr\=30
# ${2ST_HO}    ue_measurement_send_nr id\=1 meas_id\=1 event\=A3 srsrp_nr\=11 srsrq_nr\=11 phycell_id\=50 nrsrp_nr\=30 nrsrq_nr\=30
# ${UE_DISP}    ue_disp id=1
# ${COM1}    ue_history_information_list_add_ngran id\=1 cell_type\=large nrcgi\=311:489|0x01 gnb_id\=2 time_ue_stayed_in_cell\=97
# ${COM2}    ue_history_information_list_add_ngran id\=1 cell_type\=large nrcgi\=311:489|0x01 gnb_id\=1 time_ue_stayed_in_cell\=98
# ${COM3}    ue_history_information_list id\=1 action\=commit
# ${COM4}    ue_enb_param id\=1 ue_history_list\=1
# ${COM5}    gnb_param id\=1 xn_listening_socket\=1 send_xn_setup\=true measEvent\=A3
# ${COM6}    gnb_xn_ngran_conf_update_param id\=1 reset; gnb_xn_setup_param id\=1 reset
# ${COM7}    gnb_xn_link_up gnb\=1 target\=2
# 
# 
# *** Test Cases ***
# 5GC001729_Case55_B_8_interFre_interGNB_HO_in_source_cell
# 
#     Configure TL VM ETH
#     Prepare gnb onair
#     Configure intergnb ho env
#     Set traffic type to internal
#     Attach ue with '2x2_2cc'capability to 5g cell
#     Internal send mutiple trf '4' for each '175M' DL data
#     ${original_tput}    Get cell throughput
#     ${gnb1_id}    ${cell1_id}    Get and check hand over result    1st_ho    ${1ST_HO}
#     ${gnb2_id}    ${cell2_id}    Get and check hand over result    2st_ho    ${2ST_HO}
#     Check ho success and tput correct    ${original_tput}    ${gnb1_id}    ${gnb2_id}    ${cell1_id}    ${cell2_id}
#     Trigger and check HO Fail    HO_Fail    ${original_tput}
# 	
# 	
# *** Keywords ***
# Configure TL VM ETH
#     Log To Console    Configure VM interfaces...
#     OperatingSystem.Run    sudo ip addr add 10.0.1.124/24 dev eth3
#     OperatingSystem.Run    sudo ip addr add 10.0.1.125/24 dev eth3
#     OperatingSystem.Run    sudo ip addr add 10.0.2.92/24 dev eth4
#     OperatingSystem.Run    sudo ip addr add 10.0.2.121/24 dev eth4
# 	
# Configure intergnb ho env
#     airphone execute egate command    ${COM1}
#     airphone execute egate command    ${COM2}
#     airphone execute egate command    ${COM3}
#     airphone execute egate command    ${COM4}
#     airphone execute egate command    ${COM5}
#     airphone execute egate command    ${COM6}
#     airphone execute egate command    ${COM7}
# 	
# Check ho success and tput correct
#     [Arguments]    ${original_tput}    ${gnb1_id}    ${gnb2_id}    ${cell1_id}    ${cell2_id}
#     ${ho_tput}    Get cell throughput
#     should be true    ${cell1_id} == ${cell2_id}
#     should be true    ${gnb1_id} == 1
#     should be true    ${gnb2_id} == 2
#     should be true    0 <= ${ho_tput}-${original_tput} <= 50000
# 
# Trigger ue hand over
#     [Arguments]    ${command}
#     airphone_execute_egate_command    ${command}
#     Wait '3s' for stabible
# 
# Get cell throughput
#     Wait '3s' for stabible
#     ${dl_tput}    Airphone SA Get Throughput    ${UE_ID}    DL    ${PDU_ID}
#     [Return]    ${dl_tput}
# 
# Get and check hand over result
#     [Arguments]    ${ho}    ${ho_command}
#     Wait '5s' for stabible
#     Airphone cleanup egate console log
#     Start capture gnb and ap syslog in '${ho}' file
# #    Start collect ttitrace
#     Trigger ue hand over    ${ho_command}
# #    Wait for '5s' to stop ttitrace with name'${ho}'
#     Stop capture gnb and ap syslog in '${ho}' file
#     airphone execute egate command    ${ue_disp}    pass_regexp=opc_key
#     Collect AP egate log    ${ho}
#     ${gnb_id}    ${cell_id}    get_ue_disp    ${TEST_LOG_DIRECTORY()}/All/${ho}_egate
#     [Return]    ${gnb_id}    ${cell_id}
# 	
# Trigger and check HO Fail
#     [Arguments]    ${ho}    ${original_tput}
# 	Airphone cleanup egate console log
# 	Start capture gnb and ap syslog in 'ho_failure' file
# 	airphone_execute_egate_command    gnb_xn_handover_preparation_param id\=1 action\=force_failure
# 	Wait '2s' for stabible
# 	airphone_execute_egate_command    ${1ST_HO}
#     Stop capture gnb and ap syslog in '${ho}' file
#     airphone_execute_egate_command    ${ue_disp}
#     ${ho_tput}    Get cell throughput
#     Collect AP egate log    ${ho}
#     ${gnb_id}    ${cell_id}    get_ue_disp    ${TEST_LOG_DIRECTORY()}/All/${ho}_egate
#     should be true    ${gnb_id} == 2
#     should be true    ${cell_id} == 1
#     should be true    0 <= ${ho_tput}-${original_tput} <= 50000
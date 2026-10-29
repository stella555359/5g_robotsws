# *** Settings ***
# Documentation     10781 features.
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        QCD_MN_RAN    QCP_RAN_VRF    CRT    CLOUD_FCC_CUS_A    SBTS00    RAN_4G    RAN_4G_TDD    CLOUD_FCC_CUS
# Resource          ../../resources/KISS/robot/4g_common_resource.robot
# 
# *** Variables ***
# ${scfc_path}    ${CURDIR}${/}config_file${/}SCFC_CB010781_FSMF_case10.xml
# ${yaml_config}    ${CURDIR}${/}config_file${/}CUS_CB010781_FSMF_case10.yaml
# ${CUS_IP}         192.168.200.1
# ${FCT_IP}         192.168.255.1
# ${FTM_IP}         192.168.255.129
# ${cell_onair}     ${EMPTY}
# ${DL_THROUGHPUT_LOWER_THRESHOLD2cc}    100000
# ${DL_THROUGHPUT_LOWER_THRESHOLD3cc}    200000
# ${UE_INDEX_1}     1
# ${UE_INDEX_2}     2
# ${LOCAL_SOURCE_CELL11}    DN:NE-LNBTS-1/LNCEL-11/MCC-262/MNC-03
# @{swconfig}         0x340000:5   0x10041:5
# @{COUNTER_LIST}    M8046C0    M8046C1    M8046C2    M8046C3    M8046C4
# ...               M8047C0    M8047C1    M8047C2    M8047C3    M8047C4    M8047C5
# ...               M8048C4
# 
# *** Test Cases ***
# CB010781_A_case10_PM counter check for QCI-67 GBR bearer
#     Add RD
#     Prepare Enb Onair   ${scfc_path}    ${yaml_config}
#     Create aliases
#     Attach UE
#     Start data traffic
#     run keyword and continue on failure    Verify throughput
#     run keyword and continue on failure    Wait and check PMQAP PM counter
#     setup_enb_ttitrace    log_path=${TEST LOG DIRECTORY()}/macps_ttitrace    alias=enb1_ttitrace
#     start_enb_ttitrace    node_type=ALL    cell_id=ALL    alias=enb1_ttitrace
#     sleep    5
#     stop_and_decode_enb_ttitrace    alias=enb1_ttitrace
# 	Check ttitrace no bler
#     Stop data traffic
#     Detach UE
#     teardown_all_alias_for_enb_ttitrace
# 
# *** Keywords ***
# Add RD
#     ${enb_swconfig_modified_file}    Add ENB Swconfig    @{swconfig}
#     Set Suite Variable    ${enb_swconfig_file}    ${enb_swconfig_modified_file}
#     ENB Upload Swconfig    ${enb_swconfig_file}
# 	
# Attach UE
#     Comment    CUS Attach    1,3...7,9    1
#     sleep    20
#     Comment    CUS Attach    1    11
#     CUS Attach    ${UE_INDEX_1}    11
#     Add bear6967
# 	
# Add bear6967
#     Run UEx command  bearer_add ue=1 qci=69
#     Expect Message Flow
#     ...  MME_1:S1AP_E-RABSetupRequest (E-RABSetupRequest contains ((qCI eq 67) and (e-RAB-ID eq 7)))
#     ...  MME_1:S1AP_E-RABSetupResponse (E-RABSetupResponse contains (e-RAB-ID eq 7))
#     ...  alias=UE_1_flow    overall_timeout=20
#     Run UEx command  bearer_add ue=1 qci=67 mbr_dl=31 mbr_ul=31 gbr_dl=31 gbr_ul=31
#     Flow Occurred As Expected    alias=UE_1_flow
# 
# Wait and check PMQAP PM counter 
#     ${remain_time}=    get_counter_file_remaining_time
#     set test variable    ${remain_time}
#     sleep    ${remain_time}
#     ${passed}=    Run Keyword And Return Status    Download Latest Pmcounter    local_path=${TEST LOG DIRECTORY()}/    source_path=/tmp/
#     ...    suffix=xz
#     Run Keyword If    not ${passed}    Download Latest Pmcounter    local_path=${TEST LOG DIRECTORY()}/    source_path=/tmp/    suffix=gz
#     ${counter_file}    list files in directory    ${TEST LOG DIRECTORY()}/    pattern=*.ANY.*
#     set test variable    ${counter_file}
#     : FOR    ${PM_counter}    IN    @{COUNTER_LIST}
#     \    ${Count_serving}    get_counter_value_from_counter_file    ${TEST LOG DIRECTORY()}/${counter_file[0]}    ${PM_counter}    11
#     \    sleep    1s
#     \    should_be_true    ${Count_serving}>0
# 
# Start data traffic
#     Comment    CUS Start UL Udp Data Traffic    4...6    30    bearer=5
#     Comment    CUS Start DL Udp Data Traffic    7,9    5M
#     CUS Start UL Udp Data Traffic    1    20M    bearer=7
#     CUS Start DL Udp Data Traffic    1    200M    bearer=7
#     Sleep    10
# 	
# Override PHR
#     Run UEx command  ue_ul_power_control id=1 phr_operation=permanent phr_value_override=1 pathloss=115
# 
# Verify throughput
#     Comment    ${ul_tput_ave}=    CUS Get UL Throughput Ave    1    dl_mac
#     ${dl_tput_ave}=    CUS Get DL Throughput Ave    1    dl_mac
#     ${dl_throughput_pcell}    CUS Get Throughput On Specific Scell    1    dl_mac    scell_id=0    tput_type=cur
#     should_be_true    ${dl_tput_ave}>130000
#     should_be_true    ${dl_throughput_pcell}>130000
# 
# Stop data traffic
#     CUS Stop UL Udp Data Traffic    1    bearer=7
#     CUS Stop DL Udp Data Traffic    1    bearer=7
# 
# Detach UE
#     Comment    CUS Detach    1
#     Comment    Sleep    1
#     CUS All Detach
# 
# collect macps_ttitrace
#     setup_enb_ttitrace    log_path=${TEST LOG DIRECTORY()}/macps_ttitrace    alias=enb1_ttitrace
#     start_enb_ttitrace    node_type=ALL    cell_id=ALL    alias=enb1_ttitrace
#     sleep    5
#     stop_and_decode_enb_ttitrace    alias=enb1_ttitrace
#     teardown_all_alias_for_enb_ttitrace
# 
# Set R&D parameter
#     runkeyword and continue on failure    Set Rad Parameter    setlog    ALL    ALL    FID_DL_CA    DEBUG
#     ...    hw_ver=fsmr4
#     runkeyword and continue on failure    Set Rad Parameter    setlog    ALL    ALL    FID_UL_CA    DEBUG
#     ...    hw_ver=fsmr4
#     runkeyword and continue on failure    Set Rad Parameter    setlog    ALL    ALL    FID_DL_BSR    DEBUG
#     ...    hw_ver=fsmr4
# 
# Check ttitrace no bler
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_no_dl_bler_case10.ini   log_need_to_check=i
#     ...    save_log_directory=${TEST LOG DIRECTORY()}/macps_ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_no_ul_bler_case10.ini   log_need_to_check=i
#     ...    save_log_directory=${TEST LOG DIRECTORY()}/macps_ttitrace

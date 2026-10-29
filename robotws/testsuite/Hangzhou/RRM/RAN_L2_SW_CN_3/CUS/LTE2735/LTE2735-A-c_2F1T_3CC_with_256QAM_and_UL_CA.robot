# *** Settings ***
# Documentation     2735 features.
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CRT    CLOUD_R4BANO_CUS    SBTS00    RAN_4G    RAN_4G_TDD    RAN_4G_FDD
# Resource          ../../resources/KISS/robot/4g_common_resource.robot
# 
# *** Variables ***
# ${scfc_path}    ${CURDIR}${/}config_file${/}CUS_LTE2735_SCFC_ULCA.xml
# ${yaml_config}    ${CURDIR}${/}config_file${/}CUS_LTE2735_2F2T.yaml
# ${CUS_IP}         192.168.200.1
# ${FCT_IP}         192.168.255.1
# ${FTM_IP}         192.168.255.129
# ${cell_onair}     ${EMPTY}
# ${DL_THROUGHPUT_LOWER_THRESHOLD2cc}    100000
# ${DL_THROUGHPUT_LOWER_THRESHOLD3cc}    200000
# ${UE_INDEX_1}     1
# 
# 
# *** Test Cases ***
# LTE2735-A-c_2F1T_3CC_with_256QAM_and_UL_CA
#     Prepare Enb Onair   ${scfc_path}    ${yaml_config}
#     Run UEx command  turbo_mode_l2 cell=3 mode=enable  
#     Attach UE
#     Start data traffic
#     run keyword and continue on failure    Verify throughput
#     #Collect ttitrace
#     #Check ttitrace
#     Stop data traffic
#     Detach UE
#     #teardown_all_alias_for_enb_ttitrace
# 
# *** Keywords ***
# 	
# Attach UE
#     Comment    CUS Attach    1,3...7,9    1
#     sleep    20
#     Comment    CUS Attach    1    11
#     CUS Attach    ${UE_INDEX_1}    3
# 	
# Add bear6965
#     Run UEx command  bearer_add ue=1 qci=69
#     Expect Message Flow
#     ...  MME_1:S1AP_E-RABSetupRequest contains ((qCI eq "65") and (e-RAB-ID eq 7))
#     ...  MME_1:S1AP_E-RABSetupResponse contains (e-RAB-ID eq 7)
#     ...  alias=UE_1_flow    overall_timeout=20
#     Run UEx command  bearer_add ue=1 qci=65 mbr_dl=31 mbr_ul=31 gbr_dl=31 gbr_ul=31
#     Flow Occurred As Expected    alias=UE_1_flow
# 
# Start data traffic
#     Comment    CUS Start UL Udp Data Traffic    4...6    30    bearer=5
#     Comment    CUS Start DL Udp Data Traffic    7,9    5M
#     CUS Start UL Udp Data Traffic    1    50M
#     CUS Start DL Udp Data Traffic    1    350M    trf_id=1
#     Sleep    10
# 	
# Override PHR
#     Run UEx command  ue_ul_power_control id=1 phr_operation=permanent phr_value_override=1 pathloss=115
# 
# Verify throughput
#     Comment    ${ul_tput_ave}=    CUS Get UL Throughput Ave    1    dl_mac
#     ${dl_throughput_pcell}     CUS Get Throughput On Specific Scell    1    dl_mac    scell_id=0    tput_type=cur
#     ${dl_throughput_scell1}    CUS Get Throughput On Specific Scell    1    dl_mac    scell_id=1    tput_type=cur
#     ${dl_throughput_scell2}    CUS Get Throughput On Specific Scell    1    dl_mac    scell_id=2    tput_type=cur
#     ${ul_throughput_pcell}     CUS Get Throughput On Specific Scell    1    ul_mac    scell_id=0    tput_type=cur
#     ${ul_throughput_scell1}    CUS Get Throughput On Specific Scell    1    ul_mac    scell_id=1    tput_type=cur
#     should_be_true    ${dl_throughput_pcell}>140000
#     should_be_true    ${dl_throughput_scell1}>90000
#     should_be_true    ${dl_throughput_scell2}>65000
#     should_be_true    ${ul_throughput_pcell}>20000
#     should_be_true    ${ul_throughput_scell1}>10000
# 
# Send UE Measurement
#     Run UEx command  ue_measurement_send id=1 event=A6 phycell_id=2 nrsrp=90 nrsrq=30 phycell_id=6 nrsrp=90 nrsrq=30
#     #Run UEx command  ue_cqi_param id\311 scell=2 wb=5:5:1
# 
# Stop data traffic
#     CUS Stop UL Udp Data Traffic    1
#     CUS Stop DL Udp Data Traffic    1
# 
# Detach UE
#     Comment    CUS Detach    1
#     Comment    Sleep    1
#     CUS All Detach
# 
# Collect ttitrace      
# 	setup_enb_ttitrace  log_path=${TEST LOG DIRECTORY()}    alias=enb_ttitrace
# 	start_enb_ttitrace  node_type=ALL   cell_id=ALL   alias=enb_ttitrace
# 	sleep   5
# 	stop_and_decode_enb_ttitrace    alias=enb_ttitrace
# 	teardown_all_alias_for_enb_ttitrace
# 
# Check ttitrace       
# 	check_log_with_au2anlysis   ini_path=${CURDIR}/ini/tti_TDD_DL_cell_1.ini    log_need_to_check=i    save_log_directory=${TEST LOG DIRECTORY()}
# 	check_log_with_au2anlysis   ini_path=${CURDIR}/ini/tti_FDD_DL_cell_3.ini    log_need_to_check=i    save_log_directory=${TEST LOG DIRECTORY()}
# 	check_log_with_au2anlysis   ini_path=${CURDIR}/ini/tti_FDD_DL_cell_4.ini    log_need_to_check=i    save_log_directory=${TEST LOG DIRECTORY()}
# 
# Set R&D parameter
#     runkeyword and continue on failure    Set Rad Parameter    setlog    ALL    ALL    FID_DL_CA    DEBUG
#     ...    hw_ver=fsmr4
#     runkeyword and continue on failure    Set Rad Parameter    setlog    ALL    ALL    FID_UL_CA    DEBUG
#     ...    hw_ver=fsmr4
#     runkeyword and continue on failure    Set Rad Parameter    setlog    ALL    ALL    FID_DL_BSR    DEBUG
#     ...    hw_ver=fsmr4

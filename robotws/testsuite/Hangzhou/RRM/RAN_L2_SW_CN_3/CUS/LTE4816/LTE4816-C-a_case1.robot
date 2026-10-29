# *** Settings ***
# Documentation     LTE4816
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CRT    QCD_MN_RAN    QCP_RAN_ET    CRT    CLOUD_R4BANO_CUS	SBTS00     RAN_4G    RAN_4G_TDD 
# Resource          ../../resources/KISS/robot/4g_common_resource.robot
# 
# 
# *** Variables ***
# ${scfc_path}    ${CURDIR}${/}TDD_SCFC_case1.xml
# ${yaml_config}    ${CURDIR}${/}CUS_LTE4816_1CUS.yaml
# ${CUS_IP}         192.168.200.1
# ${FCT_IP}         192.168.255.1
# ${FTM_IP}         192.168.255.129
# ${btslog_port}    51000
# ${cell1}    11
# ${cell2}    13
# ${UE_ID_LIST}     1...8
# @{swconfig}         0x9D0000:15   0x10041:5
# 
# *** Test Cases ***
# LTE4816-C-a_T-T_SRIO_PMCounter_for_measuring_the_number_of_attempts_and_successes_PUCCH_format3
#     Add RD
#     Prepare Enb Onair   ${scfc_path}    ${yaml_config}
#     Attach UE 
#     Start data traffic
#     sleep    10s
#     Verify throughput
#     Wait Until PM Counter Check    Verify CA Counter List
#     Detach UE
# 
# *** Keywords ***
# Attach UE
#     CUS Attach    ${UE_ID_LIST}    11
#     sleep    5
# 
# Add RD
#     ${enb_swconfig_modified_file}    Add ENB Swconfig    @{swconfig}
#     Set Suite Variable    ${enb_swconfig_file}    ${enb_swconfig_modified_file}
#     ENB Upload Swconfig    ${enb_swconfig_file}
# 
# Start data traffic
#     CUS Start DL Udp Data Traffic    ${UE_ID_LIST}    50M    trf_id=1
#     Sleep   30s
# 
# Verify throughput
#     ${Cell_Pcell_DL_ThrPut}    Cus Get Cell Throughput    cell_id=11    stat_type=dl_mac    tput_type=cur
#     ${Cell_Scell1_DL_ThrPut}    Cus Get Cell Throughput    cell_id=12    stat_type=dl_mac    tput_type=cur
#     ${Cell_Scell2_DL_ThrPut}    Cus Get Cell Throughput    cell_id=13    stat_type=dl_mac    tput_type=cur	
#     run keyword and continue on failure    Verify DL throughput per ue
#     should_be_true    ${Cell_Pcell_DL_ThrPut}>90
#     should_be_true    ${Cell_Scell1_DL_ThrPut}+${Cell_Scell2_DL_ThrPut}>180
# 
# Verify DL throughput per ue
#     : FOR    ${ue_id}    IN RANGE    1    8+1
#     \    run keyword and continue on failure    Get and verify DL throughput average per ue   ${ue_id}
# 
# Get and verify DL throughput average per ue
#     [Arguments]    ${ue_id}
#     ${dl_throughput_pcell}    CUS Get Throughput On Specific Scell    ${ue_id}    dl_mac    scell_id=0    tput_type=cur
#     ${dl_throughput_scell1}    CUS Get Throughput On Specific Scell    ${ue_id}    dl_mac    scell_id=1    tput_type=cur
#     ${dl_throughput_scell2}    CUS Get Throughput On Specific Scell    ${ue_id}    dl_mac    scell_id=2    tput_type=cur
#     should_be_true    ${dl_throughput_pcell}+${dl_throughput_scell1}+${dl_throughput_scell2}>30000
# 
# Stop data traffic
#     CUS Stop DL Udp Data Traffic    ${UE_ID_LIST}
# 	
# Detach UE
#     CUS Detach    ${UE_ID_LIST}
# 
# Verify CA Counter List
#     Wait '180s' for stabible	
#     Check pm counter M8011C348 in cell 1 MCC-244/MNC-09 is expected > 0
#     Check pm counter M8011C349 in cell 1 MCC-244/MNC-09 is expected > 0
#     Check pm counter M8011C348 in cell 2 MCC-244/MNC-09 is expected == 0
#     Check pm counter M8011C349 in cell 2 MCC-244/MNC-09 is expected == 0
#     Check pm counter M8011C348 in cell 3 MCC-244/MNC-09 is expected == 0
#     Check pm counter M8011C349 in cell 3 MCC-244/MNC-09 is expected == 0
#     Check pm counter M8011C167 in cell 1 MCC-244/MNC-09 is expected == 0
# 
# Wait '${time}' for stabible
#     sleep    ${time}		
# 
# Get pm counter value
#     [Arguments]    ${counter_id}    ${cell_id}    ${counter_path}    ${cmcc_id}
#     ${PM_counter_file}    download_latest_pmcounter    ${counter_path}
#     ${PM_counter_value}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=${cell_id}
#     ...    cmcc_cmnc=${cmcc_id}
#     [return]    ${PM_counter_value}
# 
# Wait Until PM Counter Check
#     [Arguments]    ${keyword}
#     Wait Until Keyword Succeeds    500s    20s    ${keyword}
# 
# Check pm counter ${counter} in cell ${cell_id} ${cmcc} is expected ${symbol} ${expected_value}
#     ${cpath}    set variable    ${test_log_directory()}/All/counter_${counter}/
#     ${counter_value}    Get pm counter value    ${counter}    ${cell_id}    ${cpath}    ${cmcc}
#     should be true    ${counter_value} ${symbol} ${expected_value}	  
#     Sleep    20

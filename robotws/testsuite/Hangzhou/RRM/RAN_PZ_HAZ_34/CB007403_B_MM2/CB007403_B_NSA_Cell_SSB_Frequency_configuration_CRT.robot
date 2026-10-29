# *** Settings ***
# Force Tags    STATE_SW_UPLOADED    sw_uploaded    SBTS00    RAN_5G    RAN_5G_TDD
# ...           CLOUD_5G_CLASSICAL_ANDROID_SA_ASIBR_ABIOB4_AQHC    PY39
# Documentation     author: wenjuan.zhong
# ...               contact: wenjuan.zhong@nokia-sbell.com
# ...               squad group: MMW_02
# 
# Suite Setup       Test Suite Setup
# Suite Teardown    Test Suite Teardown
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot           
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/5G_Setup_And_Teardown.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
# 
# *** Variables ***
# ${log_namex2}      x2_with_sspbcharfcn_0.pcap
# ${pcap_path}    ${logPath}
# ${x2_check_gscn}    .//nr-rrc.ssbFrequency
# ${x2_filter}     x2ap.X2AP_PDU == 0 and x2ap.procedureCode == 27
# ${ssb_fr_0}    510750
# ${ssb_fr_1}    518430
# ${ssb_fr_2}    526830
# ${cell_gscn_10}    0
# ${cell_gscn_11}    1
# ${cell_gscn_12}    2
# ${cell_gscn_20}    6384
# ${cell_gscn_21}    6480
# ${cell_gscn_22}    6585
# ${cell_gscn_00}    510750
# ${cell_gscn_01}    518430
# ${cell_gscn_02}    526830
# ${TS_LOG_PATH_BASE}    /home/ute
# 
# *** Test Cases ***
# [1][1.0]CB007403_B_01_NSA_Cell_SSB_Frequency_configuration_with_sspbcharfcn_FR1
#     [Tags]    CRT
#     [Setup]    Cases common Setup
#     log to console    \n***Start Modify gscnOrSsPbchArfcn first***
#   	Modify gscnOrSsPbchArfcn    cell_gscn=${cell_gscn_00}
# 	  Prepare UE 7403
#     Sleep   3s
# 	  Check gscn Resource in x2 log    pcap_file=${pcap_path}${/}${log_namex2}    filter=${x2_filter}    ssb_fr=${ssb_fr_0}    log_name=${log_namex2}
#     log to console    \n***Start Modify gscnOrSsPbchArfcn second***
#     Modify gscnOrSsPbchArfcn    cell_gscn=${cell_gscn_01}
#     Sleep   3s
#   	Check gscn Resource in x2 log    pcap_file=${pcap_path}${/}${log_namex2}    filter=${x2_filter}    ssb_fr=${ssb_fr_1}    log_name=${log_namex2}
#     log to console    \n***Start Modify gscnOrSsPbchArfcn third***
#     Modify gscnOrSsPbchArfcn    cell_gscn=${cell_gscn_02}
#     Sleep   3s
# 	  Check gscn Resource in x2 log    pcap_file=${pcap_path}${/}${log_namex2}    filter=${x2_filter}    ssb_fr=${ssb_fr_2}    log_name=${log_namex2}
#     [Teardown]    Cases Common teardown
# 
# [1][1.0]CB007403_B_02_NSA_Cell_SSB_Frequency_configuration_with_gscn_less_than_3_FR1
#     [Tags]    CRT
#     [Setup]    Cases common Setup
#     log to console    \n***Start Modify gscnOrSsPbchArfcn first***
# 	  Modify gscnOrSsPbchArfcn    cell_gscn=${cell_gscn_10}
# 	  Prepare UE 7403
#     Sleep   3s
# 	  Check gscn Resource in x2 log    pcap_file=${pcap_path}${/}${log_namex2}    filter=${x2_filter}    ssb_fr=${ssb_fr_0}    log_name=${log_namex2}
#     log to console    \n***Start Modify gscnOrSsPbchArfcn second***
#     Modify gscnOrSsPbchArfcn    cell_gscn=${cell_gscn_11}
#     Sleep   3s
#   	Check gscn Resource in x2 log    pcap_file=${pcap_path}${/}${log_namex2}    filter=${x2_filter}    ssb_fr=${ssb_fr_1}    log_name=${log_namex2}
#     log to console    \n***Start Modify gscnOrSsPbchArfcn third***
#     Modify gscnOrSsPbchArfcn    cell_gscn=${cell_gscn_12}
#     Sleep   3s
#    	Check gscn Resource in x2 log    pcap_file=${pcap_path}${/}${log_namex2}    filter=${x2_filter}    ssb_fr=${ssb_fr_2}    log_name=${log_namex2}
#     [Teardown]    Cases Common teardown
# 
# [1][1.0]CB007403_B_03_NSA_Cell_SSB_Frequency_configuration_with_gscn_less_than_26640_FR1
#     [Tags]    CRT
#     [Setup]    Cases common Setup
#     log to console    \n***Start Modify gscnOrSsPbchArfcn first***
#   	Modify gscnOrSsPbchArfcn    cell_gscn=${cell_gscn_20}
#     Prepare UE 7403
#     Sleep   3s
#   	Check gscn Resource in x2 log    pcap_file=${pcap_path}${/}${log_namex2}    filter=${x2_filter}    ssb_fr=${ssb_fr_0}    log_name=${log_namex2}
#     log to console    \n***Start Modify gscnOrSsPbchArfcn second***
#     Modify gscnOrSsPbchArfcn    cell_gscn=${cell_gscn_21}
#     Sleep   3s
# 	  Check gscn Resource in x2 log    pcap_file=${pcap_path}${/}${log_namex2}    filter=${x2_filter}    ssb_fr=${ssb_fr_1}    log_name=${log_namex2}
#     log to console    \n***Start Modify gscnOrSsPbchArfcn third***
#     Modify gscnOrSsPbchArfcn    cell_gscn=${cell_gscn_22}
#     Sleep   3s
#   	Check gscn Resource in x2 log    pcap_file=${pcap_path}${/}${log_namex2}    filter=${x2_filter}    ssb_fr=${ssb_fr_2}    log_name=${log_namex2}
#     [Teardown]    Cases Common teardown
#     
# *** Keywords ***
# Test Suite Setup
#     robot_common_operations.Common Suite Setup
#     log to console  \n***Test Suite Setup***
#     SISO Coam Suite Setup
#     Selenium Login And Disable Screen Lock
#     ${src_cell_gscn_value}    Get gscnOrSsPbchArfcn value
#     set global variable    ${src_cell_gscn_value}
# 
# Test Suite Teardown
#     log to console  \n***Test Suite Teardown***
#     Run Keyword And Ignore Error    Set gscnOrSsPbchArfcn value    cell_gscn_value=${src_cell_gscn_value}
#     Run Keyword And Ignore Error    Wait Until Keyword Succeeds    10min    30s    verify all cells should be onair
#     Run Keyword And Ignore Error    selenium logout and close browser
#   	SISO Coam Suite Teardown
# 
# Cases common Setup
#     [Documentation]    Author: wenjuan.zhong
#     ...                Description: case common setup
#     robot_common_operations.Common Case Setup
#     Sleep    2s
#     log to console  \n***Test Setup***
# 
# Cases Common teardown
#     [Documentation]    Author: wenjuan.zhong
#     ...                Description: case common teardown
#     log to console  \n***Test Teardown***
#     [Teardown]  Run Keyword And Ignore Error   csn.Reset Cache
#     Run Keyword And Ignore Error    Delete log    log_file=${logPath}${/}*
#     robot_common_operations.Common Case Teardown
# 
# Get gscnOrSsPbchArfcn value
#     [Documentation]  Author: Zhong wenjuan
#     ...              Description: get gscnOrSsPbchArfcn parameter value
#     
#     ${gscnOrSsPbchArfcn}    selenium_coam.get_parameter_value
#     ...    dist_name=NRCELL-1
#     ...    abbr=gscnOrSsPbchArfcn
#     ...    filter_param=Synchronization channel number
#     ...    timeout=60
#     [Return]    ${gscnOrSsPbchArfcn}
# 
# Set gscnOrSsPbchArfcn value
#     [Documentation]  Author: Zhong wenjuan
#     ...              Description: set gscnOrSsPbchArfcn parameter value
#     [Arguments]    ${cell_gscn_value}
#     selenium_coam.set_parameter_value
#     ...    dist_name=NRCELL-1
#     ...    abbr=gscnOrSsPbchArfcn
#     ...    new_value=${cell_gscn_value}
#     ...    filter_param=Synchronization channel number
#     sleep    1s
#     Validate Plan
#     sleep    5s
#     Activate Plan
# 
# Start to collect X2log on eNB
#    [Arguments]    ${log_name}
#     wait until keyword succeeds    10 min    10 sec    Connect to eNB   alias=ENB
#   	csn.send command    command=tcpdump -i br1 -w /tmp/${log_name}   connection=ENB
# 
# Stop and get X2Logs on eNB
#     [Arguments]     ${log_name}
#     wait until keyword succeeds    10 min    10 sec    Connect to eNB   alias=ENB
#     sleep    30
#     csn.send command    command=killall tcpdump     connection=ENB
#     sleep    5
#     csn.download_file   remote_path=/tmp${/}${log_name}    local_path=${logPath}${/}${log_name}   connection=ENB
# 
# Delete log
#     [Arguments]    ${log_file}
#     Run Keyword And Ignore Error    run    command=rm -rf ${log_file}
# 
# Check gscn Resource in x2 log
#     [Documentation]    Author: wenjuan.zhong
#     ...                Description: Check gscn Resource value in x2 log
#     [Arguments]    ${pcap_file}    ${filter}    ${ssb_fr}    ${log_name}
#     UE Detach 7403
#     Start to collect X2log on eNB    log_name=${log_name}
#     log to console    \n***Attach UE***
#     UE Attach 7403
#     Run Keyword And Ignore Error    Start Traffic 7403
# 	  Stop and get X2Logs on eNB    log_name=${log_name}
# 	  log to console    \n***Check ssb***
#     ${filtered_packets}=    Load pcap with filter    pcap_file=${pcap_file}    filter_expression=${filter}
# 	  ${x2_result}=    Get field value by xpath    packets=${filtered_packets}    xpath=${x2_check_gscn}    attribute_name=show
#     should be equal    ${x2_result[0]}    ${ssb_fr}
#     log to console  \n***Check gscnOrSsPbchArfcn ${x2_result[0]} and ${ssb_fr}***
#     [Teardown]    UE Detach 7403
# 
# Modify gscnOrSsPbchArfcn
#     [Documentation]    Author: wenjuan.zhong
#     ...                Description: Modify gscnOrSsPbchArfcn on webui
#     [Arguments]    ${cell_gscn}
#     Set gscnOrSsPbchArfcn value    cell_gscn_value=${cell_gscn}
#     selenium_coam.validate_plan
#     selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${False}    timeout=${300}
#     Wait Until Keyword Succeeds    10min    30s    verify all cells should be onair
# 	  ${cell_gscn_value}    Get gscnOrSsPbchArfcn value
#     should be equal    ${cell_gscn_value}    ${cell_gscn}
#     log to console  \n***Modify gscnOrSsPbchArfcn to ${cell_gscn}***
# 
# Prepare UE 7403
#     ${ue_type}    translate_power_ue_type_from_testline    ue_index=${0}
#     Set Test Variable    ${ue_type}
#     log to console      Prepare UE   
#     power_ue.Prepare UE    ue_index=${0}    ue_type=${ue_type}    power_reset=True
#     
# UE Attach 7403
#     log to console      Attach UE
#     ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${ue_type}    log_type=Aasyslog    attach_mode=5G_NSA    power_reset=True
#     power_ue.Verify attach    ue_type=${ue_type}   5Grach_ed=${5Grach_ed_0}    4G_check=True
# 
# UE Detach 7403
#     log to console    \n***UE Detach***
#     Run Keyword And Ignore Error    Power_ue.UE Detach    ue_index=${0}    ue_type=${ue_type}    power_reset=True
# 
# Start Traffic 7403
#     log to console    \n***Start Traffic***
#     power_ue.Start traffic    ue_type=${ue_type}    ue_index=${0}    direction=dl    apn_address=dxdata1
#     ...    throughput=100MKbits/sec    duration=5    ue_mode=NSA
#     Sleep    2s

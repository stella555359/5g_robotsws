*** Settings ***
Documentation    author: Jerry Wu
...              Group: HGZ_SG7
...              contact: jerry.wu@nokia-sbell.com
...              Description
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/container_log_capturing.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_cu.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/log/collect_logs.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource          ${CURDIR}/ecpri_transport_common_keyword.robot

Library          taf.collectors.tcpdump       WITH NAME    tcpdump
Library          taf.collectors.core       WITH NAME    core
Library    taf.analyzer.pcap    WITH NAME    pcap

*** Variables ***
${pcap_path}    /tmp
${filter_expression}    ptp
${modify_SsmType}    SSM_ITU
${ru_username_default}    rfsw
${ru_password_default}    PD6N1DB0lWmwomtNL2qd3ISypbiocdGRy7U+Lipiksk=

*** Keywords ***
2377_HB and 1913_HA case11
    [Documentation]    Author: Wu Jerry
    ...                Description: keyword for 2377_HB and 1913_HA case11
    [Arguments]    ${names}
    Connect to ASIK via ssh    alias=DU
    ${pcap_file}   Collect RF Tcpdump Logs To TestPC    log_name=${names}.pcap    du_alias=DU
    Verify PTP Message    pcap_file=${pcap_file}
    Run Keyword And Ignore Error    run    command=rm -rf ${pcap_file}

2377_HB and 1913_HA case05
    [Documentation]    Author: Wu Jerry
    ...                Description: keyword for 2377_HB and 1913_HA case05
    [Arguments]    ${names}
    Check_ClockClass    MRBTS_ID=${MRBTS_ID}    expect_clockclass=7
    Connect to ASIK via ssh    alias=DU
    ${pcap_file}   Collect RF Tcpdump Logs To TestPC    log_name=${names}.pcap    du_alias=DU
    Verify clockclass in PTP Message    pcap_file=${pcap_file}
    Run Keyword And Ignore Error    run    command=rm -rf ${pcap_file}
   
2377_HB and 1913_HA_trunk case11
    [Documentation]    Author: Wu Jerry
    ...                Description: keyword for 2377_HB and 1913_HA case11
    [Arguments]    ${names}    ${ru_username}=${ru_username_default}    ${ru_password}=${ru_password_default}  
    Connect to ASIK via ssh    alias=DU
    ${pcap_file}   Collect RF Tcpdump Logs To TestPC    log_name=${names}.pcap    du_alias=DU    
    ...    ru_username=${ru_username}    ru_password=${ru_password}
    Verify PTP Message    pcap_file=${pcap_file}
    Run Keyword And Ignore Error    run    command=rm -rf ${pcap_file}

2377_HB and 1913_HA_trunk case05
    [Documentation]    Author: Wu Jerry
    ...                Description: keyword for 2377_HB and 1913_HA case05
    [Arguments]    ${names}    ${ru_username}=${ru_username_default}    ${ru_password}=${ru_password_default} 
    Check_ClockClass    MRBTS_ID=${MRBTS_ID}    expect_clockclass=7
    Connect to ASIK via ssh    alias=DU
    ${pcap_file}   Collect RF Tcpdump Logs To TestPC    log_name=${names}.pcap    du_alias=DU
    ...    ru_username=${ru_username}    ru_password=${ru_password}
    Verify clockclass in PTP Message    pcap_file=${pcap_file}
    Run Keyword And Ignore Error    run    command=rm -rf ${pcap_file}
	
Test_suite_setup
    [Documentation]    Author: Wu Jerry
    ...                Description: check gnb status after case execute 
    Cloud DU connect to gnb coam via ssl
    COAM Check GNB cell on air
    COAM Teardown gnb connections

Test_suite_teardown
    [Documentation]    Author: Wu Jerry
    ...                Description: check gnb status after case execute 
    Cloud DU connect to gnb coam via ssl
    COAM Check GNB cell on air
    COAM Teardown gnb connections

Case05 common Setup
    Du login page via webUI
    ${MRBTS_ID}    Get MRBTS Id in COAM WebEM
    Get Filter SsmType    MRBTS_ID=${MRBTS_ID}
    Run Keyword If    '${modify_SsmType}'!='$SsmType_ori_value'    Modify SsmType in webui    MRBTS_ID=${MRBTS_ID}
    Check_ClockClass    MRBTS_ID=${MRBTS_ID}    expect_clockclass=6
    Sleep    2s
    Get Filter syncInputType    MRBTS_ID=${MRBTS_ID}
    Modify syncInputType in webui    MRBTS_ID=${MRBTS_ID}    modify_syncInputType=2.048MHz input
    Sleep    5s
	set suite variable    ${MRBTS_ID}
    
Case05 Common teardown
    Run Keyword And Ignore Error    Restore parameters and check
    Run Keyword And Ignore Error    DU COAM selenium logout
    Collect Logs IF Case Failed    TS_CASE_LOG_PATH=/home/ute/test_results
    CI_interface.Common Case Teardown

Case11 common Setup
    Du login page via webUI
    
Case11 Common teardown
    Run Keyword And Ignore Error    DU COAM selenium logout
    Collect Logs IF Case Failed    TS_CASE_LOG_PATH=/home/ute/test_results
    CI_interface.Common Case Teardown
  	
Check_ClockClass
    [Documentation]    Author: Wu Jerry
    ...                Description: Check clockclass in WebEM
    [Arguments]    ${MRBTS_ID}    ${expect_clockclass}
    ${clockclass_value}    selenium_coam.get_parameter_value
    ...    dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS_R-1
    ...    abbr=eCpriMasterClockClass
    ...    filter_param=eCPRI Master clock class
    should be equal    ${clockclass_value}    ${expect_clockclass}
    
Get Filter SsmType
    [Documentation]  Author: Wu Jerry
    ...              Description: get SsmType value
	[Arguments]    ${MRBTS_ID}
    ${SsmType_ori_value}    selenium_coam.get_parameter_value
    ...   dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-1/ECPRIMASTER-1
    ...   abbr=eCpriMasterSsmType
    ...   filter_param=eCpri Master Synchronous Ethernet SSM support network standard
    set suite variable    ${SsmType_ori_value}

Modify SsmType in webui
    [Documentation]  Author: Wu Jerry
    ...              Description: modify SsmType value
	[Arguments]    ${MRBTS_ID}
    selenium_coam.set_parameter_value
    ...    dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-1/ECPRIMASTER-1
    ...    abbr=eCpriMasterSsmType
    ...    new_value=${modify_SsmType}
    ...    filter_param=eCpri Master Synchronous Ethernet SSM support network standard
    sleep    1s
    selenium_coam.validate_plan
    sleep    2s
    selenium_coam.activate_plan    activate_plan_despite_errors=True

Restore SsmType in webui
    [Documentation]  Author: Wu Jerry
    ...              Description: restore SsmType value
	[Arguments]    ${MRBTS_ID}
    selenium_coam.set_parameter_value
    ...    dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-1/ECPRIMASTER-1
    ...    abbr=eCpriMasterSsmType
    ...    new_value=${SsmType_ori_value}
    ...    filter_param=eCpri Master Synchronous Ethernet SSM support network standard
    sleep    1s
    selenium_coam.validate_plan
    sleep    2s
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    
Get Filter syncInputType
    [Documentation]  Author: Wu Jerry
    ...              Description: get syncInputType value
	[Arguments]    ${MRBTS_ID}
    ${syncInputType_ori_value}    selenium_coam.get_parameter_value
    ...   dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1
    ...   abbr=syncInputType
    ...   filter_param=Sync input type
    set suite variable    ${syncInputType_ori_value}

Modify syncInputType in webui
    [Documentation]  Author: Wu Jerry
    ...              Description: modify syncInputType value
    [Arguments]    ${MRBTS_ID}    ${modify_syncInputType}
    selenium_coam.set_parameter_value
    ...    dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1
    ...    abbr=syncInputType
    ...    new_value=${modify_syncInputType}
    ...    filter_param=Sync input type
    sleep    1s
    selenium_coam.validate_plan
    sleep    2s
    selenium_coam.activate_plan    activate_plan_despite_errors=True

Restore syncInputType in webui
    [Documentation]  Author: Wu Jerry
    ...              Description: restore syncInputType value
	[Arguments]    ${MRBTS_ID}
    selenium_coam.set_parameter_value
    ...    dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1
    ...    abbr=syncInputType
    ...    new_value=${syncInputType_ori_value}
    ...    filter_param=Sync input type
    sleep    1s
    selenium_coam.validate_plan
    sleep    2s
    selenium_coam.activate_plan    activate_plan_despite_errors=True

Restore parameters and check
    Restore syncInputType in webui    MRBTS_ID=${MRBTS_ID}
    Run Keyword If    '${modify_SsmType}'!='${SsmType_ori_value}'
    ...    Restore SsmType in webui    MRBTS_ID=${MRBTS_ID}
    Wait Until Keyword Succeeds    2min    10s    Check_ClockClass    MRBTS_ID=${MRBTS_ID}    expect_clockclass=6
    Wait Until Keyword Succeeds    6min    10s    Expect Fault Should Absent    faultId=1899

Verify PTP Message
    [Documentation]  Author: Wu Jerry
    ...              Description: verify multi-parameters in PTP message
	[Arguments]    ${pcap_file}
    ${filtered_packets}    Load pcap with filter    pcap_file=${pcap_file}    filter_expression=${filter_expression}    
    ${value_clockclass}    Get field value    packets=${filtered_packets}    field_name=ptp.v2.an.grandmasterclockclass
    ${value_timetraceable}    Get field value    packets=${filtered_packets}    field_name=ptp.v2.flags.timetraceable
    ${value_timescale}    Get field value    packets=${filtered_packets}    field_name=ptp.v2.flags.timescale
    ${value_li59}    Get field value    packets=${filtered_packets}    field_name=ptp.v2.flags.li59
    ${value_li61}    Get field value    packets=${filtered_packets}    field_name=ptp.v2.flags.li61
    ${value_offset}    Get field value    packets=${filtered_packets}    field_name=ptp.v2.an.origincurrentutcoffset
    ${value_frequencytraceable}    Get field value    packets=${filtered_packets}    field_name=ptp.v2.flags.frequencytraceable
    ${value_timesource}    Get field value    packets=${filtered_packets}    field_name=ptp.v2.timesource
    should contain    ${value_clockclass}    6
    Should Not Be Empty    ${value_timetraceable}   
    Should Not Be Empty    ${value_timescale}   
    Should Not Be Empty    ${value_li59}    
    Should Not Be Empty    ${value_li61}    
    Should Not Be Empty    ${value_offset}    
    Should Not Be Empty    ${value_frequencytraceable}    
    Should Not Be Empty    ${value_timesource} 

Verify clockclass in PTP Message
    [Documentation]  Author: Wu Jerry
    ...              Description: verify 'clockclass' parameter in PTP message
	[Arguments]    ${pcap_file}
    ${filtered_packets}    Load pcap with filter    pcap_file=${pcap_file}    filter_expression=${filter_expression}
    ${value_clockclass}    Get field value    packets=${filtered_packets}    field_name=ptp.v2.an.grandmasterclockclass
    should contain    ${value_clockclass}    7
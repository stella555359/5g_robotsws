*** Settings ***
Documentation    author: Jerry Wu
...              Group: HGZ_SG7
...              contact: jerry.wu@nokia-sbell.com
...              Description
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library    taf.transport.ssh    WITH NAME    csn
#Resource    taf/rfrl/common_resources/robot/coam_selenium.robot
#Resource    taf/rfrl/common_resources/robot/coam.robot
#Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
#Resource    ../../../../../resources/common/asod.robot
Resource    ../../common/robot/ecpri_transport_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_cu.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/log/collect_logs.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot

*** Variables ***
${testline_name}      null
${CONFIGURATION}      null


*** Keywords ***
Check_syncState_and_lockState
    [Documentation]    Author: Wu Jerry
    ...                Description: Check syncState and lockState in WebEM
    [Arguments]    ${expect_syncstate}    ${expect_lockstate}
    ${syncstate_value}    selenium_coam.get_parameter_value
    ...    dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/CLOCK_R-1
    ...    abbr=syncStatus
    ...    filter_param=Clock synchronization status
    should be equal    ${syncstate_value}    ${expect_syncstate}
    ${lockstate_value}    selenium_coam.get_parameter_value
    ...    dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1/TOPP_R-1
    ...    filter_param=ToP slave lock state
    ...    abbr=lockState
    should be equal    ${lockstate_value}    ${expect_lockstate}
    
Cases common Setup
    [Documentation]    Author: Wu Jerry
    ...                Description: case common setup
    Du login page via webUI
    ${MRBTS_ID}    Get MRBTS Id in COAM WebEM
    set suite variable    ${MRBTS_ID}
    
Cases Common teardown
    [Documentation]    Author: Wu Jerry
    ...                Description: case common teardown
    Run Keyword And Ignore Error    DU COAM selenium logout
    Collect Logs IF Case Failed    TS_CASE_LOG_PATH=/home/ute/test_results
    CI_interface.Common Case Teardown
	
RU_Reset
    selenium_coam.Reset Ru
    Sleep    10s
    wait until keyword succeeds    10 min    10 sec    Du Check cell on air via WebUI without login
    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window

Cases560_14 Common teardown
    [Documentation]    Author: Wu Jerry
    ...                Description: case common teardown
    Run Keyword And Ignore Error    Restore parameter
    Run Keyword And Ignore Error    DU COAM selenium logout
    Collect Logs IF Case Failed    TS_CASE_LOG_PATH=/home/ute/test_results
    CI_interface.Common Case Teardown
	
Get Filter topDomainNumber
    [Documentation]  Author: Wu Jerry
    ...              Description: get topDomainNumber value
    ${topDomainNumber_value}    selenium_coam.get_parameter_value
    ...   dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1
    ...   abbr=topDomainNumber
    ...   filter_param=ToP domain number
    set suite variable    ${topDomainNumber_value}

Modify topDomainNumber in webui
    [Documentation]  Author: Wu Jerry
    ...              Description: modify topDomainNumber value
    selenium_coam.set_parameter_value
    ...    dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1
    ...    abbr=topDomainNumber
    ...    new_value=${modify_topDomainNumber}
    ...    filter_param=ToP domain number    
    sleep    1s
    selenium_coam.validate_plan
    sleep    2s
    selenium_coam.activate_plan    activate_plan_despite_errors=True

Restore topDomainNumber in webui
    [Documentation]  Author: Wu Jerry
    ...              Description: restore topDomainNumber value
    selenium_coam.set_parameter_value
    ...    dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1
    ...    abbr=topDomainNumber
    ...    new_value=${topDomainNumber_value}
    ...    filter_param=ToP domain number
    sleep    1s
    selenium_coam.validate_plan
    sleep    2s
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    
Get Filter eCpriMasterDomainNumber
    [Documentation]  Author: Wu Jerry
    ...              Description: get eCpriMasterDomainNumber value
    ${eCpriMasterDomainNumber_value}    selenium_coam.get_parameter_value
    ...   dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-1/ECPRIMASTER-1
    ...   abbr=eCpriMasterDomainNumber
    ...   filter_param=eCPRI Master domain number
    set suite variable    ${eCpriMasterDomainNumber_value}

Modify eCpriMasterDomainNumber in webui
    [Documentation]  Author: Wu Jerry
    ...              Description: modify eCpriMasterDomainNumber value
    selenium_coam.set_parameter_value
    ...    dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-1/ECPRIMASTER-1
    ...    abbr=eCpriMasterDomainNumber
    ...    new_value=${modify_eCpriMasterDomainNumber}
    ...    filter_param=eCPRI Master domain number  
    sleep    1s
    selenium_coam.validate_plan
    sleep    2s
    selenium_coam.activate_plan    activate_plan_despite_errors=True

Restore eCpriMasterDomainNumber in webui
    [Documentation]  Author: Wu Jerry
    ...              Description: restore eCpriMasterDomainNumber value
    selenium_coam.set_parameter_value
    ...    dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-1/ECPRIMASTER-1
    ...    abbr=eCpriMasterDomainNumber
    ...    new_value=${eCpriMasterDomainNumber_value}
    ...    filter_param=eCPRI Master domain number
    sleep    1s
    selenium_coam.validate_plan
    sleep    2s
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    sleep    1s

Restore parameter
    Run Keyword If    ${modify_topDomainNumber}!=${topDomainNumber_value}
    ...    Restore topDomainNumber in webui
    Run Keyword If    ${modify_eCpriMasterDomainNumber}!=${eCpriMasterDomainNumber_value}
    ...    Restore eCpriMasterDomainNumber in webui
    wait until keyword succeeds    8 min    8 sec    Du Check cell on air via WebUI without login
    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    Check_syncState_and_lockState    expect_syncstate=Locked    expect_lockstate=Locked

Check_expect_alarm
    [Documentation]    Author: Wu Jerry
    [Arguments]    ${alarm_id}
    @{alarm_info}     selenium_coam.get_active_alarm_info    alarm_filter=${alarm_id}
    should not be equal    ${alarm_info}    ${null}
    
Commission_CU_DU   
    [Documentation]    Author: Wu Jerry
    ...                Description: do cu and du commission
    Cloud DU connect to gnb coam via ssl
    ${TL_NAME}    set variable if    '${testline_name}' == 'null'    ${CONFIGURATION}    ${testline_name}
    ${pattern}    Set Variable    7_5(.*)
    ${TLNAME}    Get Regexp Matches    ${TL_NAME}    ${pattern}    1
    ${testlinename}    Set Variable    7_5${TLNAME}[0]
    COAM Commission with scf file    
    ...    scf_file_path=${CURDIR}/../../../../commissionings/HGZ/${testlinename}/SCF_0.190_DU.xml
    ...    is_pdl_checking_needed=${False}
    ...    timeout=600
    CU Full Commission
    ...    path_of_commission_file=${CURDIR}/../../../../commissionings/HGZ/${testlinename}/SCF_0.190_CU.xml
    wait until keyword succeeds    25 min    10 sec    COAM Check GNB cell on air
    COAM Teardown gnb connections

Test_suite_teardown
    [Documentation]    Author: Wu Jerry
    ...                Description: check gnb status after case execute 
    Du Check cell on air via WebUI

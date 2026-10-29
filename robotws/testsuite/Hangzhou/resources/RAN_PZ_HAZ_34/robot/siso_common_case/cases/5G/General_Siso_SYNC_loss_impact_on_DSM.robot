*** Settings ***
Documentation    Verify SYNC loss impact on DSM (Deep Sleep Mode)
...              Test verifies that when ToP master IP is changed to wrong IP,
...              alarms 4298 and 16 are raised, and RMOD enters deep sleep mode properly.
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/coam.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/nr_feature_on.robot

*** Keywords ***
General_Siso_SYNC_loss_impact_on_DSM
    [Documentation]    Verify SYNC loss impact on DSM (Deep Sleep Mode)
    ...
    ...    *Test Purpose*
    ...    Verify that when ToP master IP is changed to wrong IP, alarms 4298 and 16 are raised,
    ...    and RMOD enters deep sleep mode properly.
    ...
    ...    *Prerequisites*
    ...    - BTS should be commissioned and cells are up
    ...    - No alarm 4420 should exist before test
    ...
    ...    *Test Steps*
    ...    1. Modify phaseHoldoverSpecThreshold to 210 and energySavingMode to DEEPSLEEP
    ...    2. Wait for alarm 4420 to clear (timeout 30min)
    ...    3. Change ToP master IP to wrong IP
    ...    4. Verify alarms 4298 and 16 are raised
    ...    5. Wait for alarm 4420 to clear again
    ...    6. Restore ToP master IP to original value
    ...    7. Verify alarms 4298, 16, 4452, 4405 are cleared
    ...
    ...    *History*
    ...    - 01.07.2024 - Created - JIRA: https://jiradc.ext.net.nokia.com/browse/LEOPARD-2046
    ...    - Owner: kaihui.fan@nokia-sbell.com
    [Tags]    SYNC    DSM    DeepSleep    Classical    5G    LEOPARD-2046
    [Timeout]    90 minutes
    [Arguments]    ${wrong_master_ip_addr}=10.97.120.88    ${RMOD_index}=1
    Selenium Login And Disable Screen Lock
    Log    Update phaseHoldoverSpecThreshold and energySavingMode    level=INFO
    Log To Console    \n Update phaseHoldoverSpecThreshold and energySavingMode
    ${modify_params}    Create List
    ${phaseHoldoverSpecThreshold}    Create Dictionary    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-1/ECPRIMASTER-1
    ...    filter_param=Phase holdover specification threshold
    ...    p_name=phaseHoldoverSpecThreshold    value=210
    ${esm_param}    Get Energy Saving Mode Param Name
    ${energySavingMode}    Create Dictionary    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${RMOD_index}
    ...    filter_param=${esm_param}
    ...    p_name=energySavingMode    value=DEEPSLEEP
    Append To List    ${modify_params}    ${phaseHoldoverSpecThreshold}
    Append To List    ${modify_params}    ${energySavingMode}
    Modify Parameters On Webem    modify_params=${modify_params}
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type=${gNb_CuType}
    ${masterIp_addr_origin}    Get Parameter Via Webem    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1
    ...    filter_param=IP Address of the ToP master
    Log    Original master IP address: ${masterIp_addr_origin}    level=INFO
    Log To Console    \n Original master IP: ${masterIp_addr_origin}
    Wait For Alarm 4420 Cleared
    Wait Until Keyword Succeeds    5 times    30 sec
    ...    Check and Modify Single Parameter on WebUI
    ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1
    ...    filter_param=IP Address of the ToP master
    ...    abbr=masterIpAddr
    ...    new_value=${wrong_master_ip_addr}
    Log    Waiting to verify alarms 4298 and 16 are raised    level=INFO
    Log To Console    \n Verify alarms 4298 and 16 are raised
    ${faults_present}=    Run Keyword And Return Status
    ...    Wait Until Keyword Succeeds    15 min    30 sec    Get Expected Fault Present After Modify MasterIP
    Run Keyword If    not ${faults_present}    Log
    ...    Faults 4298/16 not present after 15 min, performing BTS site reset and retrying    level=WARN
    Run Keyword If    not ${faults_present}    Perform BTS Site Reset On WebUI
    Run Keyword If    not ${faults_present}
    ...    Wait Until Keyword Succeeds    15 min    30 sec    Get Expected Fault Present After Modify MasterIP
    Sleep    5 min
    Wait For Alarm 4420 Cleared
    Wait Until Keyword Succeeds    5 times    30 sec
    ...    Check and Modify Single Parameter on WebUI
    ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1
    ...    filter_param=IP Address of the ToP master
    ...    abbr=masterIpAddr
    ...    new_value=${masterIp_addr_origin}
    Log    Waiting to verify alarms are cleared    level=INFO
    Log To Console    \n Verify alarms 4298, 16, 4452, 4405 are cleared
    Wait Until Keyword Succeeds    15 min    30 sec    Get Expected Fault Absent After Modify MasterIP
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type=${gNb_CuType}

Wait For Alarm 4420 Cleared
    [Documentation]    Wait for alarm 4420 to be cleared with 30min timeout
    Log    Checking if alarm 4420 exists and waiting for it to clear (timeout 30min)    level=INFO
    Log To Console    \n Checking if alarm 4420 exists and waiting for it to clear (timeout 30min)
    Wait Until Keyword Succeeds    30 min    30 sec    Expect Fault Should Absent    faultId=4420


Get Expected Fault Present After Modify MasterIP
    [Documentation]    Verify that faults 4298 and 16 are present after master IP modification
    ...                Author: kaihui.fan@nokia-sbell.com
    ${fault_4298_status}    Run Keyword And Return Status    Expect Fault Should Present    faultId=4298
    ${fault_16_status}    Run Keyword And Return Status    Expect Fault Should Present    faultId=16
    ${all_faults_present}    Evaluate    ${fault_4298_status} and ${fault_16_status}
    Run Keyword If    ${all_faults_present}
    ...    Log    Expected faults 4298 and 16 are present    level=INFO
    ...    ELSE    Fail    Expected faults 4298 and 16 are not present

Get Expected Fault Absent After Modify MasterIP
    [Documentation]    Verify that faults 4298, 16, 4452, 4405 are absent after restoring master IP
    ...                Author: kaihui.fan@nokia-sbell.com
    ${fault_4298_status}    Run Keyword And Return Status    Expect Fault Should Absent    faultId=4298
    ${fault_16_status}    Run Keyword And Return Status    Expect Fault Should Absent    faultId=16
    ${fault_4452_status}    Run Keyword And Return Status    Expect Fault Should Absent    faultId=4452
    ${fault_4405_status}    Run Keyword And Return Status    Expect Fault Should Absent    faultId=4405
    ${all_faults_absent}    Evaluate    ${fault_4298_status} and ${fault_16_status} and ${fault_4452_status} and ${fault_4405_status}
    Run Keyword If    ${all_faults_absent}
    ...    Log    Expected faults 4298, 16, 4452, 4405 are absent    level=INFO
    ...    ELSE    Fail    Expected faults 4298, 16, 4452, 4405 are not all absent

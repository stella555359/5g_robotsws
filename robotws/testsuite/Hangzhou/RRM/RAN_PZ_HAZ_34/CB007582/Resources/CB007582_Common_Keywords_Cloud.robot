*** Settings ***
Documentation
...    Author: y63li
...    Email address: ying.15.li@nokia-sbell.com
...    Description: This feature describes the admission control for specific SR period configured.

Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_vdu.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_cloud.robot
Variables     ./CB007582_para.py


*** Variables ***
${cu_master_ip}              ${tl.gnbs[0].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.ip_addr}
${cu_master_username}        ${tl.gnbs[0].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.username}
${cu_master_password}        ${tl.gnbs[0].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.password}

${local_file_path}    /home/ute/log
${TEST_LOG_DIRECTORY}     /home/ute/log
${alarm_filter}   Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability
${connection}    OAM_CU
*** Keywords ***
Case Setup
    Log    \n****Case Setup   console=yes
    ${START_TIME}=    Get time    exclude_millis=yes
    Set Suite Variable    ${START_TIME}
    Check Cell Should Be Onair

Case Teardown
    Log    \n****Case Teardown  console=yes
    run keyword and ignore error   Recover testline

Check Cell Should Be Onair
    Log    \n****Check Cell Should Be Onair  console=yes
    wait until keyword succeeds    600   30   vDU Verify All Cells Status Should Be Onair

Configure cell activation parameters
    Log    \n****Configure cell activation parameters     console=yes
    CU Delta Commission update    parameters=${NSA_SA_CELL_ACT}    log_dir=${TEST_LOG_DIRECTORY}

Recover cell activation parameters
    Log    \n****Recover cell activation parameters     console=yes
    CU Delta Commission update    parameters=${NSA_SA_CELL_REC}    log_dir=${TEST_LOG_DIRECTORY}

Lock cell on GNB-CU
    Log    \n****CLock cell on GNB-CU     console=yes
    CU Delta Commission update    parameters=${CELL1_LOCK}    log_dir=${TEST_LOG_DIRECTORY}

Unlock cell1 on GNB-CU
    Log    \n****Unlock cell on GNB-CU     console=yes
    CU Delta Commission update    parameters=${CELL1_UNLOCK}    log_dir=${TEST_LOG_DIRECTORY}


Lock X2 link
    Log    \n****Lock X2 link    console=yes
    CU Delta Commission update    parameters=${X2_LOCK}    log_dir=${TEST_LOG_DIRECTORY}

Unlock X2 link
    Log    \n****Unlock X2 link    console=yes
    CU Delta Commission update    parameters=${X2_UNLOCK}    log_dir=${TEST_LOG_DIRECTORY}

Lock NG link
    Log    \n****Lock NG link    console=yes
    CU Delta Commission update    parameters=${NG_LOCK}    log_dir=${TEST_LOG_DIRECTORY}

Unlock NG link
    Log    \n****Unlock NG link    console=yes
    CU Delta Commission update    parameters=${NG_UNLOCK}    log_dir=${TEST_LOG_DIRECTORY}

Check Fault and cell State
    Log    \n****Check Fault and cell State    console=yes
    [Arguments]    ${severity}    ${operational}
    Check 7107 Fault Raised    severity=${severity}
    Check cell state    operational=${operational}

Check 7107 Fault Raised
    Log    \n****Check 7107 Fault Raised    console=yes
    [Arguments]    ${severity}    ${fault}=7107
    Connect to cu via ssl    gnb_index=${0}    connection=${connection}
    ${check_alarm_output}    cu.get_active_alarms    timeout=60s    connection=${connection}
    ${alarm_num}    set variable    ${check_alarm_output['total']}
    @{active_alarms}    set variable    ${check_alarm_output['alarms']}
    ${fault_dic}     Set Variable     ${active_alarms}[0]
    ${Severity_list}    Set Variable     ${fault_dic}[severity]
    ${Alarm_ID_list}    Set Variable    ${fault_dic}[alarm_id]
    ${Alarm_name_list}    Set Variable    ${fault_dic}[alarm_name]
    ${Fault_ID_list}    Set Variable     ${fault_dic}[fault_id]
    ${Fault_name_list}    Set Variable     ${fault_dic}[fault_name]
    Should Be Equal    ${Severity_list}   ${Severity}
    Should Be Equal    ${Alarm_ID_list}   ${7114}
    Should Be Equal    ${Fault_ID_list}   ${fault}
    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Check cell state
    Log    \n****Check cell state    console=yes
    [Arguments]    ${operational}
    Connect to cu via ssl    gnb_index=${0}    connection=${connection}
    ${cell_administrativeState}  ${cell_operationalState}=  CU Get Specified Cell Status  cell_id=${1}
    Log To Console   ${cell_operationalState}
    should be equal   ${cell_operationalState}   ${operational}
    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Check No Other Fault Raise
    Log    \nCheck No Other Fault Raise    console=yes
    Recored Current Active Alarm
    Check No New Active Alarm Exist

Recored Current Active Alarm
    Log    \n****Recored Current Active Alarm   console=yes
    Connect to cu via ssl    gnb_index=${0}    connection=${connection}
    ${check_alarm_output}    cu.get_active_alarms    timeout=60s    connection=${connection}
    ${alarm_num}    set variable    ${check_alarm_output['total']}
    @{active_alarms}    set variable    ${check_alarm_output['alarms']}
    @{alarm_ID_list}    Create List
    FOR    ${alarm}    IN    @{active_alarms}
        Append To List    ${alarm_ID_list}    ${alarm["alarm_id"]}
    END
    set suite variable    @{alarm_ID_list}
    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Check No New Active Alarm Exist
    Log    \n****Check No New Active Alarm Exist   console=yes
    Connect to cu via ssl    gnb_index=${0}    connection=${connection}
     ${check_alarm_output}    cu.get_active_alarms    timeout=60s    connection=${connection}
    @{active_alarms}    set variable    ${check_alarm_output['alarms']}
    FOR    ${alarm}    IN    @{active_alarms}
        Should be true    ${alarm["alarm_id"]} in ${alarm_ID_list}
    END
    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Recover testline
    Log    \n****Recover testline   console=yes
    Connect to cu via ssl    gnb_index=${0}    connection=${connection}
    run keyword and ignore error   Unlock cell1 on GNB-CU
    run keyword and ignore error   Unlock X2 link
    run keyword and ignore error   Unlock NG link
    run keyword and ignore error   Recover cell activation parameters
    run keyword and ignore error   CU Logout
    run keyword and ignore error   CU Rest Logout
    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

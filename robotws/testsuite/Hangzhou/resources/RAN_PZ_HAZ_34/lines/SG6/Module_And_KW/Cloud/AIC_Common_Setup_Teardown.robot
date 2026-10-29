*** Settings ***
Documentation
...    Author: mengli yang
...    Email address: mengli.yang@nokia-sbell.com
...    Maintainer: mengli yang
...    Email address: mengli.yang@nokia-sbell.com
...    Common KWs related to Common Suite Setup For AIC Common Suite/test Setup/Teardown
...    All the bugs/new keyword needs/improvement should be raised in Jira and assign to the Maintainer
...    Jira link: https://jiradc.ext.net.nokia.com/projects/PZ1HAZTA/issues
...    Guideline: https://confluence.ext.net.nokia.com/display/SRANPRODHZHTA/09.+AIC+Common+Resource+Supporting+Mode+Improvement

*** Keywords ***
Common Suite Setup For AIC
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This keyword creates suite name directory path as ${SUITE_LOG_DIRECTORY}//logs//
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | None | NA | NA |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    |  Common Suite Setup For RRM  |
    ...
    Create Suite Directory
    ${vdu_version}=    Get vDU Version
    Set Suite Variable    ${VDU_VERSION}    ${vdu_version}
    Get SSH Connection Infor For vDU K8s Master
    Get SSH Connection Infor For vCU K8s Master
    ${mrbts_id_list}    ${nrbts_id_list}    Get Multi Gnb Id
    Set suite variable     ${MRBTS_ID_LIST}    ${mrbts_id_list}
    Set suite variable     ${NRBTS_ID_LIST}    ${nrbts_id_list}
    Run Keyword And Ignore Error    Get Iperf Info
    Run Keyword And Ignore Error    Prepare Netrc On VM
    Run Keyword And Ignore Error    Get TestLine Name From UTE Cloud
    Run Keyword And Ignore Error    Get Testline Type

Common Test Setup For AIC
    [Arguments]     ${vdu_index}=${0}    ${gnb_index}=${0}
    [Documentation]    This keyword is used to create log directory for case level, and Prepare ENV until on-air.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    |  Common Test Setup For AIC  |
    ...
    Create Case Directory
    _Check Maximum Line Length
    ${BEGIN_RESOURCES_USAGE_LIST}    Run keyword And Ignore Error    Start To Get Resources Usage For All vDU
    vDU Backup SCF From Test Line
    vCU Backup SCF From Test Line
    Run Keyword IF    '_AP_' in '${TESTLINE_TYPE}'
    ...     vDU Check All Cells Status Should Be Onair For All DUs     gnb_index=${0}
    Clear Legacy Logs On vDU And vCU
    ${file}    create_a_file    log_path=${TEST_LOG_DIRECTORY}/vdu_alarm_setup    file_name=vdu_active_alarm.csv
    Run keyword and ignore error    Save vDU Active Alarm    file_name=${file}    vdu_index=${vdu_index}
    ${file}    create_a_file    log_path=${TEST_LOG_DIRECTORY}/vdu_alarm_setup    file_name=vdu_historical_alarm.csv
    Run keyword and ignore error    Save vDU Historical Alarm    file_name=${file}    vdu_index=${vdu_index}
    ${file}    create_a_file    log_path=${TEST_LOG_DIRECTORY}/vcu_alarm_setup    file_name=vcu_active_alarm.csv
    Run keyword and ignore error    Get Active Alarm In vCU    file_name=${file}   gnb_index=${gnb_index}
    ${file}    create_a_file    log_path=${TEST_LOG_DIRECTORY}/vcu_alarm_setup    file_name=vcu_historical_alarm.csv
    Run keyword and ignore error    Get Historical Alarm In VCU    file_name=${file}   gnb_index=${gnb_index}
    Run keyword and ignore error    Start Alarm Watch Dog

Common Suite Teardown For AIC
    [Documentation]    This keyword is used to Clear Legacy Logs On vDU And vCU
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | None | NA | NA |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    |  Common Suite Teardown For RRM  |
    ...
    [Timeout]    15 min
    Run keyword and ignore error    Clear Legacy Logs On vDU And vCU
    # Run Keyword And Ignore Error    Remove Netrc On VM
    # Run Keyword And Ignore Error    Run keyword If    ${MoveLog_to_Logserver}
    # ...    Move All Test Result To Log Server


Common Test Teardown For AIC
    [Arguments]    ${vdu_index}=${0}    ${gnb_index}=${0}
    [Documentation]    This keyword is used to collect snapshot if test case failed, save SCF and alarm
    ...    teardown the COAM connections.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | None | NA | NA |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    |  Common Test Teardown For RRM  |
    ...
    [Timeout]    72h
    Run Keyword If Test Failed    Run Keyword If    '${DEBUG_MODE}'!='${True}'
    ...    Save Local Snapshot In vDU With Judge    local_snapshot_location=vDU_snapshot
    Run Keyword If Test Failed    Run Keyword If    '${DEBUG_MODE}'!='${True}'
    ...    Save Local Snapshot In vCU With Judge    local_snapshot_location=vCU_snapshot
    ${file}    create_a_file    log_path=${TEST_LOG_DIRECTORY}/vdu_alarm_teardown    file_name=vdu_active_alarm.csv
    Run keyword and ignore error    Save vDU Active Alarm    file_name=${file}    vdu_index=${vdu_index}
    ${file}    create_a_file    log_path=${TEST_LOG_DIRECTORY}/vdu_alarm_teardown    file_name=vdu_historical_alarm.csv
    Run keyword and ignore error    Save vDU Historical Alarm    file_name=${file}    vdu_index=${vdu_index}
    ${file}    create_a_file    log_path=${TEST_LOG_DIRECTORY}/vcu_alarm_teardown    file_name=vcu_active_alarm.csv
    Run keyword and ignore error    Get Active Alarm In vCU    file_name=${file}   gnb_index=${gnb_index}
    ${file}    create_a_file    log_path=${TEST_LOG_DIRECTORY}/vcu_alarm_teardown    file_name=vcu_historical_alarm.csv
    Run keyword and ignore error    Get Historical Alarm In VCU    file_name=${file}   gnb_index=${gnb_index}
    Run keyword and ignore error    Compare Alarms And Generate Difference    NE_TYPE=vdu
    Run keyword and ignore error    Compare Alarms And Generate Difference    NE_TYPE=vcu
#    ${status}    Check Anomalous Alarms Is Appear
#    Run Keyword If    '${status}'=='True'    Stop And Fix
    Run keyword and ignore error    Logout To vCU By Rest
    Run keyword and ignore error    vDU Logout By Rest
    Run keyword and ignore error    Stop To Get Resources Usage For All vDU
    Run keyword and ignore error    interface.Common step trigger
    Run Keyword If    "_AP_" in '${TESTLINE_TYPE}'
    ...    Run Keyword   Airphone Common Teardown
    Run keyword and ignore error    Stop And Analysis Alarm Watch Dog

Common Test Setup For NFTA
    [Arguments]     ${vdu_index}=${0}    ${gnb_index}=${0}
    [Documentation]    This keyword is used to create log directory for case level, and Prepare ENV until on-air.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    |  Common Test Setup For AIC  |
    ...
    Create Case Directory
    _Check Maximum Line Length
    ${backup_vDU_scf_file}    vDU Backup SCF From Test Line
    Set Test variable    ${backup_vDU_scf_file}
    ${backup_vCU_scf_file}    vCU Backup SCF From Test Line
    Set Test variable    ${backup_vCU_scf_file}
    vDU Check All Cells Status Should Be Onair For All DUs     gnb_index=${0}
    Clear Legacy Logs On vDU And vCU
    ${file}    create_a_file    log_path=${TEST_LOG_DIRECTORY}/vdu_alarm_setup    file_name=vdu_active_alarm.csv
    Run keyword and ignore error    Save vDU Active Alarm    file_name=${file}    vdu_index=${vdu_index}
    ${file}    create_a_file    log_path=${TEST_LOG_DIRECTORY}/vdu_alarm_setup    file_name=vdu_historical_alarm.csv
    Run keyword and ignore error    Save vDU Historical Alarm    file_name=${file}    vdu_index=${vdu_index}
    ${file}    create_a_file    log_path=${TEST_LOG_DIRECTORY}/vcu_alarm_setup    file_name=vcu_active_alarm.csv
    Run keyword and ignore error    Get Active Alarm In vCU    file_name=${file}   gnb_index=${gnb_index}
    ${file}    create_a_file    log_path=${TEST_LOG_DIRECTORY}/vcu_alarm_setup    file_name=vcu_historical_alarm.csv
    Run keyword and ignore error    Get Historical Alarm In VCU    file_name=${file}   gnb_index=${gnb_index}


Common Test Teardown For NFTA
    [Arguments]    ${vdu_index}=${0}    ${gnb_index}=${0}
    [Documentation]    This keyword is used to collect snapshot if test case failed, save SCF and alarm
    ...    teardown the COAM connections.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | None | NA | NA |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    |  Common Test Teardown For RRM  |
    ...
    [Timeout]    72h
    Run Keyword If Test Failed    Save Local Snapshot In vDU With Judge    local_snapshot_location=vDU_snapshot
    Run Keyword If Test Failed    Save Local Snapshot In vCU With Judge    local_snapshot_location=vCU_snapshot
    ${file}    create_a_file    log_path=${TEST_LOG_DIRECTORY}/vdu_alarm_teardown    file_name=vdu_active_alarm.csv
    Run keyword and ignore error    Save vDU Active Alarm    file_name=${file}    vdu_index=${vdu_index}
    ${file}    create_a_file    log_path=${TEST_LOG_DIRECTORY}/vdu_alarm_teardown    file_name=vdu_historical_alarm.csv
    Run keyword and ignore error    Save vDU Historical Alarm    file_name=${file}    vdu_index=${vdu_index}
    ${file}    create_a_file    log_path=${TEST_LOG_DIRECTORY}/vcu_alarm_teardown    file_name=vcu_active_alarm.csv
    Run keyword and ignore error    Get Active Alarm In vCU    file_name=${file}   gnb_index=${gnb_index}
    ${file}    create_a_file    log_path=${TEST_LOG_DIRECTORY}/vcu_alarm_teardown    file_name=vcu_historical_alarm.csv
    Run keyword and ignore error    Get Historical Alarm In VCU    file_name=${file}   gnb_index=${gnb_index}
    Run keyword and ignore error    Compare Alarms And Generate Difference    NE_TYPE=vdu
    Run keyword and ignore error    Compare Alarms And Generate Difference    NE_TYPE=vcu
    Run keyword and ignore error    Collect and Download Startup or Journal log    hostname=${VDU_HOSTNAME}
    ...                                                                            username=${VDU_USERNAME}
    ...                                                                            password=${VDU_PASSWORD}
    ...                                                                            alias=collect_vdu_log
    ...                                                                            cnf_type=vdu
    ...                                                                            namespace=${VDU_NAMESPACE}
    Run keyword and ignore error    Collect and Download Startup or Journal log    hostname=${VCU_HOSTNAME}
    ...                                                                            username=${VCU_USERNAME}
    ...                                                                            password=${VCU_PASSWORD}
    ...                                                                            alias=collect_vcu_log
    ...                                                                            cnf_type=vcu
    ...                                                                            namespace=${VCU_NAMESPACE}
    Run keyword and ignore error    Download Log Files to Log Server
    Check All Cells On Air In vCU    gnb_index=${0}
    ${loop_times}=    set variable    ${3}
    FOR   ${index}   IN RANGE   ${loop_times}
        ${status}    Run Keyword And Return Status     Restore vDU And vCU
        exit for loop if    ${status}
    END
    Run keyword and ignore error    Logout To vCU By Rest
    Run keyword and ignore error    vDU Logout By Rest


Restore vDU And vCU
    [Documentation]    Author: Liu Renhui
    ...                Contact: renhui-david.liu@nokia-sbell.com
    ...                This keyword is used to restore vDU and vCU with backup scf files.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | None | NA | NA |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    |  Clear Legacy Logs On Sbts  |
    ...
    vDU Update Full SCF By Rest    scf_path=${backup_vDU_scf_file}    vdu_index=${0}
    vCU Full Commssion By Rest    path_of_commission_file=${backup_vCU_scf_file}    plan_name=Plan_scf_vcu
    Wait Until Keyword Succeeds    600    20    Check All Cells On Air In vCU    gnb_index=${0}


Stop And Fix
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This keyword is used to stop and fix
    Run keyword and ignore error    truck_roll.report_to_channel
    Run keyword and ignore error    truck_roll.send_email
    Sleep    72h


Clear Legacy Logs On vDU And vCU
    [Arguments]    ${vdu_index}=${0}
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This keyword is used to clear legacy logs, e.g. aasyslog, wiresahrk log, etc.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | None | NA | NA |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    |  Clear Legacy Logs On Sbts  |
    ...
    Log    ${vdu_index} is not used
    ${vdu_conn}=    basic.master_connect    hostname=${VDU_HOSTNAME}
    ...                           username=${VDU_USERNAME}
    ...                           password=${VDU_PASSWORD}
    ...                           alias=vdu_master
    Set Variable    ${vdu_conn}
    Run Keyword And Ignore Error    tafssh.execute    command=rm -rf /tmp/bip/    connection=${vdu_conn}
    Run Keyword And Ignore Error    tafssh.execute    command=rm -rf /tmp/tti/    connection=${vdu_conn}
    Run Keyword And Ignore Error    tafssh.execute    command=rm -rf /tmp/wireshark/    connection=${vdu_conn}
    Run Keyword And Ignore Error    tafssh.execute    command=rm -rf /tmp/k8s/    connection=${vdu_conn}
    ${vcu_conn}=    basic.master_connect    hostname=${VCU_HOSTNAME}
    ...                           username=${VCU_USERNAME}
    ...                           password=${VCU_PASSWORD}
    ...                           alias=vcu_master
    Set Variable    ${vcu_conn}
    Run Keyword And Ignore Error    tafssh.execute    command=rm -rf /tmp/bip/    connection=${vcu_conn}
    Run Keyword And Ignore Error    tafssh.execute    command=rm -rf /tmp/tti/    connection=${vcu_conn}
    Run Keyword And Ignore Error    tafssh.execute    command=rm -rf /tmp/*wireshark/    connection=${vcu_conn}
    Run Keyword And Ignore Error    tafssh.execute    command=rm -rf /tmp/*pcap/    connection=${vcu_conn}
    Run Keyword And Ignore Error    tafssh.execute    command=rm -rf /tmp/k8s/    connection=${vcu_conn}
    [Teardown]    Run Keywords    run keyword and ignore error    basic.master_close    alias=vcu_master    AND
    ...                           run keyword and ignore error    basic.master_close    alias=vdu_master


Create Suite Directory
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This keyword is to create suite directory
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | None | NA | NA |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    |  Create Suite Directory  |
    ...
    ${suite_name}=    Replace String    ${SUITE NAME}    ${SPACE}    _
    ${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    ${suite_log_path}    Join path    ${OUTPUT DIR}    ${suite_name}_${timestamp}
    Set Suite Variable    ${SUITE_LOG_DIRECTORY}    ${suite_log_path}
    Create directory    ${SUITE_LOG_DIRECTORY}
    Log to Console    \n***Suite Log Directory ${SUITE_LOG_DIRECTORY}***

Create Case Directory
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This keyword is to create suite directory
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | None | NA | NA |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    |  Create Case Directory  |
    ...
    ${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    ${tc_name}=    Replace String    ${TEST_NAME}    ${SPACE}    _
    ${case_log_path}    Join path    ${SUITE_LOG_DIRECTORY}    ${tc_name}_${timestamp}
    Set Suite Variable    ${TEST_LOG_DIRECTORY}    ${case_log_path}
    Create directory    ${TEST_LOG_DIRECTORY}
    Log to Console    \n***Test Case Log Directory ${TEST_LOG_DIRECTORY}***

_Check Maximum Line Length
    [Documentation]   This keyword is to Check Maximum Line Length
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | None | NA | NA |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    |  _Check Maximum Line Length  |
    ...
    ${expression}    set variable  [("line_number:{}".format(int(i+1)),"length:{}".format(len(line.strip('\\n'))),line.strip('\\r\\n'))
    ${expression}    set variable    ${expression} for i,line in enumerate(open("${SUITE_SOURCE}")) if len(line.strip('\\n'))>150]
    ${invalid_lines}    evaluate    ${expression}
    run keyword if    ${invalid_lines.__len__()>0}    log to console    robot line length should be <=150(${SUITE_SOURCE})
    should be true    ${invalid_lines.__len__()==0}    ${invalid_lines}

Get Unique ID
    [Arguments]  ${prefix}=${EMPTY}   ${suffix}=${EMPTY}   ${precise}=HIGH
    [Documentation]   this kw is used to get unique id
    ...     Author: Yang Mengli
    ...     Contact: mengli.yang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | prefix       | no | prefix, default is ${EMTPY} |
    ...    | suffix       | no | suffix, default is ${EMTPY} |
    ...    | precise      | no | precise, HIGH or LOW, default is HIGH |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...  | ${tmp_id} | Get Unique ID |
    ...  | ${tmp_id} | Get Unique ID | prefix=myprefix |
    ...  | ${tmp_id} | Get Unique ID | prefix=myprefix | precise=HIGH |
    ...  | ${tmp_id} | Get Unique ID | precise=HIGH |
    ...  | ${tmp_id} | Get Unique ID | precise=LOW |
    ...  | ${tmp_id} | Get Unique ID | precise=FORMAT_DATETIME |
    ...  | ${tmp_id} | Get Unique ID | precise=HIGH_WITH_FORMAT_DATETIME_EPOCH |
    ...
    ${precise}  Set Variable  ${precise.upper()}
    ${rtn}  Run Keyword If  "${precise}"=="HIGH"  _Get Unique ID High Precise  prefix=${prefix}   suffix=${suffix}
    ...   ELSE IF  "${precise}"=="LOW"    _Get Unique ID LOW Precise   prefix=${prefix}   suffix=${suffix}
    ...   ELSE IF   "${precise}"=="FORMAT_DATETIME"   _Get Unique ID Format Datetime   prefix=${prefix}   suffix=${suffix}
    ...   ELSE IF   "${precise}"=="HIGH_WITH_FORMAT_DATETIME_EPOCH"
                 ...   _Get Unique ID Format High Precise Plus Datetime Epoch   prefix=${prefix}   suffix=${suffix}
    [Return]    ${rtn}


_Get Unique ID High Precise
    [Arguments]  ${prefix}=${EMPTY}   ${suffix}=${EMPTY}
    ${unique_id}    Evaluate    str(uuid.uuid4())    modules=uuid
    ${unique_id}    String.Replace String    ${unique_id}    -    ${EMPTY}
    [Return]    ${prefix}${unique_id}${suffix}


_Get Unique ID LOW Precise
    [Arguments]  ${prefix}=${EMPTY}   ${suffix}=${EMPTY}
    ${unique_id}    Evaluate    str(time.time())    modules=time
    ${unique_id}    String.Replace String    ${unique_id}    .    ${EMPTY}
    [Return]    ${prefix}${unique_id}${suffix}


_Get Unique ID Format Datetime
    [Arguments]  ${prefix}=${EMPTY}   ${suffix}=${EMPTY}
    ${unique_id_part1}    Evaluate    time.strftime("%Y%m%d_%H%M%S", time.localtime())    modules=time

    ${unique_id_part2}    Evaluate     str(time.time())    modules=time
    ${unique_id_part2}   set variable  ${unique_id_part2.split(".")[-1]}

    ${unique_id}    set variable   ${unique_id_part1}_${unique_id_part2}
    [Return]    ${prefix}${unique_id}${suffix}


_Get Unique ID Format High Precise Plus Datetime Epoch
    [Arguments]  ${prefix}=${EMPTY}   ${suffix}=${EMPTY}
    ${unique_id_part1}    Evaluate    str(uuid.uuid4())    modules=uuid
    ${unique_id_part1}    String.Replace String    ${unique_id_part1}    -    ${EMPTY}

    ${unique_id_part2}    Evaluate    time.strftime("%Y%m%d_%H%M%S", time.localtime())    modules=time

    ${unique_id}    set variable   ${unique_id_part1}_${unique_id_part2}
    [Return]    ${prefix}${unique_id}${suffix}

Get Test Case Name
    [Documentation]   Get Test Case Name
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    | Return Value | Description |
    ...    | ${rtn} | 5GC000706_Handling_of_interworking_between_DRX_and_Measurement_gaps |
    ...
    ...    Example
    ...    | ${case_name} | Get Test Case Name  |
    ...
    ${rtn}  Set Variable  ${TEST_NAME.replace(" ","_").replace(":","_")}
    [Return]  ${rtn}

Get SSH Connection Infor For vDU K8s Master
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0
    [Documentation]   this kw is used to Get SSH Connection Infor For vDU K8s Master
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | no | The list index from tl.cu[], it will use the index of gnb |
    ...    | vdu_index | no | The list index from tl.dus[], it will use the index of VDU |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Get SSH Connection Infor For vDU K8s Master |
    ...
    ${vdu_k8s_master_ssh_connection_info}    Get vDU K8s Master SSH Connection Info    gnb_index=${gnb_index}
    ...                                                                         vdu_index=${vdu_index}
    ${vdu_hostname}    set variable    ${vdu_k8s_master_ssh_connection_info["addr"]}
    ${vdu_username}    set variable    ${vdu_k8s_master_ssh_connection_info["username"]}
    ${vdu_password}    set variable    ${vdu_k8s_master_ssh_connection_info["password"]}
    ${ns}    Get vDU Namespace From Config File
    Set Suite Variable    ${VDU_HOSTNAME}    ${vdu_hostname}
    Set Suite Variable    ${VDU_USERNAME}    ${vdu_username}
    Set Suite Variable    ${VDU_PASSWORD}    ${vdu_password}
    Set Suite Variable    ${VDU_NAMESPACE}    ${ns}

Get SSH Connection Infor For vCU K8s Master
    [Arguments]    ${gnb_index}=0
    [Documentation]   this kw is used to Get SSH Connection Infor For vCU K8s Master
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | no | The list index from tl.cu[], it will use the index of gnb |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Get SSH Connection Infor For vCU K8s Master |
    ...
    ${ns}   Get vCU Namespace From Config File    gnb_index=${gnb_index}
    ${ip}=    Set Variable  ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
    ${username}=    Set Variable   ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
    ${password}=    Set Variable  ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}
    Set Suite Variable    ${VCU_HOSTNAME}    ${ip}
    Set Suite Variable    ${VCU_USERNAME}    ${username}
    Set Suite Variable    ${VCU_PASSWORD}    ${password}
    Set Suite Variable    ${VCU_NAMESPACE}    ${ns}


Get SSH Connection Infor For Multiple vCU K8s Master
    [Arguments]    ${gnb_index}=0
    [Documentation]   this kw is used to Get SSH Connection Infor For vCU K8s Master
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | no | The list index from tl.cu[], it will use the index of gnb |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Get SSH Connection Infor For vCU K8s Master |
    ...
    Log    ${gnb_index} is not used
    ${ip_list}=  create list
    ${username_list}=  create list
    ${password_list}=  create list
    ${ns_list}=  create list
    ${vCU_number}=    Get vCU Number
    FOR    ${index}    IN RANGE    ${vCU_number}
        ${ns}   Get vCU Namespace From Config File    gnb_index=${index}
        ${ip}=    Set Variable  ${tl.gnbs[${index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
        ${username}=    Set Variable   ${tl.gnbs[${index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
        ${password}=    Set Variable  ${tl.gnbs[${index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}
        Append To List   ${ip_list}       ${ip}
        Append To List   ${username_list}       ${username}
        Append To List   ${password_list}       ${password}
        Append To List   ${ns_list}       ${ns}
    END
    [Return]    ${ip_list}    ${username_list}    ${password_list}    ${ns_list}


Get SSH Connection Infor For Multiple vDU K8s Master
    [Arguments]    ${gnb_index}=0
    [Documentation]   this kw is used to Get SSH Connection Infor For vCU K8s Master
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | no | The list index from tl.cu[], it will use the index of gnb |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Get SSH Connection Infor For vCU K8s Master |
    ...
    ${vdu_hostname_list}=  create list
    ${vdu_username_list}=  create list
    ${vdu_password_list}=  create list
    ${vdu_ns_list}=  create list
    ${du_number}    Get vDU Number    gnb_index=${gnb_index}
    FOR    ${index}    IN RANGE    ${du_number}
        ${vdu_k8s_master_ssh_connection_info}    Get vDU K8s Master SSH Connection Info    gnb_index=${gnb_index}
        ...                                                                                vdu_index=${index}
        ${vdu_hostname}    set variable    ${vdu_k8s_master_ssh_connection_info["addr"]}
        ${vdu_username}    set variable    ${vdu_k8s_master_ssh_connection_info["username"]}
        ${vdu_password}    set variable    ${vdu_k8s_master_ssh_connection_info["password"]}
        ${ns}    Get vDU Namespace From Config File
        Append To List   ${vdu_hostname_list}       ${vdu_hostname}
        Append To List   ${vdu_username_list}       ${vdu_username}
        Append To List   ${vdu_password_list}       ${vdu_password}
        Append To List   ${vdu_ns_list}       ${ns}
    END
    [Return]    ${vdu_hostname_list}    ${vdu_username_list}    ${vdu_password_list}    ${vdu_ns_list}

Get SSH Connection Infor For Multiple vDU With Different vCU
    [Arguments]
    [Documentation]   this kw is used to Get SSH Connection Infor For vCU K8s Master
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | no | The list index from tl.cu[], it will use the index of gnb |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Get SSH Connection Infor For vCU K8s Master |
    ...
    &{vdu_hostname_dict}=    Create Dictionary
    &{vdu_username_dict}=    Create Dictionary
    &{vdu_password_dict}=    Create Dictionary
    &{vdu_ns_dict}=    Create Dictionary
    ${vCU_number}=    Get vCU Number
    FOR    ${index}    IN RANGE    ${vCU_number}
        ${vdu_hostname_list}    ${vdu_username_list}    ${vdu_password_list}    ${vdu_ns_list}
        ...                                             Get SSH Connection Infor For Multiple vDU K8s Master
        ...                                             gnb_index=${index}
        Set To Dictionary    ${vdu_hostname_dict}    vcu_${index}_vdu_hostname=${vdu_hostname_list}
        Set To Dictionary    ${vdu_username_dict}    vcu_${index}_vdu_username=${vdu_username_list}
        Set To Dictionary    ${vdu_password_dict}    vcu_${index}_vdu_password=${vdu_password_list}
        Set To Dictionary    ${vdu_ns_dict}          vcu_${index}_vdu_ns=${vdu_ns_list}
    END
    [Return]    ${vdu_hostname_dict}    ${vdu_username_dict}    ${vdu_password_dict}    ${vdu_ns_dict}


_Get Resources Usage
    [Arguments]    ${host}=${VDU_HOSTNAME}    ${user}=${VDU_USERNAME}    ${password}=${VDU_PASSWORD}
    ...            ${namespace}=${VDU_NAMESPACE}    ${pod}=po-cran1-cprt-0    ${port}=15057
    &{hop}=    Create Dictionary
    ...    host=${PC_HOST}
    ...    user=${PC_USER}
    ...    password=${PC_PASSWORD}
    &{k8s}=    Create Dictionary
    ...    host=${host}
    ...    user=${user}
    ...    password=${password}
    ...    proxy=${hop}
    aashell.create_aashell_cli
    ...    name=aashell
    ...    hops=${k8s}
    ...    namespace=${namespace}
    ...    pod=${pod}
    ...    port=${port}
    aashell.Setup    aashell
    ${resources_usage}    aashell.Get Resources Usage    aashell
    [Return]    ${resources_usage}
    [Teardown]    aashell.Teardown    aashell

Start To Get Resources Usage
    [Arguments]    ${host}=${VDU_HOSTNAME}    ${user}=${VDU_USERNAME}    ${password}=${VDU_PASSWORD}
    ...            ${namespace}=${VDU_NAMESPACE}    ${pod_list}=po-cran1-cprt-0    ${port}=15057
    [Documentation]   this kw is used to Start To Get Resources Usage
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | host | define vdu ip address |
    ...    | user | define vdu user name |
    ...    | password | define vdu password |
    ...    | namespace | define vdu namespace |
    ...    | pod_list | define pod list which will be check |
    ...    | port | define port id |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    |  Start To Get Resources Usage  |
    ...
    ${begin_vdu_resources_usage_list}=  create list
    FOR   ${pod}   IN   @{pod_list}
        ${begin_resources_usage}    _Get Resources Usage    host=${host}    user=${user}    password=${password}
        ...                                                 namespace=${namespace}    pod=${pod}    port=${port}
        Append To List    ${begin_vdu_resources_usage_list}    ${begin_resources_usage}
    END
    Set Test Variable    ${begin_vdu_resources_usage_list}
    [Return]    ${begin_vdu_resources_usage_list}


Start To Get Resources Usage For All vDU
    [Arguments]    ${gnb_index}=${0}
    [Documentation]   this kw is used to Start To Get Resources Usage For All vDU
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | define which gnb will is used |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    |  Start To Get Resources Usage For All vDU  |
    ...
    ${pod_list}    create list    po-cran1-cprt-0    po-cran1-up-0
    ${begin_resources_usage_list}=  create list
    ${vdu_hostname_list}    ${vdu_username_list}    ${vdu_password_list}    ${vdu_ns_list}
    ...                               Get SSH Connection Infor For Multiple vDU K8s Master
    ${du_number}    Get vDU Number    gnb_index=${gnb_index}
    FOR    ${index}    IN RANGE    ${du_number}
        ${begin_vdu_resources_usage_list}    Start To Get Resources Usage    host=${vdu_hostname_list[${index}]}
        ...                                                         user=${vdu_username_list[${index}]}
        ...                                                         password=${vdu_password_list[${index}]}
        ...                                                         namespace=${vdu_ns_list[${index}]}
        ...                                                         pod_list=${pod_list}
    END
    Append To List    ${begin_resources_usage_list}    ${begin_vdu_resources_usage_list}
    Set Test Variable    ${BEGIN_RESOURCES_USAGE_LIST}    ${begin_resources_usage_list}
    [Return]    ${BEGIN_RESOURCES_USAGE_LIST}

Stop To Get Resources Usage
    [Arguments]    ${host}=${VDU_HOSTNAME}    ${user}=${VDU_USERNAME}    ${password}=${VDU_PASSWORD}
    ...            ${namespace}=${VDU_NAMESPACE}    ${pod_list}=po-cran1-cprt-0    ${port}=15057
    [Documentation]   this kw is used to Stop To Get Resources Usage
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | host | define vdu ip address |
    ...    | user | define vdu user name |
    ...    | password | define vdu password |
    ...    | namespace | define vdu namespace |
    ...    | pod_list | define pod list which will be check |
    ...    | port | define port id |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    |  Stop To Get Resources Usage |
    ...
    ${end_vdu_resources_usage_list}=  create list
    FOR   ${pod}   IN   @{pod_list}
        ${end_resources_usage}    _Get Resources Usage    host=${host}    user=${user}    password=${password}
        ...                                                 namespace=${namespace}    pod=${pod}    port=${port}
        Append To List    ${end_vdu_resources_usage_list}    ${end_resources_usage}
    END
    Set Test Variable    ${end_vdu_resources_usage_list}
    [Return]    ${end_vdu_resources_usage_list}

Stop To Get Resources Usage For All vDU
    [Arguments]    ${gnb_index}=${0}
    [Documentation]   this kw is used to Start To Get Resources Usage For All vDU
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | define which gnb will is used |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    |  Start To Get Resources Usage For All vDU  |
    ...
    ${pod_list}    create list    po-cran1-cprt-0    po-cran1-up-0
    ${end_resources_usage_list}=  create list
    ${vdu_hostname_list}    ${vdu_username_list}    ${vdu_password_list}    ${vdu_ns_list}
    ...                               Get SSH Connection Infor For Multiple vDU K8s Master
    ${du_number}    Get vDU Number    gnb_index=${gnb_index}
    FOR    ${index}    IN RANGE    ${du_number}
        ${end_resources_usage}    Stop To Get Resources Usage    host=${vdu_hostname_list[${index}]}
        ...                                                         user=${vdu_username_list[${index}]}
        ...                                                         password=${vdu_password_list[${index}]}
        ...                                                         namespace=${vdu_ns_list[${index}]}
        ...                                                         pod_list=${pod_list}
    END
    Append To List    ${end_resources_usage_list}    ${end_resources_usage}
    Set Test Variable    ${END_RESOURCES_USAGE_LIST}    ${end_resources_usage_list}
    [Return]    ${END_RESOURCES_USAGE_LIST}

Stop And Compare Resources Usage
    [Arguments]    ${gnb_index}=${0}
    [Documentation]   this kw is used to Stop And Compare Resources Usage
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | define which gnb will is used |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Stop And Compare Resources Usage |
    ...
    ${END_RESOURCES_USAGE_LIST}    Stop To Get Resources Usage For All vDU
    ${du_number}    Get vDU Number    gnb_index=${gnb_index}
    FOR    ${index}    IN RANGE    ${du_number}
        Run Keyword And Ignore Error    Should Be Equal As Resources    ${BEGIN_RESOURCES_USAGE_LIST[${index}]}
        ...                                                             ${END_RESOURCES_USAGE_LIST[${index}]}
        ...                                                             exclude=//bufferPoolFreeCount
    END
    [Teardown]    aashell.teardown   aashell

Get Multi Gnb Id
    [Documentation]   this kw is used to get multi gnb id
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | None | NA |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Get Muti Gnb Id |
    ...
    ${gnb_list}    Set Variable    ${tl.gnbs}
    ${gnb_lenth}    get length  ${gnb_list}
    ${MRBTS_ID_list}=  create list
    ${NRBTS_ID_list}=  create list
    FOR    ${index}    IN RANGE    ${gnb_lenth}
        ${mrbts_id}    set variable    ${tl.gnbs[${index}].instance_id}
        ${nrbts_id}    set variable    ${tl.gnbs[${index}].global_bts_id}
        Append To List    ${mrbts_id_list}    ${mrbts_id}
        Append To List    ${nrbts_id_list}    ${nrbts_id}
    END
    [Return]    ${mrbts_id_list}    ${nrbts_id_list}

Get Multi vDU MRBTS Id
    [Arguments]    ${gnb_index}
    [Documentation]   this kw is used to get multi gnb id
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | which gnb should be selected |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Get Multi MRBTS Id From vDU | ${gnb_index} |
    ...
    ${MRBTS_ID_vDU_list}=  create list
    ${du_number}    Get vDU Number    gnb_index=${gnb_index}
    FOR    ${index}    IN RANGE    ${du_number}
        ${mrbts_id_vdu}    set variable    ${tl.gnbs[${gnb_index}].dus[${index}].instance_id}
        Append To List    ${MRBTS_ID_vDU_list}    ${mrbts_id_vdu}
    END
    [Return]    ${MRBTS_ID_vDU_list}


Compare Alarms And Generate Difference
    [Arguments]   ${NE_TYPE}
    [Documentation]    this kw is to Compare Alarm from Two Files
    ...    Author: Xiang Liang
    ...    Contact: Liang.xiang@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | NE_TYPE    | yes | vcu or vdu |
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Compare Alarms And Generate Difference |
    ...
    ${origin_alarm_file}    Set Variable    ${TEST_LOG_DIRECTORY}/${NE_TYPE}_alarm_setup/${NE_TYPE}_active_alarm.csv
    ${target_alarm_file}    Set Variable    ${TEST_LOG_DIRECTORY}/${NE_TYPE}_alarm_teardown/${NE_TYPE}_active_alarm.csv
    ${add_alarms}    ${clear_alarms}    aic_param.compare_alarms    ${origin_alarm_file}    ${target_alarm_file}
    ${file}    create_a_file    log_path=${TEST_LOG_DIRECTORY}/${NE_TYPE}_alarm_diff    file_name=${NE_TYPE}_active_alarm_diff.csv
    aic_param.store_alarms_to_csvfile    ${add_alarms}    ${file}
    aic_param.store_alarms_to_csvfile    ${clear_alarms}    ${file}


Prepare Netrc On VM
    ${exist_netrc}    Run Keyword And Return Status     OperatingSystem.File Should Exist
    ...    ${Artifactory_INFO.local_path}
    Return From Keyword If    ${exist_netrc}
    csn.connect_to    hostname=${Artifactory_INFO.Host}
    ...    username=${Artifactory_INFO.USERNAME}
    ...    password=${Artifactory_INFO.PASSWORD}
    ...    alias=netrc_server
    csn.download_file    remote_path=${Artifactory_INFO.path}
    ...    local_path=${Artifactory_INFO.local_path}
    ...    connection=netrc_server
    ${ret}    OperatingSystem.File Should Exist    ${Artifactory_INFO.local_path}
    OperatingSystem.Run    chmod u+r ${Artifactory_INFO.local_path}
    [Teardown]    Run Keyword And Ignore Error    csn.disconnect    connection=netrc_server

Remove Netrc On VM
    OperatingSystem.Run    rm ${Artifactory_INFO.local_path}
    OperatingSystem.File Should Not Exist
    ...    ${Artifactory_INFO.local_path}

Move All Test Result To Log Server
    [Arguments]    ${testline}=${TESTLINE_NAME}
    ...    ${get_team_kw}=Get Team Name By suite path
    ...    ${local_test_result}=/home/ute/test_results/
    Log    ${testline} is not used
    ${is_singlerun}    Run Keyword And Return Status    OperatingSystem.File Should Exist    ${UTE_EXECUTION_JSON}
    Return From Keyword If    ${is_singlerun}==${False}
    ${timestamp}    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    ${team_name}    Run Keyword    ${get_team_kw}
    csn.connect_to    hostname=${Logserver_INFO.Host}
    ...    username=${Logserver_INFO.USERNAME}
    ...    password=${Logserver_INFO.PASSWORD}
    ...    alias=log_server
    ${remote_log_path}    catenate    /data/logs/${team_name}/${TESTLINE_NAME}_${timestamp}
    csn.execute    command=cd /data/logs/${team_name};mkdir ${TESTLINE_NAME}_${timestamp}
    ...    connection=log_server
    ${cmd}    catenate    sshpass -p ${Logserver_INFO.PASSWORD}
    ...    scp -r ${local_test_result}
    ...    ${Logserver_INFO.USERNAME}@${Logserver_INFO.Host}:${remote_log_path}
    OperatingSystem.Run    command=${cmd}
    ${files}    get_all_files_in_dictionary    ${local_test_result}
    FOR    ${file}    IN    @{files}
        ${new_file_path}    Replace String    ${file}    /home/ute/    ${remote_log_path}${/}
        ${file_exist}    tafssh.File Exists    ${new_file_path}
        ...    connection=log_server
        Should Be True    ${file_exist}
    END
    Log    message=The new log link: http://10.69.69.233${remote_log_path}   level=WARN    	console=yes
    Log    message=The test_results will be removed    level=WARN    	console=yes
    ${all_dir_in_testresult}    OperatingSystem.List Directories In Directory    ${local_test_result}
    FOR    ${d}    IN    @{all_dir_in_testresult}
        Log To Console    ${d}
        ${clear_path}    Join Path    ${local_test_result}    ${d}
        Remove Directory    ${clear_path}    recursive=${True}
    END

Get Team Name By suite path
    [Documentation]    This kw is used to get teamname from scout by testline id
    ...    Author: Winnie
    ...    Contact: winnie.he@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | testline_name | yes | use the scout testline id ,usually is bts id |
    ...    | internal | yes | if you use CM single run or auto trigger, please set False |
    ...
    ...    | Return Value | Description |
    ...    | scf_id | the internal id from scout |
    ...
    ...    Example
    ...    | Get SCF Internal Id By Scout | testline_name=6141 |
    ...
    ${matches}    Get Regexp Matches    ${SUITE SOURCE}    RAN_PZ_HAZ_1${/}HAZ\\d+
    Should Not Be Empty    ${matches}
    ${match}    Split String    ${matches}[0]    ${/}
    [Return]    ${match}[-1]

Get vDU Http Connection Info
    [Arguments]    ${gnb_index}=${0}
    ...            ${du_index}=${0}
    [Documentation]
    ...    This kw is used to fetch vDU's http connection info.
    ...
    ...    Author: Liu Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | gnb_index | yes |  |
    ...    | du_index | yes |  |
    ...
    ...    | Return Value | Description |
    ...    | vdu_info | a dict |
    ...
    ...    Example
    ...   | Get vDU Http Connection Info |
    ...
    [Return]    ${tl.gnbs[${gnb_index}].dus[${du_index}].oam_http_connection_details}

Get vCU Http Connection Info
    [Arguments]    ${gnb_index}=${0}
    [Documentation]
    ...    This kw is used to fetch vCU's http connection info.
    ...
    ...    Author: Liu Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | gnb_index | yes |  |
    ...
    ...    | Return Value | Description |
    ...    | vcu_info | a dict |
    ...
    ...    Example
    ...   | Prepare vCU Http Connection Info |
    ...
    [Return]    ${tl.gnbs[${gnb_index}].cu.oam_http_connection_details}

Get BTS Http Connection Info
    [Arguments]    ${product_type}=vdu
    ...            ${gnb_index}=${0}
    ...            ${cudu_index}=${0}
    ...            ${port}=443
    [Documentation]
    ...    Supported BTS products: vdu, vcu, classical. (classcial BTS is not ready now)
    ...
    ...    Author: Liu Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | product_type | yes | classical/vcu/vdu |
    ...    | gnb_index | yes | BTS index |
    ...    | cudu_index | yes | the index of cu or du |
    ...    | port | yes | https port |
    ...
    ...    | Return Value | Description |
    ...    | bts_http_connection_info | a dict |
    ...
    ...    Example
    ...   | Get BTS Http Connection Info |
    ...
    ${http_connection_info}=    Run Keyword If    '${product_type}' == 'vdu'
    ...    Get vDU Http Connection Info    gnb_index=${gnb_index}    du_index=${cudu_index}
    ...    ELSE IF  '${product_type}' == 'vcu'
    ...    Get vCU Http Connection Info    gnb_index=${gnb_index}

    ${http_addr}    set variable    ${http_connection_info.addr}
    ${web_ip}    set variable if    ':' in '''${http_addr}'''
    ...    [${http_addr}]    ${http_addr}
    ${username}    set variable    ${http_connection_info.username}
    # ${password}    set variable    ${http_connection_details.password}
    ${password}    set variable    Nokia@123
    &{bts_http_connection_info}    create dictionary    host=${web_ip}
    ...    username=${username}    password=${password}    port=${port}
    [Return]    ${bts_http_connection_info}

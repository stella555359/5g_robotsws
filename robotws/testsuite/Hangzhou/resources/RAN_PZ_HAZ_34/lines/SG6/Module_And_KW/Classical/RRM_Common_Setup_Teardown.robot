*** Settings ***
Documentation
...    Author: Yang Mengli
...    Contact: mengli.yang@nokia-sbell.com
...    Common KWs related to Common Suite Setup For RRM/Common Suite Teardown For RRM/Common Test Setup For RRM/Common Test Teardown For RRM.

Resource    RRM_Common_Resource.robot



*** Keywords ***
Common Suite Setup For RRM
    [Documentation]    Author: He Winnie
    ...                Contact: winnie.he@nokia-sbell.com
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
    _Create Suite Directory
    Connect To FCT
    ${active_sw_version}    Get Active Bts Sw Version
    Set Suite Variable    ${ACTIVE_SW_VERSION}    ${active_sw_version}
    Run Keyword And Ignore Error    Get Testline Type
    Run Keyword And Ignore Error    Get TestLine Topology Name
    Run Keyword And Ignore Error    Get Expect Sw Version
    Run Keyword And Ignore Error    Get Release By Sw Version    sw=${ACTIVE_SW_VERSION}
    Run Keyword And Ignore Error    Prepare Netrc On VM

Common Test Setup For RRM
    [Arguments]    ${swconfig_file_path}=none    ${scf_file_path}=none    ${json_file_path}=none
    ...            ${ALLOWED_FAULT}=@{ALLOWED_FAULT}
    ...            ${tl_allowed_faults_file_path}=${testline_configuration_path}${/}${TestLine_Name}${/}${tl_allow_faults_file_name}
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This keyword is used to create log directory for case level, and Prepare ENV until on-air.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${swconfig_file_path} | No | swconfig file absolute path, if not provided, then no update for it |
    ...    | ${scf_file_path} | No | scf full commission xml file absolute path, if not provided, then no update for it |
    ...    | ${json_file_path} | No | scf delta commission json file absolute path, if not provided, then no update for it |
    ...    | ${ALLOWED_FAULT} | No | Alarms you allow tp appear on gNB, if not provided, then use default definition in RRM_Common_Resource |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    |  Example of arguments not provided:  |    |
    ...    |  Common Test Setup For RRM  |    |
    ...    |  Example of all arguments provided:  |    |
    ...    |  Common Test Setup For RRM  |  swconfig_file_path=${CURDIR}/../HAZ3/{SUITE_NAME}/swconfig.txt  |
    ...    |  ...                        |  scf_file_path=${CURDIR}/../HAZ3/{SUITE_NAME}/scf.xml  |
    ...    |  ...                        |  json_file_path=${CURDIR}/../HAZ3/{SUITE_NAME}/delta_scf.json   |
    ...    |  ...                        |  ALLOWED_FAULT=@{ALLOWED_FAULT} |
    ...
    Run Keyword And Ignore Error    Get SCF Internal Id By Scout    no_ute=${False}
    ${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    ${tc_name}=    Replace String    ${TEST_NAME}    ${SPACE}    _
    ${case_log_path}    Join path    ${SUITE_LOG_DIRECTORY}    ${tc_name}_${timestamp}
    Set Suite Variable    ${TEST_LOG_DIRECTORY}    ${case_log_path}
    Create directory    ${TEST_LOG_DIRECTORY}
    Run Keyword And Ignore Error    Start To Get Resources Usage
    Clear Legacy Logs On Sbts
    Run Keyword If    '${swconfig_file_path}' != 'none'    Update Swconfig
    ...                                                    swconfig_file_path=${swconfig_file_path}
    Run Keyword If    '${scf_file_path}' != 'none'    Commissioning Full SCF
    ...                                                    scf_file=${scf_file_path}
    Run Keyword If    '${json_file_path}' != 'none'    Commissioning Delta SCF
    ...                                                    delta_file=${json_file_path}
    Run Keyword If    '${swconfig_file_path}' != 'none' and '${scf_file_path}' == 'none'    COAM_Admin.ResetSite
    ...                                                                                     timeout=${600}
    # Wait until keyword succeeds    15m    1m    Verify bts and all cell status should be onair
    Wait Until Keyword Succeeds    3m    1m    COAM_Admin.Login
    ${combined_allow_fault_alarms}    Get All Allow Faults    tl_allowed_faults_file_path=${tl_allowed_faults_file_path}
    Set Test Variable    ${ALLOWED_FAULT}    ${combined_allow_fault_alarms}
    Run Keyword And Return Status    Check Unexpect Alarm Should Not Exist    allowed_faults=${combined_allow_fault_alarms}
    ...                                                                       file_path=${TEST_LOG_DIRECTORY}
    Run Keyword And Ignore Error    Start Alarm Watch Dog

Common Suite Teardown For RRM
    [Documentation]    Author: Liu Renhui
    ...                Contact: renhui-david.liu@nokia-sbell.com
    ...                Main functions:
    ...                1.Clear temporary logs in ASIX boards
    ...                2.Teardown the COAM connection(s)
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
    Clear Legacy Logs On Sbts
    # Run Keyword And Ignore Error    Remove Netrc On VM
    Run Keyword And Ignore Error    COAM_Admin.Logout
    Run Keyword And Ignore Error    Disconnect FCT
    ${MoveLog_to_Logserver}    Run Keyword And Ignore Error    Run Keyword If    "_AP_" in '${TESTLINE_TYPE}'
    ...    Set Variable    ${False}
    ...    ELSE    Set Variable    ${True}
    # Run Keyword And Ignore Error    Run keyword If    ${MoveLog_to_Logserver}
    # ...    Move All Test Result To Log Server

Common Test Teardown For RRM
    [Documentation]    Author: Xiang Liangliang
    ...                Contact: liang.xiang@nokia-sbell.com
    ...                This keyword is used to collect snapshot if test case failed, save SCF and swconfig,
    ...                teardown the COAM connections.
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
    # [Timeout]    15 min
    Run Keyword And Ignore Error    Get SCF Internal Id By Scout    no_ute=${False}
    Run Keyword If Test Failed    Run Keyword And Ignore Error    Collect Coam Snapshot
    ${DATE}=    Get Current Date    result_format=%Y%m%d_%H%M
    Wait Until Keyword Succeeds    3x    1min    COAM_Admin.Login    alias=SCF_backup
    Run Keyword And Ignore Error    COAM_Admin.BackupSCF    local_dir=${TEST_LOG_DIRECTORY}    file_name=SCF_${DATE}.xml
    ...    connection=SCF_backup
    Run Keyword And Ignore Error    COAM_Admin.Logout    connection=SCF_backup
    Run Keyword And Ignore Error    Stop And Analysis Alarm Watch Dog
    Wait Until Keyword Succeeds    15 min    3 sec    Connect to First_ASIB    alias=First_ASIB
    Run Keyword And Ignore Error    swconf.download_swConfig_file_from_asib_to_test_pc
    ...    localFilePath=${TEST_LOG_DIRECTORY}/swconfig.txt
    ...    remoteFilePath=/ffs/run/swconfig.txt    asib_alias=First_ASIB
    Run Keyword And Ignore Error    interface.Common step trigger
    Run Keyword And Ignore Error    COAM_Admin.Logout
    Run Keyword And Ignore Error    End Get Resources Usage And Compare
    # Run Keyword And Ignore Error    gnb_tool.stop_and_fix

Clear Legacy Logs On Sbts
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
    Connect to First_ASIB    alias=First_ASIB
    Run Keyword And Ignore Error    ssh.execute    command=rm -rf /tmp/AAsyslog.txt    connection=First_ASIB
    Run Keyword And Ignore Error    ssh.execute    command=rm -rf /tmp/*.pcap    connection=First_ASIB
    [Teardown]    csn.disconnect    connection=First_ASIB

_Create Suite Directory
    [Documentation]    Author: He Winnie
    ...                Contact: winnie.he@nokia-sbell.com
    ...                This keyword is to create suite directory
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | None | NA | NA |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    |  _Create Suite Directory  |
    ...
    ${suite_name}=    Replace String    ${SUITE NAME}    ${SPACE}    _
    ${timestamp}    Get TimeStamp With Date
    ${suite_log_path}    Join path    ${RESULT_DIR}    ${suite_name}_${timestamp}
    Set Suite Variable    ${SUITE_LOG_DIRECTORY}    ${suite_log_path}
    Create directory    ${SUITE_LOG_DIRECTORY}
    Log to Console    \n***Suite Log Directory ${SUITE_LOG_DIRECTORY}***

Get TimeStamp With Date
    [Arguments]    ${format}=%Y%m%d%H%M%S
    [Documentation]    Author: He Winnie
    ...                Contact: winnie.he@nokia-sbell.com
    ...                This keyword is to get the timestamp with required format
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${format} | NA | Give the format you want for the time stamp. Default is: %Y%m%d%H%M%S |
    ...
    ...    | Return Value | Description |
    ...    | ${timestamp} | The time stamp with required format |
    ...
    ...    Example
    ...    |  Get TimeStamp With Date  |  |
    ...    |  Get TimeStamp With Date  | format=%Y%m%d%H%M%S |
    ...
    ${timestamp}    DateTime.Get Current Date    result_format=${format}
    [Return]    ${timestamp}

Create BTS INFO Global Dictionary
    [Arguments]    ${gnb_index}=${0}    ${du_index}=${0}    ${common_units_index}=${0}
    &{bts_info}    Create Dictionary    IP=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[${common_units_index}].lmp_connection.addr}
    ...    USERNAME=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[${common_units_index}].lmp_connection.username}
    ...    PASSWORD=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[${common_units_index}].lmp_connection.password}
    ...    http_USERNAME=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...    http_PASSWORD=${tl.gnbs[0].cu.oam_http_connection_details.password}
    ...    MRBTSID=${tl.gnbs[${gnb_index}].instance_id}
    ...    NRBTSID=${tl.gnbs[${gnb_index}].global_bts_id}
    ...    PORT=443
    ...    RRUS=${tl.gnbs[${gnb_index}].dus[${du_index}].rus}
    Set Suite Variable    ${BTS${gnb_index}_INFO}    ${bts_info}
    [Return]    ${bts_info}

_Get All Gnb Active Sw Version
    [Documentation]    Author: winnie.he@nokia-sbell.com
    ...                this keyword use to get all gnb active sw version
    ${number}    Get Length    ${tl.gnbs}
    # Set Suite Variable    ${GNB_NUMBER}    ${GNB_NUMBER}
    ${exist}    Run Keyword And Return Status    Variable Should Exist    ${GNB_NUMBER}
    Run Keyword If    ${exist}
    ...    Set Suite Variable    ${GNB_NUMBER}
    ...    ELSE    Set Suite Variable    ${GNB_NUMBER}    ${number}
    FOR    ${i}    IN RANGE   ${GNB_NUMBER}
        _Get One Gnb Active Sw Version    bts_index=${i}
    END

_Get One Gnb Active Sw Version
    [Documentation]    Author: winnie.he@nokia-sbell.com
    ...                this keyword use to get all gnb active sw version
    [Arguments]    ${bts_index}=${0}
    Create BTS INFO Global Dictionary    gnb_index=${bts_index}
    Connect To One Site FCT    bts_index=${bts_index}
    ${active_sw_version}    Get Active Bts Sw Version    alias=BTS${bts_index}_LOCAL_Conn
    ${fixed_active_sw_version}    Fix SBTS Trunk Sw Version    sw=${active_sw_version}
    Set Suite Variable    ${BTS${bts_index}_ACTIVE_SW_VERSION}    ${fixed_active_sw_version}


Create BTS PC INFO Global Dictionary
    ${vm_count}    Get Length    ${tl.test_pcs}
    FOR    ${i}    IN RANGE    ${vm_count}
        &{bts_pc_info}    Create Dictionary    Host=${tl.test_pcs[${i}].default_ssh_connection_details.addr}
        ...    USERNAME=${tl.test_pcs[${i}].default_ssh_connection_details.username}
        ...    PASSWORD=${tl.test_pcs[${i}].default_ssh_connection_details.password}
        Set Suite Variable    ${BTS${i}_PC_INFO}    ${bts_pc_info}
    END

_Get Resources Usage
    ccs_aashell.Create AaShell CLI    name=aashell
    ccs_aashell.Setup    aashell
    ${resources_usage}    ccs_aashell.Get Resources Usage    aashell
    [Return]    ${resources_usage}
    [Teardown]    ccs_aashell.Teardown    aashell

Start To Get Resources Usage
    [Documentation]    Author: He Winnie
    ...                Contact: winnie.he@nokia-sbell.com
    ...                This keyword is to get the Resources usage at the test begin
    ...
    ...    | Input Parameters | Man. | Description |
    ...
    ...    | Return Value | Description |
    ...
    ...    Example
    ...    |  Start To Get Resources Usage  |  |
    ...
    ${resources_usage1}    _Get Resources Usage
    Set Test Variable    ${BEGIN_RESOURCES_USAGE}    ${resources_usage1}


End Get Resources Usage And Compare
    [Documentation]    Author: He Winnie
    ...                Contact: winnie.he@nokia-sbell.com
    ...                This keyword is to get the Resources usage after test finish
    ...
    ...    | Input Parameters | Man. | Description |
    ...
    ...    | Return Value | Description |
    ...
    ...    Example
    ...    |  End Get Resources Usage And Compare   |  |
    ...
    ${resources_usage2}=    _Get Resources Usage
    Run Keyword And Ignore Error    Should Be Equal As Resources
    ...    ${BEGIN_RESOURCES_USAGE}
    ...    ${resources_usage2}
    ...    exclude=//bufferPoolFreeCount

Prepare Netrc On VM
    # Run Keyword And Return Status     OperatingSystem.Remove File    ${Artifactory_INFO.local_path}
    # ${exist_netrc}    Run Keyword And Return Status     OperatingSystem.File Should Exist
    # ...    ${Artifactory_INFO.local_path}
    # Return From Keyword If    ${exist_netrc}
    ${ret}    Run Keyword And Return Status    csn.connect_to    hostname=${Artifactory_INFO.Host}
    ...    username=${Artifactory_INFO.USERNAME}
    ...    password=${Artifactory_INFO.PASSWORD}
    ...    alias=netrc_server
    Run Keyword If    ${ret}==${False}
    ...    Run Keywords
    ...    OperatingSystem.Run    wget -P --tries=3 --wait=10 --timeout=30 ~/ http://sw1.tc.china.nsn-net.net/build/tools/TA/.netrc
    ...    AND
    ...    OperatingSystem.Run    chmod u+r ~/\.netrc
    ...    ELSE
    ...    csn.download_file    remote_path=${Artifactory_INFO.path}
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
    Log To Console    ${testline}
    ${is_singlerun}    Run Keyword And Return Status    File Should Exist    ${UTE_EXECUTION_JSON}
    Return From Keyword If    ${is_singlerun}==${False}
    ${files}    get_all_files_in_dictionary    ${local_test_result}
    Should Not Be Empty    ${files}
    ${timestamp}    Get TimeStamp With Date
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
    FOR    ${file}    IN    @{files}
        ${new_file_path}    Replace String    ${file}    /home/ute/    ${remote_log_path}${/}
        ${file_exist}    csn.File Exists    ${new_file_path}
        ...    connection=log_server
        Should Be True    ${file_exist}
    END
    Log    message=The new log link: http://10.69.69.233${remote_log_path}   level=WARN    	console=yes
    Log    message=The test_results will be removed    level=WARN    	console=yes
    ${all_dir_in_testresult}    List Directories In Directory    ${local_test_result}
    FOR    ${d}    IN    @{all_dir_in_testresult}
        Log To Console    ${d}
        ${clear_path}    Join Path    ${local_test_result}    ${d}
        Remove Directory    ${clear_path}    recursive=${True}
    END



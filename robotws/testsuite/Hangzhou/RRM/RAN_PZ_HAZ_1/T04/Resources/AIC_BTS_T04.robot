*** Settings ***
Documentation
...    KWs copy from AIC_BTS.robot

*** Keywords ***
Get vDU Version
    [Documentation]    Get vDU Version by rest api and return the vDU version
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    |  None  |  NO  |  NA  |
    ...
    ...    | Return Value | Description |
    ...    | ${vdu_version} | return vdu version |
    ...
    ...    Example
    ...    |  Get VDU version |
    vDU Login By Rest
    ${vdu_data}=    vdu.get_vdu_state_data
    ${vdu_version}    set variable    ${vdu_data['software_version']}
    [Return]    ${vdu_version}
    [Teardown]    vDU Logout By Rest

Get vDU K8s Master SSH Connection Info
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0
    [Documentation]    this kw is used to Get vDU K8s Master SSH Connection Info
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    | Return Value | Description |
    ...    | ${du_info} | return addr/usename/password/port |
    ...
    ...    Example
    ...    | ${du_info} | Get vDU K8s Master SSH Connection Info |
    ...
    ${result}    ${addr}        Run Keyword And Ignore Error
    ...   set variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
    Should Be True    "${result}"=="PASS"    Please give K8s Master SSH ip in __init__.py for vdu_index=${vdu_index}

    ${result}    ${username}    Run Keyword And Ignore Error
    ...   set variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
    Should Be True  "${result}"=="PASS"    Please give K8s Master SSH username in __init__.py for vdu_index=${vdu_index}

    ${result}    ${password}    Run Keyword And Ignore Error
    ...   set variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}
    Should Be True  "${result}"=="PASS"    Please give K8s Master SSH password in __init__.py for vdu_index=${vdu_index}

    ${result}    ${port}        Run Keyword And Ignore Error
    ...   set variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.port}
    Should Be True    "${result}"=="PASS"    Please give K8s Master SSH port in __init__.py for vdu_index=${vdu_index}

    ${du_info}    create dictionary    addr=${addr}    username=${username}    password=${password}    port=${port}
    [Return]  ${du_info}

Get vCU Namespace From Config File
    [Arguments]    ${gnb_index}=0
    [Documentation]    this kw is used to Get vCU Namespace From Config File
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...
    ...    | Return Value | Description |
    ...    | ${vcu_namespace} | return vcu namespace|
    ...
    ...    Example
    ...    | ${vcu_namespace} | Get vCU Namespace From Config File |
    ...
    ${vcu_namespace}=    set variable    ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.namespace}
    [Return]    ${vcu_namespace}

Get vDU Namespace From Config File
    [Arguments]    ${vdu_index}=${0}    ${gnb_index}=${0}
    [Documentation]    this kw is used to Get vDU Namespace From Config File
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...
    ...    | Return Value | Description |
    ...    | ${vdu_namespace} | return vdu namespace|
    ...
    ...    Example
    ...    | ${vdu_namespace} | Get vDU Namespace From Config File |
    ...
    ${vdu_namespace}=    set variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.namespace}
    [Return]    ${vdu_namespace}

Get TestLine Name From UTE Cloud
    [Documentation]    This kw is used to get tl name
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
     ...    | Input Parameters | Man. | Description |
    ...    | NA | no | None|
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Get TestLine Name |
    ...
    ${status}    ${TestLine_Name}    Run Keyword And Ignore Error    get variable value    ${CONFIGURATION}
    ...    ${variablefile}
    ${key_list}    Create List    CM_RESOURCES    0    properties    name
    ${TestLine_Name}    Run Keyword If    '${status}'=='FAIL'
    ...    Get Info From UTE Reservation File    key_list=${key_list}
    ...    ELSE    Set Variable    ${TestLine_Name}
    Log to Console    \n***TestLine Name ${testline_name}***
    ${TestLine_Name_List}    Split String    ${TestLine_Name}    .
    Set Suite Variable    ${TESTLINE_NAME}    ${TestLine_Name_List[-1]}
    [Return]    ${TestLine_Name}

Get Testline Type
    [Documentation]    Author: He Winnie
    ...                Contact: winnie.he@nokia-sbell.com
    ...                Get the UTE testline type
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | No | NA | NA |
    ...
    ...    | Return Value | Description |
    ...    | ${Testline_type} | UTE test line type |
    ...
    ...    Example
    ...    | ${testline_type}= | Get Testline Type |
    ...
    ${key_list}    Create List    CM_TOPOLOGY    name
    ${Testline_type}    Get Info From UTE Reservation File    key_list=${key_list}
    Set Suite Variable    ${TESTLINE_TYPE}    ${testline_type}
    Log to Console    \n***Testline Type ${Testline_type}***
    [Return]    ${Testline_type}

vDU Backup SCF From Test Line
    [Arguments]    ${scf_file_name}=scf_backup.xml    ${vdu_index}=0
    [Documentation]  this kw is used to vDU Backup SCF From Test Line
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | scf_file_name | yes | define scf file name |
    ...    | vdu_index | yes | The list index from tl.dus[], it will use the index of VDU |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Backup SCF From Test Line | scf_file_name=scf_backup.xml | vdu_index=${0} |
    ...
    log to console  *** Backup SCF From Test Line Before Case Excution ***
    vDU Login By Rest    vdu_index=${vdu_index}
    ${backup_scf_path}    basic.create_a_directory    log_path=${TEST_LOG_DIRECTORY}    directory_name=backup_scf
    ${backup_scf_file}=    vdu.get_current_plan_file    local_dir_path=${backup_scf_path}    filename=${scf_file_name}
    ...                                                include_runtime_data=${False}
    [Return]    ${backup_scf_file}
    [Teardown]    vDU Logout By Rest

vCU Backup SCF From Test Line
    [Arguments]    ${gnb_index}=${0}
    [Documentation]   backup scf from vCU
     ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | yes | gnb index to indicate which gnb will be used |
    ...
    ...    | Return Value | Description |
    ...    | ${vCU_SCF_file} | return scf path |
    ...
    ...    Example
    ...    | vCU Backup SCF From Test Line | gnb_index=${0} |

    Login To vCU By Rest    gnb_index=${gnb_index}
    ${backup_vCU_scf_path}    basic.create_a_directory    log_path=${TEST_LOG_DIRECTORY}    directory_name=backup_scf_vcu
    ${vCU_SCF_file}=    Set Variable      ${backup_vCU_scf_path}/vCU_scf.xml
    ${backup_vCU_scf_file}=    cu.get_current_plan_file    path=${vCU_SCF_file}    include_runtime_data=${False}    timeout=120
    [Return]    ${vCU_SCF_file}
    [Teardown]   Logout To vCU By Rest

vDU Check All Cells Status Should Be Onair For All DUs
    [Arguments]    ${gnb_index}=${0}
    [Documentation]    vDU Check All Cells Status Should Be Onair For All DUs
    ...    Author: mengli yang
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | Yes. | gnb_index, default is 0 |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | vDU Check All Cells Status Should Be Onair For All DUs |
    ...
    ${du_number}    Get vDU Number    gnb_index=${gnb_index}
    FOR    ${i}    IN RANGE    ${du_number}
        vDU Check All Cells Status Should Be Onair    vdu_index=${i}    gnb_index=${gnb_index}
    END

Save vDU Active Alarm
    [Arguments]  ${file_name}=active_alarm  ${vdu_index}=0
    [Documentation]  VDU Save Historical Alarm To A File
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | file_name  | no | file_name, default is active_alarm|
    ...    | vdu_index  | no | vdu_index, default is 0 |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Save vDU Active Alarm |
    ...
    vDU Login By Rest    vdu_index=${vdu_index}
    ${out}    vdu.vdu_get_active_alarms
    aic_param.store_alarms_to_csvfile    alarm_data=${out}    file_name=${file_name}
    [Return]    ${file_name}
    [Teardown]    vDU Logout By Rest

Save vDU Historical Alarm
    [Arguments]    ${file_name}=Historical_Alarm    ${vdu_index}=0
    [Documentation]    VDU Save Historical Alarm To A File
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | file_name  | no | file_name, default is 0 |
    ...    | vdu_index  | no | vdu_index, default is 0 |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Save vDU Historical Alarm |
    ...
    vDU Login By Rest    vdu_index=${vdu_index}
    ${out}    vdu.vdu_get_historical_alarms
    aic_param.store_alarms_to_csvfile    alarm_data=${out}    file_name=${file_name}
    [Return]    ${file_name}
    [Teardown]    vDU Logout By Rest

Get Active Alarm In vCU
    [Arguments]    ${file_name}=vcu_active_Alarm   ${gnb_index}=0
    [Documentation]   Get Active Alarm In CU
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | yes | The list index from tl.cu[], it will use the index of gnb |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Get Active Alarm In CU | gnb_index=0 |
    ...
    Login To vCU By Rest    gnb_index=${gnb_index}
    ${active_alarm}=    cu.get_active_alarms    page_number=${1}    items_per_page=${1000}
    aic_param.store_alarms_to_csvfile    alarm_data=${active_alarm}    file_name=${file_name}
    [Return]    ${file_name}
    [Teardown]    Run keyword and ignore error    Logout To vCU By Rest

Get Historical Alarm In vCU
    [Arguments]    ${file_name}=vcu_historical_Alarm   ${gnb_index}=0
    [Documentation]   Get Active Alarm In CU
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | yes | The list index from tl.cu[], it will use the index of gnb |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Get Active Alarm In CU | gnb_index=0 |
    ...
    Login To vCU By Rest    gnb_index=${gnb_index}
    ${historical_alarm}=    cu.get_historical_alarms    page_number=${1}    items_per_page=${1000}
    aic_param.store_alarms_to_csvfile    alarm_data=${historical_alarm}    file_name=${file_name}
    [Return]    ${file_name}
    [Teardown]    Run keyword and ignore error    Logout To vCU By Rest

Download Log Files to Log Server
    [Documentation]    This keyword will download Log files to log server
    ...    Author: Cao Ge
    ...    Contact: ge.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | None | NA | NA |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ${case_name}  Get Test Case Name
    ${re_compile}   Get Regexp Matches   ${case_name}   \\[\\d*\\]
    ${value_length}    get length   ${re_compile}
    ${result}   set variable
    ${result}   run keyword if   ${value_length}>=${1}   Remove String   ${case_name}   ${re_compile}[${0}]
    run keyword if   ${value_length}>=${1}   Set Test Variable   ${case_name}    ${result}
    ${file_name}   get regexp matches  ${TEST_LOG_DIRECTORY}.tar   ${case_name}.*?tar
    OperatingSystem.Run   command=cd ${TEST_LOG_DIRECTORY} && tar cvf ${TEST_LOG_DIRECTORY}/${file_name}[0] ${TEST_LOG_DIRECTORY}
    sleep  5s
    OperatingSystem.Run   command=chmod 777 ${TEST_LOG_DIRECTORY}/${file_name}[0]
    ${hostname}   OperatingSystem.Run   command=hostname
    ${result_length}  Set Variable   3
    FOR   ${index}   IN RANGE   ${result_length}
        basic.download_file_to_server   remote_path=/logs/${hostname}_${file_name}[0]   local_path=${TEST_LOG_DIRECTORY}/${file_name}[0]
        sleep   20s
        ${remote_file_size}   basic.verify_remote_file_size   remote_path=/logs/${hostname}_${file_name}[0]
        sleep   5s
        ${local_file_size}   basic.verify_local_file_size    local_path=${TEST_LOG_DIRECTORY}/${file_name}[0]
        ${ratio}   evaluate   ${remote_file_size}/${local_file_size}
        exit for loop if    ${ratio}>0.9
        Run Keyword If    ${index}==${result_length}    fail    download file to server failed
    END
    sleep   10s
    OperatingSystem.Run   command=cd ${TEST_LOG_DIRECTORY} && rm -rf *


vDU Login By Rest
    [Arguments]    ${vdu_index}=0    ${gnb_index}=0    ${alias}=default
    [Documentation]    this kw is used to Login vDU By Rest
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_index | yes | The list index from tl.dus[], it will use the index of VDU |
    ...    | gnb_index | yes | The list index from tl.cu[], it will use the index of gnb |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | vDU Login By Rest |
    ...
    ${oam_httpaddr}    set variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.addr}
    ${oam_web_ip}    set variable if    ':' in '''${oam_httpaddr}'''   [${oam_httpaddr}]    ${oam_httpaddr}
    Run keyword and ignore error    vDU Logout By Rest    vdu_index=${vdu_index}
    vdu.connect to
    ...  host=${oam_web_ip}
    ...  port=${EMPTY}
    ...  username=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.username}
    ...  password=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.password}
    ...  secure=True
    ...  connection_name=${alias}

vDU Logout By Rest
    [Arguments]    ${vdu_index}=0    ${alias}=default
    [Documentation]  this kw is used to Logout vDU By Rest
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_index | yes | The list index from tl.dus[], it will use the index of VDU |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | vDU Logout By Rest  |
    ...
    Log    ${vdu_index} is not used
    vdu.disconnect    ${alias}

vDU Check All Cells Status Should Be Onair
    [Arguments]    ${vdu_index}=0    ${gnb_index}=0
    [Documentation]    vDU Verify Cells Status Should Be Onair With Expected Cell Number
    ...    Author: mengli yang
    ...    Contact: mengli.yang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_index | No. | specify which vdu needs to be check if the testline configed multi vdus |
    ...    | gnb_index | No. | specify which vdu needs to be check if the testline configed multi vdus |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | vDU Verify Cells Status Should Be Onair With Expected Cell Number |
    ...
    ${cell_number}    Get VDU Cell Number From SCF    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${alias}=    get unique id
    vDU Login By Rest    vdu_index=${vdu_index}    gnb_index=${gnb_index}    alias=${alias}
    ${vdu_cells_summary}=    vdu.get_vdu_cells_summary    vdu_connection=${alias}    raw=True
    Should Be Equal As Numbers    ${vdu_cells_summary['basicCellsSummary']['operationalState']['disabled']}    0
    Should Be Equal As Numbers    ${vdu_cells_summary['basicCellsSummary']['administrativeState']['locked']}    0
    # Should Be Equal As Numbers    ${vdu_cells_summary['basicCellsSummary']['administrativeState']['shutting down']}    0
    #${on_line}    set variable    ${vdu_cells_summary['availabilityStatus']['on line']}
    #should be true    ${on_line}==${cell_number}
    [Teardown]  vdu.disconnect    ${alias}

Get Info From UTE Reservation File
    [Arguments]    ${key_list}    ${file_path}=${UTE_RESERVATION_CONTEXT_JSON}
    [Documentation]    This kw is used to get Info From UTE Reservation File
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ${key_list} | Yes | The keys list need to get from ute reservation file |
    ...    | ${file_path} | No | The UTE reservation file. Default is ${UTE_RESERVATION_CONTEXT_JSON} |
    ...
    ...    | Return Value | Description |
    ...    | ${dict} | The needed info for the keys in key list |
    ...
    ...    Example
    ...    |  ${key_list}            |  Create List                         |  CM_ARTIFACTS          |  0  |  name  |
    ...    |  ${Expect_Sw_Version}=  |  Get Info From UTE Reservation File  |  key_list=${key_list}  |     |        |
    ...
    ${context}    OperatingSystem.Get File    ${file_path}
    &{context_dict}    json.Loads    ${context}
    ${dict}    Set Variable    ${context_dict}
    FOR    ${k}    IN    @{key_list}
        ${k_convert}    Run Keyword If    ${k.isdigit()}
        ...    Convert To Integer    ${k}
        ...    ELSE    Set Variable    ${k}
        ${dict}    Run Keyword If    ${k.isdigit()}
        ...    Set Variable    ${dict}[${k_convert}]
        ...    ELSE    Collections.Get From Dictionary    ${dict}    ${k_convert}
    END
    [Return]    ${dict}

Get VDU Cell Number From SCF
    [Arguments]  ${vdu_index}=0   ${gnb_index}=0
    [Documentation]   Get VCU Cell Number From SCF
    ...    Author: mengli yang
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index | no | gnb index to indicate which gnb will be used, default is 0  |
    ...
    ...    | Return Value | Description |
    ...    | ${cell_number} | return cell number |
    ...
    ...    Example
    ...    | ${cell_number} | Get VCU Cell Number From TestLine |
    ...
    vDU Login By Rest    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${tmpid1}    get unique id    precise=LOW    prefix=Get_VDU_Cell_Number_From_SCF
    ${tmp_scf_path}    basic.create_a_directory    log_path=${TEST_LOG_DIRECTORY}    directory_name=${tmpid1}
    ${tmp_scf_file}    vdu.get_current_plan_file    local_dir_path=${tmp_scf_path}   filename=scf.xml  include_runtime_data=${False}
    ${scf_content}    OperatingSystem.Get File    ${tmp_scf_file}
    ${result}    Get Regexp Matches    ${scf_content}    .*NRCELL"\\s+distName="MRBTS-(\\d+)/NRBTS-(\\d+)/NRCELL-(\\d+)"\\s+.*   3
    ${cell_number}    Set Variable    ${result.__len__()}
    [Return]   ${cell_number}
    [Teardown]   run keyword and ignore error  vDU Logout By Rest   vdu_index=${vdu_index}

#---------------------vCU--------------------------------------------------------------------------
Login To vCU By Rest
   [Arguments]   ${gnb_index}=0   ${alias}=${None}   ${restapi_version}=cuoam_24r2
   [Documentation]  Create rest session to vCU.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index  | No |  gnb index to indicate which gnb will be used  |
    ...    | restapi_version | No | if you use 'get_counter' keyword in CU trunk build, the parameter should be given |
    ...    | ...             |     'cuoam_21b' other senarios should be use default value - cuoam_21b |
    ...    | alias | No. | alias that identifies this connection, if the argument is given, |
    ...    | ...   |      the alias must be given to the Logout To vCU By Rest keyword as connection argumument. |
	...
    ...    | Return Value | Description |
    ...    | ${alias} | return the connection alias |
    ...
    ...    the connection alias
    ...    Example
    ...    | Login To vCU By Rest | gnb_index=0 |
    ...
    ${host}    set variable  ${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    run keyword and ignore error    Logout To vCU By Rest
    cu.connect to    host=${host}
    ...    port=${EMPTY}
    ...    username=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ...    cu_version=${restapi_version}
    ...    secure=${True}
    ...    alias=${alias}
    [Return]  ${alias}

Logout To vCU By Rest
    [Arguments]    ${connection}=${None}
    [Documentation]  Teardown rest session to CU.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | connection | No. | the connection alias that used in CU login |
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    |  Logout To vCU By Rest | connection=${None} |
    ...
    cu.disconnect    connection=${connection}

Block Cell In vDU
    [Arguments]    ${cell_id}=1    ${timeout}=${60}    ${alias}=default
    [Documentation]    this kw is used to Block Cell In vDU
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    |  cell_id  | No | define which cell id is blocked |
    ...    |  timeout  | No | define time of timeout |
    ...    |  alias  | No | define alias of connect to vDU |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Block Cell In vDU | cell_id=1 | timeout=${60} |
    ...
    vDU Login By Rest
    ${out}    vdu.block_cell    cell_id=${cell_id}
    ...                                                 timeout=${timeout}    vdu_connection=${alias}
    Wait Until Keyword Succeeds  60   3   _Check Block Cell Should Be Expected   operation_id=${out["id"]}
    ...                                                                          expected_status=success
    [Teardown]    vDU Logout By Rest

_Check Block Cell Should Be Expected
    [Arguments]    ${operation_id}    ${expected_status}    ${timeout}=${60}
    ${out}    vdu.get_block_cell_operation_status    operation_id=${operation_id}    timeout=${timeout}
    ...                                          vdu_connection=default
    Should Be True    "${out["status"]}"=="${expected_status}"

_Check Unblock Cell Should Be Expected
    [Arguments]    ${operation_id}    ${expected_status}    ${timeout}=${60}
    ${out}    vdu.get_unblock_cell_operation_status    operation_id=${operation_id}    timeout=${timeout}
    ...                                          vdu_connection=default
    Should Be True    "${out["status"]}"=="${expected_status}"

Unblock Cell In vDU
    [Arguments]    ${cell_id}=1    ${timeout}=${60}    ${alias}=default
    [Documentation]    this kw is used to Unblock Cell In vDU
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    |  cell_id  | No | define which cell id is unblocked |
    ...    |  timeout  | No | define time of timeout |
    ...    |  alias  | No | define alias of connect to vDU |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Unblock Cell In vDU | cell_id=1 | timeout=${60} |
    ...
    vDU Login By Rest
    ${out}    vdu.unblock_cell    cell_id=${cell_id}
    ...                                                     timeout=${timeout}    vdu_connection=${alias}
    Wait Until Keyword Succeeds  60   3   _Check Unblock Cell Should Be Expected   operation_id=${out["id"]}
    ...                                                                          expected_status=success
    [Teardown]    vDU Logout By Rest

Connect To K8s Master In vDU
    [Arguments]   ${gnb_index}=0  ${vdu_index}=0  ${alias}=default
    [Documentation]   Connect To K8s Master In vDU
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index  |  no  | gnb index, default is 0 |
    ...    | vdu_index  |  no  | VDU index, default is 0 |
    ...    | alias      | no   | alias, default value is default |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Connect To K8s Master In vDU  | alias=${alias} |
    ...
    ${vdu_k8s_master_ssh_connection_info}    Get vDU K8s Master SSH Connection Info    gnb_index=${gnb_index}
    ...                                                                             vdu_index=${vdu_index}
    ${ip}    set variable    ${vdu_k8s_master_ssh_connection_info["addr"]}
    ${username}    set variable    ${vdu_k8s_master_ssh_connection_info["username"]}
    ${password}    set variable    ${vdu_k8s_master_ssh_connection_info["password"]}

    ${prompt}    set variable    \\[cloudadmin@\\S+\\s\\S+\\]\\$|\\[root@\\S+\\s\\S+\\s+\\S+\\]\\#|\\[root@\\S+\\s\\S+\\]\\#
    ${prompt}    set variable    ${prompt}|\\[cbis-admin@\\S+\\s\\S+\\s+\\S+\\]\\$|\\[cbis-admin@\\S+\\s\\S+\\]\\$
    ${prompt}    set variable    ${prompt}|\\[core@\\S+\\s\\S+\\]\\$
    ${prompt}  set variable   ${prompt}|\\[cranuser\\d+@\\S+\\s+\\S+\\]\\$|\\[cranuser\\d+@\\S+\\s+\\S+\\s+\\S+\\]\\$
    issh.Connect_To    ip=${ip}    username=${username}    password=${password}
       ...   prompt=${prompt}
       ...   alias=${alias}
       ...   width=200
       ...   timeout=150

Reset vDU With Check Cell On Air
    [Arguments]    ${need_check_on_air}=${False}    ${vdu_index}=${0}    ${gnb_index}=${0}
    [Documentation]   Reset VDU By REST
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...
    ...   | Input Parameters | Man. | Description |
    ...   | need_check_on_air | no | if need to check cell on air |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...   Example
    ...  | Reset vDU With Check Cell On Air | need_check_on_air=${False} |
    ...
    log to console  Reset VDU By REST...
    vDU Login By Rest  vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${out}    vdu.reset_vdu
    ${error_msg}    set variable  ${out["error_message"]}
    should contain    ${error_msg}    No error
    ${out}    Wait Until Keyword Succeeds  60   10   _Check Reset VDU Status Should Be Expected    operation_id=${out["id"]}
    ...                                                                                expected_status=ongoing
    Sleep    100s
    Run Keyword If    ${need_check_on_air}   Wait Until Keyword Succeeds  800s   30s
    ...                            vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
    [Teardown]    Run Keyword And Ignore Error    vDU Logout By Rest

_Check Reset VDU Status Should Be Expected
    [Arguments]    ${operation_id}    ${expected_status}
    ${out}    vdu.get_reset_vdu_operation_status    operation_id=${operation_id}
    Should Be True    "${out["status"]}"=="${expected_status}"
    [Return]    ${out}

Start Alarm Watch Dog
    [Documentation]    Start alarm watch dog for AIC product
    Alarm Operation    operation=start_watch_alarms
    ...                product_type=vcu
    ...                bts_index=${0}
    ...                cudu_index=${0}


Stop Alarm Watch Dog For VCU
    Alarm Operation    operation=stop_watch_alarms
    ...                product_type=vcu
    ...                bts_index=${0}
    ...                cudu_index=${0}


Stop And Analysis Alarm Watch Dog
    [Documentation]    Stop alarm watch dog for AIC product and analysis the alarms
    ${res}    Alarm Operation    operation=get_detected_alarms
    ...                          product_type=vcu
    ...                          bts_index=${0}
    ...                          cudu_index=${0}
    Run Keyword And Ignore Error    Stop Alarm Watch Dog For VCU

#--------hyh----------
#7188_02
Get Cell ID List
    [Arguments]    ${vdu_index}=0    ${gnb_index}=0
    [Documentation]  this kw is used to get Cell ID List
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | yes | The list index from tl.cu[], it will use the index of gnb |
    ...    | vdu_index | yes | The list index from tl.dus[], it will use the index of VDU |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Get Cell ID List | gnb_index=${0} | vdu_index=${0} |
    ...
    vDU Login By Rest    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${cell_id_list}=    create list
    ${cell_info}=    vdu.get_vdu_cells_status
    FOR    ${cell}    IN    @{cell_info}
        append to list    ${cell_id_list}    ${cell["id"]}
    END
    log to console    ${cell_id_list}
    [Return]    ${cell_id_list}
    [Teardown]    vDU Logout By Rest

#7168_01
Delete All Certificates In vCU
    [Documentation]    Certificate Management -> Operator Certificates: Delete Certificates function In vCU
    ...   Author: yuyan xu
    ...   Contact: yuyan.xu@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | NA                 | no | NA |
    ...
    ...   | Return Value | Description |
    ...   | operation_id | operation id |
    ...
    ...   Example
    ...   | operation_status | Delete All Certificates In vCU |
    ...
    Log To Console    Delete All Certificates In vCU
    Login To vCU By Rest
    ${operation_status}    cu.delete_all_operator_certificates
    Should Be Equal As Strings    ${operation_status["status"]}    Successful
    [Return]    ${operation_status}
    [Teardown]    Run Keyword And Ignore Error    Logout To vCU By Rest

Get vCU Certificates
    [Documentation]    Get vCU Certificates
    ...   Author: yuyan xu
    ...   Contact: yuyan.xu@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | NA           | no | NA |
    ...
    ...   | Return Value | Description |
    ...   | certs_list | list of certificates |
    ...
    ...   Example
    ...   | Get vCU Certificates |
    ...
    Login To vCU By Rest
    ${certs_list}    cu.get_operator_certificate_list
    [Return]    ${certs_list}
    [Teardown]    Run Keyword And Ignore Error    Logout To vCU By Rest

Check IP Connectivity In vCU
    [Arguments]    ${operation_id}    ${expected_status}=Successful
    [Documentation]    Check IP Connectivity In vCU
    ...   Author: yuyan xu
    ...   Contact: yuyan.xu@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | operation_id      | yes | operation id get from kw:start_ip_connectivity_test |
    ...   | expected_status   | no | values: Successful(default), Ongoing |
    ...
    ...   | Return Value | Description |
    ...   | NA | NA |
    ...
    ...   Example
    ...   | Check Ip Connectivity By Rest Api In vCU | ${operation_id} |
    ...
    ${conn_result}    cu.get_ip_connectivity_test_result    ${operation_id}
    Should Be True    "${conn_result["status"]}"=="${expected_status}"

Check Ip Connectivity By Rest Api In vCU
    [Arguments]    ${destination_ip}    ${payload_size}=16    ${dscp}=10    ${source_interface_name}=default    ${source_ip}=None
    [Documentation]    Check Ip Connectivity By Rest Api In vCU
    ...   Author: yuyan xu
    ...   Contact: yuyan.xu@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | destination_ip      | yes | destination ip(it's called scope on the web) |
    ...   | payload_size        | no | int.payload size,value out of range [16...65507] |
    ...   | dscp                | no | Port of the U-Plane destination server |
    ...   | source_interface_name | no | source interface name |
    ...   | source_ip           | no | source ip |
    ...
    ...   | Return Value | Description |
    ...   | NA | NA |
    ...
    ...   Example
    ...   | Check Ip Connectivity By Rest Api In vCU | 10.108.194.162 |
    ...
    Log To Console    Check Ip Connectivity By Rest Api In vCU
    Login To vCU By Rest
    ${operation_id}    cu.start_ip_connectivity_test    destination_ip=${destination_ip}    payload_size=${payload_size}    dscp=${dscp}
    ...    source_interface_name=${source_interface_name}    source_ip=${source_ip}
    Wait Until Keyword Succeeds    10x    15s    Check IP Connectivity In vCU    ${operation_id}
    [Teardown]    Run Keyword And Ignore Error    Logout To vCU By Rest

#7186_02
Restore Default Certificates In vDU
    [Arguments]    ${vdu_index}=0    ${gnb_index}=0
    [Documentation]    Certificate Management -> Operator Certificates: Restore Default Certificates function In vDU
    ...   Author: yuyan xu
    ...   Contact: yuyan.xu@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | vdu_index           | no | vdu index |
    ...   | gnb_index           | no | gnb index |
    ...
    ...   | Return Value | Description |
    ...   | operation_id | operation id |
    ...
    ...   Example
    ...   | operation_id | Restore Default Certificates In vDU |
    ...
    vDU Login By Rest    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${operation_id}    vdu.restore_default_certificates
    [Return]    ${operation_id}
    [Teardown]    Run Keyword And Ignore Error    vDU Logout By Rest

Get vDU Certificates
    [Arguments]    ${vdu_index}=0    ${gnb_index}=0
    [Documentation]    Get vDU Certificates
    ...   Author: yuyan xu
    ...   Contact: yuyan.xu@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | vdu_index           | no | vdu index |
    ...   | gnb_index           | no | gnb index |
    ...
    ...   | Return Value | Description |
    ...   | certs_list | list of certificates |
    ...
    ...   Example
    ...   | Get vDU Certificates |
    ...
    vDU Login By Rest    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${certs_list}    vdu.get_vdu_certificates
    [Return]    ${certs_list}
    [Teardown]    Run Keyword And Ignore Error    vDU Logout By Rest

Check Ip Connectivity By Rest Api In vDU
    [Arguments]    ${destination_ip}    ${payload_size}=16    ${dscp}=10    ${source_interface_name}=default
    ...    ${source_ip}=None    ${timeout}=30    ${gnb_index}=${0}    ${vdu_index}=${0}
    [Documentation]    Check Ip Connectivity By Rest Api In vDU
    ...   Author: yuyan xu
    ...   Contact: yuyan.xu@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | destination_ip      | yes | destination ip(it's called scope on the web) |
    ...   | payload_size        | no | int.payload size,value out of range [16...65507] |
    ...   | dscp                | no | Port of the U-Plane destination server |
    ...   | source_interface_name | no | source interface name |
    ...   | source_ip           | no | source ip |
    ...   | vdu_index           | no | vdu index |
    ...   | gnb_index           | no | gnb index |
    ...
    ...   | Return Value | Description |
    ...   | NA | NA |
    ...
    ...   Example
    ...   | Check Ip Connectivity By Rest Api In vDU | 10.108.194.162 |
    ...
    Log To Console    Check Ip Connectivity By Rest Api In vCU
    vDU Login By Rest    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    ${operation_id}    vdu.start_ip_connectivity_test    destination_ip=${destination_ip}    payload_size=${payload_size}    dscp=${dscp}
    ...    source_interface_name=${source_interface_name}    source_ip=${source_ip}    timeout=${timeout}
    Wait Until Keyword Succeeds    10x    15s    Check IP Connectivity In vDU    ${operation_id}
    [Teardown]    Run Keyword And Ignore Error    vDU Logout By Rest

Check IP Connectivity In vDU
    [Arguments]    ${operation_id}    ${expected_status}=Successful
    [Documentation]    Check IP Connectivity In vDU
    ...   Author: yuyan xu
    ...   Contact: yuyan.xu@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | operation_id      | yes | operation id get from kw:start_ip_connectivity_test |
    ...   | expected_status   | no | values: Successful(default), Ongoing |
    ...
    ...   | Return Value | Description |
    ...   | NA | NA |
    ...
    ...   Example
    ...   | Check Ip Connectivity By Rest Api In vDU | ${operation_id} |
    ...
    ${conn_result}    vdu.get_ip_connectivity_test_result    ${operation_id}
    Should Be True    "${conn_result["status"]}"=="${expected_status}"

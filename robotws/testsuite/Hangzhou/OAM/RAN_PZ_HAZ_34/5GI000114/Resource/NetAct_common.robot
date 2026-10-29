*** Settings ***
Documentation
    ...    Author: yin.4.chen@nokia-sbell.com

Resource   ./NetAct_Fast_Pass_common.robot

*** Variables ***
${WEB_DOWNLOAD_DIR}   ${OUTPUT_DIR}

${SETUP_PASS}     ${false}
&{NetAct_LOGS}    FM=@{FM_LOGS}    CM=@{CM_LOGS}    SWM=@{SWM_LOGS}   COMMON_MEDIATION=@{COMMON_MEDIATION}
@{FM_LOGS}   /var/log/cpf/was/clab737node14/logs/pmserver/SystemOut.log    /var/log/cpf/was/clab737node14/logs/pmserver/SystemErr.log
...   /var/log/cpf/was/clab013node18/logs/pmserver/SystemOut.log    /var/log/cpf/was/clab013node18/logs/pmserver/SystemErr.log
...   /var/opt/oss/log/fm/fmservices/oss_activity_FMCluster_*_*.log    /var/opt/oss/log/fm/fmservices/oss_error_FMCluster_*_*.log
...   /var/opt/oss/log/fm/fmservices/oss_trace_FMCluster_*_*.log    /var/opt/oss/log/audit/oss_security_FMCluster_*_*.log
...   /var/opt/oss/log/audit/oss_change_FMCluster_*_*.log
@{CM_LOGS}   /var/opt/oss/log/audit/oss_change_CMCluster_*_*.log    /var/opt/oss/log/rac/oss_trace_CMCluster_*_*.log
...   /var/opt/oss/log/rac/oss_error_CMCluster_*_*.log
@{SWM_LOGS}   /var/opt/oss/log/swm/oss_activity_ITSMCluster_*_*.log    /var/opt/oss/log/swm/oss_error_ITSMCluster_*_*.log
...   /var/opt/oss/log/swm/oss_trace_ITSMCluster_*_*.log
@{COMMON_MEDIATION}   /var/opt/oss/log/common_mediations/oss_activity*_*.log
...   /var/opt/oss/log/common_mediations/oss_error*_*.log
...   /var/opt/oss/log/common_mediations/oss_trace*_*.log

*** Keyword ***
Login NetAct Start Page and Remove File
    Open Netact Start Page   ${START_PAGE}    ${START_PAGE_USER}    ${START_PAGE_PASSWORD}    ${true}
    Remove File    ${WEB_DOWNLOAD_DIR}/*.jnlp

Get Terminal Text
    [Arguments]    ${locator}
    ${rows}=    Call Component Method    ${locator}    getRows
    ${rows2}=   Call Component Method    ${locator}    getHistoryBuffSize
    ${rows}    evaluate    ${rows}+${rows2}
    ${text}=    Set Variable
    FOR    ${i}    IN RANGE    ${rows}
        ${i}=    Convert To String  ${i}
        ${line}=    Call Component Method     ${locator}    getRowText    ${i}
        ${len}    Get Length    ${line}
        ${text}=    Run Keyword If    ${len}>0    Catenate    SEPARATOR=\n    ${text}
        ...    ${line}
        ...    ELSE    Set Variable    ${text}
    END
    ${text}    Set Variable    ${text[1:]}
    Log To Console    ${text}
    [Return]    ${text}

Set Global Lab Information
    [Arguments]  ${lab_name}=CLAB737
    Set Suite Variable    ${LAB_INFO}    ${LAB_INFO['${lab_name}']}
    ${lab_info_keys} =    Get Dictionary Keys    ${LAB_INFO}
    FOR    ${key_name}   IN    @{lab_info_keys}
       Set Suite Variable   ${${key_name}}   ${LAB_INFO['${key_name}']}
    END

    LogIn NetAct VM And Get Config File FP
    ${Cluster_XML} =   Parse XML    ${OUTPUT_DIR}/ClusterConfig.xml
    ${START_PAGE}   ${HOST_IP}   Get Start Page And HOST From ClusterConfig FP   ${Cluster_XML}
    Set Suite Variable    ${HOST_IP}
    Set Suite Variable    ${START_PAGE}

    ${smanager_XML} =   Parse XML    ${OUTPUT_DIR}/smanagerConf.xml
    Get Node Service From smanagerConf And Set As Global Vars    ${smanager_XML}

LogIn NetAct VM And Get Config File FP
    csn.Connect To   hostname=${VM_IP}   username=${SERVICE_USER}   password=${SERVICE_PASSWORD}   alias=NETACT_VM   timeout=10
    csn.Download File   remote_path=/etc/ClusterConfig.xml   local_path=${OUTPUT_DIR}/ClusterConfig.xml   connection=NETACT_VM
    csn.Download File   remote_path=/var/opt/cpf/ha/smanagerConf.xml   local_path=${OUTPUT_DIR}/smanagerConf.xml   connection=NETACT_VM   timeout=120
    [Teardown]   csn.Disconnect   connection=NETACT_VM

Get Start Page And HOST From ClusterConfig FP
    [Arguments]    ${XML}
    ${START_PAGE} =   XML.Get Element Attribute   ${XML}   name=URL   xpath=Services/Provider/Service[@Name='HTTPS']
    &{HOST_IP}   Create Dictionary
    ${hosts_eles} =   XML.Get Elements   ${XML}   xpath=Hosts/Host
    FOR   ${host_ele}   IN   @{hosts_eles}
        Log    ${host_ele}
       ${host_name_text} =   XML.Get Element Attribute   ${host_ele}   name=Hostname   xpath=.
       ${host_ip_text} =   XML.Get Element Attribute   ${host_ele}   name=IP   xpath=.
       Set To Dictionary   ${HOST_IP}   ${host_name_text}=${host_ip_text}
    END
    [Return]   ${START_PAGE}   ${HOST_IP}

Get Node Service From smanagerConf And Set As Global Vars
    [Arguments]    ${XML}
    ${list_param_keys} =    Get Dictionary Keys    ${NODE_SERVICE_LIST}
    FOR    ${item}   IN    @{list_param_keys}
       ${item_eles} =   XML.Get Elements   ${XML}   xpath=Site/Cluster/SubCluster/NativeService[@Name="${NODE_SERVICE_LIST['${item}']}"]
       _Get_Node_Service_From_Elements   ${item}   ${item_eles}
    END

    ${list_param_rep_keys} =    Get Dictionary Keys    ${NODE_SERVICE_LIST_REP}
    FOR    ${item_rep}   IN    @{list_param_rep_keys}
       ${item_rep_eles} =   XML.Get Elements   ${XML}
       ...   xpath=Site/Cluster/SubCluster/NativeService[contains(@Name, "${NODE_SERVICE_LIST_REP['${item_rep}']}")]
       _Get_Node_Service_From_Elements   ${item_rep}   ${item_rep_eles}
    END

_Get_Node_Service_From_Elements
    [Arguments]   ${item}   ${elements}
    @{item_node_list}    Create List
    FOR   ${element}   IN   @{elements}
       ${item_node} =   XML.Get Element Attribute   ${element}   name=Node   xpath=.
       Append To List   ${item_node_list}   ${item_node}
       ${item_node_list}=   Remove Duplicates   ${item_node_list}
    END
    Set Suite Variable   ${${item}}   ${item_node_list}
    [Return]   ${${item}}

# Get Table Value By Condition
#     [Arguments]   ${table_name}   ${condition}   ${column}
#     @{table_headers}   Get Table Headers   ${table_name}
#     @{table_values}   Get Table Values   ${table_name}
#     @{new_table_values}   Create List
#     :FOR   ${index}    IN RANGE    len(${table_values})
#     \   &{table_values_dic}   Create Dictionary   row=${index}   value=${table_values[${index}]}
#     \   Append To List   ${new_table_values}   ${table_values_dic}

#     ${items}   Set Variable   ${condition.items()}
#     :FOR   ${item}   IN   @{items}
#     \   ${index}   Get Index From List   ${table_headers}   ${item[0]}
#     \   ${value}   Set Variable   ${item[1]}
#     \   ${new_table_values}   _Match_Table_Rows   ${new_table_values}   ${index}   ${value}

#     ${column_index}   Get Index From List   ${table_headers}   ${column}
#     ${value_list}   Run Keyword If   ${new_table_values}   _Match_Table_Column   ${new_table_values}   ${column_index}
#     [Return]   ${value_list}

Get Table Value By Condition
    [Arguments]   ${table_name}   ${condition}   ${column}
    ${table_rows}   ${table_headers}   ${status}   Find Items In Table Content   ${table_name}   ${condition}
    ${column_index}   Get Index From List   ${table_headers}   ${column}
    ${value_list}   Run Keyword If   ${status}   _Match_Table_Column   ${table_rows}   ${column_index}
    ...   ELSE   Create List
    ${status}   Set Variable If   not ${status} or len(${value_list})==0   ${false}
    ...   ${status} and len(${value_list})!=0   ${true}
    [Return]   ${value_list}

Find Items In Table Content
    [Arguments]   ${table_name}   ${search_key_dict}
    @{table_headers}   Get Table Headers   ${table_name}
    @{table_values}   Get Table Values   ${table_name}
    ${new_table_values}   _Construct_New_Table_Value   ${table_values}
    ${table_rows}   _Construct_New_Table_Rows   ${table_headers}   ${new_table_values}   ${search_key_dict}
    ${status}   Set Variable If   len(${table_rows})==0   ${false}
    ...   len(${table_rows})!=0   ${true}
    [Return]   ${table_rows}   ${table_headers}   ${status}

_Construct_New_Table_Value
    [Arguments]   ${table_values}
    @{table_rows}   Create List
    FOR   ${index}    IN RANGE    len(${table_values})
       &{table_values_dic}   Create Dictionary   row=${index}   value=${table_values[${index}]}
       Append To List   ${table_rows}   ${table_values_dic}
    END
    [Return]   ${table_rows}

_Construct_New_Table_Rows
    [Arguments]   ${table_headers}   ${table_values}   ${condition}
    ${items}   Set Variable   ${condition.items()}
    FOR   ${item}   IN   @{items}
       ${index}   Get Index From List   ${table_headers}   ${item[0]}
       ${value}   Set Variable   ${item[1]}
       ${table_values}   _Match_Table_Rows   ${table_values}   ${index}   ${value}
    END
    [Return]   ${table_values}

_Match_Table_Rows
    [Arguments]   ${table_values}   ${index}   ${value}
    ${matched_values}   Create List
    FOR   ${table_value}   IN   @{table_values}
       Run Keyword If   '${table_value['value'][${index}]}'=='${value}'   Append To List   ${matched_values}   ${table_value}
    END
    [Return]   ${matched_values}

_Match_Table_Column
    [Arguments]   ${table_values}   ${index}
    @{value_list}   Create List
    FOR   ${table_value}   IN   @{table_values}
       &{value_dic}   Create Dictionary   row=${table_value['row']}   column=${index}   value=${table_value['value'][${index}]}
       Append To List   ${value_list}   ${value_dic}
    END
    [Return]   ${value_list}


Click NetAct Web and Switch to App
    [Documentation]   Switch to NetAct web and click on it and then Switch to App
    ...    Author: shengyuan.jiang@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   | alias | yes | app name |
    ...    *RETURN VALUE*
    ...    no
    ...    Example
    ...    |  Click NetAct Web and Switch to App | Monitor |
    [Arguments]    ${alias}
    wait until keyword succeeds    5 times    5s
    ...    selenium_netact.switch_to_page    page_name=Start Page
    wait until keyword succeeds    5 times    1s
    ...    selenium_netact.click_button    button_xpath=//*[@id="calypso-container"]/div[1]/div/div[1]/div[3]/div[1]
    wait until keyword succeeds    20s    5s    swing.Switch to Application    alias=${alias}
    wait until keyword succeeds    10s    2s    swing.Select Main Window

Catch Logs from NetAct
    [Documentation]   Catch Logs from NetAct
    ...    Author: shengyuan.jiang@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   | Log_Area | yes | Area of log |
    ...   | download_path | no | path to save log |
    ...    *RETURN VALUE*
    ...    no
    ...    Example
    ...    |  Catch Logs from NetAct | FM |
    [Arguments]    ${node_ip}   ${username}   ${password}   ${Log_Area}    ${download_path}=${OUTPUTDIR}/
    ${connection_NetAct}    csn.connect_to   hostname=${node_ip}   username=${username}   password=${password}   alias=NetAct_WASnode
    ${NetAct_logs}    set variable    ${NetAct_LOGS['${Log_Area}']}
    FOR    ${item}    IN    @{NetAct_logs}
        Download Log from NetAct    log=${item}    alias=${connection_NetAct}
    END
    [Teardown]    csn.disconnect    connection=${connection_NetAct}

Download Log from NetAct
    [Documentation]   Download Log from NetAct
    ...    Author: shengyuan.jiang@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   | log | yes | log name which contain log path |
    ...   | alias | yes | connetion between taf and NetAct |
    ...   | download_path | no | path to save log |
    ...    *RETURN VALUE*
    ...    no
    ...    Example
    ...    |  Catch Logs from NetAct | /var/opt/oss/log/audit/oss_change_FMCluster_*_*.log | ${connection_NetAct} |
    [Arguments]    ${log}    ${alias}    ${download_path}=${OUTPUTDIR}/
    ${all_log}    csn.Execute    command=ls -lt ${log}    connection=${alias}
    ${status}    run keyword and return status    should contain    ${log}    *
    ${log_reg}    run keyword if    ${status}    set variable    ${log.split('/')[-1].split('*')[0]}
    ...    ELSE    set variable    ${log.split('/')[-1].split('.')[0]}
    ${log_path}    Remove String Using Regexp    ${log}    ${log_reg}.*.log
    ${log_name}    should match regexp    ${all_log}    ${log_reg}.*.log
    ${current_date}    DateTime.Get Current Date
    ${DATE_STR}    DateTime.Convert Date    ${current_date}    %Y%m%d%H%M
    csn.download_file    remote_path=${log_path}${log_name}    local_path=${download_path}${DATE_STR}_${log_name}    connection=${alias}

Check Ajax Status
    ${style}   selenium_netact.get_element_attribute   elem_xpath=//*[@id='ajaxStatus']   attr_name=style
    Should Not Contain   ${style}   block
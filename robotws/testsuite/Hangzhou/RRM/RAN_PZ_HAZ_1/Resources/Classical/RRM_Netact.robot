*** Setting ***
Documentation
...    VRF HAZ 1 Common Resources.

Library           taf.nms.netact                        WITH NAME    netact




*** Keyword ***
Setup NetAct
    [Arguments]     ${NETACT}
    [Documentation]    Author: Yang Mengli
    ...                 Contact: mengli.yang@nokia-sbell.com
    ...                 This keyword is used to connect to netact
    netact.Add Node    cmwas    ${NETACT['was_host']}    ${NETACT['user']}    ${NETACT['password']}
    netact.Add Node    fmwas    ${NETACT['fm_host']}    ${NETACT['user']}    ${NETACT['password']}
    ${web_url}=    netact.Detect Web Url
    netact.Add Web Url    ${web_url}    ${NETACT['user']}    ${NETACT['password']}

Teardown NetAct
    [Documentation]   Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This keyword is used to tear down NetAct and its cwwas node
    netact.Delete Node    cmwas
    netact.Delete Node    fmwas
    netact.Clean All

NetAct Export Plan
    [Arguments]    ${local_dir}    ${file_name}    ${dist_names}    ${plan_name}    ${operation_type}=plan   ${ui_values}=None
    [Documentation]    Helper keyword used for export plan from NetAct to local_dir/file_name place
    ...    Author: yuyan xu
    ...    Contact: yuyan.xu@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...    | local_dir | Yes | Path to local directory where NetAct plan should be stored |
    ...    | file_name | Yes | File name for local stored plan |
    ...    | dist_names | Yes | MO distName |
    ...    | plan_name | Yes | Name of plan on NetAct |
    ...    | operation_type | No | Specifies the type of the export operation (plan/actual/reference/template/siteTemplate |
    ...    | ui_values | No | Specifies if the file should be exported with UI parameters' values. Default value is false. |
    ...
    ...   Example
    ...  | NetAct Export Plan | local_dir=${TEST_LOG_DIRECTORY} | file_name=actual_${export_timestamp}.xml
    ...  | dist_names=${distName} | plan_name=${plan_name} | operation_type=actual |
    ${status}=    Run Keyword And Return Status    OperatingSystem.Directory Should Exist    ${local_dir}
    Run Keyword If    not ${status}    Create Directory    ${local_dir}
    ${status}=    Run Keyword And Return Status    netact.Export Configuration    local_dir=${local_dir}    file_name=${file_name}
    ...    operation_type=${operation_type}    dist_names=${dist_names}    plan_name=${plan_name}    ui_values=${ui_values}
    ${status}=    Run Keyword And Return Status    OperatingSystem.File Should Exist    ${local_dir}/${file_name}
    Run Keyword If    ${status}    Log    Plan ${plan_name} available at ${local_dir}/${file_name}    level=INFO    console=True
    ...    ELSE    Run Keywords    Log    Plan ${plan_name} not available at ${local_dir}/${file_name}    level=ERROR
    ...    AND    Fail    Plan ${plan_name} not available at ${local_dir}/${file_name}

Get Actual Parameter Value From NetAct
    [Arguments]    ${dist_name}    ${param}    ${ui_values}=false
    [Documentation]    Get and return the actual value of the given parameter
    ...                Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...    **Input Parameters:**
    ...    +-------------------+------+--------------------------------------------------------------------------+-----+
    ...    | Parameter name | Man. | Description | Default |
    ...    +===================+======+==========================================================================+=====+
    ...    | dist_name| distName of element
    ...    | param| Specifical parameter to check
    ...    | ui_values| default is false
    ...
    ...    **Return Parameters:**
    ...    +----------------+------------------------------------------------------------------------------------------+
    ...    | Parameter name | Description |
    ...    +================+==========================================================================================+
    ...    | actual_value | actual parameter value from NetAct |
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${status}    Run Keyword And Return Status    netact.Export Configuration    local_dir=${Test Results Dir}/NetActLogs
    ...    file_name=get_param_value_from_netact_plan.xml    dist_names=${MRBTS_DN}    ui_values=${ui_values}
    ${scf_xml}=    L_XML.Parse Xml    ${Test Results Dir}/NetActLogs/get_param_value_from_netact_plan.xml
    ${actual_value}   L_XML.Get Element Text   ${scf_xml}   .//managedObject[@distName="${dist_name}"]/p[@name="${param}"]
    [Return]      ${actual_value}

NetAct Create And Edit Plan
    [Arguments]    ${BTS_scf_initial}    ${name}    ${description}    ${mo_id}    ${scf_distName}    &{parameters_dict}
    [Documentation]    Helper keyword used for create new plan and parameter edit
    ...                Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...
    ...    *INPUT*
    ...    | Parameter | Mandatory | Description |
    ...    | name | Yes | Plan Name |
    ...    | description | Yes | Plan description |
    ...    | mo_id | Yes | MO distName |
    ...    | scf_distName | Yes | SCF distName of MO for given parameter |
    ...    | parameters_dict | Yes | parameters_dict (dictionary format - key:value) |
    ...
    ${status}    ${plan}=    Run Keyword And Ignore Error    netact.Get Plan Configuration    ${name}
    Run Keyword If    '${status}' == 'PASS'    NetAct Delete Plan    ${name}    ${plan}
    ${plan}=    NetAct Create Plan    ${name}    ${description}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}=    L_XML.Parse xml    ${BTS_scf_initial}
    ${MO_items}=    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="${scf_distName}"]
    NetAct Create Managed Object    plan=${plan}    meta_class=${MO_items['class']}
    ...    meta_version=${MO_items['version']}    mo_id=${mo_id}    &{parameters_dict}
    [Return]    ${plan}

NetAct Delete Plan
    [Arguments]    ${name}    ${plan}
    netact.Delete Plan    ${name}
    ${status}=    Run Keyword And Return Status    netact.Get Plan Configuration    ${name}
    Run Keyword If    ${status}    Run Keywords    Log    Plan deletion failed!    level=ERROR
    ...    AND    Fail    Plan deletion failed!
    ...    ELSE    Log    Plan successfully deleted: ${plan}    console=True

NetAct Create Plan
    [Arguments]    ${name}    ${description}
    [Documentation]    Helper keyword used for create new plan
    ...
    ...    Author: Xu Yuyan
    ...    Contact: yuyan.xu@nokia-sbell.com
    ...
    ...    *INPUT*
    ...    | Parameter | Mandatory | Description |
    ...    | name | Yes | Plan Name |
    ...    | description | Yes | Plan description |
    ${plan}=    netact.Create Plan Configuration    ${name}    ${description}
    ${status}=    Run Keyword And Return Status    netact.Get Plan Configuration    ${name}
    Run Keyword If    ${status}    Log    Plan successfully created: ${plan}    console=True
    ...    ELSE    Run Keywords    Log    Plan creation failed!    level=ERROR
    ...    AND    Fail    Plan creation failed!
    [Return]    ${plan}

NetAct Create Managed Object
    [Arguments]    ${plan}    ${meta_class}    ${meta_version}    ${mo_id}    ${operation}=UPDATE    &{parameters_dict}
    [Documentation]    Helper keyword used for create MO in existing plan
    ...
    ...    Author: Xu Yuyan
    ...    Contact: yuyan.xu@nokia-sbell.com
    ...
    ...    *INPUT*
    ...    | Parameter | Mandatory | Description |
    ...    | plan | Yes | Plan obj |
    ...    | meta_class | Yes | Meta class of mo |
    ...    | meta_version | Yes | nidd version of mo  |
    ...    | mo_id | Yes | MO distName |
    ...    | parameters_dict | Yes |  parameters_dict (dictionary format - key:value)  |
    ${managed_object}=    netact.Create Managed Object    plan=${plan}    meta_class=${meta_class}
    ...    meta_version=${meta_version}    mo_id=${mo_id}    operation=${operation}   &{parameters_dict}
    ${status}=    Run Keyword And Return Status    netact.Get Managed Object    configuration=${plan}    mo_id=${mo_id}
    Run Keyword If    ${status}    Run Keywords    Log    MO successfully created: ${managed_object}    console=True
    ...    AND    Log    Parameters were set with plan ${plan}    console=True
    ...    ELSE    Run Keywords    Log    MO creation failed!    level=ERROR
    ...    AND    Fail    MO creation failed!

NetAct Provision Plan
    [Arguments]    ${plan_name}    ${dist_names}    ${backup_plan_name}    ${create_backup_plan}
    ...    ${provisioning_operation}    ${ignore_errors}=True
    [Documentation]    Helper keyword used for provision plan
    ...                Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...
    ...    *INPUT*
    ...    | Parameter | Mandatory | Description |
    ...    | name | Yes | Plan Name |
    ...    | dist_names | Yes | MO distName |
    ...    | backup_plan_name | Yes | Backup plan name |
    ...    | create_backup_plan | Yes | Create backup plan; True or False |
    ...    | provisioning_operation| Yes | Specifies a provisioning operation (activate/preactivate) |

    ${status}=    Run Keyword And Return Status    netact.Provision Plan    plan_name=${plan_name}    dist_names=${dist_names}
    ...    backup_plan_name=${backup_plan_name}    create_backup_plan=${create_backup_plan}
    ...    provisioning_operation=${provisioning_operation}    ignore_errors=${ignore_errors}
    Should Be True    ${status}
    ${status}=    Run Keyword And Return Status    netact.Activate Preactivated Plan  plan_name=${plan_name}    dist_names=${dist_names}
    Should Be True    ${status}


Get_Counter_Value_On_NetAct
    [Arguments]     ${start_time}    ${end_time}    ${NA_name}
    [Documentation]    Author: Yang Mengli
    ...                 Contact: mengli.yang@nokia-sbell.com
    ...                 This keyword is used to get counter from netact
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${start_time} | yes  | log path to save pcdm log, if not provided, use ${TEST_LOG_DIRECTORY}  |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    |  Get_counter_value_on_NetAct  |
    Setup NetAct
    Set Shell Timeout    30
    set shell prompt    SQL>
    ta_ssh_telnet.Execute Shell Command    sqlplus omc/omc
    ta_ssh_telnet.Execute Shell Command    set heading off
    ${dn_list}    ta_ssh_telnet.Execute Shell Command
    ...                  select to_char(co_gid) from utp_common_objects where co_object_instance\=${BTS_INFO.ID} and co_oc_id\=3128;
    ${bts_dn1}    Split String    ${dn_list}
    ${bts_dn}    Get From List    ${bts_dn1}    -1
    ${cmd}    Catenate    select \ ${NA_name} , to_char(period_start_time,'YYYY-MM-DD HH24:MI:SS') from \ NOKMRN_PR_ENC_MRBTS_RAW \
    ...         where period_start_time >\= to_date('${start_time}', 'yyyy-mm-dd hh24:mi:ss') and period_start_time < to_date('${end_time}',
    ...         'yyyy-mm-dd hh24:mi:ss') \ and MRBTS_ID\= ${bts_dn};
    ${sql_output}    ta_ssh_telnet.Execute Shell Command    ${cmd}
    ${result}    Split String    ${sql_output}
    #${counter_value}    Get From List    ${result}    -6
    ${counter_value}   Convert to string     ${Counter_M40002C0}
    should contain    ${sql_output}  ${counter_value}
    [Return]    ${Counter_M40002C0}

Get_Counter_Value_From_NetAct
    [Arguments]     ${technology}    ${measurement}    ${counter}    ${filter_by}    ${mo_names}    ${object_aggregation}
    ...             ${time_aggregation}     ${start_time}    ${end_time}    ${time_filter}=absolute
    [Documentation]    Author: Yang Mengli
    ...                 Contact: mengli.yang@nokia-sbell.com
    ...                 This keyword is used to get counter from netact
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${technology} | yes  | Technology name, e.g., LNBTS-NSN LTE Base Transceiver Station |
    ...    | ${measurement} | yes  | Measurement name, e.g., LTE Cell Availability |
    ...    | ${counters} | yes  | Counter identifier(s), e.g., CHNG_TO_CELL_AVAIL or ['CHNG_TO_CELL_AVAIL', 'SAMPLES_CELL_AVAIL']. |
    ...    | ${filter_by} | yes  | Item from Filter by list at Object selection stage of Add To Ne Board wizard, e.g., MRBTS |
    ...    | ${mo_names} | yes  | Managed object name(s), e.g., PLMN-PLMN/MRBTS-12345 or ['PLMN-PLMN/MRBTS-12345', 'PLMN-PLMN/MRBTS-54321'] |
    ...    | ${time_aggregation} | yes  | Time aggregation name, e.g., RAW. Item from Time list at Aggregation stage of Add To New Board wizard |
    ...    | ${time_filter} | yes  | Corresponds to Time selection stage of Add To New Board wizard.
    ...                            | Allowed value: relative, absolute, realtime, today, currentMonth or previousMonth |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    |  Get_Counter_Value_From_NetAct  |
    ${counter_value}=    netact.get_pm_counters    technology=${technology}
    ...                                         measurement=${measurement}
    ...                                         counters=${counter}
    ...                                         filter_by=${filter_by}
    ...                                         mo_names=${mo_names}
    ...                                         object_aggregation=${object_aggregation}
    ...                                         time_aggregation=${time_aggregation}
    ...                                         start_time=${start_time}
    ...                                         end_time=${end_time}
    ...                                         time_filter=${time_filter}

    [Return]    ${counter_value}



*** Settings ***

Documentation
...   author: Rubina Nath
...   contact: rubina.nath@nokia.com
Library     taf.selenium.gnb.oam.coam.classical    WITH NAME    classical

*** Variables ***

${operation_value}=    update

*** Keywords ***

Collect Snapshot
	admin.collect_snapshot    target_file_name=${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Snapshotfile.zip

Check_BTS_State
    ${bts_state}=    admin.get_mrbts_state
    BuiltIn.Log                   [INFO] BTS STATE : ${bts_state}
    Should Contain Any            ${bts_state}    onAir    ignore_case=${TRUE}

ORU Upgrade Wo Reset
    update_software    sw_package=${sw2}
    ...                should_activate=True
    ...                timeout=1000
    ...                connection=default
    ...                should_reset_radios=False

ORU Upgrade Reset
    update_software    sw_package=${sw1}
    ...                should_activate=True
    ...                timeout=1000
    ...                connection=${connection}
    ...                should_reset_radios=True

Login To Admin
    admin.setup_admin    bts_host=${BTS_ADDRESS}

Reset Site
    admin.reset_site
    ...    wait_for_reconnection=${value_true}
    ...    connection=${connection}
    ...    timeout=600

Print Radio Version
    ${SWparameters}=    get_parameters_for_all    class_name=RMOD
    ...                                           timeout=10
    ...                                           connection=${connection}
    log    ${SWparameters}

Reset Radio
    [Arguments]    ${distname_radio}
    radio_reset_at_layer_1    dist_name=${distname_radio}
    ...                       reset_type=Soft
    ...                       timeout=300
    ...                       connection=${connection}
    ...                       detailed_output=False

Perform Parameter Recommissioning
    [Arguments]    ${parameter_dist_name}    ${parameter_name}     ${value}
    admin.perform_parameter_recommissioning
    ...    dist_name=${parameter_dist_name}
    ...    parameter=${parameter_name}
    ...    operation=${operation_value}
    ...    value=${value}
    ...    skip_parameter_relation_errors=${value_true}
    ...    should_activate=${value_true}
    ...    timeout=300
    Sleep    60s

Check ActiveFaultandAlarmID
    [Arguments]    @{fault_list}
    ${alr}=     admin.get_active_alarms
    log     ${alr}
    ${alr_num}=     admin.get_active_alarms_number
    Log    ${alr_num}
    FOR    ${i}    IN RANGE   ${alr_num}
        Log    ${alr}[${i}][faultName]
        ${Alrstring}=    Convert To String    ${alr}[${i}][alarmId]
        ${fltstring}=    Convert To String    ${alr}[${i}][faultId]
        run keyword and continue on failure    should contain any    ${fltstring}    @{fault_list}
        run keyword and continue on failure    should contain any    ${Alrstring}    @{fault_list}
    END

Get ActiveAlarms
    ${alr}=     admin.get_active_alarms
    log     ${alr}
    ${alr_num}=     admin.get_active_alarms_number
    Log    ${alr_num}

Test Teardown
    Log to console  --End test--\n
    Collect Snapshot
    Get ActiveAlarms
    Stops Btslogs from Local machine
    admin.teardown_admin

Suite Setup
    log    "Test Started"
    ${CurrentDate}=    Get Current Date    result_format=%d_%m_%Y_%H%M
    ${CurrentDate}=    Convert to String     ${CurrentDate}
    os.Create Directory    ${BTS_path}/${SUITE NAME}/${CurrentDate}
    Set global variable    ${Date}    ${CurrentDate}

Stops Btslogs from Local machine
    [Documentation]    path from where to get btslog files default value: "/tmp/btslog2"
    #[Arguments]    ${log_alias}
    Run Keyword And Continue On Failure     core.stop_collectors      btslog
    Run Keyword And Continue On Failure     core.collect_collectors      btslog
    Run Keyword And Continue On Failure    core.teardown_collectors      btslog

Start Btslogs from Local machine
    [Documentation]    path from where to get btslog files default value: "/tmp/btslog2"
    ...
    #[Arguments]    ${log_alias}
    btslog.create_btslog_collector    btslog
    ...    log_dir=/tmp/btslog2
    core.setup_collectors     btslog
    core.start_collectors     btslog
    core.Set Suite Alias    btslog

Test Setup
    Run Keywords     Login To Admin
    os.run    chmod 777 ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}
    DeleteNetconfLogs
    Get ActiveAlarms
    Start Btslogs from Local machine

Suite Teardown
	log    "Test END"

NetconfMsgValidation_rpcError
    	[Arguments]    ${netconf_file}    ${messageSubType}
       	${pm2}=    netconf_get_value    ${netconf_file}    rpc-reply    rpc-error    error-tag
        ${a}=    validate_netconf_reply_message    ${netconf_file}    ${messageSubType}    rpc-error
        run keyword and continue on failure   Should not be empty    ${a}

MoveNetconfLogs
    [Documentation]   This Keywords is Used for to rename Netconf logs
    [Arguments]    ${path}    ${Dest_path}
    SSHLibrary.Open Connection    host=10.58.238.216
    SSHLibrary.Login    ute    password=${Docker_password}    delay=1
    SSHLibrary.Write    mv ${path}/${NetconfFileName} ${path}/RMOD_L-1_NetconfRpcMessageTrace_${Dest_path}.log
    SSHLibrary.read     delay=3s
    SSHLibrary.Close All Connections

Netconf_MessageVerification_9196related_messages
    [Arguments]    ${netconf_file}    @{message}
    ${pm}=    netconf_get_value     ${netconf_file}    rpc    edit-config    measurement-object
    FOR    ${i}    IN    @{message}
        ${Value to check}    Evaluate    '${i}' in [item[1] for item in ${pm}]
        run keyword and continue on failure   Should Be True    ${Value to check}
    END
    ${pm1}=    netconf_get_value    ${netconf_file}    rpc    edit-config    active
    ${len1}=    BuiltIn.Get Length    ${pm1}
    FOR    ${i}    IN    @{active}
        ${Value to check}    Evaluate    '${i}' in [item[1] for item in ${pm1}]
        run keyword and continue on failure   Should Be True    ${Value to check}
    END
    ${a}=    validate_netconf_reply_message    ${netconf_file}    edit-config    ok
    run keyword and continue on failure    Should not be empty    ${a}

Counter_Value_Check
    [Arguments]    ${path}    @{ListofCountervalues}
    ${counter_List}=    admin.get_pm_counters_by_dist_name    timeout=300
    log    ${counter_List}
    log    ${counter_List['${path}']}
    FOR   ${count1}	IN	@{ListofCountervalues}
    	Run Keyword and Continue On Failure    Should Not Be Empty    ${counter_List['${path}']}[${count1}]}    0
        log    ${counter_List['${path}']}[${count1}]}
    END
    Sleep   60

Add URL
    netact.add_web_url    web_url=${WEB_URL}
    ...                   username=${netactUSERNAME}
    ...                   password=${netactPASSWORD}
    ...                   alias=${NETACT_NAME}

Upload Alarms
    ${alarms}=    netact.upload_alarms    dist_name=${mo_name}
    ...                                   alias=${NETACT_NAME}
    Log    ${alarms}    console=${TRUE}
    ${alarms}=    netact.Get Alarms    ${mo_name}    alias=${NETACT_NAME}
    Log   ${alarms}    console=${TRUE}

Add_fmwas_node
    netact.Add Node    fmwas   ${fm_cm_itsmwas_hostIp}
    ...                         ${node_Username_fmwas}
    ...                         ${node_password_fmwas}
    ...                         alias=${NETACT_NAME}

Add_cmwas_node
    netact.Add Node    cmwas    ${fm_cm_itsmwas_hostIp}
    ...                         ${node_Username_fmwas}
    ...                         ${node_password_fmwas}
    ...                         alias=${NETACT_NAME}

Provision Plan
    [Arguments]    ${plan_name}
    netact.provision_plan    ${plan_name}    ${mo_name}    backup_plan_name=counter_ups
    ...               create_backup_plan=${TRUE}    provisioning_operation=activate    alias=${NETACT_NAME}

Delete Plan
   [Arguments]    ${plan_name}
   netact.delete_plan    plan_name=${plan_name}    alias=${NETACT_NAME}

Configure Netconf Credentials
    [Arguments]    @{list}
    configure_netconf_accounts    unsecure_ciphering=false
    ...    authentication_method=NoAuthentication
    ...    timeout=60
    ...    connection=default
    ...    accounts=@{list}

snapshotFileIdentifier
    snapshotFileIdentifier.snapshotGetWithoutFilter
    ...    filename=${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Snapshotfile.zip
    ...    path=${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}
    ...    fileToBeChecked=NetconfSnapshotCollection

Get Actual Configuration MO Data
    [Arguments]    ${mo_id}
    ${actual_conf}=    netact.Get Actual Configuration    alias=${NETACT_NAME}
    ${managed_object}=    netact.Get Managed Object    ${actual_conf}    ${mo_id}    alias=${NETACT_NAME}
    [Return]    ${managed_object.meta_class}     ${managed_object.meta_version}

GetCounter_miTrRxWindowStats
    [Arguments]    ${counter_tx}
    ${results}=   netact.Get PM Counters    technology=${TECHNOLOGY_NRCOUNTER}    measurement=${transport_stats_group}
    ...                              counters=${counter_tx}    filter_by=${FILTER_BY}    mo_names=${mo_name}
    ...                              object_aggregation=${OBJECT_AGGREGATION}    time_aggregation=${TIME_AGGREGATION}
    ...                              time_filter=today
    ...                              alias=${NETACT_NAME}
    Run Keyword and Continue On Failure    Should Not Be Empty    ${results}
    Log    \n${results}    console=${TRUE}

Validating M-plane negotiation
    [Arguments]    ${netconf_file}
    ${a}=    netconf_get_value    ${netconf_file}    rpc    get    operational-info
    ${a}=    validate_netconf_reply_message      ${netconf_file}     get    supported-mplane-version
    run keyword and continue on failure   Should not be empty    ${a}
    Log to console  ${a}
    ${b}=  Get Dictionary Values  ${a[1][2]}
    Log to console  ${b}
    Should Be True    @{b} < ['5.0.0']

Trigger log collection (snapshot) in O-DU from WebEM
        Log to console   \n--Start troubleshooting log collection(Snapshot) from WebEM--\n
        classical.login    https://192.168.255.129    Nemuadmin    nemuuser  timeout=180    download_dir=/home/ute/logs/snapshot    version=21B
        ...    browser=Chrome
        Log To Console    Snapshot collection
        classical.snapshot_collection_settings    All log files    Local
        ${snapshot1}=    classical.collect_snapshot    snapshot_waiting_timeout=240
        os.Copy File    ${snapshot1}	/home/ute/results/Snapshot_step1.zip

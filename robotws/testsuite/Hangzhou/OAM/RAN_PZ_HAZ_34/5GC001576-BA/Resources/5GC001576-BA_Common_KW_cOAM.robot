*** Settings ***
Documentation     author: y63li
...               Group: 5G_PZ_MMW_HZ_3_SG
...               contact: ying.15.li@nokia-sbell.com

Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/coam_resource.robot
Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/siso_resource.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Library           testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/libraries/get_bts_info.py    WITH NAME    lib
Library           taf.selenium.gnb.oam.coam.cu   WITH NAME   coam_cu
Library           taf.gnb.oam.coam.cu    WITH NAME   cu
Library           taf.sbts.oam.coam.admin   WITH NAME   admin_cli
Library           taf.transport.ssh    WITH NAME    csn
Library           OperatingSystem
Library           Collections
Library           String
Library           Process
Library           taf.pdu    WITH NAME    pdu
Library 	      DateTime

*** Variables ***
${DU_OAM_IP}            ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${CU_OAM_IP}            ${tl.gnbs[0].cu.oam_http_connection_details.addr}

${WEBUI_URL}        https://${tl.gnbs[0].dus[0].f1_m_ip_addr}
${WEBUI_USER}       ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}   ${tl.gnbs[0].cu.oam_http_connection_details.password}

${scf_name}    scf_5GC001576_BA.xml
${tmp_log_dir}    /home/ute/log
${testline}  7_5_UTE5G401T903
${scf_dir}           /opt/transformers.dynamic.nsn-net.net/gnb_configuration/7_5_UTE5G401T903/5GC001576-BA/

*** Keywords ***
5GC001576_Common Suite Setup for COAM
    #CI_interface.Common Suite Setup
    Set Suite Variable    ${TS_LOG_PATH_BASE}    ${tmp_log_dir}
    5GC001576_COAM Create log directory    is_set_to_test_case_level=${False}
    ${time_stamp}    Get current date    result_format=%Y%m%d%H%M%S
    Set Suite Variable    ${epc_log_path}    ${LOG_PATH}/${time_stamp}
    Create directory    ${epc_log_path}
    Admin Get MrbtsId And NrbtsId

5GC001576_Common Suite Teardown for COAM
    Run Keyword And Ignore Error    AdminCli disconnection and Test teardown


5GC001576_Generate suite log path
    [Arguments]    ${timeout}=1min
    ${ts_name}=    Replace String    string=${SUITE NAME}    search_for=${SPACE}    replace_with=_
    wait until keyword succeeds    ${timeout}    2sec    Connect to DU via ssl
    ${sw_version} =     coam.get_sw_version    connection=DU_OAM
    ${suite_log_path}    Join path    ${TS_LOG_PATH_BASE}    ${sw_version}    TS_${ts_name}
    Set Suite Variable    ${SUITE_LOG_PATH}    ${suite_log_path}
    Create directory    ${SUITE_LOG_PATH}

5GC001576_COAM Create log directory
    [Arguments]  ${is_set_to_test_case_level}=${True}    ${timeout}=1min
    5GC001576_Generate suite log path    timeout=${timeout}
    Run keyword if  ${is_set_to_test_case_level}
    ...    Run keywords    Generate test case log path    AND
    ...    Set test variable    ${LOG_PATH}    ${TS_CASE_LOG_PATH}
    ...    ELSE    Set suite variable    ${LOG_PATH}    ${SUITE_LOG_PATH}

Connect to DU via ssl
    [Arguments]  ${connection}=DU_OAM    ${bts_host}=${DU_OAM_IP}
    ...    ${username}=${WEBUI_USER}
    ...    ${password}=${WEBUI_PASSWORD}
    coam.connect_to    bts_host=${bts_host}    bts_port=${443}    username=${username}    password=${password}
    ...   name=${connection}

Precondition: All cells can be on air
    log to console  \n***** Precondition: All cells can be on air *****
    Check If BTS Is OnAir

AdminCli disconnection and Test teardown
    [Documentation]
    ...     Disconnects connection to gNB ADMIN and collect snapshot if any TC failed
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    admin_cli.teardown    connection=DU_OAM

Admin Get MrbtsId And NrbtsId
    run keyword and ignore error    admin_cli.Teardown
    admin_cli.get_current_scf_file    local_dir_path=${epc_log_path}    file_name=${scf_name}    connection=DU_OAM
    ${commission_file}    set variable    ${epc_log_path}/${scf_name}
    ${mrbtsId}    lib.Get_MRBTSID_cOAM    scf_path=${commission_file}
    ${nrbtsId}    lib.Get_NRBTSID_cOAM    scf_path=${commission_file}
    ${BTS_NAME}   lib.Get_BTS_name    scf_path=${commission_file}
    Set Suite Variable     ${mrbtsId}
    Set Suite Variable     ${nrbtsId}
    Set Suite Variable     ${dist_name}    MRBTS-${mrbtsId}/NRBTS-${nrbtsId}
    Set Suite Variable     ${commission_file}
    Set Suite Variable     ${BTS_NAME}

Check If BTS Is OnAir
    ${bts_statuses_response}=    admin_cli.Get Bts Info    connection=DU_OAM
    ${actual_value}=    Get From Dictionary
    ...    dictionary=${bts_statuses_response['status']}
    ...    key=proceduralState
    Should Be Equal
    ...    first=${actual_value}
    ...    second=OnAir

Connect to cOAM as toor4nsn
    [Arguments]    ${alias}=gNB
    csn.Connect To    hostname=${DU_OAM_IP}
    ...               username=${asik_username}
    ...               password=${asik_password}
    ...               alias=${alias}

Disconnect from cOAM
    [Arguments]  ${connection}=cOAM_serviceuser
    csn.disconnect  connection=${connection}

Connect to CU admin
    cu.connect to     host=${CU_OAM_IP}
    ...               username=${WEBUI_USER}
    ...               password=${WEBUI_PASSWORD}
    ...               port=${EMPTY}
    ...               cu_version=cuoam_19b
    ...               secure=${True}

Perform Parameter Update
    [Arguments]    ${dist_name}
    ...            ${parameter}
    ...            ${value}
    ...            ${operation}
    ...            ${connection}=DU_OAM
    ...            ${skip_parameter_relation_errors}=True
    admin_cli.Perform Parameter Recommissioning
    ...    dist_name=${dist_name}
    ...    parameter=${parameter}
    ...    value=${value}
    ...    operation=${operation}
    ...    skip_parameter_relation_errors=True
    ...    connection=DU_OAM

Recored Current Active Alarm
    @{alarm_list_details}    admin_cli.get_active_alarms    connection=DU_OAM
    ${alarm_length}    admin_cli.get_active_alarms_number    connection=DU_OAM
    @{alarm_ID_list}    Create List
    FOR    ${alarm}    IN    @{alarm_list_details}
        Append To List    ${alarm_ID_list}    ${alarm["alarmId"]}
    END
    set suite variable    @{alarm_ID_list}
    set suite variable    ${alarm_length}

Check No New Active Alarm Exist
    ${current_alarm_length}    admin_cli.get_active_alarms_number    connection=DU_OAM
    @{current_alarm_list_details}    admin_cli.get_active_alarms    connection=DU_OAM
    FOR    ${alarm}    IN    @{current_alarm_list_details}
        Should be true    ${alarm["alarmId"]} in ${alarm_ID_list}
    END

Store Current Alarm in a file
    ${value}    Run Keyword And Ignore error    selenium_coam.save_current_alarms
    Run Keyword If   '${value[0]}'=='PASS'    Should Be True    ${value[1].count("${BTS_NAME}")} > 0

Store History Alarm in a file
    ${value}    Run Keyword And Ignore error    selenium_coam.save_historical_alarms
    Run Keyword If   '${value[0]}'=='PASS'    Should Be True    ${value[1].count("${BTS_NAME}")} > 0

Brower Current Alarm in a file
    ${value}    Run Keyword And Ignore error    selenium_coam.get_active_alarm_info
    ${alarm}    Run Keyword And Ignore error    Get From Dictionary    ${value[1]}[0]    Alarming object

Brower History Alarm in a file
    ${value}    Run Keyword And Ignore error    selenium_coam.get_history_alarm_info
    ${alarm}    Run Keyword And Ignore error    Get From Dictionary    ${value[1]}[0]    Alarming object

Check fault Cancelled on WebEM
    [Arguments]    ${alarm_filter}
    wait until keyword succeeds    3min    1min    siso_resource.WEBUI Login
    @{alarm info}=    selenium_coam.get_active_alarm_info    alarm_filter=${alarm_filter}    timeout=60
    should be empty    ${alarm_info}
    run keyword and ignore error    selenium_coam.logout

Du Reset
    [Arguments]    ${timeout}=300
    ...            ${wait_for_reconnection}=${True}
    ...            ${connection}=DU_OAM
    admin_cli.Reset Site
    ...    timeout=${timeout}
    ...    wait_for_reconnection=${wait_for_reconnection}
    ...    connection=${connection}

Get parameter value
    [Arguments]    ${dist_name}
    ...            ${parameter}
    ...            ${timeout}=10
    ...            ${connection}=DU_OAM
    ${out_parameters}    admin_cli.get_parameters
    ...    dist_name=${dist_name}
    ...    pattern=${parameter}
    ...    timeout=${timeout}
    ...    connection=${connection}
    [Return]    ${out_parameters}

Add Toggling MO in SCF
        @{payload_list}    create list
        ${payload}=    create dictionary
        ...            alToggAmount=2
        ...            alToggClearenceTime=1200
        ...            alToggConditonTime=1800
        ...            faultName=FCT_4298_ToP reference missing
        ...            inUse=true
        @{payload_list}    create list    ${payload}
        ${dict}=    create dictionary               parameterName=alToggSuppList
        ...                                         operation=update
        ...                                         value=@{payload_list}

        @{parameter_list}   create list    ${dict}
        admin_cli.perform_object_recommissioning
        ...           dist_name=MRBTS-${mrbts_id}/MNL-1/MNLENT-1/FMCADM-1
        ...           parameter=@{parameter_list}
        ...           operation=update
        ...           skip_parameter_relation_errors=${True}
        ...           should_activate=${True}
        ...           connection=DU_OAM

Modidfy Parameter
        [Arguments]    ${ip_address}
        @{payload_list}    create list
        ${payload}=    create dictionary
        ...            localPriority=128
        ...            masterIpAddr=${ip_address}
        ...            maximumNetworkTimingError=0
        ...            phaseErrorComp=0
        ...            topMasterId=1
        append to list   ${payload_list}   ${payload}
        ${dict}=    create dictionary               parameterName=topMasterList
        ...                                         operation=update
        ...                                         value=@{payload_list}

        @{parameter_list}   create list    ${dict}
        admin_cli.perform_object_recommissioning
        ...           dist_name=MRBTS-${mrbts_id}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1
        ...           parameter=@{parameter_list}
        ...           operation=update
        ...           skip_parameter_relation_errors=${True}
        ...           should_activate=${True}
        ...           connection=DU_OAM

Check Fault 4298
    Check active fault on WebUI
    ...    alarm_filter=ToP reference missing
    ...    Severity_expect=major
    ...    AlarmID_expect=7108
    ...    AlarmName_expect=BASE STATION SYNCHRONIZATION PROBLEM
    ...    FaultID_expect=4298
    ...    FaultName_expect=ToP reference missing
    ...    AlarmOB_expect=[${BTS_NAME}]MRBTS-${mrbtsId}/EQM-1/APEQM-1/CABINET-1/SMOD-1

#Check If BTS Is OnAir
#    Cell status should be Enabled
#    X2 link status should be available

Cell status should be Enabled
     ${result_cell_status}=     cu.get_cells_statuses
     ${operability_state}=     set variable    ${result_cell_status[0]['operational_state']}
     should be equal       ${operability_state}     enabled

Cell status should be Disabled
     ${result_cell_status}=     cu.get_cells_statuses
     ${operability_state}=     set variable    ${result_cell_status[0]['operational_state']}
     should be equal       ${operability_state}     disabled

X2 link status should be available
    ${result_X2_link}=      cu.get_x2_links_info
    ${availability_state}=   set variable  ${result_X2_link['created'][0]['x2_link_status']}
    should be equal    ${availability_state}    available

Check Active Alarm in WebEM
     [Arguments]    ${alarm_filter}
     ${active_alarm}=    coam_cu.get_active_alarm_info    alarm_filter=${alarm_filter}
     ${alarm_num}=    get length    ${active_alarm}
     should be true    ${alarm_num}!=0
     [Return]    ${active_alarm}

CU WebEM Login
     coam_cu.enable_virtual_display
     coam_cu.login   url=${WEBUI_URL}
     ...             browser=Firefox

CU WebEM Logout
     coam_cu.logout

Check Fault 4026
    Check active fault on WebUI
    ...    alarm_filter=Toggling: ToP reference missing (4298)
    ...    Severity_expect=major
    ...    AlarmID_expect=7108
    ...    AlarmName_expect=BASE STATION SYNCHRONIZATION PROBLEM
    ...    FaultID_expect=4026
    ...    FaultName_expect=Toggling: ToP reference missing (4298)
    ...    AlarmOB_expect=[${BTS_NAME}]MRBTS-${mrbtsId}/EQM-1/APEQM-1/CABINET-1/SMOD-1

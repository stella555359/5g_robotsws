*** Settings ***
Resource          common_resource.robot
Library           taf/rfrl/csv4all/CSV4AllTestCases.py
# Library    taf.rfrl.procedures.resources.python.lmi_light.lmi_light.LMILight
# ...    main_log_directory=/tmp/lmi_logs    WITH NAME    lmi
Library   taf.hw.rmod_serial_interface   WITH NAME   RSI
Documentation    Author: winnie
...              Contact: winnie@nokia-sbell.com
*** Variables ***
${ITERATIONS}              1
${HOSTNAME}                    ${None}
@{CRITICAL_FAULTS}             10    1806    4341    4352    4383
${SHOULD_BE_REPORTED}          ${False}
@{CUSTOMERS_LIST}              Generic
${QC_DOMAIN}                   MN_RAN
${TEST_QC_ID}                  ${None}  # SHOULD BE DIFFERENT FOR EACH TEST CASE ACCORDING TO QC_ID OF EACH TEST
${QC_PROJECT}                  RAN_VRF
${RP_CA}                       VRF_RRM
${RP_LOCATION}                 VRF_HAZ
${RP_ORGANIZATION}             VRF_HAZ_T06
${EMAIL_RECIPIENTS}            None
##For upgade
${INITIAL_SW}                  None
${TARGET_SW}                   None
${TARGET_SW_PATH}              /home/ute/Downloads
${TEMPORARY_ALLOWED_ALARMS}    ${NONE}
${ARTIFACTORY_LOCATION}        espoo2

*** Keywords ***
UUF4ALL Set Base Variable
    [Arguments]    ${bts_index}=all
    ...     ${case_name}=${TEST NAME}
    #get allow alarms
    ${CUSTOM_ALLOWED}    Create List
    ${combined_allow_fault_alarms}    Get All Allow Faults
    ...    tl_allowed_faults_file_path=${testline_configuration_path}${/}${TestLine_Name}${/}${tl_allow_faults_file_name}
    FOR    ${fault_Info}   IN    @{combined_allow_fault_alarms}
        Append To List    ${CUSTOM_ALLOWED}     ${fault_Info}[faultId]
    END
    Set Test Variable    ${CUSTOM_ALLOWED}    ${CUSTOM_ALLOWED}
    # prepare nodes
    Prepare Nodes    ${bts_index}
    Prepare Iteration By Config    casename=${case_name}

Prepare Nodes
    [Arguments]    ${bts_index}=all
    Run Keyword And Ignore Error    _Get All Gnb Active Sw Version
    ${NODES}    Create List
    ${bts_indexes}    Split String    ${bts_index}    ,
    FOR    ${index}    ${node_obj}    IN ENUMERATE    @{tl.gnbs}
        Continue For Loop If    '${index}' not in ${bts_indexes} and '${bts_index}'!='all'
        ${node_dict}    Create Dictionary    testline_object=${node_obj}
        ...    source_sw=${BTS${index}_ACTIVE_SW_VERSION}
        ...    target_sw=${EXPECT_SW_VERSION}
        ...    custom_allowed_alarms=${CUSTOM_ALLOWED}
        Append To List    ${NODES}    ${node_dict}
    END
    Set Test Variable    ${NODES}    ${NODES}

Prepare Iteration By Config
    [Arguments]    ${casename}=${TEST NAME}
    ${config_str}    OperatingSystem.Get File    ${CURDIR}/../Top50/stability_test_iteration_config.json
    ${config_str}    Replace String Using Regexp    ${config_str}    \n\s*    ${EMPTY}
    ${config}    Evaluate    json.loads('${config_str}')
    ${tl_config_keys}    Get Dictionary Keys    ${config}
    ${testline_config}    Run Keyword If    '${TESTLINE_NAME}' in ${tl_config_keys}
    ...    Set Variable    ${config}[${TESTLINE_NAME}]
    ...    ELSE
    ...    Set Variable    ${config}[Default]
    ${tl_config_testname_keys}    Get Dictionary Keys    ${testline_config}[${casename}]

    Run Keyword If    "${${casename}_times}"!="${None}"
    ...    Set To Dictionary    ${Stability_TEST_ITERATION}
    ...    ${casename}=${${casename}_times}
    ...    ELSE IF    'runtimes' not in ${tl_config_testname_keys}
    ...    Set To Dictionary    ${Stability_TEST_ITERATION}
    ...    ${casename}=${config}[Default][${casename}][runtimes]
    ...    ELSE
    ...    Set To Dictionary    ${Stability_TEST_ITERATION}
    ...    ${casename}=${testline_config}[${casename}][runtimes]
    ${matches}    Get Regexp Matches    ${casename}    Upgrade
    ${is_upgrade}    Run Keyword And Return Status    Should Not Be Empty    ${matches}
    ${reported_release}    Run Keyword If    ${is_upgrade}
    ...    Get Release By Sw Version    ${EXPECT_SW_VERSION}
    ...    ELSE
    ...    Get Release By Sw Version    ${ACTIVE_SW_VERSION}
    ${qc_config_current_case}    Create Dictionary
    Run Keyword If    '${reported_release}' in ${tl_config_testname_keys}
    ...    Set To Dictionary    ${qc_config_current_case}
    ...    ${reported_release}=${testline_config}[${casename}][${reported_release}]
    ...    ELSE
    ...    Return From Keyword
    ${UUF4ALL_CASE_QC_ID}    Create Dictionary    ${casename}=${qc_config_current_case}
    Set Suite Variable    ${UUF4ALL_CASE_QC_ID}    ${UUF4ALL_CASE_QC_ID}
    Set Test Variable    ${TEST_QC_ID}    ${UUF4ALL_CASE_QC_ID}[${casename}][${reported_release}]
    Set Test Variable    ${QC_DOMAIN}    MN_RAN
    Set Test Variable    ${QC_PROJECT}    RAN_VRF
    Run Keyword If    ${is_upgrade}
    ...    Set Test Variable    ${TARGET_SW}    ${EXPECT_SW_VERSION}
    ...    ELSE
    ...    Set Test Variable    ${TARGET_SW}    ${ACTIVE_SW_VERSION}
    ${should_reported}    Evaluate    ${testline_config}[${casename}].get('uuf4all_reported', False)
    Set Test Variable    ${SHOULD_BE_REPORTED}    ${should_reported}
    Set Tags    QCD_MN_RAN
    Set Tags    QCP_RAN_VRF
    Set Tags    QC_${TEST_QC_ID}

UUF4ALL_ENDC_Call_Check
    [Arguments]    ${vm_index}=${0}
    Log To Console    Check ENB Attach State
    ${ret}    csn.execute
    ...    command=cat ${BTS${vm_index}_LOG_PATH} |grep -a X2AP_SGNB_RECONFIGURATION_COMPLETE | grep -av grep
    ...    connection=BTS${vm_index}_VM
    Should Contain    ${ret}    X2AP_SGNB_RECONFIGURATION_COMPLETE

UUF4ALL_SA_Call_Check
    [Arguments]    ${vm_index}=${0}
    Log To Console    Check ENB Attach State
    ${ret}    csn.execute
    ...    command=cat ${BTS${vm_index}_LOG_PATH} |grep -a 'PDU sessions successfully set up' | grep -av grep
    ...    connection=BTS${vm_index}_VM
    Should Contain    ${ret}    PDU sessions successfully set up

_UUF4ALL_Method_Call
    [Arguments]    ${uuf4all_Kw}    ${L3_CALL_Kw}=${None}
    ...    ${test_iteration}=${TEST_ITERATION}
    Log to Console    ${SHOULD_BE_REPORTED}
    Run Keyword    ${uuf4all_Kw}
    ...    ${NODES}
    ...    ${NODES}
    ...    ${test_iteration}
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${TEST_QC_ID}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS_LIST}
    ...    sw_build=${TARGET_SW}
    ...    topology=${TESTLINE_TYPE}
    ...    l3_call_method=${L3_CALL_Kw}

UUF4ALL_Site_Reset_without_HWF_with_OAM_KPI
    [Arguments]    ${L3_CALL_Kw}=${None}
    ...    ${test_iteration}=${TEST_ITERATION}
    Log To Console    ${HOSTNAME}
    _UUF4ALL_Method_Call    uuf4all_Kw=E2E TL SITE RESET WITH OAM KPI
    ...    L3_CALL_Kw=${L3_CALL_Kw}
    ...    test_iteration=${test_iteration}

UUF4ALL_BBMOD_Reset_with_OAM_KPI
    [Arguments]    ${L3_CALL_Kw}=${None}
    ...    ${test_iteration}=${TEST_ITERATION}
    Log To Console    ${HOSTNAME}
    _UUF4ALL_Method_Call    uuf4all_Kw=E2E TL CAPACITY MODULE RESET WITH OAM KPI
    ...    L3_CALL_Kw=${L3_CALL_Kw}
    ...    test_iteration=${test_iteration}

UUF4ALL_RU_Reset_with_OAM_KPI
    [Arguments]    ${L3_CALL_Kw}=${None}
    ...    ${test_iteration}=${TEST_ITERATION}
    Log To Console    ${HOSTNAME}
    _UUF4ALL_Method_Call    uuf4all_Kw=E2E TL RU RESET WITH OAM KPI
    ...    L3_CALL_Kw=${L3_CALL_Kw}
    ...    test_iteration=${test_iteration}

UUF4ALL_Cell_Lock_Unlock_NR_with_OAM_KPI
    [Arguments]    ${L3_CALL_Kw}=${None}
    ...    ${test_iteration}=${TEST_ITERATION}
    Log To Console    ${HOSTNAME}
    _UUF4ALL_Method_Call    uuf4all_Kw=E2E TL CELL LOCK UNLOCK NR WITH OAM KPI
    ...    L3_CALL_Kw=${L3_CALL_Kw}
    ...    test_iteration=${test_iteration}

UUF4ALL_Cell_Lock_Unlock_LTE_with_OAM_KPI
    [Arguments]    ${L3_CALL_Kw}=${None}
    ...    ${test_iteration}=${TEST_ITERATION}
    Log To Console    ${HOSTNAME}
    _UUF4ALL_Method_Call    uuf4all_Kw=E2E TL CELL LOCK UNLOCK LTE WITH OAM KPI
    ...    L3_CALL_Kw=${L3_CALL_Kw}
    ...    test_iteration=${test_iteration}

UUF4ALL_Cell_Block_Unblock_LTE_with_OAM_KPI
    [Arguments]    ${L3_CALL_Kw}=${None}
    ...    ${test_iteration}=${TEST_ITERATION}
    Log To Console    ${HOSTNAME}
    _UUF4ALL_Method_Call    uuf4all_Kw=E2E TL CELL BLOCK UNBLOCK LTE WITH OAM KPI
    ...    L3_CALL_Kw=${L3_CALL_Kw}
    ...    test_iteration=${test_iteration}

UUF4ALL_Cell_Block_Unblock_NR_with_OAM_KPI
    [Arguments]    ${L3_CALL_Kw}=${None}
    ...    ${test_iteration}=${TEST_ITERATION}
    Log To Console    ${HOSTNAME}
    _UUF4ALL_Method_Call    uuf4all_Kw=E2E TL CELL BLOCK UNBLOCK NR WITH OAM KPI
    ...    L3_CALL_Kw=${L3_CALL_Kw}
    ...    test_iteration=${test_iteration}

UUF4ALL_Cell_Block_Unblock_WCDMA_with_OAM_KPI
    [Arguments]    ${L3_CALL_Kw}=${None}
    ...    ${test_iteration}=${TEST_ITERATION}
    Log To Console    ${HOSTNAME}
    _UUF4ALL_Method_Call    uuf4all_Kw=E2E TL CELL BLOCK UNBLOCK WCDMA WITH OAM KPI
    ...    L3_CALL_Kw=${L3_CALL_Kw}
    ...    test_iteration=${test_iteration}

UUF4ALL_RU_Lock_Unlock_with_OAM_KPI
    [Arguments]    ${L3_CALL_Kw}=${None}
    ...    ${test_iteration}=${TEST_ITERATION}
    Log To Console    ${HOSTNAME}
    _UUF4ALL_Method_Call    uuf4all_Kw=E2E TL RU LOCK UNLOCK
    ...    L3_CALL_Kw=${L3_CALL_Kw}
    ...    test_iteration=${test_iteration}

UUF4ALL_RU_Power_Reset_with_OAM_KPI
    [Arguments]    ${L3_CALL_Kw}=${None}
    ...    ${test_iteration}=${TEST_ITERATION}
    Log To Console    ${HOSTNAME}
    Log To Console    Get All pdu list
    # ${bbu_pdu_list}    Create Dictionary
    # ...    model=${tl.gnbs[${0}].dus[0].airscale.common_units[0].pdu_port.pdu.vendor}
    # ...    host=${tl.gnbs[${0}].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
    # ...    port=${tl.gnbs[${0}].dus[0].airscale.common_units[0].pdu_port.port_no}
    # ${pdu_list}    Create List    ${bbu_pdu_list}
    ${pdu_list}    Create List
    ${rru_length}    Get Length    ${BTS${0}_INFO.RRUS}

    FOR    ${i}    IN RANGE    ${rru_length}
        ${ru_pdu}    Create Dictionary
        ...    model=${tl.gnbs[${0}].dus[0].rus[${i}].pdu_port.pdu.vendor}
        ...    host=${tl.gnbs[${0}].dus[0].rus[${i}].pdu_port.pdu.addr}
        ...    port=${tl.gnbs[${0}].dus[0].rus[${i}].pdu_port.port_no}
        ${serial_no}    Set Variable    ${tl.gnbs[${0}].dus[0].rus[${i}].serial_number}
        &{rmod}    Create Dictionary    ${serial_no}=${ru_pdu}
        Append To List    ${pdu_list}    ${rmod}
    END
    E2E TL RU POWER RESET
    ...    ${NODES}
    ...    ${NODES}
    ...    ${test_iteration}
    ...    rmods_with_pdu_ports=${pdu_list}
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${TEST_QC_ID}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS_LIST}
    ...    sw_build=${TARGET_SW}
    ...    topology=${TESTLINE_TYPE}
    ...    l3_call_method=${L3_CALL_Kw}

UUF4ALL_Delta_Commissioning_With_Site_Reset_Required
    [Arguments]    ${L3_CALL_Kw}=${None}
    ...    ${test_iteration}=${TEST_ITERATION}
    Log To Console    ${HOSTNAME}
    _UUF4ALL_Method_Call    uuf4all_Kw=E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION
    ...    L3_CALL_Kw=${L3_CALL_Kw}
    ...    test_iteration=${test_iteration}
    _UUF4ALL_Method_Call    uuf4all_Kw=E2E TL DELTA COMMISSIONING WITH SITE RESET REQUIRED
    ...    L3_CALL_Kw=${L3_CALL_Kw}
    ...    test_iteration=${test_iteration}

SW_Upgrade_Rollback_with_OAM_KPI
    [Arguments]    ${L3_CALL_Kw}=${None}
    ...     ${test_iteration}=${Stability_TEST_ITERATION}[${TEST NAME}]
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...    ${NODES}
    ...    ${NODES}
    ...    ${test_iteration}
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${TEST_QC_ID}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS_LIST}
    ...    use_testpackage=${True}
    ...    sw_build=${TARGET_SW}
    ...    topology=${TESTLINE_TYPE}
    ...    download_path=${TARGET_SW_PATH}
    ...    artifactory_location=${ARTIFACTORY_LOCATION}
    ...    l3_call_method=${L3_CALL_Kw}

E2E_TL_Parallel_SW_Upgrade_Rollback_with_OAM_KPI
    [Arguments]    ${L3_CALL_Kw}=${None}
    ...     ${test_iteration}=${Stability_TEST_ITERATION}[${TEST NAME}]
    E2E PARALLEL SW UPGRADE ROLLBACK WITH OAM KPI
    ...    ${NODES}
    ...    ${NODES}
    ...    ${test_iteration}
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${TEST_QC_ID}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS_LIST}
    ...    use_testpackage=${True}
    ...    sw_build=${TARGET_SW}
    ...    topology=${TESTLINE_TYPE}
    ...    download_path=${TARGET_SW_PATH}
    ...    artifactory_location=${ARTIFACTORY_LOCATION}
    ...    l3_call_method=${L3_CALL_Kw}

UUF4ALL_Activation_Reset_with_OAM_KPI
    [Arguments]    ${L3_CALL_Kw}=${None}
    ...    ${test_iteration}=${TEST_ITERATION}
    _UUF4ALL_Method_Call    uuf4all_Kw=E2E TL ACTIVATION RESET TEST
    ...    L3_CALL_Kw=${L3_CALL_Kw}
    ...    test_iteration=${test_iteration}

UUF4ALL_Capacity_Module_Reset_with_OAM_KPI
    [Arguments]    ${L3_CALL_Kw}=${None}
    ...    ${test_iteration}=${TEST_ITERATION}
    _UUF4ALL_Method_Call    uuf4all_Kw=E2E TL CAPACITY MODULE RESET WITH OAM KPI
    ...    L3_CALL_Kw=${L3_CALL_Kw}
    ...    test_iteration=${test_iteration}


UUF4ALL_Capacity_Module_Lock_Unlock
    [Arguments]    ${L3_CALL_Kw}=${None}
    ...    ${test_iteration}=${TEST_ITERATION}
    _UUF4ALL_Method_Call    uuf4all_Kw=E2E TL CAPACITY MODULE LOCK UNLOCK
    ...    L3_CALL_Kw=${L3_CALL_Kw}
    ...    test_iteration=${test_iteration}

L3 Call
    [Arguments]    ${cell_used_in_test}    ${remote}=${USE_REMOTE_NODE}
    ...    ${bts_index}=${BTS_INDEX}    ${mode}=SA
    ...    ${remote_pa_change_kw}=${None}
    ...    ${pre_attach_kw}=${None}
    Log    ${cell_used_in_test},${remote} is not used
    Init Attenuation All Max    max_value=${PA_MaxValue}
    Log To Console    Attach UE To ENB And GNB
    Start Multi Bts Log
    ${rru_length}    Get Length    ${BTS${bts_index}_INFO.RRUS}
    FOR    ${i}    IN RANGE    ${rru_length}
        Modify Attenuation For One RRU Of One Site
        ...    ru_id=${i}    gnb_id=${bts_index}    value=${PA_NormalValue}
    END
    Run Keyword If    '${remote_pa_change_kw}'!='${None}'
    ...    Run Keyword    ${remote_pa_change_kw}
    Attach UE By AT    mode=${mode}    pre_attach_kw=${pre_attach_kw}
    ${ENDC_Call}    Run Keyword And Return Status    UUF4ALL_ENDC_Call_Check
    ...    vm_index=${bts_index}
    ${SA_Call}    Run Keyword And Return Status    UUF4ALL_SA_Call_Check
    ...    vm_index=${bts_index}
    Log To Console    ENDC_Call: ${ENDC_Call}, SA_Call:${SA_Call}
    Should Be True    ${ENDC_Call} or ${SA_Call}
    [Teardown]    L3 Call Teardown

L3 Call Teardown
    [Arguments]    ${ue_index}=${0}
    run keyword    ${UE_TYPE}.Teardown UE    ue_index=${ue_index}
    Run Keyword And Ignore Error    Stop All BTSLog And Download to Local

AT.Variable UE Set
    [Arguments]    ${ue_index}=${0}
    ${ret}    ute_ue.Send At Cmd To Ue    UE_${ue_index}
    ...    at_cmd=at+cfun=15
    AT.__Check Return Value    ${ret}

Combine Power Reset Alarms
    FOR    ${fault_Info}   IN    @{PowerReset_Allow_Alarms}
        Append To List    ${CUSTOM_ALARMS}     ${fault_Info}[faultId]
    END
    Set Test Variable    ${CUSTOM_ALARMS}    ${CUSTOM_ALARMS}

Delete Logs
    ${log_path}    Join Path    /home/ute/test_results    ${TEST_NAME}
    Remove Directory    ${log_path}    ${True}

Top50 Suite Teardown
    Run Keyword And Ignore Error    Run keyword If    ${MoveLog_to_Logserver}
    ...    Move All Test Result To Log Server

# Fetch LMI Logs
#     [Arguments]    ${connection}=${None}    ${ue_index}=${0}
#     ${lmi_config_file}    Join Path    ${testline_configuration_path}    ${tl_lmi_config}
#     ${lmi_config_content}    OperatingSystem.Get File    ${lmi_config_file}
#     &{lmi_config_json}    json.Loads    ${lmi_config_content}
#     ${serial_com}    Set Variable    ${lmi_config_json}[configuration][serial_com]
#     ${username}    Set Variable    ${lmi_config_json}[configuration][username]
#     ${password}    Set Variable    ${lmi_config_json}[configuration][password]
#     ${connection}    Run Keyword If    '${connection}'=='${None}'
#     ...    csn.connect_to    ${tl.ues[${ue_index}].ssh_connection_details.addr}
#     ...        ${tl.ues[${ue_index}].ssh_connection_details.username}
#     ...        ${tl.ues[${ue_index}].ssh_connection_details.password}
#     ...        timeout=120
#     ...        alias=lmi_server
#     ...    ELSE    Set Variable    ${connection}
#     ${ret}   csn.execute    command=python serial_control.py -p ${serial_com} -u ${username} -p ${password}
#     ...    connection=lmi_server

# Reboot RRU By LMI
#     [Arguments]    ${bts_index}=${0}    ${ru_index}=${0}
#     ${ru_info}    get_site_info    product_type=gnb
#     ...    bts_index=${bts_index}
#     ...    info_type=rru
#     ...    ru_index=${ru_index}
#     ${host_connection}    RSI.Setup Host    ${ru_info.lmi.host.default_ssh_connection_details.addr}
#     ...    ${ru_info.lmi.host.default_ssh_connection_details.username}
#     ...    ${ru_info.lmi.host.default_ssh_connection_details.password}
#     ...    upload=${True}
#     ...    alias=lmi_host
#     RSI.Setup RMOD Connection
#     ...    ${ru_info.radio_type}
#     ...    ${ru_info.lmi.uart_mapping[0].port}
#     ...    alias=lmi    host_connection=${host_connection}
#     RSI.execute_command    reboot
#     ...    alias=lmi
#     Sleep    30s
#     [Teardown]    Run Keyword And Ignore Error
#     ...    RSI.teardown    alias=lmi

# LMI Log Collection
#     [Arguments]    ${bts_index}=${0}    ${ru_index}=${0}
#     ${ru_info}    get_site_info    product_type=gnb
#     ...    bts_index=${bts_index}
#     ...    info_type=rru
#     ...    ru_index=${ru_index}
#     ${host_connection}    RSI.Setup Host    ${ru_info.lmi.host.default_ssh_connection_details.addr}
#     ...    ${ru_info.lmi.host.default_ssh_connection_details.username}
#     ...    ${ru_info.lmi.host.default_ssh_connection_details.password}
#     ...    upload=${True}
#     ...    alias=lmi_bts${bts_index}_rru${ru_index}_host
#     RSI.Setup RMOD Connection
#     ...    ${ru_info.radio_type}
#     ...    ${ru_info.lmi.uart_mapping[0].port}
#     ...    alias=lmi_bts${bts_index}_rru${ru_index}
#     ...    host_connection=${host_connection}
#     ${log_start_time}    Get TimeStamp With Date
#     RSI.execute_command    cmd=ccsShell.sh log -a -c full -z rflog.zip >> /ram/rflog_${log_start_time}.zip
#     ...    timeout=300
#     ...    alias=lmi_bts${bts_index}_rru${ru_index}
#     ${remote_log_list}    Create List    /ram/rflog_${log_start_time}.zip
#     ${soap_list_str}    RSI.execute_command    cmd=ls /ram/UnitOAM_SOAP_*
#     ...    alias=lmi_bts${bts_index}_rru${ru_index}
#     Log    ${soap_list_str}
#     ${soap_list}    Split String    ${soap_list_str}
#     FOR    ${soap_log}    IN    @{soap_list}
#         ${dir_path}    Set Variable If    '${soap_log[-1]}'==':'
#         ...    ${soap_log[:-1]}    ${dir_path}
#         Continue For Loop If    '${soap_log[-1]}'==':'
#         Append To List    ${remote_log_list}    ${dir_path}/${soap_log}
#     END
#     Log To Console    ${remote_log_list}
#     # scp log
#     csn.connect_to    ${ru_info.lmi.host.default_ssh_connection_details.addr}
#     ...    ${ru_info.lmi.host.default_ssh_connection_details.username}
#     ...    ${ru_info.lmi.host.default_ssh_connection_details.password}
#     ...    alias=lmi_pc
#     csn.connect_to    ${ru_info.default_ssh_connection_details.addr}
#     ...    ${ru_info.default_ssh_connection_details.username}
#     ...    ${ru_info.default_ssh_connection_details.password}
#     ...    alias=rru_ssh    proxy=lmi_pc
#     csn.download_file    remote_path=/ram/rflog_${log_start_time}.zip
#     [Teardown]    Run Keyword And Ignore Error
#     ...    RSI.teardown    alias=lmi_bts${bts_index}_rru${ru_index}

Rewrite The passed_logs_gathered Variable
    ${venv_path}     OperatingSystem.Run    echo $VIRTUAL_ENV
    ${python_version}     OperatingSystem.Run    python --version
    ${version}     Split String    ${python_version}
    ${file_path}    Catenate    SEPARATOR=
    ...    ${venv_path}
    ...    /lib/python${version}[-1][0:4]
    ...    /site-packages/taf/rfrl/csv4all/resources/test_cases/
    ...    csv4all_test.py

    replace_string_in_file    file_path=${file_path}
    ...    findstring='self.passed_logs_gathered = False'
    ...    replacement='self.passed_logs_gathered = True'
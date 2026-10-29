*** Settings ***
Documentation    Author: winnie
...              Contact: winnie@nokia-sbell.com

Resource          common_resource.robot
Resource          taf/rfrl/uuf4all/uuf4all_test_cases.robot
# Library    taf.rfrl.procedures.resources.python.lmi_light.lmi_light.LMILight
# ...    main_log_directory=/tmp/lmi_logs    WITH NAME    lmi
Library   taf.hw.rmod_serial_interface   WITH NAME   RSI
*** Variables ***
${TEST_ITERATION}              1
${HOSTNAME}                    ${None}
@{CUSTOM_ALARMS}               @{EMPTY}
${REMOTE_VM_IP}                ${None}
${REMOTE_MPLANE}               ${None}
${LABEL}                       ${None}
@{CRITICAL_FAULTS}             10    1806    4341    4352    4383
${SHOULD_BE_REPORTED}          ${False}
@{CUSTOMERS_LIST}              Generic
${REMOTE_NODE_UPDATE}          ${False}
${USE_REMOTE_NODE}             ${False}
${USE_BUILDS_STORAGE}          ${False}
${RESTORE_TARGET_SW}           ${True}
${PERFORM_UBOOT_DOWNGRADE}     ${True}
${DISABLE_SYSLOG_CHECK}        ${False}
@{USER_SUSPICIOUS_PRINTS}      @{EMPTY}
${REPORT_COMMENT}              ${None}
${ONLINE_PARAMETER_DELTA}      ${None}
${SITE_RESET_DELTA}            ${None}
${NR_RAT_RESET_DELTA}          ${None}
${LTE_RAT_RESET_DELTA}         ${None}
${QC_DOMAIN}                   MN_RAN
${TEST_QC_ID}                  ${None}  # SHOULD BE DIFFERENT FOR EACH TEST CASE ACCORDING TO QC_ID OF EACH TEST
${QC_PROJECT}                  RAN_VRF
##For upgade
${5G_SOURCE_SW}                ${None}
${5G_TARGET_SW}                ${None}
${5G_TARGET_SW_PATH}           ${None}
${4G_SOURCE_SW}                ${None}
${4G_TARGET_SW}                ${None}
${4G_TARGET_SW_PATH}           ${None}
*** Keywords ***
UUF4ALL Set Base Variable
    [Arguments]    ${bts_index}=${0}    ${rat_type}=${None}
    #get allow alarms
    ${combined_allow_fault_alarms}    Get All Allow Faults
    ...    tl_allowed_faults_file_path=${testline_configuration_path}${/}${TestLine_Name}${/}${tl_allow_faults_file_name}
    FOR    ${fault_Info}   IN    @{combined_allow_fault_alarms}
        Append To List    ${CUSTOM_ALARMS}     ${fault_Info}[faultId]
    END
    Set Test Variable    ${CUSTOM_ALARMS}    ${CUSTOM_ALARMS}
    # remote vm ip
    ${REMOTE_VM_IP}    Run Keyword If    ${bts_index}!=${0}
    ...    Set Variable    ${BTS${bts_index}_PC_INFO.Host}
    Set Test Variable    ${REMOTE_VM_IP}    ${REMOTE_VM_IP}
    ${rat_types}    Get RAT Type    bts_index=${bts_index}
    ${rat}    Run Keyword If    '${rat_type}'=='${None}'
    ...    Set Variable    ${rat_types}[0]
    ...    ELSE
    ...    Set Variable    ${rat_type}
    Set Test Variable    ${RAT_TYPE}    ${rat}
    ${REMOTE_MPLANE}    Run Keyword If    ${bts_index}!=${0}
    ...    Set Variable    ${BTS${bts_index}_INFO.IP}
    Set Test Variable    ${REMOTE_MPLANE}    ${REMOTE_MPLANE}
    ${LABEL}    Set Variable    ${TESTLINE_TYPE}
    Set Test Variable    ${LABEL}    ${LABEL}
    ${HOSTNAME}    Set Variable    ${TESTLINE_NAME}
    Set Test Variable    ${HOSTNAME}    ${HOSTNAME}
    ${USE_REMOTE_NODE}    Run Keyword If    ${bts_index}!=${0}
    ...    Set Variable    ${True}
    Set Test Variable    ${USE_REMOTE_NODE}    ${USE_REMOTE_NODE}
    Set Test Variable    ${BTS_INDEX}
    Prepare Iteration By Config

Prepare Iteration By Config
    ${config_str}    OperatingSystem.Get File    ${CURDIR}/../Top50/stability_test_iteration_config.json
    ${config_str}    Replace String Using Regexp    ${config_str}    \n\s*    ${EMPTY}
    ${config}    Evaluate    json.loads('${config_str}')
    ${tl_config_keys}    Get Dictionary Keys    ${config}
    ${testline_config}    Run Keyword If    '${TESTLINE_NAME}' in ${tl_config_keys}
    ...    Set Variable    ${config}[${TESTLINE_NAME}]
    ...    ELSE
    ...    Set Variable    ${config}[Default]
    ${tl_config_testname_keys}    Get Dictionary Keys    ${testline_config}[${TEST NAME}]
    Run Keyword If    'runtimes' not in ${tl_config_testname_keys}
    ...    Set To Dictionary    ${Stability_TEST_ITERATION}
    ...    ${TEST NAME}=${config}[Default][${TEST NAME}][runtimes]
    ...    ELSE
    ...    Set To Dictionary    ${Stability_TEST_ITERATION}
    ...    ${TEST NAME}=${testline_config}[${TEST NAME}][runtimes]
    ${matches}    Get Regexp Matches    ${TEST_NAME}    Upgrade
    ${is_upgrade}    Run Keyword And Return Status    Should Not Be Empty    ${matches}
    ${reported_release}    Run Keyword If    ${is_upgrade}
    ...    Get Release By Sw Version    ${EXPECT_SW_VERSION}
    ...    ELSE
    ...    Get Release By Sw Version    ${ACTIVE_SW_VERSION}
    ${qc_config_current_case}    Create Dictionary
    Run Keyword If    '${reported_release}' in ${tl_config_testname_keys}
    ...    Set To Dictionary    ${qc_config_current_case}
    ...    ${reported_release}=${testline_config}[${TEST NAME}][${reported_release}]
    ...    ELSE
    ...    Return From Keyword
    ${UUF4ALL_CASE_QC_ID}    Create Dictionary    ${TEST_NAME}=${qc_config_current_case}
    Set Suite Variable    ${UUF4ALL_CASE_QC_ID}    ${UUF4ALL_CASE_QC_ID}
    Set Test Variable    ${TEST_QC_ID}    ${UUF4ALL_CASE_QC_ID}[${TEST_NAME}][${reported_release}]
    Set Test Variable    ${QC_DOMAIN}    MN_RAN
    Set Test Variable    ${QC_PROJECT}    RAN_VRF
    Set Tags    QCD_MN_RAN
    Set Tags    QCP_RAN_VRF
    Set Tags    QC_${TEST_QC_ID}


UUF4ALL Send QC For Custom
    ${has_qc_id}    Run Keyword And Return Status
    ...    Dictionary Should Contain Key    ${UUF4ALL_CASE_QC_ID}    ${TEST_NAME}
    Return From Keyword If    '${has_qc_id}'=='${False}'
    # Return From Keyword If    '${TESTLINE_NAME}'!='10_5_UTESRAN001T6142' and '${TESTLINE_NAME}'!='10_5_UTESRAN001T6141'
    Set Test Variable    ${SHOULD_BE_REPORTED}    ${False}
    ${matches}    Get Regexp Matches    ${TEST_NAME}    Upgrade
    ${is_upgrade}    Run Keyword And Return Status    Should Not Be Empty    ${matches}
    ${reported_release}    Run Keyword If    ${is_upgrade}
    ...    Get Release By Sw Version    ${EXPECT_SW_VERSION}
    ...    ELSE
    ...    Get Release By Sw Version    ${ACTIVE_SW_VERSION}
    Set Test Variable    ${TEST_QC_ID}    ${UUF4ALL_CASE_QC_ID}[${TEST_NAME}][${reported_release}]
    Set Test Variable    ${QC_DOMAIN}    MN_RAN
    Set Test Variable    ${QC_PROJECT}    RAN_VRF

UUF4ALL Get QC Test Case Name
    ${case_name}    Set Variable    ${TEST NAME}
    ${has_qc_id}    Run Keyword And Return Status
    ...    Dictionary Should Contain Key    ${UUF4ALL_CASE_QC_ID}    ${TEST_NAME}
    Return From Keyword If    '${has_qc_id}'=='${False}'    ${case_name}
    ${has_qc_name}    Run Keyword And Return Status
    ...    Dictionary Should Contain Key    ${UUF4ALL_CASE_QC_ID}[${TEST_NAME}]    testname
    Return From Keyword If    '${has_qc_name}'=='${False}'    ${case_name}
    [Return]     ${UUF4ALL_CASE_QC_ID}[${TEST_NAME}][testname]

UUF4ALL Prepare Upgrade
    [Arguments]    ${bts_index}=${0}
    Run Keyword If    '${RAT_TYPE}'=='NR'
    ...    Set Test Variable    ${5G_SOURCE_SW}
    ...    ${BTS${bts_index}_ACTIVE_SW_VERSION}
    ...    ELSE
    ...    Set Test Variable    ${4G_SOURCE_SW}
    ...    ${BTS${bts_index}_ACTIVE_SW_VERSION}
    Run Keyword If    '${RAT_TYPE}'=='NR'
    ...    Set Test Variable    ${5G_TARGET_SW}    ${EXPECT_SW_VERSION}
    ...    ELSE
    ...    Set Test Variable    ${4G_TARGET_SW}    ${EXPECT_SW_VERSION}
    ${package_path}    Download Package    package=${EXPECT_SW_VERSION}
    Run Keyword If    '${RAT_TYPE}'=='NR'
    ...    Set Test Variable    ${5G_TARGET_SW_PATH}
    ...    ${package_path}
    ...    ELSE
    ...    Set Test Variable    ${4G_TARGET_SW_PATH}
    ...    ${package_path}
    Run Keyword If    ${bts_index}!=${0}
    ...    Set Test Variable    ${REMOTE_NODE_UPDATE}    ${True}
    ...    ELSE
    ...    Set Test Variable    ${REMOTE_NODE_UPDATE}    ${False}

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
    Run Keyword    ${uuf4all_Kw}
    ...          test_iteration=${test_iteration}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          remote_vm_ip=${REMOTE_VM_IP}
    ...          remote_mplane=${REMOTE_MPLANE}
    ...          label=${LABEL}
    ...          hostname=${HOSTNAME}
    ...          critical_faults=${CRITICAL_FAULTS}
    ...          should_be_reported=${SHOULD_BE_REPORTED}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          use_remote_node=${USE_REMOTE_NODE}
    ...          disable_syslog_check=${DISABLE_SYSLOG_CHECK}
    ...          user_suspicious_prints=${USER_SUSPICIOUS_PRINTS}
    ...          report_comment=${REPORT_COMMENT}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${TEST_QC_ID}
    ...          qc_project=${QC_PROJECT}
    ...          attach_test_keyword=${L3_CALL_Kw}

UUF4ALL_Site_Reset_without_HWF_with_OAM_KPI
    [Arguments]    ${L3_CALL_Kw}=${None}
    ...    ${test_iteration}=${TEST_ITERATION}
    Log To Console    ${HOSTNAME}
    _UUF4ALL_Method_Call    uuf4all_Kw=UUF4ALL_SITE_RESET_TEST
    ...    L3_CALL_Kw=${L3_CALL_Kw}
    ...    test_iteration=${test_iteration}

UUF4ALL_BBMOD_Reset_with_OAM_KPI
    [Arguments]    ${L3_CALL_Kw}=${None}
    ...    ${test_iteration}=${TEST_ITERATION}
    Log To Console    ${HOSTNAME}
    _UUF4ALL_Method_Call    uuf4all_Kw=OAM_BBMOD_RESET
    ...    L3_CALL_Kw=${L3_CALL_Kw}
    ...    test_iteration=${test_iteration}

UUF4ALL_RAT_Reset_with_OAM_KPI
    [Arguments]    ${L3_CALL_Kw}=${None}
    ...    ${test_iteration}=${TEST_ITERATION}
    ...    ${rat}=NR
    _UUF4ALL_Method_Call    uuf4all_Kw=DELTA_COMMISSIONING_WITH_${rat}_RAT_RESET
    ...    L3_CALL_Kw=${L3_CALL_Kw}
    ...    test_iteration=${test_iteration}

# DELTA_COMMISSIONING_RAT_RESET
#     [Documentation]
#     ...   author: He Winnie
#     ...   contact: winnie.he@nokia-sbell.com
#     [Arguments]  ${delta_file}=${None}
#     ...          ${test_iteration}=5
#     ...          ${custom_alarms}=@{EMPTY}
#     ...          ${remote_vm_ip}=${None}
#     ...          ${remote_mplane}=${None}
#     ...          ${label}=${None}
#     ...          ${hostname}=${None}
#     ...          ${critical_faults}=@{EMPTY}
#     ...          ${should_be_reported}=${False}
#     ...          ${customers_list}=@{EMPTY}
#     ...          ${use_remote_node}=${True}
#     ...          ${disable_syslog_check}=${False}
#     ...          ${user_suspicious_prints}=@{EMPTY}
#     ...          ${report_comment}=${None}
#     ...          ${qc_domain}=${None}
#     ...          ${qc_project}=${None}
#     ...          ${qc_id}=${None}
#     ...          ${attach_test_keyword}=${None}

#     uuf_rfrl_common_keywords.Common Test Setup   ${custom_alarms}  ${remote_vm_ip}  ${label}  ${hostname}
#     ...  ${critical_faults}  ${should_be_reported}  ${customers_list}  ${remote_mplane}  ${use_remote_node}
#     ...  ${disable_syslog_check}  ${user_suspicious_prints}  ${report_comment}  ${qc_domain}  ${qc_project}  ${qc_id}
#     ${rat_types}    Get RAT Type    bts_index=${BTS_INDEX}
#     FOR    ${rat}    IN     @{rat_types}
#         uuf_rfrl_common_keywords.Delta Commissioning Test Setup  ${delta_file}  ${False}  NR
#         uuf_rfrl_common_keywords.Attach Test Setup  ${attach_test_keyword}
#         uuf_rfrl_common_keywords.Verify Test In Loop  ${test_iteration}  ${should_be_reported}
#         ...  uuf_rfrl_common_keywords.Delta Commissioning With Rat Reset
#     END
#     [Teardown]  uuf_rfrl_common_keywords.Common Test Teardown

UUF4ALL_RU_Reset_with_OAM_KPI
    [Arguments]    ${L3_CALL_Kw}=${None}
    ...    ${test_iteration}=${TEST_ITERATION}
    Log To Console    ${HOSTNAME}
    _UUF4ALL_Method_Call    uuf4all_Kw=OAM_RMOD_RESET
    ...    L3_CALL_Kw=${L3_CALL_Kw}
    ...    test_iteration=${test_iteration}

UUF4ALL_Cell_Lock_Unlock_NR_with_OAM_KPI
    [Arguments]    ${L3_CALL_Kw}=${None}
    ...    ${test_iteration}=${TEST_ITERATION}
    Log To Console    ${HOSTNAME}
    _UUF4ALL_Method_Call    uuf4all_Kw=OAM_NRCEL_LOCK
    ...    L3_CALL_Kw=${L3_CALL_Kw}
    ...    test_iteration=${test_iteration}

UUF4ALL_Cell_Lock_Unlock_LTE_with_OAM_KPI
    [Arguments]    ${L3_CALL_Kw}=${None}
    ...    ${test_iteration}=${TEST_ITERATION}
    Log To Console    ${HOSTNAME}
    _UUF4ALL_Method_Call    uuf4all_Kw=OAM_LNCEL_LOCK
    ...    L3_CALL_Kw=${L3_CALL_Kw}
    ...    test_iteration=${test_iteration}

UUF4ALL_Cell_Block_Unblock_LTE_with_OAM_KPI
    [Arguments]    ${L3_CALL_Kw}=${None}
    ...    ${test_iteration}=${TEST_ITERATION}
    Log To Console    ${HOSTNAME}
    _UUF4ALL_Method_Call    uuf4all_Kw=OAM_LNCEL_BLOCK
    ...    L3_CALL_Kw=${L3_CALL_Kw}
    ...    test_iteration=${test_iteration}

UUF4ALL_Cell_Block_Unblock_NR_with_OAM_KPI
    [Arguments]    ${L3_CALL_Kw}=${None}
    ...    ${test_iteration}=${TEST_ITERATION}
    Log To Console    ${HOSTNAME}
    _UUF4ALL_Method_Call    uuf4all_Kw=OAM_NRCEL_BLOCK
    ...    L3_CALL_Kw=${L3_CALL_Kw}
    ...    test_iteration=${test_iteration}

UUF4ALL_Cell_Block_Unblock_WCDMA_with_OAM_KPI
    [Arguments]    ${L3_CALL_Kw}=${None}
    ...    ${test_iteration}=${TEST_ITERATION}
    Log To Console    ${HOSTNAME}
    _UUF4ALL_Method_Call    uuf4all_Kw=OAM_WNCEL_BLOCK
    ...    L3_CALL_Kw=${L3_CALL_Kw}
    ...    test_iteration=${test_iteration}

UUF4ALL_RU_Lock_Unlock_with_OAM_KPI
    [Arguments]    ${L3_CALL_Kw}=${None}
    ...    ${test_iteration}=${TEST_ITERATION}
    Log To Console    ${HOSTNAME}
    _UUF4ALL_Method_Call    uuf4all_Kw=RMOD_LOCK_UNLOCK
    ...    L3_CALL_Kw=${L3_CALL_Kw}
    ...    test_iteration=${test_iteration}

UUF4ALL_RU_Power_Reset_with_OAM_KPI
    [Arguments]    ${L3_CALL_Kw}=${None}
    ...    ${test_iteration}=${TEST_ITERATION}
    Log To Console    ${HOSTNAME}
    Log To Console    Get All pdu list
    ${bbu_pdu_list}    Create Dictionary
    ...    model=${tl.gnbs[${BTS_INDEX}].dus[0].airscale.common_units[0].pdu_port.pdu.vendor}
    ...    host=${tl.gnbs[${BTS_INDEX}].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
    ...    port=${tl.gnbs[${BTS_INDEX}].dus[0].airscale.common_units[0].pdu_port.port_no}
    ${rru_length}    Get Length    ${BTS${BTS_INDEX}_INFO.RRUS}
    ${pdu_list}    Create List    ${bbu_pdu_list}
    FOR    ${i}    IN RANGE    ${rru_length}
        ${ru_pdu}    Create Dictionary
        ...    model=${tl.gnbs[${BTS_INDEX}].dus[0].rus[${i}].pdu_port.pdu.vendor}
        ...    host=${tl.gnbs[${BTS_INDEX}].dus[0].rus[${i}].pdu_port.pdu.addr}
        ...    port=${tl.gnbs[${BTS_INDEX}].dus[0].rus[${i}].pdu_port.port_no}
        Append To List    ${pdu_list}    ${ru_pdu}
    END
    POWER_RESET
    ...          pdu_list=${pdu_list}
    ...          test_iteration=${test_iteration}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          remote_vm_ip=${REMOTE_VM_IP}
    ...          remote_mplane=${REMOTE_MPLANE}
    ...          label=${LABEL}
    ...          hostname=${HOSTNAME}
    ...          critical_faults=${CRITICAL_FAULTS}
    ...          should_be_reported=${SHOULD_BE_REPORTED}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          use_remote_node=${USE_REMOTE_NODE}
    ...          attach_test_keyword=${L3_CALL_Kw}

POWER_RESET
    [Documentation]
    ...   author: He Winnie
    ...   contact: winnie.he@nokia-sbell.com
    ...   Keyword for basic UUF site reset in loop:
    ...   - add proper HWF base on current sw flag to swconfig file,
    ...   - perform site reset of BTS,
    ...   - gather logs: snapshot, syslog,
    ...   - check HW state, faults, crashes in syslog,
    ...   - if iteration is failed it will try to recover BTS by performing site reset.
    [Arguments]  ${pdu_list}
    ...          ${test_iteration}=5
    ...          ${custom_alarms}=@{EMPTY}
    ...          ${remote_vm_ip}=${None}
    ...          ${remote_mplane}=${None}
    ...          ${label}=${None}
    ...          ${hostname}=${None}
    ...          ${critical_faults}=@{EMPTY}
    ...          ${should_be_reported}=${True}
    ...          ${customers_list}=@{EMPTY}
    ...          ${use_remote_node}=${True}
    ...          ${attach_test_keyword}=${None}
    ...          ${disable_syslog_check}=${False}
    ...          ${user_suspicious_prints}=@{EMPTY}
    ...          ${report_comment}=${None}
    ...          ${qc_domain}=${None}
    ...          ${qc_project}=${None}
    ...          ${qc_id}=${None}

    uuf_rfrl_common_keywords.Common Test Setup  ${custom_alarms}  ${remote_vm_ip}  ${label}  ${hostname}
    ...  ${critical_faults}  ${should_be_reported}  ${customers_list}  ${remote_mplane}  ${use_remote_node}
    ...  ${disable_syslog_check}  ${user_suspicious_prints}  ${report_comment}  ${qc_domain}  ${qc_project}  ${qc_id}
    uuf_rfrl_common_keywords.RMOD Power Reset Test Setup  ${pdu_list}
    uuf_rfrl_common_keywords.Attach Test Setup  ${attach_test_keyword}
    uuf_rfrl_common_keywords.Verify Test In Loop  ${test_iteration}
    ...  ${should_be_reported}    top50_resource.Power Reset Test
    [Teardown]  uuf_rfrl_common_keywords.Common Test Teardown

Power Reset Test
    [Arguments]    ${test_phase}=${EMPTY}
    uuf_rfrl_common.Add Allowed Alarm  fault_id=10
    uuf_rfrl_common.Logging Setup  ${test_phase}  Power Reset
    uuf_rfrl_common.Power Reset Pdu Port
    Sleep    15min
    uuf_rfrl_common.Post Test Verification  ${test_phase}  uuf_rfrl_common.Check BTS State
    ...  execute_attach=True  reset_check=${False}  alarms_timeout=30
    [Teardown]   uuf_rfrl_common_keywords.Stop Logging

UUF4ALL_Delta_Commissioning_With_Site_Reset_Required
    [Arguments]    ${L3_CALL_Kw}=${None}
    ...    ${test_iteration}=${TEST_ITERATION}
    Log To Console    ${HOSTNAME}
    _UUF4ALL_Method_Call    uuf4all_Kw=DELTA_COMMISSIONING_WITH_SITE_RESET_REQUIRED
    ...    L3_CALL_Kw=${L3_CALL_Kw}
    ...    test_iteration=${test_iteration}

SW_Upgrade_Rollback_with_OAM_KPI
    [Arguments]    ${L3_CALL_Kw}=${None}
    ...    ${test_iteration}=${TEST_ITERATION}
    Log To Console    ${HOSTNAME}
    Log    ${L3_CALL_Kw} is not used
    UUF4ALL Prepare Upgrade    bts_index=${BTS_INDEX}
    UUF4ALL_SW_UPGRADE_TEST
    ...          test_iteration=${test_iteration}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          remote_vm_ip=${REMOTE_VM_IP}
    ...          remote_mplane=${REMOTE_MPLANE}
    ...          label=${LABEL}
    ...          hostname=${HOSTNAME}
    ...          critical_faults=${CRITICAL_FAULTS}
    ...          should_be_reported=${SHOULD_BE_REPORTED}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${TEST_QC_ID}
    ...          qc_project=${QC_PROJECT}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          5g_source_sw=${5G_SOURCE_SW}
    ...          5g_target_sw=${5G_TARGET_SW}
    ...          5g_target_sw_path=${5G_TARGET_SW_PATH}
    ...          4g_source_sw=${4G_SOURCE_SW}
    ...          4g_target_sw=${4G_TARGET_SW}
    ...          4g_target_sw_path=${4G_TARGET_SW_PATH}
    ...          use_builds_storage=${USE_BUILDS_STORAGE}
    ...          restore_to_target_sw=${RESTORE_TARGET_SW}
    ...          remote_node_update=${REMOTE_NODE_UPDATE}
    ...          use_remote_node=${USE_REMOTE_NODE}
    ...          use_test_packages=${False}
    # ...          download_path=${DOWNLOAD_PATH}

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
#     [Arguments]    ${connection}=${None}
#     ${lmi_config_file}    Join Path    ${testline_configuration_path}    ${tl_lmi_config}
#     ${lmi_config_f}    OperatingSystem.Get File    ${lmi_config_file}
#     ${lmi_config}    json.Loads    ${lmi_config_f}
#     ${serial_com}    Set Variable    ${lmi_config}[configuration][serial_com]
#     ${username}    Set Variable    ${lmi_config}[configuration][username]
#     ${password}    Set Variable    ${lmi_config}[configuration][password]
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
#     [Arguments]    ${bts_index}=${0}    ${ru_index}=${0}     ${save_dir}=${TEST_LOG_DIRECTORY}
#     ${ru_info}    get_site_info    product_type=gnb
#     ...    bts_index=${bts_index}
#     ...    info_type=rru
#     ...    ru_index=${ru_index}
#     Log    ${save_dir} is not used
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

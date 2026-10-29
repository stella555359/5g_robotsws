*** Settings ***
Documentation     author:shuhui.lou
...               Group: HGZ_SG1
...               contact: shuhui.lou@nokia-sbell.com
Resource        testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG1/Cloud_Base_Resource.robot
Resource       ../../../../../RRM/RAN_PZ_HAZ_34/5GC000496_C/Resources/L3Call.robot
Resource          ../../../../../resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_vdu.robot
Resource       taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource       taf/rfrl/cbts/robot/vdu/vdu_operations.robot
Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_ru.robot
Library        SeleniumLibrary
Library        SSHLibrary
Library        taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    vdu

*** Variables ***
${CFGFILE_PATH}       /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/
${NRBTS_ID}                 ${tl.gnbs[0].cu.global_bts_id}
${MRBTS_ID}                 ${tl.gnbs[0].cu.global_bts_id}

##################define these variable for convenient############################

########################END of alias Define#######################################

*** Keywords ***

####Case Level  Keywords#####
TC.CB009903_F_3_Fault_2920 trigger and cancel with inputVoltage changed
    wait until keyword succeeds     10min    30s    All Cells Should Be Onair For One Specific vDU
    log to console  \n trigger minior fault 2920 via change voltage
    KW.Input_Voltage_with_command    voltage=${MINOR_LOW_VOLTAGE}
    wait until keyword succeeds    2min    5s     KW.Check_fault_is_raised    fault_id=2920    severity=minor    alarm_id=7115
    sleep   30s
    log to console  \n trigger critical fault 2920 via change voltage
    KW.Input_Voltage_with_command    voltage=${CRITICAL_LOW_VOLTAGE}
    wait until keyword succeeds    2min    5s     KW.Check_fault_is_raised    fault_id=2920    severity=critical    alarm_id=7100
    log to console  \n cancel critical fault 2920 via change voltage
    sleep   30s
    KW.Input_Voltage_with_command     voltage=${MINOR_LOW_VOLTAGE}
    wait until keyword succeeds     6min    5s     KW.Check_fault_is_raised    fault_id=2920    severity=minor    alarm_id=7115
    log to console  \n cancel minor fault 2920 via change voltage
    KW.Input_Voltage_with_command    voltage=${DEFAULT_VOLTAGE}
    wait until keyword succeeds    6min    5s     KW.Check_fault_is_clear    fault_id=2920    severity=minor    alarm_id=7115
    log to console  \n  minor fault 2920 cleaned
    wait until keyword succeeds    10min    5s     vDU Verify All Cells Status Should Be Onair
    [Teardown]  Run Keyword And Ignore Error   helm.helm_master_close

TC.Manual_SiSo_REC_RU_safe_mode_improper_voltage_input
    wait until keyword succeeds     10min    30s    All Cells Should Be Onair For One Specific vDU
    log to console  \n trigger minior fault 2919 via change voltage
    KW.Input_Voltage_with_command    voltage=${MINOR_HIGH_VOLTAGE}
    wait until keyword succeeds    2min    5s     KW.Check_fault_is_raised    fault_id=2919    severity=minor    alarm_id=7115
    sleep   30s
    log to console  \n trigger critical fault 2919 via change voltage
    KW.Input_Voltage_with_command    voltage=${CRITICAL_HIGH_VOLTAGE}
    wait until keyword succeeds    2min    5s     KW.Check_fault_is_raised    fault_id=2919    severity=critical    alarm_id=7100
    log to console  \n cancel critical fault 2919 via change voltage
    sleep   30s
    KW.Input_Voltage_with_command     voltage=${MINOR_HIGH_VOLTAGE}
    wait until keyword succeeds     6min    5s     KW.Check_fault_is_raised    fault_id=2919    severity=minor    alarm_id=7115
    log to console  \n cancel minor fault 2919 via change voltage
    KW.Input_Voltage_with_command    voltage=${DEFAULT_VOLTAGE}
    wait until keyword succeeds    6min    5s     KW.Check_fault_is_clear    fault_id=2919    severity=minor    alarm_id=7115
    log to console  \n  minor fault 2919 cleaned
    wait until keyword succeeds    10min    5s     vDU Verify All Cells Status Should Be Onair
    [Teardown]  Run Keyword And Ignore Error   helm.helm_master_close

####Case Level  Keywords#####

KW.SuiteSetup
    [Documentation]
#    [Arguments]    ${AdaptConfigurationPath}=${False}
    TestSuilt.Start
    Create Log Directories
    set suite variable   ${OAM_TYPE}    COAM
    Conn.ResetCache
    set suite variable    ${ns}    ${tl.gnbs[0].cloud_deployment.cloud_hosting.namespace}
    Import Variables        ${CFGFILE_PATH}TLConfiguration.py
    set suite variable      ${MINOR_LOW_VOLTAGE}        ${CASE_INPUT_CB009903['MINOR_LOW_VOLTAGE']}
    set suite variable      ${DEFAULT_VOLTAGE}          ${CASE_INPUT_CB009903['DEFAULT_VOLTAGE']}
    set suite variable      ${CRITICAL_LOW_VOLTAGE}     ${CASE_INPUT_CB009903['CRITICAL_LOW_VOLTAGE']}
    set suite variable      ${MINOR_HIGH_VOLTAGE}    ${CASE_INPUT_CB009903['MINOR_HIGH_VOLTAGE']}
    set suite variable      ${CRITICAL_HIGH_VOLTAGE}    ${CASE_INPUT_CB009903['CRITICAL_HIGH_VOLTAGE']}
    set suite variable      ${RU_SN}     ${CASE_INPUT_CB009903['RU_SN']}
    set suite variable      ${RU_ssh_username}    ${CASE_INPUT_CB009903['RU_ssh_username']}
    set suite variable      ${RU_ssh_password}    ${CASE_INPUT_CB009903['RU_ssh_password']}

KW.Input_Voltage_with_command
    [Documentation]
    [Arguments]    ${voltage}=53000
    SSHLibrary.Open Connection    ${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.ip_addr}
    SSHLibrary.Login    ${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.username}
        ...    ${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.password}
    ${cmd_GetRuIp}   Set Variable
    ...    kubectl exec -it po-oamfh-0 -c ctr-oamfh -n ${ns} -- bash -c "grep "${ru_sn}" /ffs/run/config/FRIps.txt"
    ${output}=    SSHLibrary.Execute Command    ${cmd_GetRuIp}
    ${ru_ip_t}    Split String    ${output}    ;
    ${ru_ip}    Set Variable    ${ru_ip_t}[-3]
    ${cmd_t}    Set Variable    kubectl exec -it po-oamfh-0 -c ctr-oamfh -n
    SSHLibrary.Write  ${cmd_t} ${ns} -- bash -c "ssh -o StrictHostKeyChecking=no ${RU_ssh_username}@${ru_ip}"
    sleep  3s
    ${res}    run keyword and return status    SSHLibrary.Read Until    password:
    run keyword if    '${res}' == 'True'    SSHLibrary.Write    ${RU_ssh_password}
    Sleep  2s
    SSHLibrary.Write    date;ccsShell.sh rad -mpw 0x110032 ${voltage}
    Sleep  1s
    SSHLibrary.Close All Connections
    [Teardown]  Run keyword and ignore error    SSHLibrary.Close All Connections

KW.Check_fault_is_raised
    [Arguments]    ${fault_id}    ${alarming_object}=${None}    ${severity}=${None}    ${alarm_id}=${None}
    ...            ${vdu_index}=0    ${alias}=default
    ${fault_id}    Convert To Integer    ${fault_id}
    vDU Login    vdu_index=${vdu_index}
    ${alarms}    vdu.vdu_get_active_alarms    vdu_connection=${alias}
    ${alarm_num}    Get From Dictionary    ${alarms}    total
    Run Keyword If    ${alarm_num}==0    Fail
    ${alarms}    Get From Dictionary    ${alarms}    alarms
    ${present_status}    Set Variable    ${False}
    FOR  ${alarm}  IN  @{alarms}
        ${present_status}    Run Keyword And Return Status    Run Keywords
        ...    Dictionary Should Contain Item    ${alarm}    fault_id    ${fault_id}    AND
        ...    Run Keyword If    '${alarming_object}'!='${None}'
        ...    Should Contain     ${alarm['alarming_object']}    ${alarming_object}    case_insensitive=True    AND
        ...    Run Keyword If    '${severity}'!='${None}'
        ...    Should Contain     ${alarm['severity']}   ${severity}    case_insensitive=True    AND
        ...    Run Keyword If    '${alarmId}'!='${None}'
        ...    Should Be Equal As Strings    ${alarm['alarm_id']}    ${alarm_id}
        Exit For Loop If    ${present_status}
    END
    Run Keyword If    ${present_status}==${False}    Fail
    [Teardown]  Run keyword and ignore error    vDU Rest Logout

KW.Check_fault_is_clear
    [Arguments]   ${fault_id}   ${alarming_object}=${None}    ${severity}=${None}    ${alarm_id}=${None}
    ...    ${vdu_index}=0    ${alias}=default
    ${fault_id}    Convert To Integer    ${fault_id}
    vDU Rest Login    vdu_index=${vdu_index}
    ${status}    Run Keyword And Return Status   KW.Check_fault_is_raised
    ...          fault_id=${fault_id}
    ...          alarming_object=${alarming_object}
    ...          severity=${severity}
    ...          alarm_id=${alarm_id}
    ...          vdu_index=${vdu_index}
    ...          alias=${alias}
    Run Keyword If  ${status}==${True}   Fail
    [Teardown]  Run keyword and ignore error    vDU Rest Logout

Teardown Suite
    TestSuite.Stop
    log to console     Suite teardown

Teardown case
    Run Keyword And Ignore Error    run    command=ps -ef|grep firefox|grep -v grep|awk '{print $2}' | xargs kill -9
    Collect snapshot if test failed
    Conn.ResetCache
    TestCase.Stop
    CI_interface.Common Case Teardown
    log to console     Case teardown

Collect snapshot if test failed
    run keyword if    '${TEST_STATUS}'=='FAIL'   KW.Input_Voltage_with_command    voltage=${DEFAULT_VOLTAGE}
    run keyword if    '${TEST_STATUS}'=='FAIL'    KW.vDUGetSnapshot



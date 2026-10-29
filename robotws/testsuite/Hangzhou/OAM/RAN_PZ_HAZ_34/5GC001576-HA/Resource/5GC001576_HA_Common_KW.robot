*** Settings ***
Documentation     author: Shenrao
...               Group: 5G_PZ_MMW_HZ_3_SG
...               contact: shengrong.rao@nokia-sbell.com

Resource          ../../common/taf_coam.robot
Resource          ../../common/coam_resource.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
#Resource    taf/rfrl/common_resources/robot/enb_lte.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot

Library    taf.sbts.oam.coam.admin   WITH NAME   admin_cli
Library    taf.selenium.gnb.oam.coam.classical    WITH NAME    seleniumC



*** Variables ***
${mrbts_id}    MRBTS-${tl.gnbs[0].instance_id}
${nrbts_id}    NRBTS-${tl.gnbs[0].global_bts_id}
${reportingIntervalPm_1}    5min
${sanpshot_path_local}    /home/ute/snapshot
${DU_OAM_IP}            ${tl.gnbs[0].dus[0].f1_m_ip_addr}

*** Keywords ***
AdminCli disconnection and Test teardown
    [Documentation]
    ...     Disconnects connection to gNB ADMIN and collect snapshot if any TC failed
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    #admin_cli.connect to    bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
    admin_cli.teardown    connection=COAM
    CI_interface.Common Case Teardown

Case_teardown
    Run Keyword And Ignore Error    csn.send_command     command=rm -rf /home/ute/snapshot/*    connection=ute
    run keyword and ignore error    AdminCli disconnection and Test teardown


Case_with_no_snapshot_teardown
    Run Keyword If    '${TEST_STATUS}' == 'FAIL'    Capture snasphot and RF log in DU
    run keyword and ignore error    AdminCli disconnection and Test teardown


COAM Check GNB_DU cell on air
    [Documentation]  Author: Shenrao
    ...              Description: Check if GNB is in cell on air status
    [Arguments]    ${connection}=COAM
    wait until keyword succeeds     2s    1s
    ...      admin_cli.connect to   bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
    ...      username=Nemuadmin
    ...      password=nemuuser
    ...      name=${connection}
    COAM Check All Cells Onair

Check alarm in DU
    [Arguments]       ${alarm1}    ${alarm2}
    ${len}=    Get Length    ${alarm1}
    ${len1}=    Get Length    ${alarm2}
    @{new_alarm_list}   Create List
    FOR    ${index}    IN RANGE    ${len1}
        Run Keyword If  ${alarm2[${index}]} not in @{alarm1}    Append To List    ${new_alarm_list}    ${alarm2[${index}]}
    END
    Set Suite Variable    @{new_alarm_list}
    [Return]    @{new_alarm_list}

Get alarm in DU
    ${active_fault_list}=    admin_cli.get_active_alarms    connection=COAM   timeout=20
    ${len}=    Get Length    ${active_fault_list}
    FOR    ${index}    IN RANGE    ${len}
        Keep In Dictionary    ${active_fault_list[${index}]}     alarmId    alarmName    faultId   faultName    configObjectName
    END

    ${historic_fault_list}=    admin_cli.get_historic_alarms    connection=COAM   timeout=20
    ${len1}=    Get Length    ${historic_fault_list}
    FOR    ${index}    IN RANGE    ${len1}
        Keep In Dictionary    ${historic_fault_list[${index}]}     alarmId    alarmName    faultId   faultName    configObjectName
    END

    Set Suite Variable    ${active_fault_list}
    Set Suite Variable    ${historic_fault_list}
    [Return]    ${active_fault_list}    ${historic_fault_list}

Save snapshot in DU
     ${local_file_path}    Catch Snapshot COAM
     set Suite variable   ${local_file_path}
     log    snapshot file is in '${local_file_path}'

Reset RU and check alarm
    DU RU Reset
    Wait until keyword succeeds    15 min   30 sec    COAM Check GNB_DU cell on air
    Get alarm in DU
    Set Suite Variable    ${active_fault_list2}     ${active_fault_list}
    Set Suite Variable    ${historic_fault_list2}    ${historic_fault_list}
    Check alarm in DU    alarm1=${active_fault_list1}    alarm2=${active_fault_list2}
    Set Suite Variable    ${new_alarm_list_active}    ${new_alarm_list}
    Should Be Empty    ${new_alarm_list_active}
    Check alarm in DU    alarm1=${historic_fault_list1}     alarm2=${historic_fault_list2}
    Set Suite Variable    ${new_historic_alarm_list_active}    ${new_alarm_list}
    Should Be Empty    ${new_historic_alarm_list_active}

DU RU Reset
    log to console      DU RU Reset
    seleniumC.enable_virtual_display
    seleniumC.login               url=https://${DU_OAM_IP}
    ...                    username=Nemuadmin
    ...                    password=nemuuser
    seleniumC.disable_screen_lock
    seleniumC.reset_ru
    run keyword and ignore error     seleniumC.logout

Collect RF logs
	[Timeout]										190 seconds
    [Documentation]  This keyword will Collect RF logs, and save logs to UTE.
     ${CurrentDateTime}=    Get Current Date
    Set Suite Variable    ${CurrentDateTime}
    connection_alias_store.Connect to RU   du_index=${0}   ru_index=${0}    alias=RF1
    csn.execute     command=cd /usr/bin;ccsShell.sh log -c full -z /ram/ru_fullLogs.zip    connection=RF1
    csn.Send Command
    ...    command=ls /ram/ |grep -i ru_fullLogs.zip
    ...    connection=RF1
    sleep    15s
    Connect to Common Unit Master      du_index=${0}   alias=asik
    ${rf_name} =   set variable  ${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.username}
    ${rf_addr} =   set variable  ${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.addr}
    ${rf_pw} =   set variable  ${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.password}
    csn.Send Command
    ...        command=scp -o StrictHostKeyChecking\=no ${rf_name}@${rf_addr}:/ram/ru_fullLogs.zip /tmp/ru_fullLogs.zip
    ...        get_pty=True
    ...        connection=asik
    ${scp_output} =    Run Keyword And Ignore Error
    ...                csn.read output until    match=password    timeout=10    connection=asik
    Log    ${scp_output}
    run keyword if    '${scp_output[0]}' == 'PASS'
    ...              csn.write input    data=${rf_pw}\n    connection=asik
    sleep    15s
    csn.download file
    ...   remote_path=/tmp/ru_fullLogs.zip
    ...   local_path=${OUTPUT_DIR}/ru_fullLogs_${CurrentDateTime}.zip
    ...   connection=asik

Capture snasphot and RF log in DU
    Save snapshot in DU
    Collect RF logs

Get CABLINK of RU detected Results

    ${CABLINK_statuses_response}=    admin_cli.get_managed_objects    class_name=CABLINK_R  connection=COAM
    Set Test Variable      ${CABLINK_STATUSES}    ${CABLINK_statuses_response}
    ${len}=    Get Length    ${CABLINK_STATUSES}
    FOR    ${index}    IN RANGE    ${len}
           ${operationalState}=     Get From Dictionary    ${CABLINK_STATUSES[${index}]['parameters']}     operationalState
           ${firstEndpointLabel}=     Get From Dictionary    ${CABLINK_STATUSES[${index}]['parameters']}     firstEndpointLabel
           ${secondEndpointLabel}=     Get From Dictionary    ${CABLINK_STATUSES[${index}]['parameters']}     secondEndpointLabel
           Run Keyword If    '${firstEndpointLabel}'!='BACKPLANE'    Check Cablink1 status    firstEndpointLabel=${firstEndpointLabel}
    ...     secondEndpointLabel=${secondEndpointLabel}    operationalState=${operationalState}
    END


Check Cablink1 status
    [Arguments]       ${firstEndpointLabel}    ${secondEndpointLabel}    ${operationalState}
     Should Be Equal    ${firstEndpointLabel}    SFP
     Should Be Equal    ${secondEndpointLabel}    SFP
     Should Be Equal    ${operationalState}    enabled




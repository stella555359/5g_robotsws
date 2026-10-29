*** Settings ***
Documentation    Suite description

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot

*** Variables ***

${DU_OAM_IP}    ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${DU_OAM_WEBUI_USER}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
${DU_OAM_WEBUI_PASSWORD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
${eNB_DU_OAM_IP}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${enb_ID}    ${tl.enbs[0].global_bts_id}

*** Keywords ***
Secondary syncsource check
    [Arguments]    ${bts_sync_status}
    run keyword and continue on failure    should be true    '${bts_sync_status['syncSourceInfo'][0]['isActive']}'=='True'
    run keyword and continue on failure    should be true    '${bts_sync_status['syncSourceInfo'][0]['status']['availability']}'=='Available'
    run keyword and continue on failure    should be true    '${bts_sync_status['syncSourceInfo'][0]['status']['usability']}'=='Usable'
    run keyword and continue on failure    should be true    '${bts_sync_status['syncSourceInfo'][0]['syncInputType']}'=='1pps/ToD from backplane'

Syncsource switch pre-condition
    [Documentation]    Syncsource switch pre-condition, gps and LTE
    [Arguments]    ${cell_type}=nr    ${bts_host}=${eNB_DU_OAM_IP}
    Connect to gnb coam via ssl    bts_host=${bts_host}
    Wait Until Keyword Succeeds   100s     10s    Verify all cells should be onair    cell_type=lte
    ${bts_sync_primary_status}    coam.get_bts_sync_source_status    connection=GNB_OAM
    FOR    ${item}    IN RANGE    len(@{bts_sync_primary_status['syncSourceInfo']})
        run keyword and continue on failure    should be true
        ...    '${bts_sync_primary_status['syncSourceInfo'][${item}]['status']['availability']}'=='Available'
        run keyword and continue on failure    should be true
        ...    '${bts_sync_primary_status['syncSourceInfo'][${item}]['status']['usability']}'=='Usable'
    END
    ${active_sync}    Set Variable If    '${bts_sync_primary_status['syncSourceInfo'][0]['isActive']}'=='True'
    ...    ${bts_sync_primary_status['syncSourceInfo'][0]}    ${bts_sync_primary_status['syncSourceInfo'][1]}
    ${passive_sync}    Set Variable If    '${bts_sync_primary_status['syncSourceInfo'][0]['isActive']}'=='False'
    ...    ${bts_sync_primary_status['syncSourceInfo'][0]}    ${bts_sync_primary_status['syncSourceInfo'][1]}
    should be true    '${active_sync['syncInputType']}'!='${passive_sync['syncInputType']}'    msg=syncsource should not same, please check
    [Teardown]   Run Keyword And Ignore Error   coam.teardown    connection=GNB_OAM
    [Return]  ${active_sync}    ${passive_sync}

Syncsource status check in gnb
    [Arguments]    ${connection}=GNB_OAM
    Connect to gnb coam via ssl
    Wait Until Keyword Succeeds   100s     10s    Verify all cells should be onair
    ${bts_sync_primary_status}    coam.get_bts_sync_source_status    connection=${connection}
    FOR    ${item}    IN RANGE    len(@{bts_sync_primary_status['syncSourceInfo']})
        run keyword and continue on failure    should be true
        ...    '${bts_sync_primary_status['syncSourceInfo'][${item}]['status']['availability']}'=='Available'
        run keyword and continue on failure    should be true
        ...    '${bts_sync_primary_status['syncSourceInfo'][${item}]['status']['usability']}'=='Usable'
    END
    ${result}    ${bts_sync_status}    Run Keyword And Ignore Error    coam.get_bts_sync_source_status
    ...    target=secondary    connection=${connection}
    run keyword if    '${result}'=='PASS'    Secondary syncsource check    bts_sync_status=${bts_sync_status}
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist    file_path=${OUTPUT_DIR}   allowed_faults=${ALLOWED_FAULT}
    Run Keyword And Continue On Failure    Unexpect History Alarm Should Not Exist   file_path=${OUTPUT_DIR}    allowed_faults=${ALLOWED_FAULT}
    [Teardown]   Run Keyword And Ignore Error   coam.teardown    connection=${connection}

Syncsource status check in gnb after sync switch
    [Arguments]    ${connection}=GNB_OAM
    ${status}    Run Keyword And Return Status    Topp alarm check
    Connect to gnb coam via ssl
    Wait Until Keyword Succeeds   100s     10s    Verify all cells should be onair
    ${bts_sync_primary_status}    coam.get_bts_sync_source_status    connection=${connection}
    FOR    ${item}    IN RANGE    len(@{bts_sync_primary_status['syncSourceInfo']})
        run keyword and continue on failure    should be true
        ...    '${bts_sync_primary_status['syncSourceInfo'][${item}]['status']['availability']}'=='Available'
        run keyword and continue on failure    should be true
        ...    '${bts_sync_primary_status['syncSourceInfo'][${item}]['status']['usability']}'=='Usable'
    END
    ${result}    ${bts_sync_status}    Run Keyword And Ignore Error    coam.get_bts_sync_source_status
    ...    target=secondary    connection=${connection}
    run keyword if    '${result}'=='PASS'    Secondary syncsource check    bts_sync_status=${bts_sync_status}
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist    file_path=${OUTPUT_DIR}   allowed_faults=${ALLOWED_FAULT}
    Run Keyword And Continue On Failure    Unexpect History Alarm Should Not Exist   file_path=${OUTPUT_DIR}    allowed_faults=${ALLOWED_FAULT}
    [Teardown]   Run Keyword And Ignore Error   coam.teardown    connection=${connection}

start syncsource switch
    [Documentation]    sync switch
    ...  :param  syncInputPrio: change active sync prio to 2 and then change passive sync prio to 1 can switch sync
    [Arguments]    ${active_sync}    ${passive_sync}    ${bts_host}=${eNB_DU_OAM_IP}    ${connection}=GNB_OAM
    Log To Console    Current sync source is ${active_sync['syncInputType']}, need change to ${passive_sync['syncInputType']}
    Connect to gnb coam via ssl    bts_host=${bts_host}
    ${get_managed_objects}    coam.get_managed_objects    class_name=CLOCK_A    connection=${connection}
    ${syncinput}    coam.get_parameters    dist_name=${get_managed_objects[0]['distName']}    pattern=syncInputList    connection=${connection}
    ${act_sync}    Set Variable If    '${syncinput['syncInputList'][0]['syncInputPrio']}'=='${active_sync['syncInputPrio']}'
    ...    ${syncinput['syncInputList'][0]['syncInputType']}    ${syncinput['syncInputList'][1]['syncInputType']}
    run keyword and continue on failure    should be true    '${active_sync['syncInputType']}'=='${act_sync}'
    ${prio1}    Create Dictionary    syncInputPrio=1    syncInputType=${passive_sync['syncInputType']}
    ${prio2}    Create Dictionary    syncInputPrio=2    syncInputType=${active_sync['syncInputType']}
    ${sync_switch}    Create List    ${prio1}    ${prio2}
    coam.Perform Parameter Recommissioning    dist_name=MRBTS-${enb_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1   parameter=syncInputList
    ...   value=${sync_switch}
    ...    operation=update    skip_parameter_relation_errors=${True}    should_activate=${True}    connection=${connection}
    sleep    30s
    ${bts_sync_primary_status}    coam.get_bts_sync_source_status    connection=GNB_OAM
    FOR    ${item}    IN RANGE    len(@{bts_sync_primary_status['syncSourceInfo']})
        run keyword and continue on failure    should be true
        ...    '${bts_sync_primary_status['syncSourceInfo'][${item}]['status']['availability']}'=='Available'
        run keyword and continue on failure    should be true
        ...    '${bts_sync_primary_status['syncSourceInfo'][${item}]['status']['usability']}'=='Usable'
        run keyword if    '${bts_sync_primary_status['syncSourceInfo'][${item}]['syncInputType']}'=='${passive_sync['syncInputType']}'
        ...    should be true    '${bts_sync_primary_status['syncSourceInfo'][${item}]['isActive']}'=='True'
    END
    should be true    '${active_sync['syncInputType']}'!='${passive_sync['syncInputType']}'    msg=syncsource should not same, please check
    sleep    30s
    Run Keyword And Ignore Error    Unexpect Alarm Should Not Exist    file_path=${OUTPUT_DIR}   allowed_faults=${ALLOWED_FAULT}
    Run Keyword And Ignore Error    Unexpect History Alarm Should Not Exist   file_path=${OUTPUT_DIR}    allowed_faults=${ALLOWED_FAULT}
    [Teardown]   Run Keyword And Ignore Error   coam.teardown    connection=GNB_OAM

Topp alarm check
    [Documentation]    4452 alram check, after sync, 5g will reprot 4452 and then clear
    ...  :param  syncInputPrio: change active sync prio to 2 and then change passive sync prio to 1 can switch sync
    [Arguments]    ${alarm}=4452    ${timeout1}=900    ${timeout2}=900    ${connection}=GNB_OAM
    Connect to gnb coam via ssl
    Log To Console    Wait For Fault 4452
    ${result1}    Run Keyword And Return Status    Wait For Expect Fault Present  faultId=${alarm}   timeout=${timeout1}
    Log To Console    Wait For Fault 4452 Disappear
    ${result2}    Run Keyword And Return Status    Wait For Expect Fault To Disappear  faultId=${alarm}   timeout=${timeout2}
    run keyword if    '${result2}'!='${True}'    coam.reset_site    connection=${connection}
    Wait Until Keyword Succeeds   600s     10s    Verify all cells should be onair
    [Teardown]   Run Keyword And Ignore Error   coam.teardown    connection=${connection}
    [Return]  ${result1}    ${result2}

teardown with sync failed
    [Arguments]    ${timeout1}=300    ${connection}=GNB_OAM
    Connect to gnb coam via ssl
    ${result1}    Run Keyword And Return Status    Wait For Expect Fault Present  faultId=4452   timeout=${timeout1}
    run keyword if    '${result1}'=='${True}'    coam.reset_site    connection=${connection}
    Wait Until Keyword Succeeds   600s     10s    Verify all cells should be onair
    [Teardown]   Run Keyword And Ignore Error   coam.teardown    connection=${connection}

ue attach verify
    [Documentation]    only check ue can be attach
    Log To Console    check ue can be attach
    [Arguments]    ${ue_index}=0    ${ue_type}=${tl.ues[${ue_index}].capabilities[-1]}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    Log To Console    UE Attach
    ${5Grach_ed_0}    power_ue.UE Attach    ue_type=${ue_type}    attach_mode=5G_SA    ue_index=${ue_index}
    Log To Console    Verify attach
    power_ue.Verify attach    ue_type=${ue_type}    ue_index=${ue_index}    5Grach_ed=${5Grach_ed_0}    4G_check=False

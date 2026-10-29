*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/coam_check_status.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/simple_keyword.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot

*** Keywords ***
Genaral_SiSo_MAA_radio_Pipe_failure_alarm_handling_validation_dualband
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] Purpose of this case is to trigger fault 2922 under some pipe broken scenario for SRM7 RU
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 25.05.2025 - - Created https://jiradc.ext.net.nokia.com/browse/LEOPARD-2322
    ...    *******************
    ...    Owner_shifu.lang@nokia-sbell.com
    [Arguments]  ${ru_index}=1    ${ru_alias}=RU_${ru_index}    ${connection}=GNB_OAM
    log to console   \nPerform site reset to clear history alarms which raised by previous cases
    Perform BTS Site Reset
    sleep    5m
    COAM Wait gnb And Cells ready    timeout=20 min
    log to console   \n Connect to RU
    Connect to Common Unit Master
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=${ru_alias}    asik_alias=ASIK Master
    # https://jiradc.ext.net.nokia.com/browse/LEOPARD-2521
    log to console    \n Trigger the number of suppression levels "PR824112"
     ${minor_mars_core_list}    Create List    1    3
    ${minor_pipe_index_list}    create list    1    2
    Trigger Pipe Failure By Dapd Command    ru_index=${ru_index}    ru_alias=${ru_alias}
    ...    core_id_list=${minor_mars_core_list}    pipe_index_list=${minor_pipe_index_list}
    sleep    3m
    log to console   \n Check Fault 2922 Appear On WebEM. Fault should not be raised
    FOR    ${interval}    IN RANGE    1    7    # 1 to 6 intervals (5 mins each, total 30 mins)
        Log To Console    Monitoring progress: ${interval}/6 - Checking alarm 2922 every 5 minutes...
        Expect Fault Should Absent    faultId=2922
        IF    ${interval} < 6    Sleep    5m    # No need to wait after the last check
    END
    Log To Console    ✓ 30 minutes (checked every 5 mins) continuous monitoring completed, alarm 2922 did not appear

    log to console    \n Trigger Fault 2922 with "Minor"
    ${minor_mars_core_list}    Create List    1    3
    ${minor_pipe_index_list}    create list    3    4
    Trigger Pipe Failure By Dapd Command    ru_index=${ru_index}    ru_alias=${ru_alias}
    ...    core_id_list=${minor_mars_core_list}    pipe_index_list=${minor_pipe_index_list}
    sleep    3m
    log to console   \n Check Fault 2922 Appear On WebEM. Alarm Severity is "Minor"
    ${minor_supplementary_info}    Set Variable    *has 4 TX degraded pipe(s) in Band *, has 4 TX degraded pipe(s) in Band *
    Wait until keyword succeeds    30min    60s    Expect Fault Should Present    faultId=2922
    ...    severity=Minor    configObjectName=RMOD-${ru_index}    supplementary=${minor_supplementary_info}

    log to console    \n Trigger Fault 2922 with "Major"
    ${major_mars_core_list}    Create List    3
    ${major_pipe_index_list}    create list    5
    Trigger Pipe Failure By Dapd Command    ru_index=${ru_index}    ru_alias=${ru_alias}
    ...    core_id_list=${major_mars_core_list}    pipe_index_list=${major_pipe_index_list}
    sleep    3m
    log to console   \n Check Fault 2922 Appear On WebEM. Alarm Severity is "Major" and cell "degraded"
    ${major_supplementary_info}    Set Variable    *has 4 TX degraded pipe(s) in Band *, has 5 TX degraded pipe(s) in Band *
    Wait until keyword succeeds    30min    60s    Expect Fault Should Present    faultId=2922
    ...    severity=Major    configObjectName=RMOD-${ru_index}    supplementary=${major_supplementary_info}
    # 20251021, BTSID CHANGE CAUSE THE CELL list update.
    ${band_1_cell_list}    Create List    ${141}    ${143}
    ${band_2_cell_list}    Create List    ${142}    ${144}
    Cell Status Should Be Onair    cell_list=${band_1_cell_list}
    Cell status Should Be Degraded    cell_list=${band_2_cell_list}
    log to console    \n Recover Fault 2922 by RU reset
    Perform RU Reset    download_dir=${SAVE LOG DIRECTORY}
    sleep    5m
    log to console    \n Check Fault 2922 Disappear On WebEM and cell onair
    coam wait gnb and cells ready    timeout=10min
    Wait until keyword succeeds    10min    30s    Expect Fault Should Absent    faultId=2922
    log to console    \nCheck Unexpected Alarm
    run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
    Connect to gnb coam via ssl    connection=${connection}
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    ...    connection=${connection}
    should be true    ${alarm_status}
    &{fault_2922}     Create Dictionary     faultId=${2922}
    ${ALLOWED_HISTORY_FAULT}   Create List   @{ALLOWED_HISTORY_FAULT}   ${fault_2922}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    connection=${connection}
    should be true    ${history_alarm_status}

Trigger Pipe Failure By Dapd Command
    [Arguments]  ${ru_index}  ${ru_alias}    ${core_id_list}  ${pipe_index_list}
    ...    ${ru_username}=${tl.gnbs[0].dus[0].rus[${ru_index}-1].default_ssh_connection_details.username}
    ...    ${ru_password}=${tl.gnbs[0].dus[0].rus[${ru_index}-1].default_ssh_connection_details.password}
    FOR    ${core_id}    IN    @{core_id_list}
        ${core_ip}    Set Variable    192.168.101.${core_id}
        ${core_alias}    Set Variable    core_${core_id}
        csn.Connect to   hostname=${core_ip}   username=${ru_username}   password=${ru_password}   proxy=${ru_alias}   alias=${core_alias}
        FOR  ${pipe_index}  IN  @{pipe_index_list}
        # https://jiradc.ext.net.nokia.com/browse/WESTLAKE-13277 add workaround for dapd usage.
            ${output}    Execute Command With RU rfsw Account    ru_alias=${core_alias}    cmd=source /etc/profile&&dapd-app -dg ${pipe_index} 0 -100
            Should Match Regexp    ${output}    PostCombGain\\s+=\\s+\\-inf\\s+\\[dB\\]
        END
    END

Cell Status Should Be Onair
    [Arguments]   ${cell_list}    ${cell_type}=nr  ${connection}=GNB_OAM
    Log to console    Verify the cell in [${cell_list}] are on air
    ${administrative_expected}    Set Variable If   '${cell_type}'=='nr'    Unlocked    unlocked
    ${cells_info}   coam.get_cells_info  cell_type=${cell_type}    timeout=20    connection=${connection}
    FOR    ${cell}    IN    @{cells_info}
        ${cell_id}    Set Variable    ${cell['globalCellId']}
        IF    ${{$cell_id not in $cell_list}}    CONTINUE
        Run keyword and continue on failure    Should Be Equal As Strings    ${cell['status']['administrativeState']}
        ...      ${administrative_expected}
        Run keyword and continue on failure    Should Be Equal As Strings    ${cell['status']['operationalState']}    enabled
        Run keyword and continue on failure    Dictionary Should Not Contain Key    ${cell['status']}     availabilityStatus
        ...   msg=Cell-${cell['physicalCellId']}'s availabilityStatus present, means cell is disable or degraded, please check.
    END

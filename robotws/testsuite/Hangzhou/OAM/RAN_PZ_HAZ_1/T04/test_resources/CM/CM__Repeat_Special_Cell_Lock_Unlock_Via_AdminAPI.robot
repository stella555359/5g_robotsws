*** Settings ***
Documentation       Test case for
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${REPEAT_TIME}    2
@{Lock_Cells}     NRCELL-4      NRCELL-5
@{Related_RMODs}    RMOD-11    RMOD-12

*** Keywords ***
CM__Repeat_Special_Cell_Lock_Unlock_Via_AdminAPI
    [Documentation]    [CASE MRT]: CM__Repeat_Special_Cell_Lock_Unlock_Via_AdminAPI
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    This case is for Top50 SBTS1906 customer pronto:04067914
    ...    Repeat to Lock/Unlock the Speical cells which is have configed sleep cell, so related rmod power state be SLEEP or AWAKE
    ...    and after lock/unlock need check syslog if have "ERR/ctrlNrCommon" fail case and collect snapshot.
    ...    Locked/Unlocked through ADMIN API
    ...
    ...    The main steps performed for the test are:
    ...    . Repeat Lock Unlock Selected NRCELL
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 08.30.2024 - Xu Yuyan - New case

    Set Tags    CM    AUTHOR-yuyan.xu@nokia-sbell.com     OWNER-I_NSB_MN_RAN_RD_VRF_HAZ1_8_GMS@internal.nsn.com
    Log To Console    ${TEST_NAME} start.
    Step 1: Repeat Lock Unlock Selected NRCELL


SetUp
    Common Test Setup SBTS    scf_check=${FALSE}
    ${mrbts_id}    Fetch From Right    ${MRBTS_DN}    /
    Set Test Variable    ${mrbts_id}
    ${cell_list}    coam.Get Cell List
    ${nr_cell_list}    Set Variable    ${cell_list['cells']['nr']}
    ${Lock_CellsID_Config}    Create List
    ${Lock_CellsID_Internal}    Create List
    FOR    ${cell}    IN    @{nr_cell_list}
        ${is_test_cell}    Run Keyword And Return Status
        ...    List Should Contain Value    ${Lock_Cells}    ${cell['id']['configuration'].split("/")[-1]}
        Run Keyword If    ${is_test_cell}    Append To List    ${Lock_CellsID_Config}    ${cell['id']['configuration']}
        Run Keyword If    ${is_test_cell}    Append To List    ${Lock_CellsID_Internal}    ${cell['id']['internal']}
    END
    Set Test Variable    ${Lock_CellsID_Config}
    Set Test Variable    ${Lock_CellsID_Internal}
    ${btsInfo}    coam.Get Bts Info
    Set Test Variable    ${rmod_list}     ${btsInfo['radioModules']['rmod']}
    log    ${rmod_list}
    ${Related_RMODID_Config}    Create List
    ${Related_RMODID_Internal}    Create List
    FOR    ${rmod}    IN    @{rmod_list}
        ${is_test_rmod}    Run Keyword And Return Status
        ...    List Should Contain Value    ${Related_RMODs}    ${rmod['id']['configuration'].split("/")[-1]}
        Run Keyword If    ${is_test_rmod}    Append To List    ${Related_RMODID_Config}    ${rmod['id']['configuration']}
        Run Keyword If    ${is_test_rmod}    Append To List    ${Related_RMODID_Internal}    ${rmod['id']['internal']}
    END
    Set Test Variable    ${Related_RMODID_Config}
    Set Test Variable    ${Related_RMODID_Internal}

Step ${index}: Repeat Lock Unlock Selected NRCELL
    ${REPEAT_TIME}    Evaluate    int(${REPEAT_TIME})
    ${failed_loops}    Create List
    FOR    ${index}    IN RANGE    1    ${REPEAT_TIME+1}
        Restart Infomodel And Syslog
        Set Test Variable    ${current_loop_index}    ${index}
        ${lock_oper_status}    Run Keyword And Return Status    Lock Cells     #Lock Selected NRCELL From Admin
        Run Keyword If    not ${lock_oper_status}    Run Keywords    Log    Lock NRCELL Failed at Loop${current_loop_index}
        ...    console=${True}
        ...    AND    Append To List    ${failed_loops}    ${current_loop_index}
        ...    AND    SBTS Recovery
        ...    AND    Continue For Loop
        ${unlock_oper_status}    Run Keyword And Return Status    Unlock Cells    #Unlock Selected NRCELL From Admin
        Collect Syslog For SMOD1 on Repeat ${index}
        Check Error Message Not Existed On Syslog    ${UDP Logs}/SMOD1_UDP_Repeat${index}
        Run Keyword If    not ${unlock_oper_status}    Run Keywords    Log    Unlock NRCELL Failed at Loop${current_loop_index}
        ...    console=${True}    #level=ERROR
        ...    AND    Append To List    ${failed_loops}    ${current_loop_index}
        SBTS Recovery
        ${need_restart}    Evaluate    ${index}/${70}>1 or ${index}/${70}==1
        Run Keyword If     ${need_restart}    Restart Admin
    END
    Log To Console    Repeat Lock Unlock NRCELL failed at loop @{failed_loops}!

Collect Syslog For SMOD1 on Repeat ${repeatTime}
    Log To Console   Collect Syslog For SMOD1 on Repeat${repeatTime}
    ${timestamp}    Generate Formatted Timestamp
    ${syslog_collected}=  Run keyword And Return Status  Collect syslog results  alias=SMOD1
    ...  destination=${UDP Logs}/SMOD1_UDP_Repeat${repeatTime}  unzip=true
    Run keyword if  ${syslog_collected}  Log  SMOD1 syslog collected to 'UDP Logs'    level=INFO      console=${TRUE}
    ...  ELSE  Log  SMOD1 syslog collection failed      level=ERROR    console=${TRUE}

Check Error Message Not Existed On Syslog
    [Arguments]        ${btslog_path}
    Log To Console    Check Syslog
    ${result}    ${output}    OperatingSystem.Run And Return Rc And Output    ls -l ${btslog_path}/SMOD1_UDP*
    ${files}    Split To Lines    ${output}
    FOR    ${file}    IN    @{files}
        ${file_prop}    Split String    ${file}
        ${result}    ${output}    OperatingSystem.Run And Return Rc And Output
        ...    cat ${file_prop[8]} | grep "ERR/ctrlNrCommon"
        should be empty    ${output}
    END

Lock Cells
    Log To Console    Lock Cells
    coam.Create Delta
    FOR    ${cell}    IN    @{Lock_CellsID_Config}
        coam.Append Parameter Update To Delta    dist_name=${cell}    parameter=administrativeState    value=Locked
    END
    ${json}    coam.Get Delta
    coam.Perform Delta Recommissioning    ${json}
    FOR    ${cell}    IN    @{Lock_CellsID_Internal}
        ${lockedCell_status}    Set Variable
        ...    operationalState=disabled, availabilityStatus="off line", administrativeState=Locked, blockingState=Unblocked
        Wait Until Keyword Succeeds    20min    30s    coam.Assert    NRCEL    ${cell}    ${lockedCell_status}    timeout=45s
    END
    Wait Until Keyword Succeeds    20min    30s    Check RMOD    Lock

Unlock Cells
    Log To Console    Unlock Cells
    coam.Create Delta
    FOR    ${cell}    IN    @{Lock_CellsID_Config}
        coam.Append Parameter Update To Delta    dist_name=${cell}    parameter=administrativeState    value=Unlocked
    END
    ${json}    coam.Get Delta
    coam.Perform Delta Recommissioning    ${json}
    FOR    ${cell}    IN    @{Lock_CellsID_Internal}
        ${unlockedCell_status}    Set Variable
        ...    operationalState=enabled, administrativeState=Unlocked, blockingState=Unblocked
        Wait Until Keyword Succeeds    20min    30s    coam.Assert    NRCEL    ${cell}    ${unlockedCell_status}    timeout=45s
    END
    Wait Until Keyword Succeeds    20min    30s    Check RMOD    Unlock

Check RMOD
    [Arguments]    ${operate}
    ${btsInfo}    coam.Get Bts Info
    ${rmod_list}     Set Variable    ${btsInfo['radioModules']['rmod']}
    FOR    ${rmod}    IN    @{rmod_list}
        ${tmp1}    Set Variable    "${rmod['status']['powerState']}"=="SLEEP" and "${rmod['status']['operationalState']}"=="enabled"
        ${tmp2}    Set Variable    and "${rmod['status']['administrativeState']}"=="Unlocked"
        ${condition1}    Set Variable   ${tmp1} ${tmp2}
        ${tmp3}    Set Variable    "${rmod['status']['powerState']}"=="AWAKE" and "${rmod['status']['operationalState']}"=="enabled"
        ${tmp4}    Set Variable    and "${rmod['status']['administrativeState']}"=="Unlocked"
        ${condition2}    Set Variable    ${tmp3} ${tmp4}
        ${condition}    Set Variable If    "${operate}"=="Lock"    ${condition1}    ${condition2}
        ${is_test_rmod}    Run Keyword And Return Status
        ...    List Should Contain Value    ${Related_RMODs}    ${rmod['id']['configuration'].split("/")[-1]}
        Run Keyword If    ${is_test_rmod}    Should Be True    ${condition}
    END
    Sleep    30s

SBTS Recovery
    Log To Console    SBTS Recovery
    ${status}    Run Keyword And Return Status    coam.Assert Every    NRCEL    administrativeState=${_Com_Unlocked_}
    Run Keyword If    not ${status}    Unlock Cells
    ${status}    Run Keyword And Return Status    coam.Assert Any    NRCEL   administrativeState=${_Com_Locked_}
    Run Keyword If    ${status}     Run Keywords    Log    Will perform full commissioning with backup scf!    level=WARN
    ...    AND    coam.perform_commissioning    bts_id=${mrbts_id}    scf_file=${BTS_scf_initial}
    ...    skip_parameter_relation_errors=True    timeout=600
    Wait Until Keyword Succeeds    20 min    30 sec    Check_SBTS_SMOD_RMOD_Cells_Alarms

Restart Infomodel And Syslog
    Run Keyword And Continue On Failure    Teardown All Aliases For Syslog
    Run Keyword And Continue On Failure    Wait Until Keyword Succeeds    3x    60s    Start syslog on SMOD1

Restart Admin
   Run Keyword And Continue On Failure    coam.Teardown All Aliases For Admin
   Run Keyword And Continue On Failure    Start Admin    bts_host=${SMOD1['TRS_IP']}


CaseTearDown
    Log To Console    CaseTearDown
    Run Keyword If Test Failed    Admin Get Snapshot
    Run Keyword If  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Log  Initial verification of BTS states was not completed due to timeout, or some unit indicates a faulty state    level=WARN
    Teardown All Aliases For Syslog
    Teardown All Aliases For Infomodel
    coam.Teardown All Aliases For Admin
    Collect Swconfigs
    Collect RawAlarmHistory
    hran_general.Hran_ta Postconditions
    Run keyword if  'STOPONFAIL' in @{TEST TAGS} and '${TEST STATUS}' == 'FAIL'
    ...    Fatal error  Execution stopped because critical TC '${TEST NAME}' failed
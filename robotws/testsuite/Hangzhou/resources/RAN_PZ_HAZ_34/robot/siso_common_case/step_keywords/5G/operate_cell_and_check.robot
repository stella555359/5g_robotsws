*** Settings ***
Documentation    This is common keywords for siso RRH related cases
...              Please do not modify the file without notification to author
...              Author: tingting.zhong
...              Contact: tingting.zhong@nokia-sbell.com
...              Squard: HZ SG4

Library       taf.selenium.sbts    WITH NAME    selenium_coam
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/basic/simple_ue.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/btslog_check.robot

*** Keywords ***
Lock and Unlock Cells or Groups and L3
    [Documentation]  Owner_tingting.zhong@nokia-sbell.com
    [Arguments]  ${lock_list}  ${is_group}=${True}  ${with_call}=${False}  ${with_peak}=${False}    ${4G_check}=${False}
    ${lock_num}    get length  ${lock_list}
    FOR  ${lock_id}  IN  @{lock_list}
        ${check_alarm}  set variable if  ${lock_num}==1  ${True}  ${False}
        ${other_cells}  Get Other Ids    id_list=${lock_list}    given_id=${lock_id}
        ${check_cell}  create list  ${lock_id}
        ${operate_list}    set variable if  ${lock_num}==1  ${check_cell}  ${other_cells}
        ${cell_list}    run keyword if  ${is_group}    Get Cell From Cell Group  cellgrp_id=${lock_id}
        ...    ELSE   set variable  ${check_cell}
        Lock cells or groups and check status  lock_list=${operate_list}  is_group=${is_group}  check_alarm=${check_alarm}
        ...    gnb_type='${gNb_CuType}'
        run keyword if  ${lock_num}!=1 and ${with_call}
        ...    Get UE From Init File and Make call    cell_list=${cell_list}  with_peak=${with_peak}    4G_check=${4G_check}
        Unlock cells or groups and check status  lock_list=${operate_list}  is_group=${is_group}  check_alarm=${check_alarm}
        ...    gnb_type='${gNb_CuType}'
        run keyword if  ${lock_num}==1 and ${with_call}
        ...    Get UE From Init File and Make call    cell_list=${cell_list}  with_peak=${with_peak}    4G_check=${4G_check}
    END

Lock cells or groups and check status
    [Documentation]  Owner_tingting.zhong@nokia-sbell.com
    [Arguments]  ${lock_list}  ${is_group}=${True}  ${check_alarm}=${True}    ${gnb_type}='NSA'    ${connection}=GNB_OAM
    ${output}   set variable if      ${is_group}==${False}    NRCELL-    NRCELLGRP-
    connect to gnb coam via ssl    connection=${connection}
    FOR    ${idx}  IN  @{lock_list}
        log to console  \n***Lock ${output}${idx} and check status***
        run keyword if    ${is_group}==${True}
        ...    perform_cell_group_lock_via_admin   cellgrp_id=${idx}    connection=${connection}    lock_timeout=120
        ...    ELSE
        ...    perform_cell_lock_via_admin    cell_id=${idx}    connection=${connection}    lock_timeout=120
        run keyword if    ${is_group}==${True}
        ...    Wait Until Keyword Succeeds   5 min  5 sec    Check cells under group should be locked   cell_group_idx=${idx}
        ...    connection=${connection}
        ...    ELSE
        ...    Wait Until Keyword Succeeds   5 min  5 sec   Check cell should be locked   cell_id=${idx}
    END
    ${sleep_time}       Evaluate    ${X2_link_shutdown_time}-1
    run keyword if  ${check_alarm}==${True} and ${gNB_type}=='NSA'
    ...    run keywords  sleep    ${sleep_time}min   AND
    ...    Expect Fault Should Absent    faultId=7300   AND
    ...    Expect Fault Should Absent    faultId=7319   AND
    ...    Wait For Expect Fault Present  faultId=7300   timeout=180   AND
    ...    Wait For Expect Fault Present  faultId=7319   timeout=180

Unlock cells or groups and check status
    [Documentation]  Owner_tingting.zhong@nokia-sbell.com
    [Arguments]  ${lock_list}  ${is_group}=${True}  ${check_alarm}=${True}    ${gnb_type}='NSA'    ${connection}=GNB_OAM
    ${output}   set variable if      ${is_group}==${False}    NRCELL-    NRCELLGRP-
    ${status}    run keyword and return status    variable should not exist    ${check_ru_details}
    ${check_ru_details}    run keyword if    ${status}    create dictionary
    ...    ELSE    set variable    ${check_ru_details}
    set test variable    ${check_ru_details}
    connect to gnb coam via ssl    connection=${connection}
    FOR    ${idx}  IN  @{lock_list}
        log to console  \n***unLock ${output}${idx} and check status***
        ${cell_list}    run keyword if    ${is_group}==${True}    Get Cell From Cell Group    cellgrp_id=${idx}
        ${cell_id}    set variable if    ${is_group}==${True}    ${cell_list[0]}    ${idx}
        ${ru_index}    get ru index from cell id via admin    cell_id=${cell_id}
        ${status}    run keyword and return status    RU Status Info Should Be as Expect    ru_index=${ru_index}    powerState=SLEEP
        ${ru_detail}    create dictionary    allowed_reset=${status}
        set to dictionary    ${check_ru_details}    ${ru_index}=${ru_detail}
        run keyword if    ${is_group}==${True}
        ...    perform_cell_group_unlock_via_admin  cellgrp_id=${idx}    connection=${connection}    lock_timeout=120
        ...    ELSE
        ...    perform_cell_unlock_via_admin    cell_id=${idx}    connection=${connection}    lock_timeout=120
        sleep  30
        Run Keyword If  ${check_ru_details['${ru_index}']['allowed_reset']}
        ...    Wait until keyword succeeds    10min    10sec    RU Should Be Online    ru_index=${ru_index}    connection=${connection}
        run keyword if    ${is_group}==${True}
        ...    Wait Until Keyword Succeeds   5 min  5 sec    Check cells under group should be unlocked   cell_group_idx=${idx}
        ...    connection=${connection}
        ...    ELSE
        ...    Wait Until Keyword Succeeds   5 min  5 sec   Check cell should be unlocked   cell_id=${idx}    connection=${connection}
    END
    run keyword if  ${check_alarm}==${True} and ${gNB_type}=='NSA'
    ...    run keywords  Wait For Expect Fault To Disappear  faultId=7300   timeout=600   AND
    ...    Wait For Expect Fault To Disappear  faultId=7319   timeout=300
    Wait Until Keyword Succeeds    30min    30s    Verify all cells should be onair

Lock and Unlock all Cells or Groups
    [Documentation]  Owner_tingting.zhong@nokia-sbell.com
    [Arguments]  ${lock_list}  ${is_group}=${True}
    ${output}   set variable if      ${is_group}==${False}   all cells    all cell groups
    log to console  \n***Lock ${output} and check status***
    Lock cells or groups and check status  lock_list=${lock_list}  is_group=${is_group}  check_alarm=${True}  gnb_type='${gNb_CuType}'
    log to console  \n***unLock ${output} and check status***
    Unlock cells or groups and check status  lock_list=${lock_list}  is_group=${is_group}  check_alarm=${True}  gnb_type='${gNb_CuType}'

Block and UnBlock Cells
    [Documentation]  Owner_tingting.zhong@nokia-sbell.com
    [Arguments]  ${block_list}   ${technology}=NR
    Block cells and check status    block_list=${block_list}   check_alarm=${True}
    ...     technology=${technology}  gnb_type='${gNb_CuType}'
    #WA for RU entering DEESLEEP MODE with all cells blocked; aims to avoid misoperation during RU powerState state from 'AWAKE' to 'SLEEP'
    log to console  \n***sleep 5 min for RU entering DEESLEEP MODE***
    Sleep   5min
    UnBlock Cells and check status   block_list=${block_list}   check_alarm=${True}
    ...     technology=${technology}  gnb_type='${gNb_CuType}'

Block cells and check status
    [Documentation]  Owner_tingting.zhong@nokia-sbell.com
    [Arguments]  ${block_list}   ${check_alarm}=${True}   ${technology}=NR   ${gnb_type}='NSA'    ${connection}=GNB_OAM     ${timeout}=120
    connect to gnb coam via ssl    connection=${connection}
    log to console  \n***Block cells and check status***
    FOR    ${idx}  IN  @{block_list}
        log to console  \nBlock Global cell ID : ${idx} for ${technology} and check status
        selenium_coam.block_cell    cell_idx=${idx}    technology=${technology}    timeout=${timeout}
        Wait Until Keyword Succeeds   3 min  10 sec   check single cell should be blocked   cell_idx=${idx}   cell_type=${technology.lower()}
        Wait For Expect Fault Present    faultId=49    timeout=30
    END
    ${sleep_time}       Evaluate    ${X2_link_shutdown_time}-1
    run keyword if  ${check_alarm}==${True} and ${gNB_type}=='NSA'
    ...    run keywords  sleep    ${sleep_time}min   AND
    ...    Wait For Expect Fault Present  faultId=7300   timeout=180   AND
    ...    Wait For Expect Fault Present  faultId=7319   timeout=180

UnBlock Cells and check status
    [Documentation]  Owner_tingting.zhong@nokia-sbell.com
    [Arguments]  ${block_list}  ${check_alarm}=${True}   ${technology}=NR   ${gnb_type}='NSA'  ${timeout}=60
    ...    ${connection}=GNB_OAM    ${skip_deepsleep}=${False}
    ${check_ru_details}    create dictionary
    set test variable    ${check_ru_details}
    connect to gnb coam via ssl    connection=${connection}
    log to console  \n***unblock cells and check status***
    FOR    ${idx}  IN  @{block_list}
        log to console  \nunBlock Global cell ID : ${idx} for ${technology} and check status
        ${ru_index}    get ru index from cell id via admin    cell_id=${idx}    technology=${technology}
        ${ru_index_cell_list}    ${nr_lte_concurrent}    Get All Cell Id From RU    ru_index=${ru_index}
        IF    ${{set($ru_index_cell_list).issubset(set($block_list))}} and not ${nr_lte_concurrent} and not ${skip_deepsleep}
            # REX-21512 WA for RU entering DEESLEEP MODE with all cells blocked
            ${check_deepsleep}    set variable    ${True}
        ELSE
            ${check_deepsleep}    set variable    ${False}
        END
        ${ru_index_dict}    create dictionary
        IF    '${ru_index}'!='${None}'
            ${key_status}=  Run Keyword And Return Status  Dictionary Should Contain Key    dictionary=${check_ru_details}    key=${ru_index}
            IF    not ${key_status}    set to dictionary    dictionary=${check_ru_details}   ${ru_index}=${ru_index_dict}

            ${check_deepsleep_status}=  Run Keyword And Return Status  Dictionary Should Contain Key
            ...    dictionary=${check_ru_details['${ru_index}']}    key=check_deepsleep
            IF  not ${check_deepsleep_status}  set to dictionary  dictionary=${check_ru_details['${ru_index}']}  check_deepsleep=${check_deepsleep}

            ${unsupported_dsm_ru}    run keyword and return status    RU Status Info Should Be as Expect
            ...    ru_index=${ru_index}    powerState=UNAVAILABLE
            IF    ${unsupported_dsm_ru}
                ${status}    Set Variable    ${False}
                BuiltIn.Log    message=DEEPSLEEP mode is not supported for RU ${ru_index}, skip the reset check
            ELSE IF    ${check_ru_details['${ru_index}']['check_deepsleep']}
                ${status}    run keyword and return status    Wait Until Keyword Succeeds    5min    30s    RU Status Info Should Be as Expect
                ...    ru_index=${ru_index}    powerState=SLEEP
                IF    '${status}'=='${False}'    Fail    msg=RU ${ru_index} enter DEEPSLEEP mode failed after block all cells more than 10 minutes
                set to dictionary    dictionary=${check_ru_details['${ru_index}']}    check_deepsleep=${False}
            ELSE
                ${status}    run keyword and return status    RU Status Info Should Be as Expect    ru_index=${ru_index}    powerState=SLEEP
            END
            set to dictionary    ${check_ru_details['${ru_index}']}    allowed_reset=${status}
        END

        selenium_coam.unblock_cell    cell_idx=${idx}  timeout=${timeout}  technology=${technology}
        ${check_ru}    set variable if    '${ru_index}'!='${None}'    ${check_ru_details['${ru_index}']['allowed_reset']}    ${False}
        Run Keyword If    ${check_ru}    run keywords
        ...    wait until keyword succeeds    4min     10sec    RU Should Be Offline   ru_index=${ru_index}    connection=${connection}    AND
        ...    Wait until keyword succeeds    10min    10sec    RU Should Be Online    ru_index=${ru_index}    connection=${connection}
		${check_start_time}    Run Keyword If    ${check_ru}    Btslog Get Check Start time
        Run Keyword If    '${check_start_time}'!='${None}'    run keyword and continue on failure
        ...    Btslog Check RU Reset no More than Once    check_start_time=${check_start_time}    ru_index=${ru_index}
        Wait Until Keyword Succeeds   7 min  10 sec   check single cell should be unblocked   cell_idx=${idx}   cell_type=${technology.lower()}
    END
    Wait For Expect Fault To Disappear  faultId=49    timeout=60
    run keyword if  ${check_alarm}==${True} and ${gNB_type}=='NSA'
    ...    run keywords  Wait For Expect Fault To Disappear  faultId=7300   timeout=600   AND
    ...    Wait For Expect Fault To Disappear  faultId=7319   timeout=300
    Wait Until Keyword Succeeds    10min    30s    Check all cells info should be onair

Block and UnBlock Cells and L3call
    [Arguments]  ${block_list}   ${technology}=NR   ${with_call}=${False}  ${with_peak}=${False}
    ...  ${call_keyword}=Get UE From Init File and Make call
    ${block_num}    get length  ${block_list}
    FOR  ${block_id}  IN  @{block_list}
        ${check_alarm}  set variable if  ${block_num}==1 and '${technology}'=='NR'  ${True}  ${False}
        ${other_cells}  Get Other Ids    id_list=${block_list}    given_id=${block_id}
        ${check_cell}  create list  ${block_id}
        ${operate_list}    set variable if  ${block_num}==1  ${check_cell}  ${other_cells}
        Block cells and check status   block_list=${operate_list}    technology=${technology}
	    ...    check_alarm=${check_alarm}    gnb_type='${gNb_CuType}'
        run keyword if  ${block_num}!=1 and ${with_call} and '${technology}'=='NR'
        ...    Run Keyword And Continue On Failure  ${call_keyword}  cell_list=${check_cell}  with_peak=${with_peak}
        ...    ELSE IF  ${block_num}!=1 and ${with_call} and '${technology}'=='LTE'
        ...    Simple UE L3 Call And Throughput    cell_list=${check_cell}    target_avg_percent=0.5
        ...    log=${SAVE LOG DIRECTORY}    scf_path=${Case_SCF_Path}    allowed_no_ue=${True}
        UnBlock Cells and check status   block_list=${operate_list}    technology=${technology}
	    ...    check_alarm=${check_alarm}    gnb_type='${gNb_CuType}'
        run keyword if  ${block_num}==1 and ${with_call} and '${technology}'=='NR'
        ...    Get UE From Init File and Make call    cell_list=${check_cell}  with_peak=${with_peak}
        ...    ELSE IF  ${block_num}==1 and ${with_call} and '${technology}'=='LTE'
        ...    Simple UE L3 Call And Throughput    cell_list=${check_cell}    target_avg_percent=0.5
        ...    log=${SAVE LOG DIRECTORY}    scf_path=${Case_SCF_Path}    allowed_no_ue=${True}
    END

check single cell should be blocked
    [Arguments]   ${cell_idx}=0   ${cell_type}=nr    ${connection}=GNB_OAM    ${timeout}=20
    Log to console    Check cell ${cell_idx} of ${cell_type} should be blocked
    ${cells_info}   coam.get_cells_info  cell_type=${cell_type}    timeout=${timeout}    connection=${connection}
    FOR    ${cell}    IN    @{cells_info}
        run keyword if  '${cell['globalCellId']}'!='${cell_idx}'    Continue For Loop
        Should Be Equal As Strings    ${cell['status']['operationalState'].lower()}   disabled
        Should Be Equal As Strings    ${cell['status']['administrativeState'].lower()}     unlocked
        Should Be Equal As Strings    ${cell['status']['blockingState'].lower()}   blocked
    END

check single cell should be unblocked
    [Arguments]   ${cell_idx}=0   ${cell_type}=nr    ${connection}=GNB_OAM    ${timeout}=20
    Log to console    Check cell ${cell_idx} of ${cell_type} should be unblocked(onair)
    ${cells_info}   coam.get_cells_info  cell_type=${cell_type}    timeout=${timeout}    connection=${connection}
    FOR    ${cell}    IN    @{cells_info}
        run keyword if  '${cell['globalCellId']}'!='${cell_idx}'    Continue For Loop
        Should Be Equal As Strings    ${cell['status']['operationalState'].lower()}   enabled
        Should Be Equal As Strings    ${cell['status']['administrativeState'].lower()}     unlocked
        Should Be Equal As Strings    ${cell['status']['blockingState'].lower()}   unblocked
    END

*** Settings ***
Documentation    author:Wu Xia
...              contact: n5liu@nokia-sbell.com
...               History: Do some adaption for CB008181 by LiuNing

Resource           ../../CB006443/Resources/CB006443_KW_interface.robot
Variables           ./OAMKPI_CB008181.py

*** Variables ***

*** KeyWords ***
TC.CB008181-C_07_OAM_KPI_16_Cell_Lock_Unclock
    [Documentation]  This KW is for locking one cell and unblocking one cell by cell distname
    [Arguments]    ${KPI16a}=${KPI['CB008181_KPI16']['KPI16a_MAX']}
    ...    ${KPI16b}=${KPI['CB008181_KPI16']['KPI16b_MAX']}
    ...    ${repeat_times}=${KPI['CB008181_KPI16']['lock_cell_times']}
    ...    ${fail_times}=${KPI['CB008181_KPI16']['fail_times']}
    ...    ${Check_Call}=${False}    ${call_loop}=${2}
    ...    ${UE_TYPE}=samsung    ${ue_index}=${0}    ${NR_cell_id}=${15024129}     ${throuthput_ul}=120M
    ...    ${throuthput_dl}=600M       ${exepected_ul_tp}=${95}    ${exepected_dl_tp}=${450}
    ...    ${duration_ul}=300    ${duration_dl}=300
    ${connection}    Connect to DU by ADMIN API
    DU_WebEM.Get NR Cell distname and id
    ${case_status_all}    RUN KEYWORD AND RETURN STATUS     DU_WebEM.lock cell and unlock cell one by one
    ...    cell_id_list=${cell_id_list}    connection=${connection}
    ...    KPI16a=${KPI16a}    KPI16b=${KPI16b}
    ${cellid}    evaluate    random.choice(${cell_id_list})    random
    log to console      ${cellid}
    @{block_case_status}    create list    ${empty}
    FOR    ${i}    IN RANGE    ${repeat_times}
        ${case_status_one}    RUN KEYWORD AND RETURN STATUS      RUN KEYWORD AND CONTINUE ON FAILURE
        ...    DU_WebEM.lock cell and unlock cell
        ...    cell_id=${cellid}     connection=${connection}
        ...    KPI16a=${KPI16a}    KPI16b=${KPI16b}
        ${snapshot_file}    Run Keyword If    '${case_status_one}'=='${False}'
        ...    Run Keyword And Ignore error    WEBUI.Collect snapshot
        ${remainder}    Evaluate    (${i}+1)%${call_loop}
        Run Keyword If    '${case_status_one}'=='${True}' and '${Check_Call}'=='${True}' and '${remainder}'=='${0}'
        ...    RUN KEYWORD AND CONTINUE ON FAILURE    Verify UE send full UDP UL data and full UDP DL data
        ...    UE_TYPE=${UE_TYPE}     ue_index=${ue_index}     NR_cell_id=${NR_cell_id}     throuthput_ul=${throuthput_ul}
        ...    throuthput_dl=${throuthput_dl}    exepected_ul_tp=${exepected_ul_tp}
        ...    exepected_dl_tp=${exepected_dl_tp}    duration_ul=${duration_ul}    duration_dl=${duration_dl}
        RUN KEYWORD IF    '${case_status_one}'=='False'    Append to list    ${block_case_status}    ${case_status_one}
        ${fail_num}    Count Values In List    ${block_case_status}      False
        Exit for loop if    ${fail_num}>=${fail_times}
    END
    [Teardown]    run keywords    RUN KEYWORD IF    '${fail_num}'!='${0}'
    ...    Run Keyword And Ignore error    WEBUI.Collect snapshot
    ...    AND    run keyword and ignore error    DisConnect to DU by ADMIN API
    ...    AND    run keyword and ignore error    TC.teardown



##########start keyword for KW.CB008181-C_07_OAM_KPI_16_Cell_Lock_Unclock#############

DU_WebEM.lock cell and unlock cell
    [Documentation]  This KW is for locking one cell and unblocking one cell by cell distname
    [Arguments]    ${cell_id}    ${connection}
    ...    ${KPI16a}=${KPI['CB008181_KPI16']['KPI16a']}
    ...    ${KPI16b}=${KPI['CB008181_KPI16']['KPI16b']}
    log to console    lock cell start
    ${lock_startTime}    KW.TimerStart
    wait until keyword succeeds   5x   30s    DU_Rest.lock_cell
    ...    dist_name=${cell_id['configuration']}    timeout=60    connection=${connection}

    FOR    ${i}    IN RANGE    ${60}
        ${res}    run keyword and ignore error    DU_WebEM.Check NR Cell status
        ...    cell_internal_id=${cell_id['internal']}
        ...    timeout=30   operational_State=disabled    procedural_Status=initializationrequired
        ...    blockingState=Unlocked    administrative_State=Locked
        Exit For Loop If    '${res[0]}'=='PASS'
    END
    ${lock_duration}     KW.TimerStop    timestart=${lock_startTime}
    [Teardown]    run keyword and ignore error     DU_WebEM.TearDown.unlock one cell
    ...    cell=${cell_id}     connection=${connection}

#####unlock cell start#######
    ${unlock_startTime}    KW.TimerStart
    wait until keyword succeeds   5x   30s    DU_Rest.unlock_cell
    ...    dist_name=${cell_id['configuration']}    timeout=60    connection=${connection}

    FOR    ${i}    IN RANGE    ${60}
        ${res}    run keyword and ignore error    DU_WebEM.Check NR Cell status
        ...    cell_internal_id=${cell_id['internal']}    timeout=30   operational_State=Enabled
        ...    procedural_Status=configured
        ...    blockingState=Unblocked    administrative_State=Unlocked
        Exit For Loop If    '${res[0]}'=='PASS'
    END
    ${unlock_duration}     KW.TimerStop    timestart=${unlock_startTime}

#####unlock cell end#######
    RUN KEYWORD AND CONTINUE ON FAILURE   Should be true
    ...    ${lock_duration}<${KPI16a}
    RUN KEYWORD AND CONTINUE ON FAILURE   Should be true
     ...    ${unlock_duration}<${KPI16b}

DU_WebEM.lock cell and unlock cell one by one
    [Documentation]  This KW is for locking cell and unlocking cell one by one
    [Arguments]    ${cell_id_list}    ${connection}
    ...    ${KPI16a}=${KPI['CB008181_KPI16']['KPI16a']}
    ...    ${KPI16b}=${KPI['CB008181_KPI16']['KPI16b']}
    FOR    ${cell}    IN    @{cell_id_list}
        RUN KEYWORD AND CONTINUE ON FAILURE   DU_WebEM.lock cell and unlock cell
        ...    cell_id=${cell}     connection=${connection}
        ...    KPI16a=${KPI16a}    KPI16b=${KPI16b}
    END

DU_WebEM.TearDown.unlock cell
    [Arguments]    ${cell_id_list}    ${connection}
    FOR    ${cell}    IN    @{cell_id_list}
        wait until keyword succeeds   1min    2s    DU_Rest.unlock_cell
        ...    dist_name=${cell['configuration']}    timeout=60    connection=${connection}
    END

DU_WebEM.TearDown.unlock one cell
    [Arguments]    ${cell}    ${connection}
    ${res}    run keyword and ignore error    DU_WebEM.Check NR Cell status
    ...    cell_internal_id=${cell['internal']}    timeout=30   operational_State=Enabled
    ...    procedural_Status=configured
    ...    blockingState=Unblocked    administrative_State=Unlocked
    RUN KEYWORD If    '${res[0]}'=='FAIL'    wait until keyword succeeds   1min    2s    DU_Rest.unlock_cell
    ...    dist_name=${cell['configuration']}    timeout=60    connection=${connection}

##########End keyword for KW.CB008181-C_07_OAM_KPI_16_Cell_Lock_Unclock#############

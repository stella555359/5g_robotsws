*** Settings ***
Library    ../lib/getAbilInfo.py

Documentation
...    author: jiangjing Lin
...    contact: jiangjing.lin@nokia-sbell.com
...    Group: HGZ_SG8

*** Variables ***

*** Keywords ***
General_SiSo_BB_sub-unit_reset_with_L3_call
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this test case is to verify correctness of BB sub-unit (ABIL) reset
    ...    procedure (by using provisioning plan), triggered by an operator in WebEM. Verification with L3 call.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 29.12.2020 - - Created
    ...    *******************
    ...    Owner_shufei.chen@nokia-sbell.com
    [Arguments]  ${connection}=GNB_OAM    ${SMOD_TYPE}=ASIB
    Connect to Common Unit Master
    ${ru_index_list}    Get Rus Of Abil
    ${start_server_times}    Create Dictionary
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${RU_online_status}    Run Keyword And Return Status    Connect to RU With Allocated IP    ru_alias=RU_${ru_index}
        Should be True    ${RU_online_status}
        ${start_server_time}  ${start_uptime}    Get RU Uptime Result    ru_alias=RU_${ru_index}
        Set To Dictionary    ${start_server_times}    ${ru_index}    ${start_server_time}
        csn.Disconnect  connection=RU_${ru_index}
    END
    Selenium Login And Disable Screen Lock
    selenium_coam.reset_abil
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    ${cell_list_all}    Get Cells Of Abil
    FOR  ${cell_id}  IN  @{cell_list_all}
        ${cell_info}    coam.get_subcells_status   timeout=20    connection=${connection}
        ${cell_group_idx}    get_group_id    cell_info=${cell_info}    idx=${cell_id}
        Wait Until Keyword Succeeds    5 min    3 sec    cell status is Disable  cell_idx=${cell_id}
        ...    cell_group_idx=${cell_group_idx}
    END
    ASIB is OK on webui    SMOD_TYPE=${SMOD_TYPE}
    GNSS is OK on webui
    ABIL status is Disable
    FOR  ${ru_index}  IN  @{ru_index_list}
        RU Should Be Power Off    ru_index=${ru_index}
    END
    Wait Until Keyword Succeeds    8min    30s    COAM Check GNB cell on air
    ABIL status is Enable
    FOR  ${ru_index}  IN  @{ru_index_list}
        Wait Until Keyword Succeeds    8min    5s    RU Should Be Unlocked    ru_index=${ru_index}
    END
    FOR  ${cell_id}  IN  @{cell_list_all}
        ${cell_info}    coam.get_subcells_status   timeout=20    connection=${connection}
        ${cell_group_idx}    get_group_id    cell_info=${cell_info}    idx=${cell_id}
        Wait Until Keyword Succeeds    5 min    3 sec    Cell Should Be Unlocked  cell_idx=${cell_id}
        ...    cell_group_idx=${cell_group_idx}
    END
    Connect to Common Unit Master
    log to console    ****RU should be Reset****
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${RU_recovery_status}    Run Keyword And Return Status    Connect to RU With Allocated IP    ru_alias=RU_${ru_index}
        Should be True    ${RU_recovery_status}
        ${end_server_time}    ${end_uptime}    Get RU Uptime Result    ru_alias=RU_${ru_index}
        ${start_server_time}    Get From Dictionary    ${start_server_times}    ${ru_index}
        RU Should Be Reset    start_server_time=${start_server_time}    end_server_time=${end_server_time}
        ...    uptime=${end_uptime}
        csn.Disconnect  connection=RU_${ru_index}
    END
    ${ue_index_list}    create list    ${0}    ${1}
    ${cell_list}    create list    ${1}    ${2}
    L3 call with Check Throughput
    ...    ue_index_list=${ue_index_list}
    ...    cell_list=${cell_list}
    ...    ul_tp=180M
    ...    dl_tp=400M
    ...    ul_exp=18.5
    ...    dl_exp=215
    ...    target_avg_percent=0.5
    ...    min_percent=0.5
    [Teardown]    Selenium Logout And Close Browser


Get Rus Of Abil
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] get rus related to the pointed abil
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 28.12.2020 - - Created
    ...    *******************
    ...    Owner_jiangjing.lin@nokia-sbell.com
    [Arguments]    ${abil_index}=${1}    ${connection}=GNB_OAM
    ${ru_index_list}    GetRusUnderAbil    abil_index=${abil_index}    conn=${connection}
    [Return]    ${ru_index_list}

Get Cells Of Abil
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] get cells related to the pointed abil
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 28.12.2020 - - Created
    ...    *******************
    ...    Owner_jiangjing.lin@nokia-sbell.com
    [Arguments]    ${abil_index}=${1}    ${connection}=GNB_OAM
    ${ru_index_list}    GetRusUnderAbil    abil_index=${abil_index}    conn=${connection}
    ${cell_list_all}  create list
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${cell_list}    Get All Cell Id    ru_index=${ru_index}
        ${cell_list_all}    AddListitemToList    listfrom=${cell_list}    listto=${cell_list_all}
    END
    [Return]    ${cell_list_all}

ASIB is OK on webui
    [Arguments]    ${SMOD_TYPE}=ASIB
    ${ASIB_info}    selenium_coam.get_hw_info     hw_name=${SMOD_TYPE}
    should be equal   ${ASIB_info['Status']['Availability status']}    Online
    should be equal   ${ASIB_info['Status']['Operational state']}    Enabled
    should be equal   ${ASIB_info['Status']['Administrative state']}    Unlocked
    should be equal   ${ASIB_info['Status']['Procedural status']}    configured

GNSS is OK on webui
    ${GPS_State}    selenium_coam.get_gnss_info
    should be equal   ${GPS_State['Status']['Availability status']}    Online
    should be equal   ${GPS_State['Status']['Operational state']}    Enabled
    should be equal   ${GPS_State['Status']['Administrative state']}    Unlocked

ABIL status is Disable
    ${ABIL_info}    selenium_coam.get_abil_info
    should be equal   ${ABIL_info['Status']['Availability status']}    Offline
    should be equal   ${ABIL_info['Status']['Operational state']}    Disabled
    should be equal   ${ABIL_info['Status']['Administrative state']}    Unlocked

cell status is Disable
    [Documentation]   Auther: Stella.lin@nokia-sbell.com
    [Arguments]  ${cell_idx}=${1}   ${cell_group_idx}=${0}   ${timeout}=10   ${connection}=GNB_OAM
    ${subcell_status}=  coam_siso_common.Get Cell Status      cell_idx=${cell_idx}
    ...                                      cell_group_idx=${cell_group_idx}
    ...                                      timeout=${timeout}
    ...                                      connection=${connection}
    Should Be Equal As Strings   ${subcell_status["operationalState"]}   Disabled
    Should Be Equal As Strings   ${subcell_status["availabilityStatus"]}  Failed
    Should Be Equal As Strings   ${subcell_status["administrativeState"]}  Unlocked

ABIL status is Enable
    ${ABIL_info}    selenium_coam.get_abil_info
    should be equal   ${ABIL_info['Status']['Availability status']}    Online
    should be equal   ${ABIL_info['Status']['Operational state']}    Enabled
    should be equal   ${ABIL_info['Status']['Administrative state']}    Unlocked
    should be equal   ${ABIL_info['Status']['Procedural status']}    configured

OAM_KPI_651_SiSo_Auto_RF_reset_success_rate_from_WebUI
    Set Test Variable    ${fail_count}    0
    KPI Reset multiple RU from webui
    log    ${fail_count}
    should be true     ${fail_count}<2

OAM_KPI_651_SiSo_Auto_RF_reset_success_rate_from_WebUI_with_L3Call
    [Arguments]    ${band}=20    ${frame_structure}=1070_GP1_A3    ${duration}=300    ${loop_times}=1    ${beamset}=single beam
    ...    ${prach_index}=192    ${random_access}=True    ${enable_2197}=${False}    ${dl_ul_layer}=4DL4UL
    ${fail_times}    Set variable    ${0}
    FOR    ${TEST_LOOP}    IN RANGE    0    ${RU_MAX_LOOP}
	    Exit For Loop If    ${fail_times} >= 1
	    Run Keyword And Ignore Error    Perform RU Reset
	    Sleep    30s
	    ${result}    Run Keyword And Ignore Error    COAM Wait gnb And Cells ready    timeout=15min    gnb_type='${gNb_CuType}'
	    Run keyword if    '${result[0]}'!='PASS'    Evaluate   ${fail_times}+1
    END
    run keyword if    ${fail_times} >= 1    Fail    Fail times excceed
    Run Keyword And Ignore Error    General_SiSo_Peak_with_Given_Information    band=${band}    frame_structure=${frame_structure}
    ...    duration=${duration}    loop_times=${loop_times}    beamset=${beamset}    prach_index=${prach_index}
    ...    random_access=${random_access}    enable_2197=${enable_2197}    dl_ul_layer=${dl_ul_layer}

KPI Reset multiple RU from webui
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this keyword is reset multiple RU from webui with KPI count
    ...    *******************
    ...    Owner_hongli.xu@nokia-sbell.com
    [Arguments]
    FOR    ${count}    IN RANGE    34
        log to console    ${count}
        Webui reset RU
        calculate cell not onair times
    END

Webui reset RU
    [Documentation]
    ...    Owner_hongli.xu@nokia-sbell.com
    [Arguments]
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        Perform RU Reset    ru_index=${ru_index}
        sleep   30s
    END

calculate cell not onair times
    [Documentation]
    ...    Owner_hongli.xu@nokia-sbell.com
    [Arguments]
    ${status}    run keyword and return status    Verify cell Onair status
    log    ${status}
    Run Keyword If    '${status}'=='False'
    ...    interger calculate    input_number=${fail_count}
    log    ${fail_count}

Verify cell Onair status
    [Documentation]
    ...    Owner_hongli.xu@nokia-sbell.com
    [Arguments]  ${connection}=GNB_OAM
    ${cell_id_list}  Get All Cell Id
    FOR  ${cell_id}  IN  @{cell_id_list}
        ${cell_info}    coam.get_subcells_status   timeout=20    connection=${connection}
        ${cell_group_idx}    get_group_id    cell_info=${cell_info}    idx=${cell_id}
        Wait Until Keyword Succeeds    15 min    3 sec    Cell Should Be Unlocked  cell_idx=${cell_id}
        ...    cell_group_idx=${cell_group_idx}
    END

interger calculate
    [Documentation]
    ...    Owner_hongli.xu@nokia-sbell.com
    [Arguments]    ${input_number}=0
    ${input_number}=    Convert To Integer    ${input_number}
    ${input_number}    Evaluate    ${input_number}+1
    Set Test Variable    ${fail_count}    ${input_number}
    [Return ]    ${fail_count}

General_SiSo_E2E_system_setup_with_data_transfer_AZQR
    [Arguments]  ${ue_index_list}=${None}    ${cell_list}=${None}
    L3 call with Check Throughput
    ...    ue_index_list=${ue_index_list}
    ...    cell_list=${cell_list}
    ...    ul_tp=180M
    ...    dl_tp=400M
    ...    ul_exp=18.5
    ...    dl_exp=215
    ...    actual_rate=0.95

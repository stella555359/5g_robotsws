*** Settings ***
Documentation      CB007935 Check sync status
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/CA/Resources/CA_Common.robot
#Library      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/CA/TestData/Parameters_modify_lib.py    WITH NAME    param_modify_lib
Library      ./sync_info.py


*** Keywords ***
Verify sync status should be as expected
    [Documentation]    Author: Ding Binmei
    ...    param exp_clock_sync_status: locked/holdover
    ...    param exp_syncE_lcokState: none/OutOfLock/Locked
    ...    param exp_syncE_status: none/OK/Parent/disable
    ...    param exp_ssmValue: Not_check/none/ssmQualityUnknown/ssmPRC/...
    ...    param rmod_ids: list of rmod ids
    [Arguments]    ${exp_clock_sync_status}    ${exp_syncE_lcokState}    ${exp_syncE_status}    ${rmod_ids}=${RMOD_ID_WITH_7935_ENABLED}
    ...    ${connection_alias}=GNB_OAM    ${exp_ssmValue}=Not_check
    ${rmod_ids}    string2list    input_str=${rmod_ids}
    ${dict_sync_info}    sync_info.get_sync_info_based_on_rmod_ids    rmod_ids=${rmod_ids}    connection_alias=${connection_alias}
    FOR    ${rmod_id}    IN    @{rmod_ids}
        ${clock_sync_status}    Set variable    ${dict_sync_info["${rmod_id}"]["clock_info"]["parameters"]["syncStatus"]}
        ${syncE_lcokState}    Set variable    ${dict_sync_info["${rmod_id}"]["syncE_R_info"]["parameters"]["lockState"]}
        ${syncE_status}    Set variable    ${dict_sync_info["${rmod_id}"]["syncE_R_info"]["parameters"]["synceStatus"]}
        ${syncE_ssmValue}    Set variable    ${dict_sync_info["${rmod_id}"]["syncE_R_info"]["parameters"]["ssmValue"]}
        Run Keyword And Continue On Failure    Should Be Equal As Strings    ${clock_sync_status}    ${exp_clock_sync_status}
        ...    ignore_case=${True}    msg=Clock sync status is not ${exp_clock_sync_status}
        Run Keyword And Continue On Failure    Should Be Equal As Strings    ${syncE_lcokState}    ${exp_syncE_lcokState}
        ...    ignore_case=${True}    msg=SyncE lockState is not exp_syncE_lcokState
        Run Keyword And Continue On Failure    Should Be Equal As Strings    ${syncE_status}    ${exp_syncE_status}
        ...    ignore_case=${True}    msg=SyncE status is not exp_syncE_status
        Run keyword if    '${exp_ssmValue}' != 'Not_check'    Run Keyword And Continue On Failure
        ...    Should Be Equal As Strings    ${syncE_ssmValue}    ${exp_ssmValue}    ignore_case=${True}
        ...        msg=SyncE ssmValue is not ${exp_ssmValue}
    END

Wait until synce status not displayed when feature is disabled
    [Documentation]    Author: Ding Binmei
    [Arguments]    ${rmod_ids}=${RMOD_ID_WITH_7935_ENABLED}    ${connection_alias}=GNB_OAM    ${timeout}=1 min    ${retry_interval}=10s
    Wait Until Keyword Succeeds    ${timeout}    ${retry_interval}    Verify sync status should be as expected    exp_clock_sync_status=locked
    ...    exp_syncE_lcokState=none    exp_syncE_status=none    rmod_ids=${rmod_ids}    connection_alias=${connection_alias}

Wait until synce status become available
    [Documentation]    Author: Ding Binmei
    [Arguments]    ${rmod_ids}=${RMOD_ID_WITH_7935_ENABLED}    ${connection_alias}=GNB_OAM    ${timeout}=1 min    ${retry_interval}=10s
    Wait Until Keyword Succeeds    ${timeout}    ${retry_interval}    Verify sync status should be as expected    exp_clock_sync_status=locked
    ...    exp_syncE_lcokState=OutOfLock    exp_syncE_status=OK    rmod_ids=${rmod_ids}    connection_alias=${connection_alias}

Wait until synce status change to NOK and ssmValue updated to ssmQualityUnknown
    [Documentation]    Author: Ding Binmei
    [Arguments]    ${rmod_ids}=${RMOD_ID_WITH_7935_ENABLED}    ${connection_alias}=GNB_OAM    ${timeout}=1 min    ${retry_interval}=10s
    Wait Until Keyword Succeeds    ${timeout}    ${retry_interval}    Verify sync status should be as expected    exp_clock_sync_status=locked
    ...    exp_syncE_lcokState=OutOfLock    exp_syncE_status=NOK    exp_ssmValue=ssmQualityUnknown
    ...    rmod_ids=${rmod_ids}    connection_alias=${connection_alias}

Wait until synce status change to NOK and ssmValue updated to expected value
    [Documentation]    Author: Ding Binmei
    [Arguments]    ${exp_ssmValue}    ${rmod_ids}=${RMOD_ID_WITH_7935_ENABLED}    ${connection_alias}=GNB_OAM    ${timeout}=1 min
    ...    ${retry_interval}=10s
    Wait Until Keyword Succeeds    ${timeout}    ${retry_interval}    Verify sync status should be as expected    exp_clock_sync_status=locked
    ...    exp_syncE_lcokState=OutOfLock    exp_syncE_status=NOK    exp_ssmValue=${exp_ssmValue}
    ...    rmod_ids=${rmod_ids}    connection_alias=${connection_alias}

Wait until synce status change to OK and ssmValue updated to expected value
    [Documentation]    Author: Ding Binmei
    [Arguments]    ${exp_ssmValue}    ${rmod_ids}=${RMOD_ID_WITH_7935_ENABLED}    ${connection_alias}=GNB_OAM    ${timeout}=1 min
    ...    ${retry_interval}=10s
    Wait Until Keyword Succeeds    ${timeout}    ${retry_interval}    Verify sync status should be as expected    exp_clock_sync_status=locked
    ...    exp_syncE_lcokState=OutOfLock    exp_syncE_status=OK    exp_ssmValue=${exp_ssmValue}
    ...    rmod_ids=${rmod_ids}    connection_alias=${connection_alias}

Wait until sync status enter into holdover
    [Documentation]    Author: Ding Binmei
    [Arguments]    ${rmod_ids}=${RMOD_ID_WITH_7935_ENABLED}    ${connection_alias}=GNB_OAM    ${timeout}=1 min    ${retry_interval}=10s
    Wait Until Keyword Succeeds    ${timeout}    ${retry_interval}    Verify sync status should be as expected    exp_clock_sync_status=holdover
    ...    exp_syncE_lcokState=locked    exp_syncE_status=parent    rmod_ids=${rmod_ids}    connection_alias=${connection_alias}

Verify value of ruAssistedHoPeriod is as expected
    [Documentation]    Author: Ding Binmei
    ...    Verify ruAssistedHoPeriod is as expected. If it's 65535/None, MTIE file should be removed
    ...    param exp_ruAssistedHoPeriod: expected value of ruAssistedHoPeriod. None/0/1/2/4 (when feature is disabled, it can be None value)
    ...    param expression: can be == , != , > , < , >= , <=
    ...    param fail_keyword_when_65535_triggered: ${True}/${False}.
    ...        used to control whether need to Fail keyword if ruAssistedHoPeriod is 65535, but exp_ruAssistedHoPeriod is not 65535
    ...    Retrun: if exp_ruAssistedHoPeriod!=65535 and ruAssistedHoPeriod==65535,
    ...        keyword will be failed if fail_keyword_when_65535_triggered is True; will return with Fail if it's False
    ...        else: keyword pass fail will  be determined by the expression:
    ...              Should Be True    ${ruAssistedHoPeriod} ${expression} ${exp_ruAssistedHoPeriod}
    [Arguments]    ${exp_ruAssistedHoPeriod}    ${expression}===     ${rmod_ids}=${RMOD_ID_WITH_7935_ENABLED}    ${connection_alias}=GNB_OAM
    ...    ${fail_keyword_when_65535_triggered}=${True}
    ${rmod_ids}    string2list    input_str=${rmod_ids}
    ${dict_sync_info}    sync_info.get_sync_info_based_on_rmod_ids    rmod_ids=${rmod_ids}    connection_alias=${connection_alias}
    FOR    ${rmod_id}    IN    @{rmod_ids}
        ${ruAssistedHoPeriod}    Set Variable    ${dict_sync_info["${rmod_id}"]["clock_info"]["parameters"]["ruAssistedHoPeriod"]}
        ${is_MTIE_file_removed}    Run keyword and return status    Verify MTIE file is removed    rmod_id=${rmod_id}
        Run Keyword And Continue On Failure    Run keyword if     '${ruAssistedHoPeriod}'=='${None}' or '${ruAssistedHoPeriod}'=='65535'
        ...    Should Be True    ${is_MTIE_file_removed}
        ...    ELSE    Should Not Be True    ${is_MTIE_file_removed}
        IF    "${exp_ruAssistedHoPeriod}"!="65535" and '${ruAssistedHoPeriod}'=='65535'
            IF    "${fail_keyword_when_65535_triggered}"=="${True}"
                Fail    msg=exp_ruAssistedHoPeriod is not 65535, but 65535 is triggered. Fail keyword.
            ELSE
                ${msg}    Catenate    SEPARATOR=    RMOD-${rmod_id}:exp_ruAssistedHoPeriod:${exp_ruAssistedHoPeriod},
                 ...    but ruAssistedHoPeriod 65535 is triggered. Not to fail keyword due to flag fail_keyword_when_65535_triggered is ${True}
                Log to console    ${msg}
                Return from keyword    Fail
            END
        ELSE
            Should Be True    ${ruAssistedHoPeriod} ${expression} ${exp_ruAssistedHoPeriod}
        END
    END

Get value of ruAssistedHoPeriod for each rmod
    [Documentation]    Author: Ding Binmei
    ...    Get value of ruAssistedHoPeriod for each rmod
    ...    Return with a dictionary, key is rmod id and value is ruAssistedHoPeriod
    [Arguments]    ${rmod_ids}=${RMOD_ID_WITH_7935_ENABLED}
    ${rmod_ids}    string2list    input_str=${rmod_ids}
    ${dict_ruAssistedHoPeriod_for_rmod}    Create Dictionary
    ${dict_sync_info}    sync_info.get_sync_info_based_on_rmod_ids    rmod_ids=${rmod_ids}
    FOR    ${rmod_id}    IN    @{rmod_ids}
        ${ruAssistedHoPeriod}    Set Variable    ${dict_sync_info["${rmod_id}"]["clock_info"]["parameters"]["ruAssistedHoPeriod"]}
        ${dict_ruAssistedHoPeriod_for_rmod}    Set To Dictionary    ${dict_ruAssistedHoPeriod_for_rmod}    ${rmod_id}=${ruAssistedHoPeriod}
    END
    [Return]    ${dict_ruAssistedHoPeriod_for_rmod}

Get ru index in init file based on rmod id
    [Documentation]    Author: Ding Binmei
    [Arguments]    ${rmod_id}    ${connection_alias}=GNB_OAM
    ${dic_cell_map}    get_relation_mapping_between_cell_index_and_other_ids    connection_alias=${connection_alias}
    FOR    ${cell_index}    IN    @{dic_cell_map.keys()}
        ${rmod_index_for_cell}    Set Variable    ${dic_cell_map[${cell_index}]["rmod_index"]}
        ${ru_index_in_init}    Set Variable    ${dic_cell_map[${cell_index}]["ruIndex_in_init"]}
        Run Keyword If    '${rmod_index_for_cell}'=='${rmod_id}'    Return From Keyword    ${ru_index_in_init}
    END

Login to RU which is for MTIE file checking
    [Documentation]    Author: Ding Binmei
    ...    Test with AVQQ/AQQF. For 7.1 RU like AVQQ, need to login to thor for checking.
    [Arguments]    ${rmod_id}    ${connection_alias}=GNB_OAM
    connection_alias_store.Connect to Common Unit Master
    ${ru_index_in_init}    Get ru index in init file based on rmod id    rmod_id=${rmod_id}    connection_alias=${connection_alias}
    ${ru_type}    Set variable    ${tl.gnbs[0].dus[0].rus[${ru_index_in_init}].radio_type}
    ${ru_index}    Evaluate    ${ru_index_in_init}+1
    ${ru_alias}    Set Variable    RU_${ru_index}
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=${ru_alias}
    ${ru_thor_alias}    Set Variable   ${ru_alias}_thor
    ${ru_username}    Set variable    ${tl.gnbs[0].dus[0].rus[${ru_index_in_init}].default_ssh_connection_details.username}
    ${ru_password}    Set variable    ${tl.gnbs[0].dus[0].rus[${ru_index_in_init}].default_ssh_connection_details.password}
    Run keyword if    '${ru_type}'=='AVQQ'
    ...    csn.connect to    hostname=192.168.101.17    username=${ru_username}    password=${ru_password}
    ...     proxy=${ru_alias}    alias=${ru_thor_alias}
    ${ru_alias}    Set Variable If    '${ru_type}'=='AVQQ'    ${ru_thor_alias}    ${ru_alias}
    [Return]    ${ru_alias}

Release RU connections
    [Documentation]    Author: Ding Binmei
    [Arguments]    ${ru_alias}
    ${ru_thor_alias}    Run keyword if    'thor' in '${ru_alias}'  Set variable    ${ru_alias}
    ...    ELSE     Set variable    ${None}
    ${ru_alias}    Run keyword if    'thor' in '${ru_alias}'    Replace String    ${ru_alias}    search_for=_thor    replace_with=${EMPTY}
    ...    ELSE    Set variable    ${ru_alias}
    Run Keyword And Continue On Failure    Run keyword if    '${ru_thor_alias}'!='${None}'    csn.disconnect    ${ru_thor_alias}
    csn.disconnect    ${ru_alias}

Verify MTIE file is removed
    [Documentation]    Author: Ding Binmei
    ...    Verify /rpram/hwapi/sync/SyncE_MTIE_measurements.txt is removed on RU
    [Arguments]    ${rmod_id}    ${connection_alias}=GNB_OAM
    ${ru_alias}    Login to RU which is for MTIE file checking    rmod_id=${rmod_id}    connection_alias=${connection_alias}
    ${is_MTIE_file_exists}    csn.file_exists    remote_path=/rpram/hwapi/sync/SyncE_MTIE_measurements.txt    connection=${ru_alias}
    Should Not Be True    ${is_MTIE_file_exists}    msg=MTIE file is not removed
    [Teardown]    Release RU connections    ru_alias=${ru_alias}

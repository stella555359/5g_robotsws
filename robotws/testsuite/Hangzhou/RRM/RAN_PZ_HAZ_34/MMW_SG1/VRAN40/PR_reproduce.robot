*** Settings ***
Documentation
...   Author: Ding Binmei
#Variables    /home/ute/Projects/testline_configuration/7_5_UTE5G401T2110/__init__.py
#Variables    /home/ute/Projects/robotws/commissionings/HGZ/7_5_UTE5G401T2112/__init_10411__.py
#Variables    /home/ute/Projects/testline_configuration/7_5_UTE5G401T2112/__init__.py
#Variables    /home/ute/Projects/testline_configuration/7_5_UTE5G401T2115/__init__.py
#Variables    /home/ute/Projects/testline_configuration/7_5_UTE5G401T2110/__init__2114.py
#Variables    /home/ute/Projects/testline_configuration/7_5_UTE5G401T2112/__init__2113.py

#Variables    /home/ute/Projects/testline_configuration/7_5_UTE5G402T254/__init__.py
#Variables    /home/ute/Projects/testline_configuration/7_5_UTE5G402T255/__init__.py
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB010411/Resources/CB010411_keywords.robot
#Variables  ./online_modify_test_data_update_parameters.py
#Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/Cloud_VRAN40/python/cloud_nrrel_operations.py

*** Variables ***
@{DU_SCF_TEMPLATE}
...    /home/ute/Projects/mmw1_config/7_5_UTE5G401T2113/Actual_configuration_scf_MRBTS-37207_MRBTS-VDU-2113-OE22-Rinline2_20240507-1211.xml
${VDU_MRBTS_ID}                           ${tl.gnbs[0].dus[0].instance_id}
${VDU_NRBTS_ID}                           ${tl.gnbs[0].dus[0].global_bts_id}

*** Test Cases ***
PR797093_fault_10_after_RU_reset
    [Setup]  Create log directory on cloud
    ${timeout}    Set variable    15 min
    ${timeout_fault10}    Set variable    900
    ${retry_time}    Set variable    ${0}
    ${max_retry_time}    Set variable    ${50}
    ${rmod_id}    Set variable    4
    Connect to vdu via rest api
    FOR    ${repeat}    IN RANGE    ${max_retry_time}
        vDU.Perform reset RUs    rmods_list=${rmod_id}
        ${retry_time}    Evaluate    ${retry_time}+1
        Wait until keyword succeeds    2 min    10 sec    vDU.Verify RU status are as expected    rmods_list=${rmod_id}
        ...    exp_availability_status=not installed    exp_operational_state=disabled
        ${is_ru_started_initial}    Run keyword and return status    wait until keyword succeeds    ${timeout}    10 sec
        ...    Check RU status on vdu
        Run keyword if    ${is_ru_started_initial}
        ...    Log to console    Repeat time: ${repeat}, RU started after RU reset, issue not reproduced. Retry
        Continue for loop IF    ${is_ru_started_initial}
        ${is_fault_10_present}    Run keyword and return status    Wait until expected alarm displayed    timeout=${timeout_fault10}
        ...    faultId=10    alarmId=7116    source=MRBTS-${VDU_MRBTS_ID}/EQM_R-1/APEQM_R-1/RMOD_R-${rmod_id}   severity=${None}
         Exit for loop if    ${is_fault_10_present}
    END
    Should be true    ${retry_time}<${max_retry_time}
    Log to console    issue reproduced. Collect snapshot for VDU
    VDU Collect Snapshot To Local
    [Teardown]  Teardown vdu connection

PR748346_fault_10_after_vdu_commission
    [Documentation]  Author: Ding Binmei
    ...    please update timeout value based on your requirement
    [Setup]  Create log directory on cloud
    ${timeout}    Set variable     15 min  #10 sec
    ${timeout_fault10}    Set variable    900    # 10
    ${timeout_fault4527}    Set variable    300  # 10
    Connect to vdu via rest api
    ${retry_time}    Set variable    ${0}
    ${max_retry_time}    Set variable    ${50}
    FOR    ${repeat}    IN RANGE    ${max_retry_time}
        Commission vdu with teardown
        ${retry_time}    Evaluate    ${retry_time}+1
        wait until keyword succeeds    ${timeout}    10 sec    Connect to vdu via rest api
        wait until keyword succeeds    ${timeout}    10 sec    Check vnfc status are as expected on vdu
        ${is_ru_started_initial}    Run keyword and return status    wait until keyword succeeds    ${timeout}    10 sec
        ...    Check RU status on vdu
        Run keyword if    ${is_ru_started_initial}
        ...    Log to console    Repeat time: ${repeat}, RU started after comission, issue not reproduced. Retry
        Continue for loop IF    ${is_ru_started_initial}
        ${is_fault_10_present}    Run keyword and return status    Wait until expected alarm displayed    timeout=${timeout_fault10}
        ...    faultId=10    alarmId=7116    source=MRBTS-37207/EQM_R-1/APEQM_R-1/RMOD_R-1   severity=${None}
        Run keyword if    ${is_fault_10_present}
        ...    Log to console    Repeat time: ${repeat}, Fault 10 displayed, continue to check if fault 4527 exist after RU start up
        ${is_ru_started_after_fault10}    Run keyword and return status    wait until keyword succeeds    ${timeout}    10 sec
        ...    Check RU status on vdu
        ${is_fault_4527_present}    Run keyword and return status    Wait until expected alarm displayed    timeout=${timeout_fault4527}
        ...    faultId=4527    alarmId=7115    source=MRBTS-37207/EQM_R-1/APEQM_R-1/RMOD_R-1   severity=${None}
        ${debug_log}    Set variable
        ...    Repeat time: ${repeat}, is_ru_started_after_fault10=${is_ru_started_after_fault10}, is_fault_4527_present=${is_fault_4527_present}
        Log to console    ${debug_log}
        Exit for loop if    ${is_fault_4527_present} or ${retry_time}==${max_retry_time}
        Log to console    Repeat time: ${repeat}, fault 4527 not exist after RU start up. issue not reproduced. Retry
    END
    Should be true    ${retry_time}<${max_retry_time}
    Log to console    issue reproduced. Collect snapshot for VDU
    VDU Collect Snapshot To Local

    [Teardown]  Teardown vdu connection

PR775425_fault_6450_after_vdu_commission
    [Documentation]  Author: Ding Binmei
    ...    please update timeout value based on your requirement
    [Setup]  Create log directory on cloud
    @{TL2115_SCF}    create list    /home/ute/Projects/mmw1_config/7_5_UTE5G401T2115/Actual_configuration_scf_MRBTS-37159_5gvDU1_20240618-1107.xml
    Connect to vdu via rest api
    ${retry_time}    Set variable    ${0}
    ${max_retry_time}    Set variable    ${50}
    FOR    ${repeat}    IN RANGE    ${max_retry_time}
        Commission vdu with teardown    du_scf_file_path=${TL2115_SCF[0]}
        Aic Check CU and DUs Onair
        ${retry_time}    Evaluate    ${retry_time}+1
        ${is_fault_6450_present}    Run keyword and return status    Expect Fault Should Present
        ...    faultId=6450    alarmId=7115    source=MRBTS   severity=${None}
        Exit for loop if    ${is_fault_6450_present} or ${retry_time}==${max_retry_time}
        Log to console    Repeat time: ${repeat}, fault 6450 not exist after commission. issue not reproduced. Retry
    END
    Should be true    ${retry_time}<${max_retry_time}
#    Log to console    issue reproduced. Collect snapshot for VDU
#    VDU Collect Snapshot To Local

    [Teardown]  Teardown vdu connection


*** Keywords ***
Wait until expected alarm displayed
    [Arguments]  ${timeout}    ${faultId}    ${source}=${None}   ${severity}=${None}    ${alarmId}=${None}    ${connection}=OAM_gnb0_du0
    Wait Until Keyword Succeeds   ${timeout} sec   5 sec    Expect Fault Should Present
    ...    faultId=${faultId}    source=${source}    severity=${severity}    alarmId=${alarmId}    connection=${connection}

Expect Fault Should Present
    [Arguments]    ${faultId}    ${source}=${None}    ${connection}=OAM_gnb0_du0    ${severity}=${None}    ${alarmId}=${None}
    ${faultId}    Convert To Integer    ${faultId}
    &{active_alarms}    vdu.vdu_get_active_alarms    vdu_connection=${connection}
    @{alarms}    Set variable    ${active_alarms['alarms']}
    ${alarm_num}    Set variable    ${active_alarms['total']}
    ${present_status}    Set Variable    ${False}
    FOR  ${alarm}  IN  @{alarms}
       Exit For Loop If    ${alarm_num}==${0}
       ${present_status}    Run Keyword And Return Status    Run Keywords
                  ...                      Dictionary Should Contain Item    ${alarm}    fault_id    ${faultId}    AND
                  ...                      Run Keyword If    '${source}'!='${None}'
                  ...                      Should Contain     ${alarm['alarming_object']}    ${source}    case_insensitive=True    AND
                  ...                      Run Keyword If    '${severity}'!='${None}'
                  ...                      Should Contain     ${alarm['severity']}   ${severity}    case_insensitive=True    AND
                  ...                      Run Keyword If    '${alarmId}'!='${None}'
                  ...                      Should Be Equal As Strings    ${alarm['alarm_id']}    ${alarmId}

      Exit For Loop If    ${present_status}
    END
    Run Keyword If    ${present_status}==${False}    Fail    faultId ${faultId} reported by source ${source} is not present on gnb.

Commission vdu with teardown
    [Arguments]    ${du_scf_file_path}=${DU_SCF_TEMPLATE[0]}
    Commission on vdu    du_scf_file_path=${du_scf_file_path}
    [Teardown]    vDU.Teardown vdu connection

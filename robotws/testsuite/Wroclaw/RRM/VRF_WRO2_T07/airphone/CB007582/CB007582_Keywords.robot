*** Settings ***

Documentation    :copyright: Nokia

Resource    ../../../resources/airphone/5G_SW_WRO_Keywords.robot
Library    ta5g_testline_management
Library    ta5g_enb
Library    ta5g_cell_operations
Library    ta5g_delta

*** Variables ***
${cell_service_problem_alarm}=    7114
${cell_service_problem_fault}=    7107
${robustness_loop_number}=    15

*** Keywords ***
Alarm Trigger And Check
    Execute Egate Command    cmd=link_drop link=x2 by=enb:1 to=gnb:2 msg_type=abort
    Wait For Alarm To Be Up    alarm_id=${cell_service_problem_alarm}  timeout=120
    Wait For Fault To Be Up    fault_id=${cell_service_problem_fault}
    Execute Egate Command    cmd=enb_x2_link_up enb=1 target=2
    Wait For Alarm To Be Down    alarm_id=${cell_service_problem_alarm}

Set AMF To Ignore Requests
    Execute Egate Command    cmd=amf_ng_setup_param id=1 gnb=2 request_ignore=on

Drop NG Link
    Execute Egate Command    cmd=link_drop link=ng by=amf:1 to=gnb:2 msg_type=abort

Loop For Robustness Alarm Check
    [Arguments]    ${test_name}    ${loop_number}
    ${status_of_execution}    create list
    set test variable    ${exec_number}    0
    FOR    ${i}    IN RANGE    ${loop_number}
        ${TC_status}    run keyword and return status    ${test_name}
        Append To List    ${status_of_execution}    ${TC_status}
    END
    Check If None Of Executions Fails    ${status_of_execution}

Check If None Of Executions Fails
    [Arguments]    ${status_of_execution}
    FOR    ${exec}    IN    @{status_of_execution}
        should not be equal as strings    ${exec}    False
    END

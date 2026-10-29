*** Settings ***
Resource    ./../common_setup_teardown.robot
*** Variables ***
${log_name_one_time}    cp_rt_all_info_trf
${STOP_CASE_FILE}    /home/ute/delete_me_to_stop_case.txt
*** Test Cases ***
Small Case For Get Resource Usage One Time
    [Tags]    case1
    Save CPRT Info Log    ${log_name_one_time}    ${OUTPUT_DIR}/${log_name_one_time}/
    Log To Console    \n get log done.
    Log To Console    \n log_path:${OUTPUT_DIR}

Small Case For Get Resource Usage Continously
    [Tags]    case2
    Start To Monitor Resource Usage
    Log To Console    \n get log done.
    Log To Console    \n log_path:${OUTPUT_DIR}
*** Keywords ***
Start To Monitor Resource Usage
    OperatingSystem.Create File    ${STOP_CASE_FILE}
    Print Time    run "rm ${STOP_CASE_FILE}" to stop case...
    FOR    ${i}    IN RANGE    9999999
        Save CPRT Info Log    ${i}    ${OUTPUT_DIR}/${i}/
        ${stop_flag}=    Run Keyword And Return Status    OperatingSystem.File Should Exist    ${STOP_CASE_FILE}
        Sleep    2s
        Exit For Loop If    "${stop_flag}"=="${False}"
    END


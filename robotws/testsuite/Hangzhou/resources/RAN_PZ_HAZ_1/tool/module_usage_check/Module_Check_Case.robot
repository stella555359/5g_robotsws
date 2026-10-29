*** Settings ***
Documentation
...   Author: Du Ning
...   Contact: ning.du@nokia-sbell.com
...   Description: This the UTE case to check the module usages.

Test Timeout    600 minutes

Library         OperatingSystem
Library         Process
Library         String
Library         Collections
Library         DateTime



*** Test Cases ***
Module_Check_Case_01
    ${output} =	   OperatingSystem.Run    ls -lhF ${CURDIR}${/}
    Log To Console    ${output}
    Should Be Equal    "${CURDIR}"    "/home/ute/MN/UTE/robotws/testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/tool/module_usage_check"
    ${result} =    OperatingSystem.Run    cd ${CURDIR} && python ${CURDIR}${/}module_check_vm_V1.5.py > ${CURDIR}/pythonlog.log 2>&1 &
    Sleep    120s
    ${log_file} =    Set Variable    ${CURDIR}/module_check_log.log
    FOR    ${i}    IN RANGE    1    86400
        ${result} =    OperatingSystem.Run    grep -c ": END OF LOG FILE FOR MODULE USAGE CHECK!" ${log_file}
        Run Keyword If    ${result} > 0    Exit For Loop
        ${result} =    OperatingSystem.Run    ps -al | grep -c "python"
        Run Keyword If    ${result} == 0    Exit For Loop
        Sleep    1s
        # Get the current datetime
        ${current_time} =    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
        ${minute} =    Evaluate    ${i}/60
        ${second} =    Evaluate    ${i}%60
        Run Keyword If    ${second} == 0    Log To Console    "${current_time} : The module check is not finished in ${minute} minutes!"
        Run Keyword If    ${i} == 86400    Fail    "The module check is not finished in 24 hours!"
    END



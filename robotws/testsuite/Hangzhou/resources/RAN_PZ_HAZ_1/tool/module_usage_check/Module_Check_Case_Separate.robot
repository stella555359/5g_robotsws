*** Settings ***
Documentation
...   Author: Du Ning
...   Contact: ning.du@nokia-sbell.com
...   Description: This the UTE case to check the module usages.

Test Timeout    1200 minutes

Library                OperatingSystem
Library                Process
Library                String
Library                Collections
Library                DateTime

*** Variables ***
${cmd_static}          python ${CURDIR}${/}module_check_vm_V1.7.py --operation static_module_check
${cmd_keyword}         python ${CURDIR}${/}module_check_vm_V1.7.py --operation common_keywords_check
${cmd_dynamic_rrm}     python ${CURDIR}${/}module_check_vm_V1.7.py --operation dynamic_module_check --ca RRM
${cmd_dynamic_oam1}    python ${CURDIR}${/}module_check_vm_V1.7.py --operation dynamic_module_check --ca OAM1
${cmd_dynamic_oam2}    python ${CURDIR}${/}module_check_vm_V1.7.py --operation dynamic_module_check --ca OAM2
${cmd_dynamic_siso}    python ${CURDIR}${/}module_check_vm_V1.7.py --operation dynamic_module_check --ca SISO
${cmd_dryrun_rrm}      python ${CURDIR}${/}module_check_vm_V1.7.py --operation dryrun --ca RRM
${cmd_dryrun_oam1}     python ${CURDIR}${/}module_check_vm_V1.7.py --operation dryrun --ca OAM1
${cmd_dryrun_oam2}     python ${CURDIR}${/}module_check_vm_V1.7.py --operation dryrun --ca OAM2
${cmd_dryrun_siso}     python ${CURDIR}${/}module_check_vm_V1.7.py --operation dryrun --ca SISO

*** Test Cases ***
Module_Check_Case_01_Static_Module_Check
    Check Current Directory
    ${result} =    OperatingSystem.Run    cd ${CURDIR} && ${cmd_static} > ${CURDIR}/pythonlog.log 2>&1 &
    Sleep    120s
    Check Execution Ending
    Remove The Big And Log Files In Current Directory

Module_Check_Case_02_Common_Keywords_Check
    Check Current Directory
    ${result} =    OperatingSystem.Run    cd ${CURDIR} && ${cmd_keyword} > ${CURDIR}/pythonlog.log 2>&1 &
    Sleep    120s
    Check Execution Ending
    Remove The Big And Log Files In Current Directory

Module_Check_Case_03_Dryrun_RRM
    Check Current Directory
    ${result} =    OperatingSystem.Run    cd ${CURDIR} && ${cmd_dryrun_rrm} > ${CURDIR}/pythonlog.log 2>&1 &
    Sleep    120s
    Check Execution Ending
    Remove The Big And Log Files In Current Directory

Module_Check_Case_03_Dynamic_Module_Check_RRM
    Check Current Directory
    ${result} =    OperatingSystem.Run    cd ${CURDIR} && ${cmd_dynamic_rrm} > ${CURDIR}/pythonlog.log 2>&1 &
    Sleep    120s
    Check Execution Ending
    Remove The Big And Log Files In Current Directory

Module_Check_Case_04_Dryrun_OAM1
    Check Current Directory
    ${result} =    OperatingSystem.Run    cd ${CURDIR} && ${cmd_dryrun_oam1} > ${CURDIR}/pythonlog.log 2>&1 &
    Sleep    120s
    Check Execution Ending
    Remove The Big And Log Files In Current Directory

Module_Check_Case_04_Dynamic_Module_Check_OAM1
    Check Current Directory
    ${result} =    OperatingSystem.Run    cd ${CURDIR} && ${cmd_dynamic_oam1} > ${CURDIR}/pythonlog.log 2>&1 &
    Sleep    120s
    Check Execution Ending
    Remove The Big And Log Files In Current Directory

Module_Check_Case_05_Dryrun_OAM2
    Check Current Directory
    ${result} =    OperatingSystem.Run    cd ${CURDIR} && ${cmd_dryrun_oam2} > ${CURDIR}/pythonlog.log 2>&1 &
    Sleep    120s
    Check Execution Ending
    Remove The Big And Log Files In Current Directory

Module_Check_Case_05_Dynamic_Module_Check_OAM2
    Check Current Directory
    ${result} =    OperatingSystem.Run    cd ${CURDIR} && ${cmd_dynamic_oam2} > ${CURDIR}/pythonlog.log 2>&1 &
    Sleep    120s
    Check Execution Ending
    Remove The Big And Log Files In Current Directory

Module_Check_Case_06_Dryrun_SISO
    Check Current Directory
    ${result} =    OperatingSystem.Run    cd ${CURDIR} && ${cmd_dryrun_siso} > ${CURDIR}/pythonlog.log 2>&1 &
    Sleep    120s
    Check Execution Ending
    Remove The Big And Log Files In Current Directory

Module_Check_Case_06_Dynamic_Module_Check_SISO
    Check Current Directory
    ${result} =    OperatingSystem.Run    cd ${CURDIR} && ${cmd_dynamic_siso} > ${CURDIR}/pythonlog.log 2>&1 &
    Sleep    120s
    Check Execution Ending
    Remove The Big And Log Files In Current Directory



*** Keywords ***
Check Current Directory
    ${output} =	   OperatingSystem.Run    ls -lhF ${CURDIR}${/}
    Log To Console    ${output}
    Should Be Equal    "${CURDIR}"    "/home/ute/MN/UTE/robotws/testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/tool/module_usage_check"

Check Execution Ending
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
        Run Keyword If    ${second} == 0    Log To Console    "${current_time} : The module check executed ${minute} minutes!"
        Run Keyword If    ${i} == 86400    Fail    "The module check is not finished in 24 hours!"
    END

Remove The Big And Log Files In Current Directory
    ${output} =    OperatingSystem.Run    ls -lhF ${CURDIR}${/}
    Log To Console    ${output}
    ${output} =    OperatingSystem.Run    find ${CURDIR} -type f -size +100M -exec ls -lhF {} \;
    ${output} =    OperatingSystem.Run    find ${CURDIR} -type f -size +100M -exec rm -f {} \;
    ${output} =    OperatingSystem.Run    rm -f ${CURDIR}${/}pythonlog.log
    ${output} =    OperatingSystem.Run    rm -f ${CURDIR}${/}module_check_log.log
    ${output} =    OperatingSystem.Run    ls -lhF ${CURDIR}${/}
    Log To Console    ${output}

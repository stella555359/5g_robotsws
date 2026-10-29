*** Settings ***
Documentation    :copyright: Nokia
...              :author: Mateusz Bilewicz
...              :contact: mateusz.bilewicz@nokia.com

Library    DateTime
Library    OperatingSystem
Library    skywatch_core_runner.py
Library    robot_addons/download_sw.py
Library    robot_addons/upload_logs.py
Library    helpful_scripts/utilities.py
Resource   robot_addons/common_keywords.robot
Variables  robot_addons/common_variables.py



Test Template    Run Test With Software

Suite Teardown    Run Keywords    Log    ${rotta_run_path}
    ...    AND    Create File    ${OUTPUT_DIR}/log_dest.txt    ${rotta_run_path}

*** Test Cases ***
Prepare Variables
    [Template]    NONE
    ${hostname}=    utilities.Get Machine Name
    ${ts}=    Get Current Date    result_format=%Y%m%d-%H%M%S
    Set Suite Variable    ${actual_timestamp}    ${ts}
    Set Suite Variable    ${tar_prefix}    ${first_sw_package}_vs_${second_sw_package}_${hostname}
    Set Suite Variable    ${rotta_run_path}    ${ROTTA_PATH}/${tar_prefix}/${actual_timestamp}/
    Show Gnb Versions
    utilities.Update Repo Symlink If Needed    ${EXECDIR}
    Clean Test Time File

First Run    ${first_sw_package}    timeout=85min
Second Run    ${second_sw_package}    timeout=85min
Third Run    ${first_sw_package}    timeout=85min
Fourth Run    ${second_sw_package}    timeout=85min
Fifth Run    ${first_sw_package}    timeout=85min
Sixth Run    ${second_sw_package}    timeout=85min
#Seventh Run    ${first_sw_package}
#Eighth Run    ${second_sw_package}
Generate Kpi Report
    [Template]    NONE
    Prepare KPI Reports


*** Keywords ***
Run Test With Software
    [Arguments]    ${software}    ${timeout}=None
    ${update_needed}=    Get Software Version And Check If Update Is Needed    ${software}
    Download And Activate Sw    ${update_needed}    ${software}
    Reach Onair And Wait For Cells Activation
    Wait For Next Full Pm Interval
    Run Skywatch Project    ${timeout}    ${TEST NAME}
    Collect Snapshot
    Reset All Loggers
    Shutdown Egate Edaemon
    Wait For Next Full Pm Interval

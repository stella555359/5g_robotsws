*** Settings ***
Documentation    :copyright: Nokia
...              :author: Mateusz Bilewicz
...              :contact: mateusz.bilewicz@nokia.com

Library    OperatingSystem
Library    ute_wtssim
Library    ute_fsmaccess
Library    ta5g_setups_and_teardowns
Library    ta5g_commissioning
Library    ta5g_iphy
Library    ta5g_cell_operations
Library    ta5g_egate
Library    ta5g_enb
Library    ta5g_file_system
Library    ta5g_pm_counters
Library    DateTime
Library    skywatch_core_runner.py
Library    robot_addons/download_sw.py
Library    robot_addons/upload_logs.py
Resource   robot_addons/common_keywords.robot
Variables  robot_addons/common_variables.py


Test Template    Run Test With Software
#Suite Setup    Set Log Directory    log_dir=${all_log_path}
#Test Setup    Run Keywords    Update SCF and Iphy
#    ...    AND    Reach Onair And Wait For Cells Activation
#    ...    AND    Run Skywatch Main Script
#    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
#
#Test Teardown    Run Keywords    Update SCF and Iphy
#    ...    AND    Reach Onair And Wait For Cells Activation
#    ...    AND    Run Skywatch Main Script
#    ...    AND    Collect Snapshot
#    ...    AND    Reset All Loggers
#    ...    AND    Shutdown Egate Edaemon
#Test Teardown    Log    ${actual_log_path}
#Suite Teardown    Compress Files    input_dirpath=${all_log_path}    output_dirpath=${all_log_path}    output_filename_prefix=${tar_prefix}
Suite Teardown    Run Keywords    Log    ${rotta_run_path}
#    ...    AND    Create Log Html    ${all_log_path}
#    ...    AND    Run Process    rebot    --log  log.html    --report  report.html    --output  NONE  ${all_log_path}/output.xml
    ...    AND    Create File    log_dest.txt    ${rotta_run_path}
#    ...    AND    Reset Testline And Wait For Rmods
#    ...    AND    Copy Directory With Sudo    src=${all_log_path}    dest=${rotta_run_path}
#    ...    AND    Create Log Html    ${rotta_run_path}logs/

*** Variables ***
${skywatch_path}=  ${EXECDIR}/testsuite/Wroclaw/RRM/VRF_WRO1_T04/SKYWATCH/SKYWATCH
${config_path}=  ${skywatch_path}/config_65
${iphy_config_file_name}=  ${skywatch_path}/config_65/iphy_skywatch.xml
${scf_filepath}=  ${skywatch_path}/config_65/UTE_129_skywatch.xml

# CHINA ARTIFACTORY
${sw_download_url}=  https://artifactory-hz1.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-remote/build/SBTS00/
# ESPOO ARTIFACTORY
#${sw_download_url}=  https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/build/SBTS00/
${download_path}=  /home/ute/Downloads/
${all_log_path}=  /home/ute/logs/
${rotta_path}=   /home/ute/rotta/bilewicz/SKYWATCH_RUNS

${reset_cmd}=    reset



*** Test Cases ***
Prepare Variables
    [Template]    NONE
    ${hostname}=    Get Machine Name
    ${ts}=    Get Current Date    result_format=%Y%m%d-%H%M%S
    Set Suite Variable    ${actual_timestamp}    ${ts}
    Set Suite Variable    ${tar_prefix}    ${first_sw_package}_vs_${second_sw_package}_${hostname}
    Set Suite Variable    ${rotta_run_path}    ${rotta_path}/${tar_prefix}/${actual_timestamp}/
    Show Gnb Versions
#    Clean Test Time File

#First Run    ${first_sw_package}    timeout=10min
#Second Run    ${second_sw_package}    timeout=10min
#Third Run    ${first_sw_package}    timeout=30min
#Fourth Run    ${second_sw_package}    timeout=30min
Generate Kpi Report
    [Template]    NONE
#    Generate Kpi Report Fake
#    Generate Kpi Comparator Report
#    Get Kpi Values From Report    report_id=1211316
#    Get Kpi Reports From Comparator
    Run Kpi Comparator
#Fifth Run    ${first_sw_package}
#Sixth Run    ${second_sw_package}
#Seventh Run    ${first_sw_package}
#Eighth Run    ${second_sw_package}


#Cleanup, Collect And Pack Logs
#    Stop Default Processes And Gather Logs And Compress Logs
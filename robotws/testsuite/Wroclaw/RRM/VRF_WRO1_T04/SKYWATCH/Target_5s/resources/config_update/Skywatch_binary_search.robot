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
Library    ../asyncio_scenario_runner.py
Library    download_sw.py
Library    upload_logs.py
#Resource     ../../../../../5G_SW_WRO/resources/5G_SW_WRO_Keywords.robot

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
#    ...    AND    Copy Directory With Sudo    src=${all_log_path}    dest=${rotta_run_path}
#    ...    AND    Create Log Html    ${rotta_run_path}logs/

*** Variables ***
${skywatch_path}=  ${EXECDIR}/testsuite/Wroclaw/RRM/VRF_WRO1_T04/SKYWATCH/Target_5s
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
#    Set Suite Variable    ${tar_prefix}    ${first_sw_package}_vs_${second_sw_package}
    ${hostname}=    Get Machine Name
    Set Suite Variable    ${tar_prefix}    ${1_sw_package}_vs_${2_sw_package}_${hostname}
#    Set Suite Variable    ${tar_prefix}    ${first_sw_package}_vs_${second_sw_package}_${hostname}
    ${ts}=    Get Current Date    result_format=%Y%m%d-%H%M%S
    Set Suite Variable    ${actual_timestamp}    ${ts}
    Set Suite Variable    ${rotta_run_path}    ${rotta_path}/${tar_prefix}/${actual_timestamp}/
    Show Gnb Versions

#First Run    ${first_sw_package}    timeout=1h
#Second Run    ${second_sw_package}    timeout=1h
#Third Run    ${first_sw_package}    timeout=1h
#Fourth Run    ${second_sw_package}    timeout=1h
#Fifth Run    ${first_sw_package}    timeout=1h
#Sixth Run    ${second_sw_package}    timeout=1h
#Seventh Run    ${first_sw_package}    timeout=1h
#Eighth Run    ${second_sw_package}    timeout=1h

First Run    ${1_sw_package}    timeout=1h
Second Run    ${2_sw_package}    timeout=1h
Third Run    ${3_sw_package}    timeout=1h
Fourth Run    ${4_sw_package}    timeout=1h
Fifth Run    ${5_sw_package}    timeout=1h
Sixth Run    ${6_sw_package}    timeout=1h
Seventh Run    ${7_sw_package}    timeout=1h
Eighth Run    ${8_sw_package}    timeout=1h


#Cleanup, Collect And Pack Logs
#    Stop Default Processes And Gather Logs And Compress Logs
*** Keywords ***
Run Test With Software
    [Arguments]    ${software}    ${timeout}=None
    ${update_needed}=    Get Software Version And Check If Update Is Needed    ${software}
    Download And Activate Sw    ${update_needed}    ${software}
    Software Cleanup    ${download_path}
    Update SCF and Iphy
    Reach Onair And Wait For Cells Activation
    Wait For Next Raw Pm Interval
    Run Skywatch Project    ${timeout}
    Collect Snapshot
    Reset All Loggers
    Shutdown Egate Edaemon
    Wait For Next Raw Pm Interval


Show Gnb Versions
    Log    ${tar_prefix}

Download Software
    [Arguments]    ${package}
    Download If Not Exist  version=${package}  sw_path=${download_path}

Get Actual Software Version
    ${active_sw_tuple}=    Get Software Info
    Set Global Variable    ${active_sw}    ${active_sw_tuple}[0]
    IF    '${active_sw}' == 'failed'
        Fail
    END


Get Software Version And Check If Update Is Needed
    [Arguments]    ${target_sw_package}
    [Documentation]   Checks if active sw is equal to requested in Robot command
    Wait Until Keyword Succeeds    10 min    5 sec    Get Actual Software Version
    ${update_needed}=    Set Variable If    '${active_sw}' == '${target_sw_package}'    False    True
    RETURN    ${update_needed}


Download And Activate Sw
    [Arguments]    ${update_needed}    ${target_sw_package}
    IF    ${update_needed}
        ${msg}=    Download If Not Exist  version=${target_sw_package}  sw_path=${download_path}
        Log To Console  ${msg}
        Activate Software    version=${target_sw_package}  sw_path=${download_path}
        Wait Until Keyword Succeeds    10 min    5 sec    Get Actual Software Version
        ${sw_versions_equal}=    Set Variable If    '${active_sw}' == '${target_sw_package}'    True    False
    END

Update SCF and Iphy
    Wait For Update Possible
    Update Iphy Configuration And Modify Swconfig    iphy_xml_filepath=${iphy_config_file_name}
    Fix And Send Full Commissioning With Given Scf Filepath    scfc_filepath=${scf_filepath}
    Check Radios Availability


Reach Onair And Wait For Cells Activation
    Check Radios Availability
    Reach_Onair_Without_Confirmation    lua_cfg=${config_path}/cfg_skywatch_tmo_65.lua    x2_link_start=False
    ${list_of_cells_ids}=    Get List Of All Cells Ids
    Wait Until Cells Are Onair    timeout=${180}    enb_id=${2}    cell_ids=${list_of_cells_ids}


Setup X2
    ${x2_regex}=    Return X2 Regex
    Wait For Egate Console Output    expected_message=${x2_regex}    timeout=${100}

Shutdown Egate Edaemon
    Execute Egate Cmd    cmd=${reset_cmd}
    Teardown Egate
    Teardown All Aliases For Egate

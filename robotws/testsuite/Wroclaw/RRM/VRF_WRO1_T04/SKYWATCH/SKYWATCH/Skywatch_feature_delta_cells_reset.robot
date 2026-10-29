*** Settings ***
Documentation    :copyright: Nokia
...              :author: Mateusz Bilewicz
...              :contact: mateusz.bilewicz@nokia.com

Library    DateTime
Library    OperatingSystem
Library    ta5g_file_system
Library    skywatch_core_runner.py
Library    robot_addons/download_sw.py
Library    robot_addons/upload_logs.py
Library    helpful_scripts/utilities.py
Resource   robot_addons/common_keywords.robot
Variables  robot_addons/common_variables.py


Test Template    Run Test With Software

Suite Teardown    Run Keywords    Log    ${rotta_run_path}
    ...    AND    Shutdown Egate Edaemon
    ...    AND    Reset Testline And Wait For Rmods
    ...    AND    Create File    ${OUTPUT_DIR}/log_dest.txt    ${rotta_run_path}

*** Test Cases ***
Prepare Variables
    [Template]    NONE
    ${hostname}=    utilities.Get Machine Name
    ${ts}=    Get Current Date    result_format=%Y%m%d-%H%M%S
    Set Suite Variable    ${delta_act}    /home/ute/Downloads/test2_full_activate.json
    Set Suite Variable    ${delta_deact}    /home/ute/Downloads/test2_full_deactivate.json
    Set Suite Variable    ${actual_timestamp}    ${ts}
    Set Suite Variable    ${tar_prefix}    feature_delta_CB011022_${hostname}
    Set Suite Variable    ${rotta_run_path}    ${ROTTA_PATH}/${tar_prefix}/${actual_timestamp}/
    Show Gnb Versions
    Reach Onair And Wait For Cells Activation
    utilities.Update Repo Symlink If Needed    ${EXECDIR}
    Clean Test Time File

First Run    timeout=1h    delta=${delta_act}
Second Run    timeout=1h    delta=${delta_deact}
Third Run    timeout=1h    delta=${delta_act}
Fourth Run    timeout=1h    delta=${delta_deact}
Generate Kpi Report
    [Template]    NONE
    Prepare KPI Reports

*** Keywords ***
Run Test With Software
    [Arguments]    ${timeout}=None    ${delta}=None
    ${RUN_NAME}=    Set Variable    ${TEST NAME.replace(" ", "")}
    Send Delta Commissioning    input_filepath=${delta}
    Check Radios Availability
    ${list_of_cells_ids}=    Get List Of All Cells Ids
    Wait Until Cells Are Onair    timeout=${180}    enb_id=${2}    cell_ids=${list_of_cells_ids}
    Get Scfc File    output_filepath=${OUTPUT_DIR}${RUN_NAME}/SCF_after_delta_${RUN_NAME}.xml
    Wait For Next Full Pm Interval
    Run Skywatch Project    ${timeout}    ${TEST NAME}
    Collect Snapshot
    Reset All Loggers
    Compress Files
    ...  input_dirpath=${OUTPUT_DIR}${RUN_NAME}
    ...  output_dirpath=${OUTPUT_DIR}${RUN_NAME}
    ...  output_filename_prefix=syslogs
    Wait For Next Full Pm Interval

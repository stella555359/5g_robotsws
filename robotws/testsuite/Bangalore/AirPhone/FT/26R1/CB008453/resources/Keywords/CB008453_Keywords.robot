** Settings ***
Documentation    :copyright       : Nokia
                 ...              :author       : Keerthi.Chittoor
                 ...              :contact      : keerthi.chittoor@nokia.com
                 ...              :Description  : Contains Keyword needed for CB008453
                 ...              :history change, <date>,<who>,<what and how>
                 ...              :Drafted,27.10.2025,keerthi.chittoor@nokia.com

Resource    ../../../../resources/Keywords/new_general_common_keywords.robot
Resource    ../Variables/CB008453_variables.robot
Library     ../Python/traffic_handling.py
Library     ../Python/ue_handling.py
Library     ../Python/utils.py
Library     ../Python/TddParser.py
Library     OperatingSystem
Library     BuiltIn
Library     Collections
Library     ta_a2a.interface

***Keywords***
Verify tdd-UL-DL-ConfigurationCommon
    [Documentation]    Extract all TDD blocks, log them, and save them into a CSV file.
    # Ensure the file exists
    File Should Exist    ${FILE}

    # Get all TDD blocks
    ${blocks}=    Get Tdd Blocks    ${FILE}
    ${count}=     Get Length    ${blocks}
    Log To Console    Found ${count} TDD configuration block(s).

    # Fail if no blocks found
    Run Keyword If    ${count} == 0    Fail    No TDD configuration blocks found!

    # Write blocks to CSV
    ${csv_path}=    Write Tdd To Csv    ${blocks}    ${CSV_FILE}
    Log To Console    ✅ CSV created at: ${csv_path}

    # Optional: log each block’s extracted values
    FOR    ${block}    IN    @{blocks}
        ${data}=    Extract Tdd Values    ${block}
        Log To Console    ${data}
    END

CB008453 Suite Setup
     [Arguments]    ${TC_DIR}=none
     Clean up Preparation before TC     ${TC_DIR}
     Download Ttitrace Decode Tool
     Sleep     10
     Start Logs      ${L_AP_GNB_SYS}

CB008453 Suite Teardown
     [Arguments]    ${TC_DIR}=none
     Stop and collect SOS       ${sos_script_path}    ${Log_Path}
     Sleep     10
     Stop Logs     ${L_AP_GNB_SYS}     ${TC_DIR}
     Collect Cfg and egate logs     ${TC_DIR}
     Cleanup Process After TC     ${TC_DIR}

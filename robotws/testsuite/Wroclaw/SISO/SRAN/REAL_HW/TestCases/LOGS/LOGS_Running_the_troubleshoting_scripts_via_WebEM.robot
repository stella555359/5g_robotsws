*** Settings ***
Documentation
...    Author:        szymon.przybylak@nokia.com
...    Maintainer:    szymon.przybylak@nokia.com
...
...  *****************
...  Basic information
...  *****************
...  Test case verifies running troubleshooting scripts via WebEM and checks the results.
...  The test includes the following steps:
...  1. Preconditions - Running troubleshooting scripts via WebEM
...  2. Check Troubleshooting Scripts Values
...  3. Run RU_Common_capture_IQ_data Script And Check Output
...  4. Run RU_Common_capture_L1low_data Script And Check Output
...  5. Run RU_Common_capture_register_dump Script And Check Output
...
...  Variables needed to be set by tester:
...  - ${RMOD_SERIAL_NUMBER}: Serial number of the RMOD to be used in the test.
...  - ${WRONG_CELLS_DICT}: Dictionary with incorrect cell names for error handling verification,
...    where key is RMOD serial number and value is incorrect cell name(s).
...     e.g.  &{WRONG_CELLS_DICT}  1M204457006=LNCEL-12252

Resource    ../../Resources/Robot/FM_Faults.robot
Resource    ../../Resources/Setup/setup_and_teardown.robot
Resource    ../../Resources/Robot/RM.robot
Library     taf.sbts.oam.coam.admin  WITH NAME  admin
Library     ./../../../resources/radio_operations/RadioOperations.py  WITH NAME  radio
Library     taf.selenium.sbts  WITH NAME  selenium_coam
Library    OperatingSystem
Library  /home/ute/MN/UTE/robotws/testsuite/Wroclaw/SISO/SRAN/REAL_HW/Resources/Python/zip_helpers.py  WITH NAME  zip_helpers
Library    /home/ute/MN/UTE/robotws/testsuite/Wroclaw/SISO/SRAN/REAL_HW/Resources/Python/check_dates_in_file.py    WITH NAME    date_checker

*** Variables ***
${GENERAL_TIMEOUT}  10
${SCRIPT_TIMEOUT}    300
${WEBUI_URL}     https://192.168.255.129    # ADMIN url
${WEBUI_NAME}    Nemuadmin                   # ADMIN login
${WEBUI_PWD}     nemuuser                    # ADMIN password

${TIMEOUT}           60               # Default timeout in seconds for operations

${VIRTUAL_DISPLAY_WIDTH}    3000      # Virtual display width in pixels
${VIRTUAL_DISPLAY_HEIGHT}   1080      # Virtual display height in pixels
${USE_VIRTUAL_DISPLAY}      ${True}   # Enable/disable virtual display
${BTS_ID}  1304

*** Keywords ***
TC__LOGS_Running_the_troubleshoting_scripts_via_WebEM
    [Documentation]    Main test case for running troubleshooting scripts via WebEM.
    ...  Executes all steps: preconditions, script value checks, script runs, and output validation.
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com
    Set Tags
    ...    OWNER-szymon.przybylak@nokia.com
    ...    AUTHOR-szymon.przybylak@nokia.com
    ...    MAINTAINER-szymon.przybylak@nokia.com
    Common Test Setup
    Logging With Timestamp
    ...  message=TC__LOGS_Running_the_troubleshoting_scripts_via_WebEM
    ...  style=ONGOING
    Step 1: Preconditions - Running troubleshooting scripts via WebEM
    Step 2: Check Troubleshooting Scripts Values
    Step 3: Run RU_Common_capture_IQ_data Script And Check Output
    Step 4: Run RU_Common_capture_L1low_data Script And Check Output
    Step 5: Run RU_Common_capture_register_dump Script And Check Output
    [Teardown]  Run Keywords
    ...  Selenium Logout And Close Browser
    ...  AND  Common Test Teardown

Selenium Logout And Close Browser
    [Documentation]    Logs out from Selenium session and closes the browser.
    ...  Ignores errors if logout or close fails. Disables virtual display if enabled.
    Run Keyword And Ignore Error    selenium_coam.Logout
    Run Keyword And Ignore Error    selenium_coam.Close Browser
    Run Keyword And Ignore Error    selenium_coam.Disable Virtual Display

Step 1: Preconditions - Running troubleshooting scripts via WebEM
    [Arguments]  ${download_dir}=${TEST_LOGS_PATH}/TestFiles/Selenium
    [Documentation]    Step 1 of the test case: Preconditions - Running troubleshooting scripts via WebEM
    ...  This step includes logging into the SBTS web interface
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | download_dir           | no   |  Directory to download files from the SBTS web interface                   |
    ...  +========================+======+============================================================================+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com
    Logging With Timestamp
    ...  message=Step 1: Preconditions - Running troubleshooting scripts via WebEM
    ...  style=STEP
    ...  frame=${TRUE}
    Log  ${CFG}
    ${bts_id}  Get From Dictionary  ${CFG.RF_INFO['${RMOD_SERIAL_NUMBER}']}  scf_btsid_primary
    Set Test Variable    ${BTS_ID}    ${bts_id}
    Log  ${cfg}
    selenium_coam.Enable Virtual Display  width=${VIRTUAL_DISPLAY_WIDTH}  height=${VIRTUAL_DISPLAY_HEIGHT}
    ${cell_list}  admin.Get Cell List  connection=${BTS_ID}
    ${rmods_info}  admin.Get FRM  timeout=60  connection=${BTS_ID}
    FOR  ${rmod}  IN  @{rmods_info}
        Continue For Loop If  '${rmod['serialNumber']}'!='${RMOD_SERIAL_NUMBER}'
        Log  ${rmod}
        Set Test Variable  ${rmod_internal_distname}  ${rmod['id']['internal']}
        Set Test Variable  ${rmod_rn_distname}  ${rmod['id']['runtime']}
        ${rmod_config_dn}  Set Variable  ${rmod['id']['configuration']}
        ${rmod_runtime_dn}  Set Variable  ${rmod['id']['runtime']}
        ${parts}=   Split String    ${rmod_config_dn}    /
        ${rmod_config_dn_last}=      Get From List   ${parts}    -1
        ${parts}=   Split String    ${rmod_runtime_dn}    /
        ${rmod_runtime_dn_last}=      Get From List   ${parts}    -1
        ${rmod_name}  Set Variable  ${rmod['productName']}
        ${rmod_in_scripts_name}  Set Variable  ${rmod_config_dn_last}/${rmod_runtime_dn_last} (${rmod_name})
        Set Test Variable  ${rmod_in_scripts_name}  ${rmod_in_scripts_name}
        ${tested_rmod_cells}  Get Cell Mapping By Module Id   ${rmod_internal_distname}  connection=${BTS_ID}
        ${lte_cells_distnames}  RM Get Cells Mapping By RMOD Id  LTE  ${rmod_internal_distname}  connection=${BTS_ID}
        ${nr_cells_distnames}  RM Get Cells Mapping By RMOD Id  NR  ${rmod_internal_distname}  connection=${BTS_ID}
        Exit For Loop
    END
    ${new_nr_cells}=  Create List
    FOR  ${cell}  IN  ${nr_cells_distnames}
        ${cell_id}=    Replace String    ${cell}[0]    NRCELL_R-    NRCELL-
        ${cell_id}=    Fetch From Right    ${cell_id}    /
        Append To List    ${new_nr_cells}    ${cell_id}
    END
    Set Test Variable  ${new_nr_cells}  ${new_nr_cells}
    selenium_coam.Login  ${WEBUI_URL}  ${WEBUI_NAME}  ${WEBUI_PWD}  download_dir=${download_dir}  version=${sw_release}
    ${view_exists}  selenium_coam.start_up_view_window_exists
    Run Keyword If  ${view_exists}  selenium_coam.close_start_up_view_window
    selenium_coam.Disable Message Box
    selenium_coam.Disable Screen Lock

    Logging With Timestamp
    ...  message=Step 1: Preconditions - Running troubleshooting scripts via WebEM
    ...  style=DONE

Step 2: Check Troubleshooting Scripts Values
    [Documentation]    Step 2 of the test case: Checks the results of troubleshooting scripts.
    ...  Verifies output for all required troubleshooting scripts.
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com
    Logging With Timestamp
    ...  message=Step 2: Check Troubleshooting Script Results
    ...  style=STEP
    ...  frame=${TRUE}
    Check Troubleshooting Script Output  script_name=RU_Common_capture_IQ_data
    Check Troubleshooting Script Output  script_name=RU_Common_capture_L1low_data
    Check Troubleshooting Script Output  script_name=RU_Common_capture_register_dump
    Logging With Timestamp
    ...  message=Step 2: Check Troubleshooting Script Results
    ...  style=DONE

Step 3: Run RU_Common_capture_IQ_data Script And Check Output
    [Documentation]    Step 3 of the test case: Runs RU_Common_capture_IQ_data script and checks output.
    ...  Validates correct and incorrect parameter handling and error reporting.
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    Logging With Timestamp
    ...  message=Step 3: Run RU_Common_capture_IQ_data Script And Check Output
    ...  style=STEP
    ...  frame=${TRUE}
    ${start_date}  Get Current Date  UTC
    Logging With Timestamp
    ...  message=Running script with RMOD selected: ${rmod_in_scripts_name}
    ...  style=ONGOING
    ${launch_script_output}=  Run Troubleshooting Script  script_name=RU_Common_capture_IQ_data
    Logging With Timestamp
    ...  message=Running script with RMOD selected: ${rmod_in_scripts_name}
    ...  style=DONE
    Check Downloaded Zip File  ${launch_script_output['Collection file']}  script_name=RU_Common_capture_IQ_data  start_date=${start_date}

    Logging With Timestamp
    ...  message=Running script with RMOD selected: ${rmod_in_scripts_name} and cells: ${new_nr_cells}
    ...  style=ONGOING
    ${start_date}  Get Current Date  UTC
    ${launch_script_output}=  Run Troubleshooting Script  script_name=RU_Common_capture_IQ_data  cells_name=${new_nr_cells}
    Logging With Timestamp
    ...  message=Running script with RMOD selected: ${rmod_in_scripts_name} and cells: ${new_nr_cells}
    ...  style=DONE
    Check Downloaded Zip File  ${launch_script_output['Collection file']}  script_name=RU_Common_capture_IQ_data  start_date=${start_date}


    Logging With Timestamp
    ...  message=Running script with incorrect RMOD and CELL values to check error handling
    ...  style=ONGOING
    ${launch_script_output}  Run Troubleshooting Script
    ...  script_name=RU_Common_capture_IQ_data
    ...  cells_name=${WRONG_CELLS_DICT['${RMOD_SERIAL_NUMBER}']}
    ...  timeout=30
    Logging With Timestamp
    ...  message=Error info as expected: ${launch_script_output['Launching status']}
    ...  style=INFO
    Logging With Timestamp
    ...  message=Finished checking error handling when running script with incorrect RMOD and CELL values
    ...  style=DONE
    Logging With Timestamp
    ...  message=Step 3: RU_Common_capture_IQ_data Script And Check Output
    ...  style=DONE

Step 4: Run RU_Common_capture_L1low_data Script And Check Output
    [Documentation]    Step 4 of the test case: Runs RU_Common_capture_L1low_data script and checks output.
    ...  Validates correct and incorrect parameter handling and error reporting.
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    Logging With Timestamp
    ...  message=Step 4: Run RU_Common_capture_L1low_data Script and Check Output
    ...  style=STEP
    ...  frame=${TRUE}
    ${start_date}  Get Current Date  UTC
    Logging With Timestamp
    ...  message=Running script with RMOD selected: ${rmod_in_scripts_name}
    ...  style=ONGOING
    ${launch_script_output}=  Run Troubleshooting Script  script_name=RU_Common_capture_L1low_data
    Logging With Timestamp
    ...  message=Running script with RMOD selected: ${rmod_in_scripts_name}
    ...  style=DONE
    Check Downloaded Zip File  ${launch_script_output['Collection file']}  script_name=RU_Common_capture_L1low_data  start_date=${start_date}

    Logging With Timestamp
    ...  message=Running script with RMOD selected: ${rmod_in_scripts_name} and cells: ${new_nr_cells}
    ...  style=ONGOING
    ${start_date}  Get Current Date  UTC
    ${launch_script_output}=  Run Troubleshooting Script  script_name=RU_Common_capture_L1low_data  cells_name=${new_nr_cells}
    Logging With Timestamp
    ...  message=Running script with RMOD selected: ${rmod_in_scripts_name} and cells: ${new_nr_cells}
    ...  style=DONE
    Check Downloaded Zip File  ${launch_script_output['Collection file']}  script_name=RU_Common_capture_L1low_data  start_date=${start_date}

    Logging With Timestamp
    ...  message=Running script with incorrect RMOD and CELL values to check error handling
    ...  style=ONGOING
    ${launch_script_output}  Run Troubleshooting Script
    ...    script_name=RU_Common_capture_L1low_data
    ...    cells_name=${WRONG_CELLS_DICT['${RMOD_SERIAL_NUMBER}']}
    ...    timeout=30
    Logging With Timestamp
    ...  message=Running script with incorrect RMOD and CELL values to check error handling
    ...  style=DONE

    Logging With Timestamp
    ...  message=Step 4: Run RU_Common_capture_L1low_data Script and Check Output
    ...  style=DONE

Step 5: Run RU_Common_capture_register_dump Script And Check Output
    [Documentation]    Step 5 of the test case: Runs RU_Common_capture_register_dump script and checks output.
    ...  Validates correct and incorrect parameter handling and error reporting.
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    Logging With Timestamp
    ...  message=Step 5: Run RU_Common_capture_register_dump Script and Check Output
    ...  style=STEP
    ...  frame=${TRUE}
    ${start_date}  Get Current Date  UTC
    Logging With Timestamp
    ...  message=Running script with RMOD selected: ${rmod_in_scripts_name}
    ...  style=ONGOING
    ${launch_script_output}=  Run Troubleshooting Script  script_name=RU_Common_capture_register_dump
    Logging With Timestamp
    ...  message=Running script with RMOD selected: ${rmod_in_scripts_name}
    ...  style=DONE
    Check Downloaded Zip File  ${launch_script_output['Collection file']}  script_name=RU_Common_capture_register_dump  start_date=${start_date}

    Logging With Timestamp
    ...  message=Running script with RMOD selected: ${rmod_in_scripts_name} and cells: ${new_nr_cells}
    ...  style=ONGOING
    ${start_date}  Get Current Date  UTC
    ${launch_script_output}=  Run Troubleshooting Script  script_name=RU_Common_capture_register_dump  cells_name=${new_nr_cells}
    Logging With Timestamp
    ...  message=Running script with RMOD selected: ${rmod_in_scripts_name} and cells: ${new_nr_cells}
    ...  style=DONE
    Check Downloaded Zip File  ${launch_script_output['Collection file']}  script_name=RU_Common_capture_register_dump  start_date=${start_date}

    Logging With Timestamp
    ...  message=Running script with incorrect RMOD and CELL values to check error handling
    ...  style=ONGOING
    ${launch_script_output}  Run Troubleshooting Script  script_name=RU_Common_capture_register_dump
    ...    cells_name=${WRONG_CELLS_DICT['${RMOD_SERIAL_NUMBER}']}
    ...    timeout=30
    Logging With Timestamp
    ...  message=Finished checking error handling when running script with incorrect RMOD and CELL values
    ...  style=DONE

    Logging With Timestamp
    ...  message=Step 5: Run RU_Common_capture_register_dump Script and Check Output
    ...  style=DONE

Run Troubleshooting Script
    [Arguments]  ${script_name}  ${cells_name}=${none}  ${free_text_parameters}=${EMPTY}  ${timeout}=${SCRIPT_TIMEOUT}
    [Documentation]    Runs a troubleshooting script with given parameters and validates the result.
    ...  Handles both successful and error scenarios based on input parameters.
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | script_name            | yes  | Name of the troubleshooting script to run                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | cells_name             | no   | Cell name(s) for the script (optional)                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | free_text_parameters   | no   | Free text parameters for the script (optional)                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                | no   | Timeout for the script execution                                           |
    ...  +========================+======+============================================================================+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    Log  Keys: ${WRONG_CELLS_DICT.keys()}
    ${launch_script_output}  selenium_coam.Launch Troubleshooting Script
    ...  script_name=${script_name}
    ...  cells_name=${cells_name}
    ...  mods_name=${rmod_in_scripts_name}
    ...  script_owner_module=Radio module
    ...  free_text=${free_text_parameters}
    ...  timeout=${timeout}
    IF  '${timeout}' == '${SCRIPT_TIMEOUT}'
        Should Be True  '${launch_script_output['Collection status']}' == 'Collection completed'
        ...    msg=Failed to complete troubleshooting script ${script_name}. Output: ${launch_script_output}
        Should Be True  '${launch_script_output['Launching status']}' == 'Launching succeeded'
        ...    msg=Failed to launch troubleshooting script ${script_name}. Output: ${launch_script_output}
    ELSE
        Should Be True  '${launch_script_output['Collection status']}' == ''
        ...    msg=Expected collection to fail, got: ${launch_script_output['Collection status']}
        Should Be True  '${launch_script_output['Launching status']}' == 'Launching failed, all selected fixed parameter values do not intersect'
        ...    msg=Expected launching to fail with specific message when running script with incorrect RMOD and CELL values
    END
    [Return]  ${launch_script_output}

Check Troubleshooting Script Output
    [Arguments]  ${script_name}  ${owner}=Radio module
    ${script_output}=  admin.Get Troubleshooting Script By Name
    ...  script_name=${script_name}
    ...  timeout=${GENERAL_TIMEOUT}
    ...  detailed_output=${TRUE}
    ...  connection=${BTS_ID}
    ${details}  selenium_coam.Get Troubleshooting Scripts Details
    ...  script_owner_module=Radio module
    ...  script_name=${script_name}
    ...  timeout=120
    Log  ${details}
    Log  ${script_output}
    IF  '${script_output['errorCode']}' != '0' or '${script_output['requestStatus']}' != 'completed'
        Fail  Troubleshooting script ${script_name} did not complete successfully. Error Code: ${script_output['errorCode']}.
        ...  Request Status: ${script_output['requestStatus']}.
    ELSE
        Logging With Timestamp
        ...  message=Checking output of script ${script_name}.
        ...  style=ONGOING
        Should Be True  '${script_output['requestMessage']['scriptName']}' == '${script_name}'
        ...  msg=Expected script name in output parameters to be ${script_name}, but got ${script_output['requestMessage']['scriptName']}
        Should Be True  '${script_output['requestMessage']['scriptOwnerModule']}' == '${owner}'
        ...  msg=Expected owner: '${owner}', got: ${script_output['requestMessage']['scriptOwnerModule']}
        Should Be True  '${script_output['requestMessage']['freeTextParameters']}' == '[]'
        ...  msg=Expected free text parameters in output parameters to be [], but got ${script_output['requestMessage']['freeTextParameters']}
        Should Be True  '${details['Script name']}' == '${script_name}'
        ...  msg=Expected script name in WebEM details to be ${script_name}, but got ${details['Script name']}
        Should Be True  '${details['Script owner module']}' == '${owner}'
        ...  msg=Expected script owner module in WebEM details to be '${owner}', but got ${details['Script owner module']}
        Should Be True  '${details['Supported fixed parameters']}' == 'Cells, RMODs'
    END
    ${RU_common_capture_l1low_data_desc}  Set Variable  'Processing control data (e.g. beamforming control) for active downlink and uplink carriers'
    IF  '${script_name}' == 'RU_Common_capture_IQ_data'
        Should Be True  '${details['Script description']}' == 'Capture IQ data of active downlink and uplink carriers'
        ...  msg=Expected script description to be 'Capture IQ data of active downlink and uplink carriers', but got ${details['Script description']}
    ELSE IF  '${script_name}' == 'RU_Common_capture_L1low_data'
        Should Be True  '${details['Script description']}' == ${RU_common_capture_l1low_data_desc}
        ...  msg=Expected ${script_name} description to be '${RU_common_capture_l1low_data_desc}', but got ${details['Script description']}
    ELSE IF  '${script_name}' == 'RU_Common_capture_register_dump'
        Should Be True  '${details['Script description']}' == 'Snapshot of HW register values for the set of selected components of radio module'
        ...  msg=Expected: 'Snapshot of HW register values for selected radio module components', got: ${details['Script description']}
    END
    Logging With Timestamp
    ...  message=Check Troubleshooting Script Output
    ...  style=DONE

Check Downloaded Zip File
    [Arguments]    ${file_path}  ${script_name}  ${start_date}=${EMPTY}
    Logging With Timestamp
    ...  message=Checking downloaded zip file at ${file_path}
    ...  style=ONGOING
    OperatingSystem.File Should Exist    ${file_path}
    ${parts}  Split String    ${file_path}    /
    ${filename}  Get From List   ${parts}    -1
    Zip Filename Should Match Script Date Pattern  ${filename}    ${script_name}    ${start_date}
    ${file_size}=    Get File Size    ${file_path}
    Should Be True    ${file_size} > 0    msg=Downloaded zip file ${file_path} is empty!
    ${expected_files}=    zip_helpers.Parse Snapshot File List From Zip    ${file_path}
    ${missing}=    zip_helpers.All Expected Files Present In Zip Recursive   ${file_path}   ${expected_files}
    Should Be Empty    ${missing}    msg=Missing files in zip: ${missing}
    Logging With Timestamp
    ...  message=Finished checking downloaded zip file at ${file_path}
    ...  style=DONE

Check Dates In Script Result File
    [Arguments]    ${file_path}    ${start_date}
        date_checker.Check Dates In File    ${file_path}    ${start_date}


Zip Filename Should Match Script Date Pattern
    [Arguments]    ${filename}    ${script_name}    ${date_string}
    ${date}=    Convert Date    ${date_string}    result_format=%Y%m%d
    ${pattern}=    Set Variable    ^SCRIPT_RESULT_${script_name}_${date}-.*\.zip$
    Should Match Regexp    ${filename}    ${pattern}
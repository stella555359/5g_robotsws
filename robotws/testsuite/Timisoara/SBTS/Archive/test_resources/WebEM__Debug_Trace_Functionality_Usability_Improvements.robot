*** Settings ***
Resource    ../../common_resources/ca_WebEM_general.robot

*** Variables ***
${RECOVERY_TIMEOUT}           1200            #Time for SBTS to recover from site reset
${COLLECTION_LOGS_TIMEOUT}    300             #Time for logs to be collected successfully
${BBMOD_TYPE}                                 #BBMOD on which NRCELL must be deployed (can be ABIO or ABIL)

*** Keywords ***
WebEM__Debug_Trace_Functionality_Usability_Improvements
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-24343
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This test is created to find journal.txt file for ABIO or ABIL BBMODs which have 5G cells mapped on them.
    ...  First, site reset is performed to clear checked cells in Debug Tracing page.
    ...  One random NRCELL is chosen and selected in Debug Tracing, L1-IQ Capture panel(UL and DL).
    ...  Save IQ capture panel is opened and 3 parameters are set.
    ...  For ABIO, only L1-IQData archive is downloaded and journal.txt must exist in it.
    ...  For ABIL, L1-IQData and Snapshot archives are downloaded. Journal.txt must be found in Snapshot.
    ...  ******************
    ...  - 22.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24343 - Initial TAT creation
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Add watchdog alarm monitoring
    ...  ******************

    Set Tags        CA-FM  OWNER-cristian.bulea@nokia.com  AUTHOR-anna.benzar@nokia.com
    ...             MAINTAINER-anna.benzar@nokia.com    GROUP_IN_CHARGE-TIM_1_Vrf    PHASE-CRT  SW-SBTS23

    Step0: Set preconditions
    Step1: Open Debug Tracing View
    Step2: Verify L1-IQ capture and select NRCELL
    Step3: Save IQ capture data
    Step4: Verify if journal file exists

Step0: Set preconditions
    Log  \nStep0: Set preconditions  console=true
    Reset SBTS from Admin
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10  Check All Cells  ${OnAirDone_}  ${Enabled_}  ${Active_}
    ${BTS_ID}  Admin Get BTS ID
    Set test variable  ${BTS_ID}
    ${bbmods}  Get parameters for all  BBMOD
    FOR  ${bbmod}  IN  @{bbmods}
        ${status_bbmod_type}  Run keyword and return status  Should contain  ${bbmod}[productName]  ${BBMOD_TYPE}
        ${bbmod_cells}  Run keyword if  ${status_bbmod_type}
        ...  Get cell mapping by module id  ${bbmod}[id]
        ...  ELSE
        ...  Continue for loop
        ${horizontal_position}  ${vertical_position}  Get BBMOD positions  ${bbmod}[id]
        ${NR_CELL_DN}  Get 5G cell mapped on BBMOD  ${bbmod_cells}
        ${cell_status}  Run keyword and return status  Should not be empty  ${NR_CELL_DN}
        Run keyword if  ${cell_status}
        ...  Exit for loop
    END
    ${cell_status}  Run keyword and return status  Should not be empty  ${NR_CELL_DN}
    Run keyword unless  ${cell_status}
    ...  Fail  There is no 5G cell mapped on ${BBMOD_TYPE} BBMOD.
    Set test variable  ${HORIZONTAL_POSITION}  ${horizontal_position}
    Set test variable  ${VERTICAL_POSITION}  ${vertical_position}
    ${NR_CELL}  Fetch from right  ${NR_CELL_DN}  /
    Set test variable  ${NR_CELL}

Step1: Open Debug Tracing View
    Log  \nStep1: Open Debug Tracing View  console=true
    Wait Until Keyword Succeeds  120  5  Click Element  //span[@ui-tooltip='Diagnostic']
    Click Element  //*[contains(text(), "Debug Tracing")]
    Log  Debug Tracing is open!  console=true
    Wait Until Element is Visible  //*[contains(text(), "Activate internal trace")]  60
    ${internal_trace}  Catenate  SEPARATOR=  //*[@id="main-view"]/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div/debug-tracing
    ...  /div/div[2]/log-agent-configuration/div/div[5]/div/div/div/div[1]/ui-button/button
    ${status}  Run keyword and return status  Element Should Be Enabled  ${internal_trace}
    ${trace}  Catenate  SEPARATOR=  //*[@id="main-view"]/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div/debug-tracing/div
    ...  /div[2]/log-agent-configuration/div/div[5]/div/div/div/div[2]/ui-button/button
    Run keyword if  ${status}
    ...  Activate internal trace
    ...  ELSE  run keywords
    ...  Element Should Be Enabled  ${trace}  AND
    ...  Log  Internal trace is already activated!  console=true

Step2: Verify L1-IQ capture and select NRCELL
    Log  \nStep2: Verify L1-IQ capture and select NRCELL  console=true
    Wait Until Element is visible  //div[contains(text(), "L1-IQ capture") and @class='nav-link ng-binding']  60
    Element Should Be Visible  //div[contains(text(), "L1-IQ capture") and @class='nav-link ng-binding']
    Click Element  //div[contains(text(), "L1-IQ capture") and @class='nav-link ng-binding']
    Log  Open L1-IQ capture is performed! console=true
    ${dropdowns}  Get WebElements  //button[@class='btn btn-default dropdown-toggle ui-multiselect-button']
    FOR  ${dropdown}  IN  @{dropdowns}
        Click Element  ${dropdown}
        ${status}  ${cell_to_select}  Run keyword and ignore error
        ...  Get WebElement  //div[contains(@class,'selectlist-multiple open')]//li[contains(@data-value,'${NR_CELL}')]
        Run keyword if  "${status}"=="FAIL"
        ...  Run keywords  Click Element  ${dropdown}  AND  Continue for loop
        ${cell_text}  Get text  ${cell_to_select}
        Click Element  ${cell_to_select}
        Click Element  ${dropdown}
    END
    Click Element  //button[contains(text(),'Apply Configuration') or contains(text(),'Apply configuration')]
    Wait Until Element is visible  //span[contains(text(), "Configuring succeeded.")]  30

Step3: Save IQ capture data
    Log  \nStep3: Save IQ capture data  console=true
    Click Element  //*[contains(text(), "Save IQ capture data")]
    Log  Open Save IQ capture is performed!  console=true
    ${sfn_input}  Get WebElement  //ui-text-input[@a-label='SFN']//input
    ${interval}  Catenate  SEPARATOR=  //*[@id="main-view"]/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div/debug-tracing
    ...  /div/div[2]/section/div/expansion-panel[2]/div[2]/div/u-plane-component/section/div/tracing-cells-content/div/l1-iq-capture/
    ...  div/div/div/div[2]/div[1]/div[3]
    ${interval_text}  Get text  ${interval}
    ${sfn_value}  Fetch from right  ${interval_text}  .
    ${sfn_value}  Fetch from left  ${sfn_value}  ]
    Input Text  ${sfn_input}  ${sfn_value}
    ${slot_input}  Get WebElement  //ui-text-input[@a-label='SLOT']//input
    Input Text  ${slot_input}  0
    Click Element  //button[@class='btn btn-default dropdown-toggle']
    Click Element  //*[contains(text(), "Start a new scheduled capture")]
    Click Element  //button[contains(text(),"Save IQ capture data")]
    Wait Until Element is visible  //span[contains(text(), "Save succeeded.")]  60

Step4: Verify if journal file exists
    Log  \nStep4: Verify if journal file exists  console=true
    Sleep  60s  Wait for file to be generated
    ${current_date}  Get current date
    ${current_date}  Fetch from left  ${current_date}  ${SPACE}
    ${current_date}  Remove string using regexp  ${current_date}  -
    Create Directory  ${BTSFiles}/Debug_Trace_Files
    ${debug_trace_directory}  Set variable  ${BTSFiles}/Debug_Trace_Files
    ${files_list}  OperatingSystem.List files in directory  /home/ute/Downloads  absolute=True
    FOR  ${file}  IN  @{files_list}
        ${status_file_name}  Run keyword and return status  Should match regexp  ${file}  .*L1IQData_MRBTS-${BTS_ID}.*${current_date}.*.tgz
        Run keyword if  ${status_file_name}
        ...  Run keywords  OperatingSystem.Move File  ${file}  ${debug_trace_directory}/L1IQData_${BTS_ID}.tgz
        ...  AND  Remove file  ${file}
    END
    ${l1_iq_capture_archive}  Set variable  ${debug_trace_directory}/L1IQData_${BTS_ID}.tgz
    ${status_file}  Run keyword and return status  OperatingSystem.File should exist  ${l1_iq_capture_archive}
    Run keyword unless  ${status_file}
    ...  Fail  L1IQCapture file not generated correctly.
    Run keyword if  '${BBMOD_TYPE}' == 'ABIO'
    ...  Verify journalLog.txt for ABIO  ${debug_trace_directory}  ${l1_iq_capture_archive}
    ...  ELSE
    ...  Verify journal.txt for ABIL  ${debug_trace_directory}

Get BBMOD positions
    [Arguments]  ${bbmod_dn}
    ${parameters}  coam.Get parameters  ${bbmod_dn}
    ${horizontal}  Set variable  ${parameters}[horizontalPosition]
    ${vertical}  Set variable  ${parameters}[verticalPosition]
    [Return]  ${horizontal}  ${vertical}

Get 5G cell mapped on BBMOD
    [Arguments]  ${all_cells}
    FOR  ${cell_dn}  IN  @{all_cells}
        ${status_cell}  Run keyword and return status  Should contain  ${cell_dn}  NRCELL
        Run keyword if  ${status_cell}
        ...  Return from keyword  ${cell_dn}
    END
    [Return]  ${None}

Verify journalLog.txt for ABIO
    [Arguments]  ${debug_trace_directory}  ${l1_iq_capture_archive}
    ${return_code}  ${output_file_archive}  OperatingSystem.Run and return rc and output  tar -xvzf ${l1_iq_capture_archive}
    Run keyword if  ${return_code} != 0
    ...  Fail  Not able to untar file: ${l1_iq_capture_archive}.
    Create Directory  ${debug_trace_directory}/L1IQData_${BTS_ID}
    ${return_code}  OperatingSystem.Run And Return Rc  tar -xzvf ${output_file_archive} -C ${debug_trace_directory}/L1IQData_${BTS_ID}
    Run keyword if  ${return_code} != 0
    ...  Fail  Not able to untar given file: ${output_file_archive}.
    ${journal_file_status}  Run keyword and return status
    ...  OperatingSystem.File should exist  ${debug_trace_directory}/L1IQData_${BTS_ID}/journalLog.txt
    Run keyword if  ${journal_file_status}
    ...  Log  Journal file: ${debug_trace_directory}/L1IQData_${BTS_ID}/journalLog.txt  console=true
    ...  ELSE
    ...  Fail  journalLog.txt not generated [NOK].

Verify journal.txt for ABIL
    [Arguments]  ${debug_trace_directory}
    ${snapshot_zip}  Collect snapshot zip file
    ${snapshot_directory}  Set variable  Snapshot_${CURRENT_TIME}
    ${return_code}  OperatingSystem.Run and return rc  unzip ${snapshot_zip} -d ${debug_trace_directory}/${snapshot_directory}
    Run keyword if  ${return_code} != 0
    ...  Fail  Not able to unzip given file:${snapshot_zip}.
    ${snapshot_file_status}  Run keyword and return status
    ...  OperatingSystem.File Should Exist  ${debug_trace_directory}/${snapshot_directory}/snapshot_file_list.txt
    Run keyword unless  ${snapshot_file_status}
    ...  Fail  snapshot_file_list.txt does not exist.
    ${command}  Catenate  SPEARATOR=  tr '\n' , < ${debug_trace_directory}/${snapshot_directory}/snapshot_file_list.txt |
    ...  grep -o .*BTS${BTS_ID}_${HORIZONTAL_POSITION}${VERTICAL_POSITION}.*D_syslog\.tgz | tr , '\n'
    ${command_output}  OperatingSystem.Run  ${command}
    ${matches}  Get regexp matches  ${command_output}  BTS${BTS_ID}.*D_part.*\.zip
    ${part_file_archive}  Get From List  ${matches}  -1
    ${tgz_archive}   Unzip current archive and return searched file
    ...  ${debug_trace_directory}/${snapshot_directory}/${part_file_archive}  .zip  D_syslog.tgz
    ${journal_file}  Unzip current archive and return searched file  ${tgz_archive}  .tgz  journal
    Log  Journal file: ${journal_file}  console=true

Unzip current archive and return searched file
    [Arguments]  ${full_archive_name}  ${extension}  ${file_to_find}
    ${folder_name}  Fetch from left  ${full_archive_name}  ${extension}
    Create directory  ${folder_name}
    Run keyword if  '${extension}'=='.zip'
    ...  OperatingSystem.Run  unzip ${full_archive_name} -d ${folder_name}
    ...  ELSE
    ...  OperatingSystem.Run  tar -xzvf ${full_archive_name} -C ${folder_name}
    ${files}  OperatingSystem.List Files In Directory  ${folder_name}
    FOR  ${file}  IN  @{files}
        ${file_status}  Run keyword and return status  Should contain  ${file}  ${file_to_find}
        ${matched_file}  Run keyword if  ${file_status}
        ...  Set variable  ${file}
        ${file_status}  Run keyword and return status  Should not be empty  ${matched_file}
        Exit for loop if  ${file_status}
    END
    ${file_status}  Run keyword and return status  Should not be empty  ${matched_file}
    Run keyword unless  ${file_status}
    ...  Fail  No file found in ${folder_name} that matches ${file_to_find}. [NOK]
    [Return]  ${folder_name}/${matched_file}

Collect snapshot zip file
    Log  Open Snapshop menu!  console=true
    Click Element  xpath://*[contains(text(), "Diagnostic")]
    Click Element  xpath://*[contains(text(), "Snapshot")]
    Log  Complete coverage with all log files...  console=true
    Click Element  xpath://*[contains(text(), "All log files")]
    Log  Coverage was completed successfully!  console=true
    Log  Complete save location with local...  console=true
    Click Element  xpath://*[contains(text(), "Local")]
    Log  Save location was completed successfully!  console=true
    Log  Verify Collect Snapshot button to be enabled!  console=true
    ${status}  Run keyword and return status  Element Should Be Enabled  xpath=//*[contains(@a-text, 'Collect Snapshot')]
    Run keyword if  ${status}
    ...  Log  Collect Snapshot Button is enabled![OK]  console=true
    ...  ELSE
    ...  Fail  Collect Snapshot Button is not enabled![NOK]
    ${SBTS_name}  Get Text  //*[@id="main-view"]/div/div[1]/div[1]/div/div[1]/div[1]/div[2]/div[2]
    Remove File  /home/ute/Downloads/Snapshot_MRBTS-${BTS_ID}_${SBTS_name}_${active SW version}_*.zip
    Log  Collecting snapshot will be performed...  console=true
    Wait until keyword succeeds  60  5  Click Element  xpath=//*[contains(@a-text, 'Collect Snapshot')]
    ${status}  Run keyword and return status  Wait until keyword succeeds  ${COLLECTION_LOGS_TIMEOUT}  10  Element Should Be Visible
    ...  //*[contains(text(), 'Collection completed')]
    Run keyword if  ${status}
    ...  Log  Text "Collection completed" appeard![OK]  console=true
    ...  ELSE
    ...  Fail  Text "Collection completed" did not appeard![NOK]
    ${CURRENT_TIME}  DateTime.Get Current Date    result_format=%Y.%m.%d-%H:%M    exclude_millis=True
    Set test variable   ${CURRENT_TIME}
    Wait until created  /home/ute/Downloads/Snapshot_MRBTS-${BTS_ID}_${SBTS_name}_${active SW version}_*.zip
    Move file  /home/ute/Downloads/Snapshot_MRBTS-${BTS_ID}_${SBTS_name}_${active SW version}_*.zip
    ...  ${BTSFiles}/Debug_Trace_Files/Snapshot_MRBTS-${BTS_ID}_${SBTS_name}_${active SW version}_${CURRENT_TIME}.zip
    [Return]  ${BTSFiles}/Debug_Trace_Files/Snapshot_MRBTS-${BTS_ID}_${SBTS_name}_${active SW version}_${CURRENT_TIME}.zip


TC Setup
    Common Test Setup  tc_name=WebEM__Debug_Trace_Functionality_Usability_Improvements
    WebEM Setup

TC Teardown
    WebEM Teardown
    Common Test Teardown

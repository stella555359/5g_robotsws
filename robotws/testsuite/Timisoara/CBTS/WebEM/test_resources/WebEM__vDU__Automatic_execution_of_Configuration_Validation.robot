*** Settings ***
Documentation
    ...  This TC is created to verify Diagnostic check in 5 ways.
    ...  First, Diagnostic files are verified at the beginning of the test.
    ...  Second, Diagnostic files are verified after SCF full commissioning.
    ...  Third, Site reset is performed and check is done.
    ...  Fourth and fifth time, certain parameters are set to schedule Diagnostic check at a given time.
    ...  At the end of the test generic snapshot is collected, and Diagnostic files should not be generated.

Library  ../../common_resources/python_resources/csv_resource.py
Resource  ../../common_resources/vdu_frame.robot
Resource  ../resources/vdu_WebEM_general.robot


*** Variables ***
${RESTORE_TIMEOUT}  15m  # Timeout for vDU to recover after SCF upload


*** Keywords ***
TC__WebEM__vDU__Automatic_execution_of_Configuration_Validation
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-27188
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  25.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27188 - Initial TAT creation
    ...  09.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29831 - Change method of retrieving pod and container name
    ...  ******************

    Set Tags  CA-WebEM  OWNER-marius.stanescu@nokia.com  MAINTAINER-anna.benzar@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  FEATURE-CB009129

    Step0: TC Preconditions
    Step1: Open Ssh Connection To VDU And Check Diagnostic Files
    Step2: Load SCF - Full Commissioning
    Step3: Open Ssh Connection To VDU And Check Diagnostic Files - Automatic
    Step4: Perform VDU Reset
    Step5: Open Ssh Connection To VDU And Check Diagnostic Files - Automatic
    Step6: Schedule Diagnostic Check On Current Day
    Step7: Open Ssh Connection To VDU And Check Diagnostic Files - Scheduled
    Step8: Schedule Diagnostic Check On Another Day
    Step9: Open Ssh Connection To VDU And Check No New Diagnostic Files Collected
    Step10: Collect Snapshot From VDU
    Step11: Open Ssh Connection To VDU And Check No New Diagnostic Files Collected


Step0: TC Preconditions
    Log  \nStep0: TC Preconditions.  console=true
    ${current_day}  Get Current Date  result_format=%A
    ${week_days}  Create List  Monday  Tuesday  Wednesday  Thursday  Friday  Saturday  Sunday
    ${wrong_day}  Evaluate  random.choice(${week_days})  random
    Set Test Variable  ${WEEK_DAYS}
    Set Test Variable  ${CURRENT_DAY}
    Set Test Variable  ${WRONG_DAY}


Step1: Open Ssh Connection To VDU And Check Diagnostic Files
    Log  \nStep1: Open ssh connection to vDU and check Diagnostic files.  console=true
    Open Connection To VDU And Bring Diagnostic Files To Local Machine  cran1  oamcm  1
    Log  Diagnostic files are present on vDU at the beginning of the test.  console=true
    Open SSH Connection To VDU And Connect To Openshift
    ${pod}  Get Full Name For Pod  ${VDU_CRAN}  oamcm
    ${container}  Get Full Name For Container  ${VDU_CRAN}  oamcm
    ${delete_command}  Catenate  oc exec -it -n cran1 ${pod} -c ${container} -- rm -rf  /mnt/services/SS_OAM/ASM/working_dir/diagnostic_check
    SSHLibrary.Write  ${delete_command}
    SSHLibrary.Read Until Prompt

    [Teardown]  SSHLibrary.Close Connection


Step2: Load SCF - Full Commissioning
    Log  \nStep2: Load SCF - full commissioning.  console=true
    ${current_date_time}  Get Current Time For Diagnostic Check
    Set Test Variable  ${CURRENT_DATE_TIME}
    vdu.Perform Commissioning  ${VDU_SCF_PATH}
    Wait Until Keyword Succeeds  ${RESTORE_TIMEOUT}  10s
    ...  Verify RMODs Parameter From VDU  operational_state  ${ENABLED}
    Wait Until Keyword Succeeds  ${RESTORE_TIMEOUT}  10s
    ...  Verify RMODs Parameter From VDU  availability_status  ${ONLINE}
    Wait Until Keyword Succeeds  ${RESTORE_TIMEOUT}  10s
    ...  Verify RMODs Parameter From VDU  administrative_state  ${UNLOCKED}
    Wait Until Keyword Succeeds  ${RESTORE_TIMEOUT}  10s
    ...  Check All Cells From VDU  operational_state=${ENABLED}  availability_status=${ONLINE}  administrative_state=${UNLOCKED}
    Log  All services are operational after SCF actvation. [OK]  console=true


Step${index}: Open Ssh Connection To VDU And Check Diagnostic Files - ${type}
    Log  \nStep${index}: Open ssh connection to vDU and check Diagnostic files.  console=true
    Open Connection To VDU And Bring Diagnostic Files To Local Machine  cran1  oamcm  ${index}
    ${csv_content}  Return Csv File Content  ${TEST_RESULTS_DIR}/Diagnostic_Check_step_${index}/DiagnosticReport.csv
    Verify first row in DiagnosticReport.Csv File  ${csv_content}
    Verify second row in DiagnosticReport.Csv File  ${csv_content}  ${VDU_MRBTS_ID}  ${type}  OK  ${CURRENT_DATE_TIME}
    Verify third row in DiagnosticReport.Csv File  ${csv_content}  ${VDU_MRBTS_ID}  ${type}  OK  ${CURRENT_DATE_TIME}
    Log  All Diagnostic files fields are correctly set.  console=true


Step4: Perform VDU Reset
    Log  \nStep4: Perform vDU reset.  console=true
    ${current_date_time}  Get Current Time For Diagnostic Check
    Set Test Variable  ${CURRENT_DATE_TIME}
    vdu.Reset Vdu  timeout=120
    Log  Reset vDU is performed![OK]  console=true
    Wait Until Keyword Succeeds  300s  10s
    ...  Check All Cells From VDU  availability_status=${OFFLINE}  operational_state=${DISABLED}
    Log  Cells are Offline and Disabled![OK]  console=true
    Wait Until Keyword Succeeds  ${RESTORE_TIMEOUT}  10s
    ...  Check All Cells From VDU  availability_status=${ONLINE}  operational_state=${ENABLED}
    Log  All services are operational after vDU reset. [OK]  console=true


Step6: Schedule Diagnostic Check On Current Day
    Log  \nStep6: Schedule Diagnostic Check on current day.  console=true
    VDU WebEM Setup
    Click Element  ${VDU_PARAMETER_EDITOR}
    Create Duplicate Plan For CBTS
    ${current_date_time}  Get Current Time For Diagnostic Check
    Set Test Variable  ${CURRENT_DATE_TIME}
    ${time}  Add Time To Date  ${CURRENT_DATE_TIME}  3 min  exclude_millis=True
    ${time}  Fetch From Right  ${time}  ${SPACE}
    Wait Until Keyword Succeeds  30s  2s
    ...  Input Text  //*[@id="laf-component"]/blocks-plan-toolbar/div/cem-toolbar/div/div[2]/div/ot-search/div/div/input  diagnosticCheckSchedule
    Press Keys  //*[@id="laf-component"]/blocks-plan-toolbar/div/cem-toolbar/div/div[2]/div/ot-search/div/div/input  ENTER
    Sleep  5s  Time for page to be loaded.
    Run Keyword And Ignore Error
    ...  Click Element  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[1]/td[5]/p-button[1]/button/span[1]
    Wait Until Keyword Succeeds  30s  2s
    ...  Page Should Contain  Check Days
    ${DROPDOWN_PATH}  Catenate  SEPARATOR=  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[3]/td[4]/cem-parameter-input/cem-bitmask-input
    ...  /div/cem-bitmask/p-multiselect/div/div[2]
    Click Element  ${DROPDOWN_PATH}
    Set Test Variable  ${DROPDOWN_PATH}
    Sleep  3s  Wait for dropdown to appear.
    FOR  ${day}  IN  @{WEEK_DAYS}
        Run Keyword And Ignore Error
        ...  Click Element  //*[contains(@aria-label,'${day}') and contains(@class,'p-ripple p-element p-multiselect-item p-highlight')]/div/div
    END
    Click Element  //*[contains(@aria-label,'${CURRENT_DAY}') and contains(@class,'p-ripple p-element p-multiselect-item')]/div/div
    Input Text
    ...  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[4]/td[4]/cem-parameter-input/cem-string-input/ot-field/div/input
    ...  ${time}
    Validate And Activate Plan For Unified CBTS
    Log  Wait 3 minutes to check Diagnostic files.  console=true
    Sleep  3 min


Step8: Schedule Diagnostic Check On Another Day
    Log  \nStep8: Schedule Diagnostic Check on another day.  console=true
    Wait Until Keyword Succeeds  30s  2s
    ...  Create Duplicate Plan For CBTS
    ${current_date_time}  Get Current Time For Diagnostic Check
    Set Test Variable  ${CURRENT_DATE_TIME}
    ${time}  Add Time To Date  ${CURRENT_DATE_TIME}  3 min  exclude_millis=True
    ${time}  Fetch From Right  ${time}  ${SPACE}
    Wait Until Keyword Succeeds  30s  2s
    ...  Input Text  //*[@id="laf-component"]/blocks-plan-toolbar/div/cem-toolbar/div/div[2]/div/ot-search/div/div/input  diagnosticCheckSchedule
    Press Keys  //*[@id="laf-component"]/blocks-plan-toolbar/div/cem-toolbar/div/div[2]/div/ot-search/div/div/input  ENTER
    Sleep  5s  Time for page to be loaded.
    Wait Until Keyword Succeeds  30s  2s
    ...  Page Should Contain  Check Days
    Click Element  ${DROPDOWN_PATH}
    Sleep  3s  Wait for dropdown to appear.
    FOR  ${day}  IN  @{WEEK_DAYS}
        Run Keyword And Ignore Error
        ...  Click Element  //*[contains(@aria-label,'${day}') and contains(@class,'p-ripple p-element p-multiselect-item p-highlight')]/div/div
    END
    Click Element  //*[contains(@aria-label,'${WRONG_DAY}') and contains(@class,'p-ripple p-element p-multiselect-item')]/div/div
    Input Text
    ...  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[4]/td[4]/cem-parameter-input/cem-string-input/ot-field/div/input
    ...  ${time}
    Validate And Activate Plan For Unified CBTS
    Log  Wait 3 minutes to check Diagnostic files.  console=true
    Sleep  3 min


Step${index}: Open Ssh Connection To VDU And Check No New Diagnostic Files Collected
    Log  \nStep${index}: Open ssh connection to vDU and check no new Diagnostic files collected.  console=true
    Open Connection To VDU And Bring Diagnostic Files To Local Machine  cran1  oamcm  ${index}
    ${csv_content}  Return Csv File Content  ${TEST_RESULTS_DIR}/Diagnostic_Check_step_${index}/DiagnosticReport.csv
    Verify first row in DiagnosticReport.Csv File  ${csv_content}
    ${second_row_status}  Run Keyword And Return Status
    ...  Verify second row in DiagnosticReport.Csv File  ${csv_content}  ${VDU_MRBTS_ID}  Scheduled  OK  ${CURRENT_DATE_TIME}
    Run Keyword If  ${second_row_status} != ${FALSE}
    ...  Fail  Diagnostic files collection time not correct. [NOK]
    ${third_row_status}  Run Keyword And Return Status
    ...  Verify third row in DiagnosticReport.Csv File  ${csv_content}  ${VDU_MRBTS_ID}  Scheduled  OK  ${CURRENT_DATE_TIME}
    Run Keyword If  ${third_row_status} != ${FALSE}
    ...  Fail  Diagnostic files collection time not correct. [NOK]
    Log  Diagnostic files were not collected after setting wrong day. [OK]  console=true


Step10: Collect Snapshot From VDU
    Log  \nStep10: Collect snapshot from vDU.  console=true
    Collect VDU Snapshot  directory_name=Snapshot
    Log  Snapshot was saved in ${TEST_RESULTS_DIR}/Snapshot directory![OK]  console=true


TC Setup
    Common VDU Setup
    Modify Resource Search Order  WebEM__vDU__Automatic_execution_of_Configuration_Validation


TC Teardown
    Run Keyword If Test Failed
    ...  Delete Actual Plan Via WebEM
    VDU WebEM Teardown
    Common VDU Teardown

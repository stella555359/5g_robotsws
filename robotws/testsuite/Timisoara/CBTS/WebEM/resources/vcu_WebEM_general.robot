*** Settings ***
Documentation  *AUTHOR*: andreea.burtic@nokia.com
...  This resource is used for vCU WebEM TCs that contain common KWs, both from old GUI and from the new GUI.

Library  SeleniumLibrary  run_on_failure=Nothing
Resource  WebEM_general.robot
Resource  WebEM_general_${GUI_VERSION}_GUI.robot
Resource  vcu_WebEM_general_${GUI_VERSION}_GUI.robot


*** Variables ***
${GUI_VERSION}  new  # GUI version can be old or new. The new GUI is for software releases newer or equal to 25R1.


*** Keywords ***
VCU WebEM Teardown
    [Documentation]  This keyword is used to vCU WebEM Teardown.

    Run Keyword If Test Failed
    ...  Capture Page Screenshot  Snapshot_after_test_failed.png
    Logout From CBTS
    Close Browser


VCU WebEM Setup
    [Documentation]  This keyword is used to vCU WebEM Setup.
    [Arguments]  ${timeout}=90s

    Set Screenshot Directory  ${TEST_RESULTS_DIR}/selenium_screenshot_${TEST_NAME}
    Open VCU WebEM  timeout=${timeout}


Open VCU WebEM
    [Documentation]  This keyword opens the vCU WebEM in chrome browser and maximizes the window.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${timeout}

    ${chrome_options}  Evaluate  sys.modules['selenium.webdriver'].ChromeOptions()  sys, selenium.webdriver
    ${prefs}  Create Dictionary  download.default_directory=/home/ute/Downloads
    Call Method  ${chrome_options}  add_experimental_option  prefs  ${prefs}
    Call Method  ${chrome_options}  add_argument  --ignore-ssl-errors
    Call Method  ${chrome_options}  add_argument  --ignore-certificate-errors
    Call Method  ${chrome_options}  add_argument  --disable-popup-blocking
    Call Method  ${chrome_options}  add_argument  --headless
    Create Webdriver  Chrome  options=${chrome_options}
    Go To  https://${VCU_OAM_IP}
    Set Window Size  ${1920}  ${1400}
    Check Private Connection From CBTS
    Wait Until Keyword Succeeds  30s  2s  Login On CBTS
    Confirm Legal Notice From CBTS
    Log  Wait until the page is loaded!  console=true
    Wait Until Element Is Visible  //span[contains(@class, 'title') and contains(text(), 'DUs Status Summary')]  ${timeout}
    ...  WebElement is not fully loaded in ${timeout} seconds.
    Capture Page Screenshot  vCU_WebEM_initial_state.png


Open Remote VDU WebEM From VCU
    [Documentation]  This keyword opens the vDU WebEM in chrome browser remotely on vCU VM and maximizes the window.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    ${chrome_options}  Evaluate  sys.modules['selenium.webdriver'].ChromeOptions()  sys, selenium.webdriver
    ${prefs}  Create Dictionary  download.default_directory=/home/ute/Downloads
    Call Method  ${chrome_options}  add_experimental_option  prefs  ${prefs}
    Call Method  ${chrome_options}  add_argument  --ignore-ssl-errors
    Call Method  ${chrome_options}  add_argument  --ignore-certificate-errors
    Call Method  ${chrome_options}  add_argument  --disable-popup-blocking
    Call Method  ${chrome_options}  add_argument  --headless
    ${options}  Call Method  ${chrome_options}  to_capabilities
    Create Webdriver  Remote  command_executor=http://${VDU_OAM_IP}:10020  desired_capabilities=${options}
    Go To  https://${VDU_OAM_IP}
    Set Window Size  ${1920}  ${1800}
    Check Private Connection From CBTS
    Login On CBTS
    Confirm Legal Notice From CBTS
    Log  Wait until the page is loaded.  console=true
    Wait Until Element Is Visible  //span[contains(@class, 'title') and contains(text(), 'Radio Modules Status Summary')]  30s
    ...  WebElement is not fully loaded in 30s seconds.
    Capture Page Screenshot  remote_vDU_WebEM_initial_state.png


Get List Of Active Fault Ids From vCU WebEM
    [Documentation]  This keyword is used to get a list with active fault ids from vCU WebEM.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Click Element  ${VCU_ALARMS}
    Sleep  20s
    ${active_fault_ids}  Create List
    ${alarm_table_tr}  SeleniumLibrary.Get Element Count  //*[contains(@class, "p-element p-datatable-tbody ng-star-inserted")]/tr
    FOR  ${tr}  IN RANGE  1  ${alarm_table_tr}+1
        IF  ${tr} == 1
            ${fault_id}  Get Text  //*[contains(@class, "p-element p-datatable-tbody ng-star-inserted")]/tr/td[5]
        ELSE
            ${fault_id}  Get Text  //*[contains(@class, "p-element p-datatable-tbody ng-star-inserted")]/tr[${tr}]/td[5]
        END
        Append To List  ${active_fault_ids}  ${fault_id}
    END

    RETURN  ${active_fault_ids}


Get List Of Active Alarm Ids From vCU WebEM
    [Documentation]  This keyword is used to get a list with active alarm ids from vCU WebEM.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Click Element  ${VCU_ALARMS}
    Sleep  20s
    ${active_alarm_ids}  Create List
    ${alarm_table_tr}  SeleniumLibrary.Get Element Count  //*[contains(@class, "p-element p-datatable-tbody ng-star-inserted")]/tr
    FOR  ${tr}  IN RANGE  1  ${alarm_table_tr}+1
        IF  ${tr} == 1
            ${alarm_id}  Get Text  //*[contains(@class, "p-element p-datatable-tbody ng-star-inserted")]/tr/td[3]
        ELSE
            ${alarm_id}  Get Text  //*[contains(@class, "p-element p-datatable-tbody ng-star-inserted")]/tr[${tr}]/td[3]
        END
        Append To List  ${active_alarm_ids}  ${alarm_id}
    END

    RETURN  ${active_alarm_ids}


Save Statictics File And Move It To Test Results Directory For vCU
    [Documentation]  This keyword is used to save statistics file and move it to test results directory.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${operation_time}

    Click Element  //*[@id="laf-component"]/blocks-suppressed-alarm/div/div/cem-toolbar/div/div[1]/div[3]/p-button/button/span[1]
    Log  Save button for statistics file was pushed!  console=true
    ${DATE_FOR_TXT}  Get Current Date  result_format=%Y%m%d
    Set Test Variable  ${DATE_FOR_TXT}
    Wait Until Created  /home/ute/Downloads/MRBTS-${VCU_MRBTS_ID}_${VCU_MRBTS_NAME}_SuppressedAlarms_${DATE_FOR_TXT}-*.txt  timeout=120s
    Move File  /home/ute/Downloads/MRBTS-${VCU_MRBTS_ID}_${VCU_MRBTS_NAME}_SuppressedAlarms_${DATE_FOR_TXT}-*.txt
    ...  ${TEST_RESULTS_DIR}/MRBTS-${VCU_MRBTS_ID}_${VCU_MRBTS_NAME}_SuppressedAlarms_${DATE_FOR_TXT}_${operation_time}.txt
    Log  Location: ${TEST_RESULTS_DIR}/MRBTS-${VCU_MRBTS_ID}_${VCU_MRBTS_NAME}_SuppressedAlarms_${DATE_FOR_TXT}_${operation_time}.txt  console=true


Verify Generated Fault Info From The Statistics File With Suppressed Alarms For vCU
    [Documentation]  This keyword is used to verify the generated eac fault info from the statistics file with suppressed alarms.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${file_content}  ${alarm_id}  ${alarm_name}  ${fault_id}  ${fault_name}

    ${date}  Get Current Date  result_format=%d.%m.%Y
    Should Contain  ${file_content}  minor  The file doesn't contains severity minor![NOK]
    Log  The saved file contains severity minor![OK]  console=true
    Should Contain  ${file_content}  ${alarm_id}
    ...  The file doesn't contains alarm id ${alarm_id}![NOK]
    Log  The saved file contains alarm id ${alarm_id}![OK]  console=true
    Should Contain  ${file_content}  ${alarm_name}
    ...  The file doesn't contains alarm name '${alarm_name}'![NOK]
    Log  The saved file contains alarm name '${alarm_name}'![OK]  console=true
    Should Contain  ${file_content}  ${fault_id}
    ...  The file doesn't contains fault id ${fault_id}![NOK]
    Log  The saved file contains fault id ${fault_id}![OK]  console=true
    Should Contain  ${file_content}  ${fault_name}
    ...  The file doesn't contains fault name '${fault_name}'![NOK]
    Log  The saved file contains fault name '${fault_name}'![OK]  console=true
    Should Contain  ${file_content}  ${date}  The file doesn't contains ${date}![NOK]
    Log  The saved file contains ${date}![OK]  console=true


Disable actAlarmsSuppression Parameter And Delete Instances For vCU
    [Documentation]  This keyword is used to disabled actAlarmsSuppression parameter and deleted instances.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    ${actAlarmsSuppression_parameter}  Create Dictionary  parameterName=actAlarmsSuppression  value=disabled  operation=update
    ${allowedAlarmList_parameter}  Create Dictionary  parameterName=allowedAlarmList  operation=delete
    ${allowedFaultList_parameter}  Create Dictionary  parameterName=allowedFaultList  operation=delete
    ${suppressedAlarmList_parameter}  Create Dictionary  parameterName=suppressedAlarmList  operation=delete
    ${suppressedFaultList_parameter}  Create Dictionary  parameterName=suppressedFaultList  operation=delete
    ${parameters_change_list}  Create List  ${actAlarmsSuppression_parameter}  ${allowedAlarmList_parameter}  ${allowedFaultList_parameter}
    ...  ${suppressedAlarmList_parameter}  ${suppressedFaultList_parameter}
    ${actAlarmsSuppression_changed_parameter}  Create Dictionary  distName=MRBTS-${VCU_MRBTS_ID}/MNL-1/MNLENT-1/FMCADM-1/ALARMSUPP-1
    ...  operation=update  parameters=${parameters_change_list}
    ${changed_parameters_list}  Create List  ${actAlarmsSuppression_changed_parameter}
    ${changed_parameters_string}  Evaluate  json.dumps(${changed_parameters_list})  json
    Log  Parameter actAlarmsSuppression was changed to disabled![OK]  console=true
    Log  Parameters allowedAlarmList, allowedFaultList, suppressedAlarmList and suppressedFaultList was deleted![OK]  console=true
    vcu.Perform Delta Recommissioning  ${changed_parameters_string}
    Log  Operation was done successfully!  console=true


Generate Fault Id 4592 On vCU And Verify If Fault Is Visible In Active Alarms
    [Documentation]  This keyword is used to Generate Fault Id 4592 On vCU And Verify If Fault Is Visible In Active Alarms.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${timeout}

    ${fault4592CancellationTimer_parameter}  Create Dictionary  parameterName=fault4592CancellationTimer  value=1800  operation=update
    ${fault4592CancellationTimer_parameter_change_list}  Create List  ${fault4592CancellationTimer_parameter}
    ${fault4592CancellationTimer_changed_parameter}  Create Dictionary  distName=MRBTS-${VCU_MRBTS_ID}/MNL-1/MNLENT-1/FMCADM-1  operation=update
    ...  parameters=${fault4592CancellationTimer_parameter_change_list}
    ${changed_parameters_list}  Create List  ${fault4592CancellationTimer_changed_parameter}
    ${changed_parameters_string}  Evaluate  json.dumps(${changed_parameters_list})  json
    Log  Parameter fault4592CancellationTimer was updated with value 1800s![OK]  console=true
    vcu.Perform Delta Recommissioning  ${changed_parameters_string}
    Log  Operation was done successfully!  console=true
    vcu.Reset Cu
    ${ip_adresses}  Create List  ${VCU_OAM_IP}
    ${ping_lost_status}  Run Keyword And Return Status
    ...  ping.Wait For No Ping  ip_addresses=${ip_adresses}  timeout=120s
    Run Keyword If  ${ping_lost_status} == ${FALSE}
    ...  Fail  Ping not lost after vCU reset. [NOK]
    ${ping_regained_status}  Run Keyword And Return Status
    ...  ping.Wait For Ping  ip_addresses=${ip_adresses}  timeout=300s
    Run Keyword If  ${ping_regained_status} == ${FALSE}
    ...  Fail  Ping not regained after vCU reset. [NOK]
    Log  vCU reset is performed![OK]  console=true
    Wait Until Keyword Succeeds  ${timeout}  10s
    ...  Check VDU To Be OnAir
    Wait Until Keyword Succeeds  ${timeout}  10s
    ...  Verify CU X2 Links States  ${AVAILABLE}  ${UNLOCKED}
    Wait Until Keyword Succeeds  ${timeout}  10s
    ...  Check Cells On VDU To Be OnAir
    Log  vDU, cells and X2 Links are back on air! [OK]  console=true
    ${active_faults_id_list}  Get List Of Active Fault Ids From vCU WebEM
    List Should Contain Value  ${active_faults_id_list}  4592
    Log  Fault Id 4592 is visible on WebEM before suppression![OK]  console=true
    ${active_alarms_id_list}  Get List Of Active Alarm Ids From vCU WebEM
    List Should Contain Value  ${active_alarms_id_list}  7115
    Log  Alarm Id 7115 is visible on WebEM before suppression![OK]  console=true


Cancel Fault 4592 And Change fault4592CancellationTimer To Be 30s
    [Documentation]  This keyword is used to Cancel Fault 4592 And Change fault4592CancellationTimer To Be 30s.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${timeout}

    ${fault4592CancellationTimer_parameter}  Create Dictionary  parameterName=fault4592CancellationTimer  value=30  operation=update
    ${fault4592CancellationTimer_parameter_change_list}  Create List  ${fault4592CancellationTimer_parameter}
    ${fault4592CancellationTimer_changed_parameter}  Create Dictionary  distName=MRBTS-${VCU_MRBTS_ID}/MNL-1/MNLENT-1/FMCADM-1  operation=update
    ...  parameters=${fault4592CancellationTimer_parameter_change_list}
    ${changed_parameters_list}  Create List  ${fault4592CancellationTimer_changed_parameter}
    ${changed_parameters_string}  Evaluate  json.dumps(${changed_parameters_list})  json
    Log  Parameter fault4592CancellationTimer was updated with value 30s![OK]  console=true
    vcu.Perform Delta Recommissioning  ${changed_parameters_string}
    Log  Operation was done successfully!  console=true
    vcu.Reset Cu
    ${ip_adresses}  Create List  ${VCU_OAM_IP}
    ${ping_lost_status}  Run Keyword And Return Status
    ...  ping.Wait For No Ping  ip_addresses=${ip_adresses}  timeout=120s
    Run Keyword If  ${ping_lost_status} == ${FALSE}
    ...  Fail  Ping not lost after vCU reset. [NOK]
    ${ping_regained_status}  Run Keyword And Return Status
    ...  ping.Wait For Ping  ip_addresses=${ip_adresses}  timeout=300s
    Run Keyword If  ${ping_regained_status} == ${FALSE}
    ...  Fail  Ping not regained after vCU reset. [NOK]
    Log  vCU reset is performed![OK]  console=true
    Wait Until Keyword Succeeds  ${timeout}  10s
    ...  Check VDU To Be OnAir
    Wait Until Keyword Succeeds  ${timeout}  10s
    ...  Verify CU X2 Links States  ${AVAILABLE}  ${UNLOCKED}
    Wait Until Keyword Succeeds  ${timeout}  10s
    ...  Check Cells On VDU To Be OnAir
    Log  vDU, cells and X2 Links are back on air! [OK]  console=true
    Wait Until Keyword Succeeds  30s  10s
    ...  Check If Fault Is Cleared From VCU WebEM  7115  4592

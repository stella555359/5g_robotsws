*** Settings ***
Documentation
    ...  This TC checks the statistics of suppressed alarms in WebEM.
    ...  Change parameter value of fault4592CancellationTimer to be 1800s.
    ...  Perform vCU reset and verify if fault 4592 is visible on vCU alarms active tab.
    ...  Delete CurrentPlanForRestart.Bak File From VCU and start diagnostic check.
    ...  Verify if fault 4681 is visible on vCU alarms active tab.
    ...  Set actAlarmsSuppression to 'suppressAlarms' and suppressedFaultList with parameters alarmSeverity=MINOR and faultId=4592.
    ...  Activate the plan and verify if fault 4592 is not visible anymore in active alarms view.
    ...  Sleep for 120s before adding fault 4681 in suppressedFaultList because we need later to filter by latest appeared.
    ...  Activate the plan and verify if fault 4681 is not visible anymore in active alarms view.
    ...  Click on Get Suppressed Alarms button and verify if the confirmation message is visible on page.
    ...  Verify if faults 4592 and 4681 with alarm id 7115 are visible in suppressed alarms view.
    ...  Save the statistics file of suppressed alarms.
    ...  Verify the file to contain all specific titles and generic information about the suppressed faults.
    ...  Verify the table header to contain all the specific titles.
    ...  Verify the body table to contain all the specific information about the generated faults.
    ...  Verify sorting order in descending and ascending by latest appeared.
    ...  Verify filtering by severity.
    ...  Filter the statistics of suppressed alarms.
    ...  Verify hide and show buttons for all the specific titles and verify if the title is still visible or not in table header.
    ...  Disable actAlarmsSuppression parameter and delete all instances.
    ...  Cancel fault id 4592 and verify if fault is cleared.
    ...  Cancel fault id 4681 and verify if fault is cleared.
    ...  As recovery action, if test fail the last 2 steps with disabling the parameter and canceling faults 4592 and 4681 will be perform.


Resource  ../../common_resources/vcu_frame.robot
Resource  ../resources/vcu_WebEM_general.robot


*** Variables ***
${RECOVERY_TIMEOUT}  900s  # Timeout for CBTS to be onAir


*** Keywords ***
TC__WebEM__vCU__Statistics_of_suppressed_minor_warning_alarms_in_BTS_Element_Manager
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-29157
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  16.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29157 - Initial TAT creation
    ...  09.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29831 - Change method of retrieving pod and container name
    ...  ******************

    Set Tags  CA-WebEM  OWNER-marius.stanescu@nokia.com  AUTHOR-andreea.burtic@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf  SW-vCU25R3  FEATURE-CB010788


    Step1: Generate fault id 4592 and fault id 4681
    Step2: Set actAlarmsSuppression to 'suppressAlarms' and set suppressed fault id
    Step3: Log the statistics of suppressed alarms in the statistics file and verify the file saved from WebEM
    Step4: Get suppressed alarms from BTS and verify the table
    Step5: Filter the statistics of suppressed alarms and adjust sorting order in descending or ascending by latest appeared
    Step6: Verify hide and show buttons
    Step7: Disable actAlarmsSuppression Parameter And Delete Instances
    Step8: Cancel generated faults and verify if the faults are cleared


Step1: Generate fault id 4592 and fault id 4681
    Log  \nStep1: Generate fault id 4592 and fault id 4681  console=true
    Generate Fault Id 4592 On vCU And Verify If Fault Is Visible In Active Alarms  ${RECOVERY_TIMEOUT}
    Delete CurrentPlanForRestart.Bak File From VCU
    vcu.Start diagnostic check
    Sleep  10s  Time for alarm to be visible
    ${active_faults_id_list}  Get List Of Active Fault Ids From vCU WebEM
    List Should Contain Value  ${active_faults_id_list}  4681
    Log  Fault Id 4681 is visible on WebEM before suppression![OK]  console=true
    ${active_alarms_id_list}  Get List Of Active Alarm Ids From vCU WebEM
    List Should Contain Value  ${active_alarms_id_list}  7115
    Log  Alarm Id 7115 is visible on WebEM before suppression![OK]  console=true


Step2: Set actAlarmsSuppression to 'suppressAlarms' and set suppressed fault id
    Log  \nStep2: Set actAlarmsSuppression to 'suppressAlarms' and set suppressed fault id  console=true
    ${actAlarmsSuppression_parameter}  Create Dictionary  parameterName=actAlarmsSuppression  value=suppressAlarms  operation=update
    ${allowedAlarmList_parameter}  Create Dictionary  parameterName=allowedAlarmList  operation=delete
    ${allowedFaultList_parameter}  Create Dictionary  parameterName=allowedFaultList  operation=delete
    ${suppressedAlarmList_parameter}  Create Dictionary  parameterName=suppressedAlarmList  operation=delete
    ${suppressedFaultList_parameter}  Create Dictionary  parameterName=suppressedFaultList  operation=delete
    ${severity_faultid_dict}  Create Dictionary  alarmSeverity=MINOR_AND_WARNING  faultId=4592
    ${severity_faultid_list}  Create List  ${severity_faultid_dict}
    ${suppressedFaultList_parameter_created}  Create Dictionary  parameterName=suppressedFaultList  value=${severity_faultid_list}  operation=create
    ${parameters_change_list}  Create List  ${actAlarmsSuppression_parameter}  ${allowedAlarmList_parameter}  ${allowedFaultList_parameter}
    ...  ${suppressedAlarmList_parameter}  ${suppressedFaultList_parameter}  ${suppressedFaultList_parameter_created}
    ${actAlarmsSuppression_changed_parameter}  Create Dictionary  distName=MRBTS-${VCU_MRBTS_ID}/MNL-1/MNLENT-1/FMCADM-1/ALARMSUPP-1
    ...  operation=update  parameters=${parameters_change_list}
    ${changed_parameters_list}  Create List  ${actAlarmsSuppression_changed_parameter}
    ${changed_parameters_string}  Evaluate  json.dumps(${changed_parameters_list})  json
    Log  Parameter actAlarmsSuppression was changed to suppressAlarms![OK]  console=true
    Log  Parameters allowedAlarmList, allowedFaultList, suppressedAlarmList and suppressedFaultList was deleted initially![OK]  console=true
    Log  Parameter suppressedFaultList was added with parameters alarmSeverity=MINOR_AND_WARNING and faultId=4592![OK]  console=true
    vcu.Perform Delta Recommissioning  ${changed_parameters_string}
    Log  Operation was done successfully!  console=true
    Sleep  120s  This sleep is here becaouse we need later to filter the faults by latest appeared.
    ${severity_faultid_dict}  Create Dictionary  alarmSeverity=MINOR  faultId=4592,4681
    ${severity_faultid_list}  Create List  ${severity_faultid_dict}
    ${suppressedFaultList_parameter_created}  Create Dictionary  parameterName=suppressedFaultList  value=${severity_faultid_list}  operation=update
    ${parameters_change_list}  Create List  ${suppressedFaultList_parameter_created}
    ${actAlarmsSuppression_changed_parameter}  Create Dictionary  distName=MRBTS-${VCU_MRBTS_ID}/MNL-1/MNLENT-1/FMCADM-1/ALARMSUPP-1
    ...  operation=update  parameters=${parameters_change_list}
    ${changed_parameters_list}  Create List  ${actAlarmsSuppression_changed_parameter}
    ${changed_parameters_string}  Evaluate  json.dumps(${changed_parameters_list})  json
    Log  Fault 4681 was added in suppressedFaultList![OK]  console=true
    vcu.Perform Delta Recommissioning  ${changed_parameters_string}
    Log  Operation was done successfully!  console=true


Step3: Log the statistics of suppressed alarms in the statistics file and verify the file saved from WebEM
    Log  \nStep3: Log the statistics of suppressed alarms in the statistics file and verify the file saved from WebEM  console=true
    Sleep  10s  Time for alarm to not be visible
    ${active_faults_id_list}  Get List Of Active Fault Ids From vCU WebEM
    List Should Not Contain Value  ${active_faults_id_list}  4592
    List Should Not Contain Value  ${active_faults_id_list}  4681
    Log  Fault Id 4592 and 4681 are not visible on active alarms after suppression![OK]  console=true
    Open Suppressed Alarms View And Verify If A Specific Fault Is Visible  4592  7115
    Open Suppressed Alarms View And Verify If A Specific Fault Is Visible  4681  7115
    Save Statictics File And Move It To Test Results Directory For vCU  4592_4681
    ${suppressed_content}  OperatingSystem.Get File
    ...  ${TEST_RESULTS_DIR}/MRBTS-${VCU_MRBTS_ID}_${VCU_MRBTS_NAME}_SuppressedAlarms_${DATE_FOR_TXT}_4592_4681.txt
    Verify The Titles From The Statistics File With Suppressed Alarms  ${suppressed_content}
    Verify Generated Fault Info From The Statistics File With Suppressed Alarms For vCU  ${suppressed_content}  7115  BASE STATION INFORMATION  4592
    ...  BTS Reset Cause
    Verify Generated Fault Info From The Statistics File With Suppressed Alarms For vCU  ${suppressed_content}  7115  BASE STATION INFORMATION  4681
    ...  Diagnostic Check Error


Step4: Get suppressed alarms from BTS and verify the table
    Log  \nStep4: Get suppressed alarms from BTS and verify the table  console=true
    Click Element  //*[@id="/alarm/suppressed"]/span
    Click Element
    ...  //*[@id="laf-component"]/blocks-suppressed-alarm/div/cem-toolbar/div/div[1]/div/cem-operation-button/div/div/p-button[1]/button/span
    Log  Get Suppressed Alarms button was pushed!  console=true
    Wait Until Keyword Succeeds  60  5
    ...  Page Should Contain  Get Suppressed Alarms success
    Log  Message 'Get Suppressed Alarms success' is visible![OK]  console=true
    Wait Until Element Is Visible  //*[contains(@class, "p-element p-datatable-tbody")]/tr  60
    Verify The Titles From WebEM Suppressed Alarms
    ${date}  Get Current Date  result_format=%d.%m.%Y
    ${faults_list}  Create List  4681  4592
    ${faults_name_list}  Create List  Diagnostic Check Error  BTS Reset Cause
    ${alarm_table_tr}  SeleniumLibrary.Get Element Count  //*[contains(@class, "p-element p-datatable-tbody")]/tr
    FOR  ${alarm_index}  IN RANGE  1  ${alarm_table_tr}+1
        ${severity}  Get Element Attribute  //*[contains(@class, "p-element p-datatable-tbody")]/tr[${alarm_index}]/td[1]/container-element/i
        ...  class
        Should Contain  ${severity}  minor  Severity of the alarm is not minor![NOK]
        Log  Severity of the alarm is minor![OK]  console=true
        ${time}  Get Text  //*[contains(@class, "p-element p-datatable-tbody")]/tr[${alarm_index}]/td[2]
        Should Start With  ${time}  ${date}  Last appeared of the alarm is not starting with ${date}![NOK]
        Log  Last appeared of the alarm is starting with ${date}![OK]  console=true
        ${alarm_id}  Get Text  //*[contains(@class, "p-element p-datatable-tbody")]/tr[${alarm_index}]/td[3]
        Should Be Equal  ${alarm_id}  7115  Alarm id is not 7115![NOK]
        Log  Alarm id is 7115![OK]  console=true
        ${alarm_name}  Get Text  //*[contains(@class, "p-element p-datatable-tbody")]/tr[${alarm_index}]/td[4]
        Should Be Equal  ${alarm_name}  BASE STATION INFORMATION  Alarm name is not BASE STATION INFORMATION![NOK]
        Log  Alarm name is BASE STATION INFORMATION![OK]  console=true
        ${fault_id}  Get Text  //*[contains(@class, "p-element p-datatable-tbody")]/tr[${alarm_index}]/td[5]
        ${list_index}  Evaluate  ${alarm_index} - 1
        Should Be Equal  ${fault_id}  ${faults_list}[${list_index}]  Fault id ${faults_list}[${list_index}] is not visible![NOK]
        Log  Fault id ${faults_list}[${list_index}] is visible![OK]  console=true
        ${fault_name}  Get Text  //*[contains(@class, "p-element p-datatable-tbody")]/tr[${alarm_index}]/td[6]
        Should Be Equal  ${fault_name}  ${faults_name_list}[${list_index}]
        ...  Fault name ${faults_name_list}[${list_index}] is not visible![NOK]
        Log  Fault name ${faults_name_list}[${list_index}] is visible![OK]  console=true
        ${alarming_object}  Get Text  //*[contains(@class, "p-element p-datatable-tbody")]/tr[${alarm_index}]/td[7]
        Should Be Equal  ${alarming_object}  MRBTS-${VCU_MRBTS_ID}
        ...  Alarming object is not visible correctly![NOK]
        Log  Alarming object is visible correctly![OK]  console=true
        Current And Last Appeared In Table  ${alarm_index}
        Log  All values from current or last are correctly![OK]  console=true
    END


Step5: Filter the statistics of suppressed alarms and adjust sorting order in descending or ascending by latest appeared
    Log  \nStep5: Filter the statistics of suppressed alarms and adjust sorting order in descending or ascending by latest appeared  console=true
    Verify Sorting Order In Descending Or Ascending By Latest Appeared
    Verify Filtering By Severity
    Filter The Statistics Of Suppressed Alarms


Step6: Verify hide and show buttons
    Log  \nStep6: Verify hide and show buttons  console=true
    Click Element  //*[@id="laf-component"]/blocks-suppressed-alarm/div/div/cem-toolbar/div/div[1]/div[2]/div/p-multiselect/div/div[2]/div
    Sleep  5s  Time for page to be uploaded
    ${information_list}  Create List  Alarm name  Fault name  Current 10s  Last 10s  Current minute  Last minute  Current hour  Last hour
    ...  Current day  Last day  All
    ${elements_dropdown}  SeleniumLibrary.Get Element Count   //ul[contains(@class, "p-multiselect-items p-component")]/p-multiselectitem
    FOR  ${element}  IN RANGE  1  ${elements_dropdown}+1
        ${class}  Get Element Attribute  //ul[contains(@class, "p-multiselect-items p-component")]/p-multiselectitem[${element}]/li  class
        Should Contain  ${class}  highlight
    END
    Log  As default all informations are shown![OK]  console=true
    FOR  ${element}  IN RANGE  1  ${elements_dropdown}+1
        ${list_index}  Evaluate  ${element} - 1
        ${element_title}  Get Text  //ul[contains(@class, "p-multiselect-items p-component")]/p-multiselectitem[${element}]/li
        Should Be Equal  ${element_title}  ${information_list}[${list_index}]  ${information_list}[${list_index}] is not visible![NOK]
        Log  ${information_list}[${list_index}] is visible![OK]  console=true
        Click Element  //ul[contains(@class, "p-multiselect-items p-component")]/p-multiselectitem[${element}]/li
        Sleep  5s  Time for page to be uploaded
        ${class}  Get Element Attribute  //ul[contains(@class, "p-multiselect-items p-component")]/p-multiselectitem[${element}]/li  class
        Should Not Contain  ${class}  highlight
        Log  ${information_list}[${list_index}] is not marked anymore![OK]  console=true
        Click Element  //*[@id="laf-component"]/blocks-suppressed-alarm/div/div/cem-toolbar/div/div[1]/div[2]/div/p-multiselect/div/div[2]/div
        Sleep  5s  Time for page to be uploaded
        Log  Verify if ${information_list}[${list_index}] is still visible in table!  console=true
        ${titles_list}  Get All Visible Titles From Table Header
        List Should Not Contain Value  ${titles_list}  ${information_list}[${list_index}]
        ...  ${information_list}[${list_index}] is still visible in table header![NOK]
        Log  ${information_list}[${list_index}] is not visible anymore in table header![OK]  console=true
        Log  Mark again ${information_list}[${list_index}] and verify if it's visible in table header!  console=true
        Click Element  //*[@id="laf-component"]/blocks-suppressed-alarm/div/div/cem-toolbar/div/div[1]/div[2]/div/p-multiselect/div/div[2]/div
        Sleep  5s  Time for page to be uploaded
        Click Element  //ul[contains(@class, "p-multiselect-items p-component")]/p-multiselectitem[${element}]/li
        Sleep  5s  Time for page to be uploaded
        ${class}  Get Element Attribute  //ul[contains(@class, "p-multiselect-items p-component")]/p-multiselectitem[${element}]/li  class
        Should Contain  ${class}  highlight
        Log  ${information_list}[${list_index}] is marked again![OK]  console=true
        Click Element  //*[@id="laf-component"]/blocks-suppressed-alarm/div/div/cem-toolbar/div/div[1]/div[2]/div/p-multiselect/div/div[2]/div
        Sleep  5s  Time for page to be uploaded
        Log  Verify if ${information_list}[${list_index}] is visible in table!  console=true
        ${titles_list}  Get All Visible Titles From Table Header
        List Should Contain Value  ${titles_list}  ${information_list}[${list_index}]
        ...  ${information_list}[${list_index}] is not visible in table header![NOK]
        Log  ${information_list}[${list_index}] is visible again in table header![OK]  console=true
        Click Element  //*[@id="laf-component"]/blocks-suppressed-alarm/div/div/cem-toolbar/div/div[1]/div[2]/div/p-multiselect/div/div[2]/div
        Sleep  5s  Time for page to be uploaded
    END


Step7: Disable actAlarmsSuppression Parameter And Delete Instances
    Log  \nStep7: Disable actAlarmsSuppression Parameter And Delete Instances  console=true
    Disable actAlarmsSuppression Parameter And Delete Instances For vCU
    Sleep  10s  Time for alarm to be visible
    ${active_faults_id_list}  Get List Of Active Fault Ids From vCU WebEM
    ${active_alarms_id_list}  Get List Of Active Alarm Ids From vCU WebEM
    List Should Contain Value  ${active_faults_id_list}  4592
    List Should Contain Value  ${active_faults_id_list}  4681
    List Should Contain Value  ${active_alarms_id_list}  7115
    Log  Fault Id 4592 with alarm id 7115 is visible on WebEM in active alarms after actAlarmsSuppression is disabled![OK]  console=true
    Log  Fault Id 4681 with alarm id 7115 is visible on WebEM in active alarms after actAlarmsSuppression is disabled![OK]  console=true


Step8: Cancel generated faults and verify if the faults are cleared
    Log  \nStep8: Cancel generated faults and verify if the faults are cleared  console=true
    Cancel Fault 4592 And Change fault4592CancellationTimer To Be 30s  ${RECOVERY_TIMEOUT}
    Sleep  10s  Time for alarm to not be visible
    ${active_faults_id_list}  Get List Of Active Fault Ids From vCU WebEM
    List Should Not Contain Value  ${active_faults_id_list}  4681
    Log  Fault Id 4681 with alarm id 7115 is not visible on WebEM in active alarms after site reset![OK]  console=true


Current And Last Appeared In Table
    [Arguments]  ${index}

    FOR  ${td}  IN RANGE  8  17
        ${current_last}  Get Text  //*[contains(@class, "p-element p-datatable-tbody")]/tr[${index}]/td[${td}]
        IF  ${current_last} >= 0
            CONTINUE
        ELSE
            Fail  One or more value of current or last header is not 0 or higher![NOK]
        END
    END


Verify The Titles From WebEM Suppressed Alarms
    ${alarm_table_head}  SeleniumLibrary.Get Element Count  //*[contains(@class, "p-datatable-thead")]/tr[1]/th
    ${table_head_list}  Create List  Severity  Latest appeared  Alarm ID  Alarm name  Fault ID  Fault name  Alarming object  Current 10s
    ...  Last 10s  Current minute  Last minute  Current hour  Last hour  Current day  Last day  All
    FOR  ${title_index}  IN RANGE  1  ${alarm_table_head}+1
        ${title}  Get Text  //*[contains(@class, "p-datatable-thead")]/tr[1]/th[${title_index}]/div
        ${list_index}  Evaluate  ${title_index} - 1
        IF  ${title_index} == 2
            Should Contain  ${title}  ${table_head_list}[${list_index}]
            CONTINUE
        END
        IF  '${title}' == '${table_head_list}[${list_index}]'
            Log  '${table_head_list}[${list_index}]' is visible correctly on headers table![OK]  console=true
        ELSE
            Fail  '${table_head_list}[${list_index}]' is not visible correctly on headers table![NOK]
        END
    END


Get All Visible Titles From Table Header
    ${titles_list}  Create List
    ${alarm_table_head}  SeleniumLibrary.Get Element Count  //*[contains(@class, "p-datatable-thead")]/tr[1]/th
    FOR  ${title_index}  IN RANGE  1  ${alarm_table_head}+1
        ${title}  Get Text  //*[contains(@class, "p-datatable-thead")]/tr[1]/th[${title_index}]/div
        Append To List  ${titles_list}  ${title}
    END

    RETURN  ${titles_list}


Verify Filtering By Severity
    Log  Verify filtering by severity!  console=true
    Click Element  //*[@id="laf-component"]/blocks-suppressed-alarm/div/div/cem-toolbar/div/div[1]/div[1]/div/span[1]/p-togglebutton/div
    Wait Until Page Contains  No alarms available for selected filtering options  10
    Log  Critical alarms was selected and message 'No alarms available for selected filtering options' appeared![OK]  console=true
    Click Element  //*[@id="laf-component"]/blocks-suppressed-alarm/div/div/cem-toolbar/div/div[1]/div[1]/div/span[1]/p-togglebutton/div
    Click Element  //*[@id="laf-component"]/blocks-suppressed-alarm/div/div/cem-toolbar/div/div[1]/div[1]/div/span[2]/p-togglebutton/div
    Wait Until Page Contains  No alarms available for selected filtering options  10
    Log  Major alarms was selected and message 'No alarms available for selected filtering options' appeared![OK]  console=true
    Click Element  //*[@id="laf-component"]/blocks-suppressed-alarm/div/div/cem-toolbar/div/div[1]/div[1]/div/span[2]/p-togglebutton/div
    Click Element  //*[@id="laf-component"]/blocks-suppressed-alarm/div/div/cem-toolbar/div/div[1]/div[1]/div/span[3]/p-togglebutton/div
    Wait Until Element Is Visible  //*[contains(@class, "p-element p-datatable-tbody")]/tr  60
    ${alarm_table_tr}  SeleniumLibrary.Get Element Count  //*[contains(@class, "p-element p-datatable-tbody")]/tr
    Should be equal as integers  ${alarm_table_tr}  2
    Log  Generated minor alarms appeared![OK]  console=true
    Click Element  //*[@id="laf-component"]/blocks-suppressed-alarm/div/div/cem-toolbar/div/div[1]/div[1]/div/span[3]/p-togglebutton/div
    Click Element  //*[@id="laf-component"]/blocks-suppressed-alarm/div/div/cem-toolbar/div/div[1]/div[1]/div/span[4]/p-togglebutton/div
    Wait Until Page Contains  No alarms available for selected filtering options  10
    Log  Warning alarms was selected and message 'No alarms available for selected filtering options' appeared![OK]  console=true
    Click Element  //*[@id="laf-component"]/blocks-suppressed-alarm/div/div/cem-toolbar/div/div[1]/div[1]/div/span[4]/p-togglebutton/div


Filter The Statistics Of Suppressed Alarms
    Log  Verify filtering by alarm id!  console=true
    Input Text  //*[contains(@class, "p-datatable-thead")]/tr[2]/th[3]/ot-column-filter/div/ot-column-filter-form-element/div/input  100
    Wait Until Page Contains  No alarms available for selected filtering options  10
    Log  Filtering by alarm id with alarm id 100 was made and message 'No alarms available for selected filtering options' appeared![OK]  console=true
    Input Text  //*[contains(@class, "p-datatable-thead")]/tr[2]/th[3]/ot-column-filter/div/ot-column-filter-form-element/div/input  7115
    Sleep  3s  Time for page to be uploaded
    ${alarm_table_tr}  SeleniumLibrary.Get Element Count  //*[contains(@class, "p-element p-datatable-tbody")]/tr
    Should be equal as integers  ${alarm_table_tr}  2
    Log  Filtering by alarm id with alarm id 7115 was made and both faults appeared![OK]  console=true
    Press Keys  //*[contains(@class, "p-datatable-thead")]/tr[2]/th[3]/ot-column-filter/div/ot-column-filter-form-element/div/input  CTRL+a+BACKSPACE
    Sleep  3s  Time for page to be uploaded
    ${alarm_table_tr}  SeleniumLibrary.Get Element Count  //*[contains(@class, "p-element p-datatable-tbody")]/tr
    Should be equal as integers  ${alarm_table_tr}  2
    Log  Verify filtering by fault id!  console=true
    Input Text  //*[contains(@class, "p-datatable-thead")]/tr[2]/th[5]/ot-column-filter/div/ot-column-filter-form-element/div/input  100
    Wait Until Page Contains  No alarms available for selected filtering options  10
    Log  Filtering by fault id with fault id 100 was made and message 'No alarms available for selected filtering options' appeared![OK]  console=true
    Input Text  //*[contains(@class, "p-datatable-thead")]/tr[2]/th[5]/ot-column-filter/div/ot-column-filter-form-element/div/input  4592
    Sleep  3s  Time for page to be uploaded
    ${alarm_table_tr}  SeleniumLibrary.Get Element Count  //*[contains(@class, "p-element p-datatable-tbody")]/tr
    Should be equal as integers  ${alarm_table_tr}  1
    ${suppressed_fault_id}  Get Text  //*[contains(@class, "p-element p-datatable-tbody")]/tr/td[5]
    Should be equal  ${suppressed_fault_id}  4592  Fault id 4592 is not visible on Suppressed Alarms page after filtered![NOK]
    Log  Only fault id 4592 is visible on Suppressed Alarms page![OK]  console=true
    Press Keys  //*[contains(@class, "p-datatable-thead")]/tr[2]/th[5]/ot-column-filter/div/ot-column-filter-form-element/div/input  CTRL+a+BACKSPACE
    Sleep  3s  Time for page to be uploaded
    ${alarm_table_tr}  SeleniumLibrary.Get Element Count  //*[contains(@class, "p-element p-datatable-tbody")]/tr
    Should be equal as integers  ${alarm_table_tr}  2
    Log  Verify filtering by alarming object!  console=true
    Input Text  //*[contains(@class, "p-datatable-thead")]/tr[2]/th[7]/ot-column-filter/div/ot-column-filter-form-element/div/input  587342
    Wait Until Page Contains  No alarms available for selected filtering options  10
    Log  Filtering by object with alarming object 587342 was made and message 'No alarms available for selected filtering options' appeared![OK]
    ...  console=true
    Input Text  //*[contains(@class, "p-datatable-thead")]/tr[2]/th[7]/ot-column-filter/div/ot-column-filter-form-element/div/input
    ...  MRBTS-${VCU_MRBTS_ID}
    Sleep  3s  Time for page to be uploaded
    ${alarm_table_tr}  SeleniumLibrary.Get Element Count  //*[contains(@class, "p-element p-datatable-tbody")]/tr
    Should be equal as integers  ${alarm_table_tr}  2
    Log  Filtering by alarming object with alarming object MRBTS-${VCU_MRBTS_ID} was made and both faults appeared![OK]  console=true
    Press Keys  //*[contains(@class, "p-datatable-thead")]/tr[2]/th[7]/ot-column-filter/div/ot-column-filter-form-element/div/input  CTRL+a+BACKSPACE
    Sleep  3s  Time for page to be uploaded
    ${alarm_table_tr}  SeleniumLibrary.Get Element Count  //*[contains(@class, "p-element p-datatable-tbody")]/tr
    Should be equal as integers  ${alarm_table_tr}  2


Verify Sorting Order In Descending Or Ascending By Latest Appeared
    Log  Verify sorting order in descending or ascending by latest appeared!  console=true
    ${fist_datetime}  Get Text  //*[contains(@class, "p-element p-datatable-tbody")]/tr[1]/td[2]
    ${fist_time}  Fetch From Right  ${fist_datetime}  ${SPACE}
    ${second_datetime}  Get Text  //*[contains(@class, "p-element p-datatable-tbody")]/tr[2]/td[2]
    ${second_time}  Fetch From Right  ${second_datetime}  ${SPACE}
    IF  '${fist_time}' > '${second_time}'
        Log  As default, faults are sorted in descending order by latest appeared.[OK]  console=true
    ELSE
        Fail  As default, faults are not sorted in descending order by latest appeared.[NOK]
    END
    Click Element   //*[contains(@class, "p-datatable-thead")]/tr[1]/th[2]/div
    Sleep  3s  Time for page to be uploaded
    ${fist_datetime}  Get Text  //*[contains(@class, "p-element p-datatable-tbody")]/tr[1]/td[2]
    ${fist_time}  Fetch From Right  ${fist_datetime}  ${SPACE}
    ${second_datetime}  Get Text  //*[contains(@class, "p-element p-datatable-tbody")]/tr[2]/td[2]
    ${second_time}  Fetch From Right  ${second_datetime}  ${SPACE}
    IF  '${fist_time}' < '${second_time}'
        Log  After sorting order in ascending by latest appeared, faults order is correctly.[OK]  console=true
    ELSE
        Fail  After sorting order in ascending by latest appeared, faults order is not correctly.[NOK]
    END
    Click Element   //*[contains(@class, "p-datatable-thead")]/tr[1]/th[2]/div
    Sleep  3s  Time for page to be uploaded
    ${fist_datetime}  Get Text  //*[contains(@class, "p-element p-datatable-tbody")]/tr[1]/td[2]
    ${fist_time}  Fetch From Right  ${fist_datetime}  ${SPACE}
    ${second_datetime}  Get Text  //*[contains(@class, "p-element p-datatable-tbody")]/tr[2]/td[2]
    ${second_time}  Fetch From Right  ${second_datetime}  ${SPACE}
    IF  '${fist_time}' > '${second_time}'
        Log  After sorting order in descending by latest appeared, faults order is correctly.[OK]  console=true
    ELSE
        Fail  After sorting order in desscending by latest appeared, faults order is not correctly.[NOK]
    END
    Click Element   //*[contains(@class, "p-datatable-thead")]/tr[1]/th[2]/div


Delete CurrentPlanForRestart.Bak File From VCU
    Log  \nDelete CurrentPlanForRestart.Bak File From VCU.  console=true
    Open SSH Connection To VCU And Connect To Openshift
    ${pod}  Get Full Name For Pod  ${VCU_CRAN}  oamcm
    ${container}  Get Full Name For Container  ${VCU_CRAN}  oamcm
    ${delete_command}  Catenate  oc exec -it -n ${VCU_CRAN} ${pod} -c ${container} -- rm -rf
    ...                          /mnt/services/SS_OAM/OAMCM/working_dir/currentPlan/currentPlanForRestart.bak
    SSHLibrary.Write  ${delete_command}
    SSHLibrary.Read Until Prompt

    [Teardown]  SSHLibrary.Close Connection


TC Setup
    Common VCU Setup
    VCU WebEM Setup
    Modify Resource Search Order  WebEM__vCU__Statistics_of_suppressed_minor_warning_alarms_in_BTS_Element_Manager


TC Teardown
    Run keyword if test failed  Run keywords  Disable actAlarmsSuppression Parameter And Delete Instances For vCU  AND
    ...  Cancel Fault 4592 And Change fault4592CancellationTimer To Be 30s  ${RECOVERY_TIMEOUT}
    VCU WebEM Teardown
    Common VCU Teardown

*** Settings ***
Documentation
    ...  This TC is created to check suppressed alarms after BTS reset.
    ...  1. Trigger minor faults or use already existing minor faults that are always active in webEM : E.g. 61649 - LMP access via port 443,
    ...  61524 -SSH enabled, 4655 -Service account root access is enabled, 4654 -Ethernet port security is disabled, 61652 -R&D Service Port enabled
    ...  2. ActAlarmsSuppression is set to 'SuppressAlarms'. Create SuppressedFaultList and add FID with Severity "minor and warning".
    ...  3. Check that minor alarms are suppressed in WebEM, and displayed with correct date and time into "cat /ram/RawSuppressedAlarmHistory.txt"
    ...  4. Following file should be empty or at least should not contain above supressed alarms and its timestamp:
    ...  /ffs/run/logs/lifetimedata/blackbox_RawSuppressedAlarmHistory.txt
    ...  5. Trigger manual site reset. Check that SBTS is back onair all boards and cells.
    ...  Check that following file contain above supressed alarms and its timestamp: existing file /ram/RawSuppressedAlarmHistory.txt content
    ...  before Site reset was copied into /ffs/run/logs/lifetimedata/blackbox_RawSuppressedAlarmHistory.txt
    ...  6. Check that snapshot file succesfuly collected and contains RawSuppressedAlarmHistory.txt and blackbox_RawSuppressedAlarmHistory.txt files
    ...  with above supressed alarms.
    ...  7. Load initial SCF

Resource  ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${RECOVERY_TIMEOUT}  1200  #Timeout for SBTS to be onAir


*** Keywords ***
TC__WebEM__Statistics_of_suppressed_alarms_after_BTS_reset
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-29013
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 24.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29515 - Initial TAT creation
    ...  - 29.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29956 - Adding mouse over PE and sleep before files check
    ...  - 23.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30061 - Sleep before files check from step 4
    ...  - 19.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30465 - Increase sleep before files check

    Set Tags  CA-WebEM  OWNER-marius.stanescu@nokia.com  AUTHOR-cristina.adam@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf
    ...  PHASE-CRT  SW-SBTS25  FEATURE-CB010788-E

    Step0: Set Preconditions
    Step1: Set ActAlarmsSuppression To SuppressAlarms And Set Fault Id Suppressed
    Step2: Check Alarm Is Suppressed in WebEM
    Step3: Check Blackbox_RawSuppressedAlarmHistory.txt Should Be Empty And RawSuppressedAlarmHistory.txt Contain Alarm
    Step4: Perform Site Reset And Check Blackbox_RawSuppressedAlarmHistory.txt And RawSuppressedAlarmHistory.txt
    Step5: Check Snapshot Contains RawSuppressedAlarmHistory.txt And blackbox_RawSuppressedAlarmHistory.txt Files With Supressed Alarm
    Step6: Load Initial SCF


Step0: Set Preconditions
    Log  \nStep0: Set Preconditions  console=true
    ${active_alarms}  coam.Get Active Alarms
    ${SELECTED_ALARM}  Evaluate  random.choice(${active_alarms})  random
    ${SUPPRESSED_FAULT_ID}  Convert To String  ${SELECTED_ALARM}[faultId]
    Set Test Variable  ${SUPPRESSED_FAULT_ID}
    ${DATE_TIME_RAW_SUPPRESED}  Get BTS Time In UTC Format  %Y-%m-%d %H:%M:%S
    Set Test Variable  ${DATE_TIME_RAW_SUPPRESED}


Step1: Set ActAlarmsSuppression To SuppressAlarms And Set Fault Id Suppressed
    Log  \nStep1: Set ActAlarmsSuppression To SuppressAlarms  console=true
    Wait Until Element Is Clicked  ${PARAMETER_EDITOR}  90
    ${filter_xpath}  Catenate  SEPARATOR=  //*[@id="laf-component"]/blocks-parameter-editor-layout/div/div/blocks-navigation/ot-side-sheet/div/div[1]
    ...  /div/div[2]/p-tree/div/div/input
    Input Text  ${filter_xpath}  ALARMSUPP-1
    Wait Until Element Is Clicked  //span[contains(@class, 'ot-highlight-text') and contains(text(), 'ALARMSUPP-1')]  90
    Input Text  //*[@class="cdk-virtual-scroll-content-wrapper"]/table/thead/tr[2]/th[2]/div/input  Activation of alarms suppression
    ${first_parameter}  Catenate  SEPARATOR=  //*[@class="cdk-virtual-scroll-content-wrapper"]/table/tbody/tr[1]/td[4]/cem-parameter-input/
    ...  cem-dropdown-input/div/p-dropdown/div/span
    Wait Until Element Is Clicked  ${first_parameter}
    Wait Until Element Is Visible  //li[contains(@aria-label, "suppressAlarms")]  timeout=30
    Wait Until Element Is Clicked  //li[contains(@aria-label, "suppressAlarms")]
    Sleep  5s  Time to complete the parameter
    Input Text  //*[@class="cdk-virtual-scroll-content-wrapper"]/table/thead/tr[2]/th[2]/div/input  List of suppressed fault IDs
    Wait Until Element is Visible  //*[@class="cdk-virtual-scroll-content-wrapper"]/table/tbody/tr[1]/td[6]/p-button[1]/button/span[1]  20
    Wait Until Element Is Clicked  //*[@class="cdk-virtual-scroll-content-wrapper"]/table/tbody/tr[1]/td[6]/p-button[1]/button/span[1]
    Wait Until Element Is Clicked
    ...  //*[@class="cdk-virtual-scroll-content-wrapper"]/table/tbody/tr[3]/td[4]/cem-parameter-input/cem-dropdown-input/div/p-dropdown/div/span[1]
    Sleep  5s  Time to complete the parameter
    Wait Until Element Is Clicked  //*[contains(@aria-label, "MINOR_AND_WARNING")]
    Input Text  //*[@class="cdk-virtual-scroll-content-wrapper"]/table/tbody/tr[4]/td[4]/cem-parameter-input/cem-string-input/ot-field/div/input
    ...  ${SUPPRESSED_FAULT_ID}
    Sleep  5s  Time to complete the parameter
    Wait Until Element Is Clicked  ${VALIDATE_PLAN_PE}  60
    Sleep  15s  Time for validate plan
    Mouse Over  ${PARAMETER_EDITOR}
    Wait Until Element Is Clicked  ${ACTIVATE_PLAN_PE}  60
    Wait Until Element Is Visible  //*[@id="laf-component"]/p-panel/div/div  300
    Wait Until Element Is Clicked  //span[contains(@class, 'p-button-label ng-star-inserted') and contains(text(), 'Execute')]  120
    Wait Until Element Is Visible
    ...  //*[@id="laf-component"]/div/div/div[2]/blocks-activate-plan-progress-dialog/div[2]/div/ot-instruction/div/span  90
    Wait Until Element Is Clicked  //span[contains(@class, 'p-button-label ng-star-inserted') and contains(text(), 'Close')]  120
    Log  Plan is activated![OK]  console=true


Step2: Check Alarm Is Suppressed in WebEM
    Log  \nStep2: Check Alarm Is Suppressed in WebEM  console=true
    ${active_alarms_after_suppressed}  coam.Get Active Alarms
    FOR  ${alarm}  IN  @{active_alarms_after_suppressed}
        Should Not Be Equal  ${SUPPRESSED_FAULT_ID}  ${alarm}[faultId]
        ...  Alarms with id:${SUPPRESSED_FAULT_ID} are not suppressed.[NOK]
    END
    Log  Fault with id:${SUPPRESSED_FAULT_ID} is suppressed.[OK]  console=true


Step3: Check Blackbox_RawSuppressedAlarmHistory.txt Should Be Empty And RawSuppressedAlarmHistory.txt Contain Alarm
    Log  \nStep3: Check Blackbox_RawSuppressedAlarmHistory.txt Should Be Empty And RawSuppressedAlarmHistory.txt Contain Alarm  console=true
    Go To Site View
    Sleep  500s  Time for the files to be updated
    Check Blackbox_RawSuppressedAlarmHistory.txt Should Be Empty And RawSuppressedAlarmHistory.txt Contain Alarm
    Log  File Blackbox_RawSuppressedAlarmHistory.txt not contain alarm and RawSuppressedAlarmHistory.txt contain alarm![OK]  console=true


Step4: Perform Site Reset And Check Blackbox_RawSuppressedAlarmHistory.txt And RawSuppressedAlarmHistory.txt
    Log  \nStep4: Perform Site Reset And Check Blackbox_RawSuppressedAlarmHistory.txt And RawSuppressedAlarmHistory.txt  console=true
    Reset SBTS From Admin
    Close Startup View If Visible
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10  Admin Check All Required State
    Sleep  500s  Time for the files to be updated
    Check Blackbox_RawSuppressedAlarmHistory.txt Should Not Be Empty And RawSuppressedAlarmHistory.txt Contain Alarm
    Log  File Blackbox_RawSuppressedAlarmHistory.txt contain alarm and RawSuppressedAlarmHistory.txt contain alarm![OK]  console=true


Step5: Check Snapshot Contains RawSuppressedAlarmHistory.txt And blackbox_RawSuppressedAlarmHistory.txt Files With Supressed Alarm
    Log  \nStep5: Check Snapshot Contains RawSuppressedAlarmHistory.txt And blackbox_RawSuppressedAlarmHistory.txt Files With Supressed Alarm
    ...  console=true
    Collect Snapshot  ${BTS_FILES}/snapshot.zip  timeout=300
    ${snapshot_dict}   snapshot.Get Data From Snapshot  ${BTS_FILES}/snapshot.zip
    Check Contain File From Snapshot  ${snapshot_dict}  \.+BTS${BTS_ID}_(1|2)011_RawSuppressedAlarmHistory\.txt\.xz
    Check Contain File From Snapshot  ${snapshot_dict}  \.+BTS${BTS_ID}_(1|2)011_blackbox_RawSuppressedAlarmHistory\.txt\.xz


Step6: Load Initial SCF
    Log  \nStep6: Load Initial SCF  console=true
    Load A Specific SCF  ${COMMISSIONING_PATH}


Check Blackbox_RawSuppressedAlarmHistory.txt Should ${Be/Not Be} Empty And RawSuppressedAlarmHistory.txt Contain Alarm
    SSHLibrary.Open Connection  ${OAM_BTS_IP}  encoding=unicode_escape
    SSHLibrary.Login  toor4nsn  oZPS0POrRieRtu
    SSHLibrary.Get File  /ffs/run/logs/lifetimedata/blackbox_RawSuppressedAlarmHistory.txt  ${BTS_FILES}/blackbox_RawSuppressedAlarmHistory.txt
    ${file_content}  OperatingSystem.Get File  ${BTS_FILES}/blackbox_RawSuppressedAlarmHistory.txt
    ${faults_content}  Fetch From Left  ${file_content}  Cancelled alarms
    ${file_content_fault}  Get Lines Containing String  ${faults_content}  ${SUPPRESSED_FAULT_ID}
    ${status_fault}  Run Keyword And Return Status  Should ${Be/Not Be} Empty  ${file_content_fault}
    IF  ${status_fault}==${FALSE}  Fail  Fault:${SUPPRESSED_FAULT_ID} is ${Be/Not Be} active in blackbox_RawSuppressedAlarmHistory file - [NOK]
    SSHLibrary.Close Connection
    Verify Alarm In RawSuppressedAlarmHistory File  ${SUPPRESSED_FAULT_ID}  ${DATE_TIME_RAW_SUPPRESED}


Check Contain File From Snapshot
    [Arguments]  ${snapshot_dict}  ${match_file}

    FOR  ${key}  IN  @{snapshot_dict.keys()}
        ${path_suppressed_alarm_history}  Get Regexp Matches  ${snapshot_dict["${key}"][0]}  ${match_file}
        IF  ${path_suppressed_alarm_history}  BREAK
    END
    ${status}  Run Keyword And Return Status  Should Be Empty  ${path_suppressed_alarm_history}
    IF  ${status}  Fail  File ${match_file} not exist in snapshot![NOK]
    ${parant_raw_suppressed_alarm_history_file}  Fetch From Left  ${path_suppressed_alarm_history}[0]  /
    ${raw_suppressed_alarm_history_file_xz}  Fetch From Right  ${path_suppressed_alarm_history}[0]  /
    ${raw_suppressed_alarm_history_file}  Fetch From Left  ${raw_suppressed_alarm_history_file_xz}  .xz
    Unzip  ${BTS_FILES}/snapshot.zip  ${BTS_FILES}/snapshot_dir/
    ${path}  Unzip  ${BTS_FILES}/snapshot_dir/${parant_raw_suppressed_alarm_history_file}
    ...  ${BTS_FILES}/snapshot_dir/${parant_raw_suppressed_alarm_history_file}_dir
    OperatingSystem.Run  xz -d "${path}/${raw_suppressed_alarm_history_file_xz}" -c > "${path}/${raw_suppressed_alarm_history_file}"
    ${file_content}  OperatingSystem.Get File  ${path}/${raw_suppressed_alarm_history_file}
    ${faults_content}  Fetch From Left  ${file_content}  Cancelled alarms
    ${file_content_fault}  Get Lines Containing String  ${faults_content}  ${SUPPRESSED_FAULT_ID}
    ${status_fault}  Run Keyword And Return Status  Should Not Be Empty  ${file_content_fault}
    IF  ${status_fault}
        Log  Suppressed alarm appeared in ${raw_suppressed_alarm_history_file} file - [OK].  console=true
    ELSE
        Fail  Suppressed alarm is not present in ${raw_suppressed_alarm_history_file} file - [NOK].
    END


TC Setup
    Common Test Setup
    WebEM Setup


TC Teardown
    Run Keyword If Test Failed  Load A Specific SCF  ${COMMISSIONING_PATH}
    WebEM Teardown
    Common Test Teardown

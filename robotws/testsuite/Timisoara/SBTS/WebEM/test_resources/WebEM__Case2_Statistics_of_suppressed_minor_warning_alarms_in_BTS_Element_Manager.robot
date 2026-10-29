*** Settings ***
Documentation
    ...  This user scenario describes how operator shall view the statistics of suppressed alarms in BTS Element Manager.
    ...  BTS shall suppress minor or warning or both severity alarms based on the configuration.
    ...  ALARMSUPP.actAlarmsSuppression is set to 'suppressAlarms'.
    ...  Operator clicks to get suppressed alarms from BTS.
    ...  Following statistics information will be shown:
    ...  - Severity: alarm severity, included critical, major, minor, warning.
    ...  - Latest appeared GMT+/-Timezone: timestamp of last appeared. Detailed format is dd.MM.yyyy HH:mm:ss e.g. 22.11.2024 13:53:12
    ...  - Alarm ID, Alarm name, Fault ID, Fault name, Alarming object
    ...  - Current 10s: number of occurrences in current 10 seconds
    ...  - Last 10s: Number of occurrences in last 10 seconds
    ...  - Current minute: number of occurrences in current 1 minute
    ...  - Last minute: number of occurrences in last 1 minute
    ...  - Current hour: number of occurrences in current 1 hour
    ...  - Last hour: number of occurrences in last 1 hour
    ...  - Current day: number of occurrences in current day
    ...  - Last day: number of occurrences in last day
    ...  - All: number of all occurrences
    ...  The BTS Element Manager shall support the filtering of statistics of suppressed alarms with below options:
    ...  - by alarm ID, by fault ID, by alarming object, by alarm severity.
    ...  Operator can select following information to hide or show: Alarm name, Fault name, Current 10s, Last 10s, Current minute, Last minute,
    ...  Current hour, Last hour, Current day, Last day, All.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${SUPPRESSED_ALARM_ID}  ${EMPTY}  # Mandatory, alarm id must be given
${RECOVERY_TIMEOUT}  1200  #Timeout for SBTS to be onAir


*** Keywords ***
TC__WebEM__Case2_Statistics_of_suppressed_minor_warning_alarms_in_BTS_Element_Manager
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-28903
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  24.03.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28903 - Initial TAT creation
    ...  02.06.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29305 - Table xpath was changed in trunk and recovery action was added
    ...  28.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29634 - Adding sleep KW after plan was activated
    ...  29.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29956 - Adding mouse over PE and fixing filtering problem
    ...  22.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30055 - Adding sleep KW before and after parameter is complete
    ...  05.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30118 - Change Check Head Of Table KW
    ...  19.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30183 - Table xpaths are changed
    ...  08.12.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30282 - Change Check Filters Of Table KW for step 2

    Set Tags  CA-WebEM  OWNER-marius.stanescu@nokia.com  AUTHOR-cristina.adam@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf
    ...  PHASE-CRT  SW-SBTS25  FEATURE-CB010788

    Step0: Set Preconditions
    Step1: Check Suppressed Alarms By Alarm Id
    Step2: Check Suppressed Alarms By Fault Id


Step0: Set Preconditions
    Log  \nStep0: Set Preconditions  console=true
    Should Not Be Empty  ${SUPPRESSED_ALARM_ID}
    ...  Suppressed alarm id must be specified, please provide it and retest.
    ${active_alarms}  coam.Get Active Alarms
    Set Test Variable  ${ACTIVE_ALARMS}
    ${initial_number_of_active_alarms}  Evaluate  len(${ACTIVE_ALARMS})
    Set Test Variable  ${INITIAL_NUMBER_OF_ACTIVE_ALARMS}
    FOR  ${alarm}  IN  @{ACTIVE_ALARMS}
        IF  '${alarm}[alarmId]' == '${SUPPRESSED_ALARM_ID}'
            Set Test Variable  ${SELECTED_ALARM}  ${alarm}
            BREAK
        END
    END
    ${status}  Run Keyword And Return Status  Variable Should Exist  ${SELECTED_ALARM}
    IF  ${status}
        Log  Alarm with alarmid:${SUPPRESSED_ALARM_ID} exist and test continue![OK]  console=true
    ELSE
        Fail  Alarm ID is wrong! Please provide another one!
    END
    Set Test Variable  ${SUPPRESSED_FAULT_ID}  ${SELECTED_ALARM}[faultId]
    ${TABLE_CLASS}  Set Variable If  '${ENB_BRANCH}' >= 'SBTS25R3'  p-scroller p-scroller-inline ng-star-inserted  p-datatable-wrapper
    Set Test Variable  ${TABLE_CLASS}
    Remove Allowed And Suppressed Parameters From ALARMSUPP


Step1: Check Suppressed Alarms By Alarm Id
    Log  \nStep1: Check Suppressed Alarms By Alarm Id  console=true
    Go To Parameter Editor And Set Alarm Id Searched
    ${active_alarms_after_suppressed}  coam.Get Active Alarms
    FOR  ${alarm}  IN  @{active_alarms_after_suppressed}
        Should Not Be Equal  ${SUPPRESSED_ALARM_ID}  ${alarm}[alarmId]
        ...  Alarms with id:${SUPPRESSED_ALARM_ID} are not suppressed.[NOK]
    END
    Click Element  ${ALARMS_BUTTON_SITE_VIEW}
    Wait Until Element Is Clicked  //li[@heading="Suppressed Alarms"]  90
    Wait Until Element Is Clicked  //span[contains(text(),'Get Suppressed Alarms')]  90
    Wait Until Element Is Visible  locator=//span[contains(text(),'Get Suppressed Alarms success')]  timeout=120
    Sleep  15s  Time to charge alarms
    Wait Until Element Is Visible  //div[contains(@class, '${TABLE_CLASS}')]/table/tbody/tr/td[3]/div  20
    ${INDEX_STEP}  Set Variable  1
    Set Test Variable  ${INDEX_STEP}
    Check Table With Suppressed Alarms
    Deselect Column In Table
    Check Filter By Severity
    Go To Parameter Editor And Delete Alarm Id Object
    ${active_alarms_after_desuppressed}  coam.Get Active Alarms
    ${number_of_active_alarms_after_desuppressed}  Evaluate  len(${active_alarms_after_desuppressed})
    IF  ${INITIAL_NUMBER_OF_ACTIVE_ALARMS}==${number_of_active_alarms_after_desuppressed}
        Log  Alarms with id:${SUPPRESSED_ALARM_ID} are desuppressed.[OK]  console=true
    ELSE
        Fail  Alarms with id:${SUPPRESSED_ALARM_ID} are not desuppressed.[NOK]
    END


Step2: Check Suppressed Alarms By Fault Id
    Log  \nStep2: Check Suppressed Alarms By Fault Id  console=true
    Go To Parameter Editor And Set Fault Id Searched
    ${active_alarms_after_suppressed}  coam.Get Active Alarms
    FOR  ${alarm}  IN  @{active_alarms_after_suppressed}
        Should Not Be Equal  ${SUPPRESSED_FAULT_ID}  ${alarm}[faultId]
        ...  Faults with id:${SUPPRESSED_FAULT_ID} are not suppressed.[NOK]
    END
    ${number_of_active_alarms_after_suppressed}  Evaluate  len(${active_alarms_after_suppressed})
    IF  ${INITIAL_NUMBER_OF_ACTIVE_ALARMS}>${number_of_active_alarms_after_suppressed}
        Log  Faults with id:${SUPPRESSED_FAULT_ID} are suppressed.[OK]  console=true
    END
    Click Element  ${ALARMS_BUTTON_SITE_VIEW}
    Wait Until Element Is Clicked  //li[@heading="Suppressed Alarms"]  90
    Wait Until Element Is Clicked  //span[contains(text(),'Get Suppressed Alarms')]  90
    Wait Until Element Is Visible  locator=//span[contains(text(),'Get Suppressed Alarms success')]  timeout=120
    Sleep  15s  Time to charge alarms
    Wait Until Element Is Visible  //div[contains(@class, '${TABLE_CLASS}')]/table/tbody/tr/td[3]/div  20
    ${INDEX_STEP}  Set Variable  2
    Set Test Variable  ${INDEX_STEP}
    Check Table With Suppressed Alarms
    Deselect Column In Table
    Check Filter By Severity
    Go To Parameter Editor And Delete Fault Id Object
    ${active_alarms_after_desuppressed}  coam.Get Active Alarms
    ${number_of_active_alarms_after_desuppressed}  Evaluate  len(${active_alarms_after_desuppressed})
    IF  ${INITIAL_NUMBER_OF_ACTIVE_ALARMS}==${number_of_active_alarms_after_desuppressed}
        Log  Faults with id:${SUPPRESSED_FAULT_ID} are desuppressed.[OK]  console=true
    ELSE
        Fail  Faults with id:${SUPPRESSED_FAULT_ID} are not desuppressed.[NOK]
    END


Go To Parameter Editor And Set ${Alarm/Fault} Id Searched
    ${name_id}  Set Variable If  '${Alarm/Fault}'=='Alarm'  alarm  fault
    Go To Parameter Editor And Set ActAlarmsSuppression To SuppressAlarms
    Input Text  //*[@class="cdk-virtual-scroll-content-wrapper"]/table/thead/tr[2]/th[2]/div/input  List of suppressed ${name_id} IDs
    Sleep  10s  Time to complete the parameter
    Click Element  //*[@class="cdk-virtual-scroll-content-wrapper"]/table/tbody/tr[1]/td[6]/p-button[1]/button/span[1]
    Sleep  10s  Time to complete the parameter
    IF  '${Alarm/Fault}'=='Alarm'
        Set AlarmId And AlarmSeverity Values
    ELSE
        Set FaultId And AlarmSeverity Values
    END
    Validate And Activate Plan
    Sleep  60s  Time to charge alarms


Go To Parameter Editor And Set ActAlarmsSuppression To SuppressAlarms
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


Set AlarmId And AlarmSeverity Values
    Input Text  //*[@class="cdk-virtual-scroll-content-wrapper"]/table/tbody/tr[3]/td[4]/cem-parameter-input/cem-string-input/ot-field/div/input
    ...  ${SUPPRESSED_ALARM_ID}
    Sleep  5s  Time to complete the parameter
    Wait Until Element Is Clicked
    ...  //*[@class="cdk-virtual-scroll-content-wrapper"]/table/tbody/tr[4]/td[4]/cem-parameter-input/cem-dropdown-input/div/p-dropdown/div/span[1]
    ...  20s  10s
    Wait Until Element Is Clicked  //*[contains(@aria-label, "MINOR_AND_WARNING")]
    Sleep  5s  Time to complete the parameter


Set FaultId And AlarmSeverity Values
    Wait Until Element Is Clicked
    ...  //*[@class="cdk-virtual-scroll-content-wrapper"]/table/tbody/tr[3]/td[4]/cem-parameter-input/cem-dropdown-input/div/p-dropdown/div/span[1]
    Sleep  5s  Time to complete the parameter
    Wait Until Element Is Clicked  //*[contains(@aria-label, "MINOR_AND_WARNING")]
    Sleep  5s  Time to complete the parameter
    Input Text  //*[@class="cdk-virtual-scroll-content-wrapper"]/table/tbody/tr[4]/td[4]/cem-parameter-input/cem-string-input/ot-field/div/input
    ...  ${SUPPRESSED_FAULT_ID}
    Sleep  5s  Time to complete the parameter


Validate And Activate Plan
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


Check Table With Suppressed Alarms
    ${elememt_in_table}  Get Text  //div[contains(@class, 'cem-toolbar')]/div[1]/div[2]/div/p-multiselect/div/div[2]/div
    IF  '${elememt_in_table}'!='11 columns selected'
        Select All Columns In Table
    END
    Check Head Of Table
    ${number_of_alarms_suppressed}  Get Element Count  //div[contains(@class, '${TABLE_CLASS}')]/table/tbody[1]/tr
    IF  '${ENB_BRANCH}' >= 'SBTS26R2'
        ${number_of_alarms_suppressed}  Evaluate  ${number_of_alarms_suppressed} - 1
    ELSE
        ${number_of_alarms_suppressed}  Set Variable  ${number_of_alarms_suppressed}
    END
    FOR  ${row}  IN RANGE  1  ${number_of_alarms_suppressed}+1
        Set Test Variable  ${alarm_suppressed}  ${EMPTY}
        FOR  ${column}  IN RANGE  2  17
            ${alarm_parameter}  Get Text  //div[contains(@class, '${TABLE_CLASS}')]/table/tbody/tr[${row}]/td[${column}]/div
            ${element}  Get Text  //div[contains(@class, '${TABLE_CLASS}')]/table/thead/tr[1]/th[${column}]/div
            ${alarm_suppressed}  Catenate  SEPARATOR=${SPACE}  ${alarm_suppressed} ${element}:${alarm_parameter}
        END
        Log  Alarm ${row} appear with parameters: ${alarm_suppressed}  console=true
        Should Match Regexp  ${alarm_suppressed}  Latest appeared GMT+[+-]{1}[:. 0-9]*
        Log  Statistic files contain 'Latest appeared GMT'![OK]  console=true
        Should Contain  ${alarm_suppressed}  Alarm ID
        Log  Statistic files contain 'Alarm ID'![OK]  console=true
        Should Contain  ${alarm_suppressed}  Alarm name
        Log  Statistic files contain 'Alarm name'![OK]  console=true
        Should Contain  ${alarm_suppressed}  Fault ID
        Log  Statistic files contain 'Fault ID'![OK]  console=true
        Should Contain  ${alarm_suppressed}  Fault name
        Log  Statistic files contain 'Fault name'![OK]  console=true
        Should Contain  ${alarm_suppressed}  Alarming object
        Log  Statistic files contain 'Alarming object'![OK]  console=true
        Should Contain  ${alarm_suppressed}  Current 10s
        Log  Statistic files contain 'Current 10s'![OK]  console=true
        Should Contain  ${alarm_suppressed}  Last 10s
        Log  Statistic files contain 'Last 10s'![OK]  console=true
        Should Contain  ${alarm_suppressed}  Current minute
        Log  Statistic files contain 'Current minute'![OK]  console=true
        Should Contain  ${alarm_suppressed}  Last minute
        Log  Statistic files contain 'Last minute'![OK]  console=true
        Should Contain  ${alarm_suppressed}  Current hour
        Log  Statistic files contain 'Current hour'![OK]  console=true
        Should Contain  ${alarm_suppressed}  Last hour
        Log  Statistic files contain 'Last hour'![OK]  console=true
        Should Contain  ${alarm_suppressed}  Current day
        Log  Statistic files contain 'Current day'![OK]  console=true
        Should Contain  ${alarm_suppressed}  Last day
        Log  Statistic files contain 'Last day'![OK]  console=true
        Should Contain  ${alarm_suppressed}  All
        Log  Statistic files contain 'All'![OK]  console=true
    END


Select All Columns In Table
    Click Element  //div[contains(@class, 'cem-toolbar')]/div[1]/div[2]/div/p-multiselect/div/div[2]/div
    Sleep  5s  Time for dropdown to appear
    ${checkbox_element}  SeleniumLibrary.Get Element Attribute  //*[@id="laf-component"]/div[1]/div[2]  aria-checked
    IF  ${checkbox_element} == ${FALSE}  Wait Until Element Is Clicked  //*[@id="laf-component"]/div[1]/div[2]
    Sleep  5s  Time for checkbox to be selected
    ${checkbox_element}  SeleniumLibrary.Get Element Attribute  //*[@id="laf-component"]/div[1]/div[2]  aria-checked
    IF  ${checkbox_element}
        Log  In table appear all columns.[OK]  console=true
    ELSE
        Fail  In table are not visible all columns.[NOK]
    END


Check Head Of Table
    ${head_list}  Create List  Severity  Latest appeared  Alarm ID  Alarm name  Fault ID  Fault name  Alarming object  Current 10s  Last 10s
    ...  Current minute  Last minute  Current hour  Last hour  Current day  Last day  All
    FOR  ${row}  IN RANGE  1  17
        ${element}  Get Text  //div[contains(@class, '${TABLE_CLASS}')]/table/thead/tr[1]/th[${row}]/div
        ${list_index}  Evaluate  ${row}-1
        Should Match Regexp  ${element}  ${head_list}[${list_index}]
        Log  Element:${element} appear in table.  console=true
    END
    Check Filters Of Table


Check Filters Of Table
    ${rows}  SeleniumLibrary.Get Element Count  //div[contains(@class, '${TABLE_CLASS}')]/table/thead/tr[2]/th
    FOR  ${row}  IN RANGE  1  ${rows}+1
        ${filter_tab}  Catenate  SEPARATOR=  //div[contains(@class, '${TABLE_CLASS}')]/table/thead/tr[2]/th[${row}]/ot-column-filter/div/
        ...  ot-column-filter-form-element/div/input
        ${status}  Run Keyword And Return Status  Element Should Be Visible  ${filter_tab}
        IF  ${status}
            IF  ${row}==7
                ${last_part}  Fetch From Right  ${SELECTED_ALARM}[alarmingObjectIds][0][internal]  /
                ${last_part}  Fetch From Left  ${last_part}  _
                Input Text  ${filter_tab}  ${last_part}
                Sleep  5s  Time to complete the parameter
            ELSE IF  ${row}==3
                Input Text  ${filter_tab}  ${SELECTED_ALARM}[alarmId]
                Sleep  5s  Time to complete the parameter
            ELSE IF  ${row}==5
                Input Text  ${filter_tab}  ${SELECTED_ALARM}[faultId]
                Sleep  5s  Time to complete the parameter
            END
        END
    END
    Sleep  10s  Time for table to be visible
    ${number_of_rows}  SeleniumLibrary.Get Element Count  //div[contains(@class, '${TABLE_CLASS}')]/table/tbody[1]/tr
    ${alarm_id_text}  Wait Until Keyword Succeeds  200  5  Get Text  //div[contains(@class, '${TABLE_CLASS}')]/table/tbody/tr/td[3]/div
    IF  ${number_of_rows}==1 and '${alarm_id_text}'=='${SUPPRESSED_ALARM_ID}'
        Log  \nFilters work successfully.[OK]  console=true
    ELSE
        Fail  Filters not work successfully.[NOK]
    END
    FOR  ${row}  IN RANGE  1  ${rows}+1
        ${filter_tab}  Catenate  SEPARATOR=  //div[contains(@class, '${TABLE_CLASS}')]/table/thead/tr[2]/th[${row}]/ot-column-filter/div/
        ...  ot-column-filter-form-element/div/input
        ${status}  Run Keyword And Return Status  Element Should Be Visible  ${filter_tab}
        IF  ${status}
            Press Keys  ${filter_tab}  CTRL+a+BACKSPACE  ENTER
            Sleep  5s  Time to complete the parameter
        END
    END
    Sleep  5s  Time for page to be updated
    Capture Page Screenshot  webem_after_clear_filter.png
    ${number_of_rows}  Get Element Count  //div[contains(@class, '${TABLE_CLASS}')]/table/tbody[1]/tr
    IF  ${INDEX_STEP} == 1
        IF  '${ENB_BRANCH}' < 'SBTS26R2' and ${number_of_rows}>=1 or '${ENB_BRANCH}' >= 'SBTS26R2' and ${number_of_rows}>=2
            Log  \nFilters are cleared.[OK]  console=true
        ELSE
            Fail  \nFilters are not cleared.[NOK]
        END
    ELSE IF  ${INDEX_STEP} == 2
        IF  ${number_of_rows}>=1
            Log  \nFilters are cleared.[OK]  console=true
        ELSE
            Fail  \nFilters are not cleared.[NOK]
        END
    END


Deselect Column In Table
    Log  Deselect Columns In Table  console=true
    ${elememt_in_table}  Get Text  //div[contains(@class, 'cem-toolbar')]/div[1]/div[2]/div/p-multiselect/div/div[2]/div
    IF  '${elememt_in_table}'=='11 columns selected'
        Click Element  //div[contains(@class, 'cem-toolbar')]/div[1]/div[2]/div/p-multiselect/div/div[2]/div
        ${columns}  SeleniumLibrary.Get Element Count  //*[@id="laf-component"]/ul/p-multiselectitem
        FOR  ${column}  IN RANGE  1  ${columns}+1
            ${permission_parameter}  SeleniumLibrary.Get Element Attribute
            ...  //*[@id="laf-component"]/ul/p-multiselectitem[${column}]/li  aria-selected
            ${name_parameter}  SeleniumLibrary.Get Element Attribute
            ...  //*[@id="laf-component"]/ul/p-multiselectitem[${column}]/li  aria-label
            IF  '${permission_parameter}'=='true'  Click Element
            ...  //*[@id="laf-component"]/ul/p-multiselectitem[${column}]
            BREAK
        END
        Click Element  //div[contains(@class, 'cem-toolbar')]/div[1]/div[2]/div/p-multiselect/div/div[2]/div
        ${number_of_rows}  Get Element Count  //div[contains(@class, '${TABLE_CLASS}')]/table/thead/tr[1]/th
        IF  '${ENB_BRANCH}' >= 'SBTS26R2'
            ${number_of_rows}  Evaluate  ${number_of_rows} - 3
        ELSE
            ${number_of_rows}  Set Variable  ${number_of_rows}
        END
        FOR  ${row}  IN RANGE  1  ${number_of_rows}+1
            ${element}  Get Text  //div[contains(@class, '${TABLE_CLASS}')]/table/thead/tr[1]/th[${row}]/div
            Should Not Contain  ${element}  ${name_parameter}  msg=Element:${name_parameter} not was deselected.[NOK]
        END
        Log  Column:${name_parameter} is deselected[OK]  console=true
    END


Check Filter By Severity
    ${severity}  SeleniumLibrary.Get Element Attribute
    ...  //div[contains(@class, 'cem-toolbar')]/div[1]/div[1]/div/span[3]/p-togglebutton/div  aria-checked
    IF  '${severity}'=='true'  Click Element  //div[contains(@class, 'cem-toolbar')]/div[1]/div[1]/div/span[3]/p-togglebutton
    Wait Until Element Is Visible  //*[contains(text(), ' No alarms available for selected filtering options ')]  timeout=30
    Click Element  //div[contains(@class, 'cem-toolbar')]/div[1]/div[1]/div/span[3]/p-togglebutton
    Log  Filter by severity is checked![OK]  console=true


Go To Parameter Editor And Delete ${Alarm/Fault} Id Object
    ${name_id}  Set Variable If  '${Alarm/Fault}'=='Alarm'  alarm  fault
    Wait Until Element Is Clicked  ${PARAMETER_EDITOR}  90
    ${filter_xpath}  Catenate  SEPARATOR=  //*[@id="laf-component"]/blocks-parameter-editor-layout/div/div/blocks-navigation/ot-side-sheet/div/div[1]
    ...  /div/div[2]/p-tree/div/div/input
    Input Text  ${filter_xpath}  ALARMSUPP-1
    Wait Until Element Is Clicked  //span[contains(@class, 'ot-highlight-text') and contains(text(), 'ALARMSUPP-1')]  90
    Input Text  //*[@class="cdk-virtual-scroll-content-wrapper"]/table/thead/tr[2]/th[2]/div/input  Activation of alarms suppression
    ${first_parameter}  Catenate  SEPARATOR=  //*[@class="cdk-virtual-scroll-content-wrapper"]/table/tbody/tr[1]/td[4]/cem-parameter-input/
    ...  cem-dropdown-input/div/p-dropdown/div/span
    Wait Until Element Is Clicked  ${first_parameter}
    Wait Until Element Is Visible  //li[contains(@aria-label, "disabled")]  timeout=30
    Wait Until Element Is Clicked  //li[contains(@aria-label, "disabled")]
    Sleep  5s  Time to complete the parameter
    Input Text  //*[@class="cdk-virtual-scroll-content-wrapper"]/table/thead/tr[2]/th[2]/div/input  List of suppressed ${name_id} IDs
    Wait Until Element Is Enabled  //*[@class="cdk-virtual-scroll-content-wrapper"]/table/tbody/tr[2]/td[6]/p-button[1]/button/span[1]  20
    Wait Until Element Is Clicked  //*[@class="cdk-virtual-scroll-content-wrapper"]/table/tbody/tr[2]/td[6]/p-button[1]/button/span[1]
    Validate And Activate Plan


TC Setup
    Common Test Setup
    WebEM Setup


TC Teardown
    Run Keyword If Test Failed  Load A Specific SCF  ${COMMISSIONING_PATH}
    WebEM Teardown
    Common Test Teardown

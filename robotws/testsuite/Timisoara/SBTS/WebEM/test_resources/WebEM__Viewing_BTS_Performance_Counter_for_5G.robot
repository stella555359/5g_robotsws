*** Settings ***
Documentation
    ...  This test case is created to view BTS Performance Counter for NRBTS and NRCELL.
    ...  Verify if 5G cells exist.
    ...  Verify if all cells on SBTS are working.
    ...  Reset site is performed and verify if all cells are in expected state.
    ...  Open Performance Management menu and choose BTS Counter.
    ...  From BTS section, NRBTS is chosen for checking all counters.
    ...  Check if message appears: Max limit of 20 selected counters has been reached!
    ...  Check if all counters have a value. If one counter is -, test will fail.
    ...  Export to CSV is performed.
    ...  Check if chart appears in Plot View.
    ...  Save Snapshot is performed.
    ...  From CELL section, all NRCELL are chosen for checking all counters.
    ...  Check if message appears: Max limit of 20 selected counters has been reached!
    ...  Check if all counters have a value. If one counter is -, test will fail.
    ...  Export to CSV is performed.
    ...  Check if chart appears in Plot View.
    ...  Save Snapshot is performed.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${RECOVERY_TIMEOUT}  1200  # Timeout for SBTS to recover and for counters to appear


*** Keywords ***
TC__WebEM__Viewing_BTS_Performance_Counter_for_5G
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-21614
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 20.07.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21614 - Initial TAT creation
    ...  - 10.02.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22656 - Fixed check for BTS counters
    ...  - 19.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23935 - Remove KWs changed in resource
    ...  - 11.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24106 - Change Sleep until new cycle is ready KW
    ...  - 25.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24131 - Refactor TCs with best practice
    ...  - 15.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24316 - Refactor WebEM TCs and resources to use KWs from ca_SBTS_general
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Add watchdog alarm monitoring
    ...  - 14.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27085 - Change xpaths for a version higher than 24R2
    ...  - 05.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27566 - Fixed NRCELL xpath
    ...  - 11.02.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28508 - Fixed cell name and nrbts xpath
    ...  - 12.06.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29151 - Fix cell xpath for actual trunk 25R3
    ...  - 22.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29756 - Fixed filter input and nrcell object xpaths
    ...  - 30.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30104 - Fix export to csv KW
    ...  - 22.12.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30348 - Change xpaths for a version higher than 26R2
    ...  - 21.01.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30416 - Corrected xpath for NRCELL object
    ...  - 29.01.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30451 - Fix export to csv and save snapshot for actual trunk release 26R2

    Set Tags  CA-WebEM  OWNER-george.gheban@nokia.com  AUTHOR-andreea.burtic@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf  SW-SBTS22

    Step0: TC Preconditions
    Step1: Verify Cells On SBTS And Perform Reset Site
    Step2: Open Performance Management
    Step3: BTS-NRBTS Counters
    Step4: CELL-NRCELL Counters


Step0: TC Preconditions
    IF  ${SCF_COUNT_NR}
        Log  NR cells exist!  console=true
    ELSE
        Fail  NR cells does not exist
    END
    ${nrbts_id}  Get id for current  NRBTS
    ${nrbts_id}  Fetch From Right  ${nrbts_id}  NRBTS_R-
    Set Test Variable  ${NRBTS_ID}  ${nrbts_id}
    Get NR Cell Name
    ${sbts_name}  Get Text  ${SBTS_NAME_XPATH}
    Set Test Variable  ${SBTS_NAME}  ${sbts_name}


Step1: Verify Cells On SBTS And Perform Reset Site
    Log  Step1: Verify cells on SBTS and perform Reset Site  console=true
    Reset SBTS From Admin
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10  Admin Check All Required State


Step2: Open Performance Management
    Log  Step2: Open Performance Management  console=true
    Wait Until Element Is Clicked  ${BTS_COUNTERS}  120
    ${counter}  Catenate  SEPARATOR=  //*[@class="performance-management-view"]/div/div/div[1]
    ...  /div/div[1]/historical-counters-main/div/pm-message/div
    ${status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Element Should Not Be Visible  ${counter}
    IF  ${status}
        Log  Some counters are available![OK]  console=true
    ELSE
        Fail  Counters are not available after ${RECOVERY_TIMEOUT}s![NOK]
    END


Step3: BTS-NRBTS Counters
    Log  Step3: BTS-NRBTS Counters  console=true
    Log  Waiting for BTS with NRBTS counters to be available  console=true
    IF  '${ENB_BRANCH}' >= 'SBTS26R2'
        ${nrbts_counter}  Set Variable  //*[@class="historical-counters-global-search"]/pm-tree/div/div/div/div/div[1]/span
    ELSE
        ${nrbts_counter}  Set Variable  //*[@class="historical-counters-global-search"]/pm-tree/div/div/div/div/div/div[1]/span
    END
    Wait Until Element Is Visible  ${nrbts_counter}  ${RECOVERY_TIMEOUT}
    ${bts}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Element Should Contain  ${nrbts_counter}  BTS
    IF  ${bts}
        NRBTS Counter
    ELSE
        Fail  BTS Counter are not available after ${RECOVERY_TIMEOUT}s![NOK]
    END


Step4: CELL-NRCELL Counters
    Log  Step4: CELL-NRCELL Counters  console=true
    IF  '${ENB_BRANCH}' >= 'SBTS26R2'
        ${command}  Set Variable  //*[@class="historical-counters-global-search"]/pm-tree/div/div/div/div/div[2]/i
        ${new_command}  Set Variable  //*[@class="historical-counters-global-search"]/pm-tree/div/div/div/div/div[5]/i
    ELSE
        ${command}  Set Variable  //*[@class="historical-counters-global-search"]/pm-tree/div/div/div/div/div/div[2]/i
        ${new_command}  Set Variable  //*[@class="historical-counters-global-search"]/pm-tree/div/div/div/div/div/div[5]/i
    END
    IF  '${ENB_BRANCH}'<'SBTS24R2'
        Wait Until Element Is Clicked  ${command}  60
    ELSE
        Wait Until Element Is Clicked  ${new_command}  60
    END
    FOR  ${cell}  IN  @{NR_CELLS}
        ${cell_tab}  Catenate  SEPARATOR=${SPACE}  //span[contains(@class, 'pm-input-span pm-input-span-indeterminate pm-input-span-checked') and
         ...  contains(@title, "${cell}")]
        ${status}  Run Keyword And Return Status
        ...  Wait Until Keyword Succeeds  30  10
        ...  Element Should Be Enabled  //span[contains(@class, 'pm-input-span') and contains(@title, "${cell}")]
        ${status_checked}  Run Keyword And Return Status
        ...  Wait Until Keyword Succeeds  20  5
        ...  Element Should Be Enabled  ${cell_tab}
        ${input_xpath_old}  Catenate  SEPARATOR=  //*[@id="main-view"]/div/div[1]/div[1]/div/global-search/div/wf-panel/wf-
        ...  panel-section/div/div/div/div/div[2]/global-search-tab-content/historical-counters-global-search/div/pm-t
        ...  ree/div/pm-tree-filter/ui-text-input/div/input
        ${input_xpath_new}  Catenate  SEPARATOR=  //*[@id="main-view"]/div/div[1]/div/div/div[1]/global-search/div/wf-panel/wf-panel-section/div/div/
        ...  div/div/div[2]/global-search-tab-content/historical-counters-global-search/div/pm-tree/div/pm-tree-filter/ui-text-input/div/input
        ${nrcell_object_xpath_old}  Catenate  SEPARATOR=  //*[@id="main-view"]/div/div[1]/div[1]/div/global-search/div/wf-
        ...  panel/wf-panel-section/div/div/div/div/div[2]/global-search-tab-content/historical-counters-global-search
        ...  /div/pm-tree/div/div/div/div/div/div[3]/label/span
        IF  '${ENB_BRANCH}' >= 'SBTS26R2'
            ${nrcell_object_xpath_new}  Set Variable  //*[@class="historical-counters-global-search"]/pm-tree/div/div/div/div/div[3]/label/span
        ELSE
            ${nrcell_object_xpath_new}  Set Variable  //*[@class="historical-counters-global-search"]/pm-tree/div/div/div/div/div/div[3]/label/span
        END
        IF  ${status} and ${status_checked}==${FALSE}
            Wait Until Element Is Clicked  //span[contains(@class, 'pm-input-span') and contains(@title, "${cell}")]  60
        ELSE IF  '${ENB_BRANCH}'<'SBTS24R2'
            Click Element  ${command}
            Wait Until Element Is Clicked  //span[contains(@class, 'pm-input-span') and contains(@title, "${cell}")]  120
        ELSE IF  ${status}==${FALSE} and ${status_checked}==${FALSE} and '${ENB_BRANCH}'=='SBTS25R3'
            Input Text  ${input_xpath_old}  ${cell}
            Sleep  10s  Time for cell to be visible
            Click Element  ${nrcell_object_xpath_old}
        ELSE IF  ${status}==${FALSE} and ${status_checked}==${FALSE} and '${ENB_BRANCH}'>='SBTS26R1'
            Input Text  ${input_xpath_new}  ${cell}
            Sleep  10s  Time for cell to be visible
            Click Element  ${nrcell_object_xpath_new}
        ELSE IF  ${status}==${FALSE} and ${status_checked}==${FALSE}
            Click Element  ${NRBTS_XPATH}
            Wait Until Element Is Clicked  //span[contains(@class, 'pm-input-span') and contains(@title, "${cell}")]  120
        END
        Log  Verify Counters for ${cell}!  console=true
        ${status}  Run Keyword And Return Status
        ...  Wait Until Keyword Succeeds  60  10
        ...  Element Should Be Visible  ${cell_tab}
        IF  ${status}==${FALSE}
            Click Element  //span[contains(@class, 'pm-input-span') and contains(@title, "${cell}")]
        ELSE IF  ${status}==${FALSE} and '${ENB_BRANCH}'=='SBTS25R3'
            Click Element  ${nrcell_object_xpath_old}
        ELSE IF  ${status}==${FALSE} and '${ENB_BRANCH}'>='SBTS26R1'
            Click Element  ${nrcell_object_xpath_new}
        END
        Check If Max Limit Message Appeard
        Check NRCELL Counters
        Export To CSV  ${cell}
        Plot View
        Save Snapshot  ${cell}
        Wait Until Element Is Clicked  ${cell_tab}  60
    END


Check NRCELL Counters
    ${tr_count}  Catenate  SEPARATOR=  //*[@class="performance-management-view"]/div/div/
    ...  div[1]/div/div[1]/historical-counters-main/div/historical-counters-table/div/div/table/tbody/tr
    ${tr}  SeleniumLibrary.Get Element Count  ${tr_count}
    FOR  ${index}  IN RANGE  1  ${tr}+1
        ${td_count}  Catenate  SEPARATOR=  //*[@class="performance-management-view"]/div/div/
        ...  div[1]/div/div[1]/historical-counters-main/div/historical-counters-table/div/div/table/tbody/tr[${index}]/td
        ${td}  SeleniumLibrary.Get Element Count  ${td_count}
        Check Counters For NRCELL  ${td}  ${index}
    END


Check Counters For NRCELL
    [Arguments]  ${td}  ${index}

    ${time_text}  Catenate  SEPARATOR=  //*[@class="performance-management-view"]/div/div/div[1]
    ...  /div/div[1]/historical-counters-main/div/historical-counters-table/div/div/table/tbody/tr[${index}]/td[1]
    ${time}  Get Text  ${time_text}
    ${counter_values_list}  Create List
    FOR  ${number}  IN RANGE  2  ${td}+1
        ${counter_text}  Catenate  SEPARATOR=  //*[@class="performance-management-view"]/div/div
        ...  /div[1]/div/div[1]/historical-counters-main/div/historical-counters-table/div/div/table/tbody/tr[${index}]/td[${number}]
        ${counter_value}  Get Text  ${counter_text}
        Append To List  ${counter_values_list}  ${counter_value}
    END
    Log  \n Values for time ${time}: ${counter_values_list}  console=true
    ${counters_status}  Run Keyword And Return Status
    ...  List Should Not Contain Value  ${counter_values_list}  -
    IF  ${counters_status}
        Log  For the time ${time} all counters have a value, test will continue [OK]  console=true
    ELSE
        Fail  For the time ${time} some counters are empty, test will be set to failed [NOK]
    END


Export To CSV
    [Arguments]  ${counter}

    Log  Export to CSV  console=true
    ${status}  Run Keyword And Return Status  Wait Until Element Is Clicked  //*[contains(@a-text, 'Export to CSV')]  60
    Sleep  10s  This sleep is to wait for the download to be completed
    IF  ${status}
        Log  Exporting to CSV has been performed successfully!  console=true
    ELSE
        Fail  Export to CSV was not performed!
    END
    IF  '${ENB_BRANCH}' >= 'SBTS26R2'
        ${SBTS_NAME_EXPORT}  Replace String  ${sbts_name}  ${SPACE}  _
        Set Test Variable  ${SBTS_NAME_EXPORT}
        Move File  /home/ute/Downloads/PM_MRBTS-${BTS_ID}_${SBTS_NAME_EXPORT}_*.csv  ${BTS_FILES}/PM_SBTS-${BTS_ID}_${counter}.csv
    ELSE
        Move File  /home/ute/Downloads/PM_MRBTS-${BTS_ID}_${SBTS_NAME}_*.csv  ${BTS_FILES}/PM_SBTS-${BTS_ID}_${counter}.csv
    END


Plot View
    Log  Plot View  console=true
    ${plot_button}  Catenate  SEPARATOR=  //*[@class="performance-management-view"]/div/div/
    ...  div[1]/div/div[1]/historical-counters-main/pm-buttons/execution-bar/div/ui-button[1]
    Click Element  ${plot_button}
    Log  Verify if chart appeard  console=true
    ${chart}  Catenate  SEPARATOR=  //*[@class="performance-management-view"]/div/div/
    ...  div[1]/div/div[1]/historical-counters-main/div/historical-counters-chart
    ${plot}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  120  10
    ...  Element Should Be Visible  ${chart}
    IF  ${plot}
        Log  Chart is visible in Plot View![OK]  console=true
    ELSE
        Fail  Chart is not visible in Plot View![NOK]
    END


Save Snapshot
    [Arguments]  ${counter}

    Log  Saving Snapshot...  console=true
    ${status}  Run Keyword And Return Status
    ...  Wait Until Element Is Clicked  //*[contains(@a-text, 'Save Snapshot')]  120
    Sleep  10s  This sleep is to wait for the download to be completed
    IF  ${status}
        Log  Saving snapshot has been performed successfully!  console=true
    ELSE
        Fail  Saving snapshot was not performed!
    END
    IF  '${ENB_BRANCH}' >= 'SBTS26R2'
        Move File  /home/ute/Downloads/PM_MRBTS-${BTS_ID}_${SBTS_NAME_EXPORT}_*.png  ${BTS_FILES}/PM_SBTS-${BTS_ID}_${counter}.png
    ELSE
        Move File  /home/ute/Downloads/PM_MRBTS-${BTS_ID}_${SBTS_NAME}_*.png  ${BTS_FILES}/PM_SBTS-${BTS_ID}_${counter}.png
    END
    ${snapshot}  Catenate  SEPARATOR=  //*[@class="performance-management-view"]/div/div/
    ...  div[1]/div/div[1]/historical-counters-main/pm-buttons/execution-bar/div/ui-button[1]
    Click Element  ${snapshot}


NRBTS Counter
    IF  '${ENB_BRANCH}' >= 'SBTS26R2'
        ${button}  Set Variable  //*[@class="historical-counters-global-search"]/pm-tree/div/div/div/div/div[1]/i
    ELSE
        ${button}  Set Variable  //*[@class="historical-counters-global-search"]/pm-tree/div/div/div/div/div/div[1]/i
    END
    Click Element  ${button}
    ${xpath_nrbts}  Set Variable If  '${ENB_BRANCH}'=='SBTS00' or '${ENB_BRANCH}'>='SBTS24R2'  //*[contains(text(), "NRBTS-${NRBTS_ID}")]
    ...  //*[contains(text(), "[${SBTS_NAME}] NRBTS-${NRBTS_ID}")]
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Element Should Be Enabled  ${xpath_nrbts}
    ${number1}  SeleniumLibrary.Get Element Count  class:pm-tree-level-0
    ${number2}  SeleniumLibrary.Get Element Count  class:pm-tree-level-1
    ${final}  Evaluate  ${number1}+${number2}
    FOR  ${index}  IN RANGE  1  ${final}+1
        IF  '${ENB_BRANCH}' >= 'SBTS26R2'
            ${title}  Set Variable  //*[@class="historical-counters-global-search"]/pm-tree/div/div/div/div/div[${index}]/label/span
        ELSE
            ${title}  Set Variable  //*[@class="historical-counters-global-search"]/pm-tree/div/div/div/div/div/div[${index}]/label/span
        END
        ${title_element}  SeleniumLibrary.Get Element Attribute  ${title}  title
        IF  '${ENB_BRANCH}' >= 'SBTS26R2'
            ${historical}  Set Variable  //*[@class="historical-counters-global-search"]/pm-tree/div/div/div/div/div[${index}]/label/span
        ELSE
            ${historical}  Set Variable  //*[@class="historical-counters-global-search"]/pm-tree/div/div/div/div/div/div[${index}]/label/span
        END
        IF  '${title_element}'=='[${SBTS_NAME}] NRBTS-${NRBTS_ID}' or '${title_element}'=='NRBTS-${NRBTS_ID}'
            Click Element  ${historical}
            Check BTS Counter, Export To CSV, Plot View And Save Snapshot
            Wait Until Element Is Clicked  ${historical}  60
            IF  '${ENB_BRANCH}' >= 'SBTS26R2'
                Set Test Variable  ${NRBTS_XPATH}  //*[@class="historical-counters-global-search"]/pm-tree/div/div/div/div/div[${index}]/i
            ELSE
                Set Test Variable  ${NRBTS_XPATH}  //*[@class="historical-counters-global-search"]/pm-tree/div/div/div/div/div/div[${index}]/i
            END
        END
    END
    IF  '${ENB_BRANCH}'<'SBTS24R2'  Click Element  ${button}


Check BTS Counter, Export To CSV, Plot View And Save Snapshot
    Check If Max Limit Message Appeard
    Check NRBTS Counters
    Export To CSV  NRBTS-${NRBTS_ID}
    Plot View
    Save Snapshot  NRBTS-${NRBTS_ID}


Check NRBTS Counters
    ${td_count}  Catenate  SEPARATOR=  //*[@class="performance-management-view"]/div/div/
    ...  div[1]/div/div[1]/historical-counters-main/div/historical-counters-table/div/div/table/tbody/tr/td
    ${td}  SeleniumLibrary.Get Element Count  ${td_count}
    Check Counters For BTS  ${td}
    Sleep Until New Cycle Is Ready
    Check Counters For BTS  ${td}
    Sleep Until New Cycle Is Ready
    Check Counters For BTS  ${td}
    Sleep Until New Cycle Is Ready
    Check Counters For BTS  ${td}


Get NR Cell Name
    ${xpaths_cells}  Get Xpath List For Cells  NR
    ${nr_cells}  Create List
    ${name}  Catenate  SEPARATOR=  //*[contains(@class, 'details-panel-container')]/wf-panel/wf-panel-section/div/div/
    ...  details-panel-content/div/hardware-details/div/div/div[1]/div/div/div[3]/div/div[1]/div/div/div/table/tbody/tr[2]/td[2]
    ${cell_id_xpath}  Catenate  SEPARATOR=  //*[contains(@class, 'details-panel-container')]/wf-panel/wf-panel-section/div/div/
    ...  details-panel-content/div/hardware-details/div/div/div[1]/div/div/div[3]/div/div[1]/div/div/div/table/tbody/tr[1]/td[2]
    FOR  ${cell}  IN  @{xpaths_cells}
        Click Element  ${cell}
        ${cells_n}  Get Text  ${name}
        ${cell_id}  Get Text  ${cell_id_xpath}
        ${str_cell_name}  Convert To String  ${cells_n}
        ${str_cell_id}  Convert To String  ${cell_id}
        IF  '${str_cell_name}'=='-'
            ${cell_name}  Catenate  SEPARATOR=-  NRCELL  ${str_cell_id}
        ELSE
            ${cell_name}  Catenate  SEPARATOR=${SPACE}  [${str_cell_name}]  NRCELL-${str_cell_id}
        END
        Append To List  ${nr_cells}  ${cell_name}
    END
    Set Test Variable  ${NR_CELLS}


Check Counters For BTS
    [Arguments]  ${td}

    ${time_text}  Catenate  SEPARATOR=  //*[@class="performance-management-view"]/div/div/
    ...  div[1]/div/div[1]/historical-counters-main/div/historical-counters-table/div/div/table/tbody/tr/td[1]
    ${time}  Get Text  ${time_text}
    ${dropdown}  Catenate  SEPARATOR=  //*[@class="performance-management-view"]/div/div
    ...  /div[1]/div/div[1]/historical-counters-main/pm-buttons/execution-bar/div/period-select/ui-select/div/wf-dropdown/div/button
    Double Click Element  ${dropdown}
    ${counter_values_list}  Create List
    FOR  ${index}  IN RANGE  2  ${td}+1
        ${counter}  Catenate  SEPARATOR=  //*[@class="performance-management-view"]/div/div
        ...  /div[1]/div/div[1]/historical-counters-main/div/historical-counters-table/div/div/table/tbody/tr/td[${index}]
        ${counter_value}  Get Text  ${counter}
        Append To List  ${counter_values_list}  ${counter_value}
    END
    Log  Values for time ${time}: ${counter_values_list}  console=true
    ${counters_status}  Run Keyword And Return Status
    ...  List Should Not Contain Value  ${counter_values_list}  -
    IF  ${counters_status}
        Log  For the time ${time} all counters have a value, test will continue [OK]  console=true
    ELSE
        Fail  For the time ${time} some counters are empty, test will be set to failed [NOK]
    END


Check If Max Limit Message Appeard
    ${message}  Catenate  SEPARATOR=  //*[@class="performance-management-view"]/div/div/
    ...  div[1]/div/div[1]/historical-counters-main/div/pm-message/div
    ${status}  Run Keyword And Return Status
    ...  Wait Until Element Is Enabled  ${message}  120
    IF  ${status}  Log Message  ${message}


Log Message
    [Arguments]  ${message}
    ${text}  Get Text  ${message}
    Log  Message: ${text}, appeard!  console=true


Sleep Until New Cycle Is Ready
    @{time}  Get Time  min sec
    ${minutes}  Set Variable  00:15:00
    FOR  ${index}  IN RANGE  0  4
        IF  '00:${time}[0]:${time}[1]' < '${minutes}'
            BREAK
        ELSE
            ${minutes}  Add Time To Time  ${minutes}  15:00  timer  exclude_millis=yes
        END
    END
    ${minutes}  Subtract Time From Time  ${minutes}  00:${time}[0]:${time}[1]  timer  exclude_millis=yes
    ${minutes}  Add Time To Time  ${minutes}  00:00:40  timer  exclude_millis=yes
    Log  \n Sleep for ${minutes} minutes until new 15 min cycle for counters  console=true
    ${min}  Fetch From Right  ${minutes}  00:
    ${min}  Fetch From Left  ${min}  :
    ${min_int}  Convert To Integer  ${min}
    IF  ${min_int} < 10
        Sleep  ${minutes}
    ELSE
        Sleep  10m
        Double Click Element  //*[contains(@class, 'details-panel-container')]/ui-button/button/i
        Evaluate Extra Time  ${min}
    END

Evaluate Extra Time
    [Arguments]  ${min}

    ${extra_time}  Evaluate  ${min} - 9
    Sleep  ${extra_time}m


TC Setup
    Common Test Setup  infomodel_launch=${FALSE}  tc_name=WebEM__Viewing_BTS_Performance_Counter_for_5G
    WebEM Setup


TC Teardown
    WebEM Teardown
    Common Test Teardown

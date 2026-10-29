*** Settings ***
Resource    ../../common_resources/ca_WebEM_general.robot


*** Keywords ***
TC__WebEM__Antenna_Line_Monitoring
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-21612
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This test case is created to perform antenna line monitoring test.
    ...  Verify how many RMODs exists.The Diagnostic menu opens and the Antenna Line Monitoring is selected.
    ...  All existing RMODs are selected.
    ...  The Start button is pressed and waits 5 minutes to perform the test and the Stop button is pressed.
    ...  Verify if VSWR tabel contains the title "VSWR (Total 30 time intervals)" or "VSWR" and the values are read.
    ...  Verify if RTWP LTE tabel contains the title "VSWR (Total 30 time intervals)" or "RTWP LTE" and the values are read.
    ...  Verify if RTWP WCDMA tabel contains the title "VSWR (Total 30 time intervals)" or "RTWP WCDMA" and the values are read.
    ...  Verify if RSSI GSM tabel contains the title "VSWR (Total 30 time intervals)" or "RSSI GSM" and the values are read.
    ...  If all values in the tables are 0, the test will failed.
    ...  Button Export to CSV is pressed for exporting the values in CSV format.
    ...  History of changes
    ...  ******************
    ...  - 20.07.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21612 - Initial TAT creation
    ...  - 25.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22261 - Wrong Xpath for tables
    ...  - 25.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24131 - Refactor TCs with best practice

    Set Tags    CA-WebEM    OWNER-george.gheban@nokia.com    AUTHOR-andreea.burtic@nokia.com
    ...    MAINTAINER-andreea.burtic@nokia.com    GROUP_IN_CHARGE-TIM_3_Vrf    PHASE-CRT    SW-SBTS21B

    Step1: Open Antenna Line Monitoring and choose all RMODs
    Step2: Start/Stop test
    Step3: Verify VSWR
    Step4: Verify RTWP LTE
    Step5: Verify RTWP WCDMA
    Step6: Verify RSSI GSM
    Step7: Verify all values
    Step8: Export to CSV


Step1: Open Antenna Line Monitoring and choose all RMODs
    Log  Step1: Open Antenna Line Monitoring and choose all RMODs  console=true
    ${rmods}  Selenium2Library.Get Element Count  class:rmod-grid-element
    Click Element  //*[@id="admin.navigationBar.diagnostic.TITLE"]
    Click Element  //*[@id="main-view"]/div/div[1]/app-header/main-menu/nav-item[6]/div/ng-transclude/div/div[8]/nav-link
    FOR  ${id}  IN RANGE  1  ${rmods}+1
        ${rmod}  Catenate  SEPARATOR=  xpath:/html/body/main-view/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section
        ...  /div/div/ant-monitoring/div/antenna-line-tree-list/section/div/div/div/ul/li[${id}]
        Double Click Element  ${rmod}
        ${rmods_button}  Catenate  SEPARATOR=  xpath:/html/body/main-view/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section
        ...  /div/div/ant-monitoring/div/antenna-line-tree-list/section/div/div/div/ul/li[${id}]/div/div/div/
        ...  antenna-line-tree-list-renderer/div/label/span
        Click Element  ${rmods_button}
    END

Step2: Start/Stop test
    Log  Step2: Start/Stop test  console=true
    Log  Start button is pressed!  console=true
    Click Element  xpath=//*[contains(@a-text, 'Start')]
    Log  Waiting 5 minutes for the appearance of values in tables(VSWR,RTWP LTE,RTWP WCDMA,RSSI GSM)  console=true
    Sleep  307s
    Log  Stop button is pressed!  console=true
    Click Element  xpath=//*[contains(@a-text, 'Stop')]

Step3: Verify VSWR
    Log  Step3: Verify VSWR  console=true
    ${vswr}  Catenate  SEPARATOR=  //*[@id="main-view"]/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div/
    ...  ant-monitoring/div/ant-monitoring-results-panels/section/div/expansion-panel/div[1]/span/span[1]/expansion-panel-header
    ${name_vswr}  Get Text  ${vswr}
    ${vswr_results}  Catenate  SEPARATOR=  //*[@id="main-view"]/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div/
    ...  ant-monitoring/div/ant-monitoring-results-panels/section/div/n-site-type-recognize-ui/div/expansion-panel/div[2]
    ${result}  Get Text  ${vswr_results}
    Run keyword if  '${name_vswr}'=='VSWR (Total 30 time intervals)'
    ...  Log  ${name_vswr}  console=true
    ...  ELSE IF  '${name_vswr}'=='VSWR'
    ...  Log  ${result}  console=true
    ...  ELSE
    ...  Set test restriction  ${name_vswr} had to be -VSWR (Total 30 time intervals)- because the test lasts 5 minutes!
    ${vswr_values}  Catenate  SEPARATOR=  //*[@id="main-view"]/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div
    ...  /ant-monitoring/div/ant-monitoring-results-panels/section/div/expansion-panel/div[2]/div/
    ...  ant-monitoring-results-table/section/div[2]/table/tbody
    ${vswr_tbody_values}  Selenium2Library.Get Element count  ${vswr_values}
    ${VSWR_VALUES_LIST}  Create list
    Set Test Variable  ${VSWR_VALUES_LIST}
    FOR  ${index}  IN RANGE  1  ${vswr_tbody_values}+1
        ${vswr_count}  Catenate  SEPARATOR=  //*[@id="main-view"]/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div
        ...  /ant-monitoring/div/ant-monitoring-results-panels/section/div/expansion-panel/div[2]/div/
        ...  ant-monitoring-results-table/section/div[2]/table/tbody[${index}]/tr
        ${vswr_values}  Selenium2Library.Get Element count  ${vswr_count}
        VSWR table values  ${vswr_values}  ${index}
        Append to list  ${VSWR_VALUES_LIST}  @{VSWR_LIST}
    END

Step4: Verify RTWP LTE
    Log  Step4: Verify RTWP LTE  console=true
    ${rtwp_name}  Catenate  SEPARATOR=  //*[@id="main-view"]/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div
    ...  /ant-monitoring/div/ant-monitoring-results-panels/section/div/n-site-type-recognize-ui/div/expansion-panel[1]
    ...  /div[1]/span/span[1]/expansion-panel-header
    ${name_rtwp_lte}  Get Text  ${rtwp_name}
    ${rtwp_result}  Catenate  SEPARATOR=  //*[@id="main-view"]/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div
    ...  /ant-monitoring/div/ant-monitoring-results-panels/section/div/n-site-type-recognize-ui/div/expansion-panel[1]/div[2]
    ${result}  Get Text  ${rtwp_result}
    Run keyword if  '${name_rtwp_lte}'=='RTWP LTE (Total 30 time intervals)'
    ...  Log  ${name_rtwp_lte}  console=true
    ...  ELSE IF  '${name_rtwp_lte}'=='RTWP LTE'
    ...  Log  ${result}  console=true
    ...  ELSE
    ...  Set test restriction  ${name_rtwp_lte} had to be -RTWP LTE (Total 30 time intervals) because the test lasts 5 minutes!
    ${rtwp_count}  Catenate  SEPARATOR=  //*[@id="main-view"]/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div
    ...  /ant-monitoring/div/ant-monitoring-results-panels/section/div/n-site-type-recognize-ui/div/expansion-panel[1]/
    ...  div[2]/div/ant-monitoring-results-table/section/div[2]/table/tbody/tr
    ${rtwp_values}  Selenium2Library.Get Element count  ${rtwp_count}
    ${RTWP_LTE_LIST}  Create list
    Set Test variable  ${RTWP_LTE_LIST}
    FOR  ${index}  IN RANGE  1  ${rtwp_values}+1
        ${rtwp_td}  Catenate  SEPARATOR=  //*[@id="main-view"]/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div
        ...  /ant-monitoring/div/ant-monitoring-results-panels/section/div/n-site-type-recognize-ui/div/expansion-panel[1]
        ...  /div[2]/div/ant-monitoring-results-table/section/div[2]/table/tbody/tr[${index}]/td
        ${rtwp_values_td}  Selenium2Library.Get Element count  ${rtwp_td}
        RTWP LTE table values  ${rtwp_values_td}  ${index}
        Append to list  ${RTWP_LTE_LIST}  @{RTWP_LTE_VALUES}
    END

Step5: Verify RTWP WCDMA
    Log  Step5: Verify RTWP WCDMA  console=true
    ${rtwp_wcdma_name}  Catenate  SEPARATOR=  //*[@id="main-view"]/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div
    ...  /ant-monitoring/div/ant-monitoring-results-panels/section/div/n-site-type-recognize-ui/div/expansion-panel[2]
    ...  /div[1]/span/span[1]/expansion-panel-header
    ${name_rtwp_wcdma}  Get Text  ${rtwp_wcdma_name}
    ${rtwp_result}  Catenate  SEPARATOR=  //*[@id="main-view"]/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div
    ...  /ant-monitoring/div/ant-monitoring-results-panels/section/div/n-site-type-recognize-ui/div/expansion-panel[2]/div[2]
    ${result}  Get Text  ${rtwp_result}
    Run keyword if  '${name_rtwp_wcdma}'=='RTWP WCDMA (Total 30 time intervals)'
    ...  Log  ${name_rtwp_wcdma}  console=true
    ...  ELSE IF  '${name_rtwp_wcdma}'=='RTWP WCDMA'
    ...  Log  ${result}  console=true
    ...  ELSE
    ...  Set test restriction  ${name_rtwp_wcdma} had to be -RTWP WCDMA (Total 30 time intervals) because the test lasts 5 minutes!
    ${rtwp_count}  Catenate  SEPARATOR=  //*[@id="main-view"]/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div
    ...  /ant-monitoring/div/ant-monitoring-results-panels/section/div/n-site-type-recognize-ui/div/expansion-panel[2]/
    ...  div[2]/div/ant-monitoring-results-table/section/div[2]/table/tbody/tr
    ${rtwp_values}  Selenium2Library.Get Element count  ${rtwp_count}
    ${RTWP_WCDMA_LIST}  Create list
    Set Test variable  ${RTWP_WCDMA_LIST}
    FOR  ${index}  IN RANGE  1  ${rtwp_values}+1
        ${rtwp_td}  Catenate  SEPARATOR=  //*[@id="main-view"]/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div
        ...  /ant-monitoring/div/ant-monitoring-results-panels/section/div/n-site-type-recognize-ui/div/expansion-panel[2]
        ...  /div[2]/div/ant-monitoring-results-table/section/div[2]/table/tbody/tr[${index}]/td
        ${rtwp_values_td}  Selenium2Library.Get Element count  ${rtwp_td}
        RTWP WCDMA table values  ${rtwp_values_td}  ${index}
        Append to list  ${RTWP_WCDMA_LIST}  @{RTWP_WCDMA_VALUES}
    END

Step6: Verify RSSI GSM
    Log  Step6: Verify RSSI GSM  console=true
    ${rssi_name}  Catenate  SEPARATOR=  //*[@id="main-view"]/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div
    ...  /ant-monitoring/div/ant-monitoring-results-panels/section/div/n-site-type-recognize-ui/div/expansion-panel[3]
    ...  /div[1]/span/span[1]/expansion-panel-header
    ${name_rssi_gsm}  Get Text  ${rssi_name}
    ${rssi_result}  Catenate  SEPARATOR=  //*[@id="main-view"]/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div
    ...  /ant-monitoring/div/ant-monitoring-results-panels/section/div/n-site-type-recognize-ui/div/expansion-panel[3]/div[2]
    ${result}  Get Text  ${rssi_result}
    Run keyword if  '${name_rssi_gsm}'=='RSSI GSM (Total 5 time intervals)'
    ...  Log  ${name_rssi_gsm}  console=true
    ...  ELSE IF  '${name_rssi_gsm}'=='RSSI GSM'
    ...  Log  ${result}  console=true
    ...  ELSE
    ...  Set test restriction  ${name_rssi_gsm} had to be -RSSI GSM (Total 5 time intervals)- because the test lasts 5 minutes!
    ${rssi_count}  Catenate  SEPARATOR=  //*[@id="main-view"]/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div
    ...  /ant-monitoring/div/ant-monitoring-results-panels/section/div/n-site-type-recognize-ui/div/expansion-panel[3]
    ...  /div[2]/div/ant-monitoring-results-table/section/div[2]/table/tbody/tr
    ${rssi_values}  Selenium2Library.Get Element count  ${rssi_count}
    ${RSSI_GSM_LIST}  Create list
    Set Test Variable  ${RSSI_GSM_LIST}
    FOR  ${index}  IN RANGE  1  ${rssi_values}+1
        ${rssi_td}  Catenate  SEPARATOR=  //*[@id="main-view"]/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div
        ...  /ant-monitoring/div/ant-monitoring-results-panels/section/div/n-site-type-recognize-ui/div/expansion-panel[3]
        ...  /div[2]/div/ant-monitoring-results-table/section/div[2]/table/tbody/tr[${index}]/td
        ${rssi_values_td}  Selenium2Library.Get Element count  ${rssi_td}
        RSSI GSM table values  ${rssi_values_td}  ${index}
        Append to list  ${RSSI_GSM_LIST}  @{RSSI_GSM_VALUES}
    END

Step7: Verify all values
    Log  Step7: Verify all values  console=true
    ${all_values_list}  Combine Lists  ${VSWR_VALUES_LIST}  ${RTWP_LTE_LIST}  ${RTWP_WCDMA_LIST}  ${RSSI_GSM_LIST}
    ${zero_values}  Count values in list   ${all_values_list}  0
    ${list_length}  Get Length  ${all_values_list}
    Run keyword if  ${zero_values}==${list_length}
    ...  Set Test Failed  All values are zero![NOK]
    ...  ELSE
    ...  Log  Not all values are zero![OK]  console=true

Step8: Export to CSV
    Log  Step8: Export to CSV  console=true
    ${export}  Catenate  SEPARATOR=  //*[@id="main-view"]/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div
    ...  /ant-monitoring/div/ant-monitoring-results-panels/section/header/ant-monitoring-export-button/ui-button/button
    ${status}  Run keyword and return status  Click Element  ${export}
    Run keyword if  ${status}
    ...  Log  Exporting to CSV has been performed successfully!  console=true
    ...  ELSE
    ...  Set Test Restriction  Export to CSV was not performed!

VSWR table values
    [Arguments]  ${vswr_values}  ${index}
    ${VSWR_LIST}  Create list
    Set test variable  ${VSWR_LIST}
    FOR  ${tr}  IN RANGE  1  ${vswr_values}+1
        ${vswr_value}  Catenate  SEPARATOR=  //*[@id="main-view"]/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div
        ...  /ant-monitoring/div/ant-monitoring-results-panels/section/div/expansion-panel/div[2]/div/
        ...  ant-monitoring-results-table/section/div[2]/table/tbody[${index}]/tr[${tr}]/td
        ${vswr_values_td}  Selenium2Library.Get Element count  ${vswr_value}
        Table values  ${vswr_values_td}  ${index}  ${tr}
        Append to list  ${VSWR_LIST}  @{VSWR_VALUES}
    END

Table values
    [Arguments]  ${vswr_values_td}  ${index}  ${tr}
    ${VSWR_VALUES}  Create List
    Set Test Variable  ${VSWR_VALUES}
    FOR  ${td}  IN RANGE  1  ${vswr_values_td}+1
         ${vswr_text}  Catenate  SEPARATOR=  //*[@id="main-view"]/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div
         ...  /ant-monitoring/div/ant-monitoring-results-panels/section/div/expansion-panel/div[2]/div/
         ...  ant-monitoring-results-table/section/div[2]/table/tbody[${index}]/tr[${tr}]/td[${td}]
         ${values}  Get Text  ${vswr_text}
         @{list_of_values}  Split String  ${values}  \n
         Append to list  ${VSWR_VALUES}  @{list_of_values}
    END

RTWP LTE table values
    [Arguments]  ${rtwp_values_td}  ${index}
    ${RTWP_LTE_VALUES}  Create List
    Set Test Variable  ${RTWP_LTE_VALUES}
    FOR  ${td}  IN RANGE  1  ${rtwp_values_td}+1
         ${rtwp_text}  Catenate  SEPARATOR=  //*[@id="main-view"]/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div
         ...  /ant-monitoring/div/ant-monitoring-results-panels/section/div/n-site-type-recognize-ui/div/expansion-panel[1]
         ...  /div[2]/div/ant-monitoring-results-table/section/div[2]/table/tbody/tr[${index}]/td[${td}]
         ${values}  Get Text  ${rtwp_text}
         @{list_of_values}  Split String  ${values}  \n
         Append to list  ${RTWP_LTE_VALUES}  @{list_of_values}
    END

RTWP WCDMA table values
    [Arguments]  ${rtwp_values_td}  ${index}
    ${RTWP_WCDMA_VALUES}  Create List
    Set Test Variable  ${RTWP_WCDMA_VALUES}
    FOR  ${td}  IN RANGE  1  ${rtwp_values_td}+1
         ${rtwp_values}  Catenate  SEPARATOR=  //*[@id="main-view"]/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div
         ...  /ant-monitoring/div/ant-monitoring-results-panels/section/div/n-site-type-recognize-ui/div/expansion-panel[2]
         ...  /div[2]/div/ant-monitoring-results-table/section/div[2]/table/tbody/tr[${index}]/td[${td}]
         ${values}  Get Text  ${rtwp_values}
         @{list_of_values}  Split String  ${values}  \n
         Append to list  ${RTWP_WCDMA_VALUES}  @{list_of_values}
    END

RSSI GSM table values
    [Arguments]  ${rssi_values_td}  ${index}
    ${RSSI_GSM_VALUES}  Create List
    Set Test Variable  ${RSSI_GSM_VALUES}
    FOR  ${td}  IN RANGE  1  ${rssi_values_td}+1
        ${rssi_table}  Catenate  SEPARATOR=  //*[@id="main-view"]/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div
        ...  /ant-monitoring/div/ant-monitoring-results-panels/section/div/n-site-type-recognize-ui/div/expansion-panel[3]
        ...  /div[2]/div/ant-monitoring-results-table/section/div[2]/table/tbody/tr[${index}]/td[${td}]
        ${values}  Get Text  ${rssi_table}
        @{list_of_values}  Split String  ${values}  \n
        Append to list  ${RSSI_GSM_VALUES}  @{list_of_values}
    END

TC Setup
    Common test setup
    WebEM Setup

TC Teardown
    WebEM Teardown
    Common test teardown

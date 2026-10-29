*** Settings ***
Documentation
    ...  This TC is created to activate mirroring interface.
    ...  The Diagnostic menu opens and the Mirroring -> Interface Mirroring is selected.
    ...  For interface value is choosen L1-L2.
    ...  For cells is selected "Select max 8 cells" and all NR cells are choosen.
    ...  For destination is choosen Local.
    ...  For mirroring time is the global variable, by default is 120s.
    ...  Verify if Start button is enabled and stop button is disabled.
    ...  Start action is performed.
    ...  Verify if text "Starting interface mirroring succeeded" appeard.
    ...  Verify if Start button is disabled and Stop button is enabled.
    ...  Sleep as many seconds as the global variable, in this case 120s.
    ...  Verify if Start button is enabled and stop button is disabled.
    ...  Logs are collected with Snapshot function and saved in BTS Files.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${MIRRORING_TIME}  120  # Time in seconds for mirroring
${COLLECTION_LOGS_TIMEOUT}  600  # Time for logs to be collecting successfully


*** Keywords ***
TC__WebEM__Navigation_Menu_Saving_BTS_Technical_Report_Mirroring
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-23295
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 16.06.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23295 - Initial TAT creation
    ...  - 21.07.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23404 - Adding verification on status
    ...  - 25.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24131 - Refactor TCs with best practice
    ...  - 22.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26453 - Wrong xpath for many objects
    ...  - 10.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26693 - Start message wrong on trunk

    Set Tags  CA-WebEM  OWNER-tatiana.bechet@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS22

    Step1: Open Interface Mirroring Tab
    Step2: Configuration Menu
    Step3: Starting Interface Mirroring
    Step4: Collect Logs By Snapshop Function


Step1: Open Interface Mirroring Tab
    Log  Step1: Open Interface Mirroring tab  console=true
    Open Interface Mirroring


Step2: Configuration Menu
    Log  Step2: Configuration menu  console=true
    Log  Complete interfaces...  console=true
    Wait Until Element Is Clicked  //*[contains(@class, 'interface-mirroring-form')]/div[2]/validation-dropdown-group/div/p-dropdown  60
    Click Element  //*[contains(text(), 'L1-L2')]
    Log  Interfaces completion was performed successfully.[OK]  console=true
    Log  Complete cells...  console=true
    Click Element  //*[contains(text(), 'Select max 8 cells')]
    Click Element  //*[contains(@class, 'interface-mirroring-form')]/div[3]/validation-cells-group/div/div/div/p-multiselect/div
    Sleep  5s  Time for dropdown to be visible
    ${nrcel_list}  Get Parameters For All  NRCEL
    FOR  ${nrcel}  IN  @{nrcel_list}
        Click Element  //*[contains(@aria-label, '${nrcel}[cellName]')]
    END
    Click Element  //*[contains(@class, 'interface-mirroring-form')]/div[3]/validation-cells-group/div/div/div/p-multiselect/div
    Log  Cells completion was performed successfully.[OK]  console=true
    Log  Complete destination...  console=true
    ${status}  Run Keyword And Return Status
    ...  Click Element  //*[contains(text(), 'Local')]
    Run Keyword If  ${status}
    ...  Log  Destination completion was performed successfully.[OK]  console=true
    ...  ELSE
    ...  Fail  Destination completion was not performed successfully.[NOK]
    Log  Complete mirroring time...  console=true
    ${status}  Run Keyword And Return Status
    ...  Input Text  //*[contains(@class, 'interface-mirroring-form')]/div[7]/validation-mirroring-time-group/div/div/input  ${MIRRORING_TIME}
    Run Keyword If  ${status}
    ...  Log  Mirroring time was completed successfully.[OK]  console=true
    ...  ELSE
    ...  Fail  Mirroring time was not completed successfully.[NOK]


Step3: Starting Interface Mirroring
    Log  Step3: Starting interface mirroring  console=true
    Log  Verify Start button to be enabled and Stop button to be disabled!  console=true
    ${status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  30  5
    ...  Element Should Be Enabled  //*[contains(@class, 'interface-mirroring-buttons')]/p-button[1]/button
    Run Keyword If  ${status}
    ...  Log  Start Button is enabled![OK]  console=true
    ...  ELSE
    ...  Fail  Start Button is not enabled![NOK]
    ${class}  SeleniumLibrary.Get Element Attribute  //*[contains(@class, 'interface-mirroring-buttons')]/p-button[2]/button  class
    ${status}  Run Keyword And Return Status  Should Contain  ${class}  disabled
    Run Keyword If  ${status}
    ...  Log  Stop Button is disabled![OK]  console=true
    ...  ELSE
    ...  Fail  Stop Button is not disabled![NOK]
    Log  Click Start button!  console=true
    Click Element  //*[contains(@class, 'interface-mirroring-buttons')]/p-button[1]/button
    Run Keyword If  '${ENB_BRANCH}' >= 'SBTS24R2'
    ...  Wait Until Keyword Succeeds  60  5
    ...  Element Should Be Visible  //*[contains(text(), 'Start interface mirroring succeeded')]
    ...  ELSE
    ...  Wait Until Keyword Succeeds  60  5
    ...  Element Should Be Visible  //*[contains(text(), 'Starting interface mirroring succeeded')]
    Log  Verify status to be Active!  console=true
    Wait Until Element Is Visible  //*[contains(@class, 'interface-mirroring-form')]/div[1]/div  60
    ${status_result}  Get Text  //*[contains(@class, 'interface-mirroring-form')]/div[1]/div
    Run Keyword If  '${status_result}'=='Active'
    ...  Log  Status "Active" appeard![OK]  console=true
    ...  ELSE
    ...  Fail  Status "Active" is not appeard![NOK]
    Log  Verify Start button to be disabled and Stop button to be enabled!  console=true
    ${class}  SeleniumLibrary.Get Element Attribute  //*[contains(@class, 'interface-mirroring-buttons')]/p-button[1]/button  class
    ${status}  Run Keyword And Return Status  Should Contain  ${class}  disabled
    Run Keyword If  ${status}
    ...  Log  Start Button is disabled![OK]  console=true
    ...  ELSE
    ...  Fail  Start Button is not disabled![NOK]
    ${status}  Run Keyword And Return Status
    ...  Element Should Be Enabled  //*[contains(@class, 'interface-mirroring-buttons')]/p-button[2]/button
    Run Keyword If  ${status}
    ...  Log  Stop Button is enabled![OK]  console=true
    ...  ELSE
    ...  Fail  Stop Button is not enabled![NOK]
    ${sleep_time}  Evaluate  ${MIRRORING_TIME}+10
    Log  Sleep for ${sleep_time}s!  console=true
    Sleep  ${sleep_time}s  This sleep is for wait until mirroring time is complete.
    Log  Verify status to be different than Active!  console=true
    Wait Until Element Is Visible  //*[contains(@class, 'interface-mirroring-form')]/div[1]/div  60
    ${status_result}  Get Text  //*[contains(@class, 'interface-mirroring-form')]/div[1]/div
    Run Keyword If  '${status_result}'=='Active'
    ...  Fail  Status "Active" is appeard![NOK]
    ...  ELSE
    ...  Log  Status "${status_result}" appeard![OK]  console=true
    Log  Verify Start button to be enabled and Stop button to be disabled!  console=true
    ${status}  Run Keyword And Return Status
    ...  Element Should Be Enabled  //*[contains(@class, 'interface-mirroring-buttons')]/p-button[1]/button
    Run Keyword If  ${status}
    ...  Log  Start Button is enabled![OK]  console=true
    ...  ELSE
    ...  Fail  Start Button is not enabled![NOK]
    ${class}  SeleniumLibrary.Get Element Attribute  //*[contains(@class, 'interface-mirroring-buttons')]/p-button[2]/button  class
    ${status}  Run Keyword And Return Status  Should Contain  ${class}  disabled
    Run Keyword If  ${status}
    ...  Log  Stop Button is disabled![OK]  console=true
    ...  ELSE
    ...  Fail  Stop Button is not disabled![NOK]


Step4: Collect Logs By Snapshop Function
    Log  Step4: Collect logs by Snapshop function  console=true
    Log  Open Snapshop menu!  console=true
    Open Snapshot Collection
    Log  Complete coverage with all log files...  console=true
    Click Element  xpath://*[contains(text(), "All log files")]
    Log  Coverage was completed successfully!  console=true
    Log  Complete save location with local...  console=true
    Click Element  xpath://*[contains(text(), "Local")]
    Log  Save location was completed successfully!  console=true
    Log  Input text "mirroring" in filter keyword!  console=true
    ${status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  120  5
    ...  Input Text  xpath=//*[contains(@name, 'keyword')]  mirroring
    Run Keyword If  ${status}
    ...  Log  Text "mirroring" it was written![OK]  console=true
    ...  ELSE
    ...  Fail  Text "mirroring" it wasn't written![NOK]
    Log  Verify Collect Snapshot button to be enabled!  console=true
    ${status}  Run Keyword And Return Status
    ...  Element Should Be Enabled  xpath=//*[contains(@a-text, 'Collect Snapshot')]
    Run Keyword If  ${status}
    ...  Log  Collect Snapshot Button is enabled![OK]  console=true
    ...  ELSE
    ...  Fail  Collect Snapshot Button is not enabled![NOK]
    ${bts_id}  Admin Get BTS Id
    ${sbts_name}  Get Text  ${SBTS_NAME_XPATH}
    Remove File  /home/ute/Downloads/Snapshot_MRBTS-${bts_id}_${sbts_name}_${ACTIVE_SW_VERSION}_*.zip
    Log  Collecting snapshot will be performed...  console=true
    Wait Until Element Is Clicked  //*[contains(@a-text, 'Collect Snapshot')]  60
    ${status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${COLLECTION_LOGS_TIMEOUT}  10
    ...  Element Should Be Visible  //*[contains(text(), 'Collection completed')]
    Run Keyword If  ${status}
    ...  Log  Text "Collection completed" appeard![OK]  console=true
    ...  ELSE
    ...  Fail  Text "Collection completed" is not appeard![NOK]
    ${current_time}  DateTime.Get Current Date  result_format=%Y.%m.%d-%H:%M  exclude_millis=true
    Wait Until Created  /home/ute/Downloads/Snapshot_MRBTS-${bts_id}_${sbts_name}_${ACTIVE_SW_VERSION}_*.zip
    Move File  /home/ute/Downloads/Snapshot_MRBTS-${bts_id}_${sbts_name}_${ACTIVE_SW_VERSION}_*.zip
    ...  ${BTS_FILES}/Snapshot_MRBTS-${bts_id}_${sbts_name}_${ACTIVE_SW_VERSION}_${current_time}.zip


TC Setup
    Common Test Setup
    WebEM Setup


TC Teardown
    WebEM Teardown
    Common Test Teardown

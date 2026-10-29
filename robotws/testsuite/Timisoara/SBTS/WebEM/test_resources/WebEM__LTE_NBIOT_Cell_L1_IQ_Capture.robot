*** Settings ***
Documentation
    ...  This TC is created to verify LI-IQ capture.
    ...  SCF with IoT cell will be uploaded.
    ...  Open Debug Tracing.
    ...  If SW release is 23R1:
    ...  Choosing ABIO with the specific IoT cell.
    ...  Choosing 3 index of NB-IoT carrier.
    ...  Apply configuration and wait until 'Configure succeeded' text is visible.
    ...  Restore initial configuration.
    ...  If SW release is greater than 23R1:
    ...  Choosing LTE IoT cells.
    ...  Choosing 3 index of NB-IoT carrier.
    ...  Apply configuration and wait until 'Configuring succeeded' text is visible.
    ...  Disabled IQ capture and wait until 'Disabling succeeded' text is visible.
    ...  Restore initial configuration.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${SCF_WITH_IOT}  SCF_IOT.xml  # SCF with LTE IoT cells
${RECOVERY_TIMEOUT}  1200  # Time for SBTS to be recover


*** Keywords ***
TC__WebEM__LTE_NBIOT_Cell_L1_IQ_Capture
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-23832
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 09.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23832 - Initial TAT creation
    ...  - 25.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24131 - Refactor TCs with best practice
    ...  - 15.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24316 - Refactor WebEM TCs and resources to use KWs from ca_SBTS_general
    ...  - 20.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24447 - Target Module is removed due to CNI-85021
    ...  - 14.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26089 - Improving TC to match CB010508-SR
    ...  - 10.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26691 - Improving to match the debug tracing menu changes
    ...  - 21.02.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28791 - Delete Sherpa using

    Set Tags  CA-WebEM  OWNER-tatiana.bechet@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS23

    Step1: Changing Configuration With IoT Cell
    Step2: Open Debug Tracing View
    Step3: Verify L1-IQ Capture And Restore Initial Configuration


Step1: Changing Configuration With IoT Cell
    Log  Step1: Changing configuration with IoT cell  console=true
    ${config_path}  Fetch From Left  ${COMMISSIONING_PATH}  BTS
    ${scf_with_io_t_path}  Set Variable  ${config_path}${SCF_WITH_IOT}
    ${commissioning_status}  Run Keyword And Return Status
    ...  coam.Perform Commissioning  bts_id=${BTS_ID}
    ...  scf_file=${scf_with_io_t_path}
    ...  skip_parameter_relation_errors=${TRUE}
    ...  should_activate=${TRUE}
    ...  timeout=1200
    Run Keyword If  ${commissioning_status}
    ...  Log  Loading Scf with Iot cell is performed.[OK]  console=true
    ...  ELSE
    ...  Fail  Loading Scf with IoT cell is failed.[NOK]
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  5
    ...  Close BTS Start-up View
    ${cells_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check All Cells
    Run Keyword If  ${cells_status}
    ...  Log  All cells are onAir![OK]  console=true
    ...  ELSE
    ...  Fail  Not all cells are onAir![NOK]


Step2: Open Debug Tracing View
    Log  Step2: Open Debug Tracing View  console=true
    Open Diagnostic Menu
    Click Element  //*[contains(text(), "Debug Tracing")]
    Log  Debug Tracing is open!  console=true
    Wait Until Element Is Visible  //*[contains(text(), "Activate internal trace")]  60
    ${status}  Run Keyword And Return Status
    ...  Element Should Be Enabled  //*[contains(@class, 'debug-tracing-container')]/execution-bar/div/ui-button[1]/button
    Run Keyword If  ${status}
    ...  Activate Internal Trace
    ...  ELSE
    ...  Log  Internal trace is already activated!  console=true


Step3: Verify L1-IQ Capture And Restore Initial Configuration
    Log  Step3: Verify L1-IQ capture and Restore initial configuration  console=true
    ${lte_iot_cells}  Get IoT Cells From LTE Tehnology
    Set Test Variable  ${LTE_IOT_CELLS}
    ${l1_iq_capture}  Catenate  SEPARATOR=  //*[contains(@class, 'debug-tracing-container')]/div[2]
    ...  /section/div/expansion-panel[2]/div[2]/div/u-plane-component/section/div/div/div[2]/ul/li[2]
    Wait Until Element Is Visible  ${l1_iq_capture}  60
    Click Element  ${l1_iq_capture}
    Log  Open L1-IQ capture is performed!  console=true
    Run Keyword If  '${ENB_BRANCH}'=='SBTS23R1'
    ...  Choose Parameters And Apply Configuration With Target Module
    ...  ELSE
    ...  Choose Parameters And Apply Configuration Without Target Module
    Restore Initial Configuration


Choose Parameters And Apply Configuration Without Target Module
    FOR  ${cell}  IN  @{LTE_IOT_CELLS}
        ${iot_cell_id}  Fetch From Right  ${cell}  R-
        Log  Choose ${iot_cell_id} IoT cell from LTE UL cell IDs!  console=true
        ${cells_button}  Catenate  SEPARATOR=  //*[contains(@class, 'debug-tracing-container')]/
        ...  div[2]/section/div/expansion-panel[2]/div[2]/div/u-plane-component/section/div/tracing-cells-content/div/l1-iq-capture
        ...  /div/div/div/div[2]/div[5]/div[1]/div[2]/div/ui-multiselect
        Wait Until Element Is Clicked  ${cells_button}  120
        Wait Until Element Is Clicked  //*[contains(@data-value, '${iot_cell_id}')]  120
        Wait Until Element Is Clicked  ${cells_button}  120
        ${carrier}  Catenate  SEPARATOR=  xpath=//*[contains(@class, 'debug-setup-control sub-id-table')]/ui-table/div/ng-transclude/table/tbody/
        ...  tr[2]/td[2]/div/ui-select/div/wf-dropdown/div/button
        Wait Until Element Is Clicked  ${carrier}  120
        Log  Choosing 3 index of NB-IoT carrier!  console=true
        ${index}  Catenate  SEPARATOR=  //*[contains(@class, 'debug-tracing-container')]/div[2]/section/div/expansion-panel[2]
        ...  /div[2]/div/u-plane-component/section/div/tracing-cells-content/div/l1-iq-capture/div/div/div
        ...  /div[2]/ng-container/div/ui-table/div/ng-transclude/table/tbody/tr[2]/td[2]/div/ui-select/div/wf-dropdown/div/ul/wf-dropdown-item[4]/li
        Wait Until Element Is Clicked  ${index}  120
        Run Keyword If  '${ENB_BRANCH}' >= 'SBTS24R2'
        ...  Apply Configuration  //*[contains(@class, 'test-setup-control-fourth-container apply-config')]/ui-button[1]/button  Configure succeeded
        ...  ELSE
        ...  Apply Configuration  //*[contains(@class, 'test-setup-control-fourth-container apply-config')]/ui-button[1]/button
        ...  Configuring succeeded
        Disabled IQ Capture
    END


Choose Parameters And Apply Configuration With Target Module
    ${button}  Catenate  SEPARATOR=  //*[contains(@class, 'debug-tracing-container')]/div[2]
    ...  /section/div/expansion-panel[2]/div[2]/div/u-plane-component/section/div/tracing-cells-content/div/l1-iq-capture/div/div/div/div[1]/
    ...  div[2]/div/ui-select/div
    Click Element  ${button}
    ${bbmods_nr}  Catenate  SEPARATOR=  //*[contains(@class, 'debug-tracing-container')]
    ...  /div[2]/section/div/expansion-panel[2]/div[2]/div/u-plane-component/section/div/tracing-cells-content/div/l1-iq-capture/div/div/div/div[1]/
    ...  div[2]/div/ui-select/div/wf-dropdown/div/ul/wf-dropdown-item
    ${number_of_bbmods}  SeleniumLibrary.Get Element Count  ${bbmods_nr}
    FOR  ${index}  IN RANGE  1  ${number_of_bbmods}+1
        ${bbmods_text}  Catenate  SEPARATOR=  //*[contains(@class, 'debug-tracing-container')]/
        ...  div[2]/section/div/expansion-panel[2]/div[2]/div/u-plane-component/section/div/tracing-cells-content/div/l1-iq-capture/div/div/div/
        ...  div[1]/div[2]/div/ui-select/div/wf-dropdown/div/ul/wf-dropdown-item[${index}]/li
        ${bbmod_name}  Get Text  ${bbmods_text}
        ${status_bbmod_name}  Run Keyword And Return Status
        ...  Should Match Regexp  ${bbmod_name}  .*(ABIO)
        Run Keyword If  ${status_bbmod_name}
        ...  Run Keywords
        ...  Click Element  //*[contains(text(), "${bbmod_name}")]
        ...  AND
        ...  Log  BBMOD ${bbmod_name} is chosen![OK]  console=true
    END
    FOR  ${cell}  IN  @{LTE_IOT_CELLS}
        ${iot_cell_id}  Fetch From Right  ${cell}  R-
        Log  Input ${iot_cell_id} IoT cell in LTE UL cell IDs!  console=true
        ${text}  Catenate  SEPARATOR=  //*[contains(@class, 'debug-tracing-container')]/
        ...  div[2]/section/div/expansion-panel[2]/div[2]/div/u-plane-component/section/div/tracing-cells-content/div/l1-iq-capture/div/div/div/
        ...  div[3]/ng-container/div[1]/div[2]/div[1]/div[1]/ui-text-input/div/input
        Input Text  ${text}  ${iot_cell_id}
        ${dropdown}  Catenate  SEPARATOR=  //*[contains(@class, 'debug-setup-control sub-id-table')]/ui-table/div/ng-transclude/table/tbody/tr[2]
        ...  /td[2]/div/ui-select/div/wf-dropdown
        Click Element  ${dropdown}
        Log  Choosing 3 index of NB-IoT carrier!  console=true
        ${carrier}  Catenate  SEPARATOR=  xpath=//*[contains(@class, 'debug-setup-control sub-id-table')]/ui-table/div/ng-transclude/table/tbody/
        ...  tr[2]/td[2]/div/ui-select/div/wf-dropdown/div/ul/wf-dropdown-item[4]/li
        Click Element  ${carrier}
        Click Element  //*[@class="checkbox-value ng-binding"]
        Apply Configuration  //*[contains(@a-text, 'Apply configuration')]  Configure succeeded
    END


Apply Configuration
    [Arguments]  ${xpath_for_apply_button}  ${text}

    Wait Until Element Is Visible  ${xpath_for_apply_button}  60
    ${status_apply}  Run Keyword And Return Status
    ...  Click Element  ${xpath_for_apply_button}
    Run Keyword If  ${status_apply}
    ...  Log  'Apply configuration' button is pushed![OK]  console=true
    ...  ELSE
    ...  Fail  'Apply configuration' button is not pushed![NOK]
    Log  Wait for configure to be succeeded!  console=true
    ${status_configured}  Run Keyword And Return Status
    ...  Wait Until Element Is Visible  //*[contains(text(), "${text}")]  600
    Run Keyword If  ${status_configured}
    ...  Log  '${text}' text is visible![OK]  console=true
    ...  ELSE
    ...  Fail  '${text}' text is not visible after 600s![NOK]


Disabled IQ Capture
    Wait Until Element Is Visible  //*[contains(@a-text, 'Disable IQ Capture')]  60
    ${status_capture}  Run Keyword And Return Status
    ...  Click Element  //*[contains(@a-text, 'Disable IQ Capture')]
    Run Keyword If  ${status_capture}
    ...  Log  'Disable IQ Capture' button is pushed![OK]  console=true
    ...  ELSE
    ...  Fail  'Disable IQ Capture' button is not pushed![NOK]
    Log  Wait for configure to be disabled!  console=true
    Run Keyword If  '${ENB_BRANCH}' >= 'SBTS24R2'
    ...  Wait Until Element Is Visible  //*[contains(text(), "Disable succeeded")]  600
    ...  ELSE
    ...  Wait Until Element Is Visible  //*[contains(text(), "Disabling succeeded")]  600
    Log  Configure is disabled!  console=true


Get IoT Cells From LTE Tehnology
    ${lncel}  coam.Get Parameters For All  LNCEL
    ${iot_cell}  Evaluate  [cell['nbIoTCell']['distName'] for cell in ${lncel} if cell['nbIoTCell']]

    [Return]  ${iot_cell}


Restore Initial Configuration
    Log  Restore initial configuration  console=true
    Wait Until Keyword Succeeds  120  5
    ...  Go To Site View
    coam.Perform Commissioning  bts_id=${BTS_ID}  scf_file=${COMMISSIONING_PATH}  skip_parameter_relation_errors=${TRUE}  should_activate=${TRUE}
    ...  timeout=600
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  5
    ...  Close BTS Start-up View
    ${cells_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check All Cells
    Run Keyword If  ${cells_status}
    ...  Log  All cells are onAir![OK]  console=true
    ...  ELSE
    ...  Fail  Not all cells are onAir![NOK]


TC Setup
    Common Test Setup  tc_name=WebEM__LTE_NBIOT_Cell_L1_IQ_Capture
    WebEM Setup


TC Teardown
    Run Keyword If Test Failed
    ...  Restore Initial Configuration
    WebEM Teardown
    Common Test Teardown

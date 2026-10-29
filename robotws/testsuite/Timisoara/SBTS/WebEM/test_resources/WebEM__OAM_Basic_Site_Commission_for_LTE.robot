*** Settings ***
Documentation
    ...  This TC must be execute on SBTS with LTE configuration.
    ...  Check if product variant planned is sBTS.
    ...  Open KPI Dashboard and verify if groupByObject and groupByName is visible.
    ...  Click on LNBTS object and verify if page contains Description.
    ...  Open RF Diagnostic Tab on Test Suite.
    ...  Activate Remote RF Diagnostic, choose LTE technology and select All LTE cells.
    ...  Start BTS Test and check if for all cells the results are Pass.
    ...  Save all Test Results and move them into test folder.
    ...  Clear all results from WebEM.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Keywords ***
TC__WebEM__OAM_Basic_Site_Commission_for_LTE
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-24052
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 17.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24052 - Initial TAT creation
    ...  - 25.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24131 - Refactor TCs with best practice
    ...  - 13.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24305 - Wrong Xpath in Activate Remote RF
    ...  - 29.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25591 - Parameter actRemoteRfDiag removed from NIDD after release 23R4

    Set Tags  CA-WebEM  OWNER-cristina.antoci@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS23

    Step1: Check ProductVariantPlanned
    Step2: Check KPI Dashboard And RF Diagnostic Tab
    Step3: Start BTS Test And Check Test Results
    Step4: Save Test Results And Clear Them From WebEM


Step1: Check ProductVariantPlanned
    Log  Step1: Check ProductVariantPlanned  console=true
    ${lte_xpath}  Get Xpath List For Cells  LTE
    ${lte_cells}  Create List
    FOR  ${cell}  IN  @{lte_xpath}
        Click Element  ${cell}
        ${cell_text}  Catenate  SEPARATOR=  //*[contains(@class, 'details-panel-content')]/div/hardware-details/div/
        ...  div/div[1]/div/div/div[2]/div[1]/div
        ${cell_name}  Get Text  ${cell_text}
        Append To List  ${lte_cells}  ${cell_name}
    END
    Set Test Variable  ${LTE_CELLS}
    Wait Until Element Is Visible  ${COMMISIONING_WIZARD}  timeout=20
    Click Element  ${COMMISIONING_WIZARD}
    Wait Until Element Is Visible  locator=//a[contains(text(),'Steps')]  timeout=20
    Click Element  locator=//a[contains(text(),'Steps')]
    Wait Until Element Is Visible  locator=//span[contains(text(),'General BTS/Site Settings')]  timeout=20
    Click Element  locator=//span[contains(text(),'General BTS/Site Settings')]
    Wait Until Page Contains  Product variant planned:
    ${status}  Run Keyword And Return Status
    ...  Wait Until Page Contains  sBTS
    Run Keyword If  ${status}
    ...  Log  Product variant is sBTS![OK]  console=true
    ...  ELSE
    ...  Fail  Product variant is not sBTS![NOK]
    Click Element  locator=//button[contains(text(),' Done')]


Step2: Check KPI Dashboard And RF Diagnostic Tab
    Log  Step2: Check KPI Dashboard and RF Diagnostic Tab  console=true
    Open KPI Dashboard Tab
    Wait Until Page Contains  groupByObject
    Log  groupByObject is visible!  console=true
    Wait Until Page Contains  groupByName
    Log  groupByName is visible!  console=true
    Wait Until Element Is Clicked  //div[contains(text(),'LNBTS_R-1')]  180
    Click Element  //*[contains(@class, 'details-panel-container')]/ui-button/button/i
    Wait Until Page Contains  Description
    Open Diagnostic Menu
    Wait Until Element Is Clicked  ${RF_DIAGNOSTIC_TEST}
    Wait Until Element Is Clicked  ${TEST_SETUP}
    Log  RF Diagnostic Test is open in Test Setup!  console=true
    Click Element  //*[@id="lte-aria"]
    Log  LTE technology is choosen!  console=true


Step3: Start BTS Test And Check Test Results
    Log  Step3: Start BTS Test and check Test Results  console=true
    ${dropdown_list}  Get WebElement  //button[@class="btn btn-default dropdown-toggle"]
    Click Button  ${dropdown_list}
    Select All Cells OnAir
    Click Element  locator=//ui-button[@a-text="Start RF Diagnostic Test"]
    Log  Start RF Diagnostic Test button is pushed!  console=true
    Check BTS Test Results


Step4: Save Test Results And Clear Them From WebEM
    Log  Step4: Save Test Results and clear them from WebEM  console=true
    ${bts_id}  Admin Get BTS Id
    Remove File  RFDiagnosticTest_*.txt
    ${status}  Run Keyword And Return Status
    ...  Click Element  xpath=//*[contains(@a-text, 'Save All Results')]
    Sleep  30s
    Run Keyword If  ${status}
    ...  Log  Saving all results has been performed successfully!  console=true
    ...  ELSE
    ...  Fail  Save all results action was not performed!
    Move File  /home/ute/Downloads/RFDiagnosticTest_*.txt  ${BTS_FILES}/RFDiagnosticTest_SBTS-${bts_id}.txt
    Log  Clear finished results  console=true
    Click Element  locator=//ui-button[@a-text="Clear Finished Results"]
    Wait Until Element Is Visible  locator=//span[contains(text(),'Deleting result completed.')]  timeout=150
    Log  Text 'Deleting result completed' is visible on SBTS  console=true


Select All Cells OnAir
    Log  Select all LTE cells for starting the test  console=true
    ${all_lte_cells}  Get WebElement  //li[@data-value="All LTE cells"]
    Wait Until Element Is Visible  locator=${all_lte_cells}  timeout=10
    Click Element  locator=${all_lte_cells}


Check BTS Test Results
    ${text}  Catenate  SEPARATOR=  //span[contains(text(),'Test completed, please check detailed result on corresponding result page.')]
    Wait Until Element Is Visible  locator=${text}  timeout=150
    Log  Test completed, please check detailed result on corresponding result page, is visible!  console=true
    Wait Until Element Is Visible  //li[@heading="RF Diagnostic Test Results"]  30
    Click Element  //li[@heading="RF Diagnostic Test Results"]
    Capture Page Screenshot  filename=bts_results_values.png
    FOR  ${cell}  IN  @{LTE_CELLS}
        Click Element  //*[contains(text(),'${cell}')]
        Wait Until Page Contains Element  //td[contains(text(),'Pass')]  10
        Log  For cell ${cell}, the test is Pass!  console=true
    END
    ${query_text}  Catenate  SEPARATOR=  /MRBTS-1/RAT-1/RUNTIME_VIEW-*/MRBTS_R-*/MNL_CONF_M-1/MNLENT_CONF_M-1/
    ...  TEST_CONF_M-1/RFREQ_CONF_M-1/RFRES_R-* is [testOutcome="Inconclusive",rvrsTestDisp="Pass"]
    Query Infomodel  query=${query_text}  timeout=60


TC Setup
    Common Test Setup
    WebEM Setup


TC Teardown
    WebEM Teardown
    Common Test Teardown

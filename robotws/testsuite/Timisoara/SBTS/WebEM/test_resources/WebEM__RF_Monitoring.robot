*** Settings ***
Documentation
    ...  This TC is created to performed RF Monitoring.
    ...  Flag actRfiTesting will be activated.
    ...  Start RF Monitoring via RF Scan.
    ...  The file is saving in BTSFile.
    ...  Flag actPimTesting will be activated.
    ...  Reset to test dedicated state.
    ...  Start RF PIM_Desensitization Monitoring
    ...  The file is saving in BTSFile.
    ...  Reset SBTS and verify all cells to be enabled.
    ...  Deactivate actRfiTesting and actPimTesting flags.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${RECOVERY_TIMEOUT}  1200  # Time for SBTS to recover.


*** Keywords ***
TC__WebEM__RF_Monitoring
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-24309
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 19.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24309 - Initial TAT creation
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Add watchdog alarm monitoring

    Set Tags  CA-WebEM  OWNER-cristina.antoci@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS23

    Step1: Change Flag actRfiTesting To Be true
    Step2: Start RF Scan Monitoring
    Step3: Change Flag actPimTesting To Be true
    Step4: Start RF PIM Desensitization Monitoring
    Step5: Change Flag actRfiTesting To Be false
    Step6: Change Flag actPimTesting To Be false


Step${index}: Change Flag ${parameter} To Be ${value}
    Log  \nStep${index}: Change flag ${parameter} to be ${value}  console=true
    ${status}  Run Keyword And Return Status
    ...  Perform Parameter Recommissioning  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...  ${parameter}
    ...  update
    ...  ${value}
    ...  skip_parameter_relation_errors=true
    Run Keyword If  ${status}
    ...  Log  Parameter ${parameter} is set to ${value}![OK]  console=true
    ...  ELSE
    ...  Fail  Parameter ${parameter} is not set to ${value}![NOK]


Step2: Start RF Scan Monitoring
    Log  \nStep2: Start RF Scan Monitoring  console=true
    Open RF Scan Monitoring
    Close Startup View If Visible
    Log  Set parameters for RF Scan!  console=true
    Click Element  locator=//td[@class='radios']//button[@class='btn btn-default dropdown-toggle']
    Click Element  locator=//*[contains(text(),'RMOD-1 (FXDB)')]
    Click Element  locator=//table[@class="antenna-to-be-scanned-table ng-scope"]//tbody//tr//td[2]
    Click Element  locator=//*[contains(text(),'Composite Rx (HBF0)')]
    Click Element  locator=//table[@class="antenna-to-be-scanned-table ng-scope"]//tbody//tr//td[3]
    Click Element  locator=//*[contains(text(),'All Antennas')]
    Log  Start RF Scan!  console=true
    Click Element  locator=//button[contains(text(),'Start')]
    Log  Testing and downloading files from BTS...  console=true
    Wait Until Element Is Visible  locator=//*[contains(text(),'Testing and downloading files from BTS...')]  timeout=600
    Wait Until Element Is Visible  locator=//*[contains(text(),'Download completed and file saved')]  timeout=600
    Log  Download completed and file saved!  console=true
    Sleep  60s
    Log  Move the file in BTSFiles!  console=true
    Move File  /home/ute/Downloads/RFMonitoring_SBTS-${BTS_ID}_rf-scan_*.zip  ${BTS_FILES}/RFMonitoring_SBTS-${BTS_ID}_rf-scan.zip


Step4: Start RF PIM Desensitization Monitoring
    Log  \nStep4: Start RF PIM Desensitization Monitoring  console=true
    Log  Reset to Test Dedicated state is performed!  console=true
    Reset To Test Dedicated  connection=default
    Query Infomodel  query=/MRBTS-1/RAT-1/MCTRL-1/BBTOP_M-1/MRBTS_M-1 is [stateInfo.testingState=Enabled]  timeout=500
    Log  testingState is Enabled!  console=true
    Sleep  30s
    Close Startup View If Visible
    Reload Page
    Sleep  60s
    Check Private Connection
    ${status}  Run Keyword And Return Status
    ...  Check If Bts Is Disconnected
    Run Keyword If  ${status}
    ...  Connect BTS
    Open PIM Desensitization Monitoring
    Close Startup View If Visible
    Log  Set parameters for PIM Desensitization!  console=true
    Click Element  locator=//wf-dropdown[@class="ng-isolate-scope"]
    Click Element  locator=//*[contains(text(),'RMOD-1 (FXDB) ANT 1')]
    Log  Start PIM Desensitization Monitoring!  console=true
    Click Element  locator=//button[contains(text(),'Start')]
    Log  Testing and downloading files from BTS...  console=true
    Wait Until Element Is Visible  locator=//*[contains(text(),'Testing and downloading files from BTS...')]  timeout=600
    Wait Until Element Is Visible  locator=//*[contains(text(),'Download completed and file saved')]  timeout=600
    Log  Download completed and file saved!  console=true
    Sleep  60s
    Log  Move the file in BTSFiles!  console=true
    Move File  /home/ute/Downloads/RFMonitoring_SBTS-${BTS_ID}_pim_*.zip  ${BTS_FILES}/RFMonitoring_SBTS-${BTS_ID}_pim.zip
    Log  Reset Site will be performed!  console=true
    coam.Reset Site
    ${cells_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check All Cells
    Run Keyword If  ${cells_status}
    ...  Log  All cells are onAir![OK]  console=true
    ...  ELSE
    ...  Fail  Not all cells are onAir![NOK]


TC Setup
    Common Test Setup  tc_name=WebEM__RF_Monitoring
    WebEM Setup


TC Teardown
    WebEM Teardown
    Common Test Teardown

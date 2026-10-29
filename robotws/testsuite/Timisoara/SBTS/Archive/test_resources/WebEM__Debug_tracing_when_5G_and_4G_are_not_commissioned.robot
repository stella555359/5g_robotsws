*** Settings ***
Resource    ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${RECOVERY_TIMEOUT}     600            #Time for SBTS to recovery.
${SCF_WITHOUT_5G_4G}    SCF_WG.xml     #Mandatory(SCF without 5G and 4G)


*** Keywords ***
TC__WebEM__Debug_tracing_when_5G_and_4G_are_not_commissioned
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-21607
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This TC verify debug tracing menu when 5G and 4G are not commissioned.
    ...  Verify if 5G and 4G are commissioned.
    ...  Open Debug Tracing.
    ...  Verify if Debug Tracing view is visible.
    ...  SCF without 5G and 4G will be uploaded.
    ...  Open Debug Tracing.
    ...  Verify if Debug Tracing view is not visible.
    ...  Verify if the message "Unavailable because NRBTS and LNBTS are not commissioned" appeared.
    ...  Initial SCF will be uploaded.
    ...  Verify if all cells are Enabled.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 19.07.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-21607 - Initial TAT creation
    ...  - 25.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24131 - Refactor TCs with best practice
    ...  - 15.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24316 - Refactor WebEM TCs and resources to use KWs from ca_SBTS_general
    ...  - 12.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26909 - SCF location is changed 

    Set Tags    CA-WebEM    OWNER-cristina.antoci@nokia.com    AUTHOR-andreea.burtic@nokia.com
    ...    MAINTAINER-andreea.burtic@nokia.com    GROUP_IN_CHARGE-TIM_3_Vrf    PHASE-CRT    SW-SBTS22

    Step1: Verify Debug Tracing View when 5G and 4G are commissioned
    Step2: Changing configuration without 5G and 4G
    Step3: Verify Debug Tracing View when 5G and 4G are not commissioned
    Step4: Restore 5G and 4G RATs and verify cells on SBTS


Step1: Verify Debug Tracing View when 5G and 4G are commissioned
    Log  Step1: Verify Debug Tracing View when 5G and 4G are commissioned  console=true
    Run keyword if  ${SCF_COUNT_NR} and ${SCF_COUNT_LTE}
    ...  Log  NR and LTE cells exist!  console=true
    ...  ELSE
    ...  Fail  NR or LTE cells does not exist!
    ${BTS_ID}  Admin Get BTS Id
    Set test variable  ${BTS_ID}
    Log  Open Debug tracing!  console=true
    Wait Until Keyword Succeeds  120  5  Click Element  //span[@ui-tooltip='Diagnostic']
    Click Element  //*[contains(text(), "Debug Tracing")]
    ${status}  Run keyword and return status  Wait Until Element is Visible  //*[contains(text(), "Activate internal trace")]  60
    Run keyword if  ${status}
    ...  Log  Debug Tracing View is visible![OK]  console=true
    ...  ELSE
    ...  Fail  Debug Tracing View is not visible when 5G and 4G are comissioned![NOK]  console=true
    Wait Until Keyword Succeeds  120  5  Go To Site View

Step2: Changing configuration without 5G and 4G
    Log  Step2: Changing configuration without 5G and 4G  console=true
    ${config_path}  Fetch from left  ${COMMISSIONING_PATH}  BTS
    ${SCF_without_5G_4G_path}  Set variable  ${config_path}${SCF_WITHOUT_5G_4G}
    ${commissioning_status}  Run Keyword and Return Status  coam.Perform commissioning  bts_id=${BTS_ID}
    ...  scf_file=${SCF_without_5G_4G_path}  skip_parameter_relation_errors=${True}  should_activate=${True}  timeout=600
    Run keyword if  ${commissioning_status}
    ...  Log  Loading Scf without 5G and 4G is performed.[OK]  console=true
    ...  ELSE
    ...  Fail  Loading Scf without 5G and 4G is failed.[NOK]
    Wait until keyword succeeds  ${RECOVERY_TIMEOUT}  5  Close BTS Start-up View
    ${status}  Run keyword and return status  Wait until keyword succeeds  ${RECOVERY_TIMEOUT}  10  Check WCDMA and GSM cells   ${Enabled_}
    Run keyword if  ${status}
    ...  Log  SBTS is OnAir![OK]  console=true
    ...  ELSE
    ...  Fail  Not all cells are Enabled![NOK]
    Log  Check if 5G and 4G are still commissioned on SBTS...  console=true
    ${status_NR}  Run keyword and return status  Element Should Not Be Visible  //*[contains(text(), "NR cells")]
    ${status_LTE}  Run keyword and return status  Element Should Not Be Visible  //*[contains(text(), "LTE cells")]
    Run keyword if  ${status_NR} and ${status_LTE}
    ...  Log  NR and LTE are not commissioned![OK]  console=true
    ...  ELSE
    ...  Fail  NR and LTE are still commissioned![NOK]  console=true

Step3: Verify Debug Tracing View when 5G and 4G are not commissioned
    Log  Step3: Verify Debug Tracing View when 5G and 4G are not commissioned  console=true
    Log  Open Debug Tracing!  console=true
    Wait Until Keyword Succeeds  120  5  Click Element  //span[@ui-tooltip='Diagnostic']
    Click Element  //*[contains(text(), "Debug Tracing")]
    Sleep  5s
    ${status}  Run keyword and return status  Wait Until Element is Visible
    ...  //*[contains(text(), "Unavailable because NRBTS and LNBTS are not commissioned")]  60
    Run keyword if  ${status}
    ...  Log  Text "Unavailable because NRBTS and LNBTS are not commissioned" appeared![OK]  console=true
    ...  ELSE
    ...  Fail  Text "Unavailable because NRBTS and LNBTS are not commissioned" is not appeared![NOK]  console=true
    Wait Until Keyword Succeeds  120  5  Go To Site View

Step4: Restore 5G and 4G RATs and verify cells on SBTS
    Log  Step4: Restore 5G and 4G RATs and verify cells on SBTS  console=true
    coam.Perform commissioning  bts_id=${BTS_ID}  scf_file=${COMMISSIONING_PATH}  skip_parameter_relation_errors=${True}
    ...  should_activate=${True}  timeout=600
    Wait until keyword succeeds  ${RECOVERY_TIMEOUT}  5  Close BTS Start-up View
    ${cells_status}  Run keyword and return status  Wait until keyword succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check All Cells  ${OnAirDone_}  ${Enabled_}  ${Active_}
    Run keyword if  ${cells_status}
    ...  Log  All cells are onAir![OK]  console=true
    ...  ELSE
    ...  Fail  Not all cells are onAir![NOK]

Check WCDMA and GSM cells
    [Arguments]   ${operationalState}
    Run Keyword If  ${SCF_COUNT_WCDMA}
    ...  Assert Every    WNCEL    operationalState=${operationalState}  timeout=60
    Run Keyword If  ${SCF_COUNT_GSM}
    ...  Assert Every    GNCEL    operationalState=${operationalState}  timeout=60


TC Setup
    Common test setup
    WebEM Setup

TC Teardown
    Run Keyword If Test Failed  Step4: Restore 5G and 4G RATs and verify cells on SBTS
    WebEM Teardown
    Common test teardown

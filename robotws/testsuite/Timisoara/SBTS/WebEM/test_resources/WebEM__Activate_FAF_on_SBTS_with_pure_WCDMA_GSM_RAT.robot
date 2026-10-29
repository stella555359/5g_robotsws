*** Settings ***
Documentation
    ...  This test case is created to check that there are no values set for the parameters antiTheftProtection.mcc, antiTheftProtection.mnc.
    ...  BTS is operational with WCDMA and GSM.
    ...  Initial parameter MNL/MNLENT/FEATCADM.actAntiTheftProtectionSystem is 'Disabled'.
    ...  Go to Configuration->Parameter Editor, set MNL/MNLENT/FEATCADM.actAntiTheftProtectionSystem to 'MCC and MNC', validate plan.
    ...  Relation error will be reported to indicate that FAF is supported to be enabled on pure WCDMA or GSM BTS.
    ...  Plan activated with MNL/MNLENT/FEATCADM.actAntiTheftProtectionSystem to 'MCC and MNC' and BTS is operational without units marked.
    ...  Can be read from runtime parameters under EQM_R/APEQM_R/CABINET_R/SMOD_R and EQM_R/APEQM_R/CABINET_R/BBMOD_R:
    ...  antiTheftProtection.mcc, antiTheftProtection.mnc. There would be no values set for the parameters.
    ...  Set MNL/MNLENT/FEATCADM.actAntiTheftProtectionSystem to 'disabled'.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Keywords ***
TC__WebEM__Activate_FAF_on_SBTS_with_pure_WCDMA_GSM_RAT
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-28013
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 25.09.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28013 - Initial TAT creation

    Set Tags  CA-WebEM  OWNER-cristina.antoci@nokia.com  AUTHOR-cristina.adam@nokia.com  MAINTAINER-cristina.adam@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS24  FEATURE-CB012788

    Step0: Set Preconditions
    Step1: Change ActAntiTheftProtectionSystem And Validate Plan
    Step2: Verify Permissions For ActAntiTheftProtectionSystem Parameter
    Step3: Change ActAntiTheftProtectionSystem Parameter With Initial Value


Step0: Set Preconditions
    Log  \nStep0: Set Preconditions  console=true
    Run Keyword If  ${SCF_COUNT_WCDMA} and ${SCF_COUNT_GSM}
    ...  Log  WCDMA and GSM cells exist, test will be continue!  console=true
    ...  ELSE
    ...  Fail  WCDMA or GSM cells does not exist, test case should be performed on a platform with WCDMA and GSM!


Step1: Change ActAntiTheftProtectionSystem And Validate Plan
    Log  \nStep1: Change ActAntiTheftProtectionSystem And Validate Plan  console=true
    Change Value Of ActAntiTheftProtectionSystem Parameter
    Wait Until Element Is Clicked  //*[contains(@a-title, 'Validate Plan')]
    Wait Until Element Is Clicked  //*[contains(@a-title, 'Activate Plan')]  60
    ${activate_tab}  Catenate  SEPARATOR=  xpath:/html/body/div[1]/div/div/ui-modal-renderer/deploy-plan-modal-component/ui-modal/div/div/div[2]/div/
    ...  ui-body/div[4]/label/span
    Wait Until Element Is Clicked  ${activate_tab}  90  10
    Wait Until Element Is Clicked  //*[contains(@a-title, 'Execute')]  120
    Wait Until Element Is Visible  //*[contains(text(), ' Operation finished successfully')]  300
    Click Element  xpath=//*[contains(@a-text, 'Close')]


Step2: Verify Permissions For ActAntiTheftProtectionSystem Parameter
    Log  \nStep2: Verify Permissions For ActAntiTheftProtectionSystem Parameter  console=true
    Check Permissions For AntiTheftProtection Parameter On Every SMOD
    Check Permissions For AntiTheftProtection Parameter On Every BBMOD


Step3: Change ActAntiTheftProtectionSystem Parameter With Initial Value
    Log  \nStep3: Change ActAntiTheftProtectionSystem Parameter With Initial Value  console=true
    Perform Parameter Recommissioning  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1  parameter=actAntiTheftProtectionSystem  operation=update
    ...  value=Disabled  skip_parameter_relation_errors=true  timeout=600


Change Value Of ActAntiTheftProtectionSystem Parameter
    Wait Until Element Is Clicked  ${PARAMETER_EDITOR}  90  10
    ${search_tab}  Catenate  SEPARATOR=  //*[contains(@class, 'global-search-panel view-panel ng-isolate-scope')]/wf-panel-section/div/div/div/div/
    ...  div[1]/global-search-tab-content/pe-global-search-objects/div/execution-bar/div/pe-global-search-filter/ui-text-input/div/input
    Input Text  ${search_tab}  FEATCADM-1
    Click Element  locator=//span[contains(text(),'FEATCADM-1')]
    ${number_of_row}  SeleniumLibrary.Get Element Count  xpath=//table[@class="n-table parameter-table-body"]/tbody/tr
    FOR  ${index}  IN RANGE  2  ${number_of_row}+2
        ${parameter_xpath}  Catenate  SEPARATOR=  //table[@class="n-table parameter-table-body"]/tbody/tr[${index}]/td[3]/highlighter
        ${parameter_name}  SeleniumLibrary.Get Element Attribute  ${parameter_xpath}  title
        ${select_xpath}  Catenate  SEPARATOR=  //*[contains(@class, 'n-table parameter-table-body')]/tbody/tr[${index}]/td[4]/parameter-input/div/
        ...  ui-select/div/wf-dropdown/div/button
        Run Keyword If  '${parameter_name}'=='actAntiTheftProtectionSystem'
        ...  Run Keywords
        ...  Click Element  ${select_xpath}
        ...  AND
        ...  Click Element  locator=//*[contains(text(),'MCC and MNC')]
        ...  AND
        ...  Exit For Loop
    END


Check Permissions For AntiTheftProtection Parameter On Every ${object}
    Wait Until Element Is Clicked  ${PARAMETER_EDITOR}  90  10
    ${search_tab}  Catenate  SEPARATOR=  //*[contains(@class, 'global-search-panel view-panel ng-isolate-scope')]/wf-panel-section/div/div/div/div/
    ...  div[1]/global-search-tab-content/pe-global-search-objects/div/execution-bar/div/pe-global-search-filter/ui-text-input/div/input
    Input Text  ${search_tab}  ${object}_R
    ${input_object_xpath}  Catenate  SEPARATOR=  //*[contains(@class, "tree-list-row-indent")]/div/pe-global-search-row/div/span/highlighter/span/
    ...  span[contains(text(),"${object}_R")]
    ${count_object}  SeleniumLibrary.Get Element Count  ${input_object_xpath}
    FOR  ${index}  IN RANGE  1  ${count_object}+1
        Click Element  xpath=//*[contains(@aria-label, '${object}_R-${index}')]
        Check Permissions For mcc Attribute On ${object}_R-${index}
        Check Permissions For mnc Attribute On ${object}_R-${index}
    END


Check Permissions For ${parameter} Attribute On ${object}
    Input Text  //*[contains(@class, 'n-table parameter-table-header')]/thead/tr[2]/th[3]/input  ${parameter}
    ${parameter_xpath}  Catenate  SEPARATOR=  //table[@class="n-table parameter-table-body"]/tbody/tr[4]/td[3]/highlighter
    ${parameter_name}  SeleniumLibrary.Get Element Attribute  ${parameter_xpath}  title
    ${planned_value_parameter}  Catenate  SEPARATOR=  //*[contains(@class, 'n-table parameter-table-body')]/tbody/tr/td[4]/parameter-input/div/
    ...  ui-text-input/div/input
    ${permission_parameter}  Run Keyword If  '${parameter_name}'=='${parameter}'
    ...  SeleniumLibrary.Get Element Attribute  ${planned_value_parameter}  disabled
    ...  ELSE
    ...  Fail  Parameter ${parameter} not exist on ${object}.
    Should Be Equal  ${permission_parameter}  true
    Log  \nPermissions for AntiTheftProtection ${parameter} parameter on ${object} are disabled.  console=true


TC Setup
    Common Test Setup
    WebEM Setup


TC Teardown
    Run Keyword If Test Failed
    ...  Step3: Change ActAntiTheftProtectionSystem Parameter With Initial Value
    WebEM Teardown
    Common Test Teardown

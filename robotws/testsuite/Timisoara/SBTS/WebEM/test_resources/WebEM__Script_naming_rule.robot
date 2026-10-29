*** Settings ***
Documentation
    ...  This test case is created to check in Troubleshooting Scripts tab, the name of scripts.
    ...  Verify if NR and LTE cells exists.
    ...  Open Diagnostic -> Troubleshooting Scripts tab
    ...  If only 5G cells exists and LTE cells not exists, verify scripts name to be l1_lnr_col_bun, l1_lnr_col_hdr and l1_lnr_col_reg
    ...  If only LTE cells exists and NR cells not exists, verify scripts name to be l2_lte_col_cell
    ...  If 5G cells exists and LTE cells exists too, verify scripts name to be l1_lnr_col_bun, l1_lnr_col_hdr, l1_lnr_col_reg and l2_lte_col_cell

Resource  ../../common_resources/ca_WebEM_general.robot


*** Keywords ***
TC__WebEM__Script_naming_rule
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-23214
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 30.05.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23214 - Initial TAT creation
    ...  - 25.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24131 - Refactor TCs with best practice

    Set Tags  CA-WebEM  OWNER-cristina.antoci@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS22

    Step1: Verify If NR and/or LTE Cells Exist
    Step2: Open Troubleshooting Scripts Tab
    Step3: Verify Scripts Name


Step1: Verify If NR and/or LTE Cells Exist
    Log  Step1: Verify if NR and/or LTE cells exist  console=true
    Run Keyword If  ${SCF_COUNT_NR}
    ...  Log  NR cells exist!  console=true
    Run Keyword If  ${SCF_COUNT_LTE}
    ...  Log  LTE cells exist!  console=true
    Run Keyword If  ${SCF_COUNT_NR}==0 and ${SCF_COUNT_LTE}==0
    ...  Fail  NR or LTE cells does not exist!


Step2: Open Troubleshooting Scripts Tab
    Log  Step2: Open Troubleshooting Scripts tab  console=true
    Open Diagnostic Menu
    Click Element  xpath://*[contains(text(), "Troubleshooting Scripts")]
    Log  Waiting for text "Fetching succeeded" to appear  console=true
    ${status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  300  5
    ...  Element Should Be Visible  //*[contains(text(), 'Fetching succeeded')]
    Run Keyword If  ${status}
    ...  Log  Text "Fetching succeeded" appeard![OK]  console=true
    ...  ELSE
    ...  Set Test Restriction  Text "Fetching succeeded" is not appeard![NOK]


Step3: Verify Scripts Name
    Log  Step3: Verify scripts name  console=true
    Run Keyword If  ${SCF_COUNT_NR}>0 and ${SCF_COUNT_LTE}==0
    ...  Verify Scripts Name If Only 5G Exists
    ...  ELSE IF  ${SCF_COUNT_NR}==0 and ${SCF_COUNT_LTE}>0
    ...  Verify Scripts Name If Only LTE Exists
    ...  ELSE
    ...  Verify Scripts Name If 5G And LTE Exists


Verify Scripts Name If Only 5G Exists
    Log  Verify scripts name if only 5G exists  console=true
    ${script_webem_elements}  SeleniumLibrary.Get WebElements  //div[@class='p-element script-item ng-star-inserted']
    ${number_of_scripts}  Get Length  ${script_webem_elements}
    FOR  ${script}  IN  @{script_webem_elements}
        ${text}  Get Text  ${script}
        ${script_name_status}  Run Keyword And Return Status
        ...  Should Match Regexp  ${text}  l1_lnr_col_bun|l1_lnr_col_hdr|l1_lnr_col_reg
        Run Keyword If  ${script_name_status}
        ...  Log  '${text}' script is visible ok![OK]  console=true
        ...  ELSE
        ...  Fail  '${text}' script is not visible ok![NOK]
        ${status}  Run Keyword And Return Status
        ...  Element Should Be Enabled  xpath=//*[contains(@aria-label, '${text}')]
        Run Keyword If  ${status}
        ...  Log  '${text}' script is enabled![OK]  console=true
        ...  ELSE
        ...  Fail  '${text}' script is not enabled![NOK]
        Click Element  xpath=//*[contains(@aria-label, '${text}')]
    END


Verify Scripts Name If Only LTE Exists
    Log  Verify scripts name if only LTE exists  console=true
    ${text}  Get Text  //div[@class='p-element script-item ng-star-inserted']
    ${script_name_status}  Should Be Equal  ${text}  l2_lte_col_cell
    Run Keyword If  ${script_name_status}
    ...  Log  '${text}' script is visible ok![OK]  console=true
    ...  ELSE
    ...  Fail  '${text}' script is not visible ok![NOK]
    ${status}  Run Keyword And Return Status
    ...  Element Should Be Enabled  xpath=//*[contains(@aria-label, '${text}')]
    Run Keyword If  ${status}
    ...  Log  '${text}' script is enabled![OK]  console=true
    ...  ELSE
    ...  Fail  '${text}' script is not enabled![NOK]
    Click Element  xpath=//*[contains(@aria-label, '${text}')]


Verify Scripts Name If 5G And LTE Exists
    Log  Verify scripts name if 5G and LTE exists  console=true
    ${script_webem_elements}  SeleniumLibrary.Get WebElements  //div[@class='p-element script-item ng-star-inserted']
    ${number_of_scripts}  Get Length  ${script_webem_elements}
    FOR  ${script}  IN  @{script_webem_elements}
        ${text}  Get Text  ${script}
        ${script_name_status}  Run Keyword And Return Status
        ...  Should Match Regexp  ${text}  l1_lnr_col_bun|l1_lnr_col_hdr|l1_lnr_col_reg|l2_lte_col_cell
        Run Keyword If  ${script_name_status}
        ...  Log  '${text}' script is visible ok![OK]  console=true
        ...  ELSE
        ...  Fail  '${text}' script is not visible ok![NOK]
        ${status}  Run Keyword And Return Status
        ...  Element Should Be Enabled  xpath=//*[contains(@aria-label, '${text}')]
        Run Keyword If  ${status}
        ...  Log  '${text}' script is enabled![OK]  console=true
        ...  ELSE
        ...  Fail  '${text}' script is not enabled![NOK]
        Click Element  xpath=//*[contains(@aria-label, '${text}')]
    END


TC Setup
    Common Test Setup
    WebEM Setup


TC Teardown
    WebEM Teardown
    Common Test Teardown

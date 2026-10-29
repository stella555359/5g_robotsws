*** Settings ***
Resource    ../../common_resources/ca_WebEM_mobile.robot


*** Variables ***
${CABINET}  AMIA  #Product name of cabinet
${PRODUCT_CODE_CABINET}  473098A   #Product code of cabinet


*** Keywords ***
TC__WebEM__Description_of_HW_units_based_on_their_Product_Code
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-22345
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This test case check Site Report View.
    ...  Check if Cabinet is visible in Site Report.
    ...  Check if System Modules is visible in Site Report.
    ...  Check if Baseband Modules is visible in Site Report.
    ...  Check if Radio Modules is visible in Site Report.
    ...  Check if Cells is visible in Site Report.
    ...  Check if SW Release Versions is visible in Site Report.
    ...  Check if Cabinet is visible correct in Site Report.
    ...  Check if all SMODs are visible in Site Report with correct Product code.
    ...  Check if all BBMODs are visible in Site Report with correct Product code.
    ...  Check if all RMODs are visible in Site Report with correct Product code.
    ...  Check if SW are visible in Site Report correct.
    ...  Save Report.
    ...  History of changes
    ...  ******************
    ...  - 16.12.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22345 - Initial TAT creation
    ...  - 20.01.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22509 - Adding SW check and Save Report
    ...  - 25.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24131 - Refactor TCs with best practice

    Set Tags    CA-WebEM    OWNER-george.gheban@nokia.com    AUTHOR-andreea.burtic@nokia.com
    ...    MAINTAINER-andreea.burtic@nokia.com    GROUP_IN_CHARGE-TIM_3_Vrf    FEATURE-CB005750
    ...    PHASE-CRT    SW-SBTS22

    Step1: Webem check Site Report View
    Step2: Site report check HW and SW
    Step3: Save Report


Step1: Webem check Site Report View
    Log  Step1: Webem check Site Report View  console=true
    Sleep  30s
    SELENIUM Click Visible Element  //*[@id="main-view"]/div/div[1]/app-header/div[1]/i
    SELENIUM Click Visible Element  locator=//div[contains(text(), "Site Report")]
    Wait Until Element Is Visible  locator=//div[@class="save-report-mob"]//*[@a-text="Save Report"]  timeout=10
    Wait Until Element Is Visible  locator=//div[contains(text(), "Cabinet")]  timeout=10
    Wait Until Element Is Visible  locator=//div[contains(text(), "System Modules")]  timeout=10
    Wait Until Element Is Visible  locator=//div[contains(text(), "Baseband Modules")]  timeout=10
    Wait Until Element Is Visible  locator=//div[contains(text(), "Radio Modules")]  timeout=10
    Wait Until Element Is Visible  locator=//div[contains(text(), "NR Cell Groups")]  timeout=10
    Wait Until Element Is Visible  locator=//div[contains(text(), "Cells")]  timeout=10
    Wait Until Element Is Visible  locator=//div[contains(text(), "SW Release Versions")]  timeout=10

Step2: Site report check HW and SW
    Log  Step2: Site report check HW and SW  console=true
    ${bbmods}  Get Length  ${bbmods_xpath}
    ${rmods}  Get Length  ${rmods_xpath}
    Create List Of Smod Parameters
    Create List Of Bbmods Parameters
    Create List Of Rmods Parameters
    Log  Checking Cabinet...  console=true
    ${cabinet_status}  Run keyword and return status  Site Report check Cabinet   ${CABINET}    ${PRODUCT_CODE_CABINET}
    Run keyword if  ${cabinet_status}
    ...  Log  ${CABINET} with Product Code ${PRODUCT_CODE_CABINET} is visible in Site Report![OK]  console=true
    ...  ELSE
    ...  Fail  ${CABINET} with Product Code ${PRODUCT_CODE_CABINET} is not visible in Site Report![NOK]
    Log  Checking SMOD...  console=true
    ${smod}  Run keyword and return status  Site Report check SMOD   ${OUT_ADMIN_SMOD_PARAMETERS[0]['productName']}
    ...  ${OUT_ADMIN_SMOD_PARAMETERS[0]['productCode']}
    Run keyword if  ${smod}
    ...  Log  ${OUT_ADMIN_SMOD_PARAMETERS[0]['productName']}: ${OUT_ADMIN_SMOD_PARAMETERS[0]['productCode']} appeared ![OK]  console=true
    ...  ELSE
    ...  Fail  ${OUT_ADMIN_SMOD_PARAMETERS[0]['productName']}: ${OUT_ADMIN_SMOD_PARAMETERS[0]['productCode']} is not appeared![NOK]
    Log  Checking BBMODs...  console=true
    FOR  ${index}  IN RANGE  0  ${bbmods}
       Site Report check BBMOD  ${OUT_ADMIN_BBMODS_PARAMETERS[${index}]['productName']}  ${OUT_ADMIN_BBMODS_PARAMETERS[${index}]['productCode']}
       Log  ${OUT_ADMIN_BBMODS_PARAMETERS[${index}]['productName']}: ${OUT_ADMIN_BBMODS_PARAMETERS[${index}]['productCode']} appeared!  console=true
    END
    Log  Checking RMODs...  console=true
    FOR  ${index}  IN RANGE  0  ${rmods}
       Site Report check RMOD  ${OUT_ADMIN_RMODS_PARAMETERS[${index}]['productName']}  ${OUT_ADMIN_RMODS_PARAMETERS[${index}]['productCode']}
       Log  ${OUT_ADMIN_RMODS_PARAMETERS[${index}]['productName']}: ${OUT_ADMIN_RMODS_PARAMETERS[${index}]['productCode']} appeared!  console=true
    END
    Log  Checking SW...  console=true
    SELENIUM Click Visible Element  locator=//div[contains(text(), "SW Release Versions")]
    ${sw_text}  Catenate  SEPARATOR=  //*[@id="main-view"]/div/div[1]/div/ng-view/wf-panel/wf-panel-section/div/div/
    ...  site-report-downgrade/div[2]/div/div[4]/div/ui-expansion-panel/ui-expandable-panel/div/div[2]/div/ui-list-item[1]/div/div/div
    ${sw_webem}   Get Text  ${sw_text}
    Run keyword if  '${active SW version}'=='${sw_webem}'
    ...  Log  SW: ${active SW version} appeared in Site Report![OK]  console=true
    ...  ELSE
    ...  Fail  SW: ${active SW version} not appeared in Site Report![NOK]

Step3: Save Report
    Log  Step3: Save Report  console=true
    ${im_bts_id}=  Admin Get BTS Id
    ${status}  Run keyword and return status  Click Element  xpath=//*[contains(@a-text, 'Save Report')]
    Sleep  10s
    Run keyword if  ${status}
    ...  Log  Saving Report has been performed successfully!  console=true
    ...  ELSE
    ...  Set Test Restriction  Save Report action was not performed!
    Move File  /home/ute/Downloads/Site_Report_*.zip  ${BTSFiles}/Site_Report_SBTS-${im_bts_id}.zip
    SELENIUM Click Visible Element  //*[@id="main-view"]/div/div[1]/app-header/div[1]/i
    SELENIUM Click Visible Element   locator=//div[contains(text(), "Site View")]

Site Report check Cabinet
    [Arguments]
    ...    ${cabinet_model}
    ...    ${cabinet_pc}
    SELENIUM Click Visible Element  locator=//div[text()="Cabinet"]
    Wait Until Element Is Visible  locator=//label[text()="Product code"]/..//div[text()="${cabinet_pc}"]  timeout=10
    Wait Until Element Is Visible  locator=//label[text()="Product name"]/..//div[contains(text(), "${cabinet_model}")]  timeout=10
    SELENIUM Click Visible Element  locator=//div[text()="Cabinet"]

Site Report check SMOD
    [Arguments]
    ...    ${smod_model}
    ...    ${smod_pc}
    SELENIUM Click Visible Element  locator=//div[text()="System Modules"]
    Wait Until Element Is Visible  locator=//label[text()="Product code"]/..//div[text()="${smod_pc}"]  timeout=10
    Wait Until Element Is Visible  locator=//label[text()="Product name"]/..//div[contains(text(), "${smod_model}")]  timeout=10
    SELENIUM Click Visible Element    locator=//div[text()="System Modules"]

Create List Of Smod Parameters
    ${out_smod_parameters}=    ADMIN Get Parameters For All SMOD
    Set Test Variable    ${OUT_ADMIN_SMOD_PARAMETERS}    ${out_smod_parameters}

ADMIN Get Parameters For All SMOD
    [Arguments]    ${timeout}=10
    ${out_list_of_smod_parameters_dict}=    ADMIN Get Parameters For All  class_name=SMOD  timeout=${timeout}
    [Return]    ${out_list_of_smod_parameters_dict}

Site Report check BBMOD
    [Arguments]
    ...    ${bb_model}
    ...    ${bb_pc}
    SELENIUM Click Visible Element  locator=//div[text()="Baseband Modules"]
    Wait Until Element Is Visible  locator=//label[text()="Product code"]/..//div[contains(text(), "${bb_pc}")]  timeout=10
    Wait Until Element Is Visible  locator=//label[text()="Product name"]/..//div[contains(text(), "${bb_model}")]  timeout=10
    SELENIUM Click Visible Element    locator=//div[text()="Baseband Modules"]

Create List Of Bbmods Parameters
    ${out_bbmods_parameters}=    ADMIN Get Parameters For All BBMODs
    Set Test Variable    ${OUT_ADMIN_BBMODS_PARAMETERS}    ${out_bbmods_parameters}

ADMIN Get Parameters For All BBMODs
    [Arguments]    ${timeout}=10
    ${out_list_of_bbmods_parameters_dict}=    ADMIN Get Parameters For All  class_name=BBMOD  timeout=${timeout}
    [Return]    ${out_list_of_bbmods_parameters_dict}

Site Report check RMOD
    [Arguments]
    ...    ${radio_model}
    ...    ${radio_pc}
    SELENIUM Click Visible Element  locator=//div[text()="Radio Modules"]
    Wait Until Element Is Visible  locator=//label[text()="Product code"]/..//div[text()="${radio_pc}"]  timeout=10
    Wait Until Element Is Visible  locator=//label[text()="Product name"]/..//div[contains(text(), "${radio_model}")]  timeout=10
    SELENIUM Click Visible Element  locator=//div[text()="Radio Modules"]

Create List Of Rmods Parameters
    ${out_rmods_parameters}=    ADMIN Get Parameters For All RMODs
    Set Test Variable    ${OUT_ADMIN_RMODS_PARAMETERS}    ${out_rmods_parameters}
    Set Test Variable    ${SYSTEM_RMOD_LOCAL_IP}    ${OUT_RMODS_PARAMETERS[0]['ipAddress']}

ADMIN Get Parameters For All RMODs
    [Arguments]    ${timeout}=10
    ${out_list_of_rmod_parameters_dict}=    ADMIN Get Parameters For All  class_name=RMOD  timeout=${timeout}
    [Return]    ${out_list_of_rmod_parameters_dict}


TC Setup
    Common test setup
    WebEM Setup via Mobile

TC Teardown
    WebEM Teardown via Mobile
    Common test teardown

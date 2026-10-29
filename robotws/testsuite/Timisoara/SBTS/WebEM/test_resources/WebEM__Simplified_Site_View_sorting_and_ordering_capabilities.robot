*** Settings ***
Documentation
    ...  This test case check if sorting and ordering capabilities are possible.
    ...  Filter and Unfilter SMODs/BBMODs
    ...  Filter and Unfilter NMS
    ...  Filter and Unfilter Master Node
    ...  Filter and Unfilter Controllers

Resource  ../../common_resources/ca_WebEM_mobile.robot


*** Keywords ***
TC__WebEM__Simplified_Site_View_sorting_and_ordering_capabilities
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-22348
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  - 16.12.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22348 - Initial TAT creation
    ...  - 30.08.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23604 - Filter button changed
    ...  - 25.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24131 - Refactor TCs with best practice

    Set Tags  CA-WebEM  OWNER-george.gheban@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  FEATURE-CB005750  PHASE-CRT  SW-SBTS21

    Step1: Filter And Unfilter SMODs/BBMODs
    Step2: Filter And Unfilter NMS
    Step3: Filter And Unfilter Master Node
    Step4: Filter And Unfilter Controllers


Step1: Filter And Unfilter SMODs/BBMODs
    Log  Step1: Filter and Unfilter SMODs/BBMODs  console=true
    ${site_filter_btn}  Set Variable  //*[contains(@class, 'elements-button')]
    Set Test Variable  ${SITE_FILTER_BTN}
    Sleep  60s
    Element Should Be Visible  locator=//div[text()='SMODs/BBMODs']
    Element Should Be Visible  locator=//div[contains(text(), 'SMOD-1')]
    SELENIUM Click Visible Element  locator=${SITE_FILTER_BTN}
    ${click_status}  Run Keyword And Return Status
    ...  SELENIUM Click Visible Element  locator=//span[contains(@class, 'checkbox-value') and text()='SMODs/BBMODs']
    Run Keyword If  ${click_status}
    ...  Log  SMODs/BBMODs checkbox value has been unselected![OK]  console=true
    ...  ELSE
    ...  Set Test Restriction  SMODs/BBMODs checkbox value has not been unselected![NOK]
    SELENIUM Click Visible Element  locator=${SITE_FILTER_BTN}
    ${smod_status}  Run Keyword And Return Status
    ...  Element Should Not Be Visible  locator=//div[text()='SMODs/BBMODs']
    Run Keyword If  ${smod_status}
    ...  Log  SMODs/BBMODs is not visible in Site View![OK]  console=true
    ...  ELSE
    ...  Set Test Restriction  SMODs/BBMODs is visible is Site View![NOK]
    Element Should Not Be Visible  locator=//div[contains(text(), 'SMOD-1')]
    SELENIUM Click Visible Element  locator=${SITE_FILTER_BTN}
    ${click_status}  Run Keyword And Return Status
    ...  SELENIUM Click Visible Element  locator=//span[contains(@class, 'checkbox-value') and text()='SMODs/BBMODs']
    Run Keyword If  ${click_status}
    ...  Log  SMODs/BBMODs checkbox value has been selected![OK]  console=true
    ...  ELSE
    ...  Set Test Restriction  SMODs/BBMODs checkbox value has not been selected![NOK]
    SELENIUM Click Visible Element  locator=${SITE_FILTER_BTN}
    Element Should Be Visible  locator=//div[text()='SMODs/BBMODs']
    ${smod_status}  Run Keyword And Return Status
    ...  Element Should Be Visible  locator=//div[contains(text(), 'SMOD-1')]
    Run Keyword If  ${smod_status}
    ...  Log  SMODs/BBMODs is visible in Site View![OK]  console=true
    ...  ELSE
    ...  Set Test Restriction  SMODs/BBMODs isn't visible is Site View![NOK]


Step2: Filter And Unfilter NMS
    Log  Step2: Filter and Unfilter NMS  console=true
    Element Should Be Visible  locator=//div[text()='NMS']
    Element Should Be Visible  locator=//div[contains(@class, 'bts-mediator')]//div[contains(text(), 'NMS')]
    SELENIUM Click Visible Element  locator=${SITE_FILTER_BTN}
    ${click_status}  Run Keyword And Return Status
    ...  SELENIUM Click Visible Element  locator=//span[contains(@class, 'checkbox-value') and text()='NMS']
    Run Keyword If  ${click_status}
    ...  Log  NMS checkbox value has been unselected![OK]  console=true
    ...  ELSE
    ...  Set Test Restriction  NMS checkbox value has not been unselected![NOK]
    SELENIUM Click Visible Element  locator=${SITE_FILTER_BTN}
    ${nms_status}  Run Keyword And Return Status
    ...  Element Should Not Be Visible  locator=//div[text()='NMS']
    Run Keyword If  ${nms_status}
    ...  Log  NMS isn't visible in Site View![OK]  console=true
    ...  ELSE
    ...  Set Test Restriction  NMS is visible is Site View![NOK]
    Element Should Not Be Visible  locator=//div[contains(@class, 'bts-mediator')]//div[contains(text(), 'NMS')]
    SELENIUM Click Visible Element  locator=${SITE_FILTER_BTN}
    ${click_status}  Run Keyword And Return Status
    ...  SELENIUM Click Visible Element  locator=//span[contains(@class, 'checkbox-value') and text()='NMS']
    Run Keyword If  ${click_status}
    ...  Log  NMS checkbox value has been selected![OK]  console=true
    ...  ELSE
    ...  Set Test Restriction  NMS checkbox value has not been selected![NOK]
    SELENIUM Click Visible Element  locator=${SITE_FILTER_BTN}
    ${nms_status}  Run Keyword And Return Status
    ...  Element Should Be Visible  locator=//div[text()='NMS']
    Run Keyword If  ${nms_status}
    ...  Log  NMS is visible in Site View![OK]  console=true
    ...  ELSE
    ...  Set Test Restriction  NMS isn't visible is Site View![NOK]
    Element Should Be Visible  locator=//div[contains(@class, 'bts-mediator')]//div[contains(text(), 'NMS')]


Step3: Filter And Unfilter Master Node
    Log  Step3: Filter and Unfilter Master Node  console=true
    ${status}  Run Keyword And Return Status
    ...  Element Should Be Visible  locator=//div[text()='Master Node']
    Run Keyword If  ${status}
    ...  Filter And Unfilter Master Node
    ...  ELSE
    ...  Log  Master Node doesn't exist!  console=true


Step4: Filter And Unfilter Controllers
    Log  Step4: Filter and Unfilter Controllers  console=true
    Element Should Be Visible  locator=//div[text()='Controllers']
    SELENIUM Click Visible Element  locator=${SITE_FILTER_BTN}
    ${click_status}  Run Keyword And Return Status
    ...  SELENIUM Click Visible Element  locator=//span[contains(@class, 'checkbox-value') and text()='BTS Controllers']
    Run Keyword If  ${click_status}
    ...  Log  Controllers checkbox value has been selected![OK]  console=true
    ...  ELSE
    ...  Set Test Restriction  Controllers checkbox value has not been selected![NOK]
    SELENIUM Click Visible Element  locator=${SITE_FILTER_BTN}
    ${controllers_status}  Run Keyword And Return Status
    ...  Element Should Not Be Visible  locator=//div[text()='Controllers']
    Run Keyword If  ${controllers_status}
    ...  Log  Controllers aren't visible in Site View![OK]  console=true
    ...  ELSE
    ...  Set Test Restriction  Controllers are visible is Site View![NOK]
    SELENIUM Click Visible Element  locator=${SITE_FILTER_BTN}
    ${click_status}  Run Keyword And Return Status
    ...  SELENIUM Click Visible Element  locator=//span[contains(@class, 'checkbox-value') and text()='BTS Controllers']
    Run Keyword If  ${click_status}
    ...  Log  Controllers checkbox value has been selected![OK]  console=true
    ...  ELSE
    ...  Set Test Restriction  Controllers checkbox value has not been selected![NOK]
    SELENIUM Click Visible Element  locator=${SITE_FILTER_BTN}
    ${controllers_status}  Run Keyword And Return Status
    ...  Element Should Be Visible  locator=//div[text()='Controllers']
    Run Keyword If  ${controllers_status}
    ...  Log  Controllers are visible in Site View![OK]  console=true
    ...  ELSE
    ...  Set Test Restriction  Controllers aren't visible is Site View![NOK]


Filter And Unfilter Master Node
    Element Should Be Visible  locator=//div[text()='Master Node']
    SELENIUM Click Visible Element  locator=${SITE_FILTER_BTN}
    ${click_status}  Run Keyword And Return Status
    ...  SELENIUM Click Visible Element  locator=//span[contains(@class, 'checkbox-value') and text()='Master Node']
    Run Keyword If  ${click_status}
    ...  Log  Master node checkbox value has been unselected![OK]  console=true
    ...  ELSE
    ...  Set Test Restriction  Master node checkbox value has not been unselected![NOK]
    SELENIUM Click Visible Element  locator=${SITE_FILTER_BTN}
    ${mn_status}  Run Keyword And Return Status
    ...  Element Should Not Be Visible  locator=//div[text()='Master Node']
    Run Keyword If  ${mn_status}
    ...  Log  Master node isn't visible in Site View![OK]  console=true
    ...  ELSE
    ...  Set Test Restriction  Master node is visible is Site View![NOK]
    SELENIUM Click Visible Element  locator=${SITE_FILTER_BTN}
    ${click_status}  Run Keyword And Return Status
    ...  SELENIUM Click Visible Element  locator=//span[contains(@class, 'checkbox-value') and text()='Master Node']
    Run Keyword If  ${click_status}
    ...  Log  Master node checkbox value has been selected![OK]  console=true
    ...  ELSE
    ...  Set Test Restriction  Master Node checkbox value has not been selected![NOK]
    SELENIUM Click Visible Element  locator=${SITE_FILTER_BTN}
    ${mn_status}  Run Keyword And Return Status
    ...  Element Should Be Visible  locator=//div[text()='Master Node']
    Run Keyword If  ${mn_status}
    ...  Log  Master node is visible in Site View![OK]  console=true
    ...  ELSE
    ...  Set Test Restriction  Master Node isn't visible is Site View![NOK]


TC Setup
    Common Test Setup
    WebEM Setup Via Mobile


TC Teardown
    WebEM Teardown Via Mobile
    Common Test Teardown

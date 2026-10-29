*** Settings ***
Documentation
    ...  This test case check if Master node with LTEENB link is visible.
    ...  Perform this TC on SBTS with 5G NSA.
    ...  Check if NG link status is inactive which means that SBTS has 5G NSA.
    ...  If the SBTS has 5G NSA, this test case will check if master node appeared.
    ...  Check if LTEENB link is visible.
    ...  Check if LTEENB link is available.

Resource  ../../common_resources/ca_WebEM_mobile.robot


*** Keywords ***
TC__WebEM__Simplified_Site_View_Master_Mode_visualization
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-22515
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  - 20.01.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22515 - Initial TAT creation
    ...  - 25.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24131 - Refactor TCs with best practice

    Set Tags  CA-WebEM  OWNER-george.gheban@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS22

    Step1: Check Master Node


Step1: Check Master Node
    Log  Step1: Check Master Node  console=true
    ${status}  Run Keyword And Return Status
    ...  Element Should Not Be Visible  locator=//div[contains(@title, 'NG link status: active')]
    Run Keyword If  ${status}
    ...  Run Keywords
    ...  Log  The SBTS has 5G NSA, test will be continue...  console=true
    ...  AND
    ...  Check Link LTEENB
    ...  ELSE
    ...  Fail  This SBTS doesn't have 5G NSA, please perform the test on an SBTS with 5G NSA!


Check Link LTEENB
    Log  Check if Master Node is visible...  console=true
    ${status_master_node}  Run Keyword And Return Status
    ...  Element Should Be Visible  locator=//div[text()='Master Node']
    Run Keyword If  ${status_master_node}
    ...  Log  Master Node, appeared![OK]  console=true
    ...  ELSE
    ...  Fail  Master Node does not appeared![NOK]
    Log  Check if LTEENB link is visible...  console=true
    ${status_link}  Run Keyword And Return Status
    ...  Element Should Be Visible  locator=//div[contains(text(), 'LTEENB-')]
    Run Keyword If  ${status_link}
    ...  Get Link Id
    ...  ELSE
    ...  Fail  Link LTEENB does not appeared![NOK]
    Log  Check if link is available...  console=true
    ${status_link_status}  Run Keyword And Return Status
    ...  Element Should Be Visible  locator=//div[text()='Master Node']/../../..//./div[contains(@class, 'green-diode')]
    Run Keyword If  ${status_link_status}
    ...  Log  Link is available![OK]  console=true
    ...  ELSE
    ...  Fail  Link is not available![NOK]


Get Link Id
    ${link_id}  Get Text  locator=//div[contains(text(), 'LTEENB-')]
    Log  Link ${link_id}, appeared![OK]  console=true


TC Setup
    Common Test Setup
    WebEM Setup Via Mobile


TC Teardown
    WebEM Teardown Via Mobile
    Common Test Teardown

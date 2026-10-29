*** Settings ***
Resource    ../../common_resources/ca_WebEM_mobile.robot


*** Keywords ***
TC__WebEM__Simplified_Site_View_cell_groups_visualization
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-22513
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This test case check if NR cell groups is visible.
    ...  Perform this TC on SBTS with 5G.
    ...  Check if NR cells exist.
    ...  Check if NR cell groups is visible.
    ...  Check if all groups are visible.
    ...  History of changes
    ...  ******************
    ...  - 20.01.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22513 - Initial TAT creation
    ...  - 25.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24131 - Refactor TCs with best practice

    Set Tags    CA-WebEM    OWNER-george.gheban@nokia.com    AUTHOR-andreea.burtic@nokia.com
    ...    MAINTAINER-andreea.burtic@nokia.com    GROUP_IN_CHARGE-TIM_3_Vrf     PHASE-CRT    SW-SBTS22

    Step0: Verify if NR cells exist
    Step1: Check cell groups


Step0: Verify if NR cells exist
    Log  \n Step0: Verify if NR cells exist  console=true
    Run keyword if  ${SCF_COUNT_NR}
    ...  Log  NR cells exist, test will be continue!  console=true
    ...  ELSE
    ...  Fail  NR cells does not exist!

Step1: Check cell groups
    Log  Step1: Check cell groups  console=true
    ${bts_info}  Get Bts Info
    Set test variable  ${GROUPS}  ${bts_info['cellsGroup']}
    Log  Check if NR cell groups is visible in Site View...  console=true
    ${status}  Run keyword and return status  Wait Until Element Is Visible  locator=//div[@class='title' and text()='NR cell groups']  timeout=30
    Run keyword if  ${status}  run keywords
    ...  Log  NR cell groups is visible in Site View![OK]  console=true  AND
    ...  Check all groups to be visible
    ...  ELSE
    ...  Fail  NR cell groups is not visible in Site View![NOK]

Check all groups to be visible
    FOR  ${group}  IN  @{GROUPS}
        Log  Check if group ${group['name']} who has cell ${group['nrCellList']} mapped on it is visible in Site View...  console=true
        ${status_group}  Run keyword and return status  Wait Until Element Is Visible  locator=//div[text()='${group['name']}']  timeout=30
        Run keyword if  ${status_group}
        ...  Log  Group: ${group['name']} who has cell ${group['nrCellList']} mapped on it, is visible![OK]  console=true
        ...  ELSE
        ...  Fail  Group: ${group['name']} who has cell ${group['nrCellList']} mapped on it, is not visible![NOK]
    END


TC Setup
    Common test setup
    WebEM Setup via Mobile

TC Teardown
    WebEM Teardown via Mobile
    Common test teardown

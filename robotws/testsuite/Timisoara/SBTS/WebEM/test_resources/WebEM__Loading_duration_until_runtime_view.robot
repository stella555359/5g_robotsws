*** Settings ***
Documentation
    ...  This test case checks whether the loading time of the WebEM runtime view is
    ...  within expected parameters or not (as specified in the TAT).

Resource  ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${TIMEOUT}  30s


*** Keywords ***
TC__WebEM__Loading_duration_until_runtime_view
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-21564
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 06.07.2021 - https://jira3.int.net.nokia.com/browse/TAT-21564 - Initial TAT creation
    ...  - 25.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24131 - Refactor TCs with best practice

    Set Tags  CA-WebEM  OWNER-nicolae-marcel.caragel@nokia.com  AUTHOR-vlad.slivilescu@nokia.com  MAINTAINER-vlad.slivilescu@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS00

    Step 1: Open WebEM In Browser


Step 1: Open WebEM In Browser
    Open WebEM  timeout=${TIMEOUT}


TC Setup
    Common Test Setup
    Set Screenshot Directory  ${BTS_FILES}/selenium_screenshot_${TEST_NAME}


TC Teardown
    WebEM Teardown
    Common Test Teardown

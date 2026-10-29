*** Settings ***
Resource    ../../common_resources/ca_WebEM_general.robot


*** Keywords ***
TC__WebEM__5G_RAT_reset
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-21051
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This test case performes RAT reset for each technology: NR, LTE, WCDMA, GSM.
    ...  Verify if all cells on SBTS are working.
    ...  RAT reset is performed.
    ...  Verify the operational state of each cell to be Disabled.
    ...  Verify states for cells in unaffected RATs.
    ...  Verify the operational state of each cell to be Enabled.
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 18.03.2021 - https://jira3.int.net.nokia.com/browse/TAT-21051 - Initial TAT creation
    ...  - 20.10.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22067 - Adapt WebEM TCs for CNI-61110
    ...  - 25.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24131 - Refactor TCs with best practice
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Add watchdog alarm monitoring

    Set Tags    CA-WebEM    OWNER-george.gheban@nokia.com    AUTHOR-cosmina.rebenciuc@nokia.com
    ...    MAINTAINER-andreea.burtic@nokia.com    GROUP_IN_CHARGE-TIM_3_Vrf    PHASE-CRT    SW-SBTS21B

    Step1:Verify cells on SBTS
    Step2:NR RAT Reset and verify status cells
    Step3:LTE RAT Reset and verify status cells
    Step4:WCDMA RAT Reset and verify status cells
    Step5:GSM RAT Reset and verify status cells


Step1:Verify cells on SBTS
    Log  Step1:Verify cells on SBTS  console=true
    Check all cells from WebEM

Step${id}:${RAT} RAT Reset and verify status cells
    Log  Step${id}:${RAT} RAT Reset and verify status cells  console=true
    RAT Reset  ${RAT}
    Wait until keyword succeeds  240s  5s  Check ${RAT} cells operational state to be Disabled|disabled
    Verify States for Cells in Unaffected RATs  ${RAT}
    Log  Waiting for cells to be enabled.  console=true
    Wait until keyword succeeds  360s  5s  Check ${RAT} cells operational state to be Enabled|enabled

Check ${technology} cells operational state to be ${state}
    ${cells_status}  Get States for Cells in RAT  ${technology}
    FOR  ${cell}  IN  @{cells_status.keys()}
        Should match regexp  ${cells_status}[${cell}][Operational state]  ${state}
    END

TC Setup
    Common test setup  tc_name=WebEM__5G_RAT_reset
    WebEM Setup

TC Teardown
    WebEM Teardown
    Common test teardown



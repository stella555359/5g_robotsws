*** Settings ***
Documentation
    ...  This test case is created to Block and Unblock NR,LTE,WCDMA,GSM RATs.
    ...  Verify if all cells on SBTS are working.
    ...  Block on 5G RAT will be performed.
    ...  Verify if the 5G cells have the parameter 'Blocking State'-'Blocked'.
    ...  Check if alarm '4614' is visible.
    ...  Unblock on 5G RAT will be performed.
    ...  Verify if the 5G cells have the parameter 'Blocking State'-'Unblocked'.
    ...  Check if alarm '4614' is cleared.
    ...  All the above steps are repeated for LTE,WCDMA and GSM.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Keywords ***
TC__WebEM__5G_RAT_Block_Unblock
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-21050
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 18.03.2021 - https://jira3.int.net.nokia.com/browse/TAT-21050 - Initial TAT creation
    ...  - 25.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24131 - Refactor TCs with best practice
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Add watchdog alarm monitoring

    Set Tags  CA-WebEM  OWNER-george.gheban@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-cosmina.rebenciuc@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS21B

    Step1:Verify Cells On SBTS
    Step2:NR RAT Block And Verify Cells On The Blocked RAT
    Step3:NR RAT Unblock And Verify Cells On The Unblocked RAT
    Step4:LTE RAT Block And Verify Cells On The Blocked RAT
    Step5:LTE RAT Unblock And Verify Cells On The Unblocked RAT
    Step6:WCDMA RAT Block And Verify Cells On The Blocked RAT
    Step7:WCDMA RAT Unblock And Verify Cells On The Unblocked RAT
    Step8:GSM RAT Block And Verify Cells On The Blocked RAT
    Step9:GSM RAT Unblock And Verify Cells On The Unblocked RAT


Step1:Verify Cells On SBTS
    Log  Step1:Verify cells on SBTS  console=true
    Check All Cells From WebEM


Step${id}:${rat} RAT Block And Verify Cells On The Blocked RAT
    Log  Step${id}:${rat} RAT Block and verify cells on the blocked RAT  console=true
    RAT Block  ${rat}
    Wait Until Keyword Succeeds  180s  5s
    ...  Check ${rat} Cells Blocking State To Be Blocked
    Check RAT Block Alarm Is Visible


Step${id}:${rat} RAT Unblock And Verify Cells On The Unblocked RAT
    Log  Step${id}:${rat} RAT Unblock and verify cells on the unblocked RAT  console=true
    RAT Unblock  ${rat}
    Wait Until Keyword Succeeds  180s  5s
    ...  Check ${rat} Cells Blocking State To Be Unblocked
    Check RAT Block Alarm Is Not Visible


Check ${technology} Cells Blocking State To Be ${state}
    ${cells_status}  Get States For Cells In RAT  ${technology}
    FOR  ${cell}  IN  @{cells_status.keys()}
        Should Be Equal  ${cells_status}[${cell}][Blocking state]  ${state}
    END


Check RAT Block Alarm Is Visible
    ${active_alarm}  Get Active Alarms From WebEM
    Dictionary Should Contain Key  ${active_alarm}  4614  msg=Alarm is not found.
    Go To Site View


Check RAT Block Alarm Is Not Visible
    ${active_alarm}  Get Active Alarms From WebEM
    Dictionary Should Not Contain Key  ${active_alarm}  4614  msg=Alarm is not cleared.
    Go To Site View


TC Setup
    Common Test Setup  tc_name=WebEM__5G_RAT_Block_Unblock
    WebEM Setup


TC Teardown
    WebEM Teardown
    Common Test Teardown

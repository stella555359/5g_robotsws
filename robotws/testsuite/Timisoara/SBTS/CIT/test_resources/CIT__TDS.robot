*** Settings ***
Documentation
    ...  In Step1: Reset to TDS (test dedicated state)
    ...  In Step2: Perform site reset

Resource  ../../common_resources/ca_CIT_general.robot


*** Variables ***
${STARTUP_TIMEOUT}  600  # Timeout for SBTS to recover after site reset


*** Keywords ***
TC__CIT__TDS
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25007
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 25.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25007 - Test creation
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Add watchdog alarm monitoring

    Set Tags  CA-CIT  AUTHOR-iasmin.tomici@nokia.com  OWNER-edwin-marius.macra@nokia.com  MAINTAINER-iasmin.tomici@nokia.com
    ...  GROUP_IN_CHARGE-TIM_2_Vrf  PHASE-CIT

    Step1: Reset To TDS
    Step2: Perform Site Reset


Step1: Reset To TDS
    Reset To Test Dedicated


Step2: Perform Site Reset
    Log  Step2: Perform site reset.  console=true
    coam.Reset Site  ${STARTUP_TIMEOUT}
    ${status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  20
    ...  Admin Check All Required State
    Run Keyword If  ${status}
    ...  Log  Site reached on air state after performing site reset.  console=true
    ...  ELSE
    ...  Fail  Site didn't manage to reach on air state after site reset.


TC Setup
    Common Test Setup  tc_name=CIT__TDS


TC Teardown
    Common Test Teardown

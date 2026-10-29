*** Settings ***
Resource   ../../common_resources/ca_CIT_general.robot

*** Variables ***

${BBMOD_DIST_NAME}              # BBmod distname must be provided ex:MRBTS-10719/EQM-1/APEQM-1/CABINET-1/BBMOD-1
${RECOVERY_TIMEOUT}        600  # timeout in seconds for waiting until cells reach expected states

*** Keywords ***
TC__CIT__Lock_Unlock_BBMOD
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25004
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  In Step1: Perform bbmod lock -Set Bbmod administrativeState parameter on Locked
    ...  In Step2: Perform bbmod unlock -Set Bbmod administrativeState parameter on Unlocked
    ...  In Step3: Verify all cells are onair
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...   16.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25004 - Test creation


    Set Tags    CA-CIT    AUTHOR-iasmin.tomici@nokia.com    OWNER-edwin-marius.macra@nokia.com
    ...    MAINTAINER-iasmin.tomici@nokia.com    GROUP_IN_CHARGE-TIM_2_Vrf    PHASE-CIT

    Step1: Lock BBmod
    Step2: Unlock BBMOD
    Step3: Verify all cells are onair


Step1: Lock BBmod
    Log  Step1: Set Bbmod administrativeState parameter on Locked  console=${TRUE}
    Change parameter value  Locked  administrativeState  ${BBMOD_DIST_NAME}

Step2: Unlock BBMOD
    Log  Step2: Set Bbmod administrativeState parameter on Unlocked  console=${TRUE}
    Change parameter value  Unlocked  administrativeState  ${BBMOD_DIST_NAME}

Step3: Verify all cells are onair
    Log  Step3: Check cells states after parameter change  console=${TRUE}
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT} sec  10 sec  Check All Cells  ${OnAirDone_}  ${Enabled_}  ${Active_}


Change parameter value
    [Documentation]
    ...  This keyword change the value of the given parameter , the parameter is given by the object dist_name
    [Arguments]   ${value}  ${parameter_name}  ${obj_dist_name}
    coam.Perform Parameter Recommissioning    ${obj_dist_name}    ${parameter_name}  update   ${value}
    ...     skip_parameter_relation_errors=True  should_activate=True  timeout=300
    Log    ${parameter_name} will be changed to ${value}   console=yes

TC Setup
    Common Test Setup

TC Teardown
    Common Test Teardown

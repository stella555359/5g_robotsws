*** Settings ***
Resource   ../../common_resources/ca_CIT_general.robot

*** Variables ***
${BBMOD_SERIAL_NUMBER}                                                        # Serial number for BBMOD, Mandatory ABIA model must be given
${BBMOD_TYPE}              ABIA                                               # BBMOD TYPE - always ABIA
${RECOVERY_TIMEOUT}        600                                                # Timeout in seconds for waiting until cells reach expected states

*** Keywords ***
TC__CIT__useFullCapacity_parameter_change
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25003
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  In Step1: Choose BBMOD - ABIA only (random ABIA BBMOD if SN is not given, or specific one)
    ...  In Step2: Set BBMOD useFullCapacity parameter on false
    ...  In Step3: Verify alarm
    ...  In Step4: Set BBMOD useFullCapacity parameter back to true
    ...  In Step5: Verify all cells are onair
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 10.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25003 - Test creation
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Add watchdog alarm monitoring


    Set Tags    CA-CIT    OWNER-iasmin.tomici@nokia.com
    ...    MAINTAINER-iasmin.tomici@nokia.com    GROUP_IN_CHARGE-TIM_2_Vrf    PHASE-CIT

    Step1: Choose BBMOD ABIA only
    Step2: Set BBMOD useFullCapacity parameter on false
    Step3: Verify alarm
    Step4: Set BBMOD useFullCapacity parameter back to true
    Step5: Verify all cells are onair


Step1: Choose BBMOD ABIA only
    Log  Step1: Choose BBMOD ABIA only  console=${TRUE}
    ${bbmod_dn}  Run keyword if  '${BBMOD_SERIAL_NUMBER}'=='${EMPTY}'
    ...  Get random BBMOD
    ...  ELSE
    ...  Get specific BBMOD
    Set Test Variable  ${BBMOD_DIST_NAME}  ${bbmod_dn}

Step2: Set BBMOD useFullCapacity parameter on false
    Log  Step2: Set BBMOD useFullCapacity parameter on false  console=${TRUE}
    Change parameter useFullCapacity value  false  useFullCapacity

Step3: Verify alarm
    Log  Step3: Verify alarm  console=${TRUE}
    Check alarm status in WebEM  active
    ...                          ${FAULT_1868}[fault_id]
    ...                          ${FAULT_1868}[fault_name]
    ...                          ${FAULT_1868}[alarm_id]
    ...                          ${FAULT_1868}[alarm_name]
    ...                          ${FAULT_1868}[severity]

Step4: Set BBMOD useFullCapacity parameter back to true
    Log  Step4: Set BBMOD useFullCapacity parameter back to true  console=${TRUE}
    Change parameter useFullCapacity value  true  useFullCapacity

Step5: Verify all cells are onair
    Log  Step5: Check alarm and cells states after parameter change  console=${TRUE}
    Check alarm status in WebEM  inactive
    ...                          ${FAULT_1868}[fault_id]
    ...                          ${FAULT_1868}[fault_name]
    ...                          ${FAULT_1868}[alarm_id]
    ...                          ${FAULT_1868}[alarm_name]
    ...                          ${FAULT_1868}[severity]
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT} sec  10 sec  Check All Cells  ${OnAirDone_}  ${Enabled_}  ${Active_}


Get random BBMOD
    ${bbmod_objects}  Get fbb info
    ${bbmod_list}  Create list
    FOR  ${bbmod_object}  IN  @{bbmod_objects}
         ${status}  Run keyword and return status  Should contain  ${bbmod_object}[productName]  ${BBMOD_TYPE}
         Run keyword if  ${status}
         ...  Append to list  ${bbmod_list}  ${bbmod_object}
    END
    ${bbmod_list_length}  Get length  ${bbmod_list}
    ${random_bbmod_object}  Run keyword if  ${bbmod_list_length}==1
    ...  Set variable  ${bbmod_list}[0]
    ...  ELSE  Evaluate  random.choice(${bbmod_list})  random
    [Return]  ${random_bbmod_object}[id][configuration]

Get specific BBMOD
    ${BBMOD_ALL_INFO}  Get fbb info
    FOR  ${bbmod}  IN  @{BBMOD_ALL_INFO}
      ${bbmod_sn}  Get from dictionary  ${bbmod}   serialNumber   #productName == ABIA
      Run keyword if  '${bbmod_sn}'=='${BBMOD_SERIAL_NUMBER}'
      ...  Return from keyword  ${bbmod}[id][configuration]
      ...  ELSE
      ...  Continue for loop
    END

Change parameter useFullCapacity value
    [Documentation]
    ...  This keyword verifies if specific parameter has the desired value, if not, value is updated.
    [Arguments]   ${value}  ${parameter_name}
    Run Keywords  coam.Perform Parameter Recommissioning    ${BBMOD_DIST_NAME}    ${parameter_name}  update   ${value}
    ...     skip_parameter_relation_errors=True  should_activate=True  timeout=300  AND
    ...     Log    ${parameter_name} will be changed to ${value}   console=yes

TC Setup
    Common Test Setup  tc_name=CIT__useFullCapacity_parameter_change

TC Teardown
    Common Test Teardown

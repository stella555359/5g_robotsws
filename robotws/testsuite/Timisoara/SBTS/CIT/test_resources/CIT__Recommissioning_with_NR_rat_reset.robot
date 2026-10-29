*** Settings ***
Documentation
    ...  In Step1: Set actBeamControlImprovement1 parameter on true
    ...  In Step2: Verify all cells are onair
    ...  In Step3: Set actBeamControlImprovement1 parameter back to false
    ...  In Step4: Verify all cells are onair

Resource  ../../common_resources/ca_CIT_general.robot


*** Variables ***
${ACT_BEAM_CONTROL_IMPROVEMENT1_DIST_NAME}  ${EMPTY}  # actBeamControlImprovement1 parameter dist name must be given
${RECOVERY_TIMEOUT}  600  # Timeout in seconds for waiting until cells reach expected states


*** Keywords ***
TC__CIT__Recommissioning_with_NR_rat_reset
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-24999
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...   29.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24999 - Test creation

    Set Tags  CA-CIT  AUTHOR-iasmin.tomici@nokia.com  OWNER-edwin-marius.macra@nokia.com  MAINTAINER-iasmin.tomici@nokia.com
    ...  GROUP_IN_CHARGE-TIM_2_Vrf  PHASE-CIT

    Step1: Set ActBeamControlImprovement1 Parameter On True
    Step2: Verify All Cells Are Onair
    Step3: Set ActBeamControlImprovement1 Parameter Back To False
    Step4: Verify All Cells Are Onair


Step1: Set ActBeamControlImprovement1 Parameter On True
    Log  Step1: Set actBeamControlImprovement1 parameter on true  console=true
    Change Parameter ActBeamControlImprovement1 Value  true  actBeamControlImprovement1
    ${status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  300  4
    ...  coam.Assert Any  NRCEL  availabilityStatus=${FAILED}


Step2: Verify All Cells Are Onair
    Log  Step2: Check alarm and cells states after parameter change  console=true
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT} sec  10 sec
    ...  Check All Cells


Step3: Set ActBeamControlImprovement1 Parameter Back To False
    Log  Step3: Set actBeamControlImprovement1 parameter back to false  console=true
    Change Parameter ActBeamControlImprovement1 Value  false  actBeamControlImprovement1


Step4: Verify All Cells Are Onair
    Log  Step5: Check alarm and cells states after parameter change  console=true
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT} sec  10 sec
    ...  Check All Cells


Change Parameter ActBeamControlImprovement1 Value
    [Arguments]  ${value}  ${parameter_name}

    coam.Perform Parameter Recommissioning  ${ACT_BEAM_CONTROL_IMPROVEMENT1_DIST_NAME}  ${parameter_name}  update  ${value}
    ...  skip_parameter_relation_errors=True  should_activate=True  timeout=300
    Log  ${parameter_name} will be changed to ${value}  console=true


TC Setup
    Common Test Setup


TC Teardown
    Common Test Teardown

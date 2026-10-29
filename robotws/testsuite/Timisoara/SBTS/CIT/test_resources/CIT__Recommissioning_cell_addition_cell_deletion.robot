*** Settings ***
Documentation
    ...  In Step1: Recommision with cell addition
    ...  In Step2: Recommision with cell deletion

Resource  ../../common_resources/ca_CIT_general.robot


*** Variables ***
${SCF_FILE}  ${EMPTY}  # SCF path
${SCF_FILE_CELL_ADDED}  ${EMPTY}  # path of the SCF with added cell
${RECOVERY_TIMEOUT}  600  # timeout in seconds for waiting until cells reach expected states


*** Keywords ***
TC__CIT__Recommissioning_cell_addition_cell_deletion
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25006
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...   19.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25005 - Test creation

    Set Tags  CA-CIT  AUTHOR-iasmin.tomici@nokia.com  OWNER-edwin-marius.macra@nokia.com  MAINTAINER-iasmin.tomici@nokia.com
    ...  GROUP_IN_CHARGE-TIM_2_Vrf  PHASE-CIT

    Step1 Recommision With Cell Addition
    Step2 Recommision With Cell Deletion


Step1 Recommision With Cell Addition
    ${bts_id}  Admin Get BTS Id
    Set Test Variable  ${BTS_ID}
    coam.Perform Commissioning  ${BTS_ID}  ${SCF_FILE_CELL_ADDED}  skip_parameter_relation_errors=True
    Verify All Cells Are Onair


Step2 Recommision With Cell Deletion
    coam.Perform Commissioning  ${BTS_ID}  ${SCF_FILE}  skip_parameter_relation_errors=True
    Verify All Cells Are Onair


Verify All Cells Are Onair
    Log  Check cells states after commissioning  console=true
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT} sec  10 sec
    ...  Check All Cells


TC Setup
    Common Test Setup


TC Teardown
    Common Test Teardown

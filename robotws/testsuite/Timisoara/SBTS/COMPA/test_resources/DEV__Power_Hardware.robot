*** Settings ***
Documentation
    ...  Step 1: Set Proper Apc States

Resource  ../../common_resources/ca_CIT_general.robot


*** Variables ***
${HW_OFF_ID_LIST}  ${EMPTY}  # module names as defined in interfaces.yaml. Modules shall be separated by comas (eg. SMOD_K11232234,RMOD_L11232234)
# undefined names that are in interfaces.yaml will be turned ON
${TIMEOUT}  ${EMPTY}  # Declare timeout in sec to stabilize HW after power management; Optional parameter.


*** Keywords ***
TC__DEV__Power_Hardware
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-8137
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 22.02.2018 - https://jira3.int.net.nokia.com/browse/TAT-8890 - initial creation
    ...  - 07.11.2019 - https://jira3.int.net.nokia.com/browse/TAT-18143 - add TIMEOUT and avoid failing TC when whole HW declared is going to be off
    ...  - 30.08.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21764 - [CNI-61110] STATE TCs alignment
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Add watchdog alarm monitoring

    Set Tags  CA-STATE  OWNER-wojciech.sikora@nokia.com  AUTHOR-jacek.mnich@nokia.com  MAINTAINER-daniel.bartkowiak@nokia.com  PHASE-CRT  PHASE-COMPA
    ...  SW-N/A

    Step 1: Set Proper Apc States


Step 1: Set Proper Apc States
    Log  Step1: Power off BTS  console=true
    @{hw_off_id_list}  Split String  ${HW_OFF_ID_LIST}  ,
    @{hw_on_id_list}  Get Dictionary Keys  ${INTERFACES}
    Run Keyword If  '${hw_off_id_list}[0]'!=''
    ...  Run Keywords
    ...  List Should Contain Sub List  ${hw_on_id_list}  ${hw_off_id_list}
    ...  AND
    ...  Remove Values From List  ${hw_on_id_list}  @{hw_off_id_list}
    ...  AND
    ...  Log  ${hw_on_id_list}  console= ${True}
    ...  AND
    ...  State Change If Needed  ${hw_off_id_list}  Off
    ${number}  Get Length  ${hw_on_id_list}
    Run Keyword If  ${number}
    ...  State Change If Needed  ${hw_on_id_list}  On
    Run Keyword If  "${TIMEOUT}"!=""
    ...  Run Keywords
    ...  Log  Waiting ${TIMEOUT}s untill HW stabilizes  console=true
    ...  AND
    ...  Sleep  ${TIMEOUT}s


State Change If Needed
    [Arguments]  ${hw_id_list}  ${pdu_target_state}

    FOR  ${hw_id}  IN  @{hw_id_list}
        ${hw_state}  Pdu BTS Interface Get Status  ${hw_id}
        ${hw_target_state}  Set Variable If  '${pdu_target_state}'=='On'  on  off
        Run Keyword If  '${hw_state}'!='${hw_target_state}'
        ...  Change Pdu State And Check Status  ${hw_id}  ${pdu_target_state}
        ...  ELSE
        ...  Log  ${hw_id} status already correct: ${hw_state}  console=true
    END


Change Pdu State And Check Status
    [Arguments]  ${hw_id}  ${interface_state}  # state value should be: On/Off

    Log  Turn Pdu ${interface_state} And Check Status for: ${hw_id}  console=true
    Run Keyword If  '${interface_state}'=='Off'
    ...  Pdu BTS Interface Off  ${hw_id}
    ...  ELSE
    ...  Pdu BTS Interface On  ${hw_id}
    Sleep  1
    ${hw_status}  Pdu BTS Interface Get Status  ${hw_id}
    Log  hw_status after ${interface_state} operation: ${hw_status}  console= ${True}


TC Setup
    Common Test Setup  modules_check=${FALSE}  cells_check=${FALSE}  alarms_check=${FALSE}  admin_launch=${FALSE}  infomodel_launch=${FALSE}
    ...  tc_name=DEV__Power_Hardware


TC Teardown
    Common Test Teardown  collect_snapshot=never

*** Settings ***
Documentation
...  TC for power on/off proper HW for TC

Resource    ../../../../resources/hran_frame_sbts_siso.robot
Resource    ../../../../resources/ca_siso_hran.robot

*** Variables ***
${HW_OFF_ID_LIST}=      #module names as defined in interfaces.yaml. Modules shall be separated by comas (eg. SMOD_K11232234,RMOD_L11232234)
                        #undefined names that are in interfaces.yaml will be turned ON
${TIMEOUT}=             #Declare timeout in sec to stabilize HW after power management; Optional parameter.


*** Keywords ***
TC__DEV__Power_Hardware
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-8137
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Step 1: Set Proper Apc States
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 22.02.2018 - https://jira3.int.net.nokia.com/browse/TAT-8890 - initial creation
    ...  - 07.11.2019 - https://jira3.int.net.nokia.com/browse/TAT-18143 - add TIMEOUT and avoid failing TC when whole HW declared in INTERFACES is
    ...  going to be off
    ...  - 30.08.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21764 - [CNI-61110] STATE TCs alignment
    ...  - 01-09-2022 - https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-12197 - migration hran_ta to robotws


    Set Tags    CA-STATE    OWNER-wojciech.sikora@nokia.com    AUTHOR-jacek.mnich@nokia.com
    ...    MAINTAINER-daniel.bartkowiak@nokia.com    PHASE-CRT    PHASE-COMPA    SW-N/A

    Step 1: Set Proper Apc States

Step 1: Set Proper Apc States
    Log  Step1: Power off BTS  console=${True}
    @{hw_off_id_list}  Split String  ${HW_OFF_ID_LIST}  ,
    @{hw_on_id_list}  Get dictionary keys  ${INTERFACES}
    Run Keyword If  '@{hw_off_id_list}[0]'!=''  Run Keywords
    ...  List should contain sub list  ${hw_on_id_list}  ${hw_off_id_list}  AND
    ...  Remove values from list  ${hw_on_id_list}  @{hw_off_id_list}       AND
    ...  Log  ${hw_on_id_list}  console= ${True}                            AND
    ...  State change if needed  ${hw_off_id_list}  Off
    ${number}  Get Length  ${hw_on_id_list}
    Run Keyword If  ${number}    State change if needed  ${hw_on_id_list}   On
    Run Keyword If  "${TIMEOUT}"!=""   Run Keywords  Log  Waiting ${TIMEOUT}s untill HW stabilizes  console=${True}  AND  Sleep  ${TIMEOUT}s

State change if needed
    [Arguments]  ${hw_id_list}  ${pdu_target_state}
    FOR  ${hw_id}  IN  @{hw_id_list}
      ${hw_state}  Get Pdu Port Status TAF  ${hw_id}
      ${hw_target_state}  Set Variable If  '${pdu_target_state}'=='On'  on  off
      Run Keyword If  '${hw_state}'!='${hw_target_state}'  Change Pdu State And Check Status  ${hw_id}  ${pdu_target_state}
      ...  ELSE  Log  ${hw_id} status already correct: ${hw_state}  console=${True}
    END

Change Pdu State And Check Status
    [Arguments]  ${hw_id}  ${interface_state}  #state value should be: On/Off
    Log  Turn Pdu ${interface_state} And Check Status for: ${hw_id}  console=${True}
    Run Keyword If  '${interface_state}'=='Off'  Turn Off Pdu Interface  ${hw_id}
    ...  ELSE  Turn On Pdu Interface  ${hw_id}
    Sleep  1
    ${hw_status}  Get Pdu Port Status TAF  ${hw_id}
    Log  hw_status after ${interface_state} operation: ${hw_status}  console= ${True}

TC Setup
    Common Test Setup    modules_check=${FALSE}    cells_check=${FALSE}    alarms_check=${FALSE}    admin_launch=${FALSE}    infomodel_launch=${FALSE}
    ...    enable_truck_roll=${False}

TC Teardown
    Common Test Teardown    collect_snapshot=never    enable_truck_roll=${False}

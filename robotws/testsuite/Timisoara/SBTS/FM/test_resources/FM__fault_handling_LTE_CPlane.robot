*** Settings ***
Documentation
    ...  In this TC LTE C-Plane fault is being tested.
    ...  It will be triggered by performing delta recommissioning of LNADJW and LNBTS related parameters.
    ...  Tested fault is checked against alarm details

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${COMMISSIONING_STATE}  ${FALSE}
# ${FALSE} or ${TRUE}. The value is used in Check If Recommissioning Was Done KW to apply recommissioning when the test fails.


*** Keywords ***
TC__FM__fault_handling_LTE_CPlane
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-14566
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 27.05.2019 - https://jira3.ext.net.nokia.com/browse/TAT-14566 - Initial TAT creation
    ...  - 28.08.2020 - https://jira3.ext.net.nokia.com/browse/TAT-20119 - Variable status6323 not found
    ...  - 10.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  - 17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  - 25.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25417 - Use Admin Get MRBTS ID and Admin Get LNBTS ID from sbts_admin
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  *******************

    Set Tags  CA-FM  OWNER-laura.craciunel@nokia.com  AUTHOR-pawel.korniak@nokia.com  MAINTAINER-laura.craciunel@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf
    ...  PHASE-CRT  SW-SBTS19A  SW-SBTS19  FEATURE-RP001534

    Step 1: Check All Required States
    Step 2: Create Delta And Trigger Fault 6323
    Step 3: Verify Fault 6323
    Step 4: Return Commissioning To Original State
    Step 5: Verify Alarm Cancellation


Step 1: Check All Required States
    [Documentation]  In this step specific states will be checked.

    Log  \nStep 1: Check All Required States.  console=true
    Check Commissioned Technologies  LTE
    Wait Until Keyword Succeeds  600 sec  65 sec
    ...  Check All Cells


Step 2: Create Delta And Trigger Fault 6323
    [Documentation]  In this step delta will be created and fault 6323 triggered.

    Log  \nStep 2: Create Delta And Trigger Fault 6323  console=true

    Log  Get MRBTS and LNBTS ID's...  console=true
    ${mrbts}  Admin Get BTS ID
    ${lnbts}  Admin Get LNBTS ID
    Set Test Variable  ${MRBTS}
    Set Test Variable  ${LNBTS}
    Log  MRBTS ID: ${MRBTS}; LNBTS ID: ${LNBTS}  console=true

    Log  Random LTE cell will be chosen to perform parameter recommissioning on it...  console=true
    @{lncel_ids}  Get Ids For All  LNCEL
    Log  ${lncel_ids}  console=true
    ${all_ids}  Create List  @{EMPTY}
    FOR  ${id}  IN  @{lncel_ids}
        ${string}  ${single_lncel_id}  Split String From Right  ${id}  separator=/LNCEL_R-  max_split=1
        Append To List  ${all_ids}  ${single_lncel_id}
    END

    ${final_lncel_id}  Evaluate  random.choice(${all_ids})  modules=random
    Set Test Variable  ${FINAL_LNCEL_ID}
    Log  Random LNCEL selected: LNCEL-${FINAL_LNCEL_ID}  console=true

    Log  Delta will be created...  console=true
    ${delta_id}  Set Variable  1
    Create Delta  ${delta_id}

    Log  Appending MOC and parameter updates to delta...  console=true
    Append Managed Object To Delta  MRBTS-${MRBTS}/LNBTS-${LNBTS}/LNADJW-1  create  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${MRBTS}/LNBTS-${LNBTS}/LNADJW-1  lnAdjWId  1  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${MRBTS}/LNBTS-${LNBTS}/LNADJW-1  srvccHoInd  PSandCS  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${MRBTS}/LNBTS-${LNBTS}/LNADJW-1  uTargetCid  1  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${MRBTS}/LNBTS-${LNBTS}/LNADJW-1  uTargetFreq  1  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${MRBTS}/LNBTS-${LNBTS}/LNADJW-1  uTargetLac  1  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${MRBTS}/LNBTS-${LNBTS}/LNADJW-1  uTargetRac  1  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${MRBTS}/LNBTS-${LNBTS}/LNADJW-1  uTargetRncId  1  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${MRBTS}/LNBTS-${LNBTS}/LNADJW-1  uTargetScFdd  1  ${delta_id}

    ${plmn_parameters_dict}  Create Dictionary
    Set To Dictionary  ${plmn_parameters_dict}  mcc  211
    Set To Dictionary  ${plmn_parameters_dict}  mnc  11
    Set To Dictionary  ${plmn_parameters_dict}  mncLength  2

    Append Complex Item To Delta  MRBTS-${MRBTS}/LNBTS-${LNBTS}/LNADJW-1  list_name=primaryPlmnId  &{plmn_parameters_dict}  delta_id=${delta_id}

    Append Parameter Update To Delta  MRBTS-${MRBTS}/LNBTS-${LNBTS}  actRIMforUTRAN  true  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${MRBTS}/LNBTS-${LNBTS}/LNCEL-${FINAL_LNCEL_ID}/REDRT-0  addUtranSIToRedirMsg  both  ${delta_id}

    Get Delta  ${delta_id}
    Save Delta  ${BTS_FILES}/delta.json  delta_id=${delta_id}
    Log  Performing delta recommissioning...  console=true
    ${commissioning_state}  Run Keyword And Return Status
    ...  coam.Perform Delta Recommissioning  ${BTS_FILES}/delta.json  skip_parameter_relation_errors=True
    Set Test Variable  ${COMMISSIONING_STATE}
    Remove Delta  ${delta_id}


Step 3: Verify Fault 6323
    [Documentation]  In this step, alarm with fault 6323 will be verified against reasoning status, reported severity and impact on cells.

    Log  \nStep 3: Verify fault 6323  console=true
    Check All Cells
    ${fault_6323_params}  Get String With Alarm Parameters  ${FAULT_6323_RIM_ERROR}
    Assert Alarm Active  parameters=${fault_6323_params}  timeout=60
    Log  Fault 6323 "${FAULT_6323_RIM_ERROR}[fault_name]" occurred.  console=true

    Log  Reasoning status will be checked...  console=true
    ${lnadjw_params}  Convert To String  /MRBTS-1/RAT-1/LTS-1/LNBTS_L-1/LNADJW_L-1
    ${lnabla}  Query Infomodel  get object ${lnadjw_params}
    ${reas_status}  Get From List  ${lnabla.stateInfo.reasoningStatus}  0
    ${list_values_reas_status}  Create List  RimInterfaceError  UtraSiOtherUnspecifiedError  UtraSiSyntaxErrorInTheApplicationContainer
    ...  UtraSiReportingCellIdentifierMismatched
    ${status}  Run Keyword And Return Status
    ...  Should Contain  ${list_values_reas_status}  ${reas_status}
    Run Keyword If  ${status}
    ...  Log  Reasoning status is correctly set to ${reas_status}  console=true
    ...  ELSE
    ...  Set Test Restriction  message=Reasoning status is different than expected [NOK]

    Admin Check Active Alarms TAF


Step 4: Return Commissioning To Original State
    [Documentation]  In this step, commissioning will be reverted to original state to clear alarm with fault 6323.

    Log  \nStep 4: Return commissioning to original state  console=true
    ${delta_id_2}  Set Variable  1
    Create Delta  ${delta_id_2}
    Append Managed Object To Delta  MRBTS-${MRBTS}/LNBTS-${LNBTS}/LNADJW-1  delete  ${delta_id_2}
    Append Parameter Update To Delta  MRBTS-${MRBTS}/LNBTS-${LNBTS}  actRIMforUTRAN  false  ${delta_id_2}
    Append Parameter Delete To Delta  MRBTS-${MRBTS}/LNBTS-${LNBTS}/LNCEL-${FINAL_LNCEL_ID}/REDRT-0  addUtranSIToRedirMsg  ${delta_id_2}
    Get Delta  ${delta_id_2}
    Save Delta  ${BTS_FILES}/delta2.json  delta_id=${delta_id_2}
    Log  Performing delta recommissioning...  console=true
    coam.Perform Delta Recommissioning  ${BTS_FILES}/delta2.json  skip_parameter_relation_errors=True
    ${commissioning_state}  Set Variable  ${FALSE}
    Set Test Variable  ${COMMISSIONING_STATE}


Step 5: Verify Alarm Cancellation
    [Documentation]  In this step, it will be verified if all cells remained unaffected and if alarm with fault 6323 was moved to Alarm History.

    Log  \nStep 5: Verify Alarm Cancellation  console=true
    Check All Cells
    ${fault_6323_params}  Get String With Alarm Parameters  ${FAULT_6323_RIM_ERROR}
    Assert Alarm Inactive  parameters=${fault_6323_params}  timeout=60
    ${historical_alarms}  Get_historic_alarms  load_history=True  timeout=120
    FOR  ${element}  IN  @{historical_alarms}
        ${status6323}  Run Keyword And Return Status
        ...  Should Be Equal As Integers  ${element}[faultId]  6323
        Exit For Loop If  ${status6323}
    END
    Should Be True  ${status6323}  Alarm "${FAULT_6323_RIM_ERROR}[fault_name]" is not visible in historical alarms. [NOK]
    Log  "${FAULT_6323_RIM_ERROR}[fault_name]" is visible in historical alarms. [OK]  console=true


Check If Recommissioning Was Done
    [Documentation]  This KW is created to ensure recommissioning is performed when the test fails.

    Log  Check If Recommissioning Was Done...  console=true
    Run Keyword If  ${COMMISSIONING_STATE}
    ...  Step 4: Return Commissioning To Original State


TC Setup
    Common Test Setup  tc_name=FM__fault_handling_LTE_CPlane


TC Teardown
    Run Keywords
    ...  Check If Recommissioning Was Done
    ...  AND
    ...  Common Test Teardown

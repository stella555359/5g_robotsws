*** Settings ***
Documentation
    ...  This test case was created to trigger fault 181. It first checks whether the SBTS has 2 WCDMA LCGs.
    ...  After that, it deletes one of the LCGs and moves the WCDMA cells to the other. It checks for the 181 fault.
    ...  The test recreates the deleted WCDMA cells and waits for the alarm to clear.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${RECOMMISSIONING_TIMEOUT}  300s  # Time until delta recommissioning retries stop and test fails
${WCDMA_TIMEOUT}  300s  # Time for WCDMA cells to become available after fault is cleared


*** Keywords ***
TC__FM__Trigger_and_clear_fault_181
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-21391
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 24.05.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21391 - Initial TAT Creation
    ...  - 20.10.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22067 - Adapt WebEM TCs for CNI-61110
    ...  - 10.01.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22464 - Fix operational state for WCDMA cells
    ...  - 03.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23827 - Add timeout for Assert Alarm Active KW
    ...  - 17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  - 05.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27298 - Add fault for watchdog monitoring

    Set Tags  CA-FM  OWNER-laura.craciunel@nokia.com  AUTHOR-vlad.slivilescu@nokia.com  MAINTAINER-vlad.slivilescu@nokia.com
    ...  GROUP_IN_CHARGE-TIM_4_VRF  PHASE-CRT  SW-SBTS22R1  FEATURE-RP002125-K

    Step 1: Check SBTS Configuration
    Step 2: Modify WCDMA LCGs And Wait For Fault To Trigger
    Step 3: Modify WCDMA LCGs And Wait For Fault To Clear


Step 1: Check SBTS Configuration
    [Documentation]  Check for SBTS configuration with radio module connected to BBMOD-1.
    ...  2 WCDMA LCG should exist.

    Log  Step 1: Check SBTS Configuration  level=INFO  console=true

    ${wncell_groups}  Query Infomodel  get list //WNCELG_A-*
    ${wncell_groups_length}  Get Length  ${wncell_groups}

    Should Be True  ${wncell_groups_length} >= 2
    ${wncell_groups}  Get Slice From List  ${wncell_groups}  end=2

    ${mrbts_id}  Infomodel Get Objects Parameter  //MRBTS_A-*  btsName
    ${mrbts_id}  Get From List  ${mrbts_id}  0

    ${wnbts_id}  Set Variable  1

    FOR  ${index}  ${wncelg}  IN ENUMERATE  @{wncell_groups}
        ${group_number_regex}  Set Variable  Group (\\d+)
        ${wncelg_id}  Get Regexp Matches  ${wncelg}[cellGroupName]  ${group_number_regex}  1
        ${wncelg_id}  Get From List  ${wncelg_id}  0

        ${smod_im_number_regex}  Set Variable  SMOD_A-(\\d+)
        ${smod_id}  Get Regexp Matches  ${wncelg}[smodDN]  ${smod_im_number_regex}  1
        ${smod_id}  Get From List  ${smod_id}  0

        Run Keyword If  ${index} == 0
        ...  Run Keywords
        ...  Set Test Variable  ${FIRST_WNCELG}  ${wncelg}
        ...  AND
        ...  Set Test Variable  ${FIRST_WNCELG_DIST}  MRBTS-${mrbts_id}/WNBTS-${wnbts_id}/WNCELG-${wncelg_id}

        Run Keyword If  ${index} == 1
        ...  Run Keywords
        ...  Set Test Variable  ${SECOND_WNCELG}  ${wncelg}
        ...  AND
        ...  Set Test Variable  ${SECOND_WNCELG_DIST}  MRBTS-${mrbts_id}/WNBTS-${wnbts_id}/WNCELG-${wncelg_id}
        ...  AND
        ...  Set Test Variable  ${SECOND_WNCELG_SMOD_DN}  MRBTS-${mrbts_id}/EQM-1/APEQM-1/CABINET-1/SMOD-${smod_id}
    END

    ${alarm_parameters}  Get String With Alarm Parameters  ${FAULT_181}
    Set Test Variable  ${ALARM_PARAMETERS}
    Assert Alarm Inactive  ${ALARM_PARAMETERS}

    Log  ${FIRST_WNCELG}  console=true
    Log  ${SECOND_WNCELG}  console=true


Step 2: Modify WCDMA LCGs And Wait For Fault To Trigger
    [Documentation]  Perform delta recommissioning: delete SECOND_WNCELG,
    ...  move cell to FIRST_WNCELG and modify shareOfHSUPACapacity=100 in
    ...  FIRST_LNCELG (Fault 181 should be raised).

    Log  Step 2: Modify WCDMA LCGs and wait for fault to trigger  console=true

    ${all_cells}  Combine Lists  ${FIRST_WNCELG}[wncelIdList]  ${SECOND_WNCELG}[wncelIdList]

    Create Delta
    Append Managed Object To Delta  ${SECOND_WNCELG_DIST}  operation=delete
    Append Parameter Update To Delta  ${FIRST_WNCELG_DIST}  wncelIdList  ${all_cells}
    Append Parameter Update To Delta  ${FIRST_WNCELG_DIST}  shareOfHSUPACapacity  100
    Save Delta

    Perform Delta Recommissioning  delta.json

    Remove Delta
    Assert Alarm Active  ${ALARM_PARAMETERS}  timeout=300


Step 3: Modify WCDMA LCGs And Wait For Fault To Clear
    [Documentation]  Perform delta recommissioning: create SECOND_WNCELG,
    ...  move cell to SECOND_WNCELG and modify shareOfHSUPACapacity=50 in
    ...  FIRST_WNCELG (Fault 181 should clear).

    Log  Step 3: Modify WCDMA LCGs and wait for fault to clear  console=true

    ${second_wncelg_keys}  Get Dictionary Keys  ${SECOND_WNCELG}

    Create Delta
    Append Managed Object To Delta  ${SECOND_WNCELG_DIST}  operation=create

    FOR  ${parameter}  IN  @{second_wncelg_keys}
        Run Keyword If  $SECOND_WNCELG["${parameter}"] is not None and "${parameter}"!="dist_name" and "${parameter}" != "smodDN"
        ...  Append Parameter Update To Delta  ${SECOND_WNCELG_DIST}  ${parameter}  ${SECOND_WNCELG["${parameter}"]}

        Run Keyword If  "${parameter}" == "smodDN"
        ...  Append Parameter Update To Delta  ${SECOND_WNCELG_DIST}  ${parameter}  ${SECOND_WNCELG_SMOD_DN}
    END

    Append Parameter Update To Delta  ${FIRST_WNCELG_DIST}  shareOfHSUPACapacity  50
    Append Parameter Update To Delta  ${FIRST_WNCELG_DIST}  wncelIdList  ${FIRST_WNCELG}[wncelIdList]

    Save Delta

    Wait Until Keyword Succeeds  ${RECOMMISSIONING_TIMEOUT}  30s
    ...  Perform Delta Recommissioning  delta.json
    Assert Alarm Inactive  ${ALARM_PARAMETERS}
    Wait Until Keyword Succeeds  ${WCDMA_TIMEOUT}  10s
    ...  Assert Every  WNCEL  operationalState=${ENABLED}  timeout=60


TC Setup
    Common Test Setup  tc_name=FM__Trigger_and_clear_fault_181


TC Teardown
    Common Test Teardown

*** Settings ***
Documentation
    ...  This test is created to power off and on RMOD with serial number provided by user (RMOD_SN)
    ...  that has 4G and 5G cells deployed on it.
    ...  RMOD is turned off.
    ...  Fault 10 'No connection to unit' must be visible on RMOD. Cells deployed on RMOD can be
    ...  degraded or failed depending on their mapping. If one cell is also mapped on other RMOD,
    ...  its state is degraded. It is failed otherwise.
    ...  Severity for fault 10 is Critical if there is one RMOD failed. If not, severity is Major.
    ...  After the first power off, the automated test should verify that FID:4003 is not present
    ...  in WebEM but it is the object alarm_ in infomodel.
    ...  Power on the radio module.
    ...  After the radio module gets on air, the automated test should create NOTES under MRBTS-xxx/MNL-1 in infomodel,
    ...  and should create NOTE under NOTES with the following 2 parameters: attribName: enableInformativeAlarmReport, attribValue: W9Y3.
    ...  After the second power off minor FID:4003 'Transmission path failure' should be present in WebEM on LTE or NR cells are degraded.
    ...  Power on the RF, BTS reaches on air state, no other unexpected alarms.
    ...  The automated test should delete NOTES under MRBTS-xxx/MNL-1 in infomodel.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${RMOD_SN}  ${EMPTY}  # Mandatory, RMOD with 4G and 5G which needs to be powered off
${FAULT_10_TIMEOUT}  120  # [in seconds] Timeout for fault 10 to be visible
${RECOVERY_TIMEOUT}  600  # [in seconds] Timeout for SBTS to get on air state


*** Keywords ***
TC__FM__RMOD_hide_unhide_FID4003
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-27942
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  26.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27942 - Initial TAT creation
    ...  ******************


    Set Tags  CA-FM  OWNER-florin-sebastian.nedelcu@nokia.com  AUTHOR-cristina.adam@nokia.com  MAINTAINER-cristina.adam@nokia.com
    ...  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS24  FEATURE-CNI-127210


    Step0: Set Testcase Variables
    Step1: Power Off RMOD And Check Fault 10
    Step2: Check Cells On Bts And Fault 4003
    Step3: Power On RMOD And Check Bts To Be On Air
    Step4: Create Object NOTES
    Step5: Power Off RMOD And Check Fault 10
    Step6: Check Cells On Bts And Fault 4003
    Step7: Power On RMOD And Check Bts To Be On Air
    Step8: Delete Object NOTES


Step0: Set Testcase Variables
    Log  \nStep0: Set Testcase Variables  console=true
    Run Keyword If  '${RMOD_SN}'=='${EMPTY}'
    ...  Fail  RMOD serial number must be provided through RMOD_SN variable.
    ${rmod_dn}  Get Module Dist Name By Serial Number And Class  ${RMOD_SN}  RMOD
    Check If LTE And NR Are Deployed On RMOD  ${rmod_dn}
    ${rmod_cells}  Get Cell Mapping By Module Id  ${rmod_dn}
    ${degraded_cells}  ${failed_cells}  ${cells_with_4003}  Get Impacted Cells Expected States  ${rmod_cells}  ${rmod_dn}
    ${lte_splitted_cells}  Create List
    FOR  ${cell_dn}   IN  @{degraded_cells}
      Run Keyword If  'LNCEL' in '${cell_dn}'
      ...  Append To List  ${lte_splitted_cells}  ${cell_dn}
    END
    Set SyncSigTxMode Parameter For LTE  ${lte_splitted_cells}
    ${not_impacted_cells}  Get All Cells On Bts
    Remove values from list  ${not_impacted_cells}  @{rmod_cells}
    ${fault_10_severity}  Get Fault 10 Severity  ${failed_cells}
    ${bts_name}  Get Bts Name
    Set Test Variable  ${RMOD_DN}
    Set Test Variable  ${DEGRADED_CELLS}
    Set Test Variable  ${FAILED_CELLS}
    Set Test Variable  ${CELLS_WITH_4003}
    Set Test Variable  ${NOT_IMPACTED_CELLS}
    Set Test Variable  ${FAULT_10_SEVERITY}
    Set Test Variable  ${BTS_NAME}
    Check NOTES object and delete if exist


Step${index}: Power Off RMOD And Check Fault 10
    Log  \nStep${index}: Power Off RMOD And Check Fault 10  console=true
    Pdu BTS Interface Off  RMOD_${RMOD_SN}
    ${rmod_id}  Replace String Using Regexp  ${RMOD_DN}  .+/MRBTS_R-\\d+  MRBTS-${BTS_ID}
    ${fault_10}  Set Variable If  '${FAULT_10_SEVERITY}'=='Critical'  ${FAULT_10_Critical}  ${FAULT_10_Major}
    ${fault_10_params}  Get String With Alarm Parameters  ${fault_10}
    ${fault_10_params}  Catenate  ${fault_10_params},  notifier="[${BTS_NAME}] ${rmod_id}"
    Assert Alarm Active  parameters=${fault_10_params}  timeout=${FAULT_10_TIMEOUT}
    Assert  RMOD  ${RMOD_DN}  operationalState=${DISABLED_}, availabilityStatus=${NOTINSTALLED_}


Step${index}: Check Cells On Bts And Fault 4003
    Log  \nStep${index}: Check Cells On Bts And Fault 4003  console=true
    Check Parameters Status For Cells  ${DEGRADED_CELLS}  operationalState=${ENABLED_}, availabilityStatus=${DEGRADED_}
    Check Parameters Status For Cells  ${FAILED_CELLS}  operationalState=${DISABLED_}, availabilityStatus=${FAILED_}
    Check Fault 4003 On Every Affected Cells  ${CELLS_WITH_4003}  ${index}
    FOR  ${cell_dn}  IN  @{NOT_IMPACTED_CELLS}
      ${class_name}  Get Regexp Matches  ${cell_dn}  [A-Z]{2}CEL
      Assert  ${class_name}[0]  ${cell_dn}  operationalState=${ENABLED_}
      ${is_degraded}  Run Keyword And Return Status  Assert  ${class_name}[0]
      ...                                                    ${cell_dn}
      ...                                                    availabilityStatus=${DEGRADED_}
      ...                                                    timeout=20
      Run Keyword If  ${is_degraded}  Fail  ${cell_dn} is Degraded after RMOD power off. [NOK]
    END
    Run Keyword If  ${index}==2
    ...  Check Fault 4003 In Infomodel  ${CELLS_WITH_4003}


Step${index}: Power On RMOD And Check Bts To Be On Air
    Log  \nStep${index}: Power On RMOD And Check Bts To Be On Air  console=true
    Log  Turning on RMOD.  console=true
    Pdu BTS Interface On  RMOD_${RMOD_SN}
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  30s  Admin Check All Required State


Step4: Create Object NOTES
    Log  \nStep4: Create Object NOTES  console=true
    Create NOTES Object  enableInformativeAlarmReport  W9Y3


Step8: Delete Object NOTES
    Log  \nStep8: Delete object NOTES  console=true
    Check NOTES Object And Delete If Exist


Check NOTES Object And Delete If Exist
    ${notes_object}  coam.Get Managed Objects  NOTES_A
    Run Keyword If  ${notes_object}
    ...  Delete NOTES Object


Check Fault 4003 In Infomodel
    [Arguments]  ${cells_runtime_dn}

    FOR  ${cell_dn}  IN  @{cells_runtime_dn}
      ${alarming_resource_dn}  Get Alarming Resource DN For LTE and NR Cells  ${cell_dn}
      ${variable_to_check}  Catenate  SEPARATOR=  alarmName=regex"${FAULT_4003}[alarm_name]",
      ...                                         alarmNumber=${FAULT_4003}[alarm_id],
      ...                                         alarmSeverity=${FAULT_4003}[severity],
      ...                                         faultId=${FAULT_4003}[fault_id],
      ...                                         faultSeverity=${FAULT_4003}[severity],
      ...                                         alarmingResourceDN=${alarming_resource_dn}
      ${check}  Run Keyword And Return Status  Query Infomodel  get object /MRBTS-1/RAT-1/FRI-1/ALARM-* is [${variable_to_check}]
      Run Keyword If  ${check}
      ...  Log  Fault ${FAULT_4003}[fault_id] is reported in infomodel on alarmingResourceDN : ${alarming_resource_dn}.  console=True
      ...  ELSE
      ...  Fail  Fault ${FAULT_4003}[fault_id] is not reported in infomodel on alarmingResourceDN : ${alarming_resource_dn}.[NOK]
    END


Get Alarming Resource DN For LTE and NR Cells
    [Arguments]  ${cell_dn}

    ${status}  Run Keyword And Return Status  Should Contain  ${cell_dn}  LNCEL
    Run Keyword If  ${status}
    ...  Return From Keyword  ${cell_dn}
    ${cell_id}  Replace String Using Regexp  ${cell_dn}  .+/MRBTS_R-\\d+  MRBTS-${BTS_ID}
    ${cell_id}  Remove String  ${cell_id}  _R

    [Return]  ${cell_id}


Check If LTE And NR Are Deployed On RMOD
    [Arguments]  ${rmod_dn}

    ${rmod_params}  coam.Get Parameters  ${rmod_dn}
    Should Not Be Empty  ${rmod_params}[activeLteCellsList]  LTE is not deployed on provided RMOD. Please set another serial number.
    Should Not Be Empty  ${rmod_params}[activeNrCellsList]  NR is not deployed on provided RMOD. Please set another serial number.


Get Impacted Cells Expected States
    [Arguments]  ${cells_runtime_dn}  ${rmod_dn}

    ${degraded_cells}  Create List
    ${failed_cells}  Create List
    ${cells_with_4003}  Create List
    ${bts_info}  coam.Get Bts Info
    FOR  ${cell_dn}  IN  @{cells_runtime_dn}
         Run Keyword If  'GNCEL' in '${cell_dn}'
         ...  Run Keywords
         ...  Append To List  ${failed_cells}  ${cell_dn}
         ...  AND
         ...  Continue For Loop
         ${current_cell_rat}  Set Variable If
         ...  'WNCEL' in '${cell_dn}'  wcdma
         ...  'LNCEL' in '${cell_dn}'  lte
         ...  'NRCEL' in '${cell_dn}'  nr
         ${channel_directions_on_other_rmod}  Get Cell Channels Direction To Other Rmods  ${bts_info}[cells][${current_cell_rat}]
         ...                                                                              ${cell_dn}
         ...                                                                              ${rmod_dn}
         Run Keyword If  'TX' in ${channel_directions_on_other_rmod} and 'RX' in ${channel_directions_on_other_rmod}
         ...  Append To List  ${degraded_cells}  ${cell_dn}
         ...  ELSE
         ...  Append To List  ${failed_cells}  ${cell_dn}
         Continue For Loop If  'WNCEL' in '${cell_dn}'
         Run Keyword If  '${cell_dn}' in ${degraded_cells}
         ...  Append To List  ${cells_with_4003}  ${cell_dn}
    END

    [Return]  ${degraded_cells}  ${failed_cells}  ${cells_with_4003}


Get Cell Channels Direction To Other Rmods
    [Arguments]  ${bts_info_cells}  ${cell_dn}  ${rmod_dn}

    FOR  ${cell_info}  IN  @{bts_info_cells}
         Exit For Loop If  '${cell_dn}'=='${cell_info}[id][internal]'
    END
    ${carrier_list}  Set Variable  ${cell_info}[carrierList]
    ${channel_directions_on_other_rmod}  Create List
    FOR  ${carrier}  IN  @{carrier_list}
         Run Keyword If  '${rmod_dn}' not in '${carrier}[antennaLineId][internal]'
         ...  Append To List  ${channel_directions_on_other_rmod}  ${carrier}[direction]
    END

    [Return]  ${channel_directions_on_other_rmod}


Get Fault 10 Severity
    [Arguments]  ${failed_cells}

    ${no_failed_cells}  Run Keyword And Return Status  Should Be Empty  ${failed_cells}
    ${severity}  Set Variable If  ${no_failed_cells}  Major  Critical

    [Return]  ${severity}


Check Fault 4003 On Every Affected Cells
    [Arguments]  ${cells_runtime_dn}  ${index}

    ${fault_4003_initial_params}  Get String With Alarm Parameters  ${FAULT_4003}
    FOR  ${cell_dn}  IN  @{cells_runtime_dn}
         ${cell_id}  Replace String Using Regexp  ${cell_dn}  .+/MRBTS_R-\\d+  MRBTS-${BTS_ID}
         ${cell_id}  Remove String  ${cell_id}  _R
         ${fault_4003_params}  Catenate  ${fault_4003_initial_params},  configObjectName="[${BTS_NAME}] ${cell_id}"
         Run Keyword If  ${index}==2
         ...  Assert Alarm Inactive  parameters=${fault_4003_params}
         ...  ELSE
         ...  Assert Alarm Active  parameters=${fault_4003_params}
    END


Perform recovery action
    ${rmod_status}  Run Keyword And Return Status  Assert  RMOD  ${RMOD_DN}  operationalState=${DISABLED_}
    Run Keyword If  ${rmod_status}
    ...  Pdu BTS Interface On  RMOD_${RMOD_SN}
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10  Admin Check All Required State
    Check NOTES Object And Delete If Exist


TC Setup
    Common Test Setup  tc_name=FM__RMOD_hide_unhide_FID4003


TC Teardown
    Run Keyword If Test Failed  FM__RMOD_hide_unhide_FID4003.Perform recovery action
    Common Test Teardown

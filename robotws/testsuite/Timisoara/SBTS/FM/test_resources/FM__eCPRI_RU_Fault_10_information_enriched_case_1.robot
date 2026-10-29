*** Settings ***
Documentation
    ...  Starting release 26R1 test will verify feature CB012530-SR-A in case of eCPRI radio modules.
    ...  CB012530-SR-A scope is to enrich Fault 10 with Supplementary alarm information tab,
    ...  and to inform operator about the possible failure reasons of an eCPRI radio unit.


Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${RMOD_SN}  ${EMPTY}  # [Optional] eCPRI radio module serial number to be disconnected.
${ALARM_TIMEOUT}  900  # [in seconds] Timeout for alarm to appear in WebEM.
${NETACT_TIMEOUT}  120  # [in seconds] Timeout for alarm to appear in Netact.
${STARTUP_TIMEOUT}  1200  # [in seconds] Timeout for SBTS to recover after startup.


*** Keywords ***
TC__FM__eCPRI_RU_Fault_10_information_enriched_case_1
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-30143
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 03.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30143 - Initial creation
    ...  *******************

    Set Tags  CA-FM  OWNER-radu.steici@nokia.com  MAINTAINER-laura.craciunel@nokia.com
    ...  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  FEATURE-CB012530-SR-A


    Step0: Testcase Preconditions
    Step1: Unplug Radio Module And Perform Site Reset


Step0: Testcase Preconditions
    Log  \nStep0: Testcase preconditions.  console=true
    IF  '${ENB_BRANCH}' < 'SBTS26R1'  Fail  Software release is ${ENB_BRANCH}. Test is supported on software release equal to or higher than 26R1.
    IF  '${RMOD_SN}'!='${EMPTY}'
        Set Specific Radio Module From Configuration
    ELSE
        Set Random Radio Module From Configuration
    END
    ${rmod_cells}  Get Cell Mapping By Module Id  ${RMOD_R_DN}
    ${not_affected_cells}  Get All Cells On Bts
    Remove Values From List  ${not_affected_cells}  @{rmod_cells}
    Set Test Variable  ${RMOD_CELLS}
    Set Test Variable  ${NOT_AFFECTED_CELLS}
    ${rmod_cells_count}  Get Length  ${rmod_cells}
    ${expected_severity}  Set Variable If  '${rmod_cells_count}'=='0'  Major  Critical
    ${fault_10_dictionary}  Copy Dictionary  ${FAULT_10_CRITICAL}
    Remove From Dictionary  ${fault_10_dictionary}  severity
    ${fid_10_params}  Get String With Alarm Parameters  ${fault_10_dictionary}
    ${string_module_id}  Replace String Using Regexp  ${RMOD_R_DN}  .+/MRBTS_R-\\d+  MRBTS-${BTS_ID}
    ${dn_internal}  Catenate  SEPARATOR=/  PLMN-PLMN  ${string_module_id}
    Set Test Variable  ${DN_INTERNAL}
    ${alarm_parameters}  Catenate  ${fid_10_params},  severity="${expected_severity}",  alarmingResource=${string_module_id}
    Set Test Variable  ${ALARM_PARAMETERS}


Step1: Unplug Radio Module And Perform Site Reset
    Log  \nStep1: Unplug radio module and perform site reset.  console=true
    ${transceiver_identifier}  Get Sfp Transceiver Identifier For Radio Module  ${RMOD_R_DN}
    ${rmod_cells_count}  Get Length  ${rmod_cells}
    ${expected_fault}  Set Variable If  '${rmod_cells_count}'=='0'  ${FAULT_10_MAJOR}  ${FAULT_10_CRITICAL}

    Log  Radio module will be powered off.  console=true
    Pdu Bts Interface Off  ${RMOD_IF}
    ${fault_10_suppl_info_power_loss}  Catenate  ${ALARM_PARAMETERS},  supplAlarmInfo="RU connection was lost in runtime. RU power loss."
    Assert Alarm Active  parameters=${fault_10_suppl_info_power_loss}  timeout=${ALARM_TIMEOUT}
    Log  Fault ${fault_10_suppl_info_power_loss} was active in WebEm. [OK]  console=true
    Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  30
    ...  Check Additional Information For Given Alarm And Fault  &{expected_fault}  additional_fault_id=${expected_fault}[fault_id]
    ...  object_id=${DN_INTERNAL}  suppl_info=RU connection was lost in runtime. RU power loss.
    Log  Fault ${fault_10_suppl_info_power_loss} was active in Netact. [OK]  console=true

    Log  Site reset will be performed.  console=true
    coam.Reset Site
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  60
    ...  Check Parameters Status For Cells  ${NOT_AFFECTED_CELLS}  operationalState=${ENABLED}
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  60
    ...  Check Parameters Status For Cells  ${RMOD_CELLS}  operationalState=${DISABLED}, availabilityStatus=${FAILED}
    ${fault_10_suppl_info_startup}  Catenate  ${ALARM_PARAMETERS},
    ...  supplAlarmInfo=regex"RU not detected after BTS startup.*SFP type is ${transceiver_identifier}.*Protocol is eCPRI.*"
    Assert Alarm Active  parameters=${fault_10_suppl_info_startup}  timeout=${ALARM_TIMEOUT}
    Log  Fault ${fault_10_suppl_info_startup} was active in WebEm. [OK]  console=true
    Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  30
    ...  Check Additional Information For Given Alarm And Fault  &{expected_fault}  additional_fault_id=${expected_fault}[fault_id]
    ...  object_id=${DN_INTERNAL}  suppl_info=RU not detected after BTS startup.*SFP type is ${transceiver_identifier}.*Protocol is eCPRI.*
    Log  Fault ${fault_10_suppl_info_startup} was active in Netact. [OK]  console=true


Set Specific Radio Module From Configuration
    ${rmods_list}  Get Frm
    FOR  ${rmod}  IN  @{rmods_list}
        IF  '${rmod}[serialNumber]'=='${RMOD_SN}'  BREAK
    END
    Set Test Variable  ${RMOD_IF}  RMOD_${RMOD_SN}
    Set Test Variable  ${RMOD_R_DN}  ${rmod}[id][internal]


Set Random Radio Module From Configuration
    ${rmods_list}  coam.Get Parameters For All  RMOD
    ${ecpri_rmods}  Create List
    FOR  ${rmod}  IN  @{rmods_list}
        ${status_ecpri}  Run Keyword And Return Status  Should Match Regexp  ${rmod}[l3Protocol]  .*(ecpri|eCPRI|ECPRI).*
        IF  ${status_ecpri}  Append To List  ${ecpri_rmods}  ${rmod}
    END
    ${count_ecpri}  Get Length  ${ecpri_rmods}
    Should Not Be Equal  ${count_ecpri}  0  No radio module with eCPRI found in configuration. Test will be marked as failed.
    ${rmod}  Evaluate  random.choice(${ecpri_rmods})  random
    Set Test Variable  ${RMOD_IF}  RMOD_${rmod}[serialNumber]
    Set Test Variable  ${RMOD_R_DN}  ${rmod}[id]


Power On Target Radio Module
    Log  Affected radio module will be turned on.  console=true
    Pdu Bts Interface On  ${RMOD_IF}
    Assert Alarm Inactive  parameters=${ALARM_PARAMETERS}  timeout=${ALARM_TIMEOUT}
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  60  Check Modules And Cells


TC Setup
    Common Test Setup  tc_name=FM__eCPRI_RU_Fault_10_information_enriched_case_1
    Setup NetAct


TC Teardown
    Power On Target Radio Module
    Teardown NetAct
    Common Test Teardown

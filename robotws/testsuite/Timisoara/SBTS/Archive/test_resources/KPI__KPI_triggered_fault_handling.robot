*** Settings ***
Documentation
    ...  This TC is monitoring the SBTS when actKpiAlarms parameter has true and false values.
    ...  1. actKpiAlarms is changed to true. Fault 4570 must be visible on every LTE cell and fault 4580 must be active
    ...  on MRBTS.
    ...  2. actKpiAlarms is changed to false which is the default value. Then fault 4570 and 4580 must be cleared.
    ...  SBTS is onAir during the entire TC.

Resource  ../../common_resources/ca_KPI_general.robot


*** Variables ***
${ALARMS_ACTIVE_TIMEOUT}  180


*** Keywords ***
TC__KPI__KPI_triggered_fault_handling
    [Documentation]
    ...  [CASE LINK]: https://jiradc.int.net.nokia.com/browse/TAT-23170
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...
    ...  - 24.05.2022 - https://jiradc.int.net.nokia.com/browse/TAT-23170 - Initial creation
    ...  - 18.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24130 - Refactor TC with best practices
    ...  - 16.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24317 - Refactor KPI TCs and resources to use KWs from ca_SBTS_general
    ...  - 31.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25134 - Remove faultName from both faults and configObjectName from fault 4580
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Add watchdog alarm monitoring

    Set Tags  CA-KPI  OWNER-mohamad.al_hamwi@nokia.com  AUTHOR-andrada-lavinia.baleti@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_1_Vrf  PHASE-CRT  SW-SBTS22

    Step0: TC Variables
    Step1: Change ActKpiAlarms Parameter To True
    Step2: Check Visible Alarms And SBTS Status
    Step3: Change ActKpiAlarms Parameter To False
    Step4: Check If Alarms Are Cleared And SBTS Status Is As Expected


Step0: TC Variables
    ${bts_id}  Admin Get BTS ID
    Set Test Variable  ${BTS_ID}
    ${bts_parameters}  Get Parameters For All  BTS
    ${bts_name}  Convert To String  ${bts_parameters[0].btsName}
    Set Test Variable  ${BTS_NAME}
    ${lncel_ids}  Get Ids For All  LNCEL
    Set Short Distname For LTE Cells  ${lncel_ids}
    ${fault_4570_params_for_assert}  Get String With Alarm Parameters  ${FAULT_4570}
    ${fault_4580_params_for_assert}  Get String With Alarm Parameters  ${FAULT_4580}
    Set Test Variable  ${FAULT_4570_PARAMS_FOR_ASSERT}
    Set Test Variable  ${FAULT_4580_PARAMS_FOR_ASSERT}


Step1: Change ActKpiAlarms Parameter To True
    Log  \nStep1: Change actKpiAlarms parameter to true  console=true
    Change Parameter Value  actKpiAlarms  true


Step2: Check Visible Alarms And SBTS Status
    Log  \nStep2: Check visible alarms and SBTS status  console=true
    Sleep  ${ALARMS_ACTIVE_TIMEOUT}s
    FOR  ${lncel_dn}  IN  @{LNCEL_SHORT_DN_LIST}
        ${4570_params}  Catenate  ${FAULT_4570_PARAMS_FOR_ASSERT},  configObjectName="[${BTS_NAME}] ${lncel_dn}"
        Assert Alarm Active  ${4570_params}
    END
    Log  Fault 4570: Formula-1 has been raised is active on every LTE cell. [OK]  console=true
    Assert Alarm Active  ${FAULT_4580_PARAMS_FOR_ASSERT}
    Log  Fault 4580: Formula-2 has been raised is active.  console=true
    Admin Check All Required State
    Log  SBTS is onAir. [OK]  console=true


Step3: Change ActKpiAlarms Parameter To False
    Log  \nStep3: Change actKpiAlarms parameter to false  console=true
    Change Parameter Value  actKpiAlarms  false


Step4: Check If Alarms Are Cleared And SBTS Status Is As Expected
    Log  \nStep4: Check if alarms are cleared and SBTS status is as expected  console=true
    Sleep  60s
    FOR  ${lncel_dn}  IN  @{LNCEL_SHORT_DN_LIST}
        ${4570_params}  Catenate  ${FAULT_4570_PARAMS_FOR_ASSERT},  configObjectName="[${BTS_NAME}] ${lncel_dn}"
        Assert Alarm Inactive  ${4570_params}
    END
    Log  Fault 4570: Formula-1 has been raised is inactive on every LTE cell. [OK]  console=true
    Assert Alarm Inactive  ${FAULT_4580_PARAMS_FOR_ASSERT}
    Admin Check All Required State
    Log  SBTS is onAir.  console=true


Set Short Distname For LTE Cells
    [Arguments]  ${lncel_ids}

    ${cells_dn_list}  Create List
    FOR  ${cell}  IN  @{lncel_ids}
        ${cell_dn}  Remove String Using Regexp  ${cell}  .*VIEW-\\d/
        ${cell_dn}  Remove String Using Regexp  ${cell_dn}  _R
        ${cell_dn}  Replace String Using Regexp  ${cell_dn}  MRBTS-\\d  MRBTS-${BTS_ID}
        Append To List  ${cells_dn_list}  ${cell_dn}
    END
    Set Test Variable  ${LNCEL_SHORT_DN_LIST}  ${cells_dn_list}


Change Parameter Value
    [Arguments]  ${parameter_name}  ${new_value}

    coam.Perform Parameter Recommissioning  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1  ${parameter_name}  update  ${new_value}
    ...  skip_parameter_relation_errors=True  should_activate=True  timeout=300
    Log  ${parameter_name} was changed to ${new_value}.  console=true


TC Setup
    Set Test Variable  ${DISABLE_WATCHDOG}  ${TRUE}
    Common Test Setup  tc_name=KPI__KPI_triggered_fault_handling


TC Teardown
    Common Test Teardown

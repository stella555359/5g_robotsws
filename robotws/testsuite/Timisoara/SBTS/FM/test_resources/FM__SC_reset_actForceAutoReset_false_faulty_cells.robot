*** Settings ***
Documentation
    ...  This TC can be only run on dual core platforms with NO IQ routing.
    ...  Fault 2080 is trigered on secondary core. ActFoceAutoReset is set to False.
    ...  All secondary core cells go down. Recovery action is not performed.

Resource  ../../common_resources/ca_FM_general.robot


*** Keywords ***
TC__FM__SC_reset_actForceAutoReset_false_faulty_cells
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-10245
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 19.04.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21212 - Add KW to send fault on both sides on NR configurations
    ...  - 24.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  - 28.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23842 - Remove Test Specific Teardown and Setup
    ...  - 17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  - 05.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26813 - Refactor FM testcase for assert alarm active parameters
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  - 02.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27092 - Update fault for assert alarm active
    ...  ******************

    Set Tags  CA-FM  OWNER-laura.craciunel@nokia.com  AUTHOR-piotr.szlegel@nokia.com  MAINTAINER-laura.craciunel@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf
    ...  PHASE-CRT  SW-SBTS17A  FEATURE-RP001498  FEATURE-RP001621

    Step1: Check All Required States
    Step2: Send Fault 2080
    Step3: Check If Fault 2080 Is Raised
    Step4: Recover Services


Step1: Check All Required States
    [Documentation]  In this step specific states will be checked.

    Log  \nStep1: Check all required states.  console=True
    Check If Configuration Is Dual Core
    Log  Check actForceAutoReset and change for FALSE if needed.  console=True
    ${initial_value}  Get ActForce(Unit)AutoReset Value From Infomodel  actForceAutoReset
    ${status}  Run Keyword And Return Status
    ...  Change Parameter ActForce(Unit)AutoReset  false  actForceAutoReset
    ${parameter_after_change}  Get ActForce(Unit)AutoReset Value From Infomodel  actForceAutoReset
    Run Keyword If  ${status}
    ...  Should Be Equal  ${parameter_after_change}  false
    Set Test Variable  ${INITIAL_VALUE}
    Perform Site Reset


Step2: Send Fault 2080
    [Documentation]  This step provdes triger fault 2080 on SC core.

    Log  \nStep2: Send fault 2080.  console=True
    ${hwapi_domain}  Query Infomodel  get object /MRBTS-1/RAT-1/BTS_L-* is [storedRole=Idle]
    Run Keyword If  '${hwapi_domain.hwapiDomainId}' == '1'
    ...  Run Keyword
    ...  Receiver Value For HwapiDomain1
    ...  ELSE
    ...  Receiver Value For HwapiDomain2
    Send Hwapi Api2 Alarm Msg  ${SENDER}  ${RECEIVER}  1  2080  ${DOMAIN_ID}  timeout=80


Step3: Check If Fault 2080 Is Raised
    [Documentation]  This step check recovery action result.

    Log  \nStep3:Check if fault 2080 is raised.  console=True
    ${fault_2080_params}  Get String With Alarm Parameters  ${FAULT_2080_SRIO_LINK_DOWN}
    ${fault_status}  Run Keyword And Return Status
    ...  Assert Alarm Active  parameters=${fault_2080_params}  timeout=180
    Run Keyword If  ${fault_status}
    ...  Log  Fault ${FAULT_2080_SRIO_LINK_DOWN}[fault_id] "${FAULT_2080_SRIO_LINK_DOWN}[fault_name]" is active in WebEM. [OK]  console=True
    ...  ELSE
    ...  Fail  Fault ${FAULT_2080_SRIO_LINK_DOWN}[fault_id] "${FAULT_2080_SRIO_LINK_DOWN}[fault_name]" is active in WebEM. [NOK]
    Check Secondary Core Status
    ${secondary_core_dn}  Query Infomodel  get object //${VAR_BTS_L}
    ${cells}  Infomodel Get Cells Deployed On Module  ${secondary_core_dn}
    FOR  ${im_cell}  IN  @{cells}
        Infomodel Cell Should Be Failed  ${im_cell}
    END


Step4: Recover Services
    Log  \nStep4: Recover services.  console=True
    Log  Site reset will be performed to recover services.  console=True
    Perform Site Reset
    ${fault_2080_params}  Get String With Alarm Parameters  ${FAULT_2080_SRIO_LINK_DOWN}
    Assert Alarm Inactive  parameters=${fault_2080_params}  timeout=180
    Log  Changing actForceAutoReset to initial state.  console=True
    Change Parameter ActForce(Unit)AutoReset  ${INITIAL_VALUE}  actForceAutoReset


Check If Configuration Is Dual Core
    [Documentation]  This KW is created to check if config consist of two system modules

    ${bts_l}  Query Infomodel  get list //BTS_L-*
    ${bts_l_lenght}  Get Length  ${bts_l}
    Run Keyword If  ${bts_l_lenght} < 2
    ...  Fail  msg=Tested configuration is not dual core, test will be set as fail. [NOK]
    ...  ELSE
    ...  Log  Tested configuration is dual core, test will continue. [OK]  console=True


Receiver Value For HwapiDomain1
    ${var_bts_l}  Set Variable  BTS_L-1
    Set Test Variable  ${VAR_BTS_L}
    ${receiver}  Set Variable  0x10111202
    Set Test Variable  ${RECEIVER}
    ${sender}  Set Variable  0x10110240
    Set Test Variable  ${SENDER}
    ${domain_id}  Set Variable  16
    Set Test Variable  ${DOMAIN_ID}


Receiver Value For HwapiDomain2
    ${var_bts_l}  Set Variable  BTS_L-4
    Set Test Variable  ${VAR_BTS_L}
    ${receiver}  Set Variable  0x20111202
    Set Test Variable  ${RECEIVER}
    ${sender}  Set Variable  0x20110240
    Set Test Variable  ${SENDER}
    ${domain_id}  Set Variable  32
    Set Test Variable  ${DOMAIN_ID}


Check Secondary Core Status
    [Documentation]  This KW was created to check secondary SMOD status after it was hot removed.

    ${smod_r}  Get Infomodel Object  //SMOD_R-* is [activeRole=Secondary]
    ${operational_state}  Run Keyword And Return Status
    ...  Assert Any  SMOD  operationalState=${DISABLED}
    ${availability_status}  Run Keyword And Return Status
    ...  Assert Any  SMOD  availabilityStatus=${NOT_INSTALLED}
    Run Keyword If  ${operational_state} == ${FALSE} or ${availability_status} == ${FALSE}
    ...  Set Test Restriction  SC status is different than expected operationalState!=disabled and/or availabilityStatus!=not installed [NOK].
    ...  ELSE
    ...  Log  SC after hot remove reached expected states operationalState=disabled and availabilityStatus=not installed [OK]  console=TRUE


TC Setup
    Common Test Setup  tc_name=FM__SC_reset_actForceAutoReset_false_faulty_cells


TC Teardown
    Run Keyword And Ignore Error
    ...  Change Parameter ActForce(Unit)AutoReset  ${INITIAL_VALUE}  actForceAutoReset
    Common Test Teardown

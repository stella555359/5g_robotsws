*** Settings ***
Documentation
    ...  TC will check if the given RMOD has 2 optical interfaces, the secondary OPT_IF will be chosen for hot remove.
    ...  RMOD secondary fiber hot remove, by powering off the outlet from the PSE BLACKBOX.
    ...  Verify fault and alarm after hot remove, some cells on RMOD are failed.
    ...  Verify RMOD status after hot remove, availability must be degraded and operational must be enabled.
    ...  RMOD secondary fiber hot insert in the same port, by powering on the outlet from the PSE BLACKBOX.
    ...  Verify RMOD status after hot insert, must be Online and Enabled.
    ...  Verify fault and alarm.
    ...  Verify if all cells are working.

Library  SSHLibrary
Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${RMOD_SN}  ${EMPTY}  # Mandatory
&{PDU_DICT}  IP=10.255.1.14  TYPE=BBOXPSE
&{OPT_1}  OUTLET=2  PORT_1=BBMOD_EA185079918  PORT_2=RMOD_K9184635330  &{PDU_DICT}
&{OPT_2}  OUTLET=1  PORT_1=SMOD_NK163060801  PORT_2=RMOD_K9184635330  &{PDU_DICT}


*** Keywords ***
TC__FM__RMOD_hot_remove_hot_insert_secondary
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-20993
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 04.03.2021 - https://jira3.int.net.nokia.com/browse/TAT-20993 - Initial creation
    ...  - 24.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  - 08.02.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22604 - FM__RMOD_hot_remove_hot_insert_secondary failed
    ...  - 09.09.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-22214 - Ute cloud: FM__RMOD_hot_remove_hot_insert_secondary test fails
    ...  - 28.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23931 - Move keywords to resource file
    ...  - 28.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25066 - Replace ute_pdu with taf.pdu
    ...  ******************

    Set Tags  CA-FM  OWNER-laura.craciunel@nokia.com  AUTHOR-cosmina.rebenciuc@nokia.com  MAINTAINER-andreea.burtic@nokia.com
    ...  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS21

    Step 1: Check Initial State
    Step 2: Perform RF Module Hot Remove Secondary Optical Fiber
    Step 3: Verify Fault And Alarm
    Step 4: RMOD Verification After Hot Remove
    Step 5: Verify Other RMODs
    Step 6: Secondary Fiber Is Hot Inserted To The Same Port
    Step 7: Verify Alarm And Cells


Step 1: Check Initial State
    Log  Step 1: Check inital state and verify if RMOD has 2 fibers  console=true
    Run Keyword If  ${TL}
    ...  Append Variable To Interfaces Dictionary
    ${rmod}  Query Infomodel  get object //RMOD_R-* is [serialNumber=${RMOD_SN}]
    ${rmod_dn}  Set Variable  ${rmod}[dist_name]
    ${cablinks}  Query Infomodel  get list //CABLINK_R-* is [secondEndpointDN=${rmod_dn}]
    ${cablinks_length}  Get Length  ${cablinks}
    Should Be Equal As Integers  ${cablinks_length}  2  msg=RMOD does not have 2 OPT_IF connected.
    ${secondary_cablink}  Get Secondary Cablink  ${cablinks}
    Set Test Variable  ${INITIAL_SECONDARY_CABLINK}  ${secondary_cablink}
    Set Test Variable  ${SECONDARY_RMOD_PORT_ID}  ${INITIAL_SECONDARY_CABLINK}[secondEndpointPortId]
    Log  Secondary RMOD port ID is ${SECONDARY_RMOD_PORT_ID}  console=true
    ${bbmod_object}  Query Infomodel  get object ${secondary_cablink}[firstEndpointDN]
    ${module_type}  Get Module Type  ${bbmod_object}[dist_name]
    Set Test Variable  ${BBMOD_SN}  ${bbmod_object}[serialNumber]
    ${opt_items}  Get PDU Optical Interface Info List  port_1=${module_type}_${BBMOD_SN}  port_2=RMOD_${RMOD_SN}
    FOR  ${opt_if}  IN  @{opt_items}
        ${status_opt}  Run Keyword And Return Status
        ...  Should Contain  '${opt_if}'  'OPT_${SECONDARY_RMOD_PORT_ID}'
        Run Keyword If  ${status_opt}
        ...  Set Test Variable  ${SECONDARY_OPT_IF}  ${opt_if}
        ...  ELSE
        ...  Set Test Variable  ${PRIMARY_OPT_IF}  ${opt_if}
    END
    Store Rmod  ${RMOD_SN}
    ${rmod_ref}  Infomodel Get RMOD By Serial Number  ${RMOD_SN}
    ${rmod_cells}  Infomodel Get Cells Deployed On Module  ${rmod_ref}
    ${left_over_cells}  Query Infomodel  get list //CELL_M-*
    Remove Values From List  ${left_over_cells}  @{rmod_cells}
    Set Test Variable  ${RMOD_CELLS}
    Set Test Variable  ${LEFT_OVER_CELLS}
    ${pdu_device}  Setup Pdu  ${INTERFACES}[${SECONDARY_OPT_IF}][TYPE]  ${INTERFACES}[${SECONDARY_OPT_IF}][IP]
    Set Test Variable  ${PDU_DEVICE}


Append Variable To Interfaces Dictionary
    Log  Test variable to interfaces.  console=true
    Add Variables In Interfaces  OPT_1  ${OPT_1}
    Add Variables In Interfaces  OPT_2  ${OPT_2}


Get Module Type
    [Arguments]  ${module_dn}

    ${module_type}  Run Keyword And Return Status
    ...  Should Contain  ${module_dn}  BBMOD
    Run Keyword If  ${module_type}
    ...  Return From Keyword  BBMOD
    ...  ELSE
    ...  Return From Keyword  SMOD


Get Secondary Cablink
    [Documentation]  This keyword returns the secondary cablink from the given list.
    [Arguments]  ${cablinks}

    FOR  ${cablink}  IN  @{cablinks}
        Return From Keyword If  '${cablink}[linkModeSynchronization]'=='False'  ${cablink}
    END


Step 2: Perform RF Module Hot Remove Secondary Optical Fiber
    Log  Step 2: Perform RF module hot remove secondary optical fiber  console=true
    Log  Power Off Outlet: ${INTERFACES}[${SECONDARY_OPT_IF}][OUTLET]  console=true
    Power Off  ${INTERFACES}[${SECONDARY_OPT_IF}][OUTLET]  pdu_device=${PDU_DEVICE}
    Sleep  10s


Step 3: Verify Fault And Alarm
    Log  Step 3: Verify Fault and Alarm  console=true
    Sleep  360s  Wait for alarm with faultId 2002 to appear
    Assert Alarm Active  faultId=2002, alarmId=7116, faultName="Receiving failure in Optical Interface"  timeout=360
    Verify Cells Status  ${RMOD_CELLS}  Online  Enabled


Verify Cells Status1
    [Arguments]  ${cells}

    FOR  ${im_cell}  IN  @{cells}
        ${cell_obj}  Query Infomodel  get object ${im_cell.dist_name}
        Infomodel Cell Should Be Online  ${cell_obj}
    END


Verify Cells Status
    [Arguments]  ${cells}  ${availability_status}  ${operational_status}

    FOR  ${im_cell}  IN  @{cells}
        ${cell_obj}  Query Infomodel  get object ${im_cell.dist_name}
        ${availability}  Run Keyword And Return Status
        ...  Should Be Equal  '${cell_obj}[stateInfo][availabilityStatus]'  '${availability_status}'
        ${operational}  Run Keyword And Return Status
        ...  Should Be Equal  '${cell_obj}[stateInfo][operationalState]'  '${operational_status}'
        Run Keyword If  ${availability} and ${operational}
        ...  Log  Cell ${im_cell.dist_name} is ${cell_obj}[stateInfo][availabilityStatus] and ${cell_obj}[stateInfo][operationalState]  console=true
        ...  ELSE
        ...  Log  Cell ${im_cell.dist_name} is: ${cell_obj}[stateInfo][availabilityStatus] and ${cell_obj}[stateInfo][operationalState]  level=WARN
    END


Verify Left Over Cells Status
    [Arguments]  ${cells}  ${availability_status}  ${operational_status}

    FOR  ${im_cell}  IN  @{cells}
        ${cell_obj}  Query Infomodel  get object ${im_cell.dist_name}
        ${availability}  Run Keyword And Return Status
        ...  Should Be Equal  '${cell_obj}[stateInfo][availabilityStatus]'  '${availability_status}'
        ${operational}  Run Keyword And Return Status
        ...  Should Be Equal  '${cell_obj}[stateInfo][operationalState]'  '${operational_status}'
        Run Keyword If  ${availability} and ${operational}
        ...  Log  Cell ${im_cell.dist_name} is in expected status.  console=true
        ...  ELSE
        ...  Set Test Failed  Cell is in unexpected status: availability_status=${availability} and operational_status=${operational} .
    END


Step 4: RMOD Verification After Hot Remove
    Log  Step 4: RMOD Verification after hot remove  console=true
    Verify RMOD Status  ${ENABLED}  ${DEGRADED}


Step 5: Verify Other RMODs
    Log  Step 5: Verify Other RMODs  console=true
    Verify Left Over Cells Status  ${LEFT_OVER_CELLS}  Online  Enabled


Step 6: Secondary Fiber Is Hot Inserted To The Same Port
    Log  Step 6:Secondary fiber is hot inserted to the same port  console=true
    Power On  ${INTERFACES}[${SECONDARY_OPT_IF}][OUTLET]  pdu_device=${PDU_DEVICE}
    Sleep  120s  Wait for cablink to be available.
    Log  Verify RMOD after hot inserted  console=true
    Verify RMOD Status  ${ENABLED}


Step 7: Verify Alarm And Cells
    Log  Step 7: Verify alarm and cells  console=true
    Assert Alarm Inactive  faultId=2002, alarmId=7116, faultName="Receiving failure in Optical Interface"  timeout=360
    Log  Check all cells after fiber restore  console=true
    Wait Until Keyword Succeeds  90  10
    ...  Check All Cells
    Run Keyword And Ignore Error
    ...  Teardown PDU  pdu_device=${PDU_DEVICE}


Store Rmod
    [Documentation]  This KW stores the value of IP and MasterAgentDN
    [Arguments]  ${sn}

    ${rmod}  _Get Rmod Object By Serial Number  ${sn}
    ${smod_l}  Query Infomodel  get object ${rmod.masterAgentDN}
    ${smod_r}  Query Infomodel  get object //CABINET_R-*/SMOD_R-* is [serialNumber=${smod_l.serialNumber}]
    Wait Until Keyword Succeeds  90s  10s
    ...  Should Be True  '${rmod.ipAddress}' != '0.0.0.0'
    ${rmod_ip_addr}  Set Variable  ${rmod.ipAddress}
    Set Test Variable  ${SMOD_L}
    Set Test Variable  ${SMOD_R}
    Set Test Variable  ${RMOD_IP_ADDR}


Insert Optical Fiber
    [Documentation]  Keyword used in Teardown to reestablish the optical fiber connection.

    Setup Pdu  ${INTERFACES}[${SECONDARY_OPT_IF}][TYPE]  ${INTERFACES}[${SECONDARY_OPT_IF}][IP]  alias=turn_on
    Power On  ${INTERFACES}[${SECONDARY_OPT_IF}][OUTLET]  pdu_device=turn_on
    Wait Until Keyword Succeeds  300s  10s
    ...  Check All Cells
    [Teardown]  Run Keyword And Ignore Error
    ...  Teardown Pdu  pdu_device=turn_on


TC Setup
    Common Test Setup


TC Teardown
    Run Keyword If Test Failed
    ...  Insert Optical Fiber
    Common Test Teardown

*** Settings ***
Library    SSHLibrary
Resource    ../../common_resources/ca_FM_general.robot

*** Variables ***
${RMOD_SN}      # Mandatory
&{pdu_dict}  IP=10.255.1.14  TYPE=BBOXPSE
&{OPT_1}  OUTLET=2  PORT_1=BBMOD_EA185079918  PORT_2=RMOD_K9184635330  &{pdu_dict}
&{OPT_2}  OUTLET=1  PORT_1=SMOD_NK163060801  PORT_2=RMOD_K9184635330  &{pdu_dict}

*** Keywords ***
TC__FM__RMOD_hot_remove_hot_insert_primary
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-20992
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  TC will check if the given RMOD has 2 optical interfaces, the primary OPT_IF will be chosen for hot remove.
    ...  RMOD primary fiber hot remove, by powering off the outlet from the PSE BLACKBOX.
    ...  Verify fault and alarm after hot remove, cells on RMOD must be failed.
    ...  RMOD reset is performed.
    ...  Verify if the secondary interface is now primary.
    ...  Verify if left over cells are not affected and are still online.
    ...  Verify fault and alarm after
    ...  RMOD primary fiber hot insert, by powering on the outlet from the PSE BLACKBOX.
    ...  Verify if all cells are working.
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 04.03.2021 - https://jira3.int.net.nokia.com/browse/TAT-20992 - Initial creation
    ...  - 10.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  - 08.02.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22583 - Testcase FM__RMOD_hot_remove_hot_insert_primary is failed
    ...  - 09.09.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-22214 - Ute cloud: FM__RMOD_hot_remove_hot_insert_primary test fails
    ...  - 28.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23931 - Move keywords to resource file
    ...  - 28.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25066 - Replace ute_pdu with taf.pdu
    ...  *******************

    Set Tags    CA-FM    OWNER-laura.craciunel@nokia.com    AUTHOR-andreea.burtic@nokia.com
    ...    MAINTAINER-cosmina.rebenciuc@nokia.com    GROUP_IN_CHARGE-TIM_4_Vrf    PHASE-CRT    SW-SBTS21

    Step 1: Check initial state
    Step 2: Perform RF module hot remove primary optical fiber
    Step 3: Verify Fault and Alarm
    Step 4: RMOD Verification after hot remove
    Step 5: Verify if secondary link is now used as primary
    Step 6: Verify Fault and Alarm
    Step 7: Restore Optical Fiber and Verify All Cells Are On Air

Step 1: Check Initial State
    Log  Step 1: Check inital state and verify if RMOD has 2 fibers  console=true
    Run keyword if  ${tl}
    ...  Append variable to interfaces dictionary
    ${rmod}  Query infomodel  get object //RMOD_R-* is [serialNumber=${RMOD_SN}]
    Set Test Variable  ${rmod_dn}  ${rmod}[dist_name]
    ${cablinks}  Query infomodel  get list //CABLINK_R-* is [secondEndpointDN=${rmod_dn}]
    ${cablinks_length}  Get Length  ${cablinks}
    Should Be Equal As integers  ${cablinks_length}  2  msg=RMOD does not have 2 OPT_IF connected.
    ${primary_cablink}  Get Primary Cablink  ${cablinks}
    Set Test Variable  ${INITIAL_PRIMARY_CABLINK}  ${primary_cablink}
    Set Test Variable  ${PRIMARY_RMOD_PORT_ID}  ${INITIAL_PRIMARY_CABLINK}[secondEndpointPortId]
    Log  Primary RMOD port ID is ${PRIMARY_RMOD_PORT_ID}  console=true
    ${BBMOD_OBJECT}  Query Infomodel  get object ${primary_cablink}[firstEndpointDN]
    ${module_type}  Get module type  ${BBMOD_OBJECT}[dist_name]
    Set Test Variable  ${BBMOD_SN}  ${BBMOD_OBJECT}[serialNumber]
    ${OPT_items}=  Get PDU Optical Interface Info List  port_1=${module_type}_${BBMOD_SN}  port_2=RMOD_${RMOD_SN}
    FOR  ${opt_if}  IN  @{OPT_items}
      ${status_opt}=  Run Keyword And Return Status  Should Contain  '${opt_if}'  'OPT_${PRIMARY_RMOD_PORT_ID}'
      Run Keyword If  ${status_opt}
      ...  Set Test Variable  ${PRIMARY_OPT_IF}  ${opt_if}
      ...  ELSE
      ...  Set Test Variable  ${SECONDARY_OPT_IF}  ${opt_if}
    END
    Store Rmod  ${RMOD_SN}
    ${rmod_ref}  Infomodel Get RMOD By Serial Number  ${RMOD_SN}
    ${RMOD_CELLS} =  Infomodel Get Cells Deployed On Module  ${rmod_ref}
    ${RMOD_CELLS_length}  Get Length  ${RMOD_CELLS}
    Log  Number of cells on RMOD: ${RMOD_CELLS_length}  console=true
    ${LEFT_OVER_CELLS} =  Query Infomodel  get list //CELL_M-*
    Remove Values From List  ${LEFT_OVER_CELLS}  @{RMOD_CELLS}
    Set Test Variable  ${RMOD_CELLS}
    Log  ${RMOD_CELLS}
    Set Test Variable  ${LEFT_OVER_CELLS}
    ${PDU_DEVICE}  Setup Pdu  ${INTERFACES}[${PRIMARY_OPT_IF}][TYPE]  ${INTERFACES}[${PRIMARY_OPT_IF}][IP]
    Set test variable  ${PDU_DEVICE}

Append variable to interfaces dictionary
    Log  Test variable to interfaces.  console=true
    Add variables in interfaces  OPT_1  ${OPT_1}
    Add variables in interfaces  OPT_2  ${OPT_2}

Get module type
     [Arguments]  ${module_dn}
     ${module_type}  Run Keyword and Return Status  Should Contain  ${module_dn}  BBMOD
     Run keyword if  ${module_type}
     ...  Return From Keyword  BBMOD
     ...  ELSE
     ...  Return From Keyword  SMOD

Get Primary Cablink
    [Documentation]  This keyword returns the primary cablink from the given list.
    [Arguments]    ${cablinks}
    FOR  ${cablink}  IN  @{cablinks}
      Return From Keyword If  '${cablink}[linkModeConfiguration]'=='True' and '${cablink}[linkModeSynchronization]'=='True'
      ...  ${cablink}
    END

Step 2: Perform RF module hot remove primary optical fiber
    Log  Step 2: Perform RF module hot remove primary optical fiber  console=true
    Log  Power Off Outlet: ${INTERFACES}[${PRIMARY_OPT_IF}][OUTLET]  console=true
    Power Off  ${INTERFACES}[${PRIMARY_OPT_IF}][OUTLET]  pdu_device=${PDU_DEVICE}

Step 3: Verify Fault and Alarm
    Log  Step 3: Verify Fault and Alarm  console=true
    Assert Alarm Active  faultId=10, alarmId=7116, faultName="No connection to unit"  timeout=60
    Verify cells status  ${RMOD_CELLS}  Failed  Disabled

Verify cells status
    [Arguments]  ${cells}  ${availability_status}  ${operational_status}
    FOR  ${im_cell}  IN  @{cells}
        ${cell_obj}  Query infomodel  get object ${im_cell.dist_name}
        ${availability}  Run Keyword And Return Status  Should Be Equal  '${cell_obj}[stateInfo][availabilityStatus]'  '${availability_status}'
        ${operational}  Run Keyword And Return Status  Should Be Equal  '${cell_obj}[stateInfo][operationalState]'  '${operational_status}'
        Run Keyword If  ${availability} and ${operational}
        ...  Log  Cell ${im_cell.dist_name} is in expected status.  console=true
        ...  ELSE
        ...  Set Test Failed  Cell is in unexpected status: availability_status=${availability} and operational_status=${operational} .
    END

Step 4: RMOD Verification after hot remove
    Log  Step 4: RMOD Verification after hot remove  console=true
    Verify RMOD status  ${Disabled_}

Verify RMOD after reset
    Verify RMOD status  ${Enabled_}

Step 5: Verify if secondary link is now used as primary
    Log  Step 5: Verify if secondary link is now used as primary and other RMODs  console=true
    Sleep  180  Wait for cablink to be available.
    Wait Until Keyword Succeeds  400s  10  Verify RMOD after reset
    ${cablinks}  Query infomodel  get list //CABLINK_R-* is [secondEndpointDN=${rmod_dn}]
    ${primary_cablink_after_change}  Get Primary Cablink  ${cablinks}
    ${port_ID_after_change}  Set Variable  ${primary_cablink_after_change}[secondEndpointPortId]
    ${status}=  Run Keyword and Return Status  Should Not Be Equal  ${port_ID_after_change}  ${PRIMARY_RMOD_PORT_ID}
    Run Keyword If  ${status}
    ...  Log  OPT_IF ${port_ID_after_change} has become primary after fiber hot remove.  console=true
    ...  ELSE
    ...  Set Test Restriction  OPT_IF ${port_ID_after_change} has not become primary.
    Verify cells status  ${LEFT_OVER_CELLS}  Online  Enabled

Step 6: Verify Fault and Alarm
    Log  Step 6: Verify Fault and Alarm after RMOD reset  console=true
    ${status_alarm10}  Run Keyword and Return Status  Assert Alarm Inactive  faultId=10, alarmId=7116, faultName="No connection to unit"  timeout=60
    Run Keyword if  ${status_alarm10}
    ...  Log  Alarm with faultId 10 is inactive.  console=true
    ...  ELSE
    ...  Set Test Failed  Alarm with faultId 10 is still active.
    ${status_alarm2002}  Run Keyword and Return Status
    ...  Assert Alarm Active  faultId=2002, alarmId=7116, faultName="Receiving failure in Optical Interface"  timeout=360
    Run Keyword if  ${status_alarm2002}
    ...  Log  Alarm with faultId 2002 is active.  console=true
    ...  ELSE
    ...  Set Test Failed  Alarm with faultId 2002 is still not visible.

Step 7: Restore Optical Fiber and Verify All Cells Are On Air
    Log  Step 7: Restore Optical Fiber and Verify All Cells Are On Air  console=true
    Power On  ${INTERFACES}[${PRIMARY_OPT_IF}][OUTLET]  pdu_device=${PDU_DEVICE}
    Sleep  10s  Wait for cablink to be connected.
    Assert Alarm Inactive  faultId=2002, alarmId=7116, faultName="Receiving failure in Optical Interface"  timeout=60
    Log  Check all cells after fiber restore  console=true
    Wait Until Keyword Succeeds  90  10  Check All Cells  ${OnAirDone_}  ${Enabled_}  ${Active_}
    Run Keyword And Ignore Error  Teardown PDU  pdu_device=${PDU_DEVICE}

Store Rmod
    [Documentation]  This KW stores the value of IP and MasterAgentDN
    [Arguments]  ${sn}
    ${rmod} =  _Get Rmod Object By Serial Number  ${sn}
    ${smod_l} =  Query Infomodel  get object ${rmod.masterAgentDN}
    ${smod_r} =  Query Infomodel  get object //CABINET_R-*/SMOD_R-* is [serialNumber=${smod_l.serialNumber}]
    Wait Until Keyword Succeeds  90s  10s  Should Be True  '${rmod.ipAddress}' != '0.0.0.0'
    ${RMOD_IP_addr}=  set variable  ${rmod.ipAddress}
    set test variable  ${smod_l}
    set test variable  ${smod_r}
    set test variable  ${RMOD_IP_addr}

Insert optical fiber
    [Documentation]  Keyword used in Teardown to reestablish the optical fiber connection.
    Setup Pdu  ${INTERFACES}[${PRIMARY_OPT_IF}][TYPE]  ${INTERFACES}[${PRIMARY_OPT_IF}][IP]  alias=turn_on
    Power On   ${INTERFACES}[${PRIMARY_OPT_IF}][OUTLET]  pdu_device=turn_on
    Wait Until Keyword Succeeds  300s  10s  Check All Cells  ${OnAirDone_}  ${Enabled_}  ${Active_}
    [Teardown]  Run Keyword And Ignore Error  Teardown Pdu  pdu_device=turn_on

TC Setup
    run keyword and continue on failure  Common Test Setup

TC Teardown
    Run Keyword If Test failed  Insert optical fiber
    Common Test Teardown








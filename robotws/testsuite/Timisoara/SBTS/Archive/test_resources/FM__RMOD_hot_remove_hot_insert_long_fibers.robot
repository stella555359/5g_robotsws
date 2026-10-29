*** Settings ***
Library    SSHLibrary
Resource    ../../common_resources/ca_FM_general.robot

*** Variables ***
${RMOD_SN}                             # Mandatory
${MIN_FIBER_LENGTH}  10000             # Mandatory
${PING_TIMEOUT}      1200
&{pdu_dict}  IP=10.255.1.14  TYPE=BBOXPSE
&{OPT_1}  OUTLET=3  PORT_1=SMOD_F7163523308  PORT_2=RMOD_6Q190905756  &{pdu_dict}

*** Keywords ***
TC__FM__RMOD_hot_remove_hot_insert_long_fibers
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-4040
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  TC will check if the given RMOD optical fiber length, if the length will not match the min length test will have restriction.
    ...  RMOD fiber hot remove, by powering off the outlet from the PSE BLACKBOX.
    ...  Verify fault and alarm after hot remove, cells on RMOD must be failed.
    ...  RMOD alarm No connection to unit is shown.
    ...  Verify if left over cells are not affected and are still online.
    ...  Verify fault and alarm after.
    ...  RMOD fiber hot insert, by powering on the outlet from the PSE BLACKBOX.
    ...  Verify if all cells are working.
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 04.03.2021 - https://jira3.ext.net.nokia.com/browse/TAT-20994 - Initial creation
    ...  - 24.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  - 26.01.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22478 - Fix for variable name
    ...  - 09.09.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-22214 - Ute cloud: FM__RMOD_hot_remove_hot_insert_long_fibers test fails
    ...  - 28.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23931 - Move keywords to resource file
    ...  - 14.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24111 - Migrate from hran_ssh to taf.transport.ssh
    ...  - 28.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25066 - Replace ute_pdu with taf.pdu
    ...  ******************

    Set Tags    CA-FM    OWNER-laura.craciunel@nokia.com    AUTHOR-bogdan.boldurean@nokia.com
    ...    MAINTAINER-laura.craciunel@nokia.com    GROUP_IN_CHARGE-TIM_4_Vrf    PHASE-CRT    SW-SBTS21

    Step 1: Check Initial State
    Step 2: Perform RF module hot remove optical fiber
    Step 3: Verify Fault and Alarm
    Step 4: RMOD Verification after hot remove
    Step 5: Verify Cells on Other RMODs
    Step 6: Perform RF module hot insert optical fiber
    Step 7: RMOD Verification after hot insert
    Step 8: Verify All Cells On Air

Step 1: Check Initial State
    Log  Step 1: Check Initial State  console=true
    Run keyword if  ${tl}
    ...  Append variable to interfaces dictionary
    ${rmod}  Query infomodel  get object //RMOD_R-* is [serialNumber=${RMOD_SN}]
    ${cablink}  Query infomodel  get object //CABLINK_R-* is [secondEndpointDN=${rmod}[dist_name]]
    Check fiber length  ${cablink}[fiberLength]
    ${BBMOD_OBJECT}  Query Infomodel  get object ${cablink}[firstEndpointDN]
    ${module_type}  Get module type  ${BBMOD_OBJECT}[dist_name]
    Set Test Variable  ${BBMOD_SN}  ${BBMOD_OBJECT}[serialNumber]
    ${PDU_items}=  Get PDU Optical Interface Info List  port_1=${module_type}_${BBMOD_SN}  port_2=RMOD_${RMOD_SN}
    Set Test Variable  ${OPT_IF}  ${PDU_items}[0]
    Store Rmod  ${RMOD_SN}
    ${rmod_l}  Infomodel Get RMOD By Serial Number  ${RMOD_SN}
    ${RMOD_CELLS} =  Infomodel Get Cells Deployed On Module  ${rmod_l}
    ${LEFT_OVER_CELLS} =  Query Infomodel  get list //CELL_M-*
    Remove Values From List  ${LEFT_OVER_CELLS}  @{RMOD_CELLS}
    Set Test Variable  ${RMOD_CELLS}
    Set Test Variable  ${LEFT_OVER_CELLS}
    ${PDU_DEVICE}  Setup Pdu  ${INTERFACES}[${OPT_IF}][TYPE]  ${INTERFACES}[${OPT_IF}][IP]
    Set test variable  ${PDU_DEVICE}

Append variable to interfaces dictionary
    Log  Test variable to interfaces.  console=true
    Add variables in interfaces  OPT_1  ${OPT_1}

Check fiber length
    [Arguments]  ${length}
    ${status}  run keyword and return status  Should Be True  ${length}>=${MIN_FIBER_LENGTH}
    Run keyword if  ${status}
    ...  Log  Fiber length is ${length}.  console=true
    ...  ELSE
    ...  Fail  Fiber length is less than ${MIN_FIBER_LENGTH}m, found ${length}m.

Get module type
     [Arguments]  ${module_dn}
     ${module_type}  Run Keyword and Return Status  Should Contain  ${module_dn}  BBMOD
     Run keyword if  ${module_type}
     ...  Return From Keyword  BBMOD
     ...  ELSE
     ...  Return From Keyword  SMOD

Get module by serial number
    [Arguments]  ${serial_number}
    ${is_bbmod}  run keyword and return status  Query Infomodel  get object //BBMOD_R-* is [serialNumber=${serial_number}]
    ${is_smod}  run keyword and return status  Query Infomodel  get object //SMOD_R-* is [serialNumber=${serial_number}]
    ${module}  Run Keyword If  ${is_bbmod}
    ...  Set Variable  BBMOD
    ...  ELSEIF  ${is_smod}
    ...  Set Variable  SMOD
    [Return]  ${module}

Step 2: Perform RF module hot remove optical fiber
    Log  Step 2: Perform RF module hot remove optical fiber  console=true
    Power Off  ${INTERFACES}[${OPT_IF}][OUTLET]  pdu_device=${PDU_DEVICE}
    Wait Until Keyword Succeeds  30s  6  Ping Rmod  ${RMOD_SN}  1   #1 means ping should fail
    Sleep  30

Step 3: Verify Fault and Alarm
    Log  Step 3: Verify Fault and Alarm  console=true
    Assert Alarm Active  faultId=10, alarmId=7116, faultName="No connection to unit"  timeout=300
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
        ...  Set Test Failed
        ...  Cell ${im_cell.dist_name} is in unexpected status: availability_status=${availability} and operational_status=${operational}.
    END

Step 4: RMOD Verification after hot remove
    Log  Step 4: RMOD Verification after hot remove  console=true
    ${rmod}  Query infomodel  get object //RMOD_R-* is [serialNumber=${RMOD_SN}]
    Wait Until Keyword Succeeds  300s  10  Verify RMOD status  ${Disabled_}  ${NotInstalled_}

Step 5: Verify Cells on Other RMODs
    Log  Step 5: Verify Cells on Other RMODs  console=true
    Verify cells status  ${LEFT_OVER_CELLS}  Online  Enabled

Step 6: Perform RF module hot insert optical fiber
    Log  Step 6: Perform RF module hot insert optical fiber  console=true
    Power On  ${INTERFACES}[${OPT_IF}][OUTLET]  pdu_device=${PDU_DEVICE}
    Log  TC will wait for maximum of ${PING_TIMEOUT} seconds for ping to RMOD ${RMOD_SN} to be reestablished.  console=true
    Wait Until Keyword Succeeds  ${PING_TIMEOUT}s  10  Ping Rmod  ${RMOD_SN}
    Wait Until Keyword Succeeds  30s  6  Assert Alarm Inactive  faultId=10, alarmId=7116, faultName="No connection to unit"  timeout=300

Step 7: RMOD Verification after hot insert
    Log  Step 7: RMOD Verification after hot insert  console=true
    ${rmod}  Query infomodel  get object //RMOD_R-* is [serialNumber=${RMOD_SN}]
    Wait Until Keyword Succeeds  300s  10  Verify RMOD status  ${Enabled_}

Step 8: Verify All Cells On Air
    Log  Step 8: Verify All Cells On Air  console=true
    Wait Until Keyword Succeeds  300  10  Check All Cells  ${OnAirDone_}  ${Enabled_}  ${Active_}
    Run Keyword And Ignore Error  Teardown PDU  pdu_device=${PDU_DEVICE}

Store Rmod
    [Documentation]  This KW stores the value of IP and MasterAgentDN
    [Arguments]  ${sn}
    ${rmod} =  Infomodel Get RMOD By Serial Number  ${sn}
    ${smod_l} =  Query Infomodel  get object ${rmod.masterAgentDN}
    ${smod_r} =  Query Infomodel  get object //CABINET_R-*/SMOD_R-* is [serialNumber=${smod_l.serialNumber}]
    Wait Until Keyword Succeeds  90s  10s  Should Be True  '${rmod.ipAddress}' != '0.0.0.0'
    ${RMOD_IP_addr}=  set variable  ${rmod.ipAddress}
    set test variable  ${smod_l}
    set test variable  ${smod_r}
    set test variable  ${RMOD_IP_addr}

Ping Rmod
    [Arguments]  ${sn}  ${expected_rc}=0
    Wait Until Keyword Succeeds  90s  10s  Should Be True  '${RMOD_IP_addr}' != '0.0.0.0'
    ${is_airscale}=  Run Keyword And Return Status  Should Contain  ${smod_r.productName}  AirScale
    ${command}=  Run Keyword If  ${is_airscale}
    ...  Make Command For AirScale  ping -c1 ${RMOD_IP_addr}  ${smod_r}
    ...  ELSE
    ...  Set Variable  ping -c1 ${RMOD_IP_addr}
    Connect to SMOD  ${smod_l.ipAddress}
    ssh.Execute  ${command}
    ssh.Assert exit status  ${expected_rc}

Make Command For AirScale
    [Arguments]  ${command}  ${smod_r}
    Return From Keyword  lxc-attach -n 0x${smod_r.horizontalPosition}018 -- ${command}


Insert optical fiber and reset site
    [Documentation]  Keyword used in Teardown to reestablish the optical fiber connection.
    Power On  ${INTERFACES}[${OPT_IF}][OUTLET]  pdu_device=${PDU_DEVICE}
    Run Keyword And Ignore Error  Teardown Pdu  pdu_device=${PDU_DEVICE}
    coam.Reset Site
    Wait Until Keyword Succeeds  300s  10s  Check All Cells  ${OnAirDone_}  ${Enabled_}  ${Active_}

TC Setup
    Common Test Setup

TC Teardown
    Run Keyword If Test Failed  Insert optical fiber and reset site
    Common Test Teardown








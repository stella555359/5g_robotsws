*** Settings ***
Resource    ../../common_resources/ca_FM_general.robot

*** Variables ***
${STARTUP_TIMEOUT}              600                                                       # Timeout for SBTS to recover after site reset
${EXPECTED_FAULT_ID}            2074                                                      # Expected fault id that will be checked by test
${EXPECTED_FAULT_NAME}          BBPOOL autonomous reset as recovery action                # Expected fault name that will be checked by test
${FAULT_NAME_SECOND_TRIGGER}    Baseband card autonomous reset as recovery action         # Expected second fault name that will be checked by test
${EXPECTED_ALARM_ID}            7101                                                      # Expected alarm id that will be checked by test
${EXPECTED_ALARM_NAME}          BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION           # Expected alarm name that will be checked by test
${SEVERITY}                     Warning                                                   # Expected severity that will be checked by test

*** Keywords ***
TC__FM__BBPOOL_reset_allowBbPoolRecoveryReset_true
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-21638
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This test is created to trigger BBPOOL recovery reset
    ...  AllowBbPoolRecoveryReset and actForceUnitAutoReset are set to true
    ...  Before fault triggering, site reset is performed to clear all counters
    ...  Test will randomly select BBMOD which contains LTE cells on power group 2
    ...  Fault generation method is used to trigger fault 2074 with fault name "BBPOOL autonomous reset as recovery action"
    ...  The same fault will be triggered twice
    ...  After every trigger, cells, core and alarm status are checked and should be on air
    ...  If test fails, recovery action is performed
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 22.07.2021 - https://jira3.int.net.nokia.com/browse/TAT-21638 - Initial TAT creation
    ...  - 01.02.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22577 - ta_netact_* libary replacement with taf.nms.netact
    ...  - 22.06.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23301 - Change fault sending method from FM TCs
    ...  - 17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  - 15.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25658 - Create new resources for NetAct and ONAP KWs
    ...  - 05.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26813 - Refactor FM testcase for assert alarm active parameters
    ...  *******************

    Set Tags    CA-FM  OWNER-laura.craciunel@nokia.com  AUTHOR-anna.benzar@nokia.com
    ...    MAINTAINER-anna.benzar@nokia.com    GROUP_IN_CHARGE-TIM_4_Vrf    PHASE-CRT  SW-SBTS21

    Step 1: Commission allowBbPoolRecoveryReset/actForceUnitAutoReset to true
    Step 2: Trigger fault on LTE FSP first time
    Step 3: Trigger fault on LTE FSP second time

Step 1: Commission allowBbPoolRecoveryReset/actForceUnitAutoReset to true
    Log  \nStep 1:Commissioning allowBbPoolRecoveryReset & actForceUnitAutoReset to true  console=true
    Set actForceUnitAutoReset value  actForceUnitAutoReset  true
    Change parameter allowBbPoolRecoveryReset  true

    Log  Checking modules, cells and alarms after changing parameters  console=true
    Check modules, cells and alarms
    Log  Resetting site to clear all counters  console=true
    coam.Reset site  ${STARTUP_TIMEOUT}
    ${status}  Run keyword and return status  Wait until keyword succeeds  ${STARTUP_TIMEOUT}  20  Check modules, cells and alarms
    Run keyword if  ${status}
    ...  Log  Site up and running after reset  console=true
    ...  ELSE
    ...  Fail  Site didn't manage to reset
    ${faultParams}=  Create List  180
    Set Test Variable  ${PARAMS}  ${faultParams}

Step 2: Trigger fault on LTE FSP first time
    Log  \nStep 2:Triggering fault on LTE FSP first time  console=true
    Sleep  10
    Set sender and receiver
    send_fault_ind_msg  ${SENDER}  ${RECEIVER}  2074  1  fault_params=@{PARAMS}
    Verify SBTS after fault triggering  first trigger
    Verify SBTS After Recovery  first trigger

Step 3: Trigger fault on LTE FSP second time
    Log  \nStep 3:Triggering fault on LTE FSP second time  console=true
    send_fault_ind_msg  ${SENDER}  ${RECEIVER}  2074  1  fault_params=@{PARAMS}
    Verify SBTS after fault triggering  second trigger
    Verify SBTS After Recovery  second trigger

Set actForceUnitAutoReset value
    [Arguments]  ${parameter}  ${value}
    ${parameter_initial_value}  Get actForce(Unit)AutoReset value from infomodel  ${parameter}
    ${status}  Run keyword and return status  Should contain  ${parameter_initial_value}  ${value}
    Run keyword if  ${status}
    ...  Log  ${parameter} already set to ${value}, no need to be changed  console=true
    ...  ELSE
    ...  Change actForceUnitAutoReset value and show message  ${value}  ${parameter}

Change actForceUnitAutoReset value and show message
    [Arguments]  ${value}  ${parameter}
    Change parameter actForce(Unit)AutoReset  ${value}  ${parameter}
    ${parameter_changed}  Get actForce(Unit)AutoReset value from infomodel  ${parameter}
    Log  Value of ${parameter} after changing is: ${parameter_changed}  console=true

Check modules, cells and alarms
    ${list_modules_cells}  Create List  SMOD  BBMOD  RMOD
    Run keyword if  ${SCF_COUNT_NR}
    ...  Append to list  ${list_modules_cells}  NRCEL
    Run keyword if  ${SCF_COUNT_LTE}
    ...  Append to list  ${list_modules_cells}  LNCEL
    Run keyword if  ${SCF_COUNT_WCDMA}
    ...  Append to list  ${list_modules_cells}  WNCEL
    Run keyword if  ${SCF_COUNT_GSM}
    ...  Append to list  ${list_modules_cells}  GNCEL
    FOR  ${it}  IN  @{list_modules_cells}
        Assert every  ${it}  operationalState=${Enabled_}
    END
    Admin Check Active Alarms TAF

Set sender and receiver
    Get BBMOD
    ${dsp}  evaluate  random.choice([5,6])   random
    ${dsp_core}  evaluate  random.randint(1,8)   random
    ${SENDER}  Set variable  0X${CORE}${ID_BBMOD}${dsp}${dsp_core}0240
    ${RECEIVER}  Run keyword if  '${CORE}'=='1'
    ...  Set variable  0x10110009
    ...  ELSE
    ...  Set variable  0x20110009
    ${NODE_ID}  Convert To Integer  0X${CORE}${ID_BBMOD}${dsp}${dsp_core}
    set test variable  ${SENDER}
    set test variable  ${RECEIVER}
    set test variable  ${NODE_ID}

Get BBMOD
    ${bbmod_l_list}  Get BBMODs for RAT  LTE
    ${length}  get length  ${bbmod_l_list}
    ${index}  evaluate  random.randint(0,${length}-1)   random
    ${bbmod_l}  get from list  ${bbmod_l_list}  ${index}
    set test variable  ${BBMOD_L}  ${bbmod_l}
    ${core}  ${id_bbmod}  Get BBMOD position  ${BBMOD_L}
    set test variable  ${CORE}  ${core}
    set test variable  ${ID_BBMOD}  ${id_bbmod}
    set test variable  ${BBMOD_L}  ${bbmod_l}

Get BBMODs for RAT
    [Arguments]  ${rat}
    ${soc_list}  query infomodel  get list //BBMOD_L-*/BBU_L-1/POWER_GROUP_L-2/SOC_L-*
    ${bbmod_rat}  create list
    FOR  ${bbmod}  IN  @{soc_list}
       Run keyword if  '${bbmod.rat}'=='${rat}'
       ...  Append to list  ${bbmod_rat}  ${bbmod.dist_name}
    END
    ${status}  Run keyword and return status  Should not be empty  ${bbmod_rat}
    Run keyword unless  ${status}
    ...  Fail  No LTE cells on PG2  console=true
    ${bbmod}  create list
    FOR  ${distname}  IN  @{bbmod_rat}
      ${dist}  fetch from left  ${distname}  /BBU_L
      append to list  ${bbmod}  ${dist}
    END
    ${bbmod_list}  remove duplicates  ${bbmod}
    [Return]  ${bbmod_list}

Get BBMOD position
    [Arguments]  ${bbmod_l}
    ${bbmod}  Query Infomodel  get object ${bbmod_l}
    ${bbmod_r}  Query Infomodel  get object //BBMOD_R-* is [serialNumber=${bbmod.serialNumber}]
    set test variable  ${BBMOD_R}  ${bbmod_r}
    [Return]  ${bbmod_r.horizontalPosition}  ${bbmod_r.verticalPosition}

Verify SBTS after fault triggering
    [Arguments]  ${trigger}
    Log  Veryfing SBTS after fault triggering - ${trigger}  console=true
    ${bbmod_obj}  query infomodel  get object ${BBMOD_L}
    ${cells_on_bbmod}  Infomodel Get Cells Deployed On Module  ${bbmod_obj}
    ${status}  Run keyword and return status  Wait until keyword succeeds  180  10
    ...  Verify cells supported by FSP  ${cells_on_bbmod}
    ...                                 Disabled
    ...                                 Failed
    ...                                 Faulty
    ...                                 ${trigger}
    Run keyword if  ${status}
    ...  Log  At least ${NO_AFFECTED_CELLS} cell/s are in Faulty state after ${trigger}  console=true

    Run keyword if  '${trigger}' == 'first trigger'
    ...  Verify core status  Unlocked  Offline  Disabled  Resetting
    ...  ELSE
    ...  Verify core status  Locked  Offline  Disabled  NotDetected

    ${date}  Get Current Date  time_zone=UTC  result_format=datetime
    Set Test Variable  ${START_TIME}  ${date}
    ${status_alarm_webem}  Run keyword and return status   Assert Alarm Active
    ...  parameters=alarmId=${EXPECTED_ALARM_ID}, faultId=${EXPECTED_FAULT_ID}
    ...  timeout=180
    Run keyword if  ${status_alarm_webem}
    ...  Log  Alarm ${EXPECTED_ALARM_ID} with fault ${EXPECTED_FAULT_ID} reported in WebEm  console=true
    ...  ELSE
    ...  Fail  Alarm ${EXPECTED_ALARM_ID} with fault ${EXPECTED_FAULT_ID} not reported in WebEm
    ${status_netact_alarm}  Run keyword and return status  Wait until keyword succeeds  180  10
    ...  Verify alarm present in NetAct after fault triggering  ${trigger}

    Run keyword if  ${status_netact_alarm}
    ...  Log  Alarm ${EXPECTED_ALARM_ID} with fault ${EXPECTED_FAULT_ID} reported & cleared from NetAct  console=true
    ...  ELSE
    ...  Log  Alarm ${EXPECTED_ALARM_ID} with fault ${EXPECTED_FAULT_ID} not reported & cleared from NetAct  console=true

Verify cells supported by FSP
    [Arguments]  ${bbmod_cells}  ${op_state}  ${av_status}  ${expected_state}  ${trigger}
    ${list_affected_cells}  Create list
    FOR  ${it}  IN  @{bbmod_cells}
        ${affected_cell_obj}  Query infomodel  get object ${it}[dist_name]
        ${operational_state}=  Set Variable  ${affected_cell_obj}[stateInfo][operationalState]
        ${availability_status}=  Set Variable  ${affected_cell_obj}[stateInfo][availabilityStatus]
        Run keyword if  '${operational_state}' == '${op_state}' and '${availability_status}' == '${av_status}'
        ...  Append to list  ${list_affected_cells}  ${affected_cell_obj}
    END
    ${no_affected_cells}  Get length  ${list_affected_cells}
    Set test variable  ${NO_AFFECTED_CELLS}  ${no_affected_cells}
    Set test variable  ${AFFECTED_BBMOD_CELLS}  ${list_affected_cells}

    Run keyword if  '${trigger}' == 'first trigger'
    ...  Verify only affected cells  ${no_affected_cells}  ${trigger}
    ...  ELSE
    ...  Verify that all cells are affected  ${no_affected_cells}  ${bbmod_cells}  ${expected_state}  ${trigger}

Verify only affected cells
    [Arguments]  ${no_affected_cells}  ${trigger}
    Run keyword if  ${no_affected_cells} == 0
    ...  Fail  No affected cells after ${trigger}

Verify that all cells are affected
    [Arguments]  ${no_affected_cells}  ${bbmod_cells}  ${expected_state}  ${trigger}
    ${no_total_cells}  Get length  ${bbmod_cells}
    Run keyword if  ${no_total_cells} != ${no_affected_cells}
    ...  Fail  Not all cells are faulty after ${trigger}

Verify alarm present in NetAct after fault triggering
    [Arguments]  ${trigger}
    ${status}  Run keyword if  '${trigger}' == 'first trigger'
    ...  Run keyword and return status
    ...  Check additional information for given alarm and fault in NA cleared alarms  ${EXPECTED_FAULT_ID}
    ...                                                                               ${EXPECTED_FAULT_NAME}
    ...                                                                               ${EXPECTED_ALARM_ID}
    ...                                                                               ${EXPECTED_ALARM_NAME}
    ...                                                                               ${SEVERITY}
    ...                                                                               ${START_TIME}
    ...  ELSE
    ...  Run keyword and return status
    ...  Check additional information for given alarm and fault in NA cleared alarms  ${EXPECTED_FAULT_ID}
    ...                                                                               ${FAULT_NAME_SECOND_TRIGGER}
    ...                                                                               ${EXPECTED_ALARM_ID}
    ...                                                                               ${EXPECTED_ALARM_NAME}
    ...                                                                               ${SEVERITY}
    ...                                                                               ${START_TIME}
    Run keyword unless  ${status}
    ...  Fail  Alarm ${EXPECTED_ALARM_ID} with fault ${EXPECTED_FAULT_ID} not cleared from NetAct after fault triggering  console=true

Verify core status
    [Arguments]  ${adm_state}  ${av_status}  ${op_state}  ${proced_state}
    ${status_core}  Run keyword and return status  Wait until keyword succeeds  240  10
    ...  Verify core status Resetting/NotDetected/RoutingLoaded  ${adm_state}
    ...                                                          ${av_status}
    ...                                                          ${op_state}
    ...                                                          ${proced_state}
    Run keyword if  ${status_core}
    ...  Log  Core status: ${proced_state}  console=true

Verify core status Resetting/NotDetected/RoutingLoaded
    [Arguments]  ${adm_state}  ${av_status}  ${op_state}  ${proced_state}
    ${core}  query infomodel  get object //CORE_L-* is [nodeId=${NODE_ID}]
    ${condition}  Catenate  SEPARATOR=${SPACE}and${SPACE}
    ...  '${core.stateInfo}[administrativeState]'=='${adm_state}'
    ...  '${core.stateInfo}[availabilityStatus]'=='${av_status}'
    ...  '${core.stateInfo}[operationalState]'=='${op_state}'
    ...  '${core.stateInfo}[proceduralState]'=='${proced_state}'
    Run Keyword unless  ${condition}
    ...  Fail  Core status not ok

Verify SBTS After Recovery
    [Arguments]  ${trigger}
    ${alarm_status}  Run keyword and return status  Wait until keyword succeeds  180  10
    ...  Assert Alarm Inactive  parameters=alarmId=7101, faultId=2074  timeout=180
    Run keyword if  ${alarm_status}
    ...  Log  Alarm 7101 BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION cleared from WebEm  console=true
    ...  ELSE
    ...  Fail  Alarm 7101 BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION still present in WebEm
    ${status}  Run keyword and return status  Wait until keyword succeeds  300  10
    ...  Verify affected cells after recovery  ${AFFECTED_BBMOD_CELLS}
    ...                                        Enabled
    ...                                        Online
    ...                                        up
    ...                                        ${trigger}
    Run keyword if  ${status}
    ...  Log  All cells supported by FSP are in expected state: Enabled  console=true
    Verify core status  Unlocked  Online  Enabled  RoutingLoaded


Verify affected cells after recovery
    [Arguments]  ${affected_cells}  ${op_state}  ${av_status}  ${expected_state}  ${trigger}
    ${list_affected_cells}  Create list
    FOR  ${it}  IN  @{affected_cells}
        ${affected_cell_obj}  Query infomodel  get object ${it}[dist_name]
        ${operational_state}=  Set Variable  ${affected_cell_obj}[stateInfo][operationalState]
        ${availability_status}=  Set Variable  ${affected_cell_obj}[stateInfo][availabilityStatus]
        Run keyword if  '${operational_state}' == '${op_state}' and '${availability_status}' == '${av_status}'
        ...  Fail  Not all cells are ${expected_state} after recovery
    END


TC Setup
    Common Test Setup
    Setup NetAct

TC Teardown
    Set actForceUnitAutoReset value  actForceUnitAutoReset  false
    ${status}  Run keyword and return status  Check modules, cells and alarms
    Run keyword unless  ${status}
    ...  coam.Reset site  ${STARTUP_TIMEOUT}
    Teardown NetAct
    Common Test Teardown

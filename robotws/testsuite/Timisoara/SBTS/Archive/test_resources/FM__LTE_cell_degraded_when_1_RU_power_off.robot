*** Settings ***
Resource    ../../common_resources/ca_FM_general.robot

*** Variables ***
${STARTUP_TIMEOUT}               900                                                    # Timeout for SBTS to recover after site reset
${TECHNOLOGY}                    LNCEL                                                  # Cells type deployed on RMOD which needs to be powered off
${ALARM_TIMEOUT}                 300                                                    # Timeout for alarms to appear or disappear
${EXPECTED_FAULT_ID}             10                                                     # Expected fault id that will be checked by test
${EXPECTED_FAULT_ID_SECOND}      4003                                                   # Expected second fault id that will be checked by test
${EXPECTED_FAULT_NAME}           No connection to unit                                  # Expected fault name that will be checked by test
${EXPECTED_FAULT_NAME_SECOND}    Transmission path failure                              # Expected second fault name that will be checked by test
${EXPECTED_ALARM_ID}             7116                                                   # Expected alarm id that will be checked by test
${EXPECTED_ALARM_ID_SECOND}      7115                                                   # Expected second alarm id that will be checked by test
${EXPECTED_ALARM_NAME}           BASE STATION SERVICE PROBLEM                           # Expected alarm name that will be checked by test
${EXPECTED_ALARM_NAME_SECOND}    BASE STATION INFORMATION                               # Expected second alarm name that will be checked by test
${SEVERITY}                      Minor                                                  # Expected severity that will be checked by test

*** Keywords ***
FM__LTE_cell_degraded_when_1_RU_power_off
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-24507
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This test is created to power off and on, one RMOD that has 4G cells deployed on it.
    ...  Site reset is performed to clear all counters.
    ...  RMOD is turned off; alarm and cells state are checked.
    ...  If the cells that are deployed on the chosen RMOD are deployed on another RMOD too,
    ...  a second alarm must be checked on every impacted cell and their state must be only enabled and degraded,
    ...  not disabled and failed(like the cells that are deployed only on one RMOD).
    ...  RMOD is powered on and all services must be enabled.
    ...  ******************
    ...  18.01.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24507 - Initial TAT creation
    ...  17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  15.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25658 - Create new resources for NetAct and ONAP KWs
    ...  ******************

    Set Tags        CA-FM  OWNER-florin-sebastian.nedelcu@nokia.com  AUTHOR-anna.benzar@nokia.com
    ...             MAINTAINER-anna.benzar@nokia.com    GROUP_IN_CHARGE-TIM_4_Vrf    PHASE-CRT  SW-SBTS20

    Step0: Set preconditions
    Step1: Perform Site Reset
    Step2: Power off RMOD
    Step3: Check cells and alarm status
    Step4: Power on RMOD
    Step5: Check cells and SBTS status

Step0: Set preconditions
    Log  \nStep0: Set preconditions.  console=true
    ${RMOD_DN}  ${RMOD_SN}  ${RMOD_CELLS}  Get module info based on technology  RMOD   ${TECHNOLOGY}
    FOR  ${cell}  IN  @{RMOD_CELLS}
        ${tech_status}  Run keyword and return status  Should contain  ${cell}  ${TECHNOLOGY}
        Run keyword unless  ${tech_status}
        ...   Remove values from list  ${RMOD_CELLS}  ${cell}
    END
    ${DEPLOYMENT_STATUS}  Verify if cells are deployed on another module  RMOD  ${RMOD_SN}  ${RMOD_CELLS}
    Set test variable  ${RMOD_DN}
    Set test variable  ${RMOD_SN}
    Set test variable  ${RMOD_CELLS}
    Set test variable  ${DEPLOYMENT_STATUS}
    Run keyword if  ${DEPLOYMENT_STATUS}
    ...  Set syncSigTxMode parameter for LTE  ${RMOD_CELLS}
    Log  RMOD with serial number: ${RMOD_SN} chosen.  console=true

Step1: Perform Site Reset
    Log  \nStep1: Perform Site Reset to clear all counters.  console=true
    Perform site reset

Step2: Power off RMOD
    Log  \nStep2: Power off 1 RMOD where ${TECHNOLOGY} technology is mapped.  console=true
    Log  Turning off RMOD.  console=true
    Pdu BTS Interface Off  RMOD_${RMOD_SN}
    Log  Verifying alarm on RMOD - active.  console=true
    ${alarm_parameters}  Catenate  faultId=${EXPECTED_FAULT_ID}, alarmId=${EXPECTED_ALARM_ID},
    ...  faultName="${EXPECTED_FAULT_NAME}", alarmName="${EXPECTED_ALARM_NAME}"
    ${alarm_status}  Run keyword and return status  Assert alarm active  parameters=${alarm_parameters}  timeout=${ALARM_TIMEOUT}
    Run keyword if  ${alarm_status}
    ...  Log  Alarm ${EXPECTED_FAULT_ID}: ${EXPECTED_FAULT_NAME}, reported in WebEM. [OK]  console=true
    ...  ELSE
    ...  Fail  Alarm ${EXPECTED_FAULT_ID}: ${EXPECTED_FAULT_NAME}, not reported in WebEM. [NOK]

Step3: Check cells and alarm status
    Log  \nStep3: Check ${TECHNOLOGY} cells status mapped on RMOD.  console=true
    Run keyword if  ${DEPLOYMENT_STATUS}
    ...  Run keywords  Verify cells operationalState and availabilityStatus  ${RMOD_CELLS}  ${Enabled_}  ${Degraded_}  AND
    ...  Verify if alarm with fault 4003 is active on every cell in WebEM and Netact    ${RMOD_CELLS}
    ...  ELSE
    ...  Verify cells operationalState and availabilityStatus  ${RMOD_CELLS}  ${Disabled_}  ${Failed_}

Step4: Power on RMOD
    Log  \nStep4: Power on RMOD where ${TECHNOLOGY} technology is mapped.  console=true
    Log  Turning on RMOD.  console=true
    Pdu BTS Interface On  RMOD_${RMOD_SN}
    ${TIME_FROM}  Get Current Date  time_zone=UTC  result_format=datetime
    Set test variable  ${TIME_FROM}
    Log  Verifying alarm on RMOD - inactive.  console=true
    ${alarm_parameters}  Catenate  faultId=${EXPECTED_FAULT_ID}, alarmId=${EXPECTED_ALARM_ID},
    ...  faultName="${EXPECTED_FAULT_NAME}", alarmName="${EXPECTED_ALARM_NAME}"
    ${alarm_status}  Run keyword and return status  Assert alarm inactive  parameters=${alarm_parameters}  timeout=${ALARM_TIMEOUT}
    Run keyword if  ${alarm_status}
    ...  Log  Alarm ${EXPECTED_FAULT_ID}: ${EXPECTED_FAULT_NAME}, cleared from WebEM. [OK]  console=true
    ...  ELSE
    ...  Fail  Alarm ${EXPECTED_FAULT_ID}: ${EXPECTED_FAULT_NAME}, still visible in WebEM. [NOK]
    Run keyword if  ${DEPLOYMENT_STATUS}
    ...   Verify if alarm with fault 4003 is cleared from every cell in WebEM and Netact  ${RMOD_CELLS}

Step5: Check cells and SBTS status
    Log  \nStep5: Check cells and modules.  console=true
    ${sbts_status}  Run keyword and return status  Wait until keyword succeeds  ${STARTUP_TIMEOUT}  30  Check modules and cells
    Run keyword if  ${sbts_status}
    ...  Log  All services are enabled.  console=true
    ...  ELSE
    ...  Fail  SBTS didn't manage to get on air.

Verify cells operationalState and availabilityStatus
    [Arguments]  ${cells_list}  ${op_state}  ${av_status}
    FOR  ${cell_dn}  IN  @{cells_list}
        ${cell_id}  Fetch from right  ${cell_dn}  /
        ${cell_class_name}  Get regexp matches  ${cell_dn}  [A-Z]{2}CEL
        ${cell_status}  Run keyword and return status  Assert  ${cell_class_name}[0]  id=${cell_dn}
        ...  parameters=operationalState=${op_state}, availabilityStatus=${av_status}  timeout=180
        Run keyword unless  ${cell_status}
        ...  Fail  Cell with id: ${cell_id} does not have the expected state. [NOK]
    END
    Log  Given cells list has the expected state.  console=true

Verify if alarm with fault 4003 is active on every cell in WebEM and Netact
    [Arguments]  ${module_cells}
    FOR  ${cell_dn}  IN  @{module_cells}
        ${cell_id}  Fetch from right  ${cell_dn}  -
        Check if alarm is active in WebEM   ${cell_dn}  ${cell_id}
        Check if alarm is active in Netact  ${cell_id}
    END

Check if alarm is active in WebEM
    [Arguments]  ${cell_dn}  ${cell_id}
    ${alarm_parameters}  Catenate  faultId=${EXPECTED_FAULT_ID_SECOND}, alarmId=${EXPECTED_ALARM_ID_SECOND},
    ...  faultName="${EXPECTED_FAULT_NAME_SECOND}", alarmName="${EXPECTED_ALARM_NAME_SECOND}", alarmingResource=${cell_dn}
    ${status_alarm_WebEM}  Run keyword and return status  Assert alarm active  parameters=${alarm_parameters}  timeout=${ALARM_TIMEOUT}
    Run keyword if  ${status_alarm_WebEM}
    ...  Log  Alarm ${EXPECTED_FAULT_ID_SECOND}:${EXPECTED_FAULT_NAME_SECOND}, active on cell with id: ${cell_id}, in WebEM. [OK]  console=true
    ...  ELSE
    ...  Fail  Alarm ${EXPECTED_FAULT_ID_SECOND}:${EXPECTED_FAULT_NAME_SECOND}, not active on cell with id: ${cell_id}, in WebEM. [NOK]

Check if alarm is active in Netact
    [Arguments]  ${cell_id}
    ${status_alarm_netact}  Run keyword and return status  Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  5s
    ...  Check additional information for given alarm and fault  fault_id=${EXPECTED_FAULT_ID_SECOND}
    ...                                                          fault_name=${EXPECTED_FAULT_NAME_SECOND}
    ...                                                          alarm_id=${EXPECTED_ALARM_ID_SECOND}
    ...                                                          alarm_name=${EXPECTED_ALARM_NAME_SECOND}
    ...                                                          severity=${SEVERITY}
    ...                                                          object_id=${cell_id}
    Run keyword if  ${status_alarm_netact}
    ...  Log  Alarm ${EXPECTED_FAULT_ID_SECOND}:${EXPECTED_FAULT_NAME_SECOND},active on cell with id: ${cell_id}, in NetAct. [OK]  console=true
    ...  ELSE
    ...  Fail  Alarm ${EXPECTED_FAULT_ID_SECOND}:${EXPECTED_FAULT_NAME_SECOND},not active on cell with id: ${cell_id}, in NetAct. [NOK]

Verify if alarm with fault 4003 is cleared from every cell in WebEM and Netact
    [Arguments]  ${module_cells}
    FOR  ${cell_dn}  IN  @{module_cells}
        ${cell_id}  Fetch from right  ${cell_dn}  -
        Check if alarm is cleared from WebEM   ${cell_dn}  ${cell_id}
        Check if alarm is cleared form Netact  ${cell_id}
    END

Check if alarm is cleared from WebEM
    [Arguments]  ${cell_dn}  ${cell_id}
    ${alarm_parameters}  Catenate  faultId=${EXPECTED_FAULT_ID_SECOND}, alarmId=${EXPECTED_ALARM_ID_SECOND},
    ...  faultName="${EXPECTED_FAULT_NAME_SECOND}", alarmName="${EXPECTED_ALARM_NAME_SECOND}", alarmingResource=${cell_dn}
    ${status_alarm_WebEM}  Run keyword and return status  Assert alarm inactive  parameters=${alarm_parameters}  timeout=${ALARM_TIMEOUT}
    Run keyword if  ${status_alarm_WebEM}
    ...  Log  Alarm ${EXPECTED_FAULT_ID_SECOND}:${EXPECTED_FAULT_NAME_SECOND},cleared from cell with id: ${cell_id},in WebEM.[OK]  console=true
    ...  ELSE
    ...  Fail  Alarm ${EXPECTED_FAULT_ID_SECOND}:${EXPECTED_FAULT_NAME_SECOND},didn't clear from cell with id: ${cell_id},in WebEM. [NOK]

Check if alarm is cleared form Netact
    [Arguments]  ${cell_id}
    ${status_alarm_netact}  Run keyword and return status  Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10s
    ...  Check additional information for given alarm and fault in NA cleared alarms  fault_id=${EXPECTED_FAULT_ID_SECOND}
    ...                                                                               fault_name=${EXPECTED_FAULT_NAME_SECOND}
    ...                                                                               alarm_id=${EXPECTED_ALARM_ID_SECOND}
    ...                                                                               alarm_name=${EXPECTED_ALARM_NAME_SECOND}
    ...                                                                               severity=${SEVERITY}
    ...                                                                               time_from=${TIME_FROM}
    ...                                                                               object_id=${cell_id}
    Run keyword if  ${status_alarm_netact}
    ...  Log  Alarm ${EXPECTED_FAULT_ID_SECOND}:${EXPECTED_FAULT_NAME_SECOND},cleared from cell with id: ${cell_id},in NetAct[OK]  console=true
    ...  ELSE
    ...  Fail  Alarm ${EXPECTED_FAULT_ID_SECOND}:${EXPECTED_FAULT_NAME_SECOND},didn't clear from cell with id: ${cell_id}, in NetAct. [NOK]

Perform recovery action
    ${rmod_status}  Run keyword and return status  Assert  RMOD  ${RMOD_DN}  parameters=operationalState=${Disabled_}
    Run keyword if  ${rmod_status}
    ...  Pdu BTS Interface On  RMOD_${RMOD_SN}
    Wait until keyword succeeds  300  10  Check modules and cells

TC Setup
    Common Test Setup
    Setup Netact

TC Teardown
    Run keyword if test failed  Perform recovery action
    Teardown Netact
    Common Test Teardown

*** Settings ***
Resource  ../../common_resources/ca_FM_general.robot

*** Variables ***
${STARTUP_TIMEOUT}               900                                                     # Timeout for SBTS to recover after site reset
${TECHNOLOGY}                    NRCEL                                                   # Cells type deployed on RMOD which needs to be powered off
${ALARM_TIMEOUT}                 300                                                     # Timeout for alarms to appear or disappear
${EXPECTED_FAULT_ID}             10                                                      # List of expected fault ids that will be checked by test
${EXPECTED_FAULT_NAME}           No connection to unit                                   # List of expected fault names that will be checked by test
${EXPECTED_ALARM_ID}             7116                                                    # List of expected alarm ids that will be checked by test
${EXPECTED_ALARM_NAME}           BASE STATION SERVICE PROBLEM                            # List of expected alarm names that will be checked by test

*** Keywords ***
FM__NR_cell_degraded_when_1_RU_power_off
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-24508
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This test is created to power off and on, one RMOD that has 5G cells deployed on it.
    ...  Site reset is performed to clear all counters.
    ...  RMOD is turned off; alarm and cells state are checked.
    ...  Last, RMOD is powered back on and all services must be operational.
    ...  ******************
    ...  18.01.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24508 - Initial TAT creation
    ...  17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  08.08.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25919 - Choose RMOD only if it's split
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
    ${rmods_list}  Get list of RMODs which split one technology  NR
    ${rmod_l_dn}   Evaluate  random.choice(${rmods_list})  random
    ${rmod_l_obj}  coam.Get parameters  ${rmod_l_dn}
    ${rmod_sn}     Set variable  ${rmod_l_obj}[serialNumber]
    ${rmod_dn}     Get module dist name by serial number and class  ${rmod_sn}  RMOD
    ${rmod_cells}  Get cell mapping by module id  ${rmod_dn}
    Set test variable  ${RMOD_DN}
    Set test variable  ${RMOD_SN}
    Set test variable  ${RMOD_CELLS}
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
    Verify availability status for RMOD cells

Step4: Power on RMOD
    Log  \nStep4: Power on RMOD where ${TECHNOLOGY} technology is mapped.  console=true
    Log  Turning on RMOD.  console=true
    Pdu BTS Interface On  RMOD_${RMOD_SN}
    Log  Verifying alarm on RMOD - inactive.  console=true
    ${alarm_parameters}  Catenate  faultId=${EXPECTED_FAULT_ID}, alarmId=${EXPECTED_ALARM_ID},
    ...  faultName="${EXPECTED_FAULT_NAME}", alarmName="${EXPECTED_ALARM_NAME}"
    ${alarm_status}  Run keyword and return status  Assert alarm inactive  parameters=${alarm_parameters}  timeout=${ALARM_TIMEOUT}
    Run keyword if  ${alarm_status}
    ...  Log  Alarm ${EXPECTED_FAULT_ID}: ${EXPECTED_FAULT_NAME}, cleared from WebEM. [OK]  console=true
    ...  ELSE
    ...  Fail  Alarm ${EXPECTED_FAULT_ID}: ${EXPECTED_FAULT_NAME}, still visible in WebEM. [NOK]

Step5: Check cells and SBTS status
    Log  \nStep5: Check cells and modules.  console=true
    ${sbts_status}  Run keyword and return status  Wait until keyword succeeds  ${STARTUP_TIMEOUT}  30  Check modules and cells
    Run keyword if  ${sbts_status}
    ...  Log  All services are enabled.  console=true
    ...  ELSE
    ...  Fail  SBTS didn't manage to get on air.

Get list of RMODs which split one technology
    [Arguments]  ${technology}
    ${cells_list}  Query infomodel  get list //CELL_M-* is [rat=${technology}]
    FOR  ${cell}  IN  @{cells_list}
       ${rmods_list}   Get list of RMODs by cell channel  ${cell}[dist_name]
       ${rmods_list}   Remove duplicates  ${rmods_list}
       ${list_length}  Get length  ${rmods_list}
       Run keyword if  ${list_length} >= 2
       ...  Return from keyword  ${rmods_list}
    END

Get list of RMODs by cell channel
    [Arguments]  ${cell_dn}
    ${rmods_list}  Create list
    ${cell_channels}  Query infomodel  get list ${cell_dn}/CHANNEL_GROUP_M-1/CHANNEL_M-*
    FOR  ${channel_m}  IN  @{cell_channels}
        ${channel_m_dn}  Set variable  ${channel_m}[dist_name]
        ${channel_m_path}  Query infomodel  get object ${channel_m_dn}/PATH-1
        ${devices_dns_list}  Set variable  ${channel_m_path}[devicesDNInPath]
        ${rmod}  Get rmod from devices dist names list  ${devices_dns_list}
        Append to list  ${rmods_list}  ${rmod}
    END
    Should not be empty  ${rmods_list}  msg=No RMODs found that split one technology. [NOK]
    [Return]  ${rmods_list}

Get rmod from devices dist names list
    [Arguments]  ${devices_dn_list}
    FOR  ${device_dn}  IN  @{devices_dn_list}
       ${rmod_dn}  Get regexp matches  ${device_dn}  .*RMOD_L-[0-9]*
       ${rmod_status}  Run keyword and return status  Should not be empty  ${rmod_dn}
       Run keyword if  ${rmod_status}
       ...  Return from keyword  ${rmod_dn}[0]
    END
    Fail  No RMOD found in devices dist names. [NOK]

Verify availability status for RMOD cells
    FOR  ${cell_dn}  IN  @{RMOD_CELLS}
        ${cell_id}  Fetch from right  ${cell_dn}  /
        ${cell_class_name}  Get regexp matches  ${cell_dn}  [A-Z]{2}CEL
        ${cell_degraded}  Run keyword and return status  Assert  ${cell_class_name}[0]  id=${cell_dn}
        ...                                                      parameters=availabilityStatus=${Degraded_}  timeout=30
        Run keyword if  ${cell_degraded}  Continue for loop
        ${cell_failed}    Run keyword and return status  Assert  ${cell_class_name}[0]  id=${cell_dn}
        ...                                                      parameters=availabilityStatus=${Failed_}  timeout=30
        Run keyword unless  ${cell_failed}
        ...  Fail  Cell with id: ${cell_id} does not have the expected state: Degraded or Failed. [NOK]
    END
    Log  Cells mapped on RMOD are in expected state. [OK]  console=true

Perform recovery action
    ${rmod_status}  Run keyword and return status  Assert  RMOD  ${RMOD_DN}  parameters=operationalState=${Disabled_}
    Run keyword if  ${rmod_status}
    ...  Pdu BTS Interface On  RMOD_${RMOD_SN}
    Wait until keyword succeeds  300  10  Check modules and cells

TC Setup
    Common Test Setup

TC Teardown
    Run keyword if test failed  Perform recovery action
    Common Test Teardown

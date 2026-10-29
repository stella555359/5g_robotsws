*** Settings ***
Resource    ../../common_resources/ca_FM_general.robot

*** Variables ***
${BBMOD_TYPE}                   ABIC                                                      # BBMOD type for testing
${STARTUP_TIMEOUT}              900                                                       # Timeout for SBTS to recover after site reset
${RECOVERY_TIMEOUT}             600                                                       # Timeout for SBTS to recover after tested scenario
${ALARM_TIMEOUT}                360                                                       # Timeout for alarm to appear or disappear
${NETACT_TIMEOUT}               60                                                        # Timeout for fault reporting in Netact
${EXPECTED_FAULT_ID}            6918                                                      # Expected fault id that will be checked by test
${EXPECTED_FAULT_NAME}          Baseband card autonomous reset as recovery action         # Expected fault name that will be checked by test
${EXPECTED_ALARM_ID}            7652                                                      # Expected alarm id that will be checked by test
${EXPECTED_ALARM_NAME}          BASE STATION NOTIFICATION                                 # Expected alarm name that will be checked by test
${SEVERITY}                     Warning                                                   # Expected severity that will be checked.
${PROCESS_NAME}                 ccsrt_daemon                                              # Process to be crashed by test
${SILENT_CRASH}                 ${FALSE}                                                  # Option for silent crash in command
${OPEN_SC_CONNECTION}           ${FALSE}                                                  # If BBMOD position on secondary core

*** Keywords ***
TC_FM__FID6918_fault_signature_active_CCS_RT_UP_process_crashed
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25011
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Test case will verify fault signature reporting function for UP and application crashes introduced with feature
    ...  CB008506 Fault improvement for crash reasons. Testing will involve provoking one L1 process crash to check if
    ...  autonomous recovery actions for fault 6918 are selected, handled and reported by sOAM in line with specification,
    ...  and moreover to check if the fault signature for fault 6918 works as properly.
    ...  *****************
    ...  History of changes
    ...  *****************
    ...  - 22.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25011 - Initial TAT creation
    ...  - 15.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25658 - Create new resources for NetAct and ONAP KWs
    ...  - 05.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26813 - Refactor FM testcase for assert alarm active parameters
    ...  - 06.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26772 - Option to disable alarm check on MantaRay
    ...  - 21.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27160 - Keyword enhancement in resource file
    ...  - 03.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27497 - Modify keyword in resource file
    ...  ******************

    Set Tags    CA-FM    OWNER-radu.steici@nokia.com    AUTHOR-laura.craciunel@nokia.com    MAINTAINER-laura.craciunel@nokia.com
    ...    GROUP_IN_CHARGE-TIM_4_Vrf    PHASE-CRT    SW-SBTS23    FEATURE-CB008506

    Step0: Set test variables
    Step1: Perform site reset
    Step2: Trigger RTHWAPI container crash
    Step3: Check fault signature
    Step4: Verify SBTS after recovery

Step0: Set test variables
    Log  Step0: Set test variables.  console=true
    Get BBMOD from configuration
    ${vertical}  Get module vertical position  ${BBMOD_DN}
    Set test variable  ${BBMOD_POSITION}  ${vertical}
    ${vertical}  Evaluate  ${vertical}+1
    ${horizontal}  Get BBMOD horizontal position  ${BBMOD_DN}
    Get cells mapped on FSP
    Set actFaultSignature value  true
    ${active_SW}  coam.Get sw version
    ${start_time}  Get current date  time_zone=UTC  result_format=datetime
    ${component_string}  Catenate  SEPARATOR=;${SPACE}  inventoryUnitType:${SPACE}${BBMOD_PRODUCT_NAME}  serialNumber:${SPACE}${BBMOD_SERIAL_NUMBER}
    ...  vendorUnitTypeNumber:${SPACE}${BBMOD_PRODUCT_CODE}  unitPosition:${SPACE}${horizontal}${vertical}
    Set test variable  ${ACTIVE_SW}  ${active_SW}
    Set test variable  ${START_TIME}  ${start_time}
    Set test variable  ${COMPONENT_FIELD}  ${component_string}
    ${alarm_parameters}  Catenate  SEPARATOR=${SPACE}  faultId=${EXPECTED_FAULT_ID},
    ...                                                faultName="${EXPECTED_FAULT_NAME}",
    ...                                                alarmId=${EXPECTED_ALARM_ID},
    ...                                                alarmName="${EXPECTED_ALARM_NAME}",
    ...                                                severity=${SEVERITY}
    Set test variable  ${ALARM_PARAMETERS}
    Set test variable  ${CATEGORY}  SW_FAILURE
    Set test variable  ${SCOPE}  Board
    Set test variable  ${INFO}  AaError.*Abort signal received.*

Step1: Perform site reset
    Log  Step1: Perform site reset to clear all counters.  console=true
    Perform site reset

Step2: Trigger RTHWAPI container crash
    Log  Step2: Trigger RTHWAPI container crash.  console=true
    Setup admin  bts_host=192.168.255.129  bts_port=443  use_ssl=True  alias=check_alarm
    ${alarm_webem}  Run keyword in background  Assert alarm active
    ...  parameters=${ALARM_PARAMETERS}
    ...  timeout=${ALARM_TIMEOUT}
    ...  alias=check_alarm
    Open connection and trigger ${PROCESS_NAME} process crash
    ${bbmod_status}  Run keyword and return status  Assert any  BBMOD  availabilityStatus=${Offline_},operationalState=${Disabled_}  timeout=360
    Wait until keyword succeeds  120  10  Checking cells on the given FSP  ${Failed_}  ${Disabled_}
    ${check_alarm_webem}  Collect keyword result  ${alarm_webem}  timeout=${ALARM_TIMEOUT}
    Run keyword if  ${check_alarm_webem}
    ...  Log  Fault ${EXPECTED_FAULT_ID} was active in WebEm.  console=true
    ...  ELSE  Fail  Fault ${EXPECTED_FAULT_ID} was not active in WebEm.
    Run keyword if  ${bbmod_status}
    ...  Log  BBMOD was failed.  console=true
    ...  ELSE  Set Test Restriction  BBMOD was not failed.
    Sleep  ${NETACT_TIMEOUT}s  Wait for fault to be reported in Netact.
    Log  Alarm presence will be checked in NA.  console=true
    ${alarm_netact}  Run keyword and return status
    ...  Check additional information for given alarm and fault in NA cleared alarms  ${EXPECTED_FAULT_ID}
    ...                                                                               ${EXPECTED_FAULT_NAME}
    ...                                                                               ${EXPECTED_ALARM_ID}
    ...                                                                               ${EXPECTED_ALARM_NAME}
    ...                                                                               ${SEVERITY}
    ...                                                                               ${START_TIME}
    Run keyword if  ${alarm_netact}
    ...  Log  Alarm with faultId ${EXPECTED_FAULT_ID} was reported and cleared from NetAct.  console=true
    ...  ELSE  Fail  Alarm with faultId ${EXPECTED_FAULT_ID} was not reported and cleared from NetAct.
    Run keyword and continue on failure  Teardown Admin  alias=check_alarm

Step3: Check fault signature
    Log  Step3: Check fault signature.  console=true
    Sleep  60  Wait for history alarms update.
    ${historical_alarms}  Get historic alarms
    FOR  ${item}  IN  @{historical_alarms}
         Run keyword if  '${item}[faultId]'=='${EXPECTED_FAULT_ID}'
         ...  Run keywords
         ...  Verify fault signature of alarm  ${item}  AND
         ...  Exit for loop
    END
    Check fault signature of alarm in Netact  fault_id=${EXPECTED_FAULT_ID}
    ...                                       time_from=${START_TIME}
    ...                                       category=${CATEGORY}
    ...                                       component=${COMPONENT_FIELD}
    ...                                       extra_info=${EXTRA_INFO}
    ...                                       info=${INFO}
    ...                                       load_name=${ACTIVE_SW}
    ...                                       scope=${SCOPE}

Step4: Verify SBTS after recovery
    Log  Step4: Verify SBTS after recovery.  console=true
    ${alarm_inactive}  Run keyword and return status  Assert alarm inactive
    ...  parameters=${ALARM_PARAMETERS}
    ...  timeout=${ALARM_TIMEOUT}
    Run keyword if  ${alarm_inactive}  Log  Fault ${EXPECTED_FAULT_ID} is inactive in WebEm.  console=true
    Wait until keyword succeeds  ${RECOVERY_TIMEOUT}  10  Check all cells  ${OnAirDone_}  ${Enabled_}  ${Active_}
    Admin check active alarms taf

Get BBMOD from configuration
    ${bbmods_list}  Get parameters for all  BBMOD
    ${bbmods_for_test}  Create list
    FOR  ${object}  IN  @{bbmods_list}
         ${match}  Run keyword and return status  Should contain  ${object}[productName]  ${BBMOD_TYPE}
         Run keyword if  ${match}  Append to list  ${bbmods_for_test}  ${object}
    END
    ${status}  Run keyword and return status  Should not be empty  ${bbmods_for_test}
    Run keyword if  ${status}
    ...  Log  Suitable BBMOD for test found in configuration. Test will continue.  console=true
    ...  ELSE
    ...  Fail  Suitable BBMOD for test not found in configuration.
    ${bbmod_chosen}  Evaluate  random.choice(${bbmods_for_test})  random
    ${bbmod_obj}  Set variable  ${bbmod_chosen}
    Log  BBMOD for test is: ${bbmod_obj}  console=true
    Set test variable  ${BBMOD_DN}  ${bbmod_obj}[id]
    Set test variable  ${BBMOD_SERIAL_NUMBER}  ${bbmod_obj}[serialNumber]
    Set test variable  ${BBMOD_PRODUCT_NAME}  ${bbmod_obj}[productName]
    Set test variable  ${BBMOD_PRODUCT_CODE}  ${bbmod_obj}[productCode]

Get cells mapped on FSP
    ${cells_found}=  Get cell mapping by module id  ${BBMOD_DN}
    Set Test Variable  ${CELLS_LIST_ON_FSP}  ${cells_found}
    Log  Cells on FSP: ${CELLS_LIST_ON_FSP}  console=true

Checking cells on the given FSP
    [Arguments]  ${cell_availabilityStatus}  ${cell_operationalState}
    Log  Cells on FSP will be checked.  console=true
    FOR  ${cell}  IN  @{CELLS_LIST_ON_FSP}
         Wait Until Keyword Succeeds  300s  10s  Get and check cell status  ${cell}  ${cell_availabilityStatus}  ${cell_operationalState}
    END

Get and check cell status
    [Arguments]  ${cell}  ${cell_availabilityStatus}  ${cell_operationalState}
    ${cell_obj}=  Query Infomodel  get object ${cell}
    ${availability}  Run Keyword And Return Status  Should Contain  ${cell_availabilityStatus}  ${cell_obj.availabilityStatus}
    ${operational}  Run Keyword And Return Status  Should Contain  ${cell_operationalState}  ${cell_obj.operationalState}
    Run Keyword If  ${availability} and ${operational}
    ...  Log  Cell ${cell_obj.dist_name} is in expected state [OK]  console=true
    ...  ELSE
    ...  Fail  Cell ${cell_obj.dist_name} is in unexpected state: availability_status=${availability} and operational_status=${operational}.

Open connection and trigger ${PROCESS_NAME} process crash
    Open connection to primary core
    Run keyword if  ${OPEN_SC_CONNECTION}
    ...  Open connection to secondary core
    Open connection to SOC  ${BBMOD_POSITION}  0
    Log  Crash will be performed.  console=true
    ${silent_option}  Set variable if  '${SILENT_CRASH}' == 'True'  -s  ${EMPTY}
    SSHLibrary.write  /opt/uphwapiCommonUtilities/forceTheCrash.sh -e ${PROCESS_NAME} ${silent_option}
    ${output}  SSHLibrary.read until prompt

Verify fault signature of alarm
    [Arguments]  ${alarm}
    ${date}  Get current date  result_format=%Y%m%d
    ${faultsig}  Set variable  ${alarm}[faultSignature]
    Get extraInfo field
    Should match regexp  ${faultsig}[date]  (${date})[0-9]{6}\.       msg=Date not ok.
    Run keyword if  '${faultsig}[category]' != 'SW_FAILURE'           Set Test Failed  Category did not matched.
    Run keyword if  '${faultsig}[scope]' != 'Board'                   Set Test Failed  Scope did not mached.
    Run keyword if  '${faultsig}[loadName]' != '${ACTIVE_SW}'         Set Test Failed  Load name did not matched.
    Run keyword if  '${faultsig}[component]' != '${COMPONENT_FIELD}'  Set Test Failed  Component did not mached.
    Run keyword if  '${faultsig}[extraInfo]' != '${EXTRA_INFO}'       Set Test Failed  Extra info did not mached.
    Should contain any  ${faultsig}[info]  AaError  Abort signal received
    Log  Fault signature of alarm in WebEM is ok.  console=True

Get extraInfo field
    ${cells_state}  Set variable if  '${SILENT_CRASH}' == 'True'  gracefully_shutdown_cells  faulty_cells
    ${cells_string}  Get ids of affected cells  ${CELLS_LIST_ON_FSP}
    ${cells_rat}  Get rat of affected cells  ${CELLS_LIST_ON_FSP}
    ${extraInfo}  Catenate  SEPARATOR=${EMPTY}  ${cells_state}  =${cells_rat}:  ${cells_string}
    Set test variable  ${EXTRA_INFO}  ${extraInfo}

Get ids of affected cells
    [Arguments]  ${cells_fsp}
    ${cells_list_ids}  Create list
    FOR  ${cell}  IN  @{cells_fsp}
         ${id}  Fetch from right  ${cell}  CEL_R-
         Append to list  ${cells_list_ids}  ${id}
    END
    Sort list  ${cells_list_ids}
    ${string}  Set variable  ${EMPTY}
    FOR  ${id}  IN  @{cells_list_ids}
         ${string}  Catenate  SEPARATOR=,  ${string}  ${id}
    END
    ${string}  Get substring  ${string}  1
    [Return]  ${string}

Get rat of affected cells
    [Arguments]  ${cells_fsp}
    ${bts_id}   Admin get bts id
    FOR  ${cell}  IN  @{cells_fsp}
         ${string}  Fetch from right  ${cell}  ${bts_id}/
         ${cell_type}  Fetch from left  ${string}  _R-
         ${rat}  Set variable If  '${cell_type}'=='LNCEL'  LTE  NR
         Exit for loop
    END
    [Return]  ${rat}

TC Setup
    Common Test Setup
    Setup NetAct

TC Teardown
    Teardown NetAct
    Common Test Teardown

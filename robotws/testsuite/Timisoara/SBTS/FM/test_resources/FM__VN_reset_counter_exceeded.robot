*** Settings ***
Documentation
    ...  This test case was created to trigger LTE L3Pool VN crash and recovery action multiple times to verify the counter increment.
    ...  When reset counter is exeeded (4th crash), alarm with original fault is reported. actForceAutoReset parameter set to false.
    ...  To imitate LTE L3Pool VN crash recovery reset scenario the PID of L3Pool process will be found from ps -aux output.
    ...  Appropriate fields from VNU containter in IM will be checked during crash. Fault 4383 and recovery request apperance
    ...  will be checked in seperate threads. Meantime also resoningStatus from VNU will be checked.

Library  ute_async
Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${RECOVERY_TIMEOUT}  180  # Timeout for SBTS to recover after L3Pool VN crash scenario
${STARTUP_TIMEOUT}  300  # Timeout for SBTS to recover after site reset


*** Keywords ***
TC__FM__VN_reset_counter_exceeded
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-19778
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 25.06.2020 - https://jira3.int.net.nokia.com/browse/TAT-19778 - Initial TAT creation
    ...  - 21.05.2021 - https://jira3.ext.net.nokia.com/browse/TAT-20125 - Process id was not optain correctly
    ...  - 24.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  - 28.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23842 - Remove Test Specific Teardown and Setup
    ...  - 17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  - 05.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26813 - Refactor FM testcase for assert alarm active parameters
    ...  - 29.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28007 - Add keyword perform site reset
    ...  *******************

    Set Tags  CA-FM  OWNER-laura.craciunel@nokia.com  AUTHOR-laura.craciunel@nokia.com  MAINTAINER-laura.craciunel@nokia.com
    ...  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS20  FEATURE-RP001534

    Step0: Check All Required States
    Step1: Perform Site Reset To Clear Counters
    FOR  ${loop}  IN RANGE  0  3
        Step2: Trigged LTE L3Pool VN Crash
        Step3: Verify SBTS After Recovery
    END
    Step4: Trigger 4th Fault


Step0: Check All Required States
    Log  \nStep0: Check All Required States.  console=true

    Log  \nCheck actForceAutoReset and change value if needed  console=true
    ${initial_value}  Get ActForce(Unit)AutoReset Value From Infomodel  actForceAutoReset
    ${status}  Run Keyword And Return Status
    ...  Change Parameter ActForce(Unit)AutoReset  false  actForceAutoReset
    ${parameter_after_change}  Get ActForce(Unit)AutoReset Value From Infomodel  actForceAutoReset
    Run Keyword If  ${status}
    ...  Should Be Equal  ${parameter_after_change}  false
    Set Test Variable  ${INITIAL_VALUE}

    Check Which Core Is Primary
    ${vnu_l}  Query Infomodel  get list /MRBTS-1/RAT-*//SOC_L-1/SW_NODE_L-* is [rat="LTE", applicationGroup="DistributedCPlane"]  timeout=60
    ${list_length}  Get Length  ${vnu_l}
    Log  Suitable LTE DistributedCPlane found in configuration are :\n ${vnu_l} \n  console=true

    FOR  ${object}  IN  @{vnu_l}
        Log  L3 Pool virtual node in list with coresponding dist name: ${object.dist_name}  console=true
    END

    ${crashed_vn}  Evaluate  random.randint(0, ${list_length}-1)  modules=random
    Log  Random index chosen from list is : ${crashed_vn}  console=true
    Set Test Variable  ${ELEMENT}  ${vnu_l[${crashed_vn}]}

    ${fault_4383}  Catenate  SEPARATOR=${SPACE}  faultId=4383,  faultName="Internal BTS processes autonomous reset as recovery action",
    ...  alarmId=7101
    Set Test Variable  ${FAULT_4383}


Step1: Perform Site Reset To Clear Counters
    Log  \nStep1: Site reset will be performed to clear all counters  console=true
    Perform Site Reset


Step2: Trigged LTE L3Pool VN Crash
    Log  \nStep2: Trigger LTE L3Pool VN crash.  console=true

    ${node_id}  Convert To Hex  ${ELEMENT.nodeId}  prefix=0x
    ${node_id_fsmf}  Convert To Hex  ${ELEMENT.nodeId}
    ${low_node_id}  Convert To Lowercase  ${node_id}
    ${low_node_id_fsmf}  Convert To Lowercase  ${node_id_fsmf}
    ${sm_variant}  Get SM Variant From Node  ${ELEMENT.dist_name}
    Run Keyword If  '${sm_variant}'=='AirScale'
    ...  Run Keyword
    ...  Crash VN On AirScale  ${ELEMENT}  ${low_node_id}
    ...  ELSE
    ...  Crash VN On FSMF  ${ELEMENT}  ${low_node_id_fsmf}


Step3: Verify SBTS After Recovery
    Log  \nStep3: Verify SBTS After Recovery.  console=true

    ${vnu_status}  Query Infomodel  get list ${ELEMENT.dist_name} is [stateInfo.reasoningStatus[0]="NodeStoppedUnexpectedly"]  timeout=300

    Setup Admin  bts_host=192.168.255.129  bts_port=443  use_ssl=True  alias=fault
    ${fault_status}  Run Keyword In Background  Assert Alarm Active  parameters=${FAULT_4383}  timeout=660  alias=fault
    ${reset_recovery}  Start Async  ute_admin_infomodel  Query Infomodel  get list //RECOVERY_RESET_IND-*  timeout=660  alias=recovery

    Run Keyword If  ${vnu_status}
    ...  Log  Reasoning status is NodeStoppedUnexpectedly [OK]  console=TRUE
    ...  ELSE
    ...  Set Test Restriction  message=Reasoning Status is different than expected [NOK]

    ${status_fault}  Run Keyword And Return Status
    ...  Collect Keyword Result  ${fault_status}  timeout=660
    Run Keyword If  ${status_fault}
    ...  Log  Fault 4383 with name "Internal BTS processes autonomous reset as recovery action" occured [OK]  console=TRUE
    ...  ELSE
    ...  Set Test Restriction  Fault 4383 with name "Internal BTS processes autonomous reset as recovery action" didn't occurr [NOK]

    ${status_reset_recovery}  ${async_result}  Run Keyword And Ignore Error
    ...  Wait For Async Result  alias=recovery
    Run Keyword If  '${status_reset_recovery}'=='FAIL'
    ...  Set Test Restriction  message=Recovery Reset Indication is not visible under FRI [NOK]
    ...  ELSE
    ...  Log  Recovery reset indication is visible uder FRI [OK]  console=TRUE
    Stop Async  alias=recovery
    Run Keyword And Continue On Failure
    ...  Teardown Admin  alias=fault

    Check WCDMA Cells  ${ACTIVE}  ${ENABLED}
    Check GSM Cells  ${ACTIVE}  ${ENABLED}
    ${alarm7101_recovery_status}  Run Keyword And Return Status
    ...  Assert Alarm Inactive  faultName="Internal BTS processes autonomous reset as recovery action", alarmId=7101, faultId=4383
    Run Keyword If  ${alarm7101_recovery_status}
    ...  Log  Alarm "7101 Internal BTS processes autonomous reset as recovery action" is not visible after recovery action [OK]  console=TRUE
    ...  ELSE
    ...  Fail  msg=Alarm "7101 Internal BTS processes autonomous reset as recovery action" is visible after recovery action [NOK]
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT} sec  65 sec
    ...  Check All Cells


Step4: Trigger 4th Fault
    Log  \nStep4: Triggering fault 4383 for the 4th time and verify status.  console=true

    ${node_id}  Convert To Hex  ${ELEMENT.nodeId}  prefix=0x
    ${node_id_fsmf}  Convert To Hex  ${ELEMENT.nodeId}
    ${low_node_id}  Convert To Lowercase  ${node_id}
    ${low_node_id_fsmf}  Convert To Lowercase  ${node_id_fsmf}
    ${sm_variant}  Get SM Variant From Node  ${ELEMENT.dist_name}
    Run Keyword If  '${sm_variant}'=='AirScale'
    ...  Run Keyword
    ...  Crash VN On AirScale  ${ELEMENT}  ${low_node_id}
    ...  ELSE
    ...  Crash VN On FSMF  ${ELEMENT}  ${low_node_id_fsmf}

    ${vnu_status}  Query Infomodel  get list ${ELEMENT.dist_name} is [stateInfo.reasoningStatus[0]="NodeStoppedUnexpectedly"]  timeout=300

    Setup Admin  bts_host=192.168.255.129  bts_port=443  use_ssl=True  alias=fault

    ${4th_fault}  Catenate  SEPARATOR=${SPACE}  faultId=4383,  faultName="Virtual node not responding",  alarmId=regex"7116|7115"

    ${fault_status}  Run Keyword In Background  Assert Alarm Active  parameters=${4th_fault}  timeout=660  alias=fault

    Run Keyword If  ${vnu_status}
    ...  Log  Reasoning status is NodeStoppedUnexpectedly [OK]  console=TRUE
    ...  ELSE
    ...  Set Test Restriction  message=Reasoning Status is different than expected [NOK]

    ${status_fault}  Run Keyword And Return Status
    ...  Collect Keyword Result  ${fault_status}  timeout=660
    Run Keyword If  ${status_fault}
    ...  Log  Fault 4383 with name "Virtual node not responding" occured [OK]  console=TRUE
    ...  ELSE
    ...  Set Test Restriction  Fault 4383 with name "Virtual node not responding" didn't occurr [NOK]

    Check WCDMA Cells  ${ACTIVE}  ${ENABLED}
    Check GSM Cells  ${ACTIVE}  ${ENABLED}


TC Setup
    Common Test Setup


TC Teardown
    Run Keyword And Ignore Error
    ...  Change Parameter ActForce(Unit)AutoReset  ${INITIAL_VALUE}  actForceAutoReset
    Log  \nSite reset will be performed to recover services.  console=true
    Step1: Perform Site Reset To Clear Counters
    Common Test Teardown

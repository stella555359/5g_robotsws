*** Settings ***
Documentation    TC__SBTS_SBTS__FM__ASOG_L1SoC_reset_recovery_CB010629
Variables    tc_variables/sbts_sbts__fm__asog_l1soc_reset_recovery_cb010629_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}          20                 # Number of ASOG L1SoC reset recovery operations, default value 20
${BTS_LIST}                ALL                # BTS list on which ASOG L1SoC reset recovery operations will be performed.
                                              # Possible values (by default ALL):
                                              # - ALL: action will be performed on all BTS (ASOG L1SoC reset recovery on each BTS from TL)
                                              # - list of selected BTS separated by comma labeled as BTSx (x is test_pc number in init.py)
${L1SOC_PROCESS}           l1_application_rt  # Process to be killed to trigger ASOG L1SoC reset operation
${BTS_MAX_WAIT_TIME}       900                # Maximum time to wait for BTS OnAir after ASOG L1SoC reset recovery operation, by default 900
${L1SOC_SUCCESS_RATE_THR}  95                 # Percentage of successful runs from ${REPEAT_COUNTER} variable

*** Keywords ***
TC__SBTS_SBTS__FM__ASOG_L1SoC_reset_recovery_CB010629
     [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-28525
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS test case for ASOG L1SoC reset recovery operations, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 20)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for all BTS
    ...  - get and kill l1_application PID info from specific SoC checking FID2087 on impacted BTS
    ...  - check final state and alarms for for all BTS
    ...  - calculate success rate for running loops, should be at least of min 95%
    ...  Pass criteria: L1SoC reset recovery operation works as expected; states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 16.01.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28525 - CB010629 new TC: L1SoC recovery reset

    Set Tags    CA-LOGS    OWNER-dan.popescu@nokia.com    AUTHOR-dinu.olariu@nokia.com    PHASE-QT    SW-SBTS25R2

    TC Preconditions
    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Perform L1SoC reset recovery operation on required BTS
    Step 4: Check final all BTS state
    Step 5: Check final all BTS alarms
    Step 6: Check final number and state of Cells and RMs
    Step 7: Check success rate for L1SoC reset recovery operation on required BTS

TC Preconditions
    ${BTS_alias_label_dict}  ${BTS_label_alias_dict}=  Get BTS alias label info dict
    Set Test Variable  ${BTS_alias_label_dict}
    Set Test Variable  ${BTS_label_alias_dict}
    ${BTS_alias_list}=  Get Dictionary Keys  ${BTS_alias_label_dict}  False
    ${BTS_label_list}=  Get Dictionary Values  ${BTS_alias_label_dict}  False
    Set Test Variable  ${BTS_alias_list}
    Set Test Variable  ${BTS_label_list}

    Run Keyword If  '${BTS_LIST}' != 'ALL'  Check BTS list
    Log  ================================================================  console=True
    Log  BTS label list selected for ASOG L1SoC reset recovery operation: ${BTS_label_list}  console=True
    Log  BTS alias list selected for ASOG L1SoC reset recovery operation: ${BTS_alias_list}  console=True
    Log  ================================================================  console=True

    Check BTS ASOG configuration

Step ${index}: Check ${when} all BTS state
    [Documentation]
    ...  SBTS state is checked according to Admin for BTS and each configured RAT

    Log  Step ${index}: Check ${when} all BTS state  console=True

    FOR  ${alias}  IN  @{alias_list}

        Log  ***** Check ${when} BTS ${alias} state *****  console=True

        Admin Check BTS RAT Procedural State  alias=${alias}  timeout=600

        Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  alias=${alias}

        Log  BTS ${alias} site - proceduralState: OnAir, blockingState: Unblocked  console=True

    END

Step ${index}: Check ${when} all BTS alarms
    [Documentation]
    ...  SBTS alarms are compared with values from expected, ignored and critical alarms lists. SBTS alarms are get
    ...  from Admin

    Log  Step ${index}: Check ${when} all BTS alarms  console=True

    FOR  ${alias}  IN  @{alias_list}

        Log  ***** Check ${when} BTS ${alias} alarms *****  console=True

        Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
        ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}

        Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

    END

Step ${index}: Perform L1SoC reset recovery operation on required BTS
    [Documentation]
    ...  Perform L1SoC reset recovery operation on required BTS

    Log  Step ${index}: Perform L1SoC reset recovery operation on required BTS  console=True

    FOR  ${alias}  IN  @{BTS_alias_list}

        Perform L1SoC reset recovery operation on BTS  alias=${alias}

        Clear FID6450 by BTS Snapshot collect  alias=${alias}

    END

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Step ${index}: Check success rate for L1SoC reset recovery operation on required BTS
    [Documentation]
    ...  Check success rate for L1SoC reset recovery operation on required BTS

    Log  Step ${index}: Check success rate for L1SoC reset recovery operation on required BTS  console=True

    FOR  ${alias}  IN  @{BTS_alias_list}

        Check success rate for L1SoC reset recovery operation on BTS  alias=${alias}

    END

Perform L1SoC reset recovery operation on BTS
    [Documentation]
    ...  Perform L1SoC reset recovery operation on BTS

    [Arguments]  ${alias}

    ${run_passed}=  Set Variable  0

    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1

        Continue For Loop If  '${${alias}_ASOG_check}' == 'False'

        Log  ***** Perform L1SoC reset recovery operation on ASOG from BTS ${alias} for cycle ${INDEX} of ${REPEAT_COUNTER} *****  console=True

        ${run_status}=  Run Keyword And Return Status  Perform L1SoC reset recovery operation  alias=${alias}

        ${run_passed}=  Run Keyword If  '${run_status}' == 'True'
        ...  Evaluate  ${run_passed} + 1
        ...  ELSE
        ...  Evaluate  ${run_passed} + 0

        Continue For Loop If  '${run_status}' == 'True'

        Run Keyword If  '${run_status}' == 'False'  Run Keywords
        ...  Collect BTS Snapshot for failed iteration  cycle=${INDEX}  alias=${alias}
        ...  AND  Collect other BTS Snapshot for failed iteration  cycle=${INDEX}  alias=${alias}

    END

    Set Test Variable  ${${alias}_run_passed}  ${run_passed}

Check BTS list
    ${BTS_LIST_strip}=  Replace String  ${BTS_LIST}  ${SPACE}  ${EMPTY}
    ${BTS_LIST}=  Split String  ${BTS_LIST_strip}  ,
    ${BTS_check}=  Set Variable  True
    ${BTS_invalid_label_list}=  Create List
    ${BTS_request_label_list}=  Create List
    ${BTS_request_alias_list}=  Create List

    FOR  ${item}  IN  @{BTS_LIST}
        ${BTS_check}=  Set Variable If  '${item}' not in ${BTS_label_list}  False  ${BTS_check}
        Run Keyword If  '${item}' not in ${BTS_label_list}
        ...  Append To List  ${BTS_invalid_label_list}  ${item}
        ...  ELSE
        ...  Append To List  ${BTS_request_label_list}  ${item}
    END

    Run Keyword If  '${BTS_check}' == 'False'  Run Keywords
    ...  Log Long String  Following selected BTS are not valid: ${BTS_invalid_label_list}. Please select values for test argument \${BTS_LIST} from
    ...  configured BTS: ${BTS_label_list} or let default value: ALL  console=True
    ...  AND  Fail  Improper value for argument!

    FOR  ${item}  IN  @{BTS_request_label_list}
        ${BTS_request_alias}=  Get From Dictionary  ${BTS_label_alias_dict}  ${item}
        Append To List  ${BTS_request_alias_list}  ${BTS_request_alias}
    END

    Set Test Variable  ${BTS_label_list}  ${BTS_request_label_list}
    Set Test Variable  ${BTS_alias_list}  ${BTS_request_alias_list}

Check BTS ASOG configuration

    ${TL_ASOG_check}=  Set Variable  False

    FOR  ${alias}  IN  @{BTS_alias_list}

        ${BTS_ASOG_check}=  Admin Check BTS HW product name info  class_name=SMOD  product_name=ASOG  alias=${alias}
        Set Test Variable  ${${alias}_ASOG_check}  ${BTS_ASOG_check}

        ${TL_ASOG_check}=  Set Variable If  '${BTS_ASOG_check}' == 'True'  True  ${TL_ASOG_check}

    END

    Run Keyword If  '${TL_ASOG_check}' == 'False'  Run Keywords
    ...  Log  No HW ASOG found on any BTS from TL. Testcase run will be skipped!  console=True
    ...  AND  Fail  No HW ASOG found on any BTS from TL. Testcase run will be skipped!

Perform L1SoC reset recovery operation
    [Arguments]  ${alias}

    Perform L1SoC reset operation  alias=${alias}
    Check BTS alarms during L1SoC reset operation  alias=${alias}
    Check BTS cells status after L1SoC reset recovery  alias=${alias}
    Check other BTS cells status after L1SoC reset recovery  alias=${alias}

Perform L1SoC reset operation
    [Arguments]  ${alias}  ${username}=ute  ${password}=ute  ${keypath}=/home/ute/.ssh/id_rsa

    ${hostname}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]
    ${remote_host}=  Set Variable If  '${alias}'=='Master'  None  ${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]
    ${ip_address}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_TECH_IP_ADDRESS]

    Log  Get PID for process ${L1SOC_PROCESS} running on ASOG from BTS ${alias}  console=True

    ${sysbshtopo_get_thor_bsh_cmd}=  Set Variable  chk -g sysbshtopo | grep -E 'thor.*ok'
    ${sysbshtopo_output}=  Execute Command on SM via SSH TAF  command=${sysbshtopo_get_thor_bsh_cmd}  via_ip=${remote_host}  via_username=${username}
    ...  via_password=${password}  key_path=${key_path}  alias=${alias}_ssh
    Should Not Be Empty  ${sysbshtopo_output}

    ${bsh}=  Get Regexp Matches  ${sysbshtopo_output}  [\\d]+:[\\d]+

    ${bsh_get_PID_L1SoC_process}=  Set Variable  ps ax | grep ${L1SOC_PROCESS} | grep -v grep | awk '{print $1}'
    ${PID_L1SoC_process}=  Execute BSH Command  bsh=${bsh[0]}  command=${bsh_get_PID_L1SoC_process}  via_ip=${remote_host}  via_username=${username}
    ...  via_password=${password}  alias=${alias}_ssh
    Should Not Be Empty  ${PID_L1SoC_process}
    ${PID_L1SoC_process}=  Convert To Integer  ${PID_L1SoC_process}
    Log  - PID for process ${L1SOC_PROCESS}: ${PID_L1SoC_process}  console=True

    ${bsh_kill_PID_L1SoC_process}=  Set Variable  kill -6 ${PID_L1SoC_process}
    Log  Trigger L1SoC autonomous reset operation on ASOG from BTS ${alias} by bsh command: kill -6 ${PID_L1SoC_process}  console=True

    ${kill_L1SoC_process}=  Execute BSH Command  bsh=${bsh[0]}  command=${bsh_kill_PID_L1SoC_process}  via_ip=${remote_host}  via_username=${username}
    ...  via_password=${password}  alias=${alias}_ssh

Check BTS alarms during L1SoC reset operation
    [Arguments]  ${alias}

    Log  Check BTS ${alias} alarms during L1SoC reset operation on ASOG from BTS ${alias}  console=True
    ${BTS_IGNORED_ALARMS_FULL}=  Combine Lists  ${${alias.upper()}_IGNORED_ALARMS}  ${${alias.upper()}_IGNORED_ALARMS_DURING_ACTION}

    Log  BTS ${alias} "SoC autonomous reset as recovery action (2087)" alarm, expected number: 1  console=True
    Get and Check Alarms SOAM  alias=${alias}  poll_interval=3 sec  expected_alarms=${${alias.upper()}_EXPECTED_ALARMS_2087}
    ...  ignored_alarms=${BTS_IGNORED_ALARMS_FULL}  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    Log  BTS ${alias} "SoC autonomous reset as recovery action (2087)" alarm, found number: 1, as expected!  console=True
    Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

Check BTS cells status after L1SoC reset recovery
    [Arguments]  ${alias}

    Log  Check BTS ${alias} cells status after L1SoC reset operation on ASOG from BTS ${alias}   console=True
    Check cells availability status online  ${alias}  ${BTS_MAX_WAIT_TIME}
    Log  BTS ${alias} cells status:\n - operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked  console=True

Check other BTS cells status after L1SoC reset recovery
    [Arguments]  ${alias}

    FOR  ${other_alias}  IN  @{alias_list}

        Continue For Loop If  '${other_alias}' == '${alias}'

        Log  Check BTS ${other_alias} cells status after L1SoC reset operation on ASOG from BTS ${alias}  console=True
        Check cells availability status online  ${other_alias}  ${BTS_MAX_WAIT_TIME}
        Log  BTS ${other_alias} cells status:\n - operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked  console=True

    END

Collect BTS Snapshot for failed iteration
    [Arguments]  ${cycle}  ${alias}

    ${snapshot_folder}=  Set Variable  ${Test Results Dir}/${alias}_L1SoC_Operation/Cycle_${cycle}
    Run Keyword And Continue On Failure  Snapshot collection on demand SOAM  alias=${alias}  folder_path=${snapshot_folder}

Collect other BTS Snapshot for failed iteration
    [Arguments]  ${cycle}  ${alias}

    FOR  ${other_alias}  IN  @{alias_list}

        Continue For Loop If  '${other_alias}' == '${alias}'

        ${snapshot_folder}=  Set Variable  ${Test Results Dir}/${alias}_L1SoC_Operation/Cycle_${cycle}
        Run Keyword And Continue On Failure  Snapshot collection on demand SOAM  alias=${other_alias}  folder_path=${snapshot_folder}

    END

Clear FID6450 by BTS Snapshot collect
    [Arguments]  ${alias}

    ${FID6450_status}=  Run Keyword And Return Status  Assert Alarm Active  parameters=faultId=6450  timeout=60  alias=${alias}

    Return From Keyword If  '${FID6450_status}' == 'False'

    Log  Wait for clear "Diagnostic files collected (6450)" alarm on BTS ${alias} by collect snapshot  console=True

    ${target_file_name}=  Set Variable  ${Test Results Dir}/${alias}_L1SoC_Operation/Clear_FID6450_snapshot.zip

    OperatingSystem.Remove File  ${target_file_name}

    coam.Collect Snapshot  alias=${alias}  target_file_name=${target_file_name}  timeout=1260

Check success rate for L1SoC reset recovery operation on BTS
    [Arguments]  ${alias}

    Return From Keyword If  '${${alias}_ASOG_check}' == 'False'

    Log  Check success rate after ${REPEAT_COUNTER} L1SoC reset recovery operations on BTS ${alias}  console=True

    ${L1SOC_SUCCESS_RATE}=  Evaluate  (${${alias}_run_passed} / ${REPEAT_COUNTER}) * 100
    ${L1SOC_SUCCESS_RATE}=  Convert To Integer  ${L1SOC_SUCCESS_RATE}

    Run Keyword If  ${L1SOC_SUCCESS_RATE} >= ${L1SOC_SUCCESS_RATE_THR}
    ...  Log Long String  - L1SoC reset recovery operation behavior on BTS ${alias} as expected (expected/found success rate:
    ...  ${L1SOC_SUCCESS_RATE_THR}/${L1SOC_SUCCESS_RATE})!  console=True
    ...  ELSE  Run Keywords
    ...  Log Long String  - L1SoC reset recovery operation behavior on BTS ${alias} not as expected (expected/found success rate:
    ...  ${L1SOC_SUCCESS_RATE_THR}/${L1SOC_SUCCESS_RATE})!  level=ERROR
    ...  AND  Fail  L1SoC reset recovery operation behavior on BTS ${alias} not as expected!

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
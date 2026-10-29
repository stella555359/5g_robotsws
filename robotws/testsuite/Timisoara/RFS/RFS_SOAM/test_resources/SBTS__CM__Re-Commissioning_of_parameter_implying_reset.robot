*** Settings ***
Documentation    TC__SBTS__CM__Re-Commissioning_of_parameter_implying_reset
Variables    tc_variables/sbts__cm__re-commissioning_of_parameter_implying_reset_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}  3  # Number of BTS Re-Commissioning operations, default value 3
${BTS_TIMEZONE_LIST}  (GMT+8) Asia/Hong_Kong, (GMT-11) US/Samoa, (GMT-5) Brazil/Acre   # List of BTS timeZone parameter values to be commissioned
                                        # ,separated by comma. By default: (GMT+8) Asia/Hong_Kong, (GMT-11) US/Samoa, (GMT-5) Brazil/Acre
${BTS_SCF_VALIDATION}     True     # Validate SCF; can be True or False

*** Keywords ***
TC__SBTS__CM__Re-Commissioning_of_parameter_implying_reset
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-21905
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS test case for BTS Commissioning of parameter implying reset, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial BTS state and alarms
    ...  - get initial BTS Time Zone
    ...  - perform BTS Commissioning with selected BTS Time Zone checking BTS state and alarms
    ...  - check BTS reset behavior based on IMS info: reset number is 1
    ...  - recover initial BTS Time Zone
    ...  Pass criteria: BTS Commissioning successfully, states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 26.10.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-21905 - [5G][RFSPLIT] SBTS_Recommisioning_with_parameter_implying_reset
    ...  - 17.12.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-22335 -
    ...  [5G][RFSPLIT] After recovery initial SCF, wait for all RAT cells to be up - SBTS_Recommisioning_with_parameter_implying_reset
    ...  - 23.02.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-22650 - [Cloud] [RFSplit] [Legacy] Particular teardown refactoring - SBTS part
    ...  - 01.03.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-22605 - [5G][RFSplit] SBTS__CM__Re-Commissioning_of_parameter_implying_reset
    ...  - 14.03.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-22792 - [5G][RFSplit] Fix naming of the second timezone in BTS_TIMEZONE_LIST
    ...  input variable
    ...  - 09.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24842 - [5G][Reset Number ims2] Update SBTS CM ... scenarios to take reset
    ...  number from ims2 - P2
    ...  - 14.05.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27410 - [5G] [Infomodel] - P1 - Eliminate usage of KW Infomodel "Get baseband
    ...  pool allocation mode info" in test-cases - after TAT-27401
    ...  - 21.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27665 -
    ...  [5G] [SCF check] - P1 - SBTS - Include SCF validation with hardware check in CM Tests
    ...  - 17.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28089 - [5G] managedObject class changed for timeZone
    ...  parameter -CM_Re-Comissioning_NR_change_of_parameter_implying_reset
    ...  - 04.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28348 - [5G] Use current scf for timeZone parameter check before
    ...  recommissioning action
    ...  - 01.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29003 -
    ...  Detect SBTS-SBTS instead off LTE-LTE for SBTS_SBTS__STATE__SharedRM_Power_Off_On
    ...  - 03.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29815 -
    ...  Unify alarm container names between all tests in order to use ${${alias.upper()}}_ALARMS_CNI_127210 ${${alias.upper()}}_ALARMS_NO_CNI_127210
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-21905_SBTS__CM__Re-Commissioning_of_parameter_implying_reset.png

    Set Tags    CA-CM    OWNER-cosmin.florea@nokia.com    AUTHOR-dinu.olariu@nokia.com    PHASE-QT    SW-SBTS22R1

    Collect current SCF
    Step 1: Check initial BTS state
    Step 2: Check initial BTS alarms
    Step 3: Get initial baseband pool allocation mode info
    Step 4: Get initial BTS Time Zone
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 5: Get initial date UTC info
        Step 6: Perform BTS Commissioning to change BTS Time Zone
        Step 7: Check final BTS state
        Step 8: Check final BTS alarms
        Step 9: Get final date UTC info
        Step 10: Check BTS reset behavior based on IMS info
        Step 11: Check final number and state of Cells and RMs
    END

    [Teardown]    Particular Teardown

Collect current SCF
    ${scf_path_tmp}=  Admin Collect scf.xml with timestamp TAF  alias=${alias_local}  folder_path=${BTSFiles}/${alias_local}
    OperatingSystem.File Should Exist  ${scf_path_tmp}
    ${bts_info_tmp}=  Admin Get BTS state info  alias=${alias_local}
    Set Test Variable  ${scf_path_initial}  ${scf_path_tmp}
    Set Test Variable  ${bts_info}  ${bts_info_tmp}

Step ${index}: Check ${when} BTS state
    [Documentation]
    ...  BTS state is checked according to Admin

    [Timeout]  15 min
    Log  Step ${index}: Check ${when} BTS state  console=True
    Admin Check BTS RAT Procedural State  alias=${alias_local}  timeout=600
    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  600  ${alias_local}
    Log  BTS site - proceduralState: OnAir, blockingState: Unblocked  console=True

Step ${index}: Check ${when} BTS alarms
    [Documentation]
    ...  BTS alarms are compared with values from expected, ignored and critical alarms lists. BTS alarms are get from Admin

    [Timeout]  15 min
    Log  Step ${index}: Check ${when} BTS alarms  console=True
    Get and Check Alarms SOAM  alias=${alias_local}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias_local.upper()}_IGNORED_ALARMS}
    ...  critical_alarms=${${alias_local.upper()}_CRITICAL_ALARMS}
    Log  BTS site - expected, ignored and critical alarms checked  console=True

Step ${index}: Get initial baseband pool allocation mode info
    [Documentation]
    ...  Get initial baseband pool allocation mode info

    Log  Step ${index}: Get initial baseband pool allocation mode info   console=True
    Get baseband pool allocation mode info from SCF  alias=${alias_local}

Step ${index}: Get initial BTS Time Zone
    [Documentation]
    ...  Get initial BTS Time Zone

    Log  Step ${index}: Get initial BTS Time Zone   console=True

    ${timeZone}=  Get Time Zone from SCF  scf_path=${${alias_local.lower()}_scf_initial}  alias=${alias_local}
    Set Test Variable  ${timeZone_initial}  ${timeZone}
    Log  Initial BTS Time Zone: ${timeZone_initial}  console=True
    Log  BTS Time Zone selection list for BTS Commissioning: ${BTS_TIMEZONE_LIST}  console=True
    ${BTS_TIMEZONE_LIST_strip}=  Strip String  ${BTS_TIMEZONE_LIST}
    ${BTS_TIMEZONE_LIST_strip}=  Evaluate  '${BTS_TIMEZONE_LIST_strip}'.replace(', ',',')
    ${BTS_TIMEZONE_LIST}=  Split String  ${BTS_TIMEZONE_LIST_strip}  ,
    Set Test Variable  ${BTS_TIMEZONE_LIST}

Step ${index}: Get ${when} date UTC info
    Log  Step ${index}: Get ${when} date UTC info  console=True
    Get Current Date UTC info  ${when}

Step ${index}: Perform BTS Commissioning to change BTS Time Zone
    [Documentation]
    ...  Perform BTS Commissioning to change BTS Time Zone

    Log  Step ${index}: Perform BTS Commissioning to change BTS Time Zone  console=True
    ${scf_before}=  Admin Collect scf.xml with timestamp TAF  alias=${alias_local}
    ${timeZone_before}=  Get Time Zone from SCF  scf_path=${scf_before}  alias=${alias_local}

    FOR  ${item}  IN  @{BTS_TIMEZONE_LIST}
        Run Keyword If  '${item}' not in '${timeZone_before}'  Run Keywords
        ...  Set Test Variable  ${timeZone_change}  ${item}
        ...  AND  Exit For Loop
    END
    Log  Selected BTS Time Zone for BTS Commissioning: ${timeZone_change}  console=True
    BTS Commissioning for Time Zone change  ${timeZone_change}  ${scf_before}

Step ${index}: Check BTS reset behavior based on IMS info
    [Documentation]
    ...  BTS RESET info is checked based on IMS info.
    ...  Reset behavior as expected if: reset number is 1
    ...  Otherwise, reset behavior not as expected, then errors are added to report and failed.

    Log  Step ${index}: Check BTS reset behavior based on IMS info  console=True
    Get and check BTS RESET info from IMS file  expected_reset_number=1  alias=${alias_local}
    ...  start_point_timestamp_UTC=${date_timestamp_initial_UTC}  end_point_timestamp_UTC=${date_timestamp_final_UTC}  remove_ims_file=False

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

BTS Commissioning for Time Zone change
    [Arguments]   ${timeZone_value}  ${scf_before}

    Log  Recommissioning will be performed using timeZone=${timeZone_value}  console=True
    ${dst_name}=  Get object dist name for timeZone parameter recommissioning  alias=${alias_local}  scf_path=${scf_before}
    coam.Perform Parameter Recommissioning  dist_name=${dst_name}  skip_parameter_relation_errors=False
    ...  parameter=timeZone  operation=update  value=${timeZone_value}
    ...  skip_parameter_relation_errors=True  should_activate=True  timeout=900  alias=${alias_local}

    ${scf_after_recommissioning}=  Admin Collect scf.xml with timestamp TAF  alias=${alias_local}  folder_path=${BTSFiles}/${alias_local}
    ${timeZone_after}=  Get Time Zone from SCF  scf_path=${scf_after_recommissioning}  alias=${alias_local}
    Log  BTS Time Zone after BTS Commissioning: ${timeZone_after}  console=True
    Run Keyword If  '${timeZone_value}' in '${timeZone_after}'
    ...  Log  BTS Commissioning successfuly performed  console=True
    ...  ELSE  Run Keywords
    ...  Log  BTS Commissioning failed  level=ERROR
    ...  AND  Fail  BTS Commissioning failed

    Run Keyword If  ${BTS_SCF_VALIDATION}  Check BTS SCF Validation On Demand  alias=${alias_local}

Recover initial BTS Time Zone
    ${scf_before_recovery}=  Admin Collect scf.xml with timestamp TAF  alias=${alias_local}  folder_path=${BTSFiles}/${alias_local}
    ${timeZone_final}=  Get Time Zone from SCF  scf_path=${scf_before_recovery}  alias=${alias_local}
    ${status}=  Run Keyword And Return Status  Lists Should Be Equal  ${timeZone_final}  ${timeZone_initial}
    Run Keyword If  ${status}
    ...  Log  BTS Time Zone: ${timeZone_initial}, no recover action needed  console=True
    ...  ELSE  Run Keywords
    ...  Log  Recover initial BTS Time Zone: ${timeZone_initial}  console=True
    ...  AND  coam.Perform Commissioning  bts_id=${bts_info[0]}  scf_file=${scf_path_initial}  skip_parameter_relation_errors=True
    ...  should_activate=True  timeout=400  alias=${alias_local}
    ...  AND  Admin Check BTS RAT Procedural State  alias=${alias_local}  timeout=600
    ...  AND  Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  600  ${alias_local}
    ...  AND  Check cells availability status online  ${alias_local}  600
    ...  AND  Log  BTS site - proceduralState: OnAir, blockingState: Unblocked  console=True

    ${scf_after_recovery}=  Admin Collect scf.xml with timestamp TAF  alias=${alias_local}  folder_path=${BTSFiles}/${alias_local}
    ${timeZone_after_recovery}=  Get Time Zone from SCF  scf_path=${scf_after_recovery}  alias=${alias_local}
    ${status_after_recovery}=  Run Keyword And Return Status  Should Be Equal  ${timeZone_after_recovery}  ${timeZone_initial}
    Run Keyword If  ${status_after_recovery}
    ...  Log  Recovery to initial BTS Time Zone succesfully performed!  console=True
    ...  ELSE  Run Keywords
    ...  Log  Recovery to initial BTS Time Zone failed! Actual value is ${timeZone_after_recovery}.  console=True
    ...  AND  FAIL  Recovery to initial BTS Time Zone failed!

Particular Teardown
    Run Keyword And Continue On Failure  Recover initial BTS Time Zone

TC Setup
    ${tech_preset_list}=  Create List  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown

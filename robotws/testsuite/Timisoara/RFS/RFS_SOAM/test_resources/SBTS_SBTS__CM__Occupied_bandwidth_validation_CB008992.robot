*** Settings ***
Documentation    TC__SBTS_SBTS__CM__Occupied_bandwidth_validation_CB008992
Variables    tc_variables/sbts_sbts__cm__occupied_bandwith_validation_CB008992_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}  3    # Number of cycles to check feature CB008992, default value 3
${BTS}  BTS1            # Select BTS for feature CB008992 check: BTS1 or BTS2, default value: BTS1
${SCF_file_path}  NONE  # Path to SCF file that contains necessary modifications for OBW exceeded

*** Keywords ***
TC__SBTS_SBTS__CM__Occupied_bandwidth_validation_CB008992
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25842
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS test case for feature CB008992 - Occupied bandwidth case, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check test argument values validity
    ...  - perform recommissioning with ${SCF_file_path}
    ...  - check feature CB008992 behaviour: FID1900 -> Supplementary alarm information contains "OBW excedeed"
    ...  - recover initial parameter chBw value
    ...  Pass criteria: feature CB008992 behaviour as expected, states and alarms are as expected
    ...
    ...  ***************************
    ...  History of changes for SOAM
    ...  ***************************
    ...  - 17.08.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25842 - [5G][CB008992] SBTS_TDD_RFS_CB008992_Occupied_bandwidth_validation_BTS
    ...  - 05.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26069 - Please correct SBTS_SBTS__CM_Occupied_bandwidth_validation_CB008992 TC
    ...  name
    ...  - 01.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29003 -
    ...  Detect SBTS-SBTS instead off LTE-LTE for SBTS_SBTS__STATE__SharedRM_Power_Off_On
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-25842_SBTS_SBTS__CM__Occupied_bandwidth_validation_CB008992.png

    Set Tags    CA-STATE    OWNER-violeta.zanfirescu@nokia.com    AUTHOR-horea.olar@nokia.com    PHASE-QT    SW-SBTS23R4

    TC Preconditions
    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 3: Perform recommissioning
        Step 4: Check feature CB008992 behaviour
        Step 5: Recover BTS initial settings
        Step 6: Check final all BTS state
        Step 7: Check final all BTS alarms
        Step 8: Check final number and state of Cells and RMs
    END

    [Teardown]  Particular Teardown

TC Preconditions
    ${file_status}=  Run Keyword and Return Status  OperatingSystem.File Should Exist  ${SCF_file_path}
    Run Keyword If  not ${file_status}  Run Keywords
    ...  Log  SCF file path is not correct!  console=True
    ...  AND  Fail  SCF file path is not correct!
    Get and check BTS info precondition
    ${bts_info}=  Admin Get BTS state info  alias=${alias}
    Set Test Variable  ${bts_info}
    ${SCF_file_path_initial}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}  folder_path=${BTSFiles}/${alias}
    Set Test Variable  ${SCF_file_path_initial}

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
        Get and Check Alarms SOAM  alias=${alias}  wait_for_alarm_clear=15 min  expected_alarms=@{EMPTY}
        ...  ignored_alarms=${SBTS_${alias.upper()}_IGNORED_ALARMS}  critical_alarms=${SBTS_${alias.upper()}_CRITICAL_ALARMS}
        Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True
    END

Step ${index}: Perform recommissioning
    [Documentation]
    ...  Perform recommissioning.

    Log  Step ${index}: Commissioning via ADMIN will be performed using ${SCF_file_path} on ${BTS}  console=True
    coam.Perform Commissioning  bts_id=${bts_info[0]}  scf_file=${SCF_file_path}  skip_parameter_relation_errors=True
    ...  should_activate=True  timeout=400  connection=${alias}
    Log  ${BTS} commissioning has been performed  console=True

Step ${index}: Check feature CB008992 behaviour
    [Documentation]
    ...  Check feature CB008992 behaviour:
    ...  - FID1900 with field "Supplementary alarm information" info: "OBW excedeed"

    Log  Step ${index}: Check feature CB008992 behaviour  console=True

    Log  Check ${BTS} "RF Module configuring failed (1900)" alarm:  console=True
    Log  - expected number: 1  console=True
    Log  - expected specific field "Supplementary alarm information" info: "OBW excedeed"  console=True
    Assert Alarm Active  parameters=faultId=1900, supplAlarmInfo=regex"OBW exceeded.*"  timeout=300  alias=${alias}
    Log  Check ${BTS} "RF Module configuring failed (1900)" alarm passed:  console=True
    Log  - found number: 1  console=True
    Log  - found specific field "Supplementary alarm information" info: "OBW excedeed"  console=True

    ${SBTS_IGNORED_ALARMS_full}=  Combine Lists  ${SBTS_${alias.upper()}_IGNORED_ALARMS}  ${SBTS_${alias.upper()}_IGNORED_ALARMS_CUSTOM}

    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=${SBTS_${alias.upper()}_EXPECTED_ALARMS_1900}
    ...  ignored_alarms=${SBTS_IGNORED_ALARMS_full}  critical_alarms=${SBTS_${alias.upper()}_CRITICAL_ALARMS}

Step ${index}: Recover BTS initial settings
    [Documentation]
    ...  Perform chBw parameter recommissioning.

    Log  Step ${index}: Recover BTS initial settings  console=True
    Recover BTS initial settings

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Cells state is checked according to operationalState attribute
    ...  Check if number of configured cells and radio modules in SCF are properly mapping on BTS running view.
    ...  Also check RMs operationalState

    [Timeout]  30 min
    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Get and check BTS info precondition
    ${BTS_alias_label_dict}  ${BTS_label_alias_dict}=  Get BTS alias label info dict
    ${BTS_label_list}=  Get Dictionary Keys  ${BTS_label_alias_dict}
    Run Keyword If  '${BTS}' not in ${BTS_label_list}  Run Keywords
    ...  Log Long String  Selected value ${BTS} for test argument \${BTS} is not valid. Please select values for test argument \${BTS} from valid
    ...  values: ${BTS_label_list} or let default value: BTS1  level=ERROR
    ...  AND  Fail  Improper value for argument!

    ${alias}=  Get From Dictionary  ${BTS_label_alias_dict}  ${BTS}

    Set Test Variable  ${alias}

Recover BTS initial settings
    coam.Perform Commissioning  bts_id=${bts_info[0]}  scf_file=${SCF_file_path_initial}  skip_parameter_relation_errors=True
    ...  should_activate=True  timeout=400  alias=${alias}
    Log  ${BTS} commissioning has been performed  console=True

Particular Teardown
    Run Keyword And Continue On Failure  Recover BTS initial settings

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${FALSE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
*** Settings ***
Documentation    TC__SBTS_SBTS_SBTS__STATE__SM_Power_Off_On
Variables    tc_variables/sbts_sbts_sbts__state__sm_power_off_on_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}    3    # Number of BTS power OFF/ON operations, default value 3
${BTS_TO_POWER_OFF}  ALL  # BTS list on which power OFF/ON operation will be performed. Possible values (by default ALL):
                          # - ALL: action will be performed on all BTS (power OFF/ON each BTS until last BTS from TL)
                          # - list of selected BTS separated by comma labelized as BTSx (x is test_pc number in init.py)
${BTS1_POWER_ON_WRN_THR}   600    # If BTS1 reset exceeds BTS1_POWER_ON_WRN_THR, test verdict will be failed and snapshot
                                  # collected. Default value: in accordance with KPI 3 specifications
${BTS2_POWER_ON_WRN_THR}   600    # If BTS2 reset exceeds BTS2_POWER_ON_WRN_THR, test verdict will be failed and snapshot
                                  # collected. Default value: in accordance with KPI 3 specifications
${BTS3_POWER_ON_WRN_THR}   600    # If BTS3 reset exceeds BTS2_POWER_ON_WRN_THR, test verdict will be failed and snapshot
                                  # collected. Default value: in accordance with KPI 3 specifications
${SBTS_POWER_ON_MAX_WAIT_TIME}       900   # Maximum time for wait of SBTS OnAir (all cells up after reset).
                                           # If this value is exceeded, test will fail.

*** Keywords ***
TC__SBTS_SBTS_SBTS__STATE__SM_Power_Off_On
     [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-23737
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS-SBTS test case for BTS power OFF/ON, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for all BTS
    ...  - get all BTS info
    ...  - check PDU definition and reachability
    ...  - perform BTS power OFF/ON checking alarms and state
    ...  - check final state and alarms for for all BTS
    ...  Pass criteria: BTS power OFF/ON operation works as expected; states and alarms are as expected
    ...
    ...  ***************************
    ...  History of changes for SOAM
    ...  ***************************
    ...  - 28.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23737 - [5G][CB007588] SBTS_SBTS_SBTS_Startup_Module_Main_Power_Reset_ASOE
    ...  - 22.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24128 -
    ...  [5G] KPI3 measurement +TC verdict for SBTS_SBTS_SBTS__STATE__SM_Power_Off_On
    ...  - 12.01.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24336 -
    ...  [5G] Update KW 'Get and check BTS RESET info from IMS file' and 4 TCs
    ...  - 13.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24683 - [5G] Ignore alarm FID7107, AID7114 from SBTS_SBTS_SBTS tests
    ...  - 20.07.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25583 - [5G][TC review] Possibility to perform power off/on for both Cores
    ...  (Dual Core BTS) for SBTS_SBTS_SBTS
    ...  - 20.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25787 - [5G][CB007437] SBTS_SBTS_SBTS__STATE__SM_Power_Off_On adapt for CB007437
    ...  - 17.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26162 -
    ...  [5G] LTE_Site_Reset_from_WEBEM_SharedFHS_mixed_OBSAI_CPRI - update for FID10
    ...  - 15.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26595 - [5G] Add check for BTS state in TCs with Power on / unlock / unblock /
    ...  commissioning in Particular Teardown
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-23737_SBTS_SBTS_SBTS__STATE__SM_Power_Off_On.png

    Set Tags    CA-STATE    OWNER-adrian.ierulescu@nokia.com    AUTHOR-anca.tatar@nokia.com    PHASE-QT    SW-SBTS23R1

    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Get all BTS info
    Step 4: Check PDU definition and reachability
    FOR  ${CYCLE}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${CYCLE} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 5: Perform BTS power OFF/ON for iteration ${CYCLE}
        Step 6: Check final all BTS state
        Step 7: Check final all BTS alarms
        Step 8: Check final number and state of Cells and RMs
    END

    [Teardown]  Particular Teardown

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
        Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${SBTS_${alias.upper()}_IGNORED_ALARMS}
        ...  critical_alarms=${SBTS_${alias.upper()}_CRITICAL_ALARMS}
        Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True
    END

Step ${index}: Get all BTS info
    [Documentation]
    ...  Get all BTS info

    Log  Step ${index}: Get all BTS info  console=True
    ${BTS_alias_label_dict}  ${BTS_label_alias_dict}=  Get BTS alias label info dict
    Set Test Variable  ${BTS_alias_label_dict}
    Set Test Variable  ${BTS_label_alias_dict}
    ${BTS_alias_list}=  Get Dictionary Keys  ${BTS_alias_label_dict}  False
    ${BTS_label_list}=  Get Dictionary Values  ${BTS_alias_label_dict}  False
    Set Test Variable  ${BTS_alias_list}
    Set Test Variable  ${BTS_label_list}

    Run Keyword If  '${BTS_TO_POWER_OFF}' != 'ALL'  Check BTS list
    Log  ====================================================  console=True
    Log  BTS label list selected for power OFF/ON operation: ${BTS_label_list}  console=True
    Log  BTS alias list selected for power OFF/ON operation: ${BTS_alias_list}  console=True
    Log  ====================================================  console=True

    FOR  ${alias}  IN  @{BTS_alias_list}
        Get BTS CELL list by RAT  ${alias}
    END

Step ${index}: Check PDU definition and reachability
    [Documentation]
    ...  Check if PDU for RM are defined in config file

    Log  Step ${index}: Check PDU definition and reachability  console=True
    FOR  ${alias}  IN  @{BTS_alias_list}
        ${BTS_SM_PDU_if_name_list}=  Check BTS SMs PDU info definition  ${alias}
        Set Test Variable  ${${alias}_SM_PDU_if_name_list}  ${BTS_SM_PDU_if_name_list}
        ${PDU_port_status}=  Check BTS SMs PDU port status  ${${alias}_SM_PDU_if_name_list}  on
        ${alias_label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
        Run Keyword if  ${PDU_port_status}
        ...  Log  ${alias_label} SMs PDU port status as expected  console=True  console=True
        ...  ELSE  Run Keywords
        ...  Log  PDU for ${alias_label} SMs is either not reachable or not switched on!  level=ERROR
        ...  AND  Fail  PDU for ${alias_label} SMs is either not reachable or not switched on!
    END

Step ${index}: Perform BTS power OFF/ON for iteration ${CYCLE}
    [Documentation]
    ...  Perform BTS power OFF/ON

    Log  Step ${index}: Perform BTS power OFF/ON for iteration ${CYCLE}  console=True
    Set Test Variable  ${CYCLE}
    FOR  ${alias}  IN  @{BTS_alias_list}
        ${alias_label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
        Set Test Variable  ${alias_label}
        Log  Perform ${alias_label} power OFF/ON   console=True
        Get PL shared RM impact on other BTS  ${alias}
        Get start RESET timestamp info
        Power OFF BTS  ${alias}
        Power ON BTS  ${alias}
        Get end RESET timestamp info
        Check all BTS reset behavior based on IMS info  ${alias}
        Get and check KPI3 info from IMS file  ${alias}
    END

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Cells state is checked according to operationalState attribute
    ...  Check if number of configured cells and radio modules in SCF are properly mapping on BTS running view.
    ...  Also check RMs operationalState

    [Timeout]  30 min
    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Get and check KPI3 info from IMS file
    [Documentation]
    ...  Get and check KPI3 info from IMS file.
    [Arguments]  ${alias}
    Log  Get and check KPI3 info from IMS file  console=True
    ${label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
    ${kpi_name_delta_dict}=  Get and check KPI info from IMS file
    ...  kpi_names=kpi3  kpi_thresholds=${${label}_POWER_ON_WRN_THR}  alias=${alias}  remove_ims_file=False
    ...  start_point_timestamp_UTC=${date_timestamp_power_on_${alias}_UTC}  end_point_timestamp_UTC=${date_timestamp_cells_onair_${alias}_UTC}
    ${kpi_delta_list}=  Get From Dictionary  ${kpi_name_delta_dict}  kpi3
    Export KPI Results to File  alias=${alias}  obj=BTS  obj_type=SBTS  obj_id=${label}  action_1=BTS_Power_On  kpi_reported_1=KPI_3
    ...  event_value_1=${kpi_delta_list[0]}  cycle=${CYCLE}  source_info=ims

Check BTS list
    ${BTS_LIST_strip}=  Replace String  ${BTS_TO_POWER_OFF}  ${SPACE}  ${EMPTY}
    ${BTS_TO_POWER_OFF}=  Split String  ${BTS_LIST_strip}  ,
    ${BTS_check}=  Set Variable  True
    ${BTS_invalid_label_list}=  Create List
    ${BTS_request_label_list}=  Create List
    ${BTS_request_alias_list}=  Create List

    FOR  ${item}  IN  @{BTS_TO_POWER_OFF}
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

Get BTS CELL list by RAT
    [Arguments]  ${alias}
    ${NR_CELL_list}=  Get Ids For All  class_name=NRCEL  connection=${alias}
    ${LTE_CELL_list}=  Get Ids For All  class_name=LNCEL  connection=${alias}
    ${WCDMA_CELL_list}=  Get Ids For All  class_name=WNCEL  connection=${alias}
    ${GSM_CELL_list}=  Get Ids For All  class_name=GNCEL  connection=${alias}
    ${CELL_list}=  Combine Lists   ${NR_CELL_list}  ${LTE_CELL_list}  ${WCDMA_CELL_list}  ${GSM_CELL_list}
    Set Test Variable  ${${alias}_NR_CELL_list}  ${NR_CELL_list}
    Set Test Variable  ${${alias}_LTE_CELL_list}  ${LTE_CELL_list}
    Set Test Variable  ${${alias}_WCDMA_CELL_list}  ${WCDMA_CELL_list}
    Set Test Variable  ${${alias}_GSM_CELL_list}  ${GSM_CELL_list}
    Set Test Variable  ${${alias}_CELL_list}  ${CELL_list}

Get PL shared RM impact on other BTS
    [Arguments]  ${alias}

    Log  Get PL shared RM impact on other BTS   console=True
    ${all_BTS_PL_shared_RM_info}=  Get PL shared RM info on all BTS
    ${BTS_PL_shared_RM_info}=  Get From Dictionary  ${all_BTS_PL_shared_RM_info}  ${alias}
    ${BTS_PL_CPRI_shared_RM_sn_list}=  Get From Dictionary  ${BTS_PL_shared_RM_info}  BTS_PL_CPRI_shared_RM_sn_list
    ${BTS_PL_ECPRI_shared_RM_sn_list}=  Get From Dictionary  ${BTS_PL_shared_RM_info}  BTS_PL_ECPRI_shared_RM_sn_list
    ${BTS_PL_OBSAI_shared_RM_sn_list}=  Get From Dictionary  ${BTS_PL_shared_RM_info}  BTS_PL_OBSAI_shared_RM_sn_list

    FOR  ${other_alias}  IN  @{alias_list}
        Continue For Loop If  '${other_alias}' == '${alias}'
        ${other_label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${other_alias}

        ${other_BTS_PL_shared_RM_info}=  Get From Dictionary  ${all_BTS_PL_shared_RM_info}  ${other_alias}
        ${other_BTS_non_PL_CPRI_shared_RM_sn_list}=  Get From Dictionary  ${other_BTS_PL_shared_RM_info}  BTS_non_PL_CPRI_shared_RM_sn_list
        ${other_BTS_non_PL_ECPRI_shared_RM_sn_list}=  Get From Dictionary  ${other_BTS_PL_shared_RM_info}  BTS_non_PL_ECPRI_shared_RM_sn_list
        ${other_BTS_non_PL_OBSAI_shared_RM_sn_list}=  Get From Dictionary  ${other_BTS_PL_shared_RM_info}  BTS_non_PL_OBSAI_shared_RM_sn_list

        ${other_BTS_CPRI_alarm_count}=  Calculate other BTS alarms count  ${BTS_PL_CPRI_shared_RM_sn_list}
        ...  ${other_BTS_non_PL_CPRI_shared_RM_sn_list}
        ${other_BTS_ECPRI_alarm_count}=  Calculate other BTS alarms count  ${BTS_PL_ECPRI_shared_RM_sn_list}
        ...  ${other_BTS_non_PL_ECPRI_shared_RM_sn_list}
        ${other_BTS_OBSAI_alarm_count}=  Calculate other BTS alarms count  ${BTS_PL_OBSAI_shared_RM_sn_list}
        ...  ${other_BTS_non_PL_OBSAI_shared_RM_sn_list}

        Log  ${other_label} impacted CPRI shared RM count: ${other_BTS_CPRI_alarm_count}   console=True
        Log  ${other_label} impacted ECPRI shared RM count: ${other_BTS_ECPRI_alarm_count}   console=True
        Log  ${other_label} impacted OBSAI shared RM count: ${other_BTS_OBSAI_alarm_count}   console=True

        ${FID10_1815_count}=  Set Variable  ${other_BTS_CPRI_alarm_count}
        ${FID16_alarm_count}=  Evaluate  ${other_BTS_ECPRI_alarm_count} + 0
        Set Test Variable  ${${other_alias}_FID10_1815_alarm_count}  ${FID10_1815_count}
        Set Test Variable  ${${other_alias}_FID16_alarm_count}  ${FID16_alarm_count}
        ${SBTS_EXPECTED_ALARMS}=  Create List
        ${SBTS_EXPECTED_ALARMS_10_full}=  Prepare expected alarms list  ${SBTS_${other_alias.upper()}_EXPECTED_ALARMS_10}
        ...  ${other_BTS_OBSAI_alarm_count}
        ${SBTS_EXPECTED_ALARMS_16_full}=  Prepare expected alarms list  ${SBTS_${other_alias.upper()}_EXPECTED_ALARMS_16}  ${FID16_alarm_count}
        ${SBTS_EXPECTED_ALARMS_10_1815_full}=  Prepare expected alarms list  ${SBTS_${other_alias.upper()}_EXPECTED_ALARMS_10_1815}
        ...  ${FID10_1815_count}
        ${SBTS_EXPECTED_ALARMS_10_1815_16_full}=  Combine Lists  ${SBTS_EXPECTED_ALARMS_10_full}  ${SBTS_EXPECTED_ALARMS_16_full}
        ...  ${SBTS_EXPECTED_ALARMS_10_1815_full}
        ${SBTS_EXPECTED_ALARMS}=  Set Variable If
        ...  (${FID10_1815_count} == 0 and ${other_BTS_CPRI_alarm_count} == 0)
        ...  ${SBTS_EXPECTED_ALARMS}  ${SBTS_EXPECTED_ALARMS_10_1815_16_full}
        Set Test Variable  ${SBTS_${other_alias.upper()}_EXPECTED_ALARMS}  ${SBTS_EXPECTED_ALARMS}
    END

Calculate other BTS alarms count
    [Arguments]  ${BTS_PL_shared_RM_sn_list}  ${other_BTS_non_PL_shared_RM_sn_list}
    ${other_BTS_alarm_count}=  Set Variable  0

    FOR  ${item}  IN  @{BTS_PL_shared_RM_sn_list}
        ${other_BTS_alarm_count}=  Run Keyword If  '${item}' in ${other_BTS_non_PL_shared_RM_sn_list}
        ...  Evaluate  ${other_BTS_alarm_count} + 1
        ...  ELSE
        ...  Evaluate  ${other_BTS_alarm_count} + 0
    END

    [Return]  ${other_BTS_alarm_count}

Get ${when} RESET timestamp info
    Get Current Date UTC info  ${when}
    Log  UTC ${when}_point_timestamp: ${date_timestamp_${when}_UTC}  console=True

Power OFF BTS
    [Documentation]
    ...  Keyword used to power OFF BTS
    [Arguments]  ${alias}

    Power BTS  ${alias}  OFF
    Log  Wait 1 min after ${alias_label} is powered OFF  console=True
    Sleep  1 min
    Check state and alarms after power off  ${alias}

Power ON BTS
    [Documentation]
    ...  Keyword used to power ON BTS
    [Arguments]  ${alias}

    Power BTS  ${alias}  ON
    Wait for BTS Startup  ${alias}
    Check state and alarms after power on  ${alias}

Power BTS
    [Documentation]
    ...  Helper Keyword used to power ON/OFF BTS

    [Arguments]  ${alias}  ${power}

    Log  Power ${power} ${alias_label}  console=True

    ${power}=  Convert To Lower Case  ${power}
    Run Keyword If  '${power}' == 'on'  Get Current Date UTC info  power_on_${alias}
    ${PDU_port_status}=  Set BTS SMs PDU port status  ${${alias}_SM_PDU_if_name_list}  ${power}
    Run Keyword If  ${PDU_port_status}
    ...  Log  ${alias_label} SMs PDU port status ${power}, as expected  console=True
    ...  ELSE  Run Keywords
    ...  Log  Set ${alias_label} SMs PDU port status ${power} failed!  level=ERROR
    ...  AND  Fail  Set ${alias_label} SMs PDU port status on failed!
    Run Keyword If  '${power}' == 'on'  Run Keywords
    ...  Get Current Time  bts_initial
    ...  AND  Log  Power ON ${alias_label} time is: ${time_bts_initial}  console=True

Check state and alarms after power off
    [Arguments]  ${alias}

    Log  ***** Check the other BTS(s) status after "Power OFF" operation on ${alias_label} *****  console=True

    FOR  ${other_alias}  IN  @{alias_list}
        Continue For Loop If  '${other_alias}' == '${alias}'
        ${other_label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${other_alias}
        ${SBTS_IGNORED_ALARMS_FULL}=  Combine Lists  ${SBTS_${other_alias.upper()}_IGNORED_ALARMS}  ${SBTS_${other_alias.upper()}_IGNORED_ALARMS_X2}
        ...  ${SBTS_${other_alias.upper()}_IGNORED_ALARMS_SYNC}

        Log  Check ${other_label} alarms:  console=True
        Run Keyword If  ${${other_alias}_FID10_1815_alarm_count}
        ...  Log Long String  ${other_label} "Not able to synchronize baseband bus (1815)" or "No connection to unit (10)" alarm,
        ...  expected number: ${${other_alias}_FID10_1815_alarm_count}  console=True
        Run Keyword If  ${${other_alias}_FID16_alarm_count}
        ...  Log Long String  ${other_label} "Unit synchronization failed (16)" alarm, expected number: ${${other_alias}_FID16_alarm_count}
        ...  console=True
        Get and Check Alarms SOAM  alias=${other_alias}  expected_alarms=${SBTS_${other_alias.upper()}_EXPECTED_ALARMS}
        ...  ignored_alarms=${SBTS_IGNORED_ALARMS_FULL}  critical_alarms=${SBTS_${other_alias.upper()}_CRITICAL_ALARMS}
        Run Keyword If  ${${other_alias}_FID10_1815_alarm_count}
        ...  Log Long String  ${other_label} "Not able to synchronize baseband bus (1815)" or "No connection to unit (10)" alarm,
        ...  found number: ${${other_alias}_FID10_1815_alarm_count}, as expected!  console=True
        Run Keyword If  ${${other_alias}_FID16_alarm_count}
        ...  Log Long String  ${other_label} "Unit synchronization failed (16)" alarm, found number: ${${other_alias}_FID16_alarm_count},
        ...  as expected!  console=True
        Log  ${other_label} site - expected, ignored and critical alarms checked  console=True
    END

Check state and alarms after power on
    [Arguments]  ${alias}

    ${CELL_state_enabled_check}=  Set Variable  operationalState=${Enabled_}, blockingState=${Unblocked_}
    ${CELL_state_enabled}=  Set Variable  operationalState=Enabled, blockingState=Unblocked

    Log  ***** Check ${alias_label} status after "Power ON" operation on ${alias_label} *****  console=True

    Log  Check ${alias_label} status:  console=True
    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  600  ${alias}
    Log  ${alias_label} site - proceduralState: OnAir, blockingState: Unblocked, as expected!  console=True
    ${remained_time}=  Determine remaining time for ${alias}
    Admin Check all BTS cells expected states  ${CELL_state_enabled_check}  ${alias}  ${remained_time}
    Log  All ${alias_label} cell(s) status:\n - ${CELL_state_enabled}  console=True

    Log  Check ${alias_label} alarms:  console=True
    Log  ${alias_label} expected alarm number: 0  console=True
    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${SBTS_${alias.upper()}_IGNORED_ALARMS}
    ...  critical_alarms=${SBTS_${alias.upper()}_CRITICAL_ALARMS}
    Log  ${alias_label} found alarm number: 0, as expected!  console=True
    Log  ${alias_label} site - expected, ignored and critical alarms checked  console=True

    Log  ***** Check the other BTS(s) status and alarms after "Power ON" operation on ${alias_label} *****  console=True
    FOR  ${other_alias}  IN  @{alias_list}
        Continue For Loop If  '${other_alias}' == '${alias}'
        ${other_label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${other_alias}

        Log  Check ${other_label} status:  console=True
        Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  180  ${other_alias}
        Log  ${other_label} site - proceduralState: OnAir, blockingState: Unblocked, as expected!  console=True
        Admin Check all BTS cells expected states  ${CELL_state_enabled_check}  ${other_alias}  180
        Log  All ${other_label} cell(s) status:\n - ${CELL_state_enabled}  console=True

        Log  Check ${other_label} alarms:  console=True
        Log  ${other_label} expected alarm number: 0  console=True
        Get and Check Alarms SOAM  alias=${other_alias}  expected_alarms=@{EMPTY}  ignored_alarms=${SBTS_${other_alias.upper()}_IGNORED_ALARMS}
        ...  critical_alarms=${SBTS_${other_alias.upper()}_CRITICAL_ALARMS}
        Log  ${other_label} found alarm number: 0, as expected!  console=True
        Log  ${other_label} site - expected, ignored and critical alarms checked  console=True
    END

    Get Current Date UTC info  cells_onair_${alias}

Wait for BTS Startup
    [Documentation]
    ...  Keyword used to wait for BTS Startup
    [Arguments]  ${alias}

    Log  Wait for ${alias_label} Startup  console=True
    Run Keyword If  '${alias}' == 'Master'
    ...  Wait For Target To Be Reachable TAF  hostname=${MASTER['MASTER_TECH_IP_ADDRESS']}  timeout=180
    ...  ELSE
    ...  Wait For Target To Be Reachable TAF  hostname=${${alias.upper()}}[${alias.upper()}_TECH_IP_ADDRESS]
    ...  remote_host=${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]  timeout=180
    Get Current Time  sbts_startup
    Log  Startup ${alias_label} time is: ${time_sbts_startup}  console=True
    Sleep  1 min

Check all BTS reset behavior based on IMS info
    [Documentation]
    ...  BTS RESET info is checked based on IMS info. Reset behavior as expected if:
    ...  - BTS ${alias} site: 1
    ...  - other BTS(s) site: reset number is 0
    ...  Otherwise, reset behavior not as expected, then errors are added to report and failed.
    [Arguments]  ${alias}

    Log  Check all BTS reset behavior based on IMS info  console=True
    Get and check BTS RESET info from IMS file  expected_reset_number=1  alias=${alias}
    ...  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}
    FOR  ${other_alias}  IN  @{alias_list}
        Continue For Loop If  '${other_alias}' == '${alias}'
        Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=${other_alias}
        ...  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}
    END

Check if all PDU port status is on
     FOR  ${alias}  IN  @{BTS_alias_list}
        Recover BTS SMs PDU port status  ${${alias}_SM_PDU_if_name_list}  on  ${alias}
     END

Determine remaining time for ${alias}
    Get intermediate RESET timestamp info
    ${elapsed_time}=  DateTime.Subtract Date from Date  ${date_timestamp_intermediate_UTC}  ${date_timestamp_power_on_${alias}_UTC}  number
    ${remained_time}=  BuiltIn.Evaluate  ${SBTS_POWER_ON_MAX_WAIT_TIME} - ${elapsed_time}
    [Return]  ${remained_time}

Particular Teardown
    Run Keyword And Continue On Failure  Check if all PDU port status is on
    Export KPI results to File Global  kpi_log_file_name=KpiTimeInfo
    Check all BTS cells availability status online

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown

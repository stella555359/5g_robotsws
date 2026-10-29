*** Settings ***
Documentation    TC__SBTS__STATE__FHS_Reset_from_WEBEM
Variables    tc_variables/sbts__state__fhs_reset_from_webem_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}    3       # Number of FHS reset operations, default value 3
${RESET_TYPE}        Hard    # Reset type: Soft, Hard or Warm, default value Hard

*** Keywords ***
TC__SBTS__STATE__FHS_Reset_from_WEBEM

    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-22458
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS test case for FHS reset operations, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial BTS state and alarms
    ...  - prepare FHS list and related mapping info
    ...  - perform Reset operation on each FHS checking BTS state and alarms
    ...  - check final BTS state and alarms
    ...  Pass criteria: reset operation works as expected; states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 08.02.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-22458 - Create new automated test SBTS_RFSplit_FHS_Reset_from_WEBEM
    ...  - 22.03.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-22800
    ...  - [5G][RFSplit]SBTS__STATE__BBMOD_LockUnlock_from_WEBEM fails due to IOT cells
    ...  - 23.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24774 - [5G] Replace Setup Admin KW with Start new ADMIN instance KW - RFSplit
    ...  - 09.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24193 - [5G][Reset Number ims2] Update SBTS STATE, FM
    ...  scenarios to take reset number from ims2 - P2
    ...  - 04.04.2023 - https://wrgitlab.ext.net.nokia.com/RAN/robotws.git -
    ...  [5G][Refactoring Tracker][CNI 82119] Refactor FHS state check based on admin instead of admin-infomodel - RFSplit
    ...  - 20.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24860 - [5G][CB008733] Need to consider Obsai, CPRI modules connected only in FHS
    ...  for SBTS_STATE_FHS_Reset_from_WEBEM.robot RF Split
    ...  - 01.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29003 -
    ...  Detect SBTS-SBTS instead off LTE-LTE for SBTS_SBTS__STATE__SharedRM_Power_Off_On
    ...  - 03.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29815 -
    ...  Unify alarm container names between all tests in order to use ${${alias.upper()}}_ALARMS_CNI_127210 ${${alias.upper()}}_ALARMS_NO_CNI_127210
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/TAT-22458_SBTS__STATE__FHS_Reset_from_WEBEM.png

    Set Tags    CA-STATE    OWNER-calin.velcsoff@nokia.com    AUTHOR-anca.tatar@nokia.com    PHASE-QT

    Step 1: Check initial BTS state
    Step 2: Check initial BTS alarms
    Step 3: Get BTS FHS list
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log     ==============================================================================  console=True
        Log     Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log     ==============================================================================  console=True
        Step 4: Reset BTS FHS
        Step 5: Check BTS reset behavior based on IMS info
        Step 6: Check final number and state of Cells and RMs
    END
    Step 7: Check final BTS state
    Step 8: Check final BTS alarms

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

Step ${index}: Get BTS FHS list
    [Documentation]
    ...  BTS FHS list is get from Admin

    [Timeout]  5 min
    Log  Step ${index}: Get BTS FHS list  console=True
    ${SBTS_FHS_list}=  Admin Get FHS Ids  alias=${alias_local}
    ${SBTS_FHS_count}=  Get Length  ${SBTS_FHS_list}
    Run Keyword If  ${SBTS_FHS_count} > 0
    ...  Log  FHS found: ${SBTS_FHS_list}  console=True
    ...  ELSE
    ...  Fail  No FHS are present in runtime view configuration!
    Set Test Variable  ${SBTS_FHS_list}
    Set Test Variable  ${SBTS_FHS_count}

    ${SBTS_BBMOD_list}=  Get Ids For All  class_name=BBMOD  connection=${alias_local}
    Sort List  ${SBTS_BBMOD_list}
    Set Test Variable  ${SBTS_BBMOD_list}

    ${SBTS_RMOD_list}=  Get Ids For All  class_name=RMOD  connection=${alias_local}
    Sort List  ${SBTS_RMOD_list}
    Set Test Variable  ${SBTS_RMOD_list}

    ${SBTS_RMOD_CELL_dict}=  Get RM CELL mapping info dict  ${SBTS_RMOD_list}
    Set Test Variable  ${SBTS_RMOD_CELL_dict}

    ${NR_CELL_list}=  Get Ids For All  class_name=NRCEL  connection=${alias_local}
    ${LTE_CELL_list}  ${LTE_CELL_IOT_list}=  Admin Get LTE CELL Ids list  ${alias_local}
    ${WCDMA_CELL_list}=  Get Ids For All  class_name=WNCEL  connection=${alias_local}
    ${GSM_CELL_list}=  Get Ids For All  class_name=GNCEL  connection=${alias_local}
    ${CELL_list}=  Combine Lists   ${NR_CELL_list}  ${LTE_CELL_list}  ${WCDMA_CELL_list}  ${GSM_CELL_list}
    Set Test Variable  ${NR_CELL_list}
    Set Test Variable  ${LTE_CELL_list}
    Set Test Variable  ${WCDMA_CELL_list}
    Set Test Variable  ${GSM_CELL_list}
    Set Test Variable  ${CELL_list}

Step ${index}: Reset BTS FHS
    Log  Step ${index}: Reset BTS FHS  console=True
    FOR  ${item}  IN  @{SBTS_FHS_list}
        Get Current Date UTC info  start
        Reset FHS  ${item}
        Get Current Date UTC info  end
    END

Step ${index}: Check BTS reset behavior based on IMS info
    [Documentation]
    ...  Check BTS reset behavior based on IMS info. Reset behavior as expected if:
    ...  - reset number is 0
    ...  Otherwise, reset behavior not as expected, then errors are added to report and failed.

    Log  Step ${index}: Check BTS reset behavior based on IMS info  console=True
    Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=${alias_local}
    ...  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Get RM CELL mapping info dict
    [Arguments]   ${RM_list}
    ${RM_CELL_dict}=  Create Dictionary
    FOR  ${item}  IN  @{RM_list}
        ${CELL_list}=  Get Cell Mapping By Module Id  module_id=${item}  connection=${alias_local}
        Sort List  ${CELL_list}
        Set To Dictionary  ${RM_CELL_dict}  ${item}  ${CELL_list}
    END
    [Return]  ${RM_CELL_dict}

Reset FHS
    [Arguments]  ${FHS_id}
    ${FHS_id_list}=  Create List
    Append To List  ${FHS_id_list}  ${FHS_id}
    Set Test Variable  ${FHS_id}
    Set Test Variable  ${FHS_id_list}
    Set Test Variable  ${FHS_state_disabled_check}
    ...  operationalState=${Disabled_}, availabilityStatus=${NotInstalled_}, administrativeState=${Unlocked_}
    Set Test Variable  ${FHS_state_enabled_check}  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    Set Test Variable  ${RMOD_state_degraded_check}  operationalState=${Enabled_}, availabilityStatus=${Degraded_}, administrativeState=${Unlocked_}
    Set Test Variable  ${RMOD_state_enabled_check}  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    Set Test Variable
    ...  ${RMOD_state_disabled_check}  operationalState=${Disabled_}, availabilityStatus=${NotInstalled_Offline_}, administrativeState=${Unlocked_}
    Set Test Variable  ${CELL_state_enabled_check}  operationalState=${Enabled_}, blockingState=${Unblocked_}
    Set Test Variable  ${FHS_state_disabled}  operationalState=Disabled, availabilityStatus=NotInstalled, administrativeState=Unlocked
    Set Test Variable  ${FHS_state_enabled}  operationalState=Enabled, administrativeState=Unlocked
    Set Test Variable  ${RMOD_state_degraded}  operationalState=Enabled, availabilityStatus=Degraded, administrativeState=Unlocked
    Set Test Variable  ${RMOD_state_enabled}  operationalState=Enabled, administrativeState=Unlocked
    Set Test Variable  ${RMOD_state_disabled}  operationalState=Disabled, availabilityStatus=NotInstalled|Offline, administrativeState=Unlocked
    Set Test Variable  ${CELL_state_enabled}  operationalState=Enabled, blockingState=Unblocked

    Set Test Variable  ${SBTS_alarm_count}  0
    ${SBTS_FHS_RMOD_list}=  Get RMOD Mapping on specific FHS  ${FHS_id}  ${alias_local}
    ${SBTS_FHS_CELL_list}=  Get CELL Mapping By FHS Id  ${SBTS_FHS_RMOD_list}
    ${SBTS_BBMOD_RMOD_list}=  Get BBMOD RMOD list  ${SBTS_BBMOD_list}  ${alias_local}

    ${SBTS_BBMOD_FHS_RMOD_list}=  Create List

    FOR  ${item}  IN  @{SBTS_FHS_RMOD_list}
        Run Keyword If  '${item}' in @{SBTS_BBMOD_RMOD_list}  Append To List  ${SBTS_BBMOD_FHS_RMOD_list}  ${item}
    END

    FOR  ${item}  IN  @{SBTS_BBMOD_FHS_RMOD_list}
        Remove Values From List  ${SBTS_FHS_RMOD_list}  ${item}
        Remove Values From List  ${SBTS_BBMOD_RMOD_list}  ${item}
    END

    Set Test Variable  ${SBTS_FHS_RMOD_list}
    Set Test Variable  ${SBTS_BBMOD_RMOD_list}
    Set Test Variable  ${SBTS_BBMOD_FHS_RMOD_list}

    Log  ***** Perform "Reset" operation on FHS ${FHS_id} from WebEM *****  console=True
    ${new_alias}  Set Variable  resetFHS
    Start new ADMIN instance  alias=${alias_local}  new_alias=${new_alias}  connection_type=${connection_type_${alias_local}}
    ${reset_info}=  Run Keyword In Background  Reset Unit  dist_name=${FHS_id}  reset_type=${RESET_TYPE}  timeout=600  connection=${new_alias}
    Sleep  10s

    Check FHS state during/after FHS reset  during
    Check RMOD state during/after FHS reset  during
    Check cells state during/after FHS reset  during

    Collect Keyword Result  ${reset_info}  timeout=600

    Check FHS state during/after FHS reset  after
    Check RMOD state during/after FHS reset  after
    Check cells state during/after FHS reset  after
    Check alarms during/after FHS reset  after

    [Teardown]  Teardown Admin  alias=${new_alias}

Get CELL Mapping By FHS Id
    [Arguments]   ${NR_FHS_RMOD_list}
    ${NR_FHS_CELL_list}=  Create List
    FOR  ${item}  IN  @{NR_FHS_RMOD_list}
        ${NR_FHS_RMOD_CELL_list}=  Get Cell Mapping By Module Id  module_id=${item}  alias=${alias_local}
        Append To List  ${NR_FHS_CELL_list}  @{NR_FHS_RMOD_CELL_list}
    END
    ${NR_FHS_CELL_list}=  Remove Duplicates  ${NR_FHS_CELL_list}
    [Return]  ${NR_FHS_CELL_list}

Check BTS Item State
    [Arguments]   ${BTS_item_class}  ${BTS_item_list}  ${BTS_item_state_check}  ${BTS_item_state}  ${timeout}  ${alias}
    FOR  ${item}  IN  @{BTS_item_list}
        Assert  class_name=${BTS_item_class}  id=${item}  parameters=${BTS_item_state_check}  timeout=${timeout}  connection=${alias}
        Log  ${BTS_item_class} ${item} status:\n - ${BTS_item_state}  console=True
    END

Check FHS state during/after FHS reset
    [Arguments]    ${when}

    Log  Check FHS state ${when} FHS ${FHS_id} reset:  console=True
    Run Keyword If  '${when}' == 'during'  Run Keywords
    ...  Wait Until Keyword Succeeds  180 sec  2 sec  Admin Check FHS list state  ${FHS_id_list}  ${Disabled_}
    ...  Disabled  ${NotInstalled_}  NotInstalled  ${Unlocked_}  Unlocked  alias=${alias_local}
    ...  AND  Log  FHS ${FHS_id} status as expected!  console=True
    ...  ELSE IF  '${when}' == 'after'  Run Keywords
    ...  Wait Until Keyword Succeeds  180 sec  10 sec  Admin Check FHS list state  ${FHS_id_list}  ${Enabled_}  Enabled
    ...  ${Online_}  Online|None  ${Unlocked_}  Unlocked  alias=${alias_local}
    ...  AND  Log  FHS ${FHS_id} status as expected!  console=True

Check RMOD state during/after FHS reset
    [Arguments]    ${when}

    Run Keyword If  '${when}' == 'after'  Run Keywords
    ...  Log  Check RMOD(s) state ${when} FHS ${FHS_id} reset:  console=True
    ...  AND  Check BTS Item State  RMOD  ${SBTS_RMOD_list}  ${RMOD_state_enabled_check}  ${RMOD_state_enabled}  180  ${alias_local}
    ...  AND  Log  All BTS RMOD(s) status as expected!  console=True
    ...  AND  Return From Keyword

    Log  Check RMOD(s) state that are not connected to FHS ${when} FHS ${FHS_id} reset:  console=True
    Run Keyword If  ${SBTS_BBMOD_RMOD_list}  Run Keywords
    ...  Check BTS Item State  RMOD  ${SBTS_BBMOD_RMOD_list}  ${RMOD_state_enabled_check}  ${RMOD_state_enabled}  5  ${alias_local}
    ...  AND  Log  All BTS RMOD(s) not connected to FHS ${FHS_id} status as expected!  console=True

    Log  Check RMOD(s) state that are connected to FHS and BBMOD ${when} FHS ${FHS_id} reset:  console=True
    Run Keyword If  ${SBTS_BBMOD_FHS_RMOD_list}  Run Keywords
    ...  Check BTS Item State  RMOD  ${SBTS_BBMOD_FHS_RMOD_list}  ${RMOD_state_degraded_check}  ${RMOD_state_degraded}  5  ${alias_local}
    ...  AND  Log  All BTS RMOD(s) connected to FHS ${FHS_id} and BBMOD status as expected!  console=True

    Log  Check RMOD(s) state that are connected only to FHS ${when} FHS ${FHS_id} reset:  console=True
    Run Keyword If  ${SBTS_FHS_RMOD_list}  Run Keywords
    ...  Check BTS Item State  RMOD  ${SBTS_FHS_RMOD_list}  ${RMOD_state_disabled_check}  ${RMOD_state_disabled}  5  ${alias_local}
    ...  AND  Log  All BTS RMOD(s) connected only to FHS ${FHS_id} status as expected!  console=True

Check cells state during/after FHS reset
    [Arguments]    ${when}

    Log  Check cell(s) state ${when} FHS ${FHS_id} reset:  console=True
    Run Keyword If  '${when}' == 'during'  Run Keywords
    ...  Run Keyword If  ${NR_CELL_list}  Check NR cells state and MIMO alarm  alias=${alias_local}
    ...  AND  Run Keyword If  ${LTE_CELL_list}  Check LTE cells state and MIMO alarm  alias=${alias_local}
    ...  AND  Run Keyword If  ${WCDMA_CELL_list}  Check WCDMA cells state and MIMO alarm  alias=${alias_local}
    ...  AND  Run Keyword If  ${GSM_CELL_list}  Check GSM cells state and MIMO alarm  alias=${alias_local}
    ...  AND  Log  All BTS cell(s) status as expected!  console=True
    ...  ELSE IF  '${when}' == 'after'  Run Keywords
    ...  Run Keyword If  ${NR_CELL_list}
    ...  Check BTS Item State  NRCEL  ${NR_CELL_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  300  ${alias_local}
    ...  AND  Run Keyword If  ${LTE_CELL_list}
    ...  Check BTS Item State  LNCEL  ${LTE_CELL_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  300  ${alias_local}
    ...  AND  Run Keyword If  ${WCDMA_CELL_list}
    ...  Check BTS Item State  WNCEL  ${WCDMA_CELL_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  300  ${alias_local}
    ...  AND  Run Keyword If  ${GSM_CELL_list}
    ...  Check BTS Item State  GNCEL  ${GSM_CELL_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  300  ${alias_local}
    ...  AND  Log  All BTS cell(s) status as expected!  console=True

Check alarms during/after FHS reset
    [Arguments]    ${when}

    Log  Check BTS alarms ${when} FHS ${FHS_id} reset:  console=True
    Get and Check Alarms SOAM  alias=${alias_local}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias_local.upper()}_IGNORED_ALARMS}
    ...  critical_alarms=${${alias_local.upper()}_CRITICAL_ALARMS}
    Log  BTS site - expected, ignored and critical alarms checked  console=True

Get BBMOD RMOD list
    [Arguments]  ${BBMOD_list}  ${alias}
    ${BBMOD_RMOD_list}=  Create List
    FOR  ${item}  IN  @{BBMOD_list}
        ${RMOD_list}=  Get RMOD Mapping By BBMOD Id  ${item}  ${alias}
        ${BBMOD_RMOD_list}=  Combine Lists  ${BBMOD_RMOD_list}  ${RMOD_list}
    END
    Remove Duplicates  ${BBMOD_RMOD_list}

    [Return]  ${BBMOD_RMOD_list}

Get RMOD Mapping By BBMOD Id
    [Arguments]   ${BBMOD_id}  ${alias}
    ${BBMOD_RMOD_list}=  Create List
    ${CABLINK_list}=  Get Parameters For All  CABLINK  alias=${alias}
    FOR  ${item}  IN  @{CABLINK_list}
        ${secondEndpointDN_RMOD_R}=  Run Keyword And Return Status  Should Contain  ${item.secondEndpointDN}  RMOD_R
        Run Keyword If  '${item.firstEndpointDN}' == '${BBMOD_id}' and ${secondEndpointDN_RMOD_R}
        ...  Append To List  ${BBMOD_RMOD_list}  ${item.secondEndpointDN}
    END
    Sort List  ${BBMOD_RMOD_list}
    [Return]  ${BBMOD_RMOD_list}

TC Setup
    ${tech_preset_list}=  Create List  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown

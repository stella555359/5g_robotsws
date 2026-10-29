*** Settings ***
Documentation    TC__SBTS__STATE__RAT_Reset_from_WEBEM
Variables    tc_variables/sbts__state__rat_reset_from_webem_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}          3      # Number of Reset RAT operations, default value 3
${RAT_TECH}                all    # RAT that needs to be reset. Possible values: all(RATs will be reset one by one),
                                  # NR, LTE, WCMDA, GSM
${NR_RESET_WRN_THR}        120    # Time from first cell down to last cell up defined in seconds for NR RAT.
                                  # Defaults to 120, in accordance with KPI10 specifications.
                                  # Default applicable in SA configration. For NSA configuration extra delay applies due to x2.
                                  # In multi-core configuration extra delay applies. Check manual test case descripton for exact values.
${LTE_RESET_WRN_THR}       120    # Time from first cell down to last cell up defined in seconds for LTE RAT.
                                  # Defaults to 120, in accordance with KPI7 specifications
${WCDMA_RESET_WRN_THR}     120    # Time from first cell down to last cell up defined in seconds for WCDMA RAT.
                                  # Defaults to 120, in accordance with KPI8 specifications
${GSM_RESET_WRN_THR}       120    # Time from first cell down to last cell up defined in seconds for GSM RAT.
                                  # Defaults to 120, in accordance with KPI9 specifications
${MAX_WAIT_TIME}           900    # Maximum time for wait of RAT OnAir
${RESET_TYPE}              Soft   # Reset type: Soft or Hard; default value: Soft, Hard value supported only stating with CB008880 24R2
${GRACEFUL_CELL_SHUTDOWN}  True  # Graceful cell shutdown: True or False; default value: True

*** Keywords ***
TC__SBTS__STATE__RAT_Reset_from_WEBEM
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-21077
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS test case for Individual RAT Reset from WEBEM, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial BTS state and alarms
    ...  - reset RAT as specified in ${RAT_TECH}
    ...  - check final BTS state and alarms
    ...  - check BTS reset behavior based on IMS info: reset number is 0
    ...  Pass criteria: BTS RAT Reset successfully, states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 08.11.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-21077 - [5G][RFSplit]Create new automated test SBTS__STATE__RAT_Reset_from_WEBEM
    ...  - 21.02.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-22575 - [5G] Update comment in RFsplit SBTS__STATE__RAT_Reset_from_WEBEM
    ...  for NR RAT Kpi
    ...  - 22.03.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-22800
    ...  - [5G][RFSplit]SBTS__STATE__BBMOD_LockUnlock_from_WEBEM fails due to IOT cells
    ...  - 14.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24298 -
    ...  [5G][refactoring] Add generalized implementation of "Open new admin session" in TCs SBTS -pair with TAT-24251
    ...  - 09.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24193 - [5G][Reset Number ims2] Update SBTS STATE, FM
    ...  scenarios to take reset number from ims2 - P2
    ...  - 15.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25367 - [5G] New implementation KPI7,8,9,10 measurement
    ...  TC verdict for SBTS__STATE__RAT_Reset_from_WEBEM
    ...  - 22.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25594 - [5G] Same KPI value found in KPI file for automated RAT reset scenarios
    ...  - 13.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26539 - [5G][CB009163] Port Implementation of Cell state check and RMOD
    ...  behavior check in RFSplit RAT Reset TC
    ...  - 23.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26788 - [5G][CB009163]Need 10s sleep time before cell state check for
    ...  SBTS__STATE__RAT_Reset_from_WEBEM
    ...  - 27.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27165 - [5G] [Part 1] SBTS__STATE__RAT_Reset_from_WEBEM to take into
    ...  consideration CB008880 starting 24R2
    ...  - 17.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27164 - [5G] [Part 2] SBTS__STATE__RAT_Reset_from_WEBEM to take into
    ...  consideration CB008880 starting 24R2 - after TAT-27006
    ...  - 14.05.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27410 - [5G] [Infomodel] - P1 - Eliminate usage of KW Infomodel "Get baseband
    ...  pool allocation mode info" in test-cases - after TAT-27401
    ...  - 23.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27803 -
	...  [CNI-127210] [Part 1] DSS LTE EXPECTED alarms check removal SBTS_* TCs
    ...  - 26.09.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28126 - [5G] CNI : 131510 - Classical - Part 1 - Graceful cell shutdown
    ...  - 01.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28134 - [5G] SBTS__STATE__RAT_Reset_from_WEBEM (soft) failed with
    ...  AdminApiProcedureTimeoutException
    ...  - 03.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29815 -
    ...  Unify alarm container names between all tests in order to use ${${alias.upper()}}_ALARMS_CNI_127210 ${${alias.upper()}}_ALARMS_NO_CNI_127210
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-21077_SBTS__STATE__RAT_Reset_from_WEBEM.png

    Set Tags    CA-STATE    OWNER-adrian.tanasescu@nokia.com    AUTHOR-horea.olar@nokia.com    PHASE-QT    SW-SBTS22R1

    TC Preconditions
    Step 1: Check initial BTS state
    Step 2: Check initial BTS alarms
    Step 3: Get initial baseband pool allocation mode info
    Step 4: Get Rat info
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 5: Perform RAT Reset on iteration ${INDEX}
        Step 6: Check final BTS state
        Step 7: Check final BTS alarms
        Step 8: Check BTS reset behavior based on IMS info
        Step 9: Check final number and state of Cells and RMs
    END

    [Teardown]  Particular Teardown

TC Preconditions
    ${actRatResetEnhancement}=  Get actRatResetEnhancement from SCF  alias=${alias_local}
    Set Test Variable  ${actRatResetEnhancement}

    Run Keyword If  '${RESET_TYPE}' == 'Soft' and '${actRatResetEnhancement}' != 'true'  Run Keywords
    ...  Log  Improper value for actRatResetEnhancement parameter!  level=ERROR
    ...  AND  Fail  actRatResetEnhancement parameter should be set on true for Soft reset type!

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

Step ${index}: Get Rat Info
    Log  Step ${index}: Get Rat Info  console=True
    ${Rat_list}=  Create List
    ${BTS_NR_CELL_list}=  Get Ids For All  class_name=NRCEL  connection=${alias_local}
    Run Keyword If  ${BTS_NR_CELL_list}
    ...  Append To List  ${Rat_list}  NR
    ${BTS_LTE_CELL_list}  ${BTS_LTE_CELL_IOT_list}=  Admin Get LTE CELL Ids list  ${alias_local}
    Run Keyword If  ${BTS_LTE_CELL_list}
    ...  Append To List  ${Rat_list}  LTE
    ${BTS_WCDMA_CELL_list}=  Get Ids For All  class_name=WNCEL  connection=${alias_local}
    Run Keyword If  ${BTS_WCDMA_CELL_list}
    ...  Append To List  ${Rat_list}  WCDMA
    ${BTS_GSM_CELL_list}=  Get Ids For All  class_name=GNCEL  connection=${alias_local}
    Run Keyword If  ${BTS_GSM_CELL_list}
    ...  Append To List  ${Rat_list}  GSM
    Set Test Variable  ${Rat_list}
    Log  RAT found: ${Rat_list}  console=True

    Check if DSS is configured

Step ${index}: Perform RAT Reset on iteration ${CYCLE}

    Run Keyword If  '${RAT_TECH}' == 'all'  Run Keywords
    ...  Log  Step ${index}: Perform Reset on all BTS RATs  console=True
    ...  AND  Perform Reset on all RAT  ${CYCLE}
    ...  ELSE  Run Keywords
    ...  Log  Step ${index}: Perform Reset on ${RAT_TECH} RAT  console=True
    ...  AND  Perform RAT Reset  ${RAT_TECH}  ${CYCLE}

Perform Reset on all RAT
    [Arguments]  ${CYCLE}
    FOR  ${item}  IN  @{Rat_list}
        Perform RAT Reset  ${item}  ${CYCLE}
    END

Perform RAT Reset
    [Arguments]  ${RAT_tech}  ${CYCLE}
    ${CELL_class_name}=  Set Variable If
    ...  '${RAT_tech}'=='NR'  NRCEL  '${RAT_tech}'=='LTE'  LNCEL  '${RAT_tech}'=='WCDMA'  WNCEL  '${RAT_tech}'=='GSM'  GNCEL
    Set Test Variable  ${CELL_state_disabled_check}
    ...  operationalState=${Disabled_}, availabilityStatus=${Failed_Offline_}, blockingState=${Unblocked_}
    Set Test Variable  ${CELL_state_disabled}  operationalState=Disabled, availabilityStatus=Failed|Offline, blockingState=Unblocked
    ${CELL_state_enabled_check}=  Set Variable  operationalState=${Enabled_}, blockingState=${Unblocked_}
    ${CELL_state_enabled}=  Set Variable  operationalState=Enabled, blockingState=Unblocked
    ${RMOD_state_enabled_check}=  Set Variable  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    ${RMOD_state_enabled}=  Set Variable  operationalState=Enabled, administrativeState=Unlocked
    ${new_alias_reset}=  Set Variable  resetRAT

    Get RAT reset impact  ${RAT_tech}
    Run Keyword If  ${DSS_configured} and '${RAT_tech}' in ['NR','LTE']  Get DSS impact  ${RAT_tech}

    Get Current Date UTC info  start_resetRAT
    Get Current Time  initial
    Start new ADMIN instance  alias=${alias_local}  new_alias=${new_alias_reset}  connection_type=${connection_type_${alias_local}}

    Log  Perform "Reset ${RAT_tech} RAT" operation from Admin  console=True

    ${reset_info_thread}=  RFS RAT Reset  rat_type=${RAT_tech}  timeout=${MAX_WAIT_TIME}  connection=${new_alias_reset}  alias=${alias_local}
    ...  graceful_cell_shutdown=${GRACEFUL_CELL_SHUTDOWN}  reset_type=${RESET_TYPE}

    Log  Check BTS state and alarms during ${RAT_tech} RAT reset:  console=True
    Check BTS state and alarms during RAT reset  ${RAT_tech}  ${CELL_class_name}

    ${reset_info_result}=  Collect Keyword Result  ${reset_info_thread}  timeout=${MAX_WAIT_TIME}

    Log  Check BTS state and alarms after ${RAT_tech} RAT reset:  console=True

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${MAX_WAIT_TIME}
    Assert Every  class_name=${CELL_class_name}  parameters=${CELL_state_enabled_check}  timeout=${remained_MAX_WAIT_TIME}  connection=${alias_local}
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${MAX_WAIT_TIME}
    Assert Every  class_name=RMOD  parameters=${RMOD_state_enabled_check}  timeout=${remained_MAX_WAIT_TIME}  connection=${alias_local}
    Log  All RMODs status:\n ${RMOD_state_enabled}  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${MAX_WAIT_TIME}
    Check cells availability status online  ${alias_local}  ${remained_MAX_WAIT_TIME}
    Log  All cells states:\n - ${CELL_state_enabled}  console=True

    Log  "Reset ${RAT_tech} RAT" operation successfully finished  console=True
    Get Current Date UTC info  end_resetRAT

    Get and check KPI from IMS file  ${RAT_tech}  ${CYCLE}

    [Teardown]  Teardown Admin  alias=${new_alias_reset}

Step ${index}: Check BTS reset behavior based on IMS info
    [Documentation]
    ...  Check BTS reset behavior based on IMS info. Reset behavior as expected if:
    ...  - reset number is 0
    ...  Otherwise, reset behavior not as expected, then errors are added to report and failed.

    Log  Step ${index}: Check BTS reset behavior based on IMS info  console=True
    Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=${alias_local}
    ...  start_point_timestamp_UTC=${date_timestamp_start_resetRAT_UTC}  end_point_timestamp_UTC=${date_timestamp_end_resetRAT_UTC}

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Check if DSS is configured
     Log  Check if DSS is configured on BTS  console=True
     ${BTS_XP_localAlias_remoteAlias_dict}  ${NRBTS_DSS_alias_actLteNrDss_dict}  ${LNBTS_DSS_alias_actLteNrDss_dict}
    ...  ${BTS_DSS_NR_LTE_CELL_scf_dict}  ${BTS_DSS_LTE_NR_CELL_scf_dict}  ${BTS_DSS_NR_LTE_CELL_dict}  ${BTS_DSS_LTE_NR_CELL_dict}=
    ...  Get all BTS DSS feature info
    Set Test Variable  ${BTS_DSS_NR_LTE_CELL_dict}
    Set Test Variable  ${BTS_DSS_LTE_NR_CELL_dict}

    ${BTS_actLteNrDss_NR}=  Get From Dictionary  ${NRBTS_DSS_alias_actLteNrDss_dict}  ${alias_local}
    ${BTS_actLteNrDss_LTE}=  Get From Dictionary  ${LNBTS_DSS_alias_actLteNrDss_dict}  ${alias_local}

    ${BTS_DSS_configured}=  Set Variable If  '${BTS_actLteNrDss_NR}' == 'True' and '${BTS_actLteNrDss_LTE}' == 'True'  True  False
    ${BTS_DSS}=  Get From Dictionary  ${BTS_XP_localAlias_remoteAlias_dict}  ${alias_local}

    ${BTS_DSS_status}=  Run Keyword And Return Status  Should Not Be Empty  ${BTS_DSS}
    Run Keyword If  ${BTS_DSS_configured} and ${BTS_DSS_status}
    ...  Set Test Variable  ${DSS_configured}  True
    ...  ELSE  Set Test Variable  ${DSS_configured}  False

    Run Keyword If  ${DSS_configured}
    ...  Log  DSS is configured on BTS. DSS alarms check will be performed!  console=True
    ...  ELSE  Log  DSS is not configured on BTS. DSS alarms check will be skipped!  console=True

Get RAT reset impact
    [Arguments]  ${RAT_tech}

    Return From Keyword If  '${actRatResetEnhancement}' == 'true' and '${RESET_TYPE}' == 'Soft'

    Get BTS RAT reset impact on FRONTHAUL modules and cells  ${RAT_tech}  ${alias_local}
    Log  Impacted FHS list by ${RAT_tech} RAT reset: \n ${${alias_local}_${RAT_tech}_RAT_reset_FHS_id_list}  console=True
    Log  Impacted RMOD list by ${RAT_tech} RAT reset: \n ${${alias_local}_${RAT_tech}_RAT_reset_RMOD_id_list}  console=True

Get DSS impact
    [Arguments]  ${RAT_tech}

    Run Keyword If  '${actRatResetEnhancement}' == 'true' and '${RESET_TYPE}' == 'Soft'
    ...  Get DSS alarms without LOKI impact  ${RAT_tech}

Get DSS alarms without LOKI impact
    [Arguments]  ${RAT_tech}

    ${DSS_NR_LTE_CELL_dict}=  Get From Dictionary  ${BTS_DSS_NR_LTE_CELL_dict}  ${alias_local}
    ${DSS_alarm_count}=  Get Length  ${DSS_NR_LTE_CELL_dict}

    ${EXPECTED_ALARMS_DSS}=  Run Keyword If  '${RAT_tech}' == 'LTE'
    ...  Prepare expected alarms list  ${${alias_local.upper()}_EXPECTED_ALARMS_NR_DSS}  ${DSS_alarm_count}

    Set Test Variable  ${DSS_alarm_count}
    Set Test Variable  ${EXPECTED_ALARMS_DSS}

Get BTS RAT reset impact on FRONTHAUL modules and cells
    [Arguments]  ${RAT_tech}  ${alias}

    ${RAT_reset_FHS_id_list}  ${RAT_reset_RMOD_id_list}  ${RAT_reset_NRCEL_id_list}  ${RAT_reset_LNCEL_id_list}  ${RAT_reset_WNCEL_id_list}
    ...  ${RAT_reset_GNCEL_id_list}=  Get RAT reset impact on FRONTHAUL modules and cells  ${RAT_tech}  ${alias}

    Set Test Variable  ${${alias}_${RAT_tech}_RAT_reset_FHS_id_list}  ${RAT_reset_FHS_id_list}
    Set Test Variable  ${${alias}_${RAT_tech}_RAT_reset_RMOD_id_list}  ${RAT_reset_RMOD_id_list}
    Set Test Variable  ${${alias}_${RAT_tech}_RAT_reset_NRCEL_id_list}  ${RAT_reset_NRCEL_id_list}
    Set Test Variable  ${${alias}_${RAT_tech}_RAT_reset_LNCEL_id_list}  ${RAT_reset_LNCEL_id_list}
    Set Test Variable  ${${alias}_${RAT_tech}_RAT_reset_WNCEL_id_list}  ${RAT_reset_WNCEL_id_list}
    Set Test Variable  ${${alias}_${RAT_tech}_RAT_reset_GNCEL_id_list}  ${RAT_reset_GNCEL_id_list}

Check BTS FRONTHAUL modules and cells status impacted by RAT reset
    [Arguments]  ${RAT_tech}  ${alias}
    ${MOD_state_disabled_check}=  Set Variable  operationalState=${Disabled_}, availabilityStatus=${NotInstalled_Offline_}
    ${MOD_state_disabled}=  Set Variable  operationalState=Disabled, availabilityStatus=NotInstalled|Offline

    Log  Check FRONTHAUL modules (FHS/RMOD) status impacted by ${RAT_tech} RAT reset:  console=True

    FOR  ${item}  IN  @{${alias}_${RAT_tech}_RAT_reset_FHS_id_list}
        Assert  class_name=FHS  id=${item}  parameters=${MOD_state_disabled_check}  timeout=180  connection=${alias}
        Log  FHS ${item} status:\n - ${MOD_state_disabled}  console=True
    END

    FOR  ${item}  IN  @{${alias}_${RAT_tech}_RAT_reset_RMOD_id_list}
        Assert  class_name=RMOD  id=${item}  parameters=${MOD_state_disabled_check}  timeout=180  connection=${alias}
        Log  RMOD ${item} status:\n - ${MOD_state_disabled}  console=True
    END

    Sleep  10s  reason=Avoid cell transitory states
    Log  Check other RAT cells status impacted by ${RAT_tech} RAT reset:  console=True

    Run Keyword If  ${${alias}_${RAT_tech}_RAT_reset_NRCEL_id_list} and '${RAT_tech}' != 'NR'
    ...  Check NR cells state and MIMO alarm  cell_list=${${alias}_${RAT_tech}_RAT_reset_NRCEL_id_list}  alias=${alias}

    Run Keyword If  ${${alias}_${RAT_tech}_RAT_reset_LNCEL_id_list} and '${RAT_tech}' != 'LTE'
    ...  Check LTE cells state and MIMO alarm  cell_list=${${alias}_${RAT_tech}_RAT_reset_LNCEL_id_list}  alias=${alias}

    Run Keyword If  ${${alias}_${RAT_tech}_RAT_reset_WNCEL_id_list} and '${RAT_tech}' != 'WCDMA'
    ...  Check WCDMA cells state and MIMO alarm  cell_list=${${alias}_${RAT_tech}_RAT_reset_WNCEL_id_list}  alias=${alias}

    Run Keyword If  ${${alias}_${RAT_tech}_RAT_reset_GNCEL_id_list} and '${RAT_tech}' != 'GSM'
    ...  Check GSM cells state and MIMO alarm  cell_list=${${alias}_${RAT_tech}_RAT_reset_GNCEL_id_list}  alias=${alias}

Check BTS state and alarms during RAT reset
    [Arguments]  ${RAT_tech}  ${CELL_class_name}

    Run Keyword If  '${actRatResetEnhancement}' == 'true' and '${RESET_TYPE}' == 'Soft'
    ...  Check BTS state and alarms without LOKI impact  ${RAT_tech}  ${CELL_class_name}
    ...  ELSE
    ...  Check BTS state and alarms with LOKI impact  ${RAT_tech}  ${CELL_class_name}

Check BTS state and alarms without LOKI impact
    [Arguments]  ${RAT_tech}  ${CELL_class_name}

    Log  Check ${RAT_tech} cells status:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${MAX_WAIT_TIME}
    Assert Every  class_name=${CELL_class_name}  parameters=${CELL_state_disabled_check}  timeout=${remained_MAX_WAIT_TIME}
    ...  connection=${alias_local}
    Log  ${RAT_tech} cells status:\n - ${CELL_state_disabled}  console=True

    Log  Check BTS alarms:  console=True
    ${EXPECTED_ALARMS}=  Create List
    ${EXPECTED_ALARMS_full}=  Set Variable If  ${DSS_configured} and '${RAT_tech}' in ['NR','LTE']  ${EXPECTED_ALARMS_DSS}  ${EXPECTED_ALARMS}
    ${IGNORED_ALARMS_full}=  Combine Lists  ${${alias_local.upper()}_IGNORED_ALARMS_DURING_RESET}  ${${alias_local.upper()}_IGNORED_ALARMS}

    Run Keyword If  ${DSS_configured} and '${RAT_tech}' == 'LTE'
    ...  Log Long String  NR RAT "EN DSS De-activated on partner side (7513)" or "EN DSS Keep Alive Procedure Time out (7511)", or
    ...  "EN DSS Setup Failure - Max EN DSS Counter Value reached - No answer from CRM (7509)" alarm,
    ...  expected number: ${DSS_alarm_count}  console=True

    Get and Check Alarms SOAM  alias=${alias_local}  expected_alarms=${EXPECTED_ALARMS_full}  poll_interval=10 sec
    ...  ignored_alarms=${IGNORED_ALARMS_full}  critical_alarms=${${alias_local.upper()}_CRITICAL_ALARMS}

    Run Keyword If  ${DSS_configured} and '${RAT_tech}' == 'LTE'
    ...  Log Long String  NR RAT "EN DSS De-activated on partner side (7513)" or "EN DSS Keep Alive Procedure Time out (7511)", or
    ...  "EN DSS Setup Failure - Max EN DSS Counter Value reached - No answer from CRM (7509)" alarm, found number: ${DSS_alarm_count},
    ...  as expected!  console=True

Check BTS state and alarms with LOKI impact
    [Arguments]  ${RAT_tech}  ${CELL_class_name}

    Log  Check ${RAT_tech} cells status:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${MAX_WAIT_TIME}
    Assert Every  class_name=${CELL_class_name}  parameters=${CELL_state_disabled_check}  timeout=${remained_MAX_WAIT_TIME}
    ...  connection=${alias_local}
    Log  ${RAT_tech} cells status:\n - ${CELL_state_disabled}  console=True

    Check BTS FRONTHAUL modules and cells status impacted by RAT reset  ${RAT_tech}  ${alias_local}

Get and check KPI from IMS file
    [Arguments]  ${RAT_tech}  ${CYCLE}

    ${RAT_kpi_name}=  Set Variable If
    ...  '${RAT_tech}'=='NR'  kpi10  '${RAT_tech}'=='LTE'  kpi7  '${RAT_tech}'=='WCDMA'  kpi8  '${RAT_tech}'=='GSM'  kpi9

    ${kpi_name_delta_dict}=  Get and check KPI info from IMS file  kpi_names=${RAT_kpi_name}  kpi_thresholds=${${RAT_tech}_RESET_WRN_THR}
    ...  alias=${alias_local}  start_point_timestamp_UTC=${date_timestamp_start_resetRAT_UTC}
    ...  end_point_timestamp_UTC=${date_timestamp_end_resetRAT_UTC}
    ${kpi_delta_list}=  Get From Dictionary  ${kpi_name_delta_dict}  ${RAT_kpi_name}

    Export KPI Results to File  alias=${alias_local}  obj_info=RAT  obj=BTS KPI measurement  obj_type=${RAT_tech}  obj_id=${alias_local}
    ...  action_1=RAT_Reset  kpi_reported_1=${RAT_kpi_name}  event_value_1=${kpi_delta_list[0]}  cycle=${CYCLE}  source_info=ims
    ...  add_info_label=RAT_Reset action  add_info_value=${alias_local}

Particular Teardown
    Export KPI results to File Global  kpi_log_file_name=KpiTimeInfo

TC Setup
    ${tech_preset_list}=  Create List  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
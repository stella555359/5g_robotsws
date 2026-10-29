*** Settings ***
Documentation    TC__SBTS__STATE__RAT_Block_Unblock_from_WEBEM
Variables    tc_variables/sbts__state__rat_block_unblock_from_webem_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}  3  # Number of Block/Unblock operations, default value 3
${RAT_TECH}           # RAT that needs to be blocked/unblocked. Possible values:
                      # - empty (all RATs will be blocked/unblocked one by one),
                      # - all ( all RATs will be blocked/unblocked at the same time)
                      # - particular RAT (ex: NR) or list of RATs seprated by comma (ex: NR, LTE, GSM)

*** Keywords ***
TC__SBTS__STATE__RAT_Block_Unblock_from_WEBEM
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-21834
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS test case for Individual RAT Block/Unblock from WEBEM, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial BTS state and alarms
    ...  - block unblock RAT as specified in ${RAT_TECH}
    ...  - check final BTS state and alarms
    ...  - check BTS reset behavior based on IMS info: reset number is 0
    ...  Pass criteria: BTS Commissioning successfully, states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 28.10.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-21834 - [5G] [RFSplit] RFS_SBTS_RF_Split_Individual_RAT_Block_Unblock_from_WebEM
    ...  - 23.02.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-22650 - [Cloud] [RFSplit] [Legacy] Particular teardown refactoring - SBTS part
    ...  - 22.03.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-22800
    ...  - [5G][RFSplit]SBTS__STATE__BBMOD_LockUnlock_from_WEBEM fails due to IOT cells
    ...  - 01.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23870 - [5G][TC review][RFSplit] Remove "regex" word from cell/RM/BBMode state
    ...  - 07.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23926 - [5G][CNI-82119] Implement new RAT check in RAT Block Unblock tests
    ...  - 09.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24193 - [5G][Reset Number ims2] Update SBTS STATE, FM
    ...  scenarios to take reset number from ims2 - P2
    ...  - 02.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26376 - [5G] SBTS__STATE__RAT_Block_Unblock_from_WEBEM test should be enhanced
    ...  to take into consideration DSS alarms
    ...  - 23.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26709 - [5G] Automated test of [1]SBTS__STATE__RAT_Block_Unblock_from_WEBEM can
    ...  not be done only for 2 technologies
    ...  - 14.05.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27410 - [5G] [Infomodel] - P1 - Eliminate usage of KW Infomodel "Get baseband
    ...  pool allocation mode info" in test-cases - after TAT-27401
    ...  - 23.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27803 -
	...  [CNI-127210] [Part 1] DSS LTE EXPECTED alarms check removal SBTS_* TCs
    ...  - 03.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29815 -
    ...  Unify alarm container names between all tests in order to use ${${alias.upper()}}_ALARMS_CNI_127210 ${${alias.upper()}}_ALARMS_NO_CNI_127210
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-21834_SBTS__STATE__RAT_Block_Unblock_from_WEBEM.png

    Set Tags    CA-CM    OWNER-adrian.tanasescu@nokia.com    AUTHOR-horea.olar@nokia.com    PHASE-QT    SW-SBTS22R1

    Step 1: Check initial BTS state
    Step 2: Check initial BTS alarms
    Step 3: Get initial baseband pool allocation mode info
    Step 4: Get Rat info
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 5: Perform RAT Block Unblock
        Step 6: Check final BTS state
        Step 7: Check final BTS alarms
        Step 8: Check BTS reset behavior based on IMS info
        Step 9: Check final number and state of Cells and RMs
    END

    [Teardown]  Particular Teardown

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
    Log  Step ${index}: Get RAT Info
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

    ${BTS_XP_localAlias_remoteAlias_dict}  ${NRBTS_DSS_alias_actLteNrDss_dict}  ${LNBTS_DSS_alias_actLteNrDss_dict}  ${BTS_DSS_NR_LTE_CELL_scf_dict}
    ...  ${BTS_DSS_LTE_NR_CELL_scf_dict}  ${BTS_DSS_NR_LTE_CELL_runtime_dict}  ${BTS_DSS_LTE_NR_CELL_runtime_dict}=  Get all BTS DSS feature info

    ${LNBTS_actLteNrDss}=  Get From Dictionary  ${LNBTS_DSS_alias_actLteNrDss_dict}  ${alias_local}
    Set Test Variable  ${LNBTS_actLteNrDss}
    Set Test Variable  ${BTS_DSS_NR_LTE_CELL_runtime_dict}
    Set Test Variable  ${BTS_DSS_LTE_NR_CELL_runtime_dict}
    Set Test Variable  ${DSS_alarm_count}  0

Step ${index}: Perform RAT Block Unblock
    ${techno_blocked_list}=  Create List
    Set Test Variable  ${techno_blocked_list}
    Run Keyword If  '${RAT_TECH}' == 'all'  Run Keywords
    ...  Log  Step ${index}: Perform Block/Unblock on all BTS RATs  console=True
    ...  AND  Block Unblock all Rat
    ...  ELSE IF  '${RAT_TECH}' == ''  Run Keywords
    ...  Log  Step ${index}: Perform Block/Unblock on all RAT one by one  console=True
    ...  AND  Block Unblock Rat one by one
    ...  ELSE  Run Keywords
    ...  Log  Step ${index}: Perform Block/Unblock on ${RAT_TECH} RAT  console=True
    ...  AND  Block Unblock RAT list  ${RAT_TECH}

Block Unblock all RAT
    Set Test Variable  ${alarm_4614_count}  0
    FOR  ${item}  IN  @{Rat_list}
        RAT Block  ${item}
    END
    FOR  ${item}  IN  @{Rat_list}
        Get Current Date UTC info  start
        RAT Unblock  ${item}
        Get Current Date UTC info  end
    END

Block Unblock Rat one by one
    FOR  ${item}  IN  @{Rat_list}
        Get Current Date UTC info  start
        RAT Block  ${item}
        RAT Unblock  ${item}
        Get Current Date UTC info  end
    END

Block Unblock RAT list
    [Arguments]  ${RAT_TECH}
    ${RAT_TECH_LIST_strip}=  Replace String  ${RAT_TECH}  ${SPACE}  ${EMPTY}
    ${RAT_TECH_LIST}=  Split String  ${RAT_TECH_LIST_strip}  ,
    FOR  ${item}  IN  @{RAT_TECH_LIST}
        RAT Block  ${item}
        RAT Unblock  ${item}
    END

RAT Block
    [Arguments]  ${techno}
    ${CELL_class_name}=  Set Variable If  '${techno}'=='NR'  NRCEL  '${techno}'=='LTE'  LNCEL  '${techno}'=='WCDMA'  WNCEL  '${techno}'=='GSM'  GNCEL
    ${CELL_state_disabled_check}=  Set Variable  operationalState=${Disabled_}, availabilityStatus=${Offline_}
    ${CELL_state_disabled}=  Set Variable  operationalState=Disabled, availabilityStatus=Offline

    Run Keyword If  '${RAT_TECH}' == 'all'  Append To List  ${techno_blocked_list}  ${techno}
    Set Test Variable  ${techno_blocked_list}

    Run Keyword If  ${LNBTS_actLteNrDss} and '${techno}' in ['NR','LTE']  Get DSS alarms  ${techno}

    ${alarm_4614_count}=  Run Keyword If  '${RAT_TECH}' != 'all'  Evaluate  1
    ...  ELSE  Evaluate  ${alarm_4614_count} + 1
    Set Test Variable  ${alarm_4614_count}
    ${SBTS_EXPECTED_ALARMS_4614}=  Prepare expected alarms list  ${${alias_local.upper()}_EXPECTED_ALARMS_4614}  ${alarm_4614_count}
    ${SBTS_EXPECTED_ALARMS_FULL}=  Run Keyword If  ${LNBTS_actLteNrDss} and '${techno}' in ['NR','LTE']
    ...  Combine Lists  ${DSS_EXPECTED_ALARMS}  ${SBTS_EXPECTED_ALARMS_4614}
    ...  ELSE  Set Variable  ${SBTS_EXPECTED_ALARMS_4614}
    ${SBTS_IGNORED_ALARMS_FULL}=  Combine Lists  ${${alias_local.upper()}_IGNORED_ALARMS}  ${${alias_local.upper()}_IGNORED_ALARMS_X2}
    ...  ${${alias_local.upper()}_LTE_DSS_IGNORED_DURING_BLOCK_ALARMS}
    coam.Block Rat  rat=${techno}  timeout=180  connection=${alias_local}
    Log  Checking ${techno} cells states after ${techno} RAT Block  console=True
    Assert Every  class_name=${CELL_class_name}  parameters=${CELL_state_disabled_check}  timeout=180  connection=${alias_local}
    Log  ${techno} cells: ${CELL_state_disabled}  console=True
    Log  Checking alarms after ${techno} RAT Block  console=True
    Log  "RAT blocked"(FID 4614) alarm, expected: ${alarm_4614_count}  console=True
    Run Keyword If  ${LNBTS_actLteNrDss} and '${techno}' == 'LTE'
    ...  Run Keyword If  ${DSS_alarm_count} > 0
    ...  Log Long String  NR RAT "EN DSS De-activated on partner side (7513)" or "EN DSS Keep Alive Procedure Time out (7511)" alarm, or
    ...  "EN DSS Setup Failure - Max EN DSS Counter Value reached - No answer from CRM (7509)" alarm,, expected number: ${DSS_alarm_count}
    ...  console=True

    Get and Check Alarms SOAM  alias=${alias_local}  expected_alarms=${SBTS_EXPECTED_ALARMS_FULL}  ignored_alarms=${SBTS_IGNORED_ALARMS_FULL}
    ...  critical_alarms=${${alias_local.upper()}_CRITICAL_ALARMS}

    Log  "RAT blocked"(FID 4614) alarm, found: ${alarm_4614_count}  console=True

    Run Keyword If  ${LNBTS_actLteNrDss} and '${techno}' == 'LTE'
    ...  Run Keyword If  ${DSS_alarm_count} > 0
    ...  Log Long String  NR RAT "EN DSS De-activated on partner side (7513)" or "EN DSS Keep Alive Procedure Time out (7511)" alarm, or
    ...  "EN DSS Setup Failure - Max EN DSS Counter Value reached - No answer from CRM (7509)" alarm,, found number: ${DSS_alarm_count}
    ...  console=True

RAT Unblock
    [Arguments]  ${techno}
    ${CELL_class_name}=  Set Variable If  '${techno}'=='NR'  NRCEL  '${techno}'=='LTE'  LNCEL  '${techno}'=='WCDMA'  WNCEL  '${techno}'=='GSM'  GNCEL
    ${CELL_state_enabled_check}=  Set Variable  operationalState=${Enabled_}
    ${CELL_state_enabled}=  Set Variable  operationalState=Enabled
    ${alarm_4614_count}=  Run Keyword If  '${RAT_TECH}' != 'all'  Evaluate  0
    ...  ELSE  Evaluate  ${alarm_4614_count} - 1
    Set Test Variable  ${alarm_4614_count}
    ${SBTS_EXPECTED_ALARMS_FULL}=  Prepare expected alarms list  ${${alias_local.upper()}_EXPECTED_ALARMS_4614}  ${alarm_4614_count}
    Get Current Date UTC info  start
    coam.Unblock Rat  rat=${techno}  timeout=180  connection=${alias_local}
    Log  Checking ${techno} cells states after ${techno} RAT Unblock  console=True
    Assert Every  class_name=${CELL_class_name}  parameters=${CELL_state_enabled_check}  timeout=180  connection=${alias_local}
    Log  ${techno} cells: ${CELL_state_enabled}  console=True
    Log  Checking alarms after ${techno} RAT Unblock  console=True
    Log  "RAT blocked"(FID 4614) alarm, expected: ${alarm_4614_count}  console=True
    Get and Check Alarms SOAM  alias=${alias_local}  expected_alarms=${SBTS_EXPECTED_ALARMS_FULL}
    ...  ignored_alarms=${${alias_local.upper()}_IGNORED_ALARMS}  critical_alarms=${${alias_local.upper()}_CRITICAL_ALARMS}
    Log  "RAT blocked"(FID 4614) alarm, found: ${alarm_4614_count}  console=True
    Get Current Date UTC info  end

Get DSS alarms
   [Arguments]  ${techno}

    ${peer_techno}=  Set Variable If  '${techno}' == 'NR'  LTE  NR
    ${DSS_dict}=  Create Dictionary
    ${DSS_dict}=  Set Variable If  '${techno}' == 'NR'  ${BTS_DSS_NR_LTE_CELL_runtime_dict}  '${techno}' =='LTE'
    ...  ${BTS_DSS_LTE_NR_CELL_runtime_dict}  ${DSS_dict}
    ${DSS_dict}=  Run Keyword If  ${DSS_dict}  Get From Dictionary  ${DSS_dict}  ${alias_local}  ELSE  Set Variable  ${DSS_dict}
    ${DSS_alarm_count}=  Run Keyword If  '${peer_techno}' not in @{techno_blocked_list}  Get Length  ${DSS_dict}
    ...  ELSE  Set Variable  0
    ${DSS_EXPECTED_ALARMS}=  Prepare expected alarms list  ${${alias_local.upper()}_${peer_techno}_DSS_EXPECTED_ALARMS}  ${DSS_alarm_count}
    Set Test Variable  ${DSS_alarm_count}
    Set Test Variable  ${DSS_EXPECTED_ALARMS}

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

Particular Teardown
    Run Keyword And Continue On Failure  Check if RAT is unblocked  ${alias_local}

TC Setup
    ${tech_preset_list}=  Create List  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown

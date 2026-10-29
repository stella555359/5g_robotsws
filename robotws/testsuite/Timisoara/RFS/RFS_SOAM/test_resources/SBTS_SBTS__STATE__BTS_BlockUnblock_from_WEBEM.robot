*** Settings ***
Documentation    TC__SBTS_SBTS__STATE__BTS_BlockUnblock_from_WEBEM
Variables    tc_variables/sbts_sbts__state__bts_blockunblock_from_webem_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}              3     # Number of Block/Unblock Site operations on BTS, by default 3
${BTS_LIST}                    ALL   # BTS list on which Block/Unblock Site operations will be performed. Possible values (by default ALL):
                                     # - ALL: action will be performed on all BTS (Block/Unblock Site on each BTS until last BTS from TL)
                                     # - list of selected BTS separated by comma labeled as BTSx (x is test_pc number in init.py) (ex. BTS1, BTS2)
${BTS_PRIMARY_LINK_LIST}             # BTS for primary link set before Block/Unblock Site operation. Possible values (by default empty):
                                     # - empty (no set required) -> Block/Unblock Site operations on BTS from ${BTS_LIST} will be performed with
                                     # existing BTS primary link settings
                                     # - single BTS value labeled as BTSx (x is test_pc number in init.py) -> Block/Unblock Site operations on each
                                     # BTS from ${BTS_LIST} will be performed with BTSx value set as primary link (ex. BTS2 means that BTS2 set
                                     # is required before Block/Unblock Site on each BTS from ${BTS_LIST})
                                     # - list of BTS values separated by comma labeled as BTSx (x is test_pc number in init.py) -> Block/Unblock Site
                                     # operations on each BTS from ${BTS_LIST} will be performed with specific BTSx value set as primary link; in
                                     # this case, number of BTS values for primary link settings should be equal with number of BTS on which
                                     # Block/Unblock Site operations will be performed (ex. BTS2, BTS1 means: BTS2 set required before first BTS
                                     # operations, BTS1 set required before second BTS operations)
${SET_PRIMARY_LINK_TIME}       720   # Maximum time in seconds to wait for Primary Link set on ${BTS_PRIMARY_LINK}, default value: 720
${SET_PRIMARY_LINK_PROCEDURE}  LANE  # Procedure for setting BTS_PRIMARY_LINK, possible values: BTS (BTS Reset), LANE (Lock Unlock SFP LANE)
${BTS_RESET_WRN_THR_LIST}      600   # Time (secs) spent between first cell down to last cell up due to unblock BTS: in accordance with KPI1a
                                     # specifications. Possible values (by default 600 secs):
                                     # - single KPI value -> it will be used as KPI1a value for each BTS from ${BTS_LIST}
                                     # - list of KPI values separated by comma -> in this case, number of KPI values should be equal with number of
                                     # BTS on which Block/Unblock Site operations will be performed (ex. 600, 800 means: 600 secs as KPI1a for first
                                     # BTS, 800 secs as KPI1a for second BTS)
${BTS_MAX_WAIT_TIME}           900   # Maximum time to wait for BTS Block/Unblock Site operations checks completed, by default 900

*** Keywords ***
TC__SBTS_SBTS__STATE__BTS_BlockUnblock_from_WEBEM
     [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-23090
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS test case for BTS Block/Unblock Site, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for both BTS
    ...  - get and set if needed shared RMOD primary link info before Block/Unblock Site operation
    ...  - perform Block Site operation on BTS checking states and alarms on both BTS
    ...  - perform Unblock Site operation on BTS checking states and alarms on both BTS
    ...  - check reset behavior on both BTS based on initial and final RESET info as follows:
    ...    - BTS: reset number is 1
    ...    - peer BTS: reset number is 0
    ...  - check final state and alarms for both BTS
    ...  Pass criteria: BTS Block/Unblock operations works as expected, states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 20.05.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23090 - [5G][CB007636] New SBTS_SBTS scenario_RFS_SBTS_Block_Unblock_from_WebEM
    ...  - 05.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23480 - [5G][Legacy] Eliminate IM_IP_ADDRESS variable usage in TCs
    ...  - 19.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24216 - [5G][refactoring] Add generalized implementation of
    ...  "Open new admin session" in TCs: SBTS_SBTS
    ...  - 17.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24729 -
    ...  [5G][CRT][SBTS-SBTS]Ignore FID7107, FID7114 in SBTS_SBTS TCs, where there are alarm checks made, while one BTS is failed
    ...  - 22.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24195 - [5G][Reset Number ims2] Update SBTS-SBTS CM, STATE, FM
    ...  scenarios to take reset number from ims2 - P2
    ...  - 12.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25472 - [5G][CB008129] SBTS_SBTS__STATE__BTS1_BTS2_BlockUnblock_from_WEBEM
    ...  handling of non-primary link eCPRI RF state
    ...  - 11.08.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25853 - [5G][CB009569] Add checks regarding DSS alarms -
    ...  SBTS_SBTS__STATE__BTS1_BTS2_BlockUnblock_from_WEBEM
    ...  - 31.07.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25484 -
    ...  [5G][CB008378] Resolve CB007437 impact on Automated_RFS_SBTS_SBTS__STATE__BTS1_BTS2_BlockUnblock
    ...  - 01.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26056 - [5G] SBTS_SBTS__STATE__BTS1_BTS2_BlockUnblock_from_WEBEM fails with
    ...  Variable '${FID6134_alarm_count}' not found
    ...  - 18.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26133 - [5G] New expected state after NR BTS block for
    ...  NR_SBTS__STATE__NR_BTS_BlockUnblock_from_WEBEM
    ...  - 15.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26369 -  [5G][CB009210] Update SBTS_SBTS__STATE__BTS1_BTS2_BlockUnblock_from_WEBEM
    ...  with MHA checks
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26705 - [5G][CB007329] " SBTS__STATE__Baseband_module_LockUnlock
    ...  " is failed with "Critical alarms present and/or missing expected alarms!"
    ...  -29.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27008 - [5G][DSS alarms]Add wait_for_alarm_clear
    ...  because DSS alarms are not cleared in current timer
    ...  - 02.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27183 - [5G] Increase kpi from bts_block_unblock
    ...  - 23.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27803 -
	...  [CNI-127210] [Part 1] DSS LTE EXPECTED alarms check removal SBTS_* TCs
    ...  - 17.09.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28021 - [5G] [Infomodel] Infomodel refactor in
    ...  SBTS_SBTS__STATE__BTS1_BTS2_BlockUnblock_from_WEBEM - after TAT-27963
    ...  - 04.12.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28094 -
    ...  [REFACTORING][GENERIC_TC] NRL &NR_SBTS BTS BlockUnblock to SBTS_SBTS_BTS1_BTS2_BlockUnblock_from_WEBEM
    ...  - 16.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29418 -
    ...  Enhancement to NRL__STATE__LTE_BTS_BlockUnblock_from_WEBEM to support CB07447
    ...  - 27.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30221 - Remove ${actForceUnitAutoReset}' in tests and KWs related to CB007447
    ...

    Set Tags    CA-STATE    OWNER-razvan.roman@nokia.com    AUTHOR-anca.tatar@nokia.com    PHASE-QT

    TC Preconditions
    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Get all BTS info
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 4: Perform Block/Unblock Site on BTS for iteration ${INDEX}
        Step 5: Check final all BTS state
        Step 6: Check final all BTS alarms
        Step 7: Check final number and state of Cells and RMs
    END

    [Teardown]  Particular Teardown

TC Preconditions
    ${BTS_alias_label_dict}  ${BTS_label_alias_dict}=  Get BTS alias label info dict
    Set Test Variable  ${BTS_alias_label_dict}
    Set Test Variable  ${BTS_label_alias_dict}
    ${BTS_alias_list}=  Get Dictionary Keys  ${BTS_alias_label_dict}  False
    ${BTS_label_list}=  Get Dictionary Values  ${BTS_alias_label_dict}  False
    Set Test Variable  ${BTS_alias_list}
    Set Test Variable  ${BTS_label_list}

    Run Keyword If  '${BTS_LIST}' != 'ALL'  Check BTS list  ${BTS_label_alias_dict}  ${BTS_label_list}
    Log  =========================================================  console=True
    Log  BTS label list selected for Block/Unblock Cell operation: ${BTS_label_list}  console=True
    Log  BTS alias list selected for Block/Unblock Cell operation: ${BTS_alias_list}  console=True
    Log  =========================================================  console=True

    Run Keyword If  '${BTS_PRIMARY_LINK_LIST}' != ''  Check BTS Primary Link list

    Check BTS KPI1a values

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

        Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${test_alarms_list['${alias.upper()}_IGNORED_ALARMS']}
        ...  critical_alarms=${test_alarms_list['${alias.upper()}_CRITICAL_ALARMS']}

        Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

    END

Step ${index}: Get all BTS info
    Log  Step ${index}: Get all BTS info  console=True

    FOR  ${alias}  IN  @{alias_list}

       Get BTS CELL list by RAT  ${alias}

    END

    Check CB007447 feature settings

    ${BTS_XP_localAlias_remoteAlias_dict}  ${NRBTS_DSS_alias_actLteNrDss_dict}  ${LNBTS_DSS_alias_actLteNrDss_dict}
    ...  ${BTS_DSS_NR_LTE_CELL_scf_dict}  ${BTS_DSS_LTE_NR_CELL_scf_dict}  ${BTS_DSS_NR_LTE_CELL_dict}  ${BTS_DSS_LTE_NR_CELL_dict}=
    ...  Get all BTS DSS feature info
    Set Test Variable  ${BTS_XP_localAlias_remoteAlias_dict}
    Set Test Variable  ${NRBTS_DSS_alias_actLteNrDss_dict}
    Set Test Variable  ${LNBTS_DSS_alias_actLteNrDss_dict}
    Set Test Variable  ${BTS_DSS_NR_LTE_CELL_dict}
    Set Test Variable  ${BTS_DSS_LTE_NR_CELL_dict}

    ${NR_DSS_alarms_info}=  Create Long String  "EN DSS De-activated on partner side (7513)" or "EN DSS Keep Alive Procedure Time out (7511)" or
    ...  "EN DSS Setup Failure - Max EN DSS Counter Value reached - No answer from CRM (7509)" alarm alarm
    ${LTE_DSS_alarms_info}=  Create Long String  "EN DSS De-activated on partner side (6134)" or "EN DSS Keep Alive Procedure Time out (6132)" or
    ...  "EN DSS Setup Failure - Max EN DSS Counter Value reached - No DSS Partner Cell (6129)" alarm

    Set Test Variable  ${NR_DSS_alarms_info}
    Set Test Variable  ${LTE_DSS_alarms_info}

    Set Test Variable  ${RMOD_state_enabled_check}  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    Set Test Variable  ${RMOD_state_enabled}  operationalState=Enabled, administrativeState=Unlocked
    Set Test Variable  ${CELL_state_blocked_check}  operationalState=${Disabled_}, availabilityStatus=${Offline_}, blockingState=${Blocked_}
    Set Test Variable  ${CELL_state_blocked}  operationalState=Disabled, availabilityStatus=Offline, blockingState=Blocked
    Set Test Variable  ${CELL_state_enabled}  operationalState=Enabled, blockingState=Unblocked

Step ${index}: Perform Block/Unblock Site on BTS for iteration ${CYCLE}
    [Documentation]
    ...  Perform Block/Unblock Site on BTS

    Log  Step ${index}: Perform Block/Unblock Site on BTS for iteration ${CYCLE}  console=True

    Set Test Variable  ${CYCLE}

    FOR  ${alias}  IN  @{BTS_alias_list}

        Set shared RMOD Primary Link before Block/Unblock Site on BTS  ${alias}

        Perform Block Site on BTS  ${alias}

        Perform Unblock Site on BTS  ${alias}

        Check all BTS reset behavior based on IMS info  ${alias}

        Get and check KPI1a info from IMS file  ${alias}

    END

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Check BTS list
    [Arguments]  ${BTS_label_alias_dict}  ${BTS_label_list}

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

Check BTS Primary Link list
    ${BTS_PRIMARY_LINK_LIST_strip}=  Replace String  ${BTS_PRIMARY_LINK_LIST}  ${SPACE}  ${EMPTY}
    ${BTS_PL_LIST}=  Split String  ${BTS_PRIMARY_LINK_LIST_strip}  ,
    ${BTS_PL_check}=  Set Variable  True
    ${BTS_PL_invalid_label_list}=  Create List
    ${BTS_PL_request_label_list}=  Create List
    ${BTS_PL_request_alias_list}=  Create List

    ${label_list}=  Get Dictionary Values  ${BTS_alias_label_dict}  False

    FOR  ${item}  IN  @{BTS_PL_LIST}

        ${BTS_PL_check}=  Set Variable If  '${item}' not in ${label_list}  False  ${BTS_PL_check}

        Run Keyword If  '${item}' not in ${label_list}
        ...  Append To List  ${BTS_PL_invalid_label_list}  ${item}
        ...  ELSE
        ...  Append To List  ${BTS_PL_request_label_list}  ${item}

    END

    Run Keyword If  '${BTS_PL_check}' == 'False'  Run Keywords
    ...  Log Long String  Following selected BTS are not valid: ${BTS_PL_invalid_label_list}. Please select values for test argument
    ...  \${BTS_PRIMARY_LINK_LIST} from configured BTS: ${label_list} or let default value (empty)   console=True
    ...  AND  Fail  Improper value for argument!

    ${BTS_PL_LIST_length}=  Get Length  ${BTS_PL_LIST}

    Run Keyword If  ${BTS_PL_LIST_length} == 1  Run Keywords
    ...  Create BTS Primary Link info dict  ${BTS_alias_list}  ${BTS_PL_LIST}
    ...  AND  Return From Keyword

    ${BTS_LIST_length}=  Get Length  ${BTS_alias_list}

    Run Keyword If  ${BTS_PL_LIST_length} != ${BTS_LIST_length}  Run Keywords
    ...  Log Long String  Number of BTS for primary link set for test argument \${BTS_PRIMARY_LINK_LIST} is not aligned with number of selected BTS
    ...  for Block/Unblock operations. Please align values for \${BTS_PRIMARY_LINK_LIST} according to argument description!  level=ERROR
    ...  AND  Fail  Improper value for argument!

    Create BTS Primary Link info dict  ${BTS_alias_list}  ${BTS_PL_LIST}

Create BTS Primary Link info dict
    [Arguments]  ${BTS_alias_list}  ${BTS_PL_LIST}

    ${BTS_alias_BTS_PL_label_dict}=  Create Dictionary
    ${BTS_PL_LIST_length}=  Get Length  ${BTS_PL_LIST}

    FOR  ${index}  ${alias}  IN ENUMERATE  @{BTS_alias_list}

        ${BTS_PL_label}=  Run Keyword If  ${BTS_PL_LIST_length} == 1
        ...  Get From List  ${BTS_PL_LIST}  0
        ...  ELSE
        ...  Get From List  ${BTS_PL_LIST}  ${index}

        Set To Dictionary  ${BTS_alias_BTS_PL_label_dict}  ${alias}  ${BTS_PL_label}

    END

    Set Test Variable  ${BTS_alias_BTS_PL_label_dict}

Check BTS KPI1a values
    ${BTS_RESET_WRN_THR_LIST_strip}=  Replace String  ${BTS_RESET_WRN_THR_LIST}  ${SPACE}  ${EMPTY}
    ${BTS_KPI_LIST}=  Split String  ${BTS_RESET_WRN_THR_LIST_strip}  ,
    ${BTS_KPI_LIST_length}=  Get Length  ${BTS_KPI_LIST}

    Run Keyword If  ${BTS_KPI_LIST_length} == 1  Run Keywords
    ...  Create BTS KPI info dict  ${BTS_alias_list}  ${BTS_KPI_LIST}
    ...  AND  Return From Keyword

    ${BTS_LIST_length}=  Get Length  ${BTS_alias_list}

    Run Keyword If  ${BTS_KPI_LIST_length} != ${BTS_LIST_length}  Run Keywords
    ...  Log Long String  Number of KPI values set for test argument \${BTS_RESET_WRN_THR_LIST} is not aligned with number of selected BTS for
    ...  Block/Unblock operations. Please align values for \${BTS_RESET_WRN_THR_LIST} according to \${BTS_LIST} info or let default value!
    ...  level=ERROR
    ...  AND  Fail  Improper value for argument!

    Create BTS KPI info dict  ${BTS_alias_list}  ${BTS_KPI_LIST}

Create BTS KPI info dict
    [Arguments]  ${BTS_alias_list}  ${BTS_KPI_LIST}

    ${BTS_alias_BTS_KPI_dict}=  Create Dictionary
    ${BTS_KPI_LIST_length}=  Get Length  ${BTS_KPI_LIST}

    FOR  ${index}  ${alias}  IN ENUMERATE  @{BTS_alias_list}

        ${BTS_KPI}=  Run Keyword If  ${BTS_KPI_LIST_length} == 1
        ...  Get From List  ${BTS_KPI_LIST}  0
        ...  ELSE
        ...  Get From List  ${BTS_KPI_LIST}  ${index}

        Set To Dictionary  ${BTS_alias_BTS_KPI_dict}  ${alias}  ${BTS_KPI}

    END

    Set Test Variable  ${BTS_alias_BTS_KPI_dict}

Get BTS CELL list by RAT
    [Arguments]  ${alias}

    ${NR_CELL_id_list}=  Get Ids For All  class_name=NRCEL  connection=${alias}
    ${LTE_CELL_id_list}=  Get Ids For All  class_name=LNCEL  connection=${alias}
    ${WCDMA_CELL_id_list}=  Get Ids For All  class_name=WNCEL  connection=${alias}
    ${GSM_CELL_id_list}=  Get Ids For All  class_name=GNCEL  connection=${alias}
    ${BTS_CELL_id_list}=  Combine Lists   ${NR_CELL_id_list}  ${LTE_CELL_id_list}  ${WCDMA_CELL_id_list}  ${GSM_CELL_id_list}

    Set Test Variable  ${${alias}_NR_CELL_id_list}  ${NR_CELL_id_list}
    Set Test Variable  ${${alias}_LTE_CELL_id_list}  ${LTE_CELL_id_list}
    Set Test Variable  ${${alias}_WCDMA_CELL_id_list}  ${WCDMA_CELL_id_list}
    Set Test Variable  ${${alias}_GSM_CELL_id_list}  ${GSM_CELL_id_list}
    Set Test Variable  ${${alias}_BTS_CELL_id_list}  ${BTS_CELL_id_list}

Check CB007447 feature settings

    FOR  ${alias}  IN  @{alias_list}

        ${actCpriLinkRecovery}  ${actSyncLinkSwitchover}  ${cpriSyncBreakTime}  ${stickToSyncSourcePeriod}=  Get feature CB007447 info  ${alias}

        Run Keyword If  '${actCpriLinkRecovery}' == 'true' and '${actSyncLinkSwitchover}' == 'true'  Run Keywords
        ...  Log  BTS ${alias} CB007447 feature status: Enabled  console=True
        ...  AND  Set Test Variable  ${${alias}_CB007447_status}  ${TRUE}
        ...  ELSE  Run Keywords
        ...  Log  BTS ${alias} CB007447 feature status: Disabled  console=True
        ...  AND  Set Test Variable  ${${alias}_CB007447_status}  ${FALSE}

    END

Set shared RMOD Primary Link before Block/Unblock Site on BTS
    [Arguments]  ${alias}

    Log  Set shared RMOD Primary Link before Block/Unblock Site on BTS ${alias}  console=True

    Run Keyword If  '${BTS_PRIMARY_LINK_LIST}' == ''  Run Keywords
    ...  Log  - test action will be performed with existing shared RMODs Primary Link configuration   console=True
    ...  AND  Return From Keyword

    ${BTS_PL_label}=  Get From Dictionary  ${BTS_alias_BTS_PL_label_dict}  ${alias}
    ${BTS_PL_alias}=  Get From Dictionary  ${BTS_label_alias_dict}  ${BTS_PL_label}
    Log  - test action will be performed with shared RMODs Primary Link set on ${BTS_PL_label}  console=True
    Set Primary Link status based on linkModeSynchronization  module_type=RMOD  procedure_for_Primary_Link_set=${SET_PRIMARY_LINK_PROCEDURE}
    ...  alias=${BTS_PL_alias}  wait_for_Primary_Link_set=${SET_PRIMARY_LINK_TIME}

Perform Block Site on BTS
    [Arguments]  ${alias}

    ${peer_alias}=  Set Variable If  '${alias}' == 'Master'  Slave  Master
    Get DSS feature impact on all BTS  ${alias}

    Log  ***** Perform "Block Site" operation on BTS ${alias} *****  console=True
    Get Current Date UTC info  start
    Get Current Time  bts_block
    coam.Block  timeout=${BTS_MAX_WAIT_TIME}  alias=${alias}

    Check BTS states and alarms after Block Site operation on BTS  ${alias}

    Check peer BTS states and alarms after Block Site operation on BTS  ${alias}  ${peer_alias}

Perform Unblock Site on BTS
    [Arguments]  ${alias}

    ${peer_alias}=  Set Variable If  '${alias}' == 'Master'  Slave  Master
    ${hostname_ip}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_TECH_IP_ADDRESS]
    ${remote_host_ip}=  Set Variable If  '${alias}' == 'Master'  None  ${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]

    Log  ***** Perform "Unblock Site" operation on BTS ${alias} *****  console=True

    Count peer BTS expected alarms related to shared RMOD primary link info  ${peer_alias}

    Get Current Time  bts_unblock
    coam.Unblock  timeout=${BTS_MAX_WAIT_TIME}  alias=${alias}  wait_for_reconnection=False

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_bts_unblock}  ${BTS_MAX_WAIT_TIME}
    Wait For Target To Be Not Reachable TAF  hostname=${hostname_ip}  remote_host=${remote_host_ip}  timeout=${remained_MAX_WAIT_TIME}

    Check peer BTS alarms during Unblock Site operation on BTS  ${alias}  ${peer_alias}

    Check BTS states and alarms after Unblock Site operation on BTS  ${alias}

    Check peer BTS states and alarms after Unblock Site operation on BTS  ${alias}  ${peer_alias}

    Get Current Date UTC info  end

Get DSS feature impact on all BTS
    [Arguments]  ${alias}

    ${BTS_alias_NR_DSS_alarms_dict}=  Create Dictionary
    ${BTS_alias_LTE_DSS_alarms_dict}=  Create Dictionary
    ${LTE_DSS_alarms_count}=  Set Variable  0
    ${NR_DSS_alarms_count}=  Set Variable  0

    FOR  ${cell_id}  IN  @{${alias}_NR_CELL_id_list}

        ${DSS_peer_cell_id}  ${DSS_peer_rat}  ${DSS_peer_alias}=  Get DSS feature impact  ${cell_id}  NR  ${alias}

        ${LTE_DSS_alarms_count}=  Run Keyword If  '${DSS_peer_cell_id}' != 'None' and '${DSS_peer_alias}' not in ['${alias}', 'None']
        ...  Evaluate  ${LTE_DSS_alarms_count} + 1
        ...  ELSE
        ...  Set Variable  ${LTE_DSS_alarms_count}

        Run Keyword If  '${DSS_peer_cell_id}' != 'None' and '${DSS_peer_alias}' not in ['${alias}', 'None']
        ...  Set To Dictionary  ${BTS_alias_LTE_DSS_alarms_dict}  ${DSS_peer_alias}=${LTE_DSS_alarms_count}

    END

    FOR  ${cell_id}  IN  @{${alias}_LTE_CELL_id_list}

        ${DSS_peer_cell_id}  ${DSS_peer_rat}  ${DSS_peer_alias}=  Get DSS feature impact  ${cell_id}  LTE  ${alias}

        ${NR_DSS_alarms_count}=  Run Keyword If  '${DSS_peer_cell_id}' != 'None' and '${DSS_peer_alias}' not in ['${alias}', 'None']
        ...  Evaluate  ${NR_DSS_alarms_count} + 1
        ...  ELSE
        ...  Set Variable  ${NR_DSS_alarms_count}

        Run Keyword If  '${DSS_peer_cell_id}' != 'None' and '${DSS_peer_alias}' not in ['${alias}', 'None']
        ...  Set To Dictionary  ${BTS_alias_NR_DSS_alarms_dict}  ${DSS_peer_alias}=${NR_DSS_alarms_count}

    END

    Set Test Variable  ${BTS_alias_NR_DSS_alarms_dict}
    Set Test Variable  ${BTS_alias_LTE_DSS_alarms_dict}

Get DSS feature impact
    [Arguments]  ${cell_id}  ${rat}  ${alias}

    ${DSS_peer_rat}=  Set Variable If  '${rat}' == 'NR'  LTE  NR

    ${actLteNrDss}=  Run Keyword If  '${rat}' == 'NR'
    ...  Get From Dictionary  ${NRBTS_DSS_alias_actLteNrDss_dict}  ${alias}
    ...  ELSE IF  '${rat}' == 'LTE'
    ...  Get From Dictionary  ${LNBTS_DSS_alias_actLteNrDss_dict}  ${alias}

    Return From Keyword If  '${actLteNrDss}' == 'False'  None  ${DSS_peer_rat}  None

    ${DSS_NR_LTE_CELL_dict}=  Get From Dictionary  ${BTS_DSS_NR_LTE_CELL_dict}  ${alias}
    ${DSS_LTE_NR_CELL_dict}=  Get From Dictionary  ${BTS_DSS_LTE_NR_CELL_dict}  ${alias}
    ${DSS_NR_LTE_dict_keys}=  Get Dictionary Keys  ${DSS_NR_LTE_CELL_dict}
    ${DSS_LTE_NR_dict_keys}=  Get Dictionary Keys  ${DSS_LTE_NR_CELL_dict}

    ${DSS_peer_cell_id}=  Run Keyword If  '${rat}' == 'NR' and '${cell_id}' in ${DSS_NR_LTE_dict_keys}
    ...  Get From Dictionary  ${DSS_NR_LTE_CELL_dict}  ${cell_id}
    ...  ELSE IF  '${rat}' == 'LTE' and '${cell_id}' in ${DSS_LTE_NR_dict_keys}
    ...  Get From Dictionary  ${DSS_LTE_NR_CELL_dict}  ${cell_id}
    ...  ELSE
    ...  Set Variable  None

    Return From Keyword If  '${DSS_peer_cell_id}' == 'None'  None  ${DSS_peer_rat}  None

    ${DSS_peer_alias_list}=  Get From Dictionary  ${BTS_XP_localAlias_remoteAlias_dict}  ${alias}
    ${DSS_peer_alias}=  Get DSS peer BTS  ${DSS_peer_cell_id}  ${DSS_peer_rat}  ${DSS_peer_alias_list}

    [Return]  ${DSS_peer_cell_id}  ${DSS_peer_rat}  ${DSS_peer_alias}

Get DSS peer BTS
    [Arguments]  ${DSS_peer_cell_id}  ${DSS_peer_rat}  ${DSS_peer_alias_list}

    ${DSS_peer_alias}=  Set Variable  None

    FOR  ${alias}  IN  @{DSS_peer_alias_list}

        ${DSS_peer_alias}=  Set Variable If  '${DSS_peer_cell_id}' in ${${alias}_${DSS_peer_rat}_CELL_id_list}  ${alias}
        Exit For Loop If  '${DSS_peer_alias}' != 'None'

    END

    [Return]  ${DSS_peer_alias}

Check BTS states and alarms after Block Site operation on BTS
    [Arguments]  ${alias}

    Log  Check BTS ${alias} states and alarms after "Block Site" operation on BTS ${alias}   console=True

    Log  Check BTS ${alias} status:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_bts_block}  ${BTS_MAX_WAIT_TIME}
    Admin Check BTS Procedural and Blocking states  ${IntegratedToRan_Configured_}  ${Blocked_}  ${remained_MAX_WAIT_TIME}  ${alias}
    Log  BTS ${alias} - proceduralState: IntegratedToRAN|Configured, blockingState: Blocked, as expected!  console=True

    Log  Check BTS ${alias} cells status:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_bts_block}  ${BTS_MAX_WAIT_TIME}
    Admin Check all BTS cells expected states  ${CELL_state_blocked_check}  ${alias}  ${remained_MAX_WAIT_TIME}
    Log  All BTS ${alias} cells status:\n - ${CELL_state_blocked}  console=True

    Log  Check BTS ${alias} alarms:  console=True
    ${BTS_IGNORED_ALARMS_FULL}=  Combine Lists  ${test_alarms_list['${alias.upper()}_IGNORED_ALARMS']}
    ...  ${test_alarms_list['${alias.upper()}_IGNORED_ALARMS_DURING_ACTION']}

    Log  BTS ${alias} "BTS blocked (50)" alarm, expected number: 1  console=True

    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=${test_alarms_list['${alias.upper()}_EXPECTED_ALARMS_50']}
    ...  ignored_alarms=${BTS_IGNORED_ALARMS_FULL}  critical_alarms=${test_alarms_list['${alias.upper()}_CRITICAL_ALARMS']}

    Log  BTS ${alias} "BTS blocked (50)" alarm, found number: 1, as expected!  console=True

    Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

Check peer BTS states and alarms after Block Site operation on BTS
    [Arguments]  ${alias}  ${peer_alias}

    Log  Check BTS ${peer_alias} states and alarms after "Block Site" operation on BTS ${alias}  console=True

    Log  Check BTS ${peer_alias} status:  console=True
    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  ${BTS_MAX_WAIT_TIME}  ${peer_alias}
    Log  BTS ${peer_alias} site - proceduralState: OnAir, blockingState: Unblocked, as expected!  console=True

    Log  Check BTS ${peer_alias} alarms:  console=True
    ${NR_DSS_alarms}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${BTS_alias_NR_DSS_alarms_dict}  ${peer_alias}
    ${LTE_DSS_alarms}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${BTS_alias_LTE_DSS_alarms_dict}  ${peer_alias}
    ${NR_DSS_alarms_count}=  Run Keyword If  ${NR_DSS_alarms}
    ...  Get From Dictionary  ${BTS_alias_NR_DSS_alarms_dict}  ${peer_alias}
    ...  ELSE
    ...  Set Variable  0
    ${LTE_DSS_alarms_count}=  Run Keyword If  ${LTE_DSS_alarms}
    ...  Get From Dictionary  ${BTS_alias_LTE_DSS_alarms_dict}  ${peer_alias}
    ...  ELSE
    ...  Set Variable  0
    ${NR_DSS_EXPECTED_ALARMS_full}=  Prepare expected alarms list  ${test_alarms_list['${peer_alias.upper()}_ALARMS_NR_DSS']}  ${NR_DSS_alarms_count}
    ${LTE_DSS_EXPECTED_ALARMS_full}=  Prepare expected alarms list  ${test_alarms_list['${peer_alias.upper()}_ALARMS_LTE_DSS']}
    ...  ${LTE_DSS_alarms_count}
    ${DSS_EXPECTED_ALARMS_full}=  Combine Lists  ${NR_DSS_EXPECTED_ALARMS_full}  ${LTE_DSS_EXPECTED_ALARMS_full}

    ${peer_BTS_IGNORED_ALARMS_FULL}=  Combine Lists  ${test_alarms_list['${peer_alias.upper()}_IGNORED_ALARMS']}
    ...  ${test_alarms_list['${peer_alias.upper()}_IGNORED_ALARMS_DURING_ACTION']}

    Run Keyword If  ${NR_DSS_alarms_count} > 0
    ...  Log  BTS ${peer_alias} ${NR_DSS_alarms_info}, expected number: ${NR_DSS_alarms_count}  console=True
    Run Keyword If  ${LTE_DSS_alarms_count} > 0
    ...  Log  BTS ${peer_alias} ${LTE_DSS_alarms_info}, expected number: ${LTE_DSS_alarms_count}  console=True

    Get and Check Alarms SOAM  alias=${peer_alias}  expected_alarms=${DSS_EXPECTED_ALARMS_full}
    ...  ignored_alarms=${peer_BTS_IGNORED_ALARMS_FULL}  critical_alarms=${test_alarms_list['${peer_alias.upper()}_CRITICAL_ALARMS']}

    Run Keyword If  ${NR_DSS_alarms_count} > 0
    ...  Log  BTS ${peer_alias} ${NR_DSS_alarms_info}, found number: ${NR_DSS_alarms_count}, as expected!  console=True
    Run Keyword If  ${LTE_DSS_alarms_count} > 0
    ...  Log  BTS ${peer_alias} ${LTE_DSS_alarms_info}, found number: ${LTE_DSS_alarms_count}, as expected!  console=True

    Log  BTS ${peer_alias} site - expected, ignored and critical alarms checked  console=True

Count peer BTS expected alarms related to shared RMOD primary link info
    [Arguments]  ${peer_alias}

    ${all_BTS_PL_shared_RMOD_info}=  Get PL shared RM info on all BTS

    ${BTS_PL_shared_RMOD_info}=  Get From Dictionary  ${all_BTS_PL_shared_RMOD_info}  ${peer_alias}

    ${BTS_non_PL_OBSAI_shared_RMOD_id_list}=  Get From Dictionary  ${BTS_PL_shared_RMOD_info}  BTS_non_PL_OBSAI_shared_RM_id_list
    ${BTS_non_PL_CPRI_shared_RMOD_id_list}=  Get From Dictionary  ${BTS_PL_shared_RMOD_info}  BTS_non_PL_CPRI_shared_RM_id_list
    ${BTS_non_PL_ECPRI_shared_RMOD_id_list}=  Get From Dictionary  ${BTS_PL_shared_RMOD_info}  BTS_non_PL_ECPRI_shared_RM_id_list
    ${BTS_non_PL_not_excepted_ECPRI_shared_RMOD_id_list}  ${BTS_non_PL_excepted_ECPRI_shared_RMOD_id_list}=
    ...  Get excepted and not excepted RMOD lists  ${BTS_non_PL_ECPRI_shared_RMOD_id_list}  ${RMOD_ECPRI_fid16_exceptions}  ${peer_alias}

    ${BTS_non_PL_OBSAI_shared_RMOD_count}=  Get Length  ${BTS_non_PL_OBSAI_shared_RMOD_id_list}
    ${BTS_non_PL_CPRI_shared_RMOD_count}=  Get Length  ${BTS_non_PL_CPRI_shared_RMOD_id_list}
    ${BTS_non_PL_not_excepted_ECPRI_shared_RMOD_count}=  Get Length  ${BTS_non_PL_not_excepted_ECPRI_shared_RMOD_id_list}
    ${BTS_non_PL_excepted_ECPRI_shared_RMOD_count}=  Get Length  ${BTS_non_PL_excepted_ECPRI_shared_RMOD_id_list}

    ${BTS_EXPECTED_ALARMS_shared_RMOD_OBSAI_count}=  Set Variable  ${BTS_non_PL_OBSAI_shared_RMOD_count}
    ${BTS_EXPECTED_ALARMS_shared_RMOD_CPRI_count}=  Run Keyword If  ${${peer_alias}_CB007447_status}
    ...  Set Variable  0
    ...  ELSE
    ...  Set Variable  ${BTS_non_PL_CPRI_shared_RMOD_count}
    ${BTS_EXPECTED_ALARMS_shared_RMOD_ECPRI_count}=  Set Variable  ${BTS_non_PL_not_excepted_ECPRI_shared_RMOD_count}

    ${BTS_EXPECTED_ALARMS_shared_RMOD_OBSAI_list}=  Prepare expected alarms list  ${test_alarms_list['${peer_alias.upper()}_EXPECTED_ALARMS_10_1815']}
    ...  ${BTS_EXPECTED_ALARMS_shared_RMOD_OBSAI_count}
    ${BTS_EXPECTED_ALARMS_shared_RMOD_CPRI_list}=  Prepare expected alarms list  ${test_alarms_list['${peer_alias.upper()}_EXPECTED_ALARMS_10_1815']}
    ...  ${BTS_EXPECTED_ALARMS_shared_RMOD_CPRI_count}
    ${BTS_EXPECTED_ALARMS_shared_RMOD_ECPRI_list}=  Prepare expected alarms list  ${test_alarms_list['${peer_alias.upper()}_EXPECTED_ALARMS_16']}
    ...  ${BTS_EXPECTED_ALARMS_shared_RMOD_ECPRI_count}
    ${BTS_EXPECTED_ALARMS_shared_RMOD_OBSAI_CPRI_count}=  Evaluate
    ...  ${BTS_EXPECTED_ALARMS_shared_RMOD_OBSAI_count} + ${BTS_EXPECTED_ALARMS_shared_RMOD_CPRI_count}

    Set Test Variable  ${${peer_alias.upper()}_EXPECTED_ALARMS_10_1815_count}  ${BTS_EXPECTED_ALARMS_shared_RMOD_OBSAI_CPRI_count}
    Set Test Variable  ${${peer_alias.upper()}_EXPECTED_ALARMS_16_count}  ${BTS_EXPECTED_ALARMS_shared_RMOD_ECPRI_count}

    ${BTS_EXPECTED_ALARMS_list}=  Combine Lists  ${BTS_EXPECTED_ALARMS_shared_RMOD_OBSAI_list}
    ...  ${BTS_EXPECTED_ALARMS_shared_RMOD_CPRI_list}  ${BTS_EXPECTED_ALARMS_shared_RMOD_ECPRI_list}
    ${BTS_IGNORED_ALARMS_list}=  Combine Lists  ${test_alarms_list['${peer_alias.upper()}_IGNORED_ALARMS']}
    ...  ${test_alarms_list['${peer_alias.upper()}_IGNORED_ALARMS_DURING_ACTION']}

    Set Test Variable  ${${peer_alias.upper()}_EXPECTED_ALARMS_list}  ${BTS_EXPECTED_ALARMS_list}
    Set Test Variable  ${${peer_alias.upper()}_IGNORED_ALARMS_list}  ${BTS_IGNORED_ALARMS_list}

Check peer BTS alarms during Unblock Site operation on BTS
    [Arguments]  ${alias}  ${peer_alias}

    Log  Check BTS ${peer_alias} alarms during "Unblock Site" operation on BTS ${alias}:  console=True

    ${peer_BTS_IGNORED_ALARMS_FULL}=  Combine Lists  ${${peer_alias.upper()}_IGNORED_ALARMS_list}
    ...  ${test_alarms_list['${peer_alias.upper()}_ALARMS_NR_DSS']}  ${test_alarms_list['${peer_alias.upper()}_ALARMS_LTE_DSS']}

    Run Keyword If  ${${peer_alias.upper()}_EXPECTED_ALARMS_10_1815_count} > 0
    ...  Log Long String  BTS ${peer_alias} "No connection to Unit (10)" or "Not able to synchronize baseband bus (1815)" alarm, expected number:
    ...  ${${peer_alias.upper()}_EXPECTED_ALARMS_10_1815_count}  console=True
    Run Keyword If  ${${peer_alias.upper()}_EXPECTED_ALARMS_16_count} > 0
    ...  Log  BTS ${peer_alias} "Unit synchronization failed (16)" alarm, expected number: ${${peer_alias.upper()}_EXPECTED_ALARMS_16_count}
    ...  console=True

    Get and Check Alarms SOAM  alias=${peer_alias}  poll_interval=5s  expected_alarms=${${peer_alias.upper()}_EXPECTED_ALARMS_list}
    ...  ignored_alarms=${peer_BTS_IGNORED_ALARMS_FULL}  critical_alarms=${test_alarms_list['${peer_alias.upper()}_CRITICAL_ALARMS']}

    Run Keyword If  ${${peer_alias.upper()}_EXPECTED_ALARMS_10_1815_count} > 0
    ...  Log Long String  BTS ${peer_alias} "No connection to Unit (10)" or "Not able to synchronize baseband bus (1815)" alarm, found number:
    ...  ${${peer_alias.upper()}_EXPECTED_ALARMS_10_1815_count}  console=True
    Run Keyword If  ${${peer_alias.upper()}_EXPECTED_ALARMS_16_count} > 0
    ...  Log  BTS ${peer_alias} "Unit synchronization failed (16)" alarm, found number: ${${peer_alias.upper()}_EXPECTED_ALARMS_16_count}
    ...  console=True

    Log  BTS ${peer_alias} site - expected, ignored and critical alarms checked  console=True

Check BTS states and alarms after Unblock Site operation on BTS
    [Arguments]  ${alias}

    Log  Check BTS ${alias} states and alarms after "Unblock Site" operation on BTS ${alias}:  console=True

    Log  Check BTS ${alias} status:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_bts_unblock}  ${BTS_MAX_WAIT_TIME}
    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  ${remained_MAX_WAIT_TIME}  ${alias}
    Log  BTS ${alias} status:\n - proceduralState: OnAir, blockingState: Unblocked  console=True

    Log  Check BTS ${alias} RMODs status:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_bts_unblock}  ${BTS_MAX_WAIT_TIME}
    Assert Every  class_name=RMOD  parameters=${RMOD_state_enabled_check}  timeout=${remained_MAX_WAIT_TIME}  connection=${alias}
    Log  BTS ${alias} RMODs status:\n - ${RMOD_state_enabled}  console=True

    Log  Check BTS ${alias} cells status:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_bts_unblock}  ${BTS_MAX_WAIT_TIME}
    Check cells availability status online  ${alias}  ${remained_MAX_WAIT_TIME}
    Log  BTS ${alias} cells status:\n - operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked  console=True

    Log  Check BTS ${alias} alarms:  console=True
    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${test_alarms_list['${alias.upper()}_IGNORED_ALARMS']}
    ...  critical_alarms=${test_alarms_list['${alias.upper()}_CRITICAL_ALARMS']}
    Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

Check peer BTS states and alarms after Unblock Site operation on BTS
    [Arguments]  ${alias}  ${peer_alias}

    Log  Check BTS ${peer_alias} states and alarms after "Unblock Site" operation on BTS ${alias}  console=True

    Log  Check BTS ${peer_alias} status:  console=True
    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  ${BTS_MAX_WAIT_TIME}  ${peer_alias}
    Log  BTS ${peer_alias} site - proceduralState: OnAir, blockingState: Unblocked, as expected!  console=True

    Log  Check BTS ${peer_alias} RMODs status:  console=True
    Assert Every  class_name=RMOD  parameters=${RMOD_state_enabled_check}  timeout=${BTS_MAX_WAIT_TIME}  connection=${peer_alias}
    Log  BTS ${peer_alias} RMODs status:\n - ${RMOD_state_enabled}  console=True

    Log  Check BTS ${peer_alias} cells status:  console=True
    Check cells availability status online  ${peer_alias}  ${BTS_MAX_WAIT_TIME}
    Log  BTS ${peer_alias} cells status:\n - operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked  console=True

    Log  Check BTS ${peer_alias} alarms:  console=True
    Get and Check Alarms SOAM  alias=${peer_alias}  wait_for_alarm_clear=15 min  expected_alarms=@{EMPTY}
    ...  ignored_alarms=${test_alarms_list['${peer_alias.upper()}_IGNORED_ALARMS']}
    ...  critical_alarms=${test_alarms_list['${peer_alias.upper()}_CRITICAL_ALARMS']}
    Log  BTS ${peer_alias} site - expected, ignored and critical alarms checked  console=True

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
    FOR  ${peer_alias}  IN  @{alias_list}
        Continue For Loop If  '${peer_alias}' == '${alias}'
        Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=${peer_alias}
        ...  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}
    END

Get and check KPI1a info from IMS file
    [Documentation]
    ...  Get and check KPI1a info from IMS file.
    [Arguments]  ${alias}

    Log  Get and check KPI1a info from IMS file  console=True
    ${BTS_KPI}=  Get From Dictionary  ${BTS_alias_BTS_KPI_dict}  ${alias}
    ${kpi_name_delta_dict}=  Get and check KPI info from IMS file  kpi_names=kpi1a  kpi_thresholds=${BTS_KPI}  alias=${alias}
    ...  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}
    ${kpi_delta_list}=  Get From Dictionary  ${kpi_name_delta_dict}  kpi1a

    Export KPI Results to File  alias=${alias}  obj=BTS  obj_type=SBTS  obj_id=BTS ${alias}  action_1=BTS_Unblock  kpi_reported_1=KPI_1a
    ...  event_value_1=${kpi_delta_list[0]}  cycle=${CYCLE}  source_info=ims

Particular Teardown
    FOR  ${alias}  IN  @{BTS_alias_list}

        Admin Check if BTS is unblocked  ${alias}

    END

    Export KPI results to File Global  kpi_log_file_name=KpiTimeInfo

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}  newAlarmsFormat=${TRUE}

TC Teardown
    Common Test Teardown

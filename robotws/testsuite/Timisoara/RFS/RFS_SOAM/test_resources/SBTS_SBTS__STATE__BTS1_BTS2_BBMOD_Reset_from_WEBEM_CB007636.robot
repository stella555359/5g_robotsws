*** Settings ***
Documentation    TC__SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WEBEM_CB007636
Variables    tc_variables/sbts_sbts__state__bts1_bts2_bbmod_reset_from_webem_CB007636_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}  3                  # Number of BBMOD Reset operations on both BTS, default value 3
${HISTORICAL_ALARMS_CHECK}   True  # Flag to enable/disable historical alarms check; Possible values: True, False
${RESET_BBMOD_TYPE_LIST}  ABIA, ABIL, ABIN, ABIO, ABIP, ABIQ  # BBMOD type list on which Reset operation is valid. User may add/remove BBMOD type
                                                              # according with BBMOD Reset operation validity
${BBMOD_RESET_WRN_THR}    270   # Time from BBMOD Reset to last cell up. Default value: in accordance with KPI 5 specifications
${BBMOD_RESET_MAX_WAIT_TIME}    900   # Maximum time for wait of BTS OnAir (first cell up after reset). If this value is exceeded, test will fail

*** Keywords ***
TC__SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WEBEM_CB007636
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-22958
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS test case for BBMOD Reset operation, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial BTS state and alarms
    ...  - get BBMOD list and cell info
    ...  - perform reset operation on each BBMOD checking BTS state and alarms
    ...  - check BTS reset behavior based on IMS: reset number is 0
    ...  - check final BTS state and alarms
    ...  Pass criteria: BBMOD reset operations works as expected; states and alarms are as expected
    ...
    ...  ***************************
    ...  History of changes for SOAM
    ...  ***************************
    ...  - 06.06.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-22958 - [5G][CB007636] New SBTS_SBTS
    ...  scenario_RFS_SBTS_RF_Share_Baseband_module_Reset_SBTS_with_FHS
    ...  - 24.06.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23342 - [5G] Fix alarm file name
    ...  - 01.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23861 -
    ...  [5G][TC review] [SBTS-SBTS] Remove cells "AdministrativeState" check in all SBTS-SBTS robots
    ...  - 21.08.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25846 - [5G][CB009569] Update
    ...  SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WEBEM_CB007636 - pair with TAT-24775, TAT-24740
    ...  - 21.08.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24740 - [5G][TC review] Update BBMOD Reset scenario, with input list of BBMOD
    ...  HW Type which need reset - SBTS-SBTS - CB007636
    ...  - 21.08.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24775 - [5G] Replace Setup Admin KW with Start new ADMIN instance
    ...  KW - SBTS_SBTS - w2310
    ...  - 25.08.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24739 - [5G][KPI5] Please update BBMOD Reset to use KPI#5 measurements from
    ...  ims - SBTS_SBTS CB007636 - w2310 pair with TAT-25855
    ...  - 28.08.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25855 - [5G][CB009569] Add checks regarding DSS alarms -
    ...  SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WEBEM_CB007636 pair with TAT-24739
    ...  - 23.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27803 -
	...  [CNI-127210] [Part 1] DSS LTE EXPECTED alarms check removal SBTS_* TCs
	...  - 18.09.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28022 - [5G] [Infomodel] Infomodel refactor in
	...  SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WEBEM_CB007636 - after TAT-27963
    ...  - 01.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29003 -
    ...  Detect SBTS-SBTS instead off LTE-LTE for SBTS_SBTS__STATE__SharedRM_Power_Off_On
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-22958_SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WEBEM.png

    Set Tags    CA-STATE    OWNER-roman.razvan@nokia.com    AUTHOR-horea.olar@nokia.com    PHASE-QT

    TC Preconditions
    Step 1: Check initial BTS Master state
    Step 2: Check initial BTS Slave state
    Step 3: Check initial BTS Master alarms
    Step 4: Check initial BTS Slave alarms
    Step 5: Get BBMOD list and related FHS and RMOD info for both BTS
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 6: Perform Reset BBMOD on BTS Master for iteration ${INDEX}
        Step 7: Perform Reset BBMOD on BTS Slave for iteration ${INDEX}
        Step 8: Check both SBTS reset behavior from IMS
        Step 9: Check Historic Alarms
        Step 10: Check final number and state of Cells and RMs
    END
    Step 11: Check final BTS Master state
    Step 12: Check final BTS Slave state
    Step 13: Check final BTS Master alarms
    Step 14: Check final BTS Slave alarms

    [Teardown]  Particular Teardown

TC Preconditions
    ${BTS_alias_label_dict}  ${BTS_label_alias_dict}=  Get BTS alias label info dict
    Set Test Variable  ${BTS_alias_label_dict}
    Set Test Variable  ${BTS_label_alias_dict}

    ${RESET_BBMOD_TYPE_LIST_strip}=  Replace String  ${RESET_BBMOD_TYPE_LIST}  ${SPACE}  ${EMPTY}
    ${RESET_BBMOD_TYPE_LIST}=  Split String  ${RESET_BBMOD_TYPE_LIST_strip}  ,
    Set Test Variable  ${RESET_BBMOD_TYPE_LIST}
    ${TL_BBMOD_reset_check}=  Set Variable  ${FALSE}
    FOR  ${alias}  IN  @{alias_list}
        ${BTS}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
        Log  TC Preconditions verification started on ${BTS}  console=True
        ${BBMOD_reset_check}=  Check BBMOD type reset info  ${RESET_BBMOD_TYPE_LIST}  ${alias}
        Run Keyword If  ${BBMOD_reset_check}
        ...  Log  TC Preconditions passed on ${BTS}. Reset operation will be performed on valid BBMOD(s) from: ${RESET_BBMOD_TYPE_LIST}  console=True
        ...  ELSE
        ...  Log  TC Preconditions failed on ${BTS}. No BBMOD type valid for Reset operation found in: ${RESET_BBMOD_TYPE_LIST}  console=True
        Set Test Variable  ${${alias}_BBMOD_reset_check}  ${BBMOD_reset_check}
        ${TL_BBMOD_reset_check}=  Set Variable If  ${BBMOD_reset_check}  ${TRUE}  ${TL_BBMOD_reset_check}
    END
    Run Keyword If  not ${TL_BBMOD_reset_check}  Run Keywords
    ...  Log Long String  TC Preconditions failed on TL. No BBMOD type valid for Reset operation found on any BTS. Test execution will be stopped!
    ...  level=ERROR
    ...  AND  Fail  TC Preconditions failed on TL. No BBMOD type valid for Reset operation found on any BTS. Test execution will be stopped!

Step ${index}: Check ${when} BTS ${alias} state
    [Documentation]
    ...  SBTS state is checked according to Admin for BTS and each configured RAT

    [Timeout]  15 min
    Log  Step ${index}: Check ${when} BTS ${alias} state  console=True
    Admin Check BTS RAT Procedural State  alias=${alias}  timeout=600
    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  alias=${alias}
    Log  BTS ${alias} site - proceduralState: OnAir, blockingState: Unblocked  console=True

Step ${index}: Check ${when} BTS ${alias} alarms
    [Documentation]
    ...  SBTS alarms are compared with values from expected, ignored and critical alarms lists. SBTS alarms are get
    ...  from admin

    [Timeout]  15 min
    Log  Step ${index}: Check ${when} BTS ${alias} alarms  console=True
    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${SBTS_${alias.upper()}_IGNORED_ALARMS}
    ...  critical_alarms=${SBTS_${alias.upper()}_CRITICAL_ALARMS}
    Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

Step ${index}: Get BBMOD list and related FHS and RMOD info for both BTS
    [Documentation]
    ...  Get BBMOD list and related FHS and RMOD info for both BTS from Admin

    [Timeout]  5 min
    Log  Step ${index}: Get BBMOD list and related FHS RMOD and cells info for both BTS  console=True
    ${Master_BBMOD_list}=  Get Ids For All  class_name=BBMOD  connection=Master
    Sort List  ${Master_BBMOD_list}
    ${Master_BBMOD_count}=  Get Length  ${Master_BBMOD_list}
    Run Keyword If  ${Master_BBMOD_count} > 0
    ...  Log  Master BBMOD found: ${Master_BBMOD_list}  console=True
    ...  ELSE
    ...  Fail  No Master BBMOD are present in runtime view configuration!
    Set Test Variable  ${Master_BBMOD_list}

    ${Slave_BBMOD_list}=  Get Ids For All  class_name=BBMOD  connection=Slave
    Sort List  ${Slave_BBMOD_list}
    ${Slave_BBMOD_count}=  Get Length  ${Slave_BBMOD_list}
    Run Keyword If  ${Slave_BBMOD_count} > 0
    ...  Log  Slave BBMOD found: ${Slave_BBMOD_list}  console=True
    ...  ELSE
    ...  Fail  No Slave BBMOD are present in runtime view configuration!
    Set Test Variable  ${Slave_BBMOD_list}

    ${Master_shared_FHS_list}  ${Slave_shared_FHS_list}  ${Master_dedicated_FHS_list}  ${Slave_dedicated_FHS_list}=
    ...  Admin Get shared and dedicated module list for Master and Slave  FHS  Master  Slave
    Set Test Variable  ${Master_shared_FHS_list}
    Set Test Variable  ${Slave_shared_FHS_list}
    Set Test Variable  ${Master_dedicated_FHS_list}
    Set Test Variable  ${Slave_dedicated_FHS_list}
    ${Master_shared_RMOD_list}  ${Slave_shared_RMOD_list}  ${Master_dedicated_RMOD_list}  ${Slave_dedicated_RMOD_list}=
    ...  Admin Get shared and dedicated module list for Master and Slave  RMOD  Master  Slave
    Set Test Variable  ${Master_shared_RMOD_list}
    Set Test Variable  ${Slave_shared_RMOD_list}
    Set Test Variable  ${Master_dedicated_RMOD_list}
    Set Test Variable  ${Slave_dedicated_RMOD_list}

    Get BTS FHS ID SN dict  Master
    Get BTS FHS ID SN dict  Slave
    Get BTS RMOD ID SN dict  Master
    Get BTS RMOD ID SN dict  Slave

    ${Master_BBMOD_shared_FHS_dict}  ${Master_BBMOD_dedicated_FHS_dict}=  Get BBMOD FHS info  ${Master_BBMOD_list}  Master
    Set Test Variable  ${Master_BBMOD_shared_FHS_dict}
    Set Test Variable  ${Master_BBMOD_dedicated_FHS_dict}
    ${Master_BBMOD_shared_RMOD_dict}  ${Master_BBMOD_dedicated_RMOD_dict}=  Get BBMOD RMOD info  ${Master_BBMOD_list}  Master
    Set Test Variable  ${Master_BBMOD_shared_RMOD_dict}
    Set Test Variable  ${Master_BBMOD_dedicated_RMOD_dict}
    ${Master_BBMOD_FHS_RMOD_dict}=  Get BBMOD FHS RMOD info  ${Master_BBMOD_list}  Master
    Set Test Variable  ${Master_BBMOD_FHS_RMOD_dict}

    ${Slave_BBMOD_shared_FHS_dict}  ${Slave_BBMOD_dedicated_FHS_dict}=  Get BBMOD FHS info  ${Slave_BBMOD_list}  Slave
    Set Test Variable  ${Slave_BBMOD_shared_FHS_dict}
    Set Test Variable  ${Slave_BBMOD_dedicated_FHS_dict}
    ${Slave_BBMOD_shared_RMOD_dict}  ${Slave_BBMOD_dedicated_RMOD_dict}=  Get BBMOD RMOD info  ${Slave_BBMOD_list}  Slave
    Set Test Variable  ${Slave_BBMOD_shared_RMOD_dict}
    Set Test Variable  ${Slave_BBMOD_dedicated_RMOD_dict}
    ${Slave_BBMOD_FHS_RMOD_dict}=  Get BBMOD FHS RMOD info  ${Slave_BBMOD_list}  Slave
    Set Test Variable  ${Slave_BBMOD_FHS_RMOD_dict}

    Get BTS CELL list by RAT  Master
    Get BTS CELL list by RAT  Slave

    ${Master_BBMOD_CELL_runtime_dict}  ${Master_BBMOD_CELL_scf_dict}=  Get BBMOD CELL mapping based on BBPOOL info from SCF  Master
    ${Slave_BBMOD_CELL_runtime_dict}  ${Slave_BBMOD_CELL_scf_dict}=  Get BBMOD CELL mapping based on BBPOOL info from SCF  Slave
    Set Test Variable  ${Master_CELL_BBMOD_dict}  ${Master_BBMOD_CELL_runtime_dict}
    Set Test Variable  ${Slave_CELL_BBMOD_dict}  ${Slave_BBMOD_CELL_runtime_dict}

    ${BTS_XP_localAlias_remoteAlias_dict}  ${NRBTS_DSS_alias_actLteNrDss_dict}  ${LNBTS_DSS_alias_actLteNrDss_dict}  ${BTS_DSS_NR_LTE_CELL_scf_dict}
    ...  ${BTS_DSS_LTE_NR_CELL_scf_dict}  ${BTS_DSS_NR_LTE_CELL_runtime_dict}  ${BTS_DSS_LTE_NR_CELL_runtime_dict}=  Get all BTS DSS feature info
    Set Test Variable  ${BTS_DSS_NR_LTE_CELL_runtime_dict}
    Set Test Variable  ${BTS_DSS_LTE_NR_CELL_runtime_dict}
    FOR  ${alias}  IN  @{alias_list}
        ${peer_alias}=  Set Variable If  '${alias}' == 'Master'  Slave  Master
        ${BTS_actLteNrDss_NR}=  Get From Dictionary  ${NRBTS_DSS_alias_actLteNrDss_dict}  ${alias}
        ${BTS_actLteNrDss_LTE}=  Get From Dictionary  ${LNBTS_DSS_alias_actLteNrDss_dict}  ${alias}

        ${BTS_DSS_configured}=  Set Variable If  '${BTS_actLteNrDss_NR}' == 'True' or '${BTS_actLteNrDss_LTE}' == 'True'  True  False
        ${BTS_DSS_peer}=  Get From Dictionary  ${BTS_XP_localAlias_remoteAlias_dict}  ${alias}
        Run Keyword If  '${peer_alias}' not in ${BTS_DSS_peer}
        ...  Set Test Variable  ${BTS_DSS_configured}  False

        Set Test Variable  ${${alias}_DSS_configured}  ${BTS_DSS_configured}
    END

    Run Keyword If  ${Master_DSS_configured} and ${Slave_DSS_configured}
    ...  Log  DSS is configured between BTS1 and BTS2. DSS alarms check will be performed!  console=True
    ...  ELSE  Log  DSS is not configured between BTS1 and BTS2. DSS alarms check will be skipped!  console=True

Get BTS RMOD ID SN dict
    [Arguments]  ${alias}
    ${RMOD_list}=  Get Ids For All  class_name=RMOD  connection=${alias}
    ${module_SN_ID_dict}=  Create Dictionary
    ${module_ID_SN_dict}=  Create Dictionary
    FOR  ${item}  IN  @{RMOD_list}
        ${module_param}=  Get Parameters For  class_name=RMOD  id_num=${item}  connection=${alias}
        Set To Dictionary  ${module_SN_ID_dict}  ${module_param['serialNumber']}  ${module_param['id']}
        Set To Dictionary  ${module_ID_SN_dict}  ${module_param['id']}  ${module_param['serialNumber']}
    END
    Set Test Variable  ${${alias}_RMOD_SN_ID_dict}  ${module_SN_ID_dict}
    Set Test Variable  ${${alias}_RMOD_ID_SN_dict}  ${module_ID_SN_dict}

Get BTS FHS ID SN dict
    [Arguments]  ${alias}
    ${FHS_info_list}=  Get Fhs List  connection=${alias}
    ${module_SN_ID_dict}=  Create Dictionary
    ${module_ID_SN_dict}=  Create Dictionary
    FOR  ${item}  IN  @{FHS_info_list}
        Set To Dictionary  ${module_SN_ID_dict}  ${item['serialNumber']}  ${item['id']['internal']}
        Set To Dictionary  ${module_ID_SN_dict}  ${item['id']['internal']}  ${item['serialNumber']}
    END
    Set Test Variable  ${${alias}_FHS_SN_ID_dict}  ${module_SN_ID_dict}
    Set Test Variable  ${${alias}_FHS_ID_SN_dict}  ${module_ID_SN_dict}

Step ${index}: Perform Reset BBMOD on BTS ${alias} for iteration ${CYCLE}
    [Documentation]
    ...  Perform Reset BBMOD

    Log  Step ${index}: Perform Reset BBMOD on BTS ${alias} for iteration ${CYCLE}  console=True
    ${BTS}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
    Run Keyword If  not ${${alias}_BBMOD_reset_check}  Run Keywords
    ...  Log  Test execution will be skipped on ${BTS} due to TC Preconditions check!  console=True
    ...  AND  Return From Keyword
    Get Current Date UTC info  start_${alias}
    FOR  ${item}  IN  @{${alias}_BBMOD_list}
        Reset BBMOD  ${item}  ${alias}  ${CYCLE}
    END

Step ${index}: Check both SBTS reset behavior from IMS
    [Documentation]
    ...  Check both BTS reset behavior based on IMS info. Reset behavior as expected iFș
    ...  - BTS1: reset number is 0
    ...  - BTS2: reset number is 0
    ...  Otherwise, reset behavior not as expected, then errors are added to report and failed.
    Log  Step ${index}: Check both SBTS reset behavior from IMS  console=True

    Get Current Date UTC info  end
    Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=Master
    ...  start_point_timestamp_UTC=${date_timestamp_start_Master_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}
    Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=Slave
    ...  start_point_timestamp_UTC=${date_timestamp_start_Slave_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Cells state is checked according to operationalState attribute
    ...  Check if number of configured cells and radio modules in SCF are properly mapping on BTS running view.
    ...  Also check RMs operationalState

    [Timeout]  30 min
    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Get BBMOD list
    [Documentation]
    ...  Get BBMOD list

    [Arguments]  ${alias}

    Log  Get BTS ${alias} BBMOD list  console=True
    ${BBMOD_list}=  Get Ids For All  class_name=BBMOD  connection=${alias}
    Sort List  ${BBMOD_list}
    ${BBMOD_count}=  Get Length  ${BBMOD_list}
    Run Keyword If  ${BBMOD_count} > 0
    ...  Log  BTS ${alias} BBMOD list: ${BBMOD_list}  console=True
    ...  ELSE
    ...  Fail  No BTS ${alias} BBMOD are present in runtime view!
    Set Test Variable  ${${alias}_BBMOD_list}  ${BBMOD_list}
    Set Test Variable  ${${alias}_BBMOD_count}  ${BBMOD_count}

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

Reset BBMOD
    [Arguments]  ${BBMOD_id}  ${alias}  ${CYCLE}

    ${peer_alias}=  Set Variable If  '${alias}' == 'Master'  Slave  Master
    ${CELL_state_enabled_check}=  Set Variable  operationalState=${Enabled_}
    ${CELL_state_enabled}=  Set Variable  operationalState=Enabled
    ${CELL_state_enabled_WCDMA_check}=  Set Variable  operationalState=${Enabled_}
    ${CELL_state_enabled_WCDMA}=  Set Variable  operationalState=Enabled

    ${BBMOD_param}=  Get Parameters For  class_name=BBMOD  id_num=${BBMOD_id}  connection=${alias}
    Set Test Variable  ${BBMOD_sn}  ${BBMOD_param['serialNumber']}
    Set Test Variable  ${BBMOD_prodName}  ${BBMOD_param['productName']}

    Get shared RMOD Primary Link Info
    ${CELL_BBMOD_list}=  Get From Dictionary  ${${alias}_CELL_BBMOD_dict}  ${BBMOD_id}
    ${CELL_BBMOD_count}=  Get Length  ${CELL_BBMOD_list}
    Set Test Variable  ${CELL_BBMOD_list}
    Set Test Variable  ${CELL_BBMOD_count}
    ${BBMOD_shared_RMOD_list}=  Get From Dictionary  ${${alias}_BBMOD_shared_RMOD_dict}  ${BBMOD_id}
    ${BBMOD_FHS_RMOD_list}=  Get From Dictionary  ${${alias}_BBMOD_FHS_RMOD_dict}  ${BBMOD_id}
    ${BBMOD_FHS_linkModeSynchronization}=  Get linkModeSynchronization from CABLINK  ${BBMOD_id}  ${alias}
    ${alarm_count}=  Set Variable  0
    FOR  ${item}  IN  @{${alias}_PL_shared_RMOD_list}
        ${alarm_count}=  Run Keyword If  '${item}' in ${BBMOD_shared_RMOD_list}
        ...  Evaluate  ${alarm_count} + 1
        ...  ELSE IF  '${item}' in ${BBMOD_FHS_RMOD_list} and ${BBMOD_FHS_linkModeSynchronization}
        ...  Evaluate  ${alarm_count} + 1
        ...  ELSE  Set Variable  ${alarm_count}
    END
    Run Keyword If  ${${alias}_DSS_configured}  Get DSS alarms  ${alias}

    ${new_alias}=  Set Variable  resetBBMOD
    Start new ADMIN instance  alias=${alias}  new_alias=${new_alias}  connection_type=${connection_type_${alias}}
    ${BBMOD_reset_check}=  Check BBMOD reset validity  ${RESET_BBMOD_TYPE_LIST}  ${BBMOD_param.productName}
    Run Keyword If  not ${BBMOD_reset_check}  Run Keywords
    ...  Log  "Reset" operation on SBTS BTS for BBMOD with SN ${BBMOD_sn} will be skipped as not valid!  console=True
    ...  AND  Return From Keyword

    Log  Perform Reset operation from BTS ${alias} on BBMOD ${BBMOD_id} with SN ${BBMOD_sn}:  console=True
    Get Current Time  initial
    Get Current Date UTC info  bbmod_reset
    ${reset_info}=  Run Keyword In Background  Reset Unit  dist_name=${BBMOD_id}  reset_type=Warm  timeout=${BBMOD_RESET_MAX_WAIT_TIME}
    ...  connection=${new_alias}
    Set Test Variable  ${reset_info}
    Sleep  5s

    ${peer_SBTS_EXPECTED_ALARMS_7513}=  Run Keyword If  ${${alias}_DSS_configured} and ${alarm_count} == 0
    ...  Prepare expected alarms list  ${SBTS_EXPECTED_ALARMS_NR_DSS}  ${FID7513_alarm_count}
    ...  ELSE  Create List
    ${peer_SBTS_EXPECTED_ALARMS_10}=  Prepare expected alarms list  ${SBTS_EXPECTED_ALARMS}  ${alarm_count}
    ${peer_SBTS_EXPECTED_ALARMS}=  Combine Lists  ${peer_SBTS_EXPECTED_ALARMS_7513}  ${peer_SBTS_EXPECTED_ALARMS_10}
    ${peer_SBTS_IGNORED_ALARMS}=  Combine Lists  ${SBTS_DURING_RESET_IGNORED_ALARMS}  ${SBTS_${peer_alias.upper()}_IGNORED_ALARMS}

    Log  Check BTS ${peer_alias} state and alarms during Reset operation from BTS ${alias} on BBMOD with SN ${BBMOD_sn}:  console=True
    Log  BTS ${peer_alias} "No connection to Unit (10)" alarm, expected number: ${alarm_count}  console=True
    Run Keyword If  ${${peer_alias}_DSS_configured}
    ...  Log  BTS ${peer_alias} "EN DSS De-activated on partner side (7513)" alarm, expected number: ${FID7513_alarm_count}  console=True
    Get and Check Alarms SOAM  alias=${peer_alias}  poll_interval=5 sec  expected_alarms=${peer_SBTS_EXPECTED_ALARMS}
    ...  ignored_alarms=${peer_SBTS_IGNORED_ALARMS}  critical_alarms=${SBTS_${peer_alias.upper()}_CRITICAL_ALARMS}
    Log  BTS ${peer_alias} "No connection to Unit (10)" alarm, found number: ${alarm_count}, as expected!  console=True
    Run Keyword If  ${${peer_alias}_DSS_configured}
    ...  Log  BTS ${peer_alias} "EN DSS De-activated on partner side (7513)" alarm, found number: ${FID7513_alarm_count}, as expected!
    ...  console=True

    Collect Keyword Result  ${reset_info}  timeout=${BBMOD_RESET_MAX_WAIT_TIME}

    Log  Check BTS ${alias} state and alarms after Reset operation from BTS ${alias} on BBMOD with SN ${BBMOD_sn}:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${BBMOD_RESET_MAX_WAIT_TIME}
    Run Keyword If  ${${alias}_NR_CELL_list}
    ...  Assert Every  class_name=NRCEL  parameters=${CELL_state_enabled_check}  timeout=${remained_MAX_WAIT_TIME}  connection=${alias}
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${BBMOD_RESET_MAX_WAIT_TIME}
    Run Keyword If  ${${alias}_LTE_CELL_list}
    ...  Assert Every  class_name=LNCEL  parameters=${CELL_state_enabled_check}  timeout=${remained_MAX_WAIT_TIME}  connection=${alias}
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${BBMOD_RESET_MAX_WAIT_TIME}
    Run Keyword If  ${${alias}_WCDMA_CELL_list}
    ...  Assert Every  class_name=WNCEL  parameters=${CELL_state_enabled_WCDMA_check}  timeout=${remained_MAX_WAIT_TIME}  connection=${alias}
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${BBMOD_RESET_MAX_WAIT_TIME}
    Run Keyword If  ${${alias}_GSM_CELL_list}
    ...  Assert Every  class_name=GNCEL  parameters=${CELL_state_enabled_check}  timeout=${remained_MAX_WAIT_TIME}  connection=${alias}

    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${SBTS_${alias.upper()}_IGNORED_ALARMS}
    ...  critical_alarms=${SBTS_${alias.upper()}_CRITICAL_ALARMS}
    Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

    Log  Check BTS ${peer_alias} state and alarms after Reset operation from BTS ${alias} on BBMOD with SN ${BBMOD_sn}:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${BBMOD_RESET_MAX_WAIT_TIME}
    Run Keyword If  ${${peer_alias}_NR_CELL_list}  Run Keywords
    ...  Assert Every  class_name=NRCEL  parameters=${CELL_state_enabled_check}  timeout=${remained_MAX_WAIT_TIME}  connection=${peer_alias}
    ...  AND  Log  All NR ${peer_alias} cell(s) status:\n - ${CELL_state_enabled}  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${BBMOD_RESET_MAX_WAIT_TIME}
    Run Keyword If  ${${peer_alias}_LTE_CELL_list}  Run Keywords
    ...  Assert Every  class_name=LNCEL  parameters=${CELL_state_enabled_check}  timeout=${remained_MAX_WAIT_TIME}  connection=${peer_alias}
    ...  AND  Log  All LTE ${peer_alias} cell(s) status:\n - ${CELL_state_enabled}  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${BBMOD_RESET_MAX_WAIT_TIME}
    Run Keyword If  ${${peer_alias}_WCDMA_CELL_list}  Run Keywords
    ...  Assert Every  class_name=WNCEL  parameters=${CELL_state_enabled_WCDMA_check}  timeout=${remained_MAX_WAIT_TIME}  connection=${peer_alias}
    ...  AND  Log  All WCDMA ${peer_alias} cell(s) status:\n - ${CELL_state_enabled_WCDMA}  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${BBMOD_RESET_MAX_WAIT_TIME}
    Run Keyword If  ${${peer_alias}_GSM_CELL_list}  Run Keywords
    ...  Assert Every  class_name=GNCEL  parameters=${CELL_state_enabled_check}  timeout=${remained_MAX_WAIT_TIME}  connection=${peer_alias}
    ...  AND  Log  All GSM ${peer_alias} cell(s) status:\n - ${CELL_state_enabled}  console=True

    Get and Check Alarms SOAM  alias=${peer_alias}  expected_alarms=@{EMPTY}  ignored_alarms=${SBTS_${peer_alias.upper()}_IGNORED_ALARMS}
    ...  critical_alarms=${SBTS_${peer_alias.upper()}_CRITICAL_ALARMS}
    Log  SBTS ${peer_alias} site - expected, ignored and critical alarms checked  console=True

    Get Current Date UTC info  cells_onair

    Get and check KPI5 info from IMS file  ${BBMOD_id}  ${BBMOD_sn}  ${BBMOD_prodName}  ${CYCLE}  ${alias}

    [Teardown]  Teardown Admin  alias=${new_alias}

Step ${index}: Check Historic Alarms

    Run Keyword If  ${HISTORICAL_ALARMS_CHECK}==False  Run Keywords
    ...  Log  Historical Alarms Check will be skipped.  console=True
    ...  AND  Return From Keyword
    Log  Step ${index}: Check SBTS1 and SBTS2 Historic alarms  console=True

    ${SBTS_MASTER_HISTORICAL_ALARMS}=  Combine Lists  ${SBTS_MASTER_IGNORED_ALARMS}  ${SBTS_DURING_RESET_IGNORED_ALARMS}  ${SBTS_EXPECTED_ALARMS}
    ...  ${SBTS_EXPECTED_ALARMS_NR_DSS}
    ${SBTS_SLAVE_HISTORICAL_ALARMS}=  Combine Lists  ${SBTS_SLAVE_IGNORED_ALARMS}  ${SBTS_DURING_RESET_IGNORED_ALARMS}  ${SBTS_EXPECTED_ALARMS}
    ...  ${SBTS_EXPECTED_ALARMS_NR_DSS}

    Eval Historic Alarms  connection=Master    expected_alarms=@{EMPTY}  ignored_alarms=${SBTS_MASTER_HISTORICAL_ALARMS}
    ...  critical_alarms=${SBTS_MASTER_CRITICAL_ALARMS}  ignore_unexpected=True
    Eval Historic Alarms  connection=Slave    expected_alarms=@{EMPTY}  ignored_alarms=${SBTS_SLAVE_HISTORICAL_ALARMS}
    ...  critical_alarms=${SBTS_SLAVE_CRITICAL_ALARMS}  ignore_unexpected=True

Check Cell State
    [Arguments]   ${cell_class_name}  ${cell_list}  ${cell_state_check}  ${cell_state}  ${timeout}  ${alias}

    FOR  ${item}  IN  @{cell_list}
        Assert  class_name=${cell_class_name}  id=${item}  parameters=${cell_state_check}  timeout=${timeout}  connection=${alias}
        Log  ${cell_class_name} ${item} status:\n - ${cell_state}  console=True
    END

Get shared RMOD Primary Link Info
    [Documentation]
    ...  Get shared RMOD Primary Link Info

    ${Master_PL_shared_RMOD_list}=  Create List
    ${Master_non_PL_shared_RMOD_list}=  Create List
    ${Slave_PL_shared_RMOD_list}=  Create List
    ${Slave_non_PL_shared_RMOD_list}=  Create List
    ${Master_PL_dict}  ${Slave_PL_dict}=  Get Primary Link status for shared RMOD
    ${Master_keys}=  Get Dictionary Keys  ${Master_PL_dict}  False
    ${Slave_keys}=  Get Dictionary Keys  ${Slave_PL_dict}  False
    FOR  ${Master_key}  ${Slave_key}  IN ZIP  ${Master_keys}  ${Slave_keys}
        ${Master_value}=  Get From Dictionary  ${Master_PL_dict}  ${Master_key}
        ${Slave_value}=  Get From Dictionary  ${Slave_PL_dict}  ${Slave_key}
        Run Keyword If  'True' in '${Master_value}'
        ...  Append To List  ${Master_PL_shared_RMOD_list}  ${Master_key}
        ...  ELSE IF  'False' in '${Master_value}'
        ...  Append To List  ${Master_non_PL_shared_RMOD_list}  ${Master_key}
        Run Keyword If  'True' in '${Slave_value}'
        ...  Append To List  ${Slave_PL_shared_RMOD_list}  ${Slave_key}
        ...  ELSE IF  'False' in '${Slave_value}'
        ...  Append To List  ${Slave_non_PL_shared_RMOD_list}  ${Slave_key}
    END
    Set Test Variable  ${Master_PL_shared_RMOD_list}
    Set Test Variable  ${Master_non_PL_shared_RMOD_list}
    Set Test Variable  ${Slave_PL_shared_RMOD_list}
    Set Test Variable  ${Slave_non_PL_shared_RMOD_list}

Check BBMOD type reset info
    [Arguments]  ${RESET_BBMOD_TYPE_LIST}  ${alias}
    ${BBMOD_reset_check}=  Set Variable  ${FALSE}
    ${BBMOD_param_list}=  Get Parameters For All  class_name=BBMOD  connection=${alias}
    FOR  ${item}  IN  @{BBMOD_param_list}
        ${BBMOD_reset_check}=  Check BBMOD reset validity  ${RESET_BBMOD_TYPE_LIST}  ${item.productName}
        Exit For Loop If  ${BBMOD_reset_check}
    END
    [Return]  ${BBMOD_reset_check}

Check BBMOD reset validity
    [Arguments]  ${RESET_BBMOD_TYPE_LIST}  ${productName}
    ${BBMOD_reset_check}=  Set Variable  ${FALSE}
    FOR  ${item}  IN  @{RESET_BBMOD_TYPE_LIST}
        ${BBMOD_reset_check}=  Set Variable If  '${item}' in '${productName}'  ${TRUE}  ${BBMOD_reset_check}
        Exit For Loop If  '${item}' in '${productName}'
    END

    [Return]  ${BBMOD_reset_check}

Get DSS alarms
    [Arguments]  ${alias}

    ${DSS_NR_LTE_CELL_runtime_dict}=  Get From Dictionary  ${BTS_DSS_NR_LTE_CELL_runtime_dict}  ${alias}
    ${DSS_LTE_NR_CELL_runtime_dict}=  Get From Dictionary  ${BTS_DSS_LTE_NR_CELL_runtime_dict}  ${alias}
    ${DSS_LTE_CELL_list}=  Get Dictionary Keys  ${DSS_LTE_NR_CELL_runtime_dict}
    ${DSS_NR_CELL_list}=  Get Dictionary Keys  ${DSS_NR_LTE_CELL_runtime_dict}

    ${CELL_BBMOD_impacted_LTE_list}=  Create list
    ${CELL_BBMOD_impacted_NR_list}=  Create list
    FOR  ${item}  IN  @{CELL_BBMOD_list}
        Run Keyword If  '${item}' in ${DSS_LTE_CELL_list}  Append To List  ${CELL_BBMOD_impacted_LTE_list}  ${item}
        ...  ELSE IF  '${item}' in ${DSS_NR_CELL_list}  Append To List  ${CELL_BBMOD_impacted_NR_list}  ${item}
    END

    ${FID7513_alarm_count}=  Get Length  ${CELL_BBMOD_impacted_LTE_list}
    ${FID6134_alarm_count}=  Get Length  ${CELL_BBMOD_impacted_NR_list}

    Set Test Variable  ${FID7513_alarm_count}
    Set Test Variable  ${FID6134_alarm_count}

Get and check KPI5 info from IMS file
    [Documentation]
    ...  Get and check KPI5 info from IMS file.

    [Arguments]  ${BBMOD_id}  ${BBMOD_sn}  ${BBMOD_prodName}  ${CYCLE}  ${alias}

    Log  Get and check KPI5 info from IMS file on BTS ${alias} for iteration ${CYCLE}  console=True

    Run Keyword If  ${CELL_BBMOD_count} == 0  Run Keywords
    ...  Log  KPI calculation and reporting will be skipped because BBMOD does not process any cells  console=True
    ...  AND  Return From Keyword

    ${kpi_name_delta_dict_kpi5}=  Get and check KPI info from IMS file
    ...  kpi_names=kpi5  kpi_thresholds=${BBMOD_RESET_WRN_THR}  alias=${alias}  start_point_timestamp_UTC=${date_timestamp_bbmod_reset_UTC}
    ...  end_point_timestamp_UTC=${date_timestamp_cells_onair_UTC}
    ${kpi_delta_list_kpi5}=  Get From Dictionary  ${kpi_name_delta_dict_kpi5}  kpi5
    Export KPI Results to File  alias=${alias}  obj=BBMOD  obj_type=${BBMOD_prodName}_${BBMOD_sn}  obj_id=${BBMOD_id}  action_1=BBMOD_Reset
    ...  kpi_reported_1=KPI_5  event_value_1=${kpi_delta_list_kpi5[0]}  cycle=${CYCLE}  source_info=ims

Particular Teardown
    Export KPI results to File Global  kpi_log_file_name=KpiTimeInfo

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${FALSE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown

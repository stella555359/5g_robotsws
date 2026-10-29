*** Settings ***
Resource    ../../../resources/common.robot
Resource    ../../../resources/alarms.robot
Resource    ../../../resources/ald.robot
Resource    ../../../resources/netact.robot
Resource    ../../../resources/power_saving.robot
Resource    ../../../resources/L3_call.robot

Documentation
...  TEST NAME:     PS.35_CB006830_Automated_GCS_during_BBMOD_reset_via_HWRESETREQ_NA
...  AUTHORS:       jakub.hirny@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  This test resets random BBMOD with Graceful Cell Shutdown via HWRESETREQ NetAct
...  *****************
...  Pre-conditions
...  *****************
...  BTS-NetAct M-Plane connection is working
...  HWRESETREQ with Graceful Cell Shutdown NIDD adaptation is supported by SW releases on both NetAct and BTS
...  SRNCLAB with "pure trunk base"
...  NetActTrunk - NetAct - 99.23.04.0.96 (or higher)
...  ******************
...  History of changes
...  ******************
...  26.07.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-365 - TC creation
...  15.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-506 - BBMOD reset time measurement enhancement
...  08.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-520 - Add check if RMOD is connected to more than one BBMOD and adjust expectred states
...  08.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-534 - Solution for reselecting BBMOD if there is no RMOD connected to it + Test Overhaul
...  *******************
...  RAN PZ3 WRO1 TEMPLATE

*** Variables ***
${BBMOD_expected_states}=               administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled"
${RMOD_expected_states}=                administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled"
${FHS_expected_states}=                 administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled"
${BBMOD_expected_states_reset}=         administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Disabled"
${RMOD_expected_states_reset}=          administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Disabled"
${RMOD_expected_degraded}=              availabilityStatus=regex"(?i)Degraded", operationalState=regex"(?i)Enabled"
${FHS_expected_states_reset}=           administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Disabled"
${LNCEL_expected_state_reset}=            administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Disabled",
...                                     blockingState=regex"(?i)Unblocked"
${NRCEL_expected_state_reset}=             administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Disabled",
...                                     blockingState=regex"(?i)Unblocked"
${GNCEL_expected_state}=                  administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled",
...                                     blockingState=regex"(?i)Unblocked", usageState=regex"(?i)Active"
${WNCEL_expected_state}=                operationalState=regex"(?i)Enabled", blockingState=regex"(?i)Unblocked",
...                                     usageState=regex"(?i)Active"
${LNCEL_expected_state}=                  administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled",
...                                     blockingState=regex"(?i)Unblocked"
${NRCEL_expected_state}=                   administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled",
...                                     blockingState=regex"(?i)Unblocked"

*** Keywords ***
PS.35_CB006830_Automated_GCS_during_BBMOD_reset_via_HWRESETREQ_NA
    PS.35_CB006830_Automated_GCS_during_BBMOD_reset_via_HWRESETREQ_NA.Test_Step:0 Test Preparation
    PS.35_CB006830_Automated_GCS_during_BBMOD_reset_via_HWRESETREQ_NA.Test_Step:1 Delete HWRESETREQ object
    PS.35_CB006830_Automated_GCS_during_BBMOD_reset_via_HWRESETREQ_NA.Test_Step:2 Disable feature LTE914/5GC000501 flag
    PS.35_CB006830_Automated_GCS_during_BBMOD_reset_via_HWRESETREQ_NA.Test_Step:3 Resetting BBMOD
    PS.35_CB006830_Automated_GCS_during_BBMOD_reset_via_HWRESETREQ_NA.Test_Step:4 Final Checkpoint

PS.35_CB006830_Automated_GCS_during_BBMOD_reset_via_HWRESETREQ_NA.Test_Step:0 Test Preparation
    Log to console    \n========================================
    Log  Test_Step:0 Test Preparation  console=${True}
    Log to console    ========================================
    ${COUNTER_BEFORE_TEST}  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
    netact.Upload Configuration  dist_names=PLMN-PLMN/MRBTS-${MRBTS_ID}
    SCF Backup
    Get Resettable BBMODS
    FOR  ${item}  IN  @{bbmods}
        ${selected_bbmod}  Evaluate  random.choice(${bbmods})  random
        Set Test Variable  ${selected_bbmod}
        Find Radios Connected To BBMOD  ${selected_bbmod}
        ${status}  Run Keyword And Return Status  Should Not Be Empty  ${connected_radios}
        IF  not ${status}  Remove Values From List  ${bbmods}  ${selected_bbmod}
        Exit For Loop If  ${status}
    END
    Find Cells Deployed On RMOD  NL  ${connected_radios}
    ${affected_radios}  Combine Lists  ${connected_radios}
    FOR  ${item}  IN  @{connected_other_bbmods}
        Remove Values From List  ${affected_radios}  ${item}
    END
    Map HW And Cells For BBMOD Reset  ${selected_bbmod}  ${affected_radios}  ${deployed_cells}

PS.35_CB006830_Automated_GCS_during_BBMOD_reset_via_HWRESETREQ_NA.Test_Step:1 Delete HWRESETREQ object
    Log to console    \n========================================
    Log  Test_Step:1 Delete HWRESETREQ object  console=${True}
    Log to console    ========================================
    ${managed_object}=  admin.Get Managed Objects  HWRESETREQ_A
    ${status}=  Run Keyword And Return Status  Should Be Empty  ${managed_object}
    IF  not ${status}
        Remove HWRESETREQ From SCF
    ELSE
        Log  There is no HWRESETREQ object - no need to remove it.  console=${True}
    END

PS.35_CB006830_Automated_GCS_during_BBMOD_reset_via_HWRESETREQ_NA.Test_Step:2 Disable feature LTE914/5GC000501 flag
    Log to console  \n========================================
    Log  Test_Step:2 Disable feature LTE914/5GC000501 flag  console=${True}
    Log to console  ========================================
    Check which RAT are on given TestLine

    IF  '${IF_LTE_EXIST}'=='EXIST' and '${IF_NR_EXIST}'=='EXIST'
        Log to console    \n========================================
        Log  Step: 1a Disable feature LTE914 flag  console=${True}
        Log  Step: 1a Set shutdownStepAmount for LTE to 6  console=${True}
        Log  Step: 1a Set shutdownWindow for LTE to 60s  console=${True}
        Log to console    ========================================
        Set Parameters For LTE Graceful Cell Shutdown  enableGrflShdn=Disabled  shutdownStepAmount=6  shutdownWindow=60s
        Log to console    \n========================================
        Log  Step: 1b Disable feature 5GC000501 flag  console=${True}
        Log  Step: 1a Set shutdownStepAmount for NR to 6  console=${True}
        Log  Step: 1a Set shutdownWindow for NR to 60s  console=${True}
        Log to console    ========================================
        Set Parameters For NR Graceful Cell Shutdown  actGrflShdn=false  shutdownStepAmount=6  shutdownWindow=60s
    ELSE IF  '${IF_LTE_EXIST}'=='EXIST' and '${IF_NR_EXIST}'=='NO'
        Log to console    \n========================================
        Log  Step: 1a Disable feature LTE914 flag  console=${True}
        Log  Step: 1a Set shutdownStepAmount for LTE to 6  console=${True}
        Log  Step: 1a Set shutdownWindow for LTE to 60s  console=${True}
        Log to console    ========================================
        Set Parameters For LTE Graceful Cell Shutdown  enableGrflShdn=Disabled  shutdownStepAmount=6  shutdownWindow=60s
    ELSE IF  '${IF_NR_EXIST}'=='EXIST' and '${IF_LTE_EXIST}'=='NO'
        Log to console    \n========================================
        Log  Step: 1b Disable feature 5GC000501 flag  console=${True}
        Log  Step: 1a Set shutdownStepAmount for NR to 6  console=${True}
        Log  Step: 1a Set shutdownWindow for NR to 60s  console=${True}
        Log to console    ========================================
        Set Parameters For NR Graceful Cell Shutdown  actGrflShdn=false  shutdownStepAmount=6  shutdownWindow=60s
    END

PS.35_CB006830_Automated_GCS_during_BBMOD_reset_via_HWRESETREQ_NA.Test_Step:3 Resetting BBMOD
    Log to console  \n========================================
    Log  Test_Step:3 Resetting BBMOD: ${selected_bbmod}  console=${True}
    Log to console  ========================================
    Allow Fault In Watchdog  faultID=6134  #EN DSS De-activated on partner side'
    Set Target HW To Reset With GCS Under HWRESETREQ Via NA  ${selected_bbmod}  gracefulCellShutdown  true
    ${reset_start_time}  Get Current Date
    IF  ${GCS_value}
        Log  \n \n===== Checking HW and cells state before reset with GCS =====  console=${True}
        Check Not Affected By BBMOD Reset
        Check Affected By BBMOD Reset  before
        Log  \n \n===== Waiting for GCS to check HW and cells state during reset =====  console=${True}
        Wait Until Keyword Succeeds  4x  20s  Check Affected By BBMOD Reset  during
        Check Not Affected By BBMOD Reset
    ELSE
        Log  \n \n===== Checking HW and cells state during BBMOD reset =====  console=${True}
        Check Not Affected By BBMOD Reset
        Check Affected By BBMOD Reset  during
    END
    Check For BBMOD Reset Message In Syslog  start
    Log  \n \n===== Waiting for reset to finish =====  console=${True}
    Check For BBMOD Reset Message In Syslog  finish
    ${reset_end_time}  Get Current Date
    ${reset_time}  Subtract Date From Date  ${reset_end_time}  ${reset_start_time}
    Wait Until Keyword Succeeds  20x  15s  Check For Object  HWRESETRES_R
    IF  '${object_parameters[0]['parameters']['hwResetResult']}'=='success'
        Log To Console  Reset is done and it took ${reset_time}
    ELSE
        Fail  msg=BBMOD reset not successful
    END
    Should Be True  ${reset_time}<250  #OM_GEN_SFS_PERF_CAP.26568 + 60s of shutdownWindow
    Check If NLWG Cells Are OnAir
    Disallow Fault In Watchdog  faultID=6134  #EN DSS De-activated on partner side'

PS.35_CB006830_Automated_GCS_during_BBMOD_reset_via_HWRESETREQ_NA.Test_Step:4 Final Checkpoint
    Log to console  \n========================================
    Log  Test_Step:4 Final Checkpoint  console=${True}
    Log to console  ========================================
    ${COUNTER_AFTER_TEST}  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
    Run Keywords
    ...  Check SMODs State  ${SMOD_expected_states}
	...  AND  Check RMODs State  ${RMOD_expected_states}
	...  AND  Check If ALDs Are Connected And Achieved Expected State
	...  AND  common.Check BTS State  ${BTS_expected_states}
	...  AND  Check If NLWG Cells Are OnAir
	...  AND  Check If Unexpected Alarms Are Raised  ${skip_fault}

PS.35_CB006830_Automated_GCS_during_BBMOD_reset_via_HWRESETREQ_NA.Test Case Teardown
    Remove HWRESETREQ From SCF
    Run Keywords  common.Common Test Teardown  AND  Teardown TAF Netact

Get Resettable BBMODS
    ${bbmods_parameters}  admin.Get Managed Objects  BBMOD_R
    ${managed_bbmod_l}  admin.Get Managed Objects  BBMOD_L
    ${bbmods}  Create List
    ${bbmods_invalid}  Create List
    ${bbmods_configuration}  Create List
    ${bbmods_mapping}  Create Dictionary
    FOR  ${bbmod}  IN  @{bbmods_parameters}
        ${bbmod_type_invalid}  Run Keyword And Return Status  Should Contain Any  '${bbmod['parameters']['productName']}'  FBBC
        IF  '${bbmod['parameters']['geranSupport']}'=='True' or '${bbmod['parameters']['utranSupport']}'=='True' or ${bbmod_type_invalid}
            Append To List  ${bbmods_invalid}  ${bbmod['distName']}
        END
    END
    ${bts_info}  admin.get bts info
    FOR  ${item}  IN  @{bts_info['basebandModules']}
        ${BTS_ID_remove}  Remove String  ${item['id']['runtime']}  MRBTS-${MRBTS_ID}
        ${bbmods_invalid_full}  Run Keyword And Return Status  Should Contain Any  '${bbmods_invalid}'  ${BTS_ID_remove}
        IF  ${bbmods_invalid_full}
            Set To Dictionary  ${bbmods_mapping}  ${item['serialNumber']}  ${item['id']['configuration']}
        ELSE
            Append To List  ${bbmods}  ${item['id']['configuration']}
            Set To Dictionary  ${bbmods_mapping}  ${item['serialNumber']}  ${item['id']['configuration']}
        END
    END
    #Create dictionary mapping of baseband modules (BBMOD-x with BBMOD_L-x and BBMOD_L-x with BBMOD-x)
    FOR  ${item}  IN  @{managed_bbmod_l}
        ${from_dict}  Get From Dictionary  ${bbmods_mapping}  ${item['parameters']['serialNumber']}
        Set To Dictionary  ${bbmods_mapping}  ${item['distName']}  ${from_dict}
        Set To Dictionary  ${bbmods_mapping}  ${from_dict}  ${item['distName']}
    END
    ${bbmods_empty}  Run Keyword And Return Status  Should Be Empty  ${bbmods}
    Set Test Variable  ${bbmods_mapping}
    IF  ${bbmods_empty}
        Fail  msg=There are no resettable BBMODs in configuration. Skipping test.
    ELSE
        Set Test Variable  ${bbmods}
    END

Set Target HW To Reset With GCS Under HWRESETREQ Via NA
    [Documentation]  Keyword setting indicated object to reset under HWRESETREQ object Via NA
    ...  Example of usage:
    ...  Set Target HW To Reset With GCS Under HWRESETREQ Via NA  .../BBMOD-6  gracefulCellShutdown  true  ${RESULTS}/SCF_UPDATE.xml
    [Arguments]  ${target}  ${feature}  ${value}  ${SCF_PATH}=${RESULTS}/SCF_BACKUP.xml
    ${GCS_value}  Run Keyword And Return Status  Should Be True  '${feature}'=='gracefulCellShutdown' and '${value}'=='true'
    Set Test Variable  ${GCS_value}
    ${current_date}  DateTime.Get Current Date  result_format=%d%m%Y%H%M%S  exclude_millis=True
    ${CMD_DN}  Set Variable  MRBTS-${MRBTS_ID}/MNL-1/CMD-1
    ${managed_object}  admin.Get Managed Objects  HWRESETREQ_A
    ${status}  Run Keyword And Return Status  Should Be Empty  ${managed_object}
    ${meta_ver}  Get Meta Version Or Class From SCFC  ${SCF_PATH}  ${CMD_DN}  version
    ${meta_class}  Get Meta Version Or Class From SCFC  ${SCF_PATH}  ${CMD_DN}  class
    ${meta_class_hwresetreq}  Get Meta Version Or Class From SCFC  ${SCF_PATH}  ${CMD_DN}/HWRESETREQ-1  class
    IF  ${status}
        Replace Class String In Meta Class  ${meta_class}  CMD  HWRESETREQ
    ELSE
        Set Test Variable  ${meta_class}  ${meta_class_hwresetreq}
    END
    ${delta}  Set Variable  MRBTS-${MRBTS_ID}_Plan_${feature}
    Run Keyword And Ignore Error  netact.delete plan  ${delta}
    ${plan}  netact.create plan configuration  name=${delta}  description=Automation WRO1 for MRBTS-${MRBTS_ID}_Plan_${feature}
    ${managed_objects}  netact.create managed object  plan=${plan}  meta_class=${meta_class}
    ...  meta_version=${meta_ver}  mo_id=PLMN-PLMN/${CMD_DN}/HWRESETREQ-1  operation=CREATE
    ...  targetHwResetUDN=${target}  hwResetComment=${current_date}  ${feature}=${value}
    Log To Console  Plan provisioning via NetAct requesting ${target} to reset with ${feature} set as ${value}
    netact.provision plan  MRBTS-${MRBTS_ID}_Plan_${feature}  dist_names=PLMN-PLMN/MRBTS-${MRBTS_ID}  create_backup_plan=true
    ...  backup_plan_name=${MRBTS_ID}_${current_date}_backup

Replace Class String In Meta Class
    [Documentation]  Keyword replacing object class fetched with 'Get Meta Version Or Class From SCFC' keyword
    ...              Example of usage:
    ...              Replace Class String In Meta Class  ${meta_class}  CMD  HWRESETREQ
    [Arguments]  ${meta_class}  ${search_for}  ${replace_with}
    FOR  ${class}  IN  ${meta_class}
        ${replace_class}  Replace String  ${meta_class}  ${search_for}  ${replace_with}
        Set Test Variable  ${meta_class}  ${replace_class}
    END

Remove HWRESETREQ From SCF
    Log  \n ===== Removing HWRESETREQ object from configuration =====  console=${True}
    ${HWRESETREQ_DN}  Set Variable  MRBTS-${MRBTS_ID}/MNL-1/CMD-1/HWRESETREQ-1
    ${pre_action_reset_number}  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
    ${delta_remove}  Set Variable    SCF_REMOVE
    admin.create delta  ${delta_remove}
    admin.append managed object to delta  ${HWRESETREQ_DN}  delete  ${delta_remove}
    admin.get delta  ${delta_remove}
    ${json_path}  Set Variable  ${RESULTS}/${delta_remove}.json
    admin.save delta  ${json_path}  delta_id=${delta_remove}
    admin.perform delta recommissioning  ${json_path}  ${skip_parameter_relation_errors}
    ${post_action_reset_number}  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
    Log  Reset counter after applying delta: ${post_action_reset_number}  console=${True}
    ${counter_diff}  Evaluate  abs(${pre_action_reset_number} - ${post_action_reset_number})
    IF  ${counter_diff}!=${0}  Fail  msg=Detected unexpected BTS reset
    ${managed_object}  admin.Get Managed Objects  HWRESETREQ_A
    ${status}  Run Keyword And Return Status  Should Be Empty  ${managed_object}
    IF  ${status}
        Log To Console  HWRESETREQ was removed properly from commissioning.
    ELSE
        Fail  msg=HWRESETREQ was not removed.
    END

Check For Object
    [Documentation]  Keyword checks for given managed object and, if it exists, sets variable with its parameters.
    ...              Example of usage:
    ...              Check For Object  HWRESETRES_R
    [Arguments]  ${object}
    ${item}  admin.Get Managed Objects  ${object}
    ${status}  Should Not Be Empty  ${item}
    IF  '${status}'=='None'
        Set Test Variable  ${object_parameters}  ${item}
    ELSE
        Log  Object ${object} was not found.  console=${True}
    END

Find Radios Connected To BBMOD
    [Documentation]  Keyword checks for radios connected to given BBMOD and adds them to a list ${connected_radios}.
    ...              Example of usage:
    ...              Find Radios Connected To BBMOD  ${selected_bbmod}
    [Arguments]  ${object}
    ${bts_info}  admin.Get BTS Info
    ${connected_radios}  Create List
    ${connected_fhs}  Create List
    FOR  ${item}  IN  @{bts_info['cables']}
        ${matched_connection}  Run Keyword And Return Status  Should Contain  '${item['firstEndPointId']['configuration']}'  ${object}
        ${matched_fhs}  Run Keyword And Return Status  Should Contain  '${item['secondEndPointId']['configuration']}'  FHS
        ${distName}  ${ignore}  Split String From Right  ${item['secondEndPointId']['configuration']}  separator=/  max_split=1
        IF  ${matched_connection} and not ${matched_fhs}  Append To List  ${connected_radios}  ${distName}
        IF  ${matched_connection} and ${matched_fhs}  Append To List  ${connected_fhs}  ${distName}
    END
    Set Test Variable  ${connected_fhs}
    FOR  ${item}  IN  @{bts_info['cables']}
        ${matched_first}   Run Keyword And Return Status  Should Contain Any  '${item['firstEndPointId']['configuration']}'  @{connected_fhs}
        ${matched_second}  Run Keyword And Return Status  Should Contain  '${item['secondEndPointId']['configuration']}'  RMOD
        ${string}  ${ignore}  Split String From Right  ${item['firstEndPointId']['configuration']}  separator=/  max_split=1
        ${distName}  ${ignore}  Split String From Right  ${item['secondEndPointId']['configuration']}  separator=/  max_split=1
        IF  ${matched_first} and ${matched_second}
            Append To List  ${connected_radios}  ${distName}
        ELSE IF  ${matched_first} and not ${matched_second}
            Log To Console  There are no radios connected to ${string}.
        END
    END
    Set Test Variable  ${connected_radios}
    ${connected_other_bbmods}  Create List
    FOR  ${item}  IN  @{bts_info['cables']}
        ${is_not_fhs}  Run Keyword And Return Status  Should Not Contain  '${item['firstEndPointId']['configuration']}'  FHS
        ${matched_connection}  Run Keyword And Return Status  Should Not Contain  '${item['firstEndPointId']['configuration']}'  ${object}
        ${matched_radios}      Run Keyword And Return Status  Should Contain Any  '${item['secondEndPointId']['configuration']}'  @{connected_radios}
        ${distName}  ${ignore}  Split String From Right  ${item['secondEndPointId']['configuration']}  separator=/  max_split=1
        IF  ${matched_connection} and ${matched_radios} and ${is_not_fhs}  Append To List  ${connected_other_bbmods}  ${distName}
    END
    Set Test Variable  ${connected_other_bbmods}

Find Cells Deployed On RMOD
    [Documentation]  Keyword checks for cells of specified RAT deployed on given RMOD/s and adds them to a list ${deployed_cells}.
    ...              Example of usage:
    ...              Find Cells Deployed On RMOD  NLWG  ${connected_radios}
    [Arguments]  ${technology}  ${object}
    ${bts_info}  admin.Get BTS Info
    ${deployed_cells}  Create List
    ${deployed_cells_mapping}  Create Dictionary
    ${status_lte}    Run Keyword And Return Status  Should Contain  ${technology}  L  ignore_case=${True}
    ${status_nr}     Run Keyword And Return Status  Should Contain  ${technology}  N  ignore_case=${True}
    ${status_wcdma}  Run Keyword And Return Status  Should Contain  ${technology}  W  ignore_case=${True}
    ${status_gsm}    Run Keyword And Return Status  Should Contain  ${technology}  G  ignore_case=${True}
    ${selected_technology_cells}  Create List
    FOR  ${item}  IN  @{bts_info['cells']}
        Continue For Loop If  not ${status_${item}}
        ${selected_technology_cells}  Combine Lists  ${selected_technology_cells}  ${bts_info['cells']['${item}']}
    END
    ${carrierlist_items}  Create List
    FOR  ${item}  IN  @{selected_technology_cells}
        ${carrierlist_items}  Combine Lists  ${carrierlist_items}  ${item['carrierList']}
    END
    FOR  ${item}  IN  @{carrierlist_items}
        ${status}  Run Keyword And Return Status
        ...  Should Contain Any  ${item['antennaLineId']['configuration']}  @{object}
        Continue For Loop If  not ${status}
        ${config_id}  ${ignore}  Split String From Right  ${item['id']['configuration']}  separator=/  max_split=1
        ${unique_cell}  Run Keyword And Return Status  List Should Not Contain Value  ${deployed_cells}  ${config_id}
        Continue For Loop If  not ${unique_cell}
        ${bbmod_l_from_path}  Get BBMOD_L From Cell Path  ${item['id']['internal']}
        ${from_dict}  Get From Dictionary  ${bbmods_mapping}  ${bbmod_l_from_path}
        Set To Dictionary  ${deployed_cells_mapping}  ${config_id}  ${from_dict}
        Append To List  ${deployed_cells}  ${config_id}
    END
    IF  ${deployed_cells}!=[]
        Set Test Variable  ${deployed_cells}
        Set Test Variable  ${deployed_cells_mapping}
    ELSE
        Fail  msg=There are no cells deployed on ${object}
    END

Map HW And Cells For BBMOD Reset
    [Documentation]  Keyword creates dictionaries with mappings of HW (${affected_hw}, ${affected_radios_degraded}) and
    ...              cells (${affected_cells}) that will be affected by BBMOD reset and HW (${not_affected_hw}) and
    ...              cells (${not_affected_cells}) that should not be affected by BBMOD reset.
    ...              Example of usage:
    ...              Map HW And Cells For BBMOD Reset  ${selected_bbmod}  ${affected_radios}  ${deployed_cells}
    [Arguments]  ${bbmod}  ${rmods}  ${cells}
    ${affected_hw}  Create Dictionary
    ${not_affected_hw}  Create Dictionary
    ${not_affected_cells}  Create Dictionary
    ${affected_cells}  Create Dictionary
    ${bts_info}  admin.Get BTS Info
    ${cells_list}  Combine Lists  ${bts_info['cells']['nr']}
    ...                           ${bts_info['cells']['lte']}
    ...                           ${bts_info['cells']['wcdma']}
    ...                           ${bts_info['cells']['gsm']}
    FOR  ${item}  IN  @{bts_info['basebandModules']}
        ${status}  Run Keyword And Return Status  Should Not Contain Any  '${item['id']['configuration']}'  ${bbmod}
        IF  ${status}
            Set To Dictionary  ${not_affected_hw}  ${item['id']['configuration']}  ${item['id']['internal']}
        ELSE
            Set To Dictionary  ${affected_hw}  ${item['id']['configuration']}  ${item['id']['internal']}
        END
    END
    FOR  ${item}  IN  @{bts_info['fhs']}
        ${status}  Run Keyword And Return Status  Should Contain Any  '${item['id']['configuration']}'  @{connected_fhs}
        IF  ${status}
            Set To Dictionary  ${affected_hw}  ${item['id']['configuration']}  ${item['id']['internal']}
        ELSE
            Set To Dictionary  ${not_affected_hw}  ${item['id']['configuration']}  ${item['id']['internal']}
        END
    END
    ${affected_radios_degraded}  Create Dictionary
    FOR  ${item}  IN  @{bts_info['radioModules']['rmod']}
        ${status}  Run Keyword And Return Status  Should Not Contain Any  '${item['id']['configuration']}'  @{rmods}
        ${will_be_degraded}  Run Keyword And Return Status  Should Contain Any  '${item['id']['configuration']}'  @{connected_other_bbmods}
        IF  ${status} and not ${will_be_degraded}
            Set To Dictionary  ${not_affected_hw}  ${item['id']['configuration']}  ${item['id']['internal']}
        ELSE IF  ${status} and ${will_be_degraded}
            Set To Dictionary  ${affected_radios_degraded}  ${item['id']['configuration']}  ${item['id']['internal']}
        ELSE
            Set To Dictionary  ${affected_hw}  ${item['id']['configuration']}  ${item['id']['internal']}
        END
    END
    Set Test Variable  ${affected_radios_degraded}
    FOR  ${cell}  IN  @{cells}
        ${from_dict}  Get From Dictionary  ${deployed_cells_mapping}  ${cell}
        ${status}  Run Keyword And Return Status  Should Not Contain  ${from_dict}  ${selected_bbmod}
        IF  ${status}  Remove Values From List  ${cells}  ${cell}
    END
    FOR  ${item}  IN  @{cells_list}
        ${status}  Run Keyword And Return Status  Should Not Contain Any  '${item['id']['configuration']}'  @{cells}
        IF  ${status}
            Set To Dictionary  ${not_affected_cells}  ${item['id']['configuration']}  ${item['id']['internal']}
        ELSE
            Set To Dictionary  ${affected_cells}      ${item['id']['configuration']}  ${item['id']['internal']}
        END
    END
    Set Test Variable  ${not_affected_cells}
    Set Test Variable  ${affected_cells}
    Set Test Variable  ${affected_hw}
    Set Test Variable  ${not_affected_hw}

Check Affected By BBMOD Reset
    [Documentation]  Keyword checks states of HW and cells affected by BBMOD reset
    ...              with possibility to indicate when those checks will be performed: before/during/after
    ...              Example of usage:
    ...              Check Affected By BBMOD Reset  during
    [Arguments]  ${when}=before
    ${before_or_after}  Run Keyword And Return Status  Should Contain Any  ${when}  before  after
    FOR  ${item}  IN  @{affected_hw}
    ${string}  Fetch From Right  ${item}  marker=/  #getting hw from configuration, eg. RMOD-1 or BBMOD-3
    ${hw_type}  Fetch From Left  ${string}  marker=-
    ${hw_id}  Get From Dictionary  ${affected_hw}  ${item}
      IF  ${before_or_after}
        ${status}  Run Keyword And Return Status
        ...  Wait Until Keyword Succeeds  1x  1s  admin.Assert  ${hw_type}  ${hw_id}  ${${hw_type}_expected_states}
      ELSE
        ${status}  Run Keyword And Return Status
        ...  Wait Until Keyword Succeeds  1x  1s  admin.Assert  ${hw_type}  ${hw_id}  ${${hw_type}_expected_states_reset}
      END
      IF  ${status}
        Log To Console  ${item} has expected state.
      ELSE
        Fail  msg=${item} has unexpected state.
      END
    END
    FOR  ${item}  IN  @{affected_radios_degraded}
    ${string}  Fetch From Right  ${item}  marker=/  #getting hw from configuration, eg. RMOD-1 or BBMOD-3
    ${hw_type}  Fetch From Left  ${string}  marker=-
    ${hw_id}  Get From Dictionary  ${affected_radios_degraded}  ${item}
      IF  ${before_or_after}
        ${status}  Run Keyword And Return Status
        ...  Wait Until Keyword Succeeds  1x  1s  admin.Assert  ${hw_type}  ${hw_id}  ${${hw_type}_expected_states}
      ELSE
        ${status}  Run Keyword And Return Status
        ...   Wait Until Keyword Succeeds  1x  1s  admin.Assert  ${hw_type}  ${hw_id}  ${${hw_type}_expected_degraded}
      END
      IF  ${status}
        Log To Console  ${item} has expected state.
      ELSE
        Fail  msg=${item} has unexpected state.
      END
    END
    FOR  ${item}  IN  @{affected_cells}
        ${cell_to_check}  Get From Dictionary  ${affected_cells}  ${item}
        ${string}  Fetch From Right  ${item}  marker=/  #getting cell from configuration, eg. LNCEL-1 or NRCELL-3
        ${cell_type}  Get Substring  ${string}  start=0  end=5
        IF  ${before_or_after}
            ${cell_status}  Run Keyword And Return Status
            ...  Wait Until Keyword Succeeds  1x  1s  admin.Assert  ${cell_type}  ${cell_to_check}  ${${cell_type}_expected_state}
        ELSE
            ${cell_status}  Run Keyword And Return Status
            ...  Wait Until Keyword Succeeds  1x  1s  admin.Assert  ${cell_type}  ${cell_to_check}  ${${cell_type}_expected_state_reset}
        END
        IF  ${cell_status}
            Log To Console  ${item} has expected state.
        ELSE
            Fail  msg=${item} has unexpected state.
        END
    END

Check Not Affected By BBMOD Reset
    [Documentation]  Keyword checks states of HW and cells not affected by BBMOD reset
    FOR  ${item}  IN  @{not_affected_cells}
        ${cell_to_check}  Get From Dictionary  ${not_affected_cells}  ${item}
        ${string}  Fetch From Right  ${item}  marker=/  #getting cell from configuration, eg. LNCEL-1 or NRCELL-3
        ${cell_type}  Get Substring  ${string}  start=0  end=5
        ${cell_status}  Run Keyword And Return Status
        ...  Wait Until Keyword Succeeds  1x  1s  admin.Assert  ${cell_type}  ${cell_to_check}  ${${cell_type}_expected_state}
        IF  ${cell_status}
            Log To Console  ${item} has expected state.
        ELSE
            Fail  msg=${item} has unexpected state.
        END
    END
    FOR  ${item}  IN  @{not_affected_hw}
        ${string}  Fetch From Right  ${item}  marker=/  #getting hw from configuration, eg. RMOD-1 or BBMOD-3
        ${hw_type}  Fetch From Left  ${string}  marker=-
        ${hw_id}  Get From Dictionary  ${not_affected_hw}  ${item}
        ${status}  Run Keyword And Return Status
        ...  Wait Until Keyword Succeeds  1x  1s  admin.Assert  ${hw_type}  ${hw_id}  ${${hw_type}_expected_states}
        IF  ${status}
            Log To Console  ${item} has expected state.
        ELSE
            Fail  msg=${item} has unexpected state.
        END
    END

Check For BBMOD Reset Message In Syslog
    [Arguments]  ${start_or_finish}
    ${from_dict_bbmod_l}  Get From Dictionary  ${bbmods_mapping}  ${selected_bbmod}
    ${ignore}  ${string}  Split String From Right  ${from_dict_bbmod_l}  separator=/  max_split=1
    ${timeout}  Set Variable If  '${start_or_finish}'=='finish'  200  90
    ${message}  Set Variable If  '${start_or_finish}'=='finish'  ${string}.*RESET_TASK.*Finished with status: Succeeded
    ...    Reset called for.*${string}.*RESET_TASK
    ${in_syslog}  Run Keyword And Ignore Error
    ...    ute_syslog.Wait For Message In Syslog File  regexp=${message}  alias=ute_syslog  timeout=${timeout}
    IF  '${in_syslog[0]}'=='PASS'
        Log  Reset ${start_or_finish} message was found in syslog: ${in_syslog[1]}
    ELSE
        Log  There was some issue with finding reset ${start_or_finish} message in syslog  WARN
    END

Get BBMOD_L From Cell Path
  [Arguments]  ${channel_m_path}
  ${managed_path}  Get Managed Objects  PATH
  FOR  ${item}  IN  @{managed_path}
      ${status}  Run Keyword And Return Status  Should Contain  ${item['distName']}  ${channel_m_path}
      ${path_parameters}  Set Variable  ${item['parameters']}
      Exit For Loop If  ${status}
  END
  ${processingDeviceDNs_list}  Get From Dictionary  ${path_parameters}  processingDeviceDNs
  FOR  ${item}  IN  @{processingDeviceDNs_list}
      ${status}  Run Keyword And Return Status  Should Contain  ${item}  BBMOD_L
      ${bbu_status}  Run Keyword And Return Status  Should Contain  ${item}  BBU_L
      ${board_status}  Run Keyword And Return Status  Should Contain  ${item}  BOARD_L
      IF  ${bbu_status}
          ${bbmod_l_from_path}  Remove String Using Regexp  ${item}  /BBU_L.*
      ELSE IF  ${board_status}
          ${bbmod_l_from_path}  Remove String Using Regexp  ${item}  /BOARD_L.*
      END
      Exit For Loop If  ${status}
  END
  RETURN  ${bbmod_l_from_path}

*** Settings ***
Documentation
    ...  This test case was created to imitate seconday core hot remove/ hot insert scenario.
    ...  Fault 4352 occurence and recovery action after hot insert will be checked apperance
    ...  Faults 10 suppresion will be also checked

Library  ute_async
Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${RECOVERY_TIMEOUT}  360  # Timeout for SBTS to recover after SC hot insert
${STARTUP_TIMEOUT}  600  # Timeout for SBTS to recover after startup


*** Keywords ***
TC__FM__SC_hot_remove_hot_insert
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-10142
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  08.04.2019 - https://jira3.int.net.nokia.com/browse/TAT-10243 - Initial TAT creation
    ...  23.09.2019 - https://jira3.int.net.nokia.com/browse/TAT-17587 - Reset counters clearance before hot removal for AS+F platform
    ...  12.07.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21215 - Update FM testcases accordingly with CNI-64164
    ...  24.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  10.01.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22451 - Fix for path to _A object
    ...  17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  26.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27704 - Add option to skip RMOD power check
    ...  29.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28007 - Add keyword perform site reset
    ...  26.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29236 - Add support for SBTS25R3 and higher - verify fault 4670
    ...  25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29190 - Enhancement of all test cases in regression to check fault signature
    ...  25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29459 - Enhancement of all test cases in regression to check FS component field
    ...  08.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28933 - Verify supplAlarmInfo
    ...  22.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29908 - Increase Alarm timeout
    ...  03.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30108 - Check that Fid 4352 is cleared in Mantaray
    ...  *******************

    Set Tags  CA-FM  OWNER-laura.craciunel@nokia.com  AUTHOR-rafal.ozga@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf
    ...  PHASE-CRT  SW-SBTS17A  FEATURE-RP0011621  FEATURE-RP001498

    Step1: Check All Required States
    Step2: Secondary Core Hot Remove
    Step3: Secondary Core Hot Insert


Step1: Check All Required States
    [Documentation]  In this step specific states will be checked.

    Log  \nStep1: Check all required states.  console=true
    ${start_time}  Get Current Date  time_zone=UTC  result_format=datetime
    Set Test Variable  ${START_TIME}
    Check If Configuration Is Dual Core
    ${is_as+f}  Check If Configuration Is AS+F
    IF  ${is_as+f}  Perform Site Reset
    Get Secondary Core Serial Number
    Set Variables For Fault Signature
    ${affected_r_ms_connected_to_sc}  Get List Of RMs Connected To Secondary Core
    Set Test Variable  ${AFFECTED_R_MS_CONNECTED_TO_SC}

    ${all_rmods_power_before_reco_reset}  Create Dictionary
    Set Test Variable  ${ALL_RMODS_POWER_BEFORE_RECO_RESET}
    ${all_rmods_power_after_reco_reset}  Create Dictionary
    Set Test Variable  ${ALL_RMODS_POWER_AFTER_RECO_RESET}
    Get All Tx Power From All RMs  ${ALL_RMODS_POWER_BEFORE_RECO_RESET}
    ${bts_name}  Infomodel Get Objects Parameter  //MRBTS_A-*  btsName
    ${mrbts}  Infomodel Get Objects Parameter  /MRBTS-1/RAT-1/BTS_L-1  btsId
    ${smod_r}  Query Infomodel  get object //SMOD_R-* is [serialNumber=${SERIAL_NUMBER}]  timeout=60
    ${conf_a_str}  Remove String  ${smod_r.configDN}  _A
    ${string}  Fetch From Right  ${conf_a_str}  /MRBTS-${mrbts[0]}/
    Set Test Variable  ${CONF_OBJ}  [${bts_name[0]}] MRBTS-${mrbts[0]}/${string}
    ${rnc_infomodel}  Query Infomodel  get object //RAT-*/WTS-*/RNC-*
    ${wbts_infomodel}  Query Infomodel  get object //RAT-*/WTS-*/RNC-*/WBTS-*
    ${rnc_id}  Fetch From Right  ${rnc_infomodel}[dist_name]  RNC-
    ${wbts_id}  Fetch From Right  ${wbts_infomodel}[dist_name]  WBTS-
    Set Test Variable  ${RNC_ID}
    Set Test Variable  ${WBTS_ID}


Step2: Secondary Core Hot Remove
    [Documentation]  In this step secondary core will be hot removed.

    Log  \nStep2: Hot remove of secondary core.  console=true
    Pdu Bts Interface Off  SMOD_${SERIAL_NUMBER}
    Log  Secondary core has been successfully hot removed. [OK]  console=true
    Setup Admin  bts_host=192.168.255.129  bts_port=443  use_ssl=True  alias=fault
    ${fault_2nd_core_auto_reset_params}  Get String With Alarm Parameters  ${FAULT_4352_2_ND_CORE_AUTO_RST}
    ${fault_2nd_core_auto_reset_params}  Catenate  ${fault_2nd_core_auto_reset_params},  alarmingResource=${SMOD_RUNTIME_DIST_NAME}
    ${fault_status}  Run Keyword In Background  Assert Alarm Active  parameters=${fault_2nd_core_auto_reset_params}  timeout=120  alias=fault
    Sleep  120s
    ${status_fault}  Run Keyword And Return Status  Collect Keyword Result  ${fault_status}  timeout=120
    IF  ${status_fault}
      Log  Fault 4352 with alarmId 7101 on alarmingResource=${SMOD_RUNTIME_DIST_NAME} appeared. [OK]  console=true
    ELSE
      Set Test Restriction  Fault 4352 with alarmId 7101 and name "${FAULT_4352_2_ND_CORE_AUTO_RST}[fault_name]" didn't occur. [NOK]
    END

    ${fault_cores_not_conn_params}  Get String With Alarm Parameters  ${FAULT_4352_CORES_NOT_CONN}
    ${fault_cores_not_conn_params}  Catenate  ${fault_cores_not_conn_params},  alarmingResource=${SMOD_RUNTIME_DIST_NAME}
    ${fault_status_with_alaram7116}  Run Keyword And Return Status  Assert Alarm Active  parameters=${fault_cores_not_conn_params}  timeout=120
    IF  ${fault_status_with_alaram7116}
      Log  Fault 4352 "${FAULT_4352_CORES_NOT_CONN}[fault_name]" on alarmingResource=${SMOD_RUNTIME_DIST_NAME} appeared.[OK]  console=true
    ELSE
      Pdu Bts Interface On  SMOD_${SERIAL_NUMBER}
      Fail  Fault 4352 "${FAULT_4352_CORES_NOT_CONN}[fault_name]" is not visible after SC hot remove crash. [NOK]
    END
    ${config_object_check}  Run Keyword And Return Status  Assert Alarm Active  parameters=faultId=4352, configObjectName="${CONF_OBJ}"  timeout=60
    IF  ${config_object_check}
      Log  Configuration alarming object in alarm is filled correctly : configObjectName="${CONF_OBJ}".  console=true
    ELSE
      Set Test Restriction  Configuration alarming object field in alarm is incorrect. [NOK]
    END

    Run Keyword And Continue On Failure  Teardown Admin  alias=fault
    IF  '${SECONDARY_CORE_MODULE_TYPE}' == 'AirScale'  Recovery Over Backplane Check
    FOR  ${rmod}  IN  @{AFFECTED_R_MS_CONNECTED_TO_SC}
        ${present}  Run Keyword And Return Status  Assert Alarm Active  parameters=faultId=10, alarmingResource=${rmod.id}  timeout=60
        IF  not ${present}  Set Test Restriction  Expected fault 10 with alarmingResource ${rmod.id} did not occur.
    END
    Check System Secondary Core Status


Step3: Secondary Core Hot Insert
    [Documentation]  In this step secondary core will be hot inserted.

    Log  \nStep3: Hot insert of secondary core.  console=true
    Pdu Bts Interface On  SMOD_${SERIAL_NUMBER}
    Log  Secondary core has been successfully hot inserted. [OK]  console=true
    IF  ${SCF_COUNT_WCDMA} and '${ENB_BRANCH}' >= 'SBTS25R3'
        ${suppl_alarm_info}  Catenate  BTS secondary core is enabled, or, un-commissioned BBMOD detected at BTS start-up is commissioned at runtime
        ...  or BBMOD is reset at runtime. To use the affected resources and setup disabled WCDMA cell(s), the WCDMA RAT Reset is needed.
        ${fid_4670_params}  Get String With Alarm Parameters  ${FAULT_4670}
        ${fid_4670_params}  Catenate  ${fid_4670_params},  supplAlarmInfo="${suppl_alarm_info}"
        Assert Alarm Active  parameters=${fid_4670_params}  timeout=990
        Log  Fault ${FAULT_4670} is visible in WebEM.  console=true
    END
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT} sec  65 sec  Check All Cells
    Get All Tx Power From All RMs  ${ALL_RMODS_POWER_AFTER_RECO_RESET}
    Compare TXs  ${ALL_RMODS_POWER_AFTER_RECO_RESET}  ${ALL_RMODS_POWER_BEFORE_RECO_RESET}

    ${alarm7101_recovery_status}  Run Keyword And Return Status
    ...  Assert Alarm Inactive  faultName="BTS secondary core autonomous reset as recovery action", alarmId=7101, faultId=4352
    IF  ${alarm7101_recovery_status}
      Log  Alarm "7101 BTS secondary core autonomous reset as recovery action" is not visible after recovery action. [OK]  console=true
    ELSE
      Fail  msg=Alarm "7101 BTS secondary core autonomous reset as recovery action" is visible after recovery action. [NOK]
    END
    ${alarm7116_recovery_status}  Run Keyword And Return Status
    ...  Assert Alarm Inactive  faultName="No connection between primary and BTS extension system module", alarmId=7116, faultId=4352
    IF  ${alarm7116_recovery_status}
      Log  Alarm "7116 No connection between primary and BTS extension system module" is not visible after recovery action [OK]  console=true
    ELSE
      Fail  msg=Alarm "7116 No connection between primary and BTS extension system module" is visible after recovery action [NOK]
    END
    Wait Until Keyword Succeeds  180s  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_4352_2_ND_CORE_AUTO_RST}
    ...                                                                               time_from=${START_TIME}
    Wait Until Keyword Succeeds  180s  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_4352_CORES_NOT_CONN}
    ...                                                                               time_from=${START_TIME}

    Admin Check Active Alarms TAF
    IF  ${SCF_COUNT_WCDMA} and '${ENB_BRANCH}' >= 'SBTS25R3'
        ${suppl_alarm_info}  Catenate  BTS secondary core is enabled, or, un-commissioned BBMOD detected at BTS start-up is commissioned at runtime
        ...  or BBMOD is reset at runtime\\. To use the affected resources and setup disabled WCDMA cell\\(s\\), the WCDMA RAT Reset is needed\\.
        Wait Until Keyword Succeeds  180s  10s
        ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_4670}
        ...                                                                               time_from=${START_TIME}
        ...                                                                               dist_name=PLMN-PLMN/RNC-${RNC_ID}/WBTS-${WBTS_ID}
        ...                                                                               suppl_info=${suppl_alarm_info}
        Log  Fault ${FAULT_4670} reported and cleared from WebEM and Netact.  console=true
    END
    Log  Check fault signature.  console=true
    Check Fault Signature Of Alarm In WebEM  fault_id=${FAULT_4590}[fault_id]  category=${CATEGORY}  info=${INFO}  load_name=${SW_VERSION}
    ...  reset_counter=${RESET_COUNTER}  scope=${SCOPE}  full_product_name=${PRODUCT_NAME}  serial_number=${SERIAL_NUMBER}
    ...  unit_position=${UNIT_POSITION}  core_unit_position=${CORE_UNIT_POSITION}
    Check Fault Signature Of Alarm In Netact  fault_id=${FAULT_4590}[fault_id]  time_from=${START_TIME}  category=CATEGORY:${SPACE}${CATEGORY}
    ...  info=INFO:${SPACE}${INFO}  load_name=LOAD_NAME:${SPACE}${SW_VERSION}  reset_counter=RESET_COUNTER:${SPACE}${RESET_COUNTER}
    ...  scope=SCOPE:${SPACE}${SCOPE}  full_product_name=${PRODUCT_NAME}  serial_number=${SERIAL_NUMBER}  unit_position=${UNIT_POSITION}
    ...  core_unit_position=${CORE_UNIT_POSITION}
    Check Fault Signature If Fault 4589 Was Raised At Power Off/On For Radio Module


Set Variables For Fault Signature
    ${module_l_parameters}  coam.Get Parameters  ${SECONDARY_CORE_DIST_NAME}
    ${module_r_dn}  Get Module Dist Name By Serial Number And Class  ${SERIAL_NUMBER}  SMOD
    Set Test Variable  ${PRODUCT_NAME}  ${module_l_parameters}[productName]
    Set Unit Position For Fault Signature  ${module_r_dn}
    Set Test Variable  ${MINOR}  UNKNOWN
    Set Test Variable  ${INFO}  Unknown power reset. Possible causes e.g. HW watchdog or external power off/on cycle
    Set Test Variable  ${SCOPE}  ESM
    Set Test Variable  ${CATEGORY}  POWER_OFF
    Set Test Variable  ${RESET_COUNTER}  [0-9]+


Check If Configuration Is Dual Core
    [Documentation]  This KW is created to check if config consist of two system modules.

    ${bts_l}  Query Infomodel  get list //BTS_L-*
    ${bts_l_lenght}  Get Length  ${bts_l}
    IF  ${bts_l_lenght} < 2
      Fail  msg=Tested configuration is not dual core, test will be set as fail. [NOK]
    ELSE
      Log  Tested configuration is dual core, test will contine. [OK]  console=true
    END


Check If Configuration Is AS+F
    [Documentation]  This KW is for checking whether tested configuration is AS+F (4+3), then return TRUE in case of AS+F otherwise FALSE.

    Log  Check if tested configuration is AS+F (4+3):  console=true
    ${configuration}  Check System Modules Configuration In InfoModel
    ${is_as+f}  Set Variable If  '${configuration}' == '4+3' or '${configuration}' == '3+4'  ${TRUE}  ${FALSE}
    Log  ${is_as+f}  console=true

    RETURN  ${is_as+f}


Get Secondary Core Serial Number
    [Documentation]  This KW is created to get secondary core serial number.

    ${bts_l}  Query Infomodel  get list //BTS_L-* is [storedRole=Idle]
    ${element}  Get From List  ${bts_l}  0
    ${secondary_core_dist_name}  Convert To String  ${element["dist_name"]}/EQM_L-1/CABINET_L-1/SMOD_L-1
    Set Test Variable  ${SECONDARY_CORE_DIST_NAME}
    ${secondary_core_object}  Query Infomodel  get object ${SECONDARY_CORE_DIST_NAME}
    Set Test Variable  ${SERIAL_NUMBER}  ${secondary_core_object.serialNumber}
    Log  Secondary Core Serial Number is: ${SERIAL_NUMBER}.  console=true
    ${smod_runtime_object}  Get Infomodel Object  //SMOD_R-* is [activeRole=Secondary]
    Set Test Variable  ${SMOD_RUNTIME_DIST_NAME}  ${smod_runtime_object.dist_name}
    ${status}  Run Keyword And Return Status  Should Contain  ${smod_runtime_object.productName}  Flexi System Module Outdoor FSMF
    IF  ${status}
      Set Test Variable  ${SECONDARY_CORE_MODULE_TYPE}  FSMF
    ELSE
      Set Test Variable  ${SECONDARY_CORE_MODULE_TYPE}  AirScale
    END
    Log  Tested secondary module type is ${SECONDARY_CORE_MODULE_TYPE}.  console=true


Get List Of RMs Connected To Secondary Core
    [Documentation]  This KW was created to collect distNames of radio modules connected to secondary core.

    ${filtered_rmo_ds}  Create List
    ${rmod_r}  Get Parameters For All  RMOD
    FOR  ${rmod}  IN  @{rmod_r}
        ${rmod_ref}  Query Infomodel  get object ${rmod.id}/REF-*
        ${rmod_l}  Query Infomodel  get object ${rmod_ref.distName}
        IF  '${rmod_l.masterAgentDN}' == '${SECONDARY_CORE_DIST_NAME}'  Append To List  ${filtered_rmo_ds}  ${rmod}
    END

    RETURN  ${filtered_rmo_ds}


Recovery Over Backplane Check
    [Documentation]  This KW was created to check whether after 5 minutes after SC is lost autonomous reset is triggered over backplane on rel4.

    ${fault_2nd_core_auto_reset_params}  Get String With Alarm Parameters  ${FAULT_4352_2_ND_CORE_AUTO_RST}
    ${fault_2nd_core_auto_reset_params}  Catenate  ${fault_2nd_core_auto_reset_params},  alarmingResource=${SMOD_RUNTIME_DIST_NAME}
    ${fault_status_with_alaram7101}  Run Keyword And Return Status  Assert Alarm Active  parameters=${fault_2nd_core_auto_reset_params}  timeout=180
    IF  ${fault_status_with_alaram7101}
      Log  Fault 4352 with alarmId 7101 on alarmingResource=${SMOD_RUNTIME_DIST_NAME} is visible again after 5 min. [OK]  console=true
    ELSE
      Set Test Restriction  Alarm 7101 with Fault 4352 is not visible again after 5 min. [NOK]
    END


Check System Secondary Core Status
    [Documentation]  This KW was created to check secondary SMOD status after it was hot removed.

    ${operational_state}  Run Keyword And Return Status  Assert Any  SMOD  operationalState=${DISABLED}
    ${availability_status}  Run Keyword And Return Status  Assert Any  SMOD  availabilityStatus=${NOT_INSTALLED}
    IF  ${operational_state} == ${FALSE} or ${availability_status} == ${FALSE}
      Set Test Restriction  SC status is different than expected operationalState!=disabled and/or availabilityStatus!=not installed. [NOK]
    ELSE
      Log  SC after hot remove reached expected states operationalState=disabled and availabilityStatus=not installed. [OK]  console=true
    END


TC Setup
    Common Test Setup  tc_name=FM__SC_hot_remove_hot_insert
    Setup Netact


TC Teardown
    Teardown Netact
    Common Test Teardown

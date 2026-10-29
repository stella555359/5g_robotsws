*** Settings ***
Documentation
    ...  This test case was created to imitate seconday core Late Startup scenario.
    ...  Fault 4352 occurence and recovery action after hot insert will be checked apperance
    ...  Fault 4001 "BTS site autonomous reset as recovery action" will be also checked

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${RECOVERY_TIMEOUT}  360  # [in seconds] Timeout for SBTS to recover after SC hot insert.
${STARTUP_TIMEOUT}  900  # [in seconds] Timeout for SBTS to recover after startup.
${NETACT_TIMEOUT}  180  # [in seconds] Timeout for alarm to be active in NetAct.
${ALARM_TIMEOUT}  360  # [in seconds] Timeout for alarm to be active in WebEm.


*** Keywords ***
TC__FM__SC_Late_Startup_actForce_True
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-10250
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  17.12.2019 - https://jira3.int.net.nokia.com/browse/TAT-10250 - Initial TAT creation
    ...  22.01.2020 - https://jira3.int.net.nokia.com/browse/TAT-18847 - Add power on PDU of SC in test teardown
    ...  10.10.2020 - https://jira3.ext.net.nokia.com/browse/TAT-20317 - Timeout at site reset for secondary core late startup scenario
    ...  19.04.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21212 - Checking if 5G cells are on SC and ignore alarm with fault 4001
    ...  21.05.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21346 - TC fails because timeout expires and alarm appers after that
    ...  27.09.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21932 - Modify "FM__SC_Late_Startup_actForce_True" for A+F configuration
    ...  05.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21932 - Modify "FM__SC_Late_Startup_actForce_True" for A+A configuration fix
    ...  24.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  31.05.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23086 - Changing the checking of 5G cells on secondary core
    ...  17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  05.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26813 - Refactor FM testcase for assert alarm active parameters
    ...  19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  26.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27704 - Add option to skip RMOD power check
    ...  29.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28007 - Add keyword perform site reset
    ...  17.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29103 - Update testcases and resourses for CB011146
    ...  25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29190 - Enhancement of all test cases in regression to check fault signature
    ...  25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29459 - Enhancement of all test cases in regression to check FS component field
    ...  19.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29766 - Added core variables for fault signature
    ...  26.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29827 - Added restriction for 4001 alarm check
    ...  *******************

    Set Tags  CA-FM  OWNER-laura.craciunel@nokia.com  AUTHOR-narcis.onut@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf
    ...  PHASE-CRT  SW-SBTS17A  FEATURE-RP0011621  FEATURE-RP001498

    Step1: Check All Required States
    Step2: Secondary Core Hot Remove
    Step3: Secondary Core Hot Insert
    Step4: Return ActForce(Unit)AutoReset To Initial Value


Step1: Check All Required States
    [Documentation]  In this step specific states will be checked.

    Log  \nStep1: Check all required states.  console=true
    Check If Configuration Is Dual Core
    Log  Checking value for actForceAutoReset = true.  console=true
    ${initial_value}  Get ActForce(Unit)AutoReset Value From Infomodel  actForceAutoReset
    ${status}  Run Keyword And Return Status  Change Parameter ActForce(Unit)AutoReset  true  actForceAutoReset
    ${parameter_after_change}  Get ActForce(Unit)AutoReset Value From Infomodel  actForceAutoReset
    IF  ${status}  Should Be Equal  ${parameter_after_change}  true
    Set Test Variable  ${INITIAL_VALUE}
    Set Test Variable  ${PARAMETER_AFTER_CHANGE}
    ${is_as+f}  Check If Configuration Is AS+F
    Set Test Variable  ${IS_AS+F}
    IF  ${IS_AS+F}  Perform Site Reset
    Get Secondary Core Serial Number
    Set Variables For Fault Signature
    ${affected_r_ms_connected_to_sc}  Get List Of RMs Connected To Secondary Core
    Set Test Variable  ${AFFECTED_R_MS_CONNECTED_TO_SC}
    ${all_rmods_power_before_reco_reset}  Create Dictionary
    Set Test Variable  ${ALL_RMODS_POWER_BEFORE_RECO_RESET}
    ${all_rmods_power_after_reco_reset}  Create Dictionary
    Set Test Variable  ${ALL_RMODS_POWER_AFTER_RECO_RESET}
    Get All Tx Power From All RMs  ${ALL_RMODS_POWER_BEFORE_RECO_RESET}
    ${5_g_cells_on_sc}  IF  ${SCF_COUNT_NR} > 0  Check If 5G Is On Secondary Core  ELSE  Set Variable  ${FALSE}
    Set Test Variable  ${5_G_CELLS_ON_SC}


Step2: Secondary Core Hot Remove
    [Documentation]  In this step secondary core will be hot removed.

    Log  \nStep2: Hot remove of secondary core and reset site.  console=true
    ${start_time}  Get Current Date  time_zone=UTC  result_format=datetime
    Set Test Variable  ${START_TIME}
    Pdu Bts Interface Off  SMOD_${SECONDARY_CORE_SERIAL_NUMBER}
    ${fid_4352_params}  Get String With Alarm Parameters  ${FAULT_4352_CORES_NOT_CONN}
    Assert Alarm Active  parameters=${fid_4352_params}  timeout=${ALARM_TIMEOUT}
    Log  Fault 4352 "${FAULT_4352_CORES_NOT_CONN}[fault_name]" is visible after secondary core hot remove.  console=true
    Log  Secondary core has been successfully hot removed. [OK]  console=true
    Log  Site reset will be performed.  console=true
    coam.Reset Site  timeout=300
    Sleep  300s


Step3: Secondary Core Hot Insert
    [Documentation]  In this step secondary core will be hot inserted.

    Log  \nStep3: Hot insert of secondary core.  console=true
    ${fid_4001_params}  Get String With Alarm Parameters  ${FAULT_4001_SITE_AUTO_RST}
    ${fid_4352_params}  Get String With Alarm Parameters  ${FAULT_4352_CORES_NOT_CONN}
    Assert Alarm Active  parameters=${fid_4352_params}  timeout=${ALARM_TIMEOUT}
    Log  Fault 4352 "${FAULT_4352_CORES_NOT_CONN}[fault_name]" is visible after site reset.  console=true
    Pdu Bts Interface On  SMOD_${SECONDARY_CORE_SERIAL_NUMBER}
    Log  Secondary core has been successfully hot inserted. [OK]  console=true
    Sleep  120s

    IF  ${5_G_CELLS_ON_SC} == ${FALSE}
        ${status_alarm}  Run Keyword And Return Status  Assert Alarm Active  parameters=${fid_4001_params}  timeout=${ALARM_TIMEOUT}
        IF  ${status_alarm}
            Log  Fault 4001 "${FAULT_4001_SITE_AUTO_RST}[fault_name]" is active in WebEM. [OK]  console=true
        ELSE
            Set Test Restriction  Fault 4001 "${FAULT_4001_SITE_AUTO_RST}[fault_name]" didn't occurr. [NOK]
        END
    END
    Sleep  ${RECOVERY_TIMEOUT}s
    Wait Until Keyword Succeeds  2 min  0 sec  Check if target is stable  ${OAM_BTS_IP}  30  30  120
    Log  Ping to SBTS is back, test will be continued. [OK]  console=true
    Admin Check Active Alarms Taf
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT} sec  30 sec  Check All Cells
    Check Links Status  Available
    Get All Tx Power From All RMs  ${ALL_RMODS_POWER_AFTER_RECO_RESET}
    Compare TXs  ${ALL_RMODS_POWER_AFTER_RECO_RESET}  ${ALL_RMODS_POWER_BEFORE_RECO_RESET}

    Log  Checking alarms presence in Netact.  console=true
    Wait Until Keyword Succeeds  300  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_4352_CORES_NOT_CONN}  time_from=${START_TIME}
    ...  additional_fault_id=${FAULT_4352_CORES_NOT_CONN}[fault_id]
    Log  Fault 4352 "${FAULT_4352_CORES_NOT_CONN}[fault_name]" was reported & cleared from NetAct.  console=true
    Log  Check fault signature.  console=true
    Check Fault Signature Of Alarm In WebEM  fault_id=${FAULT_4590}[fault_id]  category=${CATEGORY}  info=${INFO}  load_name=${SW_VERSION}
    ...  minor=${MINOR}  reset_counter=${RESET_COUNTER}  scope=${SCOPE}  full_product_name=${PRODUCT_NAME}  serial_number=${SERIAL_NUMBER}
    ...  core_serial_number=${CORE_SERIAL_NUMBER}  vendor_unit_number=${PRODUCT_CODE}  core_vendor_unit_number=${CORE_PRODUCT_CODE}
    ...  unit_position=${UNIT_POSITION}  core_unit_position=${CORE_UNIT_POSITION}
    Check Fault Signature Of Alarm In Netact  fault_id=${FAULT_4590}[fault_id]  time_from=${START_TIME}  category=CATEGORY:${SPACE}${CATEGORY}
    ...  info=INFO:${SPACE}${INFO}  load_name=LOAD_NAME:${SPACE}${SW_VERSION}  minor=MINOR:${SPACE}${MINOR}  scope=SCOPE:${SPACE}${SCOPE}
    ...  reset_counter=RESET_COUNTER:${SPACE}${RESET_COUNTER}  full_product_name=${PRODUCT_NAME}  serial_number=${SERIAL_NUMBER}
    ...  core_serial_number=${CORE_SERIAL_NUMBER}  vendor_unit_number=${PRODUCT_CODE}  core_vendor_unit_number=${CORE_PRODUCT_CODE}
    ...  unit_position=${UNIT_POSITION}  core_unit_position=${CORE_UNIT_POSITION}


Step4: Return ActForce(Unit)AutoReset To Initial Value
    Log  Step4:\n Return actForceAutoReset parameter if needed.  console=true
    ${im_bts_id}  Admin Get BTS ID
    ${bts_dist_name}  Set Variable  MRBTS-${im_bts_id}/MNL-1/MNLENT-1/FMCADM-1
    IF  '${INITIAL_VALUE}'=='false'
        coam.Perform Parameter Recommissioning  ${bts_dist_name}  actForceAutoReset  update  false  skip_parameter_relation_errors=True
        Log  actForceAutoReset will be changed to initial value (False)  console=true
    END


Set Variables For Fault Signature
    ${module_l_parameters}  coam.Get Parameters  ${SECONDARY_CORE_DIST_NAME}
    ${module_r_dn}  Get Module Dist Name By Serial Number And Class  ${SECONDARY_CORE_SERIAL_NUMBER}  SMOD
    Set Test Variable  ${PRODUCT_NAME}  ${module_l_parameters}[productName]
    Set Test Variable  ${SERIAL_NUMBER}  ${module_l_parameters}[serialNumber]
    Set Test Variable  ${PRODUCT_CODE}  ${module_l_parameters}[productCode]
    ${module_l_parameters}  coam.Get Parameters  ${module_r_dn}
    Set Test Variable  ${CORE_SERIAL_NUMBER}  ${module_l_parameters}[coreHwBoardSerialNumber]
    Set Test Variable  ${CORE_PRODUCT_CODE}  ${module_l_parameters}[coreHwBoardProductCode]
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
    IF  ${is_as+f}  Log  TRUE  console=true  ELSE  Log  FALSE  console=true

    RETURN  ${is_as+f}


Get Secondary Core Serial Number
    [Documentation]  This KW is created to get secondary core serial number.

    ${bts_l}  Query Infomodel  get list //BTS_L-* is [storedRole=Idle]
    ${element}  Get From List  ${bts_l}  0
    ${secondary_core_dist_name}  Convert To String  ${element["dist_name"]}/EQM_L-1/CABINET_L-1/SMOD_L-1
    Set Test Variable  ${SECONDARY_CORE_DIST_NAME}
    ${secondary_core_object}  Query Infomodel  get object ${SECONDARY_CORE_DIST_NAME}
    Set Test Variable  ${SECONDARY_CORE_SERIAL_NUMBER}  ${secondary_core_object.serialNumber}
    Log  Secondary Core Serial Number is: ${SECONDARY_CORE_SERIAL_NUMBER}  console=true
    ${smod_runtime_object}  Get Infomodel Object  //SMOD_R-* is [activeRole=Secondary]
    Set Test Variable  ${SMOD_RUNTIME_DIST_NAME}  ${smod_runtime_object.dist_name}
    ${status}  Run Keyword And Return Status  Should Contain  ${smod_runtime_object.productName}  Flexi System Module Outdoor FSMF
    IF  ${status}
        Set Test Variable  ${SECONDARY_CORE_MODULE_TYPE}  FSMF
    ELSE
        Set Test Variable  ${SECONDARY_CORE_MODULE_TYPE}  AirScale
    END
    Log  Tested Secondary Module Type is ${SECONDARY_CORE_MODULE_TYPE}  console=true


Get List Of RMs Connected To Secondary Core
    [Documentation]  This KW was created to collect distNames of radio modules connected to secondary core.

    ${filtered_rmo_ds}  Create List
    ${rmod_r}  Get Parameters For All  RMOD
    FOR  ${rmod}  IN  @{rmod_r}
        ${rmod_ref}  Query Infomodel  get object ${rmod.id}/REF-*
        ${rmod_l}  Query Infomodel  get object ${rmod_ref.distName}
        IF  '${rmod_l.masterAgentDN}'=='${SECONDARY_CORE_DIST_NAME}'  Append To List  ${filtered_rmo_ds}  ${rmod}
    END

    RETURN  ${filtered_rmo_ds}


Get List Of RMODS
    ${filtered_rmo_ds}  Create List
    ${rmod_l}  Query Infomodel  get list /MRBTS-1/RAT-1/BTS_L-*/EQM_L-1/RMOD_L-*
    FOR  ${rmod}  IN  @{rmod_l}
        IF  '${rmod.masterAgentDN}'=='${SECONDARY_CORE_DIST_NAME}'  Append To List  ${filtered_rmo_ds}  ${rmod}
    END

    RETURN  ${filtered_rmo_ds}


Check If 5G Is On Secondary Core
    ${rmods_list}  Get List Of RMODS
    ${slave_cells_list}  Create List
    FOR  ${item}  IN  @{rmods_list}
        ${cells_on_rmod}  Infomodel Get Cells Deployed On Module  ${item}
        Append To List  ${slave_cells_list}  @{cells_on_rmod}
    END
    ${status}  Run Keyword And Return Status  Should Not Be Empty  ${slave_cells_list}
    ${status_nr_cells}  IF  ${status}  Check If NR Cells Are On Secondary Core  ${slave_cells_list}  ELSE  Set Variable  ${FALSE}

    RETURN  ${status_nr_cells}


Check If NR Cells Are On Secondary Core
    [Documentation]  This KW is created to check if NR cells are on secondary core.
    ...  If there are NR cells, the KW will return TRUE, else will return the default value, FALSE.
    [Arguments]  ${cells_on_slave}

    FOR  ${cell}  IN  @{cells_on_slave}
        ${nr_cell_status}  Run Keyword And Return Status  Should Contain  ${cell}[dist_name]  NR
        IF  ${nr_cell_status}  Return From Keyword  ${TRUE}
    END
    Log  NR cells are not on secondary core.  console=true

    RETURN  ${FALSE}


TC Setup
    Common Test Setup  tc_name=FM__SC_Late_Startup_actForce_True
    Setup NetAct


TC Teardown
    Pdu Bts Interface On  SMOD_${SECONDARY_CORE_SERIAL_NUMBER}
    Teardown NetAct
    Common Test Teardown
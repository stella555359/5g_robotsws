*** Settings ***
Resource    ../../common_resources/ca_FM_general.robot

*** Variables ***
@{RMOD_TYPE}                    AEQE  AENB  AZQJ                                    # Supported RMOD types for test.
                                                                                    # RF 6.1 from Master, Amber and Scorpio families.
${STARTUP_TIMEOUT}              660                                                 # Timeout for SBTS recovery after site reset.
${ALARM_TIMEOUT}                900                                                 # Timeout for critical alarm reporting in WebEM.
${NETACT_TIMEOUT}               120                                                 # Timeout for fault reporting in Netact.
@{parameter_values_1}           8                                                   # Parameter values for fault triggering.
                                                                                    # Parameter under first SYNC source.
@{parameter_values_2}           8                                                   # Parameter values for fault triggering.
                                                                                    # Parameter under second SYNC source.

*** Keywords ***
TC__FM__RMOD_reset_counter_exceeded_FID1900
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-23752
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Test case will verify that the fault signature fields are populated in the alarm raised
    ...  for fault 1900 on radios release RF 6.1 from Master, Amber and Scorpio families.
    ...  In first step test case precondition will be verified:
    ...  check if configuration has RF type for test, perform site reset to clear all recovery counters,
    ...  get initial values of acceptedClockClass parameters, change actFaultSignature and actSyncToRU parameters to true.
    ...  In second step fault 1900 will be triggered by modifying acceptedClockClass parameters on TOPP sync sources.
    ...  In third step the presence of fault 1900 will be verified in WebEm and Netact.
    ...  Radio autonomous reset is performed three times and fault 19000 is raised with warning severity each time.
    ...  After three consecutive 1900 faults, fault is raised once again with critical severity.
    ...  Fault signature fields will be checked in alarms raised in WebEM and Netact.
    ...  In fourth step actFaultSignature, actSyncToRU, acceptedClockClass parameters will be set to initial values.
    ...  Radio modules recovery will be performed by resetting affected modules.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 23.09.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23752 - Initial test case creation
    ...  - 28.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23931 - Move keywords to resource file
    ...  - 31.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23753 - Move check fault signature keywords to resource file
    ...  - 17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  - 31.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25478 - Update FM testcases for actFaultSignature
    ...  - 26.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25598 - Test fails when checking extra_info field from fault signature
    ...  - 27.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25299 - Fault is raised on all eCPRI RFs, but not all RFs are recovered
    ...  - 15.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25658 - Create new resources for NetAct and ONAP KWs
    ...  - 05.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26813 - Refactor FM testcase for assert alarm active parameters
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  *******************

    Set Tags    OWNER-alina.cret@nokia.com    AUTHOR-laura.craciunel@nokia.com    MAINTAINER-laura.craciunel@nokia.com
    ...    GROUP_IN_CHARGE-TIM_4_Vrf    CA-FM    PHASE-CRT    SW-SBTS22    FEATURE-CB007273

    Step 1: Test case preconditions
    Step 2: Trigger fault 1900
    Step 3: Verify fault presence
    Step 4: Return parameter to original values

Step 1: Test case preconditions
    Log  Step 1: Test case preconditions.  console=true
    ${mrbts_id}  Get mrbts id
    Set Test Variable  ${MRBTS_ID}  ${mrbts_id}
    Check radio modules in configuration
    Check if other radio modules are affected
    Get config object names
    Set actFaultSignature value  true
    Perform site reset
    ${sync_objects}  Query Infomodel  get list //TOPP_A-*
    ${sync_source_number}  Get Length  ${sync_objects}
    Set Test Variable  ${SYNC_SOURCE_NUMBER}  ${sync_source_number}
    ${initial_values}  Get acceptedClockClass value from infomodel
    Set Test Variable  ${INITIAL_VALUES}  ${initial_values}
    ${all_parameter_values}  Create List
    Append To List  ${all_parameter_values}  ${parameter_values_1}  ${parameter_values_2}
    Set Test Variable  ${ALL_PARAMETER_VALUES}  ${all_parameter_values}
    ${date_utc}  Get Current Date  time_zone=UTC  result_format=datetime
    Set Test Variable  ${START_TIME}  ${date_utc}
    ${current_date}  Get current date  result_format=%Y%m%d
    Set Test Variable  ${CURRENT_DATE}  ${current_date}
    ${active_SW}  coam.get_sw_version
    Set Test Variable  ${ACTIVE_SW}  ${active_SW}
    ${serial_numbers}  Get RMODs serial number  ${TESTED_RMODS}
    Set Test Variable  ${SERIAL_NUMBERS}  ${serial_numbers}

Step 2: Trigger fault 1900
    Log  Step 2: Trigger fault 1900.  console=true
    Set all test paramerters values  true  ${ALL_PARAMETER_VALUES}

Step 3: Verify fault presence
    Log  Step 3: Verify fault presence.  console=true
    Setup Admin  bts_host=192.168.255.129  bts_port=443  use_ssl=True  alias=check_critical_alarm
    ${alarm_critical_parameters}  Get string with alarm parameters  ${FAULT_1900_RF_CONFIG_FAILED}
    ${critical_alarm}  Run Keyword In Background  Assert Alarm Active
    ...  parameters=${alarm_critical_parameters}
    ...  timeout=${ALARM_TIMEOUT}
    ...  alias=check_critical_alarm
    Setup Admin  bts_host=192.168.255.129  bts_port=443  use_ssl=True  alias=check_warning_alarm
    ${alarm_warning_parameters}  Get string with alarm parameters  ${FAULT_1900_RADIO_AUTO_RST}
    ${warning_alarm}  Run Keyword In Background  Assert Alarm Active
    ...  parameters=${alarm_warning_parameters}
    ...  timeout=300
    ...  alias=check_warning_alarm
    Verify RMOD status  ${Disabled_}  ${Offline_}

    ${check_warning}  Collect Keyword Result  ${warning_alarm}  timeout=300
    Run Keyword If  ${check_warning}  
    ...  Log  Fault ${FAULT_1900_RADIO_AUTO_RST}[fault_id] with ${FAULT_1900_RADIO_AUTO_RST}[severity] severity is present.  console=true
    ...  ELSE  Fail  Fault ${FAULT_1900_RADIO_AUTO_RST}[fault_id] with ${FAULT_1900_RADIO_AUTO_RST}[severity] severity is not present.
    Run Keyword And Continue On Failure  Teardown Admin  alias=check_warning_alarm

    ${check_critical}  Collect Keyword Result  ${critical_alarm}  timeout=${ALARM_TIMEOUT}
    Run Keyword If  ${check_critical}  
    ...  Log  Fault ${FAULT_1900_RF_CONFIG_FAILED}[fault_id] with ${FAULT_1900_RF_CONFIG_FAILED}[severity] severity is present.  console=true
    ...  ELSE  Fail  Fault ${FAULT_1900_RF_CONFIG_FAILED}[fault_id] with ${FAULT_1900_RF_CONFIG_FAILED}[severity] severity is not present.
    Run Keyword And Continue On Failure  Teardown Admin  alias=check_critical_alarm

    Sleep  ${NETACT_TIMEOUT}s
    ${check_fault_na_critical}  Run Keyword And Return Status
    ...  Check additional information for given alarm and fault  &{FAULT_1900_RF_CONFIG_FAILED}
    Run Keyword If  ${check_fault_na_critical}
    ...  Log  Given alarm and fault fields are correct in NA, alarm is present in NA.  console=true
    ...  ELSE  Fail  Given alarm and fault fields are incorrect in NA or alarm is missing in NA.
    ${check_fault_na_warning}  Run Keyword And Return Status
    ...  Check additional information for given alarm and fault in NA cleared alarms  &{FAULT_1900_RADIO_AUTO_RST}
    ...                                                                               time_from=${START_TIME}
    Run Keyword If  ${check_fault_na_warning}
    ...  Log  Given alarm and fault fields are correct in NA, alarm is present in NA cleared alarms.  console=true
    ...  ELSE  Fail  Given alarm and fault fields are incorrect in NA or alarm is missing in NA cleared alarms.

    ${category}    Set variable  OAM_RESET
    ${scope}       Set variable  RFM
    ${extra_info}  Set variable  faulty_cells=.*NR:[0-9]+.*
    Check fault signature of alarm in WebEM for all RMODs  ${FAULT_1900_RADIO_AUTO_RST}[fault_id]
    ...                                                    ${FAULT_1900_RADIO_AUTO_RST}[severity]
    ...                                                    ${SERIAL_NUMBERS}
    ...                                                    ${RMODS_COUNT}
    ...                                                    ${category}
    ...                                                    ${scope}
    ...                                                    ${extra_info}
    ...                                                    ${ACTIVE_SW}
    ...                                                    ${CURRENT_DATE}
    Check fault signature of alarm in NA for all RMODs  ${FAULT_1900_RADIO_AUTO_RST}[fault_id]
    ...                                                 ${SERIAL_NUMBERS}
    ...                                                 ${category}
    ...                                                 ${scope}
    ...                                                 ${extra_info}
    ...                                                 ${ACTIVE_SW}
    ...                                                 ${START_TIME}
    Check alarms in alarms history   warning
    Check alarms in alarms history   critical

Step 4: Return parameter to original values
    Log  Step 4: Return parameter to original values.  console=true
    Set all test paramerters values  false  ${INITIAL_VALUES}
    Reset affected RMODs
    Wait Until Keyword Succeeds  300s  60s  Verify RMOD status  ${Enabled_}
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  10  Check All Cells  ${OnAirDone_}  ${Enabled_}  ${Active_}
    Admin Check Active Alarms Taf


Get mrbts id
    [Arguments]  ${connection}=default
    ${info}  coam.Get BTS Info  connection=${connection}
    ${bts_id}  Convert To String  ${info['mrbtsID']}
    [Return]  ${bts_id}

Check radio modules in configuration
    ${rmods_config_list}  get_parameters_for_all  RMOD
    ${rmods_matches}  Create List
    FOR  ${rmod}  IN  @{rmods_config_list}
         ${match}  Run Keyword And Return Status  List Should Contain Value  ${RMOD_TYPE}  ${rmod.productName}
         Run Keyword If  ${match}  Append To List  ${rmods_matches}  ${rmod}
    END
    ${length}  Get Length  ${rmods_matches}
    Run Keyword If  ${length}  Log  Suitable RMOD for test found in configuration.  console=true
    ...  ELSE  Fail  No suitable RMOD found in configuration.
    Set Test Variable  ${TESTED_RMODS}  ${rmods_matches}
    Set Test Variable  ${RMODS_COUNT}  ${length}

Check if other radio modules are affected
    ${rmods_config_list}  get_parameters_for_all  RMOD
    ${rmods_matches}  Create List
    FOR  ${rmod}  IN  @{rmods_config_list}
         ${match}  Run Keyword And Return Status  Should Be Equal  ${rmod}[l3Protocol]  ECPRI_MPLANE
         Run Keyword If  ${match}  Append To List  ${rmods_matches}  ${rmod}
    END
    ${affected_rmods}  Copy List  ${rmods_matches}
    Remove Values From List  ${affected_rmods}  @{TESTED_RMODS}
    Set Test Variable  ${AFFECTED_RMODS}  ${affected_rmods}

Get config object names
    ${rmods_info_list}  get_frm
    ${configObjectName_list}  Create List
    FOR  ${rmod}  IN  @{TESTED_RMODS}
         ${configObjectName}  Get configObjectName for RMOD  ${rmod}  ${rmods_info_list}
         Append To List  ${configObjectName_list}  ${configObjectName}
    END
    FOR  ${rmod}  IN  @{AFFECTED_RMODS}
         ${configObjectName}  Get configObjectName for RMOD  ${rmod}  ${rmods_info_list}
         Append To List  ${configObjectName_list}  ${configObjectName}
    END
    Set Test Variable  ${CONFIG_NAMES}  ${configObjectName_list}

Get configObjectName for RMOD
    [Arguments]  ${selected_rmod}  ${rmod_list}
    FOR  ${rmod}  IN  @{rmod_list}
         ${configuration_string}  Set Variable If  '${selected_rmod}[id]'=='${rmod}[id][internal]'  ${rmod}[id][configuration]
         Run Keyword If  '${configuration_string}'!='None'  Exit For Loop
    END
    ${configObjectName_string}  Catenate  SEPARATOR=${SPACE}  [SBTS${MRBTS_ID}]  ${configuration_string}
    [Return]  ${configObjectName_string}

Check alarms in alarms history
    [Arguments]  ${severity}
    ${historical_alarms}  get_historic_alarms  severity=${severity}
    FOR  ${item}  IN  @{historical_alarms}
         Check configObjectName in alarms  ${item}
    END

Check configObjectName in alarms
    [Arguments]  ${alarm}
    FOR  ${config_name}  IN  @{CONFIG_NAMES}
         ${status}  Run Keyword And Return Status  Should Be Equal  ${config_name}  ${alarm}[configObjectName]
         Run Keyword If  ${status}
         ...  Log  Alarm with fault ${alarm}[faultId] was raised on configObjectName: ${alarm}[configObjectName].  console=true
    END

Get RMODs serial number
    [Arguments]  ${rmod_list}
    ${rmods_serial_numbers}  Create list
    FOR  ${rmod}  IN  @{rmod_list}
         Append To List  ${rmods_serial_numbers}  ${rmod.serialNumber}
    END
    [Return]  ${rmods_serial_numbers}

Reset affected RMODs
    FOR  ${rmod}  IN  @{TESTED_RMODS}
         ${reset_status}  Run Keyword And Return Status  coam.reset_unit  ${rmod.id}  timeout=300
         Run Keyword If  ${reset_status}  Log  RMOD reset was performed with success.  console=true
         ...  ELSE  Set Test Restriction  RMOD reset was not performed or timeout exceeded.
    END
    FOR  ${rmod}  IN  @{AFFECTED_RMODS}
         ${reset_status}  Run Keyword And Return Status  coam.reset_unit  ${rmod.id}  timeout=300
         Run Keyword If  ${reset_status}  Log  RMOD reset was performed with success.  console=true
         ...  ELSE  Set Test Restriction  RMOD reset was not performed or timeout exceeded.
    END

Set all test paramerters values
    [Arguments]  ${actSyncToRU_value}  ${acceptedClockClass_value}
    Set actSyncToRU value   ${actSyncToRU_value}
    Create and apply provisioning plan  ${MRBTS_ID}  ${SYNC_SOURCE_NUMBER}  ${acceptedClockClass_value}

Set actSyncToRU value
    [Arguments]  ${value}
    ${parameter_initial_value}  Get actSyncToRU value from infomodel
    ${status}  Run keyword and return status  Should contain  ${parameter_initial_value}  ${value}
    Run keyword If  ${status}
    ...  Log  actSyncToRU already set to ${value}, no need to be changed.  console=true
    ...  ELSE  Change parameter actSyncToRU  ${value}

Get actSyncToRU value from infomodel
    [Arguments]   ${im_parameter}=actSyncToRU
    ${parameter_name}  Convert To String  ${im_parameter}
    ${parameter_object}  Query Infomodel  get object //MNL_A-1/MNLENT_A-1/SECADM_A-1
    ${parameter_object_value_string}  Convert To String  ${parameter_object.${parameter_name}}
    ${parameter_object_lower}  Convert To Lowercase  ${parameter_object_value_string}
    [Return]  ${parameter_object_lower}

Change parameter actSyncToRU
    [Arguments]   ${value}  ${parameter_name}=actSyncToRU
    ${im_bts_id}  Admin Get BTS ID
    ${dist_name_bts_id}   Set Variable  MRBTS-${im_bts_id}/MNL-1/MNLENT-1/SECADM-1
    ${get_parameter_value}  Get actSyncToRU value from infomodel  ${parameter_name}
    Run Keyword If  '${get_parameter_value}'!='${value}'  Run Keywords
    ...  Log  ${parameter_name} will be changed to ${value}  console=true  AND
    ...  coam.Perform Parameter Recommissioning  ${dist_name_bts_id}
    ...                                          ${parameter_name}
    ...                                          update
    ...                                          ${value}
    ...                                          skip_parameter_relation_errors=True
    ...                                          should_activate=True
    ...                                          timeout=300

Get acceptedClockClass value from infomodel
    ${topp_objects}  Query Infomodel  get list //CLOCK_A-1/TOP_A-1/TOPP_A-*
    ${values}  Create list
    FOR  ${item}  IN  @{topp_objects}
         Append To List  ${values}  ${item}[acceptedClockClass]
    END
    [Return]  ${values}

Create and apply provisioning plan
    [Arguments]   ${id}  ${sync_souces}  ${values}
    Log  Updating acceptedClockClass parameters on sync sources.   console=true
    ${delta_id}  Set Variable  1
    Create Delta  ${delta_id}
    FOR  ${loop}  IN RANGE  1  ${sync_souces}+1
         ${list_index}  Evaluate  ${loop}-1
         Append Managed Object To Delta  MRBTS-${id}/MNL-1/MNLENT-1/SYNC-${loop}/CLOCK-1/TOP-1/TOPP-1
         ...                             update
         ...                             ${delta_id}
         Append Parameter Update To Delta  MRBTS-${id}/MNL-1/MNLENT-1/SYNC-${loop}/CLOCK-1/TOP-1/TOPP-1
         ...                               acceptedClockClass
         ...                               ${values}[${list_index}]
         ...                               delta_id=${delta_id}
    END
    Get Delta  ${delta_id}
    Save Delta  ${BTS Files}/delta_1.json  delta_id=${delta_id}
    Log  Performing delta recommissioning.  console=true
    ${status}  Run Keyword And Return Status
    ...  coam.Perform Delta Recommissioning  ${BTS Files}/delta_1.json
    ...                                      skip_parameter_relation_errors=True
    ...                                      timeout=180
    Run Keyword If  ${status}
    ...  Log  Recommissioning was performed.   console=true
    ...  ELSE  Fail  Recommissioning failed.
    Remove Delta  ${delta_id}


TC Setup
    Common Test Setup  tc_name=FM__RMOD_reset_counter_exceeded_FID1900
    Setup NetAct

TC Teardown
    Run Keyword If Test Failed  Set all test paramerters values  false  ${INITIAL_VALUES}
    Teardown NetAct
    Common Test Teardown

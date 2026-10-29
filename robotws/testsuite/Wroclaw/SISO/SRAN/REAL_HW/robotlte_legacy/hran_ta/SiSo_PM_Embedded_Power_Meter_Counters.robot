*** Settings ***

Resource   resources/ca_BSRF_general.robot

Library    DateTime
Library    taf.sbts.oam.coam.admin  WITH NAME  admin

*** Variables ***

${INTERVAL}  15  # for parameter: mtBtsEnergyMonitoring. Please enter only the number. Available intervals in minutes: 15,30,60,360,720,1440

*** Keywords ***
TC__SiSo_PM_Embedded_Power_Meter_Counters
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-21141
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  TC for feature: 5GC000433-A-SyVe - Embedded Power Meter for Energy Efficiency
    ...  The purpose of this Test Case is to check the activation and deactivation for Embedded Power Meter
    ...  for Enegry Efficiency Monitoring.
    ...  Power Meter is capable of measure power consumption (DC voltage and amperage) in RFM, SM and whole BTS.
    ...  TC verifies if all counters for feature are correctly gathered.
    ...  SBTS counters: M40002C0,M40002C1,M40002C2
    ...  RFM counters:  M40003C0,M40003C1,M40003C2,M40003C3,M40003C4,M40003C5
    ...  SM counters:   M40004C0,M40004C1,M40004C2,M40004C3,M40004C4,M40004C5
    ...  TC can be execute on BTS contains RU with release >= 3.0 only !
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 06.04.2021 - https://jira3.int.net.nokia.com/browse/TAT-21141 - Initial creation
  Common Test Setup
  Logging With Timestamp
  ...  message=TC__SiSo_PM_Embedded_Power_Meter_Counters will be executed
  ...  style=ONGOING

    Set Tags    OWNER-mateusz.kawka@nokia.com
    ...         AUTHOR-mateusz.kawka@nokia.com
    ...         MAINTAINER-mateusz.kawka@nokia.com
    ...         PHASE-CRT

    SiSo_PM_Embedded_Power_Meter_Counters.step1: Preconditions
    step2: Enable Embedded Power Meter
    step3: Disable Embedded Power Meter
    Restore Reference EEM Configuration

    [Teardown]  Run Keywords  Log to console  TC finished. Result = ${KEYWORD STATUS}
    ...  AND  Set Suite Variable  ${KEYWORD STATUS}
    ...  AND  Run Keyword If  '${KEYWORD STATUS}'!='PASS' and ${RESTORE_CONFIG}  Restore Reference EEM Configuration
    ...  AND  Common Test Teardown

step1: Preconditions

    Log To Console  step1: Preconditions

    ${START_TIME}  Evaluate  int((__import__('datetime').datetime.now().timestamp())-900)
    Set Test Variable    ${START_TIME}

    Set Test Variable  ${RESTORE_CONFIG}  ${FALSE}
    Set Test Variable  ${SBTS_COUNTERS}  M40002C0,M40002C1,M40002C2
    Set Test Variable  ${RFM_COUNTERS}   M40003C0,M40003C1,M40003C2,M40003C3,M40003C4,M40003C5
    Set Test Variable  ${SM_COUNTERS}    M40004C0,M40004C1,M40004C2,M40004C3,M40004C4,M40004C5

    ${bts_params}  admin.Get parameters for all  BTS  alias=${node}
    Set Test Variable  ${BTS_ID}  ${bts_params[0].btsId}

    Set Test Variable  ${object_variable_actPowerMeter}  MRBTS-${bts_id}/MNL-1/MNLENT-1/FEATCADM-1
    Set Test Variable  ${object_variable_mtBtsEnergyMonitoring}  MRBTS-${bts_id}/MNL-1/MNLENT-1/PMMNL-1

    Check Interval  ${INTERVAL}
    ${reference_dict}  Get Enegry Efficiency Parameters From SCF
    Set Test Variable  ${REFERENCE_DICT}

    ${smods}  admin.Get Parameters For All  SMOD  alias=${node}

    ${smods_list}  Create List
    FOR  ${smod}  IN  @{smods}
        Append To List  ${smods_list}  ${smod['productName']}
    END

    ${EEM_SMOD}  Evaluate  next((True for smod in ${smods_list} if 'AirScale' in smod), False )
    Set Test Variable  ${EEM_SMOD}

    ${new_counters_path}    Check If Current Build Is Newer Than    SBTS24R2_ENB_9999_231220_000004  alias=${node}
    Set Test Variable    ${NEW_COUNTERS_PATH}

step2: Enable Embedded Power Meter

    Log To Console  \nstep2: Enable Power Meter Feature\n

    Set Test Variable  ${RESTORE_CONFIG}  ${TRUE}
    ${params_list}  Get Dictionary Values  ${REFERENCE_DICT}

    Run Keyword If  ${params_list.count('true')} == 1 and ${params_list.count('15min')} == 3
    ...  Log To Console  Energy Efficiency Monitoring feature already activated!\n
    ...  ELSE
    ...  Run Keywords  Log To Console  Energy Efficiency Monitoring feature is not active, activating ongoing..\n
    ...  AND  Parameters Recommissioning For Power Meter
    ...  actPowerMeter=true
    ...  mtBtsEnergyMonitoring=15min
    ...  mtSBTSSmEnergyMonitoring=15min
    ...  mtSBTSRfmEnergyMonitoring=15min

    ${status}  Run Keyword And Return Status  Check If All Cells Are onAir  alias=${node}
    Run Keyword If  '${status}'=='False'  
    ...  Fail  Cells are not onAir after recommissioning! Parameters restoring and set test fail !
    ...  ELSE
    ...  Log to console  All cells are onAir !${\n}

    ${time_to_sleep}  ${time_to_verdict}  Time To Sleep  ${INTERVAL}
    Log To Console  Waiting for ${time_to_sleep} minutes to Get PM Counters ! ${\n}Verdict will be released at *${time_to_verdict}* !
    Sleep  ${time_to_sleep} minutes
    # Set Test Variable  ${EEM_EPOCH_OFFSET}  1020  #  17 minutes in epoch format
    # Set Test Variable  ${FEATURE_MODE}  ${TRUE}

    ${not_ee_rmods}  Get Not Supported EE RMODs
    Set Test Variable  ${NOT_EE_RMODS}
    ${sbts_counter_len}  Verify EEM Counters And Return Length  SBTS  ${SBTS_COUNTERS}
    ${rfm_counter_len}  Verify EEM Counters And Return Length  RFM  ${RFM_COUNTERS}
    ${sm_counter_len}  Run Keyword If  '${EEM_SMOD}'=='True'
    ...  Verify EEM Counters And Return Length  SM  ${SM_COUNTERS}

    Set Test Variable  ${SBTS_COUNTER_ENABLED}   ${sbts_counter_len}
    Set Test Variable  ${RFM_COUNTER_ENABLED}   ${rfm_counter_len}
    Run Keyword If  '${EEM_SMOD}'=='True'
    ...  Set Test Variable  ${SM_COUNTER_ENABLED}   ${sm_counter_len}

step3: Disable Embedded Power Meter

    Log To Console  ${\n}step3: Disable Energy Efficiency monitoring${\n}

    Parameters Recommissioning For Power Meter
    ...  actPowerMeter=false
    ...  mtBtsEnergyMonitoring=disabled
    ...  mtSBTSSmEnergyMonitoring=disabled
    ...  mtSBTSRfmEnergyMonitoring=disabled

    ${status}  Run Keyword And Return Status  Check If All Cells Are onAir  alias=${node}
    Run Keyword If  '${status}'=='False'
    ...  Fail  Cells are not onAir after recommissioning! Feature deactivated and set test fail !
    ...  ELSE
    ...  Log to console  All cells are onAir !${\n}

    ${time_to_sleep}  ${time_to_verdict}  Time To Sleep  ${INTERVAL}
    Log To Console  Waiting ${time_to_sleep} minutes for re-collect PM counters to check if feature was correctly deactivated !
    Log To Console  Verdict will be released at *${time_to_verdict}* !
    Sleep  ${time_to_sleep} minutes

    Set Test Variable  ${FEATURE_MODE}  ${FALSE}
    ${sbts_counter_len}  Verify EEM Counters And Return Length  SBTS  ${SBTS_COUNTERS}
    ${rfm_counter_len}  Verify EEM Counters And Return Length  RFM  ${RFM_COUNTERS}
    ${sm_counter_len}  Run Keyword If  '${EEM_SMOD}'=='True'
    ...  Verify EEM Counters And Return Length  SM  ${SM_COUNTERS}

    Set Test Variable  ${SBTS_COUNTER_DISABLED}   ${sbts_counter_len}
    Set Test Variable  ${RFM_COUNTER_DISABLED}   ${rfm_counter_len}
    Run Keyword If  '${EEM_SMOD}'=='True'
    ...  Set Test Variable  ${SM_COUNTER_DISABLED}   ${sm_counter_len}

    ${sbts_counter_verdict}  Run Keyword And Return Status  Should Be Equal  ${SBTS_COUNTER_DISABLED}  ${SBTS_COUNTER_ENABLED}
    ${rfm_counter_verdict}  Run Keyword And Return Status  Should Be Equal  ${RFM_COUNTER_DISABLED}  ${RFM_COUNTER_ENABLED}
    ${sm_counter_verdict}  Run Keyword If  '${EEM_SMOD}'=='True'
    ...  Run Keyword And Return Status  Should Be Equal  ${SM_COUNTER_DISABLED}  ${SM_COUNTER_ENABLED}
    ...  ELSE  Set Variable  True

    Run Keyword If  (${sbts_counter_verdict} and ${rfm_counter_verdict} and ${sm_counter_verdict})==True
    ...  Log To Console  Embedded Power Meter feature deactivation was successfull !
    ...  ELSE  Fail  Embedded Power Meter feature deactivation wasn't successfull !

Restore Reference EEM Configuration
    Log To Console    Restoring Reference EEM configuration\n

    Parameters Recommissioning For Power Meter
    ...  actPowerMeter=${REFERENCE_DICT['actPowerMeter']}
    ...  mtBtsEnergyMonitoring=${REFERENCE_DICT['mtBtsEnergyMonitoring']}
    ...  mtSBTSSmEnergyMonitoring=${REFERENCE_DICT['mtSBTSSmEnergyMonitoring']}
    ...  mtSBTSRfmEnergyMonitoring=${REFERENCE_DICT['mtSBTSRfmEnergyMonitoring']}

Get Ids To Verify Counters
    [Arguments]  ${type}

    ${ids}  Run Keyword If  '${type}'=='SBTS'
    ...  admin.Get Ids For All  BTS  alias=${node}
    ...  ELSE IF  '${type}'=='RFM'
    ...  admin.Get Ids For All  RMOD  alias=${node}
    ...  ELSE IF  '${type}'=='SM'
    ...  admin.Get Ids For All  SMOD  alias=${node}

    ${ids_count}  Get Length  ${ids}
    ${ids_count}  Convert To Integer  ${ids_count}

    [Return]  ${ids_count}  ${ids}

Verify EEM Counters And Return Length
    [Arguments]  ${type}  ${counters}

    ${counters_list}  Split string  ${counters}  ,

    ${ids_count}  ${ids}  Get Ids To Verify Counters  ${type}   # zwraca liste id np. 4 RU to 4 id rmodów

    ${pm_counter}  admin.Get Pm Counters  ${counters}  alias=${node}

    ${counters_dict}  Run Keyword If  '${type}'=='RFM'
    ...  Verify RFM Counters  ${pm_counter}  ${ids}
    ...  ELSE IF  '${type}'=='SBTS'
    ...  Verify SBTS Counters  ${pm_counter}  ${ids}
    ...  ELSE
    ...  Verify SM Counters  ${pm_counter}  ${ids}

    ${pm_counters_string}  Convert To String  ${pm_counter}
    ${pm_length}  Get Length  ${pm_counters_string}

    [Return]  ${pm_length}

Verify SBTS Counters
    [Arguments]  ${counters_dict}  ${ids}

    ${bts_keys}    Set Variable If
    ...    ${NEW_COUNTERS_PATH}
    ...    ${counters_dict['BTS']}
    ...    ${counters_dict['BTS']['BTS']}

    ${bts_counter}  Get Length  ${ids}
    ${dict_length}  Get Length  ${bts_keys}

    ${all_bts_status}  Run Keyword And Return Status  Should Be Equal As Integers  ${bts_counter}  ${dict_length}
    # sprawdzenie czy wszystkie RU s? widoczne
    Run Keyword If  '${all_bts_status}'=='False'  Run Keywords
    ...  Log To Console  Counters dictionary doesn't contain all BTS, should be ${bts_counter} BTS, is ${dict_length} BTS !${\n}
    ...  AND  Run Keyword And Continue On Failure  Fail  Counters dictionary doesn't contain all BTS !

    # sprawdzenie czy ka?dy counter per bts jest widoczny oraz walidacja poszczegolnych counterów pod k?tem wartosci
    FOR  ${key}  ${value}  IN ZIP  ${bts_keys.keys()}  ${bts_keys.values()}
        ${counters_dict}  Get From Dictionary  ${value}  SBTS_Energy_Consumption
        Validate Counters  ${counters_dict}  ${SBTS_COUNTERS}  ${key}  1  100000  # pojedynczy bts
    END

    [Return]  ${bts_keys}

Verify RFM Counters
    [Arguments]  ${counters_dict}  ${ids}

    ${rmod_keys}    Set Variable If
    ...    ${NEW_COUNTERS_PATH}
    ...    ${counters_dict['BTS']['MRBTS-${BTS_ID}']['EQM-1']['APEQM-1']}
    ...    ${counters_dict['BTS']['BTS']['MRBTS-${BTS_ID}']}

    ${rmod_counter}  Get Length  ${ids}
    ${dict_length}  Get Length  ${rmod_keys}

    ${all_ru_status}  Run Keyword And Return Status  Should Be Equal As Integers  ${rmod_counter}  ${dict_length}
    # sprawdzenie czy wszystkie RU s? widoczne
    Run Keyword If  '${all_ru_status}'=='False'  Run Keywords
    ...  Log To Console  Counters dictionary doesn't contain all RMODs, should be ${rmod_counter} RU, is ${dict_length} RU !${\n}
    ...  AND  Run Keyword And Continue On Failure  Fail  Counters dictionary doesn't contain all RMODs !

    # sprawdzenie czy ka?dy counter per radio jest widoczny oraz walidacja wartosci 1 <= x <= 60000
    FOR  ${key}  ${value}  IN ZIP  ${rmod_keys.keys()}  ${rmod_keys.values()}
        Continue For Loop If  '${key}' in ${NOT_EE_RMODS}
        ${counters_dict}  Get From Dictionary  ${value}  SBTS_RFM_Energy_Monitoring
        Validate Counters  ${counters_dict}  ${RFM_COUNTERS}  ${key}  1  1000000  # pojedyncze radio
    END

    [Return]  ${rmod_keys}

Verify SM Counters
    [Arguments]  ${counters_dict}  ${ids}

    ${smods}  admin.Get Parameters For All  SMOD  alias=${node}

    ${not_as_counter}  Set Variable  ${0}
    FOR  ${smod}  IN  @{smods}
        ${not_as_counter}  Set Variable If  'AirScale' not in '${smod['productName']}'  ${not_as_counter+1}  ${not_as_counter}
    END

    ${smod_counter}  Evaluate  len(${ids}) - ${not_as_counter}

    ${smod_keys}    Set Variable If
    ...    ${NEW_COUNTERS_PATH}
    ...    ${counters_dict['BTS']['MRBTS-${BTS_ID}']['EQM-1']['APEQM-1']}
    ...    ${counters_dict['BTS']['SMOD']}

    ${dict_length}  Get Length  ${smod_keys['CABINET-1']}

    ${all_smod_status}  Run Keyword And Return Status  Should Be Equal As Integers  ${smod_counter}  ${dict_length}
    # sprawdzenie czy wszystkie RU s? widoczne
    Run Keyword If  '${all_smod_status}'=='False'  Run Keywords
    ...  Log To Console  Counters dictionary doesn't contain all AirScale SMODs, should be ${smod_counter} SMOD, is ${dict_length} SMOD !${\n}
    ...  AND  Run Keyword And Continue On Failure  Fail  Counters dictionary doesn't contain all AirScale SMODs !

    Run Keyword If    ${NEW_COUNTERS_PATH}
    ...    Validate SM Counters For New Path    ${smod_keys}
    ...    ELSE    Validate SM Counter For Old Path    ${smod_keys}

    [Return]  ${smod_keys}

Validate SM Counter For Old Path
    [Arguments]    ${smod_keys}

    FOR  ${key}  ${value}  IN ZIP  ${smod_keys.keys()}  ${smod_keys.values()}
        ${cabinets}  Get Dictionary Keys  ${value}
        ${counters_dict}  Get From Dictionary  ${value}  ${cabinets}[0]
        ${counters_dict}  Get From Dictionary  ${counters_dict}  SBTS_SM_Energy_Monitoring
        Validate Counters  ${counters_dict}  ${SM_COUNTERS}  ${key}  1  1000000  # pojedynczy airscale
    END

Validate SM Counters For New Path
    [Arguments]    ${smod_keys}

    FOR  ${key}  ${value}  IN ZIP  ${smod_keys.keys()}  ${smod_keys.values()}
        Iterator For Validate SM Counter For New Path    ${value}
    END

Iterator For Validate SM Counter For New Path
    [Arguments]    ${dict}

    FOR    ${smod}  ${counters}    IN ZIP  ${dict.keys()}  ${dict.values()}
        ${counters_dict}  Get From Dictionary  ${counters}  SBTS_SM_Energy_Monitoring
        Validate Counters  ${counters_dict}  ${SM_COUNTERS}  ${smod}  1  1000000  # pojedynczy airscale
    END

Validate Counters
    [Arguments]  ${counters_dict}  ${type}  ${key}  ${min_value}  ${max_value}

    ${keys}  Get Dictionary Keys  ${counters_dict}
    ${is_equal}  Evaluate  sorted(${keys}) == sorted('${type}'.split(','))

    Log to console  ${\n}Validating counters: ${type} for ${key}${\n}
    Log to console  Every counter must be in range ${min_value} <= COUNTER_VALUE <= ${max_value}${\n}
    ${verdict_list}  Create List
    FOR  ${counter}  ${values}  IN ZIP  ${counters_dict.keys()}  ${counters_dict.values()}
        ${mV_values}  ${timestamps}  Get Counter Values To Validate  ${values}
        ${in_range}  Evaluate  all(float(${min_value}) <= float(x) <= float(${max_value}) for x in ${mV_values})
        Append To List  ${verdict_list}  ${in_range}
        Run Keyword If  '${in_range}'=='True'
        ...  Log to console  Validating ${counter} -> PASS
        ...  ELSE
        ...  Log to Console  Validating ${counter} -> FAIL
    END

    ${validate_status}  Run Keyword And Return Status  List Should Not Contain Value  ${verdict_list}  ${FALSE}
    Run Keyword If  '${validate_status}'=='False'  Run Keywords
    ...  Log To Console  At least one counter doesn't meet condition ${min_value} <= counter_value <= ${max_value} !${\n}
    ...  AND  Run Keyword And Continue On Failure  Fail
    ...  At least one counter doesn't meet condition ${min_value} <= counter_value <= ${max_value} !

Get Counter Values To Validate
    [Arguments]  ${values}

    ${substracted_dict}  Evaluate  {k: v for k, v in ${values}.items() if int(k) >= ${START_TIME}}
    Run Keyword If  not ${substracted_dict}
    ...  Fail  No new counters collected during last ${INTERVAL} minutes !
    ${mV_values}  Get Dictionary Values  ${substracted_dict}
    ${timestamps}  Get Dictionary Keys  ${substracted_dict}

    Return From Keyword If  len(${timestamps}) == 1  ${mV_values}  ${timestamps}
    ${two_first_timestamp_diff}  Evaluate  ${timestamps}[1] - ${timestamps}[0]
    ${mv_values_return}  Set Variable If  ${two_first_timestamp_diff} == 60  ${mV_values}[1:]  ${mV_values}

    [Return]  ${mv_values_return}  ${timestamps}

#Check If Timestamp Is In Range
#   [Arguments]  ${timestamp}  ${range}  ${feature_mode}  ${offset}=0
#    [Documentation]  1epoch = 1 second, 3minutes = 180 epoch
#
#    ${current_time}  Evaluate  int((__import__('datetime').datetime.now().timestamp()))
#
#    ${status}  Run Keyword If  ${feature_mode}
#    ...  Evaluate
#    ...  ${current_time} - int(${range}/2) - int(${offset}) <= ${timestamp} <= ${current_time} - int(${range}/2)
#    ...  ELSE
#    ...  Evaluate
#    ...  ${current_time} - int(${range}/2) - int(${offset}) - 900 <= ${timestamp} <= ${current_time} + int(${range}/2) - int(${offset})
#
#    [Return]  ${status}

Parameters Recommissioning For Power Meter
    [Arguments]  ${actPowerMeter}  ${mtBtsEnergyMonitoring}  ${mtSBTSSmEnergyMonitoring}  ${mtSBTSRfmEnergyMonitoring}

    Create Delta
    Append Parameter Update To Delta   ${object_variable_actPowerMeter}  actPowerMeter  ${actPowerMeter}
    Append Parameter Update To Delta   ${object_variable_mtBtsEnergyMonitoring}  mtBtsEnergyMonitoring  ${mtBtsEnergyMonitoring}
    Append Parameter Update To Delta   ${object_variable_mtBtsEnergyMonitoring}  mtSBTSSmEnergyMonitoring  ${mtSBTSSmEnergyMonitoring}
    Append Parameter Update To Delta   ${object_variable_mtBtsEnergyMonitoring}  mtSBTSRfmEnergyMonitoring  ${mtSBTSRfmEnergyMonitoring}

    Log To Console  actPowerMeter -> ${actPowerMeter} <- added to delta
    Log To Console  mtBtsEnergyMonitoring -> ${mtBtsEnergyMonitoring} <- added to delta
    Log To Console  mtSBTSSmEnergyMonitoring -> ${mtSBTSSmEnergyMonitoring} <- parameter added to delta
    Log To Console  mtSBTSRfmEnergyMonitoring -> ${mtSBTSRfmEnergyMonitoring} <- parameter added to delta

     ${delta}  Get Delta
     Log To Console  Energy Efficiency parameters recommissioning, please wait !
     admin.Perform Delta Recommissioning  ${delta}  skip_parameter_relation_errors=True  alias=${node}
     Remove Delta


Check Interval
    [Arguments]  ${int}

    @{available_intervals}=  Create List  15  30  60  360  720  1440
    ${interval_status}=  Run Keyword And Return Status  List Should Contain Value  ${available_intervals}  ${int}
    Set Test Variable  ${interval_status_teardown}  ${interval_status}
    Run Keyword If  ${interval_status}==False  Fail  Given interval ${int} does't meet condition. Allowed values 15 30 60 360 720 1440.
    ...  ELSE  Log To Console  Given interval ${int} is correct.

Get Enegry Efficiency Parameters From SCF

    ${reference_dict}  Create Dictionary
    ${parameter}  admin.Get Scf  export_type=configurationAndRuntimeObjects  parameters_save_variant=actualValues  alias=${node}
    ${scfc_xml}  Parse XML  source=${parameter}
    ${actpowermeter_scf}  Evaluate Xpath  ${scfc_xml}
    ...  string(.//managedObject[@distName='${OBJECT_VARIABLE_ACTPOWERMETER}']/p[@name='actPowerMeter']/text())
    ${mtBtsEnergyMonitoring_scf}  Evaluate Xpath  ${scfc_xml}
    ...  string(.//managedObject[@distName='${OBJECT_VARIABLE_MTBTSENERGYMONITORING}']/p[@name='mtBtsEnergyMonitoring']/text())
    ${mtSBTSsm_scf}  Evaluate Xpath  ${scfc_xml}
    ...  string(.//managedObject[@distName='${OBJECT_VARIABLE_MTBTSENERGYMONITORING}']/p[@name='mtSBTSSmEnergyMonitoring']/text())
    ${mtSBTSRfm_scf}  Evaluate Xpath  ${scfc_xml}
    ...  string(.//managedObject[@distName='${OBJECT_VARIABLE_MTBTSENERGYMONITORING}']/p[@name='mtSBTSRfmEnergyMonitoring']/text())
    Set To Dictionary  ${reference_dict}
    ...  mtBtsEnergyMonitoring=${mtBtsEnergyMonitoring_scf}
    ...  actPowerMeter=${actpowermeter_scf}
    ...  mtSBTSSmEnergyMonitoring=${mtSBTSsm_scf}
    ...  mtSBTSRfmEnergyMonitoring=${mtSBTSRfm_scf}

    [Return]   ${reference_dict}

Get Not Supported EE RMODs
    ${rmod_runtime_id_list}  Create List
    ${real_time_meas}  admin.Get Measurements  realTime  connection=${node}
    FOR  ${row}  IN  @{real_time_meas}
        ${distname}  Get Dictionary Keys  ${row}
        Continue For Loop If    'RMOD' not in '${distname}[0]'
        ${measures}  Get Dictionary Values  ${row}
        Run Keyword If  'Not supported' in ${measures}
        ...  Append To List  ${rmod_runtime_id_list}  ${distname[0].rsplit('/', 1)[-1]}
    END

    ${rmod_config_id_list}  Create List
    ${frm_info}  admin.Get FRM  connection=${node}
    FOR  ${info}  IN  @{frm_info}
        ${rmod_runtime_id}  Set Variable  ${info['id']['runtime'].rsplit('/', 1)[-1]}
        Run Keyword If  '${rmod_runtime_id}' in ${rmod_runtime_id_list}
        ...  Append To List  ${rmod_config_id_list}  ${info['id']['configuration'].rsplit('/', 1)[-1]}
    END

    [Return]  ${rmod_config_id_list}








*** Settings ***
Documentation
    ...  The purpose of this Test Case is to check the activation and deactivation for Embedded Power Meter
    ...  for Enegry Efficiency Monitoring.
    ...  Power Meter is capable of measure power consumption (DC voltage and amperage) in RF and SM.
    ...  TC includes checking the display PM Counters for SBTS Enegry Consumption and Real Time Measurements.
    ...  Additional for Real-Time Measurements is checking voltage values for all modules (RMOD(s) and SMOD(s)) in configuration.
    ...  Voltage values are collecting for 5 minutes.
    ...  For FSM-r3 should be visible "0" in voltage field because FSM-r3 do not have Power Meter units.
    ...  For RMODs which doesn't support EEM in voltage field should be visible "0"
    ...  Voltage for FSM-r4 and all supported RMODs should be between 48-56V.

Resource  ../../common_resources/ca_CIT_general.robot


*** Variables ***
${INTERVAL}  15  # for parameter: mtBtsEnergyMonitoring. Please enter only the number. Available intervals in minutes: 15,30,60,360,720,1440
${RMODS}  ${EMPTY}  # Please specify how many RMODs in configuration support Embedded Power Meter feature.


*** Keywords ***
TC__BS-RF__Embedded_Power_Meter_EEM_act_deact_in_WebEM__RP000951__Automated
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-11060
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 08.08.2018 - https://jira3.int.net.nokia.com/browse/TAT-11060 - Initial creation
    ...  - 15.11.2018 - https://jira3.int.net.nokia.com/browse/TAT-13191 - Fix related with amount of unsupported RMODs and collecting snapshot
    ...  - 13.02.2019 - https://jira3.int.net.nokia.com/browse/TAT-14532 - Changed method for time to wait for Energy Efficiency Monitoring
    ...  - 04.06.2019 - https://jira3.int.net.nokia.com/browse/TAT-16468 - Independence from path in KW "Collect PM Counters"
    ...  - 12.07.2019 - https://jira3.int.net.nokia.com/browse/TAT-16793 - Added voltage checking for SMOD(s)
    ...  - 23.07.2019 - https://jira3.int.net.nokia.com/browse/TAT-16970 - Added voltage checking for RMOD(s)
    ...  - 19.11.2019 - https://jira3.int.net.nokia.com/browse/TAT-18255 - Shorten TC name
    ...  - 27.12.2019 - https://jira3.int.net.nokia.com/browse/TAT-18661 - Change in timing mechanism
    ...  - 18.08.2021 - https://jira3.int.net.nokia.com/browse/TAT-21754 - Changes due to CNI-61110
    ...  - 14.12.2021 - https://jira3.int.net.nokia.com/browse/TAT-22332 - Values "Not supported" and "Not avaialable" changed to 0
    ...  - 21.03.2022 - https://jira3.int.net.nokia.com/browse/TAT-22729 - SMOD Counter value verification
    ...  - 01.08.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23484 - PM modules may has value "-" instead of "0"
    ...  - 20.09.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-26057 - Fix compatibility wth python 3
    ...  - 21.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26540 - Adapt TC to CB009480
    ...  - 05.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26673 - Add suport for branch

    Set Tags  CA-BS-RF  OWNER-mateusz.kawka@nokia.com  AUTHOR-mateusz.kawka@nokia.com  MAINTAINER-mateusz.kawka@nokia.com  GROUP_IN_CHARGE-WRO_3_Vrf
    ...  PHASE-CIT  SW-SBTS17A  SW-SBTS18  FEATURE-RP000951  FEATURE-RP001486_2  FEATURE-RP001145_1

    Step1: Preconditions
    Step2: Enable Embedded Power Meter
    Step3: Check Voltage On Modules
    Step4: Check SMOD Power Consumption
    Step5: Disable Embedded Power Meter


Step1: Preconditions
    Log To Console  ${\n}step1: Preconditions${\n}
    ${bts_id}  Admin Get Bts Id
    Set Test Variable  ${BTS_ID}
    Set Test Variable  ${OBJECT_VARIABLE_ACT_POWER_METER}  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    Set Test Variable  ${OBJECT_VARIABLE_MT_BTS_ENERGY_MONITORING}  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMMNL-1
    Check Interval  ${INTERVAL}
    Check Number Of RMODS  ${RMODS}


Step2: Enable Embedded Power Meter
    Log To Console  ${\n}step2: Enable Power Meter Feature${\n}
    Parameters Recommissioning And Check Cells  true  ${INTERVAL}min
    Log To Console  ${\n}Waiting max. 10 minutes for Real-time measurements ! Attempt to read every minute !${\n}
    Wait Until Keyword Succeeds  10x  1 minute
    ...  Check Energy Efficiency Monitoring
    FOR  ${row}  IN  @{LIST_OF_MEASUREMENTS}
        ${keys}  Get Dictionary Keys  ${row}
        ${status}  Run Keyword And Return Status
        ...  Should Contain Match  ${keys}  regexp=ENERGY
        Run Keyword If  ${status}==True
        ...  Log To Console  ${row}
    END
    Verdict For EEM  should_be_collected=True
    ${time_to_sleep}  ${time_to_verdict}  Time For Sleep  ${INTERVAL}
    Log To Console  Waiting for ${time_to_sleep} minutes to Get PM Counters ! ${\n}Verdict will be released at *${time_to_verdict}* !
    Sleep  ${time_to_sleep} minutes
    Collect PM Counters


Step3: Check Voltage On Modules
    Log To Console  ${\n}Step3: Check Voltage On Modules${\n}
    ${smods_parameters}  Get Parameters For All  SMOD
    ${modules_ids}  Create List
    ${modules_product_names}  Create List
    FOR  ${smod}  IN  @{smods_parameters}
        ${smod_id}  Evaluate  ('/'.join('${smod['id']}'.split('/')[-2:]))
        Append To List  ${modules_ids}  ${smod_id}
        Append To List  ${modules_product_names}  ${smod['productName']}
    END
    ${rmods_parameters}  Get Parameters For All  RMOD
    FOR  ${rmod}  IN  @{rmods_parameters}
        ${rmod_id}  Evaluate  ('${rmod['id']}'.split('/')[-1])
        Append To List  ${modules_ids}  ${rmod_id}
        Append To List  ${modules_product_names}  ${rmod['productName']}
    END
    ${modules_product_names}  Evaluate
    ...  [link.replace('Flexi System Module Outdoor FSMF','FSMF').replace('ASIA AirScale Common','AirScale') for link in ${modules_product_names}]
    ${dict_of_modules}  Evaluate  ({i:[] for i in ${modules_ids}})
    Set Test Variable  ${DICT_OF_MODULES}  ${dict_of_modules}
    Set Test Variable  ${MODULES_PRODUCT_NAMES}  ${modules_product_names}
    ${minutes_to_collect_voltage}  Set Variable  ${5}
    Set Test Variable  ${MINUTES_TO_COLLECT_VOLTAGE}  ${minutes_to_collect_voltage}
    Log To Console
    ...  Waiting ${MINUTES_TO_COLLECT_VOLTAGE} minutes to collect ${MINUTES_TO_COLLECT_VOLTAGE} voltage measurements for all modules !${\n}
    FOR  ${minute}  IN RANGE  ${MINUTES_TO_COLLECT_VOLTAGE}
        ${dict_with_measurements}  Append Voltage To Dict
        Exit For Loop If  ${minute}==${MINUTES_TO_COLLECT_VOLTAGE-1}
        Sleep  1 minute
    END
    ${modules_parameters}  Combine Lists  ${smods_parameters}  ${rmods_parameters}
    Log To Console  Note:${\n}FSMF has no Power Meter Unit, so all voltage fields should have "0"${\n}
    Log To Console  If RMOD doesn't support EEM, all voltage fields should have "0"
    Log To Console  All modules that support EEM should return valid numeric values${\n}
    Sleep  10s
    FOR  ${module}  ${module_id}  ${module_product_name}  IN ZIP  ${modules_parameters}  ${modules_ids}  ${MODULES_PRODUCT_NAMES}
        Log To Console  ${module_product_name} -> ${module_id} !
        ${voltage_from_dict}  Get From Dictionary  ${dict_with_measurements}  ${module_id}
        Run Keyword If  'FSMF' in '${module['productName']}'
        ...  Check Voltage Values For FSMF  ${voltage_from_dict}
        ...  ELSE IF  'AirScale' in '${module['productName']}'
        ...  Check Voltage Values For AirScale  ${voltage_from_dict}
        ...  ELSE
        ...  Check Voltage Values For RMOD  ${voltage_from_dict}  ${module_id}  ${module_product_name}
    END
    Log To Console  Voltage values for all modules are OK, going to next step !


Step4: Check SMOD Power Consumption
    Log To Console  ${\n}Step4: Check SMOD Power Consumption${\n}
    ${time_to_sleep}  ${time_to_verdict}  Time For Sleep  ${INTERVAL}
    Log To Console  Waiting ${time_to_sleep} minutes for re-collect PM counters to check power consumption! ${\n}
    Log To Console  Verdict will be released at *${time_to_verdict}* !
    Sleep  ${time_to_sleep} minutes
    Collect PM Counters
    Set Test Variable  ${PM_LENGTH_AFTER_SLEEP}  ${PM_LENGTH_COLLECTED}
    Log To Console  Checking SMOD with sub-modules power consumption based on collected counter M40002C0!\n
    ${module_id_dict}  Create Dictionary
    ${smods}  Get Parameters For All  SMOD
    ${counter}  Set Variable  ${1}
    FOR  ${smod}  IN  @{smods}
        ${short_id}  Evaluate  '${smod['id']}'.split('/', 7)[-1]
        Run Keyword If  'FSMF' in '${smod['productName']}'
        ...  Set To Dictionary  ${module_id_dict}  FSMF_${counter}  ENERGY_EFFICIENCY/SMOD/${short_id}
        ...  ELSE IF  'AirScale' in '${smod['productName']}'
        ...  Set To Dictionary  ${module_id_dict}  AirScale_${counter}  ENERGY_EFFICIENCY/SMOD/${short_id}
        ${counter}  Evaluate  ${counter}+1
    END
    Log To Console  Collecting current power consumption measurement !${\n}
    ${measurements_list}  Get Measurements  realTime
    ${power_cons_sum}  Set Variable  ${0}
    FOR  ${module}  ${id}  IN ZIP  ${module_id_dict.keys()}  ${module_id_dict.values()}
        ${match}  Evaluate  [s for s in ${measurements_list} if '${id}' in s][0]
        ${value_dict}  Get From Dictionary  ${match}  ${id}
        ${real_power}  Get From Dictionary  ${value_dict}  power
        ${cabinet}  Get Regexp Matches  ${id}  CABINET_R-\\d+
        Run Keyword If  'FSMF' in '${module}'
        ...  Run Keywords
        ...  Calculate Static FSMF Power Consumption  ${cabinet}[0]
        ...  AND
        ...  Check Static FSMF Power  ${real_power}
        ...  AND
        ...  Log To Console  FSMF power consumption: ${real_power} W
        ...  ELSE IF  'AirScale' in '${module}'
        ...  Log To Console  AirScale power consumption: ${real_power} W
        ${power_cons_sum}  Evaluate  ${power_cons_sum}+${real_power}
    END
    ${power_cons_sum_kwh}  Evaluate  ${power_cons_sum}/1000
    ${power_cons_per_minute}  Evaluate  (${power_cons_sum_kwh}/60)
    ${power_cons_per_inteval}  Evaluate  ${power_cons_per_minute}*${INTERVAL}
    ${power_cons_counter}  Evaluate  ${power_cons_per_inteval}*100000
    ${dict}  Set Variable If  '${ENB_BRANCH}'=='SBTS00' or '${ENB_BRANCH}'>='SBTS24R2'  ${PM_COUNTERS}[BTS][MRBTS-${BTS_ID}][SBTS_Energy_Consumption]
    ...  ${PM_COUNTERS}[BTS][BTS][MRBTS-${BTS_ID}][SBTS_Energy_Consumption]
    ${smod_counters}  Get From Dictionary  ${dict}  M40002C0
    ${counter_values}  Get Dictionary Values  ${smod_counters}
    ${last_counter}  Get From List  ${counter_values}  -1
    ${in_range}  Evaluate  ${power_cons_counter-100} <= ${last_counter} <= ${power_cons_counter+100}
    Run Keyword If  '${in_range}'=='True'
    ...  Log To Console  Power Consumption counter M40002C0 for all SMOD(s) is CORRECT !
    ...  ELSE
    ...  Fail
    ...  Power Consumption counter M40002C0 for all SMOD(s) is INCORRECT! Expected value ${power_cons_counter} +/-100, actual values: ${last_counter}


Step5: Disable Embedded Power Meter
    Log To Console  ${\n}step5: Disable Energy Efficiency monitoring${\n}
    Parameters Recommissioning And Check Cells  false  disabled
    Reset Admin  # to refresh admin and clear real-time logs
    Log To Console  ${\n}Waiting max. 5 minutes for empty Real-time measurements ! Attempt to read every minute !${\n}
    Wait Until Keyword Succeeds  5x  1 minute
    ...  Run Keyword And Expect Error  *
    ...  Check Energy Efficiency Monitoring
    Verdict For EEM  should_be_collected=False
    ${time_to_sleep}  ${time_to_verdict}  Time For Sleep  ${INTERVAL}
    Log To Console  Waiting ${time_to_sleep} minutes for re-collect PM counters to check if feature was correctly deactivated ! ${\n}
    Log To Console  Verdict will be released at *${time_to_verdict}* !
    Sleep  ${time_to_sleep} minutes
    Collect PM Counters
    Set Test Variable  ${PM_LENGTH_DISABLE}  ${PM_LENGTH_COLLECTED}
    ${pm_length_compare}  Run Keyword And Return Status
    ...  Should Be Equal  ${PM_LENGTH_AFTER_SLEEP}  ${PM_LENGTH_DISABLE}
    Run Keyword If  ${pm_length_compare}==True
    ...  Log To Console  Embedded Power Meter feature deactivation was successfull !
    ...  ELSE
    ...  Run Keyword And Continue On Failure
    ...  Fail  Embedded Power Meter feature deactivation wasn't successfull !


Check Static FSMF Power
    [Arguments]  ${real_power}

    ${real_power_kwh}  Evaluate  ${real_power}/1000
    ${status}  Run Keyword And Continue On Failure
    ...  Should Be Equal As Numbers  ${real_power_kwh}
    ...  ${FSMF_WITH_MODULES_CONS}
    ...  Power in WebEM for FSMF is other than static ${FSMF_WITH_MODULES_CONS}kWh!


Calculate Static FSMF Power Consumption
    [Arguments]  ${cabinet}

    ${fsmf_cons}  Set Variable  ${0.125}  # power consumption in kWh
    ${fbba_cons}  Set Variable  ${0.085}
    ${fbbc_cons}  Set Variable  ${0.091}
    ${fsmf_counter}  Set Variable  ${0}
    ${fbba_counter}  Set Variable  ${0}
    ${fbbc_counter}  Set Variable  ${0}
    ${smods}  Get Parameters For All  SMOD
    FOR  ${smod}  IN  @{smods}
        Continue For Loop If  '${cabinet}' not in '${smod['id']}'
        ${fsmf_counter}  Set Variable If  'FSMF' in '${smod['productName']}'  ${fsmf_counter+1}  ${fsmf_counter}
    END
    ${fbbs}  Get Parameters For All  BBMOD
    FOR  ${fbb}  IN  @{fbbs}
        Continue For Loop If  '${cabinet}' not in '${fbb['id']}'
        ${fbba_counter}  Set Variable If  'FBBA' in '${fbb['productName']}'  ${fbba_counter+1}  ${fbba_counter}
        ${fbbc_counter}  Set Variable If  'FBBC' in '${fbb['productName']}'  ${fbbc_counter+1}  ${fbbc_counter}
    END
    ${sum}  Evaluate  ${fsmf_counter}+${fbbc_counter}+${fbba_counter}
    ${fsmf_with_modules_cons}  Evaluate  (${fsmf_counter}*${fsmf_cons})+(${fbba_counter}*${fbba_cons})+(${fbbc_counter}*${fbbc_cons})
    Set Test Variable  ${FSMF_COUNTER}
    Set Test Variable  ${FBBC_COUNTER}
    Set Test Variable  ${FBBA_COUNTER}
    Set Test Variable  ${FSMF_WITH_MODULES_CONS}


Check Voltage Values For RMOD
    [Arguments]  ${voltage}  ${rmod}  ${rmod_name}

    Run Keyword If  0 in ${voltage}
    ...  Check Unsupported RMOD  ${voltage}  ${rmod}  ${rmod_name}
    ...  ELSE
    ...  Check Voltage For Supported RMOD  ${voltage}  ${rmod}


Check Unsupported RMOD
    [Arguments]  ${voltage}  ${rmod}  ${rmod_name}

    ${not_supported_count}  Evaluate  ${voltage}.count(0)
    ${not_supported_status}  Run Keyword And Return Status
    ...  Should Be Equal  ${not_supported_count}  ${MINUTES_TO_COLLECT_VOLTAGE}
    Run Keyword If  ${not_supported_status}==False
    ...  Run Keywords
    ...  Log To Console  For ${rmod} should be '0' in all voltage fields because doesn't support EEM,
    ...  found ${not_supported_count} out of ${MINUTES_TO_COLLECT_VOLTAGE} !
    ...  AND
    ...  Set Test Failed  ${rmod} doesn't support EEM so all voltage fields should have "0" but don't have !
    ...  ELSE
    ...  Run Keywords
    ...  Log To Console  For ${rmod_name} found ${not_supported_count} out of ${MINUTES_TO_COLLECT_VOLTAGE} "0",
    ...  AND
    ...  Log To Console  Real-Time measurements for ${rmod} are OK !${\n}


Check Voltage For Supported RMOD
    [Arguments]  ${voltage}  ${rmod}

    ${rmod_voltage}  Evaluate  ([float(i) for i in ${voltage}])
    ${average_voltage}  Evaluate  (round(sum(i for i in ${rmod_voltage})/len(${rmod_voltage}),2))
    ${verdict}  Evaluate  (48<=${average_voltage}<=56)
    Run Keyword If  '${verdict}'=='True'
    ...  Log To Console  Average voltage: ${average_voltage} V${\n}
    ...  ELSE
    ...  Run Keywords
    ...  Log To Console  Average voltage for ${rmod}: ${average_voltage} V so is not in range 48-56 V !
    ...  AND
    ...  Set Test Failed  Average voltage for ${rmod} is ${average_voltage} V so is not in range 48-56 V !


Check Voltage Values For FSMF
    [Arguments]  ${voltage}

    ${not_available_count}  Evaluate  ${voltage}.count(0)
    ${not_available_status}  Run Keyword And Return Status
    ...  Should Be Equal  ${not_available_count}  ${MINUTES_TO_COLLECT_VOLTAGE}
    Run Keyword If  ${not_available_status}==False
    ...  Run Keywords
    ...  Log To Console  For FSMF should be '0' in all voltage fields because has no Power Meter Unit,
    ...  found ${not_available_count} out of ${MINUTES_TO_COLLECT_VOLTAGE} !
    ...  AND
    ...  Set Test Failed  FSMF has no Power Meter Unit so all voltage fields should have "0" but don't have !
    ...  ELSE
    ...  Log To Console  Found ${not_available_count} out of ${MINUTES_TO_COLLECT_VOLTAGE} "0", Real-Time measurements OK !${\n}


Check Voltage Values For AirScale
    [Arguments]  ${voltage}

    ${voltage_rel4}  Evaluate  ([float(i) for i in ${voltage}])
    ${average_voltage}  Evaluate  (round(sum(i for i in ${voltage_rel4})/len(${voltage_rel4}),2))
    ${verdict}  Evaluate  (48<=${average_voltage}<=56)
    Run Keyword If  '${verdict}'=='True'
    ...  Log To Console  Average voltage: ${average_voltage} V${\n}
    ...  ELSE
    ...  Run Keywords
    ...  Log To Console  Average voltage: ${average_voltage} V so is not in range 48-56 V !${\n}
    ...  AND
    ...  Set Test Failed  Average voltage is ${average_voltage} V so is not in range 48-56 V !


Append Voltage To Dict
    FOR  ${key}  IN  @{DICT_OF_MODULES.keys()}
        ${voltage}  Get Voltage For Module  ${key}
        Append To List  ${DICT_OF_MODULES}[${key}]  ${voltage}
    END
    FOR  ${key}  ${value}  IN ZIP  ${DICT_OF_MODULES.keys()}  ${DICT_OF_MODULES.values()}
        ${voltage_values}  Evaluate  ${DICT_OF_MODULES}\['${key}']
        Log To Console  ${key}: ${voltage_values}
    END
    Log To Console  ${\n}

    [Return]  ${DICT_OF_MODULES}


Get Voltage For Module
    [Arguments]  ${module}

    ${measurement}  Get Measurements
    FOR  ${key}  IN  @{measurement}
        ${dict_key}  Get Dictionary Keys  ${key}
        ${dict_value}  Get Dictionary Values  ${key}
        Continue For Loop If  ('ENERGY_EFFICIENCY' not in '${dict_key}[0]') or ('${module}' not in '${dict_key}[0]')
        ${voltage}  Set Variable  ${dict_value}[0][voltage]
    END

    [Return]  ${voltage}


Parameters Recommissioning And Check Cells
    [Arguments]  ${param_act_power_meter}  ${param_mt_bts}

    Log To Console  Updating actPowerMeter parameter to ${param_act_power_meter} ...
    Perform Parameter Recommissioning  ${OBJECT_VARIABLE_ACT_POWER_METER}  actPowerMeter  update  ${param_act_power_meter}
    ...  skip_parameter_relation_errors=true
    Run Keyword If  '${param_mt_bts}'=='disabled'
    ...  Log To Console  Updating mtBtsEnergyMonitoring parameter to disabled
    ...  ELSE
    ...  Log To Console  Updating mtBtsEnergyMonitoring parameter to ${INTERVAL} minutes ...
    Perform Parameter Recommissioning  ${OBJECT_VARIABLE_MT_BTS_ENERGY_MONITORING}  mtBtsEnergyMonitoring  update  ${param_mt_bts}
    ...  skip_parameter_relation_errors=true
    Log To Console  Checking if all cells are still onAir after recommissioning
    ${status}  Run Keyword And Return Status
    ...  Check If All Cells Are OnAir
    Run Keyword If  '${status}'=='False'
    ...  Run Keywords
    ...  Perform Parameter Recommissioning  ${OBJECT_VARIABLE_ACT_POWER_METER}  actPowerMeter  update  false
    ...  AND
    ...  Fail  At least one cell is NOT onAir after recommissioning! Feature deactivated and set test failed !
    ...  ELSE
    ...  Log To Console  All cells are onAir !${\n}


Collect PM Counters
    Log To Console  Collecting PM Counters ...
    ${status}  ${pm_counters}  Run Keyword And Ignore Error
    ...  coam.Get Pm Counters  M40002C0,M40002C1,M40002C2  timeout=120
    Run Keyword If  '${status}'=='FAIL'
    ...  Run Keywords
    ...  Log To Console  Cannot Get PM Counters, feature deactivating and set test failed !
    ...  AND
    ...  Parameters Recommissioning And Check Cells  false  disabled
    ...  AND
    ...  Fail  Cannot Get PM Counters, probably not visible in WebEM !
    ${path}  ${pm_counters_string}  Evaluate  (str(${pm_counters}).split(':', 1))
    ${pm_status}  Run Keyword And Return Status
    ...  Should Contain X Times  ${pm_counters_string}  M40002C  3
    Run Keyword If  ${pm_status}==False
    ...  Set Test Failed  Collected PM Counters don't contain expected counters !  fail_fast=True
    Run Keyword If  ${pm_status}==True
    ...  Log To Console  PM Counters was successfull collected for M40002C0,M40002C1,M40002C2 !
    ${pm_length}  Get Length  ${pm_counters_string}
    Set Test Variable  ${PM_LENGTH_COLLECTED}  ${pm_length}
    Set Test Variable  ${PM_COUNTERS}


Check Energy Efficiency Monitoring
    ${list_of_measurements}  Get Measurements
    ${eem_rmod_list}  Create List
    ${eem_smod_list}  Create List
    FOR  ${key}  IN  @{list_of_measurements}
        ${string_key}  Convert To String  ${key}
        Continue For Loop If  'ENERGY_EFFICIENCY' not in "${string_key}"
        Run Keyword If  'RMOD' in "${string_key}"
        ...  Append To List  ${eem_rmod_list}  ${key}
        ...  ELSE IF  'SMOD' in "${string_key}"
        ...  Append To List  ${eem_smod_list}  ${key}
    END
    ${status_list}  Create List
    FOR  ${measure}  IN  @{eem_rmod_list}
        ${measures}  Get Dictionary Values  ${measure}
        ${measured_values}  Get Dictionary Values  ${measures}[0]
        ${measured_values}  Evaluate  list(map(lambda x: x.replace('-', '0'), ${measured_values}))
        ${status}  Evaluate  all(float(x) > 0 for x in ${measured_values})
        Append To List  ${status_list}  ${status}
    END
    ${rmods_list}  Get Ids For All  RMOD
    ${rmods_number}  Get Length  ${rmods_list}
    ${exp_unsupported_rmods}  Evaluate  (${rmods_number}-${RMODS})
    ${collected_unsupp_rmods}  Evaluate  ${status_list}.count(False)
    ${collected_supp_rmods}  Evaluate  ${status_list}.count(True)
    ${rmods_occur}  Get Length  ${status_list}
    ${get_status}  Run Keywords
    ...  Should Be Equal  ${exp_unsupported_rmods}  ${collected_unsupp_rmods}
    ...  AND
    ...  Should Be Equal  ${rmods_occur}  ${rmods_number}
    ...  AND
    ...  Should Not Be Empty  ${eem_smod_list}
    ${eem_list}  Combine Lists  ${eem_smod_list}  ${eem_rmod_list}
    Set Test Variable  ${LIST_OF_MEASUREMENTS}  ${eem_list}
    Set Test Variable  ${GET_STATUS}  ${get_status}
    Set Test Variable  ${COLLECTED_SUPP_RMODS}  ${collected_supp_rmods}
    Set Test Variable  ${COLLECTED_UNSUPP_RMODS}  ${collected_unsupp_rmods}


Verdict For EEM
    [Arguments]  ${should_be_collected}

    ${collected_message}  Catenate  Energy Efficiency counter has been collected --> Power Meter Feature activation completed successfull ! ${\n}
    ...  Supported RMODs given by user: ${RMODS} ${\n} Supported RMODs in WebEM: ${COLLECTED_SUPP_RMODS} ${\n}
    ...  Unsupported RMODs in WebEM: ${COLLECTED_UNSUPP_RMODS}${\n}
    Run Keyword If  ${GET_STATUS}==False and ${should_be_collected}==True
    ...  Run Keywords
    ...  Log To Console  ${LIST_OF_MEASUREMENTS}
    ...  AND
    ...  Set Test Failed  Power Meter Feature wasn't enabled or cannot collect Energy Efficiency counter!  fail_fast=True
    ...  ELSE IF  ${GET_STATUS}==True and ${should_be_collected}==False
    ...  Run Keywords
    ...  Log To Console  ${LIST_OF_MEASUREMENTS}
    ...  AND
    ...  Set Test Failed  Power Meter Feature wasn't disabled or Admin reset wasn't perform !  fail_fast=True
    Run Keyword If  ${should_be_collected}==True
    ...  Run Keyword
    ...  Log To Console  ${collected_message}
    ...  ELSE
    ...  Log To Console  Real-time counter Energy Efficiency isn't generated --> Power Meter Feature deactivated successfull !


Time For Sleep
    [Documentation]  KW checks how much time has been left to collect PM Counters.
    ...  This was introduced to shorten the waiting time for collecting PM Counters.
    ...  It's possible due to the fact that the PM Counters are collected at predeterminated times.
    ...  For example: For 15 minutes measurement interval the reports are scheduled at 00:15h, 00:30h, 00:45h, 01:00h, etc.
    ...  For example: For 720 minutes measurement interval the reports are scheduled at 12:00h and 24:00h.
    [Arguments]  ${int}

    ${minutes}  Get Time  minutes
    ${hours}  Get Time  hours
    ${minutes}  Convert Time  ${minutes}
    ${hours}  Convert Time  ${hours}
    ${hours_to_minutes}  Run Keyword If  ${int}==360 or ${int}==720 or ${int}==1440
    ...  Evaluate  int(${hours}*60+${minutes})
    ${time}  Run Keyword If  ${int}==15 and 0<=${minutes}<=13
    ...  Evaluate  int(17-${minutes})
    ...  ELSE IF  ${int}==15 and 14<=${minutes}<=28
    ...  Evaluate  int(32-${minutes})
    ...  ELSE IF  ${int}==15 and 29<=${minutes}<=43
    ...  Evaluate  int(47-${minutes})
    ...  ELSE IF  ${int}==15 and 44<=${minutes}<=58
    ...  Evaluate  int(62-${minutes})
    ...  ELSE IF  ${int}==15 and ${minutes}>=59
    ...  Evaluate  int(18)
    ...  ELSE IF  ${int}==30 and 0<=${minutes}<=28
    ...  Evaluate  int(32-${minutes})
    ...  ELSE IF  ${int}==30 and 29<=${minutes}<=58
    ...  Evaluate  int(62-${minutes})
    ...  ELSE IF  ${int}==30 and ${minutes}>=59
    ...  Evaluate  int(33)
    ...  ELSE IF  ${int}==60 and 0<=${minutes}<=58
    ...  Evaluate  int(62-${minutes})
    ...  ELSE IF  ${int}==60 and ${minutes}>=59
    ...  Evaluate  int(63)
    ...  ELSE IF  ${int}==360 and 0<=${hours_to_minutes}<=358
    ...  Evaluate  int(362-${hours_to_minutes})
    ...  ELSE IF  ${int}==360 and 359<=${hours_to_minutes}<=718
    ...  Evaluate  int(722-${hours_to_minutes})
    ...  ELSE IF  ${int}==360 and 719<=${hours_to_minutes}<=1078
    ...  Evaluate  int(1082-${hours_to_minutes})
    ...  ELSE IF  ${int}==360 and 1079<=${hours_to_minutes}<=1438
    ...  Evaluate  int(1442-${hours_to_minutes})
    ...  ELSE IF  ${int}==360 and {hours_to_minutes}>=359
    ...  Evaluate  int(363)
    ...  ELSE IF  ${int}==720 and 0<=${hours_to_minutes}<=718
    ...  Evaluate  int(722-${hours_to_minutes})
    ...  ELSE IF  ${int}==720 and 719<=${hours_to_minutes}<=1438
    ...  Evaluate  int(1442-${hours_to_minutes})
    ...  ELSE IF  ${int}==720 and {hours_to_minutes}>=1439
    ...  Evaluate  int(1443)
    ...  ELSE IF  ${int}==1440 and 0<=${hours_to_minutes}<=1438
    ...  Evaluate  int(1442-${hours_to_minutes})
    ...  ELSE IF  ${int}==1440 and {hours_to_minutes}>=1439
    ...  Evaluate  int(1443)
    ...  ELSE
    ...  Set Test NoRun  Cannot set correct time to sleep !
    ${date}  Get Current Date
    ${time_to_verdict}  Add Time To Date  ${date}  ${time} minutes  result_format=%H:%M  exclude_millis=True

    [Return]  ${time}  ${time_to_verdict}


Check Number Of RMODS
    [Arguments]  ${rmods}

    ${rmods_list}  Get Ids For All  RMOD
    ${rmods_number}  Get Length  ${rmods_list}
    ${rmods_status}  Evaluate  ${rmods}<=${rmods_number}
    Set Test Variable  ${RMODS_STATUS_TEARDOWN}  ${rmods_status}
    Run Keyword If  ${rmods_status}==False
    ...  Set Test NoRun  Given number of RMODs: ${rmods} is incorrect, please check it !
    ...  ELSE
    ...  Log To Console  Given number of RMODs: ${rmods} is correct.


Check Interval
    [Arguments]  ${int}

    @{available_intervals}  Create List  15  30  60  360  720  1440
    ${interval_status}  Run Keyword And Return Status
    ...  List Should Contain Value  ${available_intervals}  ${int}
    Set Test Variable  ${INTERVAL_STATUS_TEARDOWN}  ${interval_status}
    Run Keyword If  ${interval_status}==False
    ...  Set Test NoRun  Given interval ${int} does't meet condition. Allowed values 15 30 60 360 720 1440.
    ...  ELSE
    ...  Log To Console  Given interval ${int} is correct.


Custom Test Teardown
    ${check_if_variable_exists}  Run Keyword And Return Status
    ...  Variable Should Exist  ${RMODS_STATUS_TEARDOWN}
    Run Keyword If  ${check_if_variable_exists}==True
    ...  Set Test Variable  ${TMP_RMODS_STATUS}  ${RMODS_STATUS_TEARDOWN}
    ...  ELSE
    ...  Set Test Variable  ${TMP_RMODS_STATUS}  False
    Run Keyword If  ${INTERVAL_STATUS_TEARDOWN}==False
    ...  Common Test Teardown
    ...  ELSE IF  ${INTERVAL_STATUS_TEARDOWN}==True and ${TMP_RMODS_STATUS}==False
    ...  Common Test Teardown
    ...  ELSE
    ...  Run Keywords
    ...  Perform Parameter Recommissioning  ${OBJECT_VARIABLE_ACT_POWER_METER}  actPowerMeter  update  false  skip_parameter_relation_errors=true
    ...  AND
    ...  Perform Parameter Recommissioning  ${OBJECT_VARIABLE_MT_BTS_ENERGY_MONITORING}
    ...  mtBtsEnergyMonitoring
    ...  update
    ...  disabled
    ...  skip_parameter_relation_errors=true
    ...  AND
    ...  Common Test Teardown


TC Setup
    Common Test Setup


TC Teardown
    Common Test Teardown

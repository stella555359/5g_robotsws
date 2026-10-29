*** Settings ***
Documentation
...  The purpose of this Test Case is to check the activation and deactivation for Embedded Power Meter
...  for Enegry Efficiency Monitoring.

Resource    ../../../../resources/hran_frame_sbts_siso.robot
Resource    ../../../../resources/ca_BSRF_general.robot
Resource    ../../../../resources/ca_BSRF_Energy_Efficiency.robot

*** Variables ***

${INTERVAL}  15  # for parameter: mtBtsEnergyMonitoring. Please enter only the number. Available intervals in minutes: 15,30,60,360,720,1440
${RMODS}         # Please specify how many RMODs in configuration support Embedded Power Meter feature.

*** Keywords ***
TC__BS-RF__Embedded_Power_Meter_EEM_act_deact_in_WebEM__RP000951__Automated
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-11060
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  The purpose of this Test Case is to check the activation and deactivation for Embedded Power Meter
    ...  for Enegry Efficiency Monitoring.
    ...  Power Meter is capable of measure power consumption (DC voltage and amperage) in RF and SM.
    ...  TC includes checking the display PM Counters for SBTS Enegry Consumption and Real Time Measurements.
    ...  Additional for Real-Time Measurements is checking voltage values for all modules (RMOD(s) and SMOD(s)) in configuration.
    ...  Voltage values are collecting for 5 minutes.
    ...  For FSM-r3 should be visible "0" in voltage field because FSM-r3 do not have Power Meter units.
    ...  For RMODs which doesn't support EEM in voltage field should be visible "0"
    ...  Voltage for FSM-r4 and all supported RMODs should be between 48-56V.
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
    ...  - 19.07.2022 - Changes due to PR645366 - PM unsupported modules has value "-" instead of "0"
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/BS-RF__BTS_Embedded_Power_Meter_for_Energy_
    ...  Efficiency_Monitoring_feature_activation_and_deactivation_in_WebEM__RP000951__Automated_TAT-11060.png


    Set Tags    CA-BS-RF    OWNER-mateusz.kawka@nokia.com    AUTHOR-mateusz.kawka@nokia.com
    ...    MAINTAINER-mateusz.kawka@nokia.com    GROUP_IN_CHARGE-WRO_3_Vrf    PHASE-CIT    SW-SBTS17A    SW-SBTS18
    ...    FEATURE-RP000951    FEATURE-RP001486_2    FEATURE-RP001145_1

    step1: Preconditions
    step2: Enable Embedded Power Meter
    step3: Check Voltage On Modules
    step4: Check SMOD Power Consumption
    step5: Disable Embedded Power Meter
    Restore Reference Configuration


step1: Preconditions

    Log To Console  ${\n}step1: Preconditions${\n}

    Set Test Variable  ${RESTORE_CONFIG}  ${FALSE}
    ${bts_obj}   admin.Get parameters for all  BTS
    ${bts_id}    Convert To String  ${bts_obj[0].btsId}
    Set Test Variable  ${BTS_ID}
    Set Test Variable  ${OBJECT_VARIABLE_ACTPOWERMETER}  MRBTS-${bts_id}/MNL-1/MNLENT-1/FEATCADM-1
    Set Test Variable  ${OBJECT_VARIABLE_MTBTSENERGYMONITORING}  MRBTS-${bts_id}/MNL-1/MNLENT-1/PMMNL-1

    ${reference_dict}  Create Dictionary
    ${parameter}  admin.Get Scf  export_type=configurationAndRuntimeObjects  parameters_save_variant=actualValues  alias=default
    ${scfc_xml}  Parse XML  source=${parameter}
    ${actpowermeter_scf}  Evaluate Xpath  ${scfc_xml}
    ...  string(.//managedObject[@distName='${OBJECT_VARIABLE_ACTPOWERMETER}']/p[@name='actPowerMeter']/text())
    Set To Dictionary  ${reference_dict}  actPowerMeter  ${actpowermeter_scf}
    ${interval_scf}  Evaluate Xpath  ${scfc_xml}
    ...  string(.//managedObject[@distName='${OBJECT_VARIABLE_MTBTSENERGYMONITORING}']/p[@name='mtBtsEnergyMonitoring']/text())
    Set To Dictionary  ${reference_dict}  mtBtsEnergyMonitoring  ${interval_scf}
    Set Test Variable    ${REFERENCE_DICT}

    ca_BSRF_Energy_Efficiency.Check Interval  ${INTERVAL}
    Check Number of RMODS  ${RMODS}
    ${new_counters_path}    Check If Current Build Is Newer Than    SBTS24R2_ENB_9999_231220_000004
    Set Test Variable    ${NEW_COUNTERS_PATH}

step2: Enable Embedded Power Meter

    Log To Console  ${\n}step2: Enable Power Meter Feature${\n}

    Set Test Variable  ${RESTORE_CONFIG}  ${TRUE}
    Run Keyword If  '${reference_dict['actPowerMeter'].lower()}' == 'false'  Run Keywords
    ...  Log To Console  Energy Efficiency Monitoring feature is not active, activating ongoing..\n
    ...  AND  Parameters Recommissioning and Check Cells  true  ${INTERVAL}min
    ...  ELSE
    ...  Log To Console  Energy Efficiency Monitoring feature already activated!\n
    Log To Console  ${\n}Waiting max. 10 minutes for Real-time measurements ! Attempt to read every minute !${\n}
    ${EEM_status}  Run Keyword And Return Status  Wait Until Keyword Succeeds  10x  1 minute  Check Real Time Measurements  True

    Run Keyword If  ${EEM_status}==False  Run Keywords
    ...  Log To Console  Embedded Power Meter For Enegry Efficiency Monitoring feature wasn't enabled or cannot collect all Real-time measurements!
    ...  AND  Log To Console  ${\n} Check given number of RMODS supporting Embedded Power Meter feature!
    ...  AND  Fail  Embedded Power Meter For Enegry Efficiency Monitoring feature wasn't enabled or cannot collect all Real-time measurements!
    ...  ELSE
    ...  Log To Console  ${\n}Real-time measurements has been collected !

    FOR  ${row}  IN  @{LIST_OF_MEASUREMENTS}
      ${keys}  Get Dictionary Keys  ${row}
      ${status}  Run Keyword And Return Status  Should Contain Match  ${keys}  regexp=ENERGY
      Run Keyword If  ${status}==True  Log To Console  ${row}
    END

    ${time_to_sleep}  ${time_to_verdict}  Time To Sleep  ${INTERVAL}
    Log To Console  Waiting for ${time_to_sleep} minutes to Get PM Counters ! ${\n}Verdict will be released at *${time_to_verdict}* !
    Sleep  ${time_to_sleep} minutes
    Collect PM Counters

step3: Check Voltage On Modules

    Log to console  ${\n}Step3: Check Voltage On Modules${\n}

    ${smods_parameters}  admin.Get Parameters For All  SMOD
    ${modules_ids}  Create List
    ${modules_product_names}  Create List
    FOR  ${smod}  IN  @{smods_parameters}
        ${smod_id}  Evaluate  ('/'.join('${smod['id']}'.split('/')[-2:]))
        Append to list  ${modules_ids}  ${smod_id}
        Append to List  ${modules_product_names}  ${smod['productName']}
    END

    ${rmods_parameters}  admin.Get Parameters For All  RMOD
    FOR  ${rmod}  IN  @{rmods_parameters}
        Continue For Loop If  'U' in '${rmod['productName']}'
        ${rmod_id}  Evaluate  ('${rmod['id']}'.split('/')[-1])
        Append to list  ${modules_ids}  ${rmod_id}
        Append to list  ${modules_product_names}  ${rmod['productName']}
    END

    ${modules_product_names}  Evaluate
    ...  [link.replace('Flexi System Module Outdoor FSMF','FSMF').replace('ASIA AirScale Common','AirScale') for link in ${modules_product_names}]
    ${dict_of_modules}  Evaluate  ({i:[] for i in ${modules_ids}})

    Set Test Variable  ${DICT_OF_MODULES}  ${dict_of_modules}
    Set Test Variable  ${MODULES_PRODUCT_NAMES}  ${modules_product_names}

    ${minutes_to_collect_voltage}  Set Variable  ${5}
    Set Test Variable  ${MINUTES_TO_COLLECT_VOLTAGE}  ${minutes_to_collect_voltage}

    Log to console  Waiting ${minutes_to_collect_voltage} minutes to collect ${minutes_to_collect_voltage} voltage measurements for all modules${\n}

    FOR  ${minute}  IN RANGE  ${minutes_to_collect_voltage}
      ${dict_with_measurements}  Append Voltage To Dict
      Exit For Loop If  ${minute}==${minutes_to_collect_voltage-1}
      Sleep  1 minute
    END

    ${modules_parameters}  Combine Lists  ${smods_parameters}  ${rmods_parameters}

    Log to console  Note:${\n}FSMF has no Power Meter Unit, so all voltage fields should have "0"
    Log To Console  ${\n}If RMOD doesn't support EEM, all voltage fields should have "0"
    Log to console  All modules that support EEM should return valid numeric values${\n}
    Sleep  10s

    FOR  ${module}  ${module_id}  ${module_product_name}  IN ZIP  ${modules_parameters}  ${modules_ids}  ${modules_product_names}
        Log to console  ${module_product_name} -> ${module_id} !
        ${voltage_from_dict}  Get From Dictionary  ${dict_with_measurements}  ${module_id}
        ${voltage_from_dict}  Evaluate  list(map(lambda x: x.replace('-', '0'), ${voltage_from_dict}))
        ${voltage_from_dict}  Evaluate  [float(i) for i in ${voltage_from_dict}]
        Run Keyword If  'FSMF' in '${module['productName']}'  Check Voltage Values For FSMF  ${voltage_from_dict}
        ...  ELSE IF  'AirScale' in '${module['productName']}'  Check Voltage Values For AirScale  ${voltage_from_dict}
        ...  ELSE  Check Voltage Values For RMOD  ${voltage_from_dict}  ${module_id}  ${module_product_name}
    END

    Log to console  Voltage values for all modules are OK, going to next step !


step4: Check SMOD Power Consumption

    Log To Console  ${\n}Step4: Check SMOD Power Consumption${\n}

    ${time_to_sleep}  ${time_to_verdict}  Time To Sleep  ${INTERVAL}
    Log To Console  Waiting ${time_to_sleep} minutes for re-collect PM counters to check power consumption!
    Log To Console  ${\n}Verdict will be released at *${time_to_verdict}* !
    Sleep  ${time_to_sleep} minutes
    Collect PM Counters
    Set Test Variable  ${pm_length_after_sleep}  ${pm_length_collected}

    Log To Console  Checking SMOD with sub-modules power consumption based on collected counter M40002C0!\n

    ${module_id_dict}  Create Dictionary
    ${smods}  admin.Get Parameters For All  SMOD
    ${counter}  Set Variable  ${1}
    FOR  ${smod}  IN  @{smods}
        ${short_id}  Evaluate  '${smod['id']}'.split('/', 7)[-1]
        Run Keyword If  'FSMF' in '${smod['productName']}'
        ...  Set To Dictionary  ${module_id_dict}  FSMF_${counter}  ENERGY_EFFICIENCY/SMOD/${short_id}
        ...  ELSE IF  'AirScale' in '${smod['productName']}'
        ...  Set To Dictionary  ${module_id_dict}  AirScale_${counter}  ENERGY_EFFICIENCY/SMOD/${short_id}
        ${counter}  Evaluate  ${counter}+1
    END

    Log to console  Collecting current power consumption measurement !${\n}
    ${measurements_list}  admin.Get Measurements  realTime

    ${power_cons_list}  Create List
    FOR  ${module}  ${id}  IN ZIP  ${module_id_dict.keys()}  ${module_id_dict.values()}
        ${match}  Evaluate  [s for s in ${measurements_list} if '${id}' in s][0]
        ${cabinet}  Get Regexp Matches  ${id}  CABINET_R-\\d+
        Run Keyword If  'FSMF' in '${module}'  Run Keywords
        ...  Calculate Static FSMF Power Consumption  ${cabinet}[0]
        ...  AND  Append To List  ${power_cons_list}  ${FSMF_WITH_FBB_CONSUMPTION}
        ...  AND  Log to console  FSMF power consumption: ${FSMF_WITH_FBB_CONSUMPTION} W
        ...  AND  Continue For Loop
        ${value_dict}  Get From Dictionary  ${match}  ${id}
        ${real_power}  Get From Dictionary  ${value_dict}  power
        ${real_power}  Convert To Number  ${real_power}
        Run Keyword If  'AirScale' in '${module}'  Run Keywords
        ...  Log to console  AirScale power consumption: ${real_power} W
        ...  AND  Append To List  ${power_cons_list}  ${real_power}
    END

    ${power_cons_sum}  Evaluate  sum(${power_cons_list})
    ${power_cons_sum_kwh}  Evaluate  ${power_cons_sum}/1000
    ${power_cons_per_minute}  Evaluate  (${power_cons_sum_kwh}/60)
    ${power_cons_per_inteval}  Evaluate  ${power_cons_per_minute}*${INTERVAL}
    ${power_cons_counter}  Evaluate  ${power_cons_per_inteval}*100000

    ${counters_path}    Set Variable If
    ...    ${NEW_COUNTERS_PATH}
    ...    ${PM_COUNTERS['BTS']['MRBTS-${BTS_ID}']['SBTS_Energy_Consumption']}
    ...    ${PM_COUNTERS['BTS']['BTS']['MRBTS-${BTS_ID}']['SBTS_Energy_Consumption']}

    ${smod_counters}
    ...  Get From Dictionary  ${counters_path}  M40002C0
    ${counter_values}  Get Dictionary Values  ${smod_counters}
    ${last_counter}  Get From List  ${counter_values}  -1

    ${in_range}  Evaluate  ${power_cons_counter-100} <= ${last_counter} <= ${power_cons_counter+100}

    Run Keyword If  '${in_range}'=='True'
    ...  Log to console  Power Consumption counter M40002C0 for all SMOD(s) is CORRECT !
    ...  ELSE  Run Keywords
    ...  Log To Console  Power Consumption counter M40002C0 for all SMOD(s) is INCORRECT ! Check values in logs !
    ...  AND  Log To Console  ${\n}Expected value ${power_cons_counter} +/-100, actual values: ${last_counter}
    ...  AND  Fail  Power Consumption counter M40002C0 for all SMOD(s) is INCORRECT ! Check values in logs !


step5: Disable Embedded Power Meter

    Log To Console  ${\n}step5: Disable Energy Efficiency monitoring${\n}
    Parameters Recommissioning And Check Cells  false  disabled
    Log To Console  ${\n}Waiting max. 5 minutes for empty Real-time measurements ! Attempt to read every minute !${\n}

    ${EEM_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  5x  1 minute  Check Real Time Measurements  False

    Run Keyword If  ${EEM_status}!=True
    ...  Fail
    ...  Run Keyword And Continue On Failure  Embedded Power Meter For Enegry Efficiency Monitoring feature wasn't disabled !
    ...  ELSE
    ...  Log To Console  Real-time measurements isn't generated --> Embedded Power Meter For Enegry Efficiency Monitoring feature deactivated ok !

    ${time_to_sleep}  ${time_to_verdict}  Time To Sleep  ${INTERVAL}
    Log To Console  Waiting ${time_to_sleep} minutes for re-collect PM counters to check if feature was correctly deactivated !
    Log To Console  ${\n}Verdict will be released at *${time_to_verdict}* !
    Sleep  ${time_to_sleep} minutes
    Collect PM Counters

    Set Test Variable  ${pm_length_disable}  ${pm_length_collected}
    ${pm_length_compare}=  Run Keyword And Return Status  Should Be Equal  ${pm_length_after_sleep}  ${pm_length_disable}
    Run Keyword If  ${pm_length_compare}==True  Log To Console  Embedded Power Meter feature deactivation was successfull !
    ...  ELSE
    ...  Run Keyword And Continue On Failure
    ...  Fail  Embedded Power Meter feature deactivation wasn't successfull !\n

Restore Reference Configuration

    Log To Console  Restore Reference Configuration...\n

    ${actual_dict}  Create Dictionary
    ${parameter}  admin.Get Scf  export_type=configurationAndRuntimeObjects  parameters_save_variant=actualValues  alias=default
    ${scfc_xml}  Parse XML  source=${parameter}
    ${actpowermeter_scf}  Evaluate Xpath  ${scfc_xml}
    ...  string(.//managedObject[@distName='${OBJECT_VARIABLE_ACTPOWERMETER}']/p[@name='actPowerMeter']/text())
    Set To Dictionary  ${actual_dict}  actPowerMeter  ${actpowermeter_scf}
    ${interval_scf}  Evaluate Xpath  ${scfc_xml}
    ...  string(.//managedObject[@distName='${OBJECT_VARIABLE_MTBTSENERGYMONITORING}']/p[@name='mtBtsEnergyMonitoring']/text())
    Set To Dictionary  ${actual_dict}  mtBtsEnergyMonitoring  ${interval_scf}

    Run Keyword If  '${REFERENCE_DICT['actPowerMeter'].lower()}' != '${actual_dict['actPowerMeter'].lower()}'  Run Keywords
    ...  Log To Console  Energy Efficiency Monitoring feature have to be restored to reference state, please wait !
    ...  AND  Parameters Recommissioning and Check Cells  ${REFERENCE_DICT['actPowerMeter']}  ${REFERENCE_DICT['mtBtsEnergyMonitoring']}
    ...  AND  Log To Console  Energy Efficiency Monitoring feature restored to actPowerMeter -> ${REFERENCE_DICT['actPowerMeter']}
    ...  ELSE
    ...  Log To Console  Energy Efficiency Monitoring feature already in reference state, no more actions needed!

Check Static FSMF Power
    [Arguments]  ${real_power}

    ${real_power_kwh}  Evaluate  ${real_power}/1000
    ${status}  Run Keyword And Continue On Failure  Should Be Equal As Numbers  ${real_power_kwh}  ${fsmf_with_modules_cons}
    ...  Power in WebEM for FSMF is other than static ${fsmf_with_modules_cons}kWh!

Calculate Static FSMF Power Consumption
    [Arguments]  ${cabinet}

    ${fsmf_cons}  Set Variable  ${125}  # power consumption in kWh
    ${fbba_cons}  Set Variable  ${85}
    ${fbbc_cons}  Set Variable  ${91}

    ${fsmf_counter}  Set Variable  ${0}
    ${fbba_counter}  Set Variable  ${0}
    ${fbbc_counter}  Set Variable  ${0}

    ${smods}  admin.Get Parameters For All  SMOD
    FOR  ${smod}  IN  @{smods}
        Continue For Loop If  '${cabinet}' not in '${smod['id']}'
        ${fsmf_counter}  Set Variable If  'FSMF' in '${smod['productName']}'
        ...  ${fsmf_counter+1}  ${fsmf_counter}
    END

    ${fbbs}  admin.Get Parameters For All  BBMOD
        FOR  ${fbb}  IN  @{fbbs}
            Continue For Loop If  '${cabinet}' not in '${fbb['id']}'
            ${fbba_counter}  Set Variable If  'FBBA' in '${fbb['productName']}'
            ...  ${fbba_counter+1}  ${fbba_counter}
            ${fbbc_counter}  Set Variable If  'FBBC' in '${fbb['productName']}'
            ...  ${fbbc_counter+1}  ${fbbc_counter}
        END

    ${sum}  Evaluate  ${FSMF_COUNTER}+${FBBC_COUNTER}+${FBBA_COUNTER}

    ${fsmf_with_modules_cons}  Evaluate
    ...  (${FSMF_COUNTER}*${fsmf_cons})+(${FBBA_COUNTER}*${fbba_cons})+(${FBBC_COUNTER}*${fbbc_cons})


    Set Test Variable  ${FSMF_WITH_FBB_CONSUMPTION}  ${fsmf_with_modules_cons}


Check Voltage Values For RMOD
    [Arguments]  ${voltage}  ${rmod}  ${rmod_name}

    Run Keyword If  0 in ${voltage}  Check Unsupported RMOD  ${voltage}  ${rmod}  ${rmod_name}
    ...  ELSE  Check Voltage For Supported RMOD  ${voltage}  ${rmod}

Check Unsupported RMOD
    [Arguments]  ${voltage}  ${rmod}  ${rmod_name}

    ${not_supported_count}  Evaluate  ${voltage}.count(0)
    ${not_supported_status}  Run Keyword And Return Status  Should Be Equal  ${not_supported_count}  ${MINUTES_TO_COLLECT_VOLTAGE}
    Run Keyword If  ${not_supported_status}==False  Run Keywords
    ...  Log to console  For ${rmod} should be '0' in all voltage fields because doesn't support EEM,
    ...  found ${not_supported_count} out of ${MINUTES_TO_COLLECT_VOLTAGE} !
    ...  AND  Run Keyword And Continue On Failure  Fail  ${rmod} doesn't support EEM so all voltage fields should have "0" but don't have !
    ...  ELSE  Run Keywords
    ...  Log to console  For ${rmod_name} found ${not_supported_count} out of ${MINUTES_TO_COLLECT_VOLTAGE} "0",
    ...  AND  Log To Console  ${\n}Real-Time measurements for ${rmod} are OK !${\n}

Check Voltage For Supported RMOD
    [Arguments]  ${voltage}  ${rmod}

    ${rmod_voltage}  Evaluate  ([float(i) for i in ${voltage}])
    ${average_voltage}  Evaluate  (round(sum(i for i in ${rmod_voltage})/len(${rmod_voltage}),2))
    ${verdict}  Evaluate  (48<=${average_voltage}<=56)
    Run Keyword If  '${verdict}'=='True'  Log to console  Average voltage: ${average_voltage} V${\n}
    ...  ELSE  Run Keywords  Log to console  Average voltage for ${rmod}: ${average_voltage} V so is not in range 48-56 V !
    ...  AND  Run Keyword And Continue On Failure  Fail  Average voltage for ${rmod} is ${average_voltage} V so is not in range 48-56 V !

Check Voltage Values For FSMF
    [Arguments]  ${voltage}

    ${not_available_count}  Evaluate  ${voltage}.count(0)
    ${not_available_status}  Run Keyword And Return Status  Should Be Equal  ${not_available_count}  ${MINUTES_TO_COLLECT_VOLTAGE}
    Run Keyword If  ${not_available_status}==False  Run Keywords
    ...  Log to console  For FSMF should be '0' in all voltage fields because has no Power Meter Unit,
    ...  found ${not_available_count} out of ${MINUTES_TO_COLLECT_VOLTAGE} !
    ...  AND  Run Keyword And Continue On Failure  Fail  FSMF has no Power Meter Unit so all voltage fields should have "0" but don't have !
    ...  ELSE  Log to console  Found ${not_available_count} out of ${MINUTES_TO_COLLECT_VOLTAGE} "0", Real-Time measurements OK !${\n}

Check Voltage Values For AirScale
    [Arguments]  ${voltage}

    ${voltage_rel4}  Evaluate  ([float(i) for i in ${voltage}])
    ${average_voltage}  Evaluate  (round(sum(i for i in ${voltage_rel4})/len(${voltage_rel4}),2))
    ${verdict}  Evaluate  (48<=${average_voltage}<=56)
    Run Keyword If  '${verdict}'=='True'  Log to console  Average voltage: ${average_voltage} V${\n}
    ...  ELSE  Run Keywords  Log to console  Average voltage: ${average_voltage} V so is not in range 48-56 V !${\n}
    ...  AND  Run Keyword And Continue On Failure  Fail  Average voltage is ${average_voltage} V so is not in range 48-56 V !

Append Voltage To Dict

    FOR  ${key}  IN  @{DICT_OF_MODULES.keys()}
        ${voltage}  Get Voltage For Module  ${key}
        Append to List  ${DICT_OF_MODULES}[${key}]  ${voltage}
    END

    FOR  ${key}  ${value}  IN ZIP  ${DICT_OF_MODULES.keys()}  ${DICT_OF_MODULES.values()}
        ${voltage_values}  Evaluate  ${DICT_OF_MODULES}\['${key}']
        Log to console  ${key}: ${voltage_values}
    END

    Log to console  ${\n}

    [Return]  ${dict_of_modules}

Get Voltage For Module
    [Arguments]  ${module}

    ${measurement}  admin.Get Measurements

    FOR  ${key}  IN  @{measurement}
        ${key}  Get Dictionary Items  ${key}
        Continue For Loop If  ('ENERGY_EFFICIENCY' not in '${key}[0]') or ('${module}' not in '${key}[0]')
        ${meas}  Set Variable  ${key}[1]
        Return From Keyword If  "${meas}"=="Not supported"  0
        ${voltage}  Set Variable  ${meas['voltage']}
    END

    [Return]  ${voltage}

Parameters Recommissioning And Check Cells
    [Arguments]  ${param_actPowerMeter}  ${param_mtBts}

    Log To Console  Updating actPowerMeter parameter to ${param_actPowerMeter} ...
    admin.Perform Parameter Recommissioning  ${OBJECT_VARIABLE_ACTPOWERMETER}  actPowerMeter
    ...  update  ${param_actPowerMeter}  skip_parameter_relation_errors=true
    Run Keyword If  '${param_mtBts}'=='disabled'
    ...  Log to Console  Updating mtBtsEnergyMonitoring parameter to disabled
    ...  ELSE  Log to console  Updating mtBtsEnergyMonitoring parameter to ${INTERVAL} minutes ...
    admin.Perform Parameter Recommissioning  ${OBJECT_VARIABLE_MTBTSENERGYMONITORING}  mtBtsEnergyMonitoring
    ...  update  ${param_mtBts}  skip_parameter_relation_errors=true
    Log To Console  Checking if all cells are still onAir after recommissioning
    ${status}  Run Keyword And Return Status  Check If All Cells Are OnAir
    Run Keyword If  '${status}'=='False'
    ...  Run Keywords
    ...  admin.Perform Parameter Recommissioning  ${OBJECT_VARIABLE_ACTPOWERMETER}  actPowerMeter  update  false  skip_parameter_relation_errors=true
    ...  AND  Fail  At least one cell is NOT onAir after recommissioning! Feature deactivated and set test fail !
    ...  ELSE
    ...  Log to console  All cells are onAir !${\n}

Collect PM Counters
    Log To Console  Collecting PM Counters ...
    ${status}  ${pm_counters}  Run Keyword And Ignore Error  admin.Get Pm Counters  M40002C0,M40002C1,M40002C2  timeout=120
    Run Keyword If  '${status}'=='FAIL'  Run Keywords
    ...  Log to console  Cannot Get PM Counters, feature deactivating and set test fail !
    ...  AND  Parameters Recommissioning And Check Cells  false  disabled
    ...  AND  Fail  Cannot Get PM Counters, probably not visible in WebEM !
    ${path}  ${pm_counters_string}  Evaluate  (str(${pm_counters}).split(':', 1))
    ${pm_status}=  Run Keyword And Return Status  Should Contain X Times  ${pm_counters_string}  M40002C  3
    Run Keyword If  ${pm_status}==False  Fail  Collected PM Counters don't contain expected counters !
    Run Keyword If  ${pm_status}==True  Log To Console  PM Counters was successfull collected for M40002C0,M40002C1,M40002C2 !
    ${pm_length}=  Get Length  ${pm_counters_string}
    Set Test Variable  ${pm_length_collected}  ${pm_length}
    Set Test Variable  ${PM_COUNTERS}


TC Setup
    Common Test Setup

TC Teardown
    Run Keyword If Test Failed  Run Keyword If  ${RESTORE_CONFIG}  Restore Reference Configuration
    Common Test Teardown

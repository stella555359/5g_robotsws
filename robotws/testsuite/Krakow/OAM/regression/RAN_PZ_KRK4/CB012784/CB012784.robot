*** Settings ***
Documentation
...    author: Agata Sidlo, Marcin Szlapa
...    contact: agata.sidlo@nokia.com
...    Description: CB012784 KPI triggered alarm and log collection enhancements

Library       testsuite.Krakow.OAM.regression.RAN_PZ_KRK4.CB007257.resources.keywords.SeleniumKeywords
Library       testsuite.Krakow.resources.alarm.Alarm
Library       ./resources/keywords.py
Resource      taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource      taf/rfrl/bts/robot/logs_collecting.robot
Variables     taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables     ./delta/delta.py
Variables     ./resources/variables.py

Test Timeout  24 hours

Suite Setup         Suite Setup
Suite Teardown      Common Suite Teardown
Test Setup          Common Preconditions
Test Teardown       Common Postconditions

*** Variables ***
${global_bts_id} =  ${tl.gnbs[0].global_bts_id}

*** Test Cases ***
CB012784_Negative_scenario_wrong_value
    Perform Delta Commissioning And Expect Error
    ...  delta=${tc_2_negative_scenario_wrong_formulaDescription_delta}
    ...  error_regex=AdminApiProcedureFailureException:.*'parameterName': 'kpiAlarmTriggers'.*\n.*formulaDescription.*VALUE_IS_TO_TOO_LONG.*
    Perform Delta Commissioning And Expect Error
    ...  delta=${tc_2_negative_scenario_wrong_timeToTrigger_delta}
    ...  error_regex=AdminApiProcedureFailureException:.*'parameterName': 'kpiAlarmTriggers'.*\n.*timeToTrigger.*VALUE_IS_TOO_SMALL.*
    Perform Delta Commissioning And Expect Error
    ...  delta=${tc_2_negative_scenario_wrong_triggeringFormula_delta}
    ...  error_regex=AdminApiProcedureFailureException:.*'parameterName': 'kpiAlarmTriggers'.*\n.*Syntax error in triggeringFormula:.*
    Perform Delta Commissioning And Expect Error
    ...  delta=${tc_2_negative_scenario_unsupported_counters_delta}
    ...  error_regex=AdminApiProcedureFailureException.*\n.*Unsupported counters in triggeringFormula: F1_DU_CU_CNF_UPD_FL_OTH == 0.*
    Perform Full Commissioning and Wait for onAir    prefix_tag=${none}
    Perform Delta Commissioning And Expect Error
    ...  delta=${tc_2_negative_scenario_misspelt_counter_name_delta}
    ...  error_regex=AdminApiProcedureFailureException.*\n.*Syntax error in triggeringFormula: \\$NR_CELL_PLAN_UNAVAIL_CHNG_TO.*
    Perform Delta Commissioning And Expect Error
    ...  delta=${tc_2_negative_scenario_unsupported_mix_of_counters_delta_1}
    ...  error_regex=AdminApiProcedureFailureException.*\n.*${message_mix_1} SBTS_SM_MAX_TEMPERATURE > SBTS_SFPSM_RX_POWER_LANE_SUM.*
    Perform Delta Commissioning And Expect Error
    ...  delta=${tc_2_negative_scenario_unsupported_mix_of_counters_delta_2}
    ...  error_regex=AdminApiProcedureFailureException.*\n.*${message_mix_2} SBTS_SFPRM_RX_POWER_LANE_MAX != SUCC_SETUP_USER_SA_PLMN.*
    Perform Full Commissioning and Wait for onAir    prefix_tag=${none}

CB012784_Possitive_scenario
    [Setup]  Common Preconditions With Counters Delta

    Perform Delta Commissioning On gNB    ${tc_1_possitive_scenario_delta_1}
    Wait For Counters Update
    Verify Alarms    ${expected_alarms_1}    ${expected_not_visible_alarms_1}    TC1_1
    Perform Delta Commissioning On gNB    ${feature_deactivation_delta}
    Sleep    10s
    Verify Default Allowed Alarms on gNB

    Perform Delta Commissioning On gNB    ${tc_1_possitive_scenario_delta_2}
    Wait Until Alarm Is Active On Gnb
    ...  fault_name=The following KPI formula ${TC_1_alarm_2}[2] has been evaluated to true: ${TC_1_alarm_description_2}[2]
    ...  timeout=180
    Wait For Counters Update
    Verify Alarms    ${expected_alarms_2}    ${expected_not_visible_alarms_2}     TC1_2
    Perform Delta Commissioning On gNB    ${feature_deactivation_delta}
    Sleep    10s
    Verify Default Allowed Alarms on gNB

*** Keywords ***
Perform Delta Commissioning And Expect Error
    [Arguments]  ${delta}  ${error_regex}
    Run Keyword And Expect Error
    ...  REGEXP:${error_regex}
    ...  Perform Delta Commissioning On gNB  ${delta}
    Log To Console    Expected validation error is visible: "${error_regex}"

Suite Setup
	gnbbbu.upload_swconfig    sw_config_path=commissionings/${CONFIGURATION.replace('.', '/')}/swconfig.txt
	Common Suite Setup With Commissioning

Common Preconditions With Counters Delta
    Common Preconditions
    Perform Delta Commissioning On gNB    ${activate_pm_counters_delta}

Wait For Counters Update
    Sleep    5m

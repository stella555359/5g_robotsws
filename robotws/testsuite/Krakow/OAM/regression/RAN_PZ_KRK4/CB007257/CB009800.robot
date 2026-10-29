*** Settings ***
Documentation
...    author: Marcin Szlapa
...    contact: marcin.szlapa@nokia.com
...    Description: Test Cases CB009800-5G KPI triggered alarm and log collection in gNB

Library       testsuite.Krakow.OAM.regression.RAN_PZ_KRK4.CB007257.resources.keywords.SeleniumKeywords
Library       testsuite.Krakow.resources.alarm.Alarm
Library       ./resources/keywords.py
Resource      taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource      taf/rfrl/bts/robot/logs_collecting.robot
Variables     taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables     ./delta/delta.py

Test Timeout  24 hours

Suite Setup         Suite Setup
Suite Teardown      Common Suite Teardown
Test Setup          Common Preconditions
Test Teardown       Common Postconditions

*** Variables ***
${global_bts_id} =  ${tl.gnbs[0].global_bts_id}

*** Test Cases ***
CB009800-5G_3_Negative scenario - wrong value
    Perform Delta Commissioning And Expect Error
    ...  delta=${tc_3_negative_scenario_wrong_formulaDescription_delta}
    ...  error_regex=AdminApiProcedureFailureException:.*'parameterName': 'kpiAlarmTriggers'.*\n.*formulaDescription.*VALUE_IS_TO_TOO_LONG.*
    Perform Delta Commissioning And Expect Error
    ...  delta=${tc_3_negative_scenario_wrong_timeToTrigger_delta}
    ...  error_regex=AdminApiProcedureFailureException:.*'parameterName': 'kpiAlarmTriggers'.*\n.*timeToTrigger.*VALUE_IS_TOO_SMALL.*
    Perform Delta Commissioning And Expect Error
    ...  delta=${tc_3_negative_scenario_wrong_triggeringFormula_delta}
    ...  error_regex=AdminApiProcedureFailureException:.*'parameterName': 'kpiAlarmTriggers'.*\n.*Syntax error in triggeringFormula:.*
    Perform Delta Commissioning And Expect Error
    ...  delta=${tc_3_negative_scenario_unsupported_counters_delta}
    ...  error_regex=AdminApiProcedureFailureException.*\n.*Unsupported counters in triggeringFormula: F1_DU_CU_CNF_UPD_FL_OTH == 0.*
    Perform Full Commissioning and Wait for onAir  CB009800
    Perform Delta Commissioning And Expect Error
    ...  delta=${tc_3_negative_scenario_misspelt_counter_name_delta}
    ...  error_regex=AdminApiProcedureFailureException.*\n.*Syntax error in triggeringFormula: \\$NR_CELL_PLAN_UNAVAIL_CHNG_TO.*

CB009800-5G_4_Negative scenario - same fautlID
    Perform Delta Commissioning And Expect Error
    ...  delta=${tc_4_negative_scenario_same_faultid_delta}
    ...  error_regex=AdminApiProcedureFailureException:.*\n.*Assertion not met: TRBLCADM.kpiAlarmTriggers have faultID unique.*

CB009800-5G_8_Structures check
    Perform Delta Commissioning And Expect Error
    ...  delta=${tc_8_structures_check_delta}
    ...  error_regex=AdminApiProcedureFailureException:.*(\n.*)+kpiAlarmTriggers.*21.*IS_OUT_OF_RANGE.*20.*kpiAlarmTriggers.*INCORRECT_ENUM.*

CB009800-5G_1_Feature activation deactivation
    Perform Delta Commissioning On gNB    ${tc_1_feature_activation_deactivation_delta}
    Run Keyword And Expect Error
    ...  ExecutionException*Alarm*is not active*
    ...  Wait Until Alarm Is Active On Gnb
    ...  fault_name=The following KPI formula PDSCH_RANK1_64TBL_MCS_00 != 100000 has been evaluated to true: description
    ...  timeout=120
    Repeat keyword  3 times
    ...  Run Keywords
    ...  Activate feature and verify no gNB reboot  AND
    ...  Wait Until Alarm Is Active On Gnb
    ...  fault_name=The following KPI formula PDSCH_RANK1_64TBL_MCS_00 != 100000 has been evaluated to true: description
    ...  timeout=600  AND
    ...  Deactivate feature and verify no gNB reboot  AND
    ...  Wait Until Alarm Is Not Active On Gnb
    ...  fault_name=The following KPI formula PDSCH_RANK1_64TBL_MCS_00 != 100000 has been evaluated to true: description
    ...  timeout=300

CB009800-5G_2_Possitive scenario
    [Setup]  Common Preconditions With Commissioning  CB009800
    Save gNB uptime
    Perform Delta Commissioning On gNB    ${tc_2_possitive_scenario_delta}
    Verify no gNB reboot since last saved uptime

CB009800-5G_5_Snapshot collection
    [Setup]  Common Preconditions With Commissioning  CB009800_05
    Configure Lss User
    ${fault_number}=  Get Fault Number
    Prepare Snapshot Directory on gNB
    Modify Fault Number  ${fault_number}
    Perform Delta Commissioning On gNB    ${tc_5_snapshot_collection_delta}
    gnbcell.Block Cell    cell_id=${21}
    Wait Until Alarm Is Active On Gnb
    ...  fault_name=The following KPI formula ${TC_5_alarm} has been evaluated to true: ${TC_5_alarm_description}
    ...  timeout=180
    gnbcell.Unblock Cell    cell_id=${21}
    Wait Until Alarm Is Not Active On Gnb
    ...  fault_name=The following KPI formula ${TC_5_alarm} has been evaluated to true: ${TC_5_alarm_description}
    ...  timeout=180
    Verify Snapshot Collected on gNB
    Perform Delta Commissioning On gNB    ${feature_deactivation_delta}

CB009800-5G_7_Intervals and timing check
    [Setup]  Common Preconditions With Commissioning  CB009800
    Check Interval And Timing  cell_id=${21}
    Perform Delta Commissioning On gNB    ${feature_deactivation_delta}

*** Keywords ***
Activate feature and verify no gNB reboot
    Save gNB uptime
    Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=MRBTS-${global_bts_id}/MNL-1/MNLENT-1/FEATCADM-1
    ...  param_name=actKpiAlarms
    ...  param_value=true
    Verify no gNB reboot since last saved uptime

Deactivate feature and verify no gNB reboot
    Save gNB uptime
    Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=MRBTS-${global_bts_id}/MNL-1/MNLENT-1/FEATCADM-1
    ...  param_name=actKpiAlarms
    ...  param_value=false
    Verify no gNB reboot since last saved uptime

Perform Delta Commissioning And Expect Error
    [Arguments]  ${delta}  ${error_regex}
    Run Keyword And Expect Error
    ...  REGEXP:${error_regex}
    ...  Perform Delta Commissioning On gNB  ${delta}

Suite Setup
	gnbbbu.upload_swconfig    sw_config_path=commissionings/${CONFIGURATION.replace('.', '/')}/swconfig.txt
	Common Suite Setup With Commissioning    prefix_tag=CB009800

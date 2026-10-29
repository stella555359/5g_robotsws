from robot.libraries.BuiltIn import BuiltIn

bts_id = BuiltIn().get_variable_value('${tl.gnbs[0].dus[0].global_bts_id}')

tc_2_negative_scenario_wrong_formulaDescription_delta = [
    {"distName": "MRBTS-{0}/MNL-1/MNLENT-1/FEATCADM-1".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "actKpiAlarms", "value": "true", "operation": "update"},
     ]},
    {"distName": "MRBTS-{0}/MNL-1/MNLENT-1/TRBLCADM-1".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "kpiAlarmTriggers",
          "value": [{"faultID": "4570",
                     "formulaDescription": "x" * 501,
                     "timeToTrigger": "1",
                     "triggeringFormula": "DENOM_CELL_AVAIL != 5"}],
          "operation": "update"},
         {"parameterName": "kpiAlarmMutingTime", "value": "1", "operation": "update"},
     ]}]

tc_2_negative_scenario_wrong_timeToTrigger_delta = [
    {"distName": "MRBTS-{0}/MNL-1/MNLENT-1/FEATCADM-1".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "actKpiAlarms", "value": "true", "operation": "update"},
     ]},
    {"distName": "MRBTS-{0}/MNL-1/MNLENT-1/TRBLCADM-1".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "kpiAlarmTriggers",
          "value": [{"faultID": "4570",
                     "formulaDescription": "x",
                     "timeToTrigger": "-1",
                     "triggeringFormula": "DENOM_CELL_AVAIL != 5"}],
          "operation": "update"},
         {"parameterName": "kpiAlarmMutingTime", "value": "1", "operation": "update"},
     ]}]

tc_2_negative_scenario_wrong_triggeringFormula_delta = [
    {"distName": "MRBTS-{0}/MNL-1/MNLENT-1/FEATCADM-1".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "actKpiAlarms", "value": "true", "operation": "update"},
     ]},
    {"distName": "MRBTS-{0}/MNL-1/MNLENT-1/TRBLCADM-1".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "kpiAlarmTriggers",
          "value": [{"faultID": "4570",
                     "formulaDescription": "x",
                     "timeToTrigger": "1",
                     "triggeringFormula": "x"}],
          "operation": "update"},
         {"parameterName": "kpiAlarmMutingTime", "value": "1", "operation": "update"},
     ]}]

tc_2_negative_scenario_misspelt_counter_name_delta = [
    {"distName": "MRBTS-{0}/MNL-1/MNLENT-1/FEATCADM-1".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "actKpiAlarms", "value": "true", "operation": "update"},
     ]},
    {"distName": "MRBTS-{0}/MNL-1/MNLENT-1/TRBLCADM-1".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "kpiAlarmTriggers",
          "value": [{"faultID": "4570",
                     "formulaDescription": "x",
                     "timeToTrigger": "1",
                     "triggeringFormula": "$$NR_CELL_PLAN_UNAVAIL_CHNG_TO"}],
          "operation": "update"},
         {"parameterName": "kpiAlarmMutingTime", "value": "1", "operation": "update"},
     ]}]

tc_2_negative_scenario_unsupported_counters_delta = [
    {"distName": "MRBTS-{0}/MNL-1/MNLENT-1/FEATCADM-1".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "actKpiAlarms", "value": "true", "operation": "update"},
     ]},
    {"distName": "MRBTS-{0}/MNL-1/MNLENT-1/TRBLCADM-1".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "kpiAlarmTriggers",
          "value": [{"faultID": "4570",
                     "formulaDescription": "x",
                     "timeToTrigger": "1",
                     "triggeringFormula": "F1_DU_CU_CNF_UPD_FL_OTH == 0"}],
          "operation": "update"},
         {"parameterName": "kpiAlarmMutingTime", "value": "1", "operation": "update"},
     ]}]

tc_2_negative_scenario_unsupported_mix_of_counters_delta_1 = [
    {"distName": "MRBTS-{0}/MNL-1/MNLENT-1/FEATCADM-1".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "actKpiAlarms", "value": "true", "operation": "update"},
     ]},
    {"distName": "MRBTS-{0}/MNL-1/MNLENT-1/TRBLCADM-1".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "kpiAlarmTriggers",
          "value": [{"faultID": "4574",
                     "formulaDescription": "XD",
                     "timeToTrigger": "0",
                     "triggeringFormula": "SBTS_SM_MAX_TEMPERATURE > SBTS_SFPSM_RX_POWER_LANE_SUM"}],
          "operation": "update"},
         {"parameterName": "kpiAlarmMutingTime", "value": "1", "operation": "update"},
     ]}]

tc_2_negative_scenario_unsupported_mix_of_counters_delta_2 = [
    {"distName": "MRBTS-{0}/MNL-1/MNLENT-1/FEATCADM-1".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "actKpiAlarms", "value": "true", "operation": "update"},
     ]},
    {"distName": "MRBTS-{0}/MNL-1/MNLENT-1/TRBLCADM-1".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "kpiAlarmTriggers",
          "value": [{"faultID": "4585",
                     "formulaDescription": "XD",
                     "timeToTrigger": "1",
                     "triggeringFormula": "SBTS_SFPRM_RX_POWER_LANE_MAX != SUCC_SETUP_USER_SA_PLMN"}],
          "operation": "update"},
         {"parameterName": "kpiAlarmMutingTime", "value": "1", "operation": "update"},
     ]}]

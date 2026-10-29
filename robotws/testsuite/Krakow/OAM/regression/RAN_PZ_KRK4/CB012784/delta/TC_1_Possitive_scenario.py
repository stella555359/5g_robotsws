import os

from robot.libraries.BuiltIn import BuiltIn

bts_id = BuiltIn().get_variable_value('${tl.gnbs[0].dus[0].global_bts_id}')
oam_ip = BuiltIn().get_variable_value('${tl.gnbs[0].dus[0].oam_ip.v4}').split('/')[0]

tc_1_possitive_scenario_delta_1 = [
    {"distName": "MRBTS-{0}/MNL-1/MNLENT-1/FEATCADM-1".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "actKpiAlarms", "value": "true", "operation": "update"},
     ]},
    {"distName": "MRBTS-{0}/MNL-1/MNLENT-1/TRBLCADM-1".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "kpiAlarmTriggers",
          "value": [{"faultID": "4570",
                     "formulaDescription": "description",
                     "timeToTrigger": "0",
                     "triggeringFormula": "SBTS_SFPBM_RX_POWER_LANE_MIN >-1.33"}],
          "operation": "update"},
     ]}]

tc_1_possitive_scenario_delta_2 = [
    {"distName": "MRBTS-{0}/MNL-1/MNLENT-1/FEATCADM-1".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "actKpiAlarms", "value": "true", "operation": "update"},
     ]},
    {"distName": "MRBTS-{0}/MNL-1/MNLENT-1/TRBLCADM-1".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "kpiAlarmTriggers",
          "value": [{"faultID": "4570",
                     "formulaDescription": "description",
                     "timeToTrigger": "0",
                     "triggeringFormula": "SBTS_SFPRM_BIASCURR_LANE_SUM < 5.0"},
                    {"faultID": "4571",
                     "formulaDescription": "description\tfor counters\tSBTS_SFPSM_TEMPERATURE_MIN\tand "
                                           "SBTS_SFPSM_RX_POWER_LANE_MAX",
                     "timeToTrigger": "1",
                     "triggeringFormula": "SBTS_SFPBM_TEMPERATURE_MIN > 3 AND SBTS_SFPBM_RX_POWER_LANE_MAX < 3 "
                                          "AND SBTS_SFPBM_RX_POWER_LANE_MIN < -0.005"},
                    {"faultID": "4586",
                     "formulaDescription": "description3",
                     "timeToTrigger": "0",
                     "triggeringFormula": "NOT(100 < sbts_sfprm_biascurr_lane_sum) AND SBTS_SFPRM_BIASCURR_LANE_SUM>5"},
                    {"faultID": "4579",
                     "formulaDescription": "'SBTS_SFPRM_BIASCURR_LANE_SUM'",
                     "timeToTrigger": "0",
                     "triggeringFormula": "(SBTS_SFPRM_BIASCURR_LANE_SUM == SBTS_SFPRM_BIASCURR_LANE_SUM AND "
                                          "SBTS_SFPRM_BIASCURR_LANE_SUM != SBTS_SFPRM_BIASCURR_LANE_SUM) OR "
                                          "(SBTS_SFPRM_BIASCURR_LANE_SUM-3 < SBTS_SFPRM_BIASCURR_LANE_SUM AND "
                                          "SBTS_SFPRM_BIASCURR_LANE_SUM < SBTS_SFPRM_BIASCURR_LANE_SUM-(-5))"},
                    {"faultID": "4588",
                     "formulaDescription": "description",
                     "timeToTrigger": "1",
                     "triggeringFormula": "SBTS_SFPBM_TX_POWER_LANE_MAX >=-0.86"},
                    {"faultID": "4575",
                     "formulaDescription": "description",
                     "timeToTrigger": "0",
                     "triggeringFormula": "10+SBTS_SFPBM_TX_POWER_LANE_SUM*10 < 91"},
                    {"faultID": "4576",
                     "formulaDescription": "description",
                     "timeToTrigger": "0",
                     "triggeringFormula": "SBTS_SFPRM_BIASCURR_LANE_SUM/0 != -100"}],
          "operation": "update"},
     ]}]

TC_1_alarm_1 = tc_1_possitive_scenario_delta_1[1]['parameters'][0]['value'][0]['triggeringFormula']
TC_1_alarm_description_1 = tc_1_possitive_scenario_delta_1[1]['parameters'][0]['value'][0]['formulaDescription']

TC_1_alarm_2 = [x['triggeringFormula'] for x in tc_1_possitive_scenario_delta_2[1]['parameters'][0]['value']]
TC_1_alarm_description_2 = [x['formulaDescription'] for x in
                            tc_1_possitive_scenario_delta_2[1]['parameters'][0]['value']]

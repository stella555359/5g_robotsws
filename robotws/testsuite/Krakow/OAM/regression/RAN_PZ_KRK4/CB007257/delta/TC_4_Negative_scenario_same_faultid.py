from robot.libraries.BuiltIn import BuiltIn

bts_id = BuiltIn().get_variable_value('${tl.gnbs[0].dus[0].global_bts_id}')

tc_4_negative_scenario_same_faultid_delta = [
    {"distName": "MRBTS-{0}/MNL-1/MNLENT-1/FEATCADM-1".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "actKpiAlarms", "value": "true", "operation": "update"},
     ]},
    {"distName": "MRBTS-{0}/MNL-1/MNLENT-1/TRBLCADM-1".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "kpiAlarmTriggers",
          "value": [
              {"faultID": "4570",
               "formulaDescription": "x",
               "timeToTrigger": "1",
               "triggeringFormula": "DENOM_CELL_AVAIL != 5"},
              {"faultID": "4570",
               "formulaDescription": "x",
               "timeToTrigger": "1",
               "triggeringFormula": "DENOM_CELL_AVAIL != 5"},
          ],
          "operation": "update"},
         {"parameterName": "kpiAlarmMutingTime", "value": "1", "operation": "update"},
     ]}]

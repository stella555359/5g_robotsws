from robot.libraries.BuiltIn import BuiltIn

bts_id = BuiltIn().get_variable_value('${tl.gnbs[0].dus[0].global_bts_id}')

tc_11_EDA_delta = [
    {"distName": "MRBTS-{0}/MNL-1/MNLENT-1/FEATCADM-1".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "actKpiAlarms", "value": "true", "operation": "update"},
     ]},
    {"distName": "MRBTS-{0}/MNL-1/MNLENT-1/TRBLCADM-1".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "kpiAlarmTriggers",
          "value": [{"faultID": "4569",
                     "formulaDescription": "description",
                     "timeToTrigger": "0",
                     "triggeringFormula": "X2_SGNB_ADD_REQ_ACK_SENT >= 1"}],
          "operation": "update"},
         {"parameterName": "kpiAlarmMutingTime", "value": "1", "operation": "update"},
     ]}]

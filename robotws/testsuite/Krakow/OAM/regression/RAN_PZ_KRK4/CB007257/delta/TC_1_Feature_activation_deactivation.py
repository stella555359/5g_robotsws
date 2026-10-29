from robot.libraries.BuiltIn import BuiltIn

bts_id = BuiltIn().get_variable_value('${tl.gnbs[0].dus[0].global_bts_id}')

tc_1_feature_activation_deactivation_delta = [
    {"distName": "MRBTS-{0}/MNL-1/MNLENT-1/FEATCADM-1".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "actKpiAlarms", "value": "false", "operation": "update"},
     ]},
    {"distName": "MRBTS-{0}/MNL-1/MNLENT-1/TRBLCADM-1".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "kpiAlarmTriggers",
          "value": [{"faultID": "4570",
                     "formulaDescription": "description",
                     "timeToTrigger": "1",
                     "triggeringFormula": "PDSCH_RANK1_64TBL_MCS_00 != 100000"}],
          "operation": "update"},
         {"parameterName": "kpiAlarmMutingTime", "value": "1", "operation": "update"},
     ]}]

feature_deactivation_delta = [
    {"distName": "MRBTS-{0}/MNL-1/MNLENT-1/FEATCADM-1".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "actKpiAlarms", "value": "false", "operation": "update"},
     ]}
]

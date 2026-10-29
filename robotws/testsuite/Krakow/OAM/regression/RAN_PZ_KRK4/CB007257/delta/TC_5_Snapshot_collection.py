import os

from robot.libraries.BuiltIn import BuiltIn

bts_id = BuiltIn().get_variable_value('${tl.gnbs[0].dus[0].global_bts_id}')
oam_ip = BuiltIn().get_variable_value('${tl.gnbs[0].dus[0].oam_ip.v4}').split('/')[0]

tc_5_snapshot_collection_delta = [
    {"distName": "MRBTS-{0}/MNL-1/MNLENT-1/TRBLCADM-1".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "diagSnapDestination", "value": "lss", "operation": "update"},
     ]},
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
                     "triggeringFormula": "(NR_CELL_PLAN_UNAVAIL_CHNG_TO + 10 -8 >= 3) AND"
                                          " (NR_CELL_PLAN_UNAVAIL_CHNG_TO != 0) OR (NR_CELL_PLAN_UNAVAIL_CHNG_TO"
                                          " * 2 > 4 ) OR NR_CELL_PLAN_UNAVAIL_CHNG_TO != 0"}],
          "operation": "update"},
         {"parameterName": "lssConfig",
          "value": [{"directory": "snapshot/alarm_triggered_snapshot",
                     "lssIPaddress": oam_ip,
                     "lssPortNo": "22"}],
          "operation": "update"},
     ]}]

TC_5_alarm = tc_5_snapshot_collection_delta[2]['parameters'][0]['value'][0]['triggeringFormula']
TC_5_alarm_description = tc_5_snapshot_collection_delta[2]['parameters'][0]['value'][0]['formulaDescription']

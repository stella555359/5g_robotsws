from robot.libraries.BuiltIn import BuiltIn

bts_id = BuiltIn().get_variable_value('${tl.gnbs[0].dus[0].global_bts_id}')

tc_7_intervals_and_timing_check_delta = [
    {"distName": "MRBTS-{0}/MNL-1/MNLENT-1/FEATCADM-1".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "actKpiAlarms", "value": "true", "operation": "update"},
     ]},
    {"distName": "MRBTS-{0}/MNL-1/MNLENT-1/TRBLCADM-1".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "kpiAlarmTriggers",
          "value": [{"faultID": "4570",
                     "formulaDescription": "description",
                     "timeToTrigger": "{}",
                     "triggeringFormula": "NR_CELL_PLAN_UNAVAIL_SAMPLES > 58"}],
          "operation": "update"},
     ]}]

tc_7_intervals_and_timing_check_kpiAlarmMutingTime_delta = [
    {"distName": "MRBTS-{0}/MNL-1/MNLENT-1/TRBLCADM-1".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "kpiAlarmMutingTime", "value": "{}", "operation": "update"},
     ]}]

tc_7_intervals_and_timing_check_cleaning_delta = [
    {"distName": "MRBTS-{0}/MNL-1/MNLENT-1/FEATCADM-1".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "actKpiAlarms", "value": "false", "operation": "update"},
     ]},
    {"distName": "MRBTS-{0}/MNL-1/MNLENT-1/TRBLCADM-1".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "kpiAlarmTriggers",
          "parameters": [],
          "operation": "delete"},
         {"parameterName": "kpiAlarmMutingTime",
          "parameters": [],
          "operation": "delete"},
     ]}]

from robot.libraries.BuiltIn import BuiltIn

bts_id = BuiltIn().get_variable_value('${tl.gnbs[0].dus[0].global_bts_id}')

feature_deactivation_delta = [
    {"distName": "MRBTS-{0}/MNL-1/MNLENT-1/FEATCADM-1".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "actKpiAlarms", "value": "false", "operation": "update"},
     ]}
]

activate_pm_counters_delta = [
    {"distName": "MRBTS-{0}/MNL-1/MNLENT-1/PMMNL-1".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "mtSBTSBBCAPEnergyMonitoring", "value": "15min", "operation": "update"},
         {"parameterName": "mtSBTSBBMODTemperature", "value": "5min", "operation": "update"},
         {"parameterName": "mtSBTSRMODFan", "value": "5min", "operation": "update"},
         {"parameterName": "mtSBTSRMODTemperature", "value": "5min", "operation": "update"},
         {"parameterName": "mtSBTSSMODTemperature", "value": "5min", "operation": "update"},
         {"parameterName": "mtSBTSSfpBBMOD", "value": "5min", "operation": "update"},
         {"parameterName": "mtSBTSSfpRMOD", "value": "15min", "operation": "update"},
         {"parameterName": "mtSBTSSfpSMOD", "value": "15min", "operation": "update"},
         {"parameterName": "mtSbtsSfpBbmodLane", "value": "5min", "operation": "update"},
         {"parameterName": "mtSbtsSfpFhs", "value": "5min", "operation": "update"},
         {"parameterName": "mtSbtsSfpFhsLane", "value": "5min", "operation": "update"},
         {"parameterName": "mtSbtsSfpRmodLane", "value": "5min", "operation": "update"},
         {"parameterName": "mtSbtsSfpSmodLane", "value": "5min", "operation": "update"}
     ]}
]

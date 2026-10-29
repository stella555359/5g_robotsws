from robot.libraries.BuiltIn import BuiltIn

bts_id = BuiltIn().get_variable_value('${tl.gnbs[0].dus[0].global_bts_id}')

delta = [
    {"distName": "MRBTS-{0}/NRBTS-{0}/NRCELL-61".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "prachConfigurationIndex", "value": "177", "operation": "update"},
     ]},
    {"distName": "MRBTS-{0}/NRBTS-{0}/NRCELL-62".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "prachConfigurationIndex", "value": "177", "operation": "update"},
     ]},
    {"distName": "MRBTS-{0}/NRBTS-{0}/NRCELL-63".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "prachConfigurationIndex", "value": "177", "operation": "update"},
     ]},
    {"distName": "MRBTS-{0}/NRBTS-{0}/NRCELL-64".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "prachConfigurationIndex", "value": "177", "operation": "update"},
     ]},
    {"distName": "MRBTS-{0}/NRBTS-{0}/NRCELL-65".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "prachConfigurationIndex", "value": "177", "operation": "update"},
     ]},
    {"distName": "MRBTS-{0}/NRBTS-{0}/NRCELL-66".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "prachConfigurationIndex", "value": "177", "operation": "update"},
     ]},
    {"distName": "MRBTS-{0}/NRBTS-{0}/NRCELL-67".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "prachConfigurationIndex", "value": "177", "operation": "update"},
     ]},
    {"distName": "MRBTS-{0}/NRBTS-{0}/NRCELL-68".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "prachConfigurationIndex", "value": "177", "operation": "update"},
     ]},
    {"distName": "MRBTS-{0}/NRBTS-{0}/NRCELL-71".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "prachConfigurationIndex", "value": "177", "operation": "update"},
     ]},
    {"distName": "MRBTS-{0}/NRBTS-{0}/NRCELL-72".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "prachConfigurationIndex", "value": "177", "operation": "update"},
     ]},
    {"distName": "MRBTS-{0}/NRBTS-{0}/NRCELL-73".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "prachConfigurationIndex", "value": "177", "operation": "update"},
     ]},
    {"distName": "MRBTS-{0}/NRBTS-{0}/NRCELL-74".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "prachConfigurationIndex", "value": "177", "operation": "update"},
     ]},
    {"distName": "MRBTS-{0}/NRBTS-{0}/NRCELL-75".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "prachConfigurationIndex", "value": "177", "operation": "update"},
     ]},
    {"distName": "MRBTS-{0}/NRBTS-{0}/NRCELL-76".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "prachConfigurationIndex", "value": "177", "operation": "update"},
     ]},
    {"distName": "MRBTS-{0}/NRBTS-{0}/NRCELL-77".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "prachConfigurationIndex", "value": "177", "operation": "update"},
     ]},
    {"distName": "MRBTS-{0}/NRBTS-{0}/NRCELL-78".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "prachConfigurationIndex", "value": "177", "operation": "update"},
     ]}
]

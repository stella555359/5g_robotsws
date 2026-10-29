enable_PoE_for_AWHQC_1 = [
    {"distName": "ASI-1/HUBMOD-2/ANTPORT-1",
     "parameters": [
         {"operation": "update", "parameterName": "poeEnabled", "value": "true"}
     ]}
]

enable_PoE_for_AWHQC_2 = [
    {"distName": "ASI-1/HUBMOD-1/ANTPORT-1",
     "parameters": [
         {"operation": "update", "parameterName": "poeEnabled", "value": "true"}
     ]}
]

enable_PoE_for_AWHQC_1_supercell = [
    {"distName": "ASI-1/HUBMOD-3/ANTPORT-1",
     "parameters": [
         {"operation": "update", "parameterName": "poeEnabled", "value": "true"}
     ]}
]

enable_PoE_for_AWHQC_2_supercell = [
    {"distName": "ASI-1/HUBMOD-2/ANTPORT-1",
     "parameters": [
         {"operation": "update", "parameterName": "poeEnabled", "value": "true"}
     ]}
]

disable_PoE_for_AWHQC_1 = [
    {"distName": "ASI-1/HUBMOD-2/ANTPORT-1",
     "parameters": [
         {"operation": "update", "parameterName": "poeEnabled", "value": "false"}
     ]}
]

disable_PoE_for_AWHQC_2 = [
    {"distName": "ASI-1/HUBMOD-1/ANTPORT-1",
     "parameters": [
         {"operation": "update", "parameterName": "poeEnabled", "value": "false"}
     ]}
]

disable_PoE_for_AWHQC_1_supercell = [
    {"distName": "ASI-1/HUBMOD-3/ANTPORT-1",
     "parameters": [
         {"operation": "update", "parameterName": "poeEnabled", "value": "false"}
     ]}
]

disable_PoE_for_AWHQC_2_supercell = [
    {"distName": "ASI-1/HUBMOD-2/ANTPORT-1",
     "parameters": [
         {"operation": "update", "parameterName": "poeEnabled", "value": "false"}
     ]}
]

sHUB_enabled_status = {'operationalState': 'enabled', 'commissioned': 'Yes', 'localState': 'unblocked',
                       'hardwareState': 'working', 'softwareState': 'configured', 'activeStatusLEDColor': 'Green',
                       'faultStatusLEDColor': 'Off', 'powerStatusLEDColor': 'Green'}

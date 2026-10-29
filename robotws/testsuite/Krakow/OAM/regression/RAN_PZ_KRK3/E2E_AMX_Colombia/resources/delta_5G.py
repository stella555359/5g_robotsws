delta_online = """[{"distName": "MRBTS-75125/MNL-1/MNLENT-1/TRBLCADM-1", "operation": "update", "parameters": [
    {"parameterName": "syslogSubstringTrigger", "value": "OnlineComissioning", "operation": "update"}]}]"""
delta_reset = """[{"distName": "MRBTS-75125/MNL-1/MNLENT-1/SYNC-1",
               "operation": "update",
               "parameters": [{"parameterName": "manualFrameTimingAdjustment",
                               "value": "100",
                               "operation": "update"}]}]"""
delta_nr_reset = """[{"distName": "MRBTS-75125/NRBTS-75125",
               "operation": "update",
               "parameters": [{"parameterName": "actSchedFairnessUlOlc",
                               "value": "true",
                               "operation": "update"}]}]"""

delta_online_084 = """[{"distName": "MRBTS-77084/MNL-1", "operation": "update", "parameters": [
    {"parameterName": "validatePlanAgainstDetectedHW", "value": "true", "operation": "update"}]}]"""
delta_reset_084 = """[{"distName": "MRBTS-77084/MNL-1/MNLENT-1/SYNC-1",
               "operation": "update",
               "parameters": [{"parameterName": "manualFrameTimingAdjustment",
                               "value": "100",
                               "operation": "update"}]}]"""
delta_rat_reset_084 = """[{"distName": "MRBTS-77084/NRBTS-77084",
               "operation": "update",
               "parameters": [{"parameterName": "actSchedFairnessUlOlc",
                               "value": "true",
                               "operation": "update"}]}]"""

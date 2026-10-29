from robot.libraries.BuiltIn import BuiltIn

bts_id = BuiltIn().get_variable_value('${tl.gnbs[0].dus[0].global_bts_id}')

tc_1_delta_1 = [
    {"distName": "MRBTS-{0}/MNL-1/MNLENT-1/TRBLCADM-1/SLCELLDRCONF-1".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "nrRxPwrSlCellRecPhAct", "value": "Phase 1", "operation": "update"},
         {"parameterName": "nrRxPwrSlCellRecPh1Tmr", "value": "240", "operation": "update"},
         {"parameterName": "nrRxPwrSlCellRecPh2Tmr", "value": "240", "operation": "update"},
         {"parameterName": "nrRxPwrSlCellDetLowPwrThr", "value": "1789", "operation": "update"},
     ]},
    {"distName": "MRBTS-{0}/MNL-1/MNLENT-1/FEATCADM-1".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "actNrAutRxPwrSlCellDetRec", "value": "true", "operation": "update"},
     ]}]

tc_1_delta_2 = [
    {"distName": "MRBTS-{0}/MNL-1/MNLENT-1/TRBLCADM-1/SLCELLDRCONF-1".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "nrRxPwrSlCellRecPhAct", "value": "Phase 2", "operation": "update"},
     ]},
    {"distName": "MRBTS-{0}/MNL-1/MNLENT-1/FEATCADM-1".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "actNrAutRxPwrSlCellDetRec", "value": "false", "operation": "update"},
     ]}]

tc_1_delta_3 = [
    {"distName": "MRBTS-{0}/MNL-1/MNLENT-1/TRBLCADM-1/SLCELLDRCONF-1".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "nrRxPwrSlCellDetLowPwrThr", "value": "1789", "operation": "update"},
     ]},
    {"distName": "MRBTS-{0}/MNL-1/MNLENT-1/FEATCADM-1".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "actNrAutRxPwrSlCellDetRec", "value": "true", "operation": "update"},
     ]}]

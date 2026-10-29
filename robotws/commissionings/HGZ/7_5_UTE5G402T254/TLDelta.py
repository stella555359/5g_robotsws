from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")
MR_BTS_NAME = "MRBTS-" + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + "/NRBTS-" + str(tl.gnbs[0].global_bts_id)

# Used for block all PA ports to reduce interference
PA_OUT_PORTS = [5, 6, 7, 8]
PA_ROWS = 32

# PARAMS_TO_MODIFY_GOLDEN and PARAMS_TO_ADD_GOLDEN are related with peak.
PARAMS_TO_MODIFY_GOLDEN = [
    dict(value="true", dist_name=MR_NR_BTS_NAME + "/NRCELL-1", p_name="actPrachMultiplexing"),
    dict(value="true", dist_name=MR_NR_BTS_NAME + "/NRCELL-2", p_name="actPrachMultiplexing"),
    dict(value="pos3", dist_name=MR_NR_BTS_NAME + "/NRCELL-1", p_name="dmrsTypeAPosition"),
    dict(value="pos2", dist_name=MR_NR_BTS_NAME + "/NRCELL-2", p_name="dmrsTypeAPosition"),
    dict(value="true", dist_name=MR_NR_BTS_NAME + "/NRCELL-1", p_name="actPdschRmCsirsForTracking"),
    dict(value="true", dist_name=MR_NR_BTS_NAME + "/NRCELL-2", p_name="actPdschRmCsirsForTracking"),
    dict(value="-90", dist_name=MR_NR_BTS_NAME + "/NRCELL-2", p_name="p0NominalPucchF1F3",
         list_name='ulPowerControlCommon'),
]

PARAMS_TO_ADD_GOLDEN = [
    dict(
        dist_name=MR_NR_BTS_NAME + "/NRCELL-1",
        list_name="dynPdcchTdMgt",
        elements={
            "actDynPdcchTd": "true",
            "pdcchBlockingThreshold": "30",
            "pdcchFreeThreshold": "50"}),
    dict(
        dist_name=MR_NR_BTS_NAME + "/NRCELL-2",
        list_name="dynPdcchTdMgt",
        elements={
            "actDynPdcchTd": "true",
            "pdcchBlockingThreshold": "30",
            "pdcchFreeThreshold": "50"}),
]

# This is WA for 2329 and will be removed after align golden SCF
PARAMS_TO_ADD_GOLDEN_2329 = PARAMS_TO_ADD_GOLDEN

# Used for TMO peak tput check via RRC message, take 6137-A as an example
EXP_CELL_TPUT_INFO = {
    2: {'bandwidth': '20M', 'maxMIMO_layers_ul': '1', 'ul_tput': 70, 'maxMIMO_layers_dl': '2', 'dl_tput': 200},
    1: {'bandwidth': '100M', 'maxMIMO_layers_ul': '1', 'ul_tput': 72.95, 'maxMIMO_layers_dl': '4', 'dl_tput': 1400},
    3: {'bandwidth': '10M', 'maxMIMO_layers_ul': '1', 'ul_tput': '', 'maxMIMO_layers_dl': '2', 'dl_tput': 95},
    5: {'bandwidth': '60M', 'maxMIMO_layers_ul': '1', 'ul_tput': '', 'maxMIMO_layers_dl': '4', 'dl_tput': 850}
}

# Add allowed fault ids for TL254, if for multiple alarms, you can add here. like 61074,2922
ALLOWED_FAULTS_IDS = "61074"

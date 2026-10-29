from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")
MR_BTS_NAME = "MRBTS-" + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + "/NRBTS-" + str(tl.gnbs[0].global_bts_id)

# MODIFY_SCF_80040_ENABLE = [
#     dict(
#         value='true',
#         dist_name=MR_NR_BTS_NAME,
#         p_name='actProactResendRlcPdu')
# ]

# PARAMS_TO_MODIFY_GOLDEN and PARAMS_TO_ADD_GOLDEN are related with peak.
PARAMS_TO_MODIFY_GOLDEN = [
    dict(value="true", dist_name=MR_NR_BTS_NAME + "/NRCELL-1", p_name="actPrachMultiplexing"),
    dict(value="true", dist_name=MR_NR_BTS_NAME + "/NRCELL-2", p_name="actPrachMultiplexing"),
    dict(value="pos2", dist_name=MR_NR_BTS_NAME + "/NRCELL-1", p_name="dmrsTypeAPosition"),
    dict(value="pos3", dist_name=MR_NR_BTS_NAME + "/NRCELL-2", p_name="dmrsTypeAPosition"),
    dict(value="true", dist_name=MR_NR_BTS_NAME + "/NRCELL-1", p_name="actPdschRmCsirsForTracking"),
    dict(value="true", dist_name=MR_NR_BTS_NAME + "/NRCELL-2", p_name="actPdschRmCsirsForTracking"),
    # dict(value="370", dist_name=MR_NR_BTS_NAME + "/NRCELL-1", p_name="pMax"),
]

# Leave this NIDDs for other feature TestData invoking
PARAMS_TO_ADD_GOLDEN = []

BWP_ID_MAPPING = {
    'TDD_1116_0_100M': {'initial': '7', 'dedicate': '11'},
    'TDD_1116_0_60M': {'initial': '7', 'dedicate': '73'},
    'TDD_1116_3_100M': {'initial': '12', 'dedicate': '102'},
    'TDD_8406_100M': {'initial': '20', 'dedicate': '50'},
    'TDD_8406_60M': {'initial': '20', 'dedicate': '51'},
    'TDD_1070_100M': {'initial': '13', 'dedicate': '103'},
    'TDD_1070_60M': {'initial': '13', 'dedicate': '106'},
    'TDD_1070_20M': {'initial': '16', 'dedicate': '107'},
    'FDD_10M': {'initial': '1', 'dedicate': '33'},
    'FDD_20M': {'initial': '1', 'dedicate': '32'},
    'FDD_20M_2329': {'initial': '1', 'dedicate': '32'}  # Will be removed after other TLs has aligned BWP
}

# Used for block all PA ports to reduce interference
PA_OUT_PORTS = [1, 2, 3, 4]
PA_ROWS = 32

# Used for TMO peak tput check via RRC message, take 6137-A as an example
EXP_CELL_TPUT_INFO = {
    2: {'bandwidth': '20M', 'maxMIMO_layers_ul': '1', 'ul_tput': 78.9, 'maxMIMO_layers_dl': '2', 'dl_tput': 214.8},
    1: {'bandwidth': '100M', 'maxMIMO_layers_ul': '1', 'ul_tput': 72.95, 'maxMIMO_layers_dl': '4', 'dl_tput': 1500},
    3: {'bandwidth': '10M', 'maxMIMO_layers_ul': '1', 'ul_tput': '', 'maxMIMO_layers_dl': '2', 'dl_tput': 98},
    5: {'bandwidth': '60M', 'maxMIMO_layers_ul': '1', 'ul_tput': '', 'maxMIMO_layers_dl': '4', 'dl_tput': 881}
}

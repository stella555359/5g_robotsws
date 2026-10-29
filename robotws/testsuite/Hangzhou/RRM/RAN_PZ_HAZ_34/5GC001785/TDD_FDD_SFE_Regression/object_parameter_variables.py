from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")

# MO = {"GNB1": [
#     {
#         "class_name": "NOKLTE:LNADJGNB",
#         "dist_name": f"MRBTS-{tl.gnbs[0].dus[0]}/LNBTS-{tl.enbs[0].dus[0]}/",
#         "version": "xL24R1_2322_110",
#         "NUM": 128
#     },
#     {
#         "class_name": "NOKLTE:LNADJGNB",
#         "dist_name": f"MRBTS-{tl.gnbs[0].dus[0]}/LNBTS-{tl.enbs[0].dus[0]}/",
#         "version": "xL24R1_2322_110",
#         "NUM": 128
#     },
# ]
# }
"""4Gpart"""
"LNADJ:256"
"MRBTS-35811/LNBTS-35821/LNADJ-252"
# {'dist_name': 'MRBTS-35811/NRBTS-35811', 'p_name': 'xnSetupRespTmr', 'value': '60'}

"LNADJL:256"
"MRBTS-35811/LNBTS-35821/LNADJ-252/LNADJL-253"

"LNADJG:256"
"MRBTS-35811/LNBTS-35821/LNADJG-2"

"LNREL:389"
"MRBTS-35811/LNBTS-35821/LNCEL-1/LNREL-327"

"LNRELG:256"
"MRBTS-35811/LNBTS-35821/LNCEL-1/LNRELG-0"

"LNRELGNBCELL:256"
"MRBTS-35811/LNBTS-35821/LNCEL-1/LNRELGNBCELL-0"

"LNMME:64"
"MRBTS-35811/LNBTS-35821/LNMME-12"

"PMQAP:64"
"MRBTS-35811/LNBTS-35821/PMRNL-1/PMQAP-1"

"""5Gpart"""
"NRADJGNB:256"
"MRBTS-35811/NRBTS-35811/NRADJGNB-245"

"NRADJECELL:5000"
"MRBTS-35811/NRBTS-35811/NRADJECELL-4985"

"NRRELE:256"
"MRBTS-35811/NRBTS-35811/NRCELL-21/NRRELE-238"

"BWP_PROFILE:150"
"MRBTS-35811/NRBTS-35811/BWP_PROFILE-4"

"NRADJNRCELL:12288"
"MRBTS-35811/NRBTS-35811/NRADJNRCELL-83"

"NRX2LINK_TRUST:512"
"MRBTS-35811/NRBTS-35811/NRX2LINK_TRUST-268"

"SNSSAI:2000"
"MRBTS-35811/NRBTS-35811/SNSSAI-10"

"XNLINK:256"
"MRBTS-35811/NRBTS-35811/XNLINK-20"

all_required_add_paras = [
    {"dist_name": "MRBTS-35811/LNBTS-35811/LNADJ-", "p_name": "cPlaneIpAddrCtrl", "value": "oamControlled"},
    {"dist_name": "MRBTS-35811/LNBTS-35811/LNADJ-", "p_name": "rlfBasedRCRsupported", "value": "false"}
]

all_required_mos = [
    {"start_index": 0, "end_index": 256, "bts_name": "LNBTS", "mo_name": "LNADJ", "cp_i": 0},
    {"start_index": 0, "end_index": 256, "bts_name": "LNBTS", "mo_name": "LNADJG", "cp_i": 0},
    {"start_index": 0, "end_index": 128, "bts_name": "LNBTS", "mo_name": "LNADJGNB", "cp_i": 0},
    {"start_index": 0, "end_index": 64, "bts_name": "LNBTS", "mo_name": "LNMME", "cp_i": 0},
    {"start_index": 0, "end_index": 256, "bts_name": "NRBTS", "mo_name": "NRADJGNB", "cp_i": 1},
    {"start_index": 0, "end_index": 5000, "bts_name": "NRBTS", "mo_name": "NRADJECELL", "cp_i": 1},
    {"start_index": 0, "end_index": 150, "bts_name": "NRBTS", "mo_name": "BWP_PROFILE", "cp_i": 1},
    {"start_index": 0, "end_index": 12288, "bts_name": "NRBTS", "mo_name": "NRADJNRCELL", "cp_i": 1},
    {"start_index": 0, "end_index": 512, "bts_name": "NRBTS", "mo_name": "NRX2LINK_TRUST", "cp_i": 257},
    {"start_index": 0, "end_index": 2000, "bts_name": "NRBTS", "mo_name": "SNSSAI", "cp_i": 1},
    {"start_index": 0, "end_index": 256, "bts_name": "NRBTS", "mo_name": "XNLINK", "cp_i": 1},
]

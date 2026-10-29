import os

__team__ = "MN 5G RAN I&V 4 Pz HZG SG1"
__email__ = "I_MN_5G_RAN_IV4_LINE_HZG_1@internal.nsn.com"


PARAMS_TO_MODIFY_5752_B_12 = [
    dict(
        value="NSA",
        dist_name="MRBTS-10031/NRBTS-10031",
        p_name="gNbCuType",
    ),
    dict(
        value="NSA",
        dist_name="MRBTS-10031/NRBTS-10031/NRCELL-1",
        p_name="cellDepType",
    ),
    dict(
        value="NSA",
        dist_name="MRBTS-10031/NRBTS-10031/NRCELL-2",
        p_name="cellDepType",
    ),
]


PARAMS_TO_DELETE_5752_B_12 = [
    dict(dist_name="MRBTS-10031/NRBTS-10031/NRPLMN-1"),
    dict(dist_name="MRBTS-10031/NRBTS-10031/NRSYSINFO_PROFILE-0"),
    dict(dist_name="MRBTS-10031/NRBTS-10031/NRSYSINFO_PROFILE-0/NRIAFIM-1"),
    dict(dist_name="MRBTS-10031/NRBTS-10031/NRSYSINFO_PROFILE-1"),
    dict(dist_name="MRBTS-10031/NRBTS-10031/NRSYSINFO_PROFILE-1/NRIAFIM-1"),
    dict(dist_name="MRBTS-10031/NRBTS-10031/SERVEDAMF-1"),
    dict(dist_name="MRBTS-10031/NRBTS-10031/SNSSAI-1"),
    dict(dist_name="MRBTS-10031/NRBTS-10031/NRCELL-1", p_name="nrSysInfoProfileDN"),
    dict(dist_name="MRBTS-10031/NRBTS-10031/NRCELL-1", p_name="trackingAreaDN"),
    dict(dist_name="MRBTS-10031/NRBTS-10031/NRCELL-2", p_name="nrSysInfoProfileDN"),
    dict(dist_name="MRBTS-10031/NRBTS-10031/NRCELL-2", p_name="trackingAreaDN"),
    dict(dist_name="MRBTS-10031/NRBTS-10031", list_name="xnCplane"),
    dict(dist_name="MRBTS-10031/NRBTS-10031", list_name="xnUplane"),
    dict(dist_name="MRBTS-10031/NRBTS-10031", list_name="ngCplane"),
    dict(dist_name="MRBTS-10031/NRBTS-10031", list_name="ngUplane"),
    dict(
        dist_name="MRBTS-10031/NRBTS-10031/TRACKINGAREA-210", list_name="snssaiDNList"
    ),
]

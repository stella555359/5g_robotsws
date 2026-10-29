import os

__team__ = "MN 5G RAN I&V 4 Pz HZG SG1"
__email__ = "I_MN_5G_RAN_IV4_LINE_HZG_1@internal.nsn.com"


PARAMS_TO_MODIFY_CNI_84033_Case1 = [
    dict(
        value="Locked",
        dist_name="MRBTS-430000000/NRBTS-430000000/NRCELL-1",
        p_name="administrativeState",
    ),
    dict(
        value="false",
        dist_name="MRBTS-430000/NRBTS-430000",
        p_name="actNonGbrServiceDiff",
    ),
    dict(
        value="true",
        dist_name="MRBTS-430000/NRBTS-430000",
        p_name="actFdmScheduling",
    ),
    dict(
        value="2",
        dist_name="MRBTS-430000/NRBTS-430000/NRCELL-2",
        p_name="maxNumPdschAllocationPerSlot",
    ),
    dict(
        value="2",
        dist_name="MRBTS-430000/NRBTS-430000/NRCELL-2",
        p_name="maxNumPuschAllocationPerSlot",
    ),
    dict(
        value="MRBTS-430000/NRBTS-430000/NRDRB-12",
        dist_name="MRBTS-430000/NRBTS-430000/NRDRB_5QI-3",
        p_name="nrDrbDN",
    ),
    dict(
        value="3",
        dist_name="MRBTS-430000/NRBTS-430000/NRDRB-12",
        p_name="schedulWeight",
    ),
    dict(
        value="MRBTS-430000/NRBTS-430000/NRDRB-11",
        dist_name="MRBTS-430000/NRBTS-430000/NRDRB_5QI-2",
        p_name="nrDrbDN",
    ),
    dict(
        value="1",
        dist_name="MRBTS-430000/NRBTS-430000/NRDRB-11",
        p_name="schedulWeight",
    ),
    dict(
        value="MRBTS-430000/NRBTS-430000/NRDRB-10",
        dist_name="MRBTS-430000/NRBTS-430000/NRDRB_5QI-1",
        p_name="nrDrbDN",
    ),
    dict(
        value="2",
        dist_name="MRBTS-430000/NRBTS-430000/NRDRB-10",
        p_name="schedulWeight",
    ),
]

PARAMS_TO_ADD_CNI_84033_Case1 = [
    dict(
        dist_name="MRBTS-430000/NRBTS-430000/NRDRB_5QI-1",
        list_name="fiveqiValueList",
        elements=["5"],
    ),
    dict(
        dist_name="MRBTS-430000/NRBTS-430000/NRDRB_5QI-2",
        list_name="fiveqiValueList",
        elements=["6"],
    ),
    dict(
        dist_name="MRBTS-430000/NRBTS-430000/NRDRB_5QI-3",
        list_name="fiveqiValueList",
        elements=["7"],
    ),
]

PARAMS_TO_DELETE_CNI_84033_Case1 = [
    dict(dist_name="MRBTS-430000/NRBTS-430000/NRDRB_5QI-2", list_name="fiveqiValueList"),
    dict(dist_name="MRBTS-430000/NRBTS-430000/NRDRB_5QI-3", list_name="fiveqiValueList"),
    dict(dist_name="MRBTS-430000/NRBTS-430000/NRDRB_5QI-1", list_name="fiveqiValueList"),
]

PARAMS_TO_MODIFY_CNI_84033_Case2 = [
    dict(
        value="true",
        dist_name="MRBTS-430000/NRBTS-430000",
        p_name="actNonGbrServiceDiff",
    ),
    dict(
        value="true",
        dist_name="MRBTS-430000/NRBTS-430000",
        p_name="actMultiDrbNSA",
    ),
    dict(
        value="true",
        dist_name="MRBTS-430000/NRBTS-430000/NRDRB-1",
        p_name="nsa3xBearerAllowed",
    ),
    dict(
        value="true",
        dist_name="MRBTS-430000/NRBTS-430000/NRDRB-2",
        p_name="nsa3xBearerAllowed",
    ),
    dict(
        value="true",
        dist_name="MRBTS-430000/NRBTS-430000/NRDRB-8",
        p_name="nsa3xBearerAllowed",
    ),
    dict(
        value="true",
        dist_name="MRBTS-430000/NRBTS-430000/NRDRB-9",
        p_name="nsa3xBearerAllowed",
    ),
    dict(
        value="MRBTS-430000/NRBTS-430000/NRDRB-2",
        dist_name="MRBTS-430000/NRBTS-430000/NRDRB_QCI-3",
        p_name="nrDrbDN",
    ),
    dict(
        value="2",
        dist_name="MRBTS-430000/NRBTS-430000/NRDRB-2",
        p_name="schedulWeight",
    ),
    dict(
        value="MRBTS-430000/NRBTS-430000/NRDRB-8",
        dist_name="MRBTS-430000/NRBTS-430000/NRDRB_QCI-7",
        p_name="nrDrbDN",
    ),
    dict(
        value="4",
        dist_name="MRBTS-430000/NRBTS-430000/NRDRB-8",
        p_name="schedulWeight",
    ),
    dict(
        value="1",
        dist_name="MRBTS-430000/NRBTS-430000/NRDRB-1",
        p_name="schedulWeight",
    ),
    dict(
        value="MRBTS-430000/NRBTS-430000/NRDRB-9",
        dist_name="MRBTS-430000/NRBTS-430000/NRDRB_QCI-8",
        p_name="nrDrbDN",
    ),
    dict(
        value="3",
        dist_name="MRBTS-430000/NRBTS-430000/NRDRB-9",
        p_name="schedulWeight",
    ),
    dict(
        value="7000",
        dist_name="MRBTS-430000/NRBTS-430000",
        p_name="nsaInactivityTimer",
    ),
]

PARAMS_TO_ADD_CNI_84033_Case2 = [
    dict(
        dist_name="MRBTS-430000/NRBTS-430000/NRDRB_QCI-3",
        list_name="qciValueList",
        elements=["7"],
    ),
    dict(
        dist_name="MRBTS-430000/NRBTS-430000/NRDRB_QCI-7",
        list_name="qciValueList",
        elements=["70"],
    ),
    dict(
        dist_name="MRBTS-430000/NRBTS-430000/NRDRB_QCI-8",
        list_name="qciValueList",
        elements=["79"],
    ),
]

PARAMS_TO_DELETE_CNI_84033_Case2 = [
    dict(dist_name="MRBTS-430000/NRBTS-430000/NRDRB_QCI-3", list_name="qciValueList"),
    dict(dist_name="MRBTS-430000/NRBTS-430000/NRDRB_QCI-7", list_name="qciValueList"),
    dict(dist_name="MRBTS-430000/NRBTS-430000/NRDRB_QCI-8", list_name="qciValueList"),
]

PARAMS_TO_MODIFY_CNI_84033_Case3 = [
    dict(
        value="true",
        dist_name="MRBTS-430000/NRBTS-430000/NRCELL-2",
        p_name="actNonVoNRGbrService",
    ),
    dict(
        value="MRBTS-430000/NRBTS-430000/NRDRB-15",
        dist_name="MRBTS-430000/NRBTS-430000/NRDRB_5QI-6",
        p_name="nrDrbDN",
    ),
    dict(
        value="GBR",
        dist_name="MRBTS-430000/NRBTS-430000/NRDRB-15",
        p_name="resType",
    ),
    dict(
        value="MRBTS-430000/NRBTS-430000/NRDRB-16",
        dist_name="MRBTS-430000/NRBTS-430000/NRDRB_5QI-7",
        p_name="nrDrbDN",
    ),
    dict(
        value="1",
        dist_name="MRBTS-430000/NRBTS-430000/NRDRB-16",
        p_name="schedulWeight",
    ),
    dict(
        value="GBR",
        dist_name="MRBTS-430000/NRBTS-430000/NRDRB-16",
        p_name="resType",
    ),
    dict(
        value="MRBTS-430000/NRBTS-430000/NRDRB-11",
        dist_name="MRBTS-430000/NRBTS-430000/NRDRB_5QI-2",
        p_name="nrDrbDN",
    ),
    dict(
        value="40",
        dist_name="MRBTS-430000/NRBTS-430000/NRDRB-11",
        p_name="schedulWeight",
    ),
]

PARAMS_TO_ADD_CNI_84033_Case3 = [
    dict(
        dist_name="MRBTS-430000/NRBTS-430000/NRDRB_5QI-6",
        list_name="fiveqiValueList",
        elements=["1"],
    ),
    dict(
        dist_name="MRBTS-430000/NRBTS-430000/NRDRB_5QI-7",
        list_name="fiveqiValueList",
        elements=["2"],
    ),
    dict(
        dist_name="MRBTS-430000/NRBTS-430000/NRDRB_5QI-2",
        list_name="fiveqiValueList",
        elements=["6"],
    ),
]

PARAMS_TO_DELETE_CNI_84033_Case3 = [
    dict(dist_name="MRBTS-430000/NRBTS-430000/NRDRB_5QI-6", list_name="fiveqiValueList"),
    dict(dist_name="MRBTS-430000/NRBTS-430000/NRDRB_5QI-7", list_name="fiveqiValueList"),
    dict(dist_name="MRBTS-430000/NRBTS-430000/NRDRB_5QI-2", list_name="fiveqiValueList"),
]

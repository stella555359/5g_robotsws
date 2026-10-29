import os

__team__ = "MN 5G RAN I&V 4 Pz HZG SG1"
__email__ = "I_MN_5G_RAN_IV4_LINE_HZG_1@internal.nsn.com"


# modify CB008204_E2 SCF
# CU
PARAMS_TO_DELETE_CU_8204_E2 = []

MOs_TO_ADD_CU_8204_E2 = [
    dict(
        class_name="com.nokia.srbts.nrbts:NRPMCCP",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMCCP-1",
        version="NRBTSCU23R1_2220_101",
    ),
    dict(
        class_name="com.nokia.srbts.nrbts:NRPMQAP",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMQAP-1",
        version="NRBTSCU23R1_2220_101",
    ),
    dict(
        class_name="com.nokia.srbts.nrbts:NRPMQAP",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMQAP-2",
        version="NRBTSCU23R1_2220_101",
    ),
]

PARAMS_TO_MODIFY_CU_8204_E2 = [
    dict(value="true", dist_name="MRBTS-10550/NRBTS-10550", p_name="actIpThpt"),
    dict(
        value="true", dist_name="MRBTS-10550/NRBTS-10550", p_name="actNrpmqapProfiles"
    ),
    dict(
        value="15min",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1",
        p_name="miNrF1UInterfaceCUpmqap",
    ),
    dict(
        value="15min",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1",
        p_name="miNrNsaAcCuNrpmqap",
    ),
    dict(
        value="15min",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1",
        p_name="miNrPDCPCell",
    ),
    dict(
        value="15min",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1",
        p_name="miNrPdcpCellNrpmqap",
    ),
    dict(
        value="15min",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1",
        p_name="miNrX2UInterfacepmqap",
    ),
    dict(
        value="15min",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1",
        p_name="miNrX2ccNrpmqap",
    ),
    dict(
        value="Bin ranges based on SCS",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMCCP-1",
        p_name="cfgTAcounters",
    ),
    dict(
        value="1-15",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMQAP-1",
        p_name="cfgArpRange",
    ),
    dict(
        value="NSA",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMQAP-1",
        p_name="cfgProfType",
    ),
    dict(
        value="7,8,9",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMQAP-1",
        p_name="cfgQciRange",
    ),
    dict(
        value="5-7",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMQAP-2",
        p_name="cfg5qiRange",
    ),
    dict(
        value="1-15",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMQAP-2",
        p_name="cfgArpRange",
    ),
    dict(
        value="SA",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMQAP-2",
        p_name="cfgProfType",
    ),
]


LIST_PARAMS_TO_MODIFY_CU_8204_E2 = []


LIST_TO_ADD_CU_8204_E2 = [
    dict(
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMQAP-1",
        list_name="cfgPlmnId",
        elements=dict(mcc="460", mnc="2", mncLength="2"),
    ),
    dict(
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMQAP-2",
        list_name="cfgPlmnId",
        elements=dict(mcc="460", mnc="2", mncLength="2"),
    ),
    dict(
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMQAP-2",
        list_name="cfgSliceId",
        elements=dict(sd="13714341", sst="1"),
    ),
]

# DU

PARAMS_TO_DELETE_DU_8204_E2 = []

MOs_TO_ADD_DU_8204_E2 = [
    dict(
        class_name="com.nokia.srbts.nrbts:NRPMCCP",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMCCP-1",
        version="NRBTSVDU23R1_2220_101",
    ),
    dict(
        class_name="com.nokia.srbts.nrbts:NRPMQAP",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMQAP-1",
        version="NRBTSVDU23R1_2220_101",
    ),
    dict(
        class_name="com.nokia.srbts.nrbts:NRPMQAP",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMQAP-2",
        version="NRBTSVDU23R1_2220_101",
    ),
]

PARAMS_TO_MODIFY_DU_8204_E2 = [
    dict(value="true", dist_name="MRBTS-10550/NRBTS-10550", p_name="actIpThpt"),
    dict(
        value="true", dist_name="MRBTS-10550/NRBTS-10550", p_name="actNrpmqapProfiles"
    ),
    dict(
        value="15min",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1",
        p_name="miNrCellUtilization",
    ),
    dict(
        value="15min",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1",
        p_name="miNrHighRlcCell",
    ),
    dict(
        value="15min",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1",
        p_name="miNrHighRlcCellNrpmqap",
    ),
    dict(
        value="15min",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1",
        p_name="miNrPRBthroughputpmqap",
    ),
    dict(
        value="Bin ranges based on SCS",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMCCP-1",
        p_name="cfgTAcounters",
    ),
    dict(
        value="1-15",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMQAP-1",
        p_name="cfgArpRange",
    ),
    dict(
        value="NSA",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMQAP-1",
        p_name="cfgProfType",
    ),
    dict(
        value="7,8,9",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMQAP-1",
        p_name="cfgQciRange",
    ),
    dict(
        value="5-7",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMQAP-2",
        p_name="cfg5qiRange",
    ),
    dict(
        value="1-15",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMQAP-2",
        p_name="cfgArpRange",
    ),
    dict(
        value="SA",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMQAP-2",
        p_name="cfgProfType",
    ),
]

LIST_PARAMS_TO_MODIFY_DU_8204_E2 = []

LIST_TO_ADD_DU_8204_E2 = [
    dict(
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMQAP-1",
        list_name="cfgPlmnId",
        elements=dict(mcc="460", mnc="2", mncLength="2"),
    ),
    dict(
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMQAP-2",
        list_name="cfgPlmnId",
        elements=dict(mcc="460", mnc="2", mncLength="2"),
    ),
    dict(
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMQAP-2",
        list_name="cfgSliceId",
        elements=dict(sd="13714341", sst="1"),
    ),
]


# modify CB008204_C1 SCF
# CU
PARAMS_TO_DELETE_CU_8204_C1 = [
    # NSA parameters
    dict(dist_name="MRBTS-10550/NRBTS-10550/NRCELL-1", p_name="trackingAreaDN"),
    dict(dist_name="MRBTS-10550/NRBTS-10550/NRCELL-2", p_name="trackingAreaDN"),
    dict(dist_name="MRBTS-10550/NRBTS-10550/SERVEDAMF-1"),
    dict(dist_name="MRBTS-10550/NRBTS-10550/SNSSAI-1"),
    dict(dist_name="MRBTS-10550/NRBTS-10550/TRACKINGAREA-1", list_name="snssaiDNList"),
]

MOs_TO_ADD_CU_8204_C1 = [
    dict(
        class_name="com.nokia.srbts.nrbts:NRPMCCP",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMCCP-1",
        version="NRBTSCU23R1_2220_101",
    ),
    dict(
        class_name="com.nokia.srbts.nrbts:NRPMQAP",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMQAP-1",
        version="NRBTSCU23R1_2220_101",
    ),
    dict(
        class_name="com.nokia.srbts.nrbts:NRPMQAP",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMQAP-2",
        version="NRBTSCU23R1_2220_101",
    ),
]

PARAMS_TO_MODIFY_CU_8204_C1 = [
    dict(value="true", dist_name="MRBTS-10550/NRBTS-10550", p_name="actIpThpt"),
    dict(
        value="true", dist_name="MRBTS-10550/NRBTS-10550", p_name="actNrpmqapProfiles"
    ),
    dict(
        value="15min",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1",
        p_name="miNrF1UInterfaceCUpmqap",
    ),
    dict(
        value="15min",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1",
        p_name="miNrPDCPCell",
    ),
    dict(
        value="15min",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1",
        p_name="miNrPdcpCellNrpmqap",
    ),
    dict(
        value="15min",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1",
        p_name="miNrX2UInterfacepmqap",
    ),
    dict(
        value="15min",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1",
        p_name="miNrX2ccNrpmqap",
    ),
    dict(
        value="Bin ranges based on SCS",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMCCP-1",
        p_name="cfgTAcounters",
    ),
    dict(
        value="1-15",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMQAP-1",
        p_name="cfgArpRange",
    ),
    dict(
        value="NSA",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMQAP-1",
        p_name="cfgProfType",
    ),
    dict(
        value="7,8,9",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMQAP-1",
        p_name="cfgQciRange",
    ),
    dict(
        value="5-7",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMQAP-2",
        p_name="cfg5qiRange",
    ),
    dict(
        value="1-15",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMQAP-2",
        p_name="cfgArpRange",
    ),
    dict(
        value="SA",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMQAP-2",
        p_name="cfgProfType",
    ),
    # NSA parameters
    dict(value="false", dist_name="MRBTS-10550/NRBTS-10550", p_name="actPaging"),
    dict(value="NSA", dist_name="MRBTS-10550/NRBTS-10550", p_name="gNbCuType"),
    dict(
        value="NSA", dist_name="MRBTS-10550/NRBTS-10550/NRCELL-1", p_name="cellDepType"
    ),
    dict(
        value="NSA", dist_name="MRBTS-10550/NRBTS-10550/NRCELL-2", p_name="cellDepType"
    ),
    dict(value="false", dist_name="MRBTS-10550/NRBTS-10550", p_name="actNgcFlexSaMode"),
]


LIST_PARAMS_TO_MODIFY_CU_8204_C1 = [
    dict(
        dist_name="MRBTS-10550/NRBTS-10550/NRDRB-1",
        list_name="nsaDrbParam",
        elements=[
            dict(p_name="dlDataSplitMode", value="dlOverF1UX2U", index=0),
            dict(p_name="ulDataPath", value="ulOverLteNr_PrimaryPathOverNr", index=0),
            dict(p_name="ulDataSplitThreshold", value="b3200", index=0),
        ],
    ),
    dict(
        dist_name="MRBTS-10550/NRBTS-10550/NRDRB-2",
        list_name="nsaDrbParam",
        elements=[
            dict(p_name="dlDataSplitMode", value="dlOverF1UX2U", index=0),
            dict(p_name="ulDataPath", value="ulOverLteNr_PrimaryPathOverNr", index=0),
            dict(p_name="ulDataSplitThreshold", value="b3200", index=0),
        ],
    ),
]


LIST_TO_ADD_CU_8204_C1 = [
    dict(
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMQAP-1",
        list_name="cfgPlmnId",
        elements=dict(mcc="460", mnc="2", mncLength="2"),
    ),
    dict(
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMQAP-2",
        list_name="cfgPlmnId",
        elements=dict(mcc="460", mnc="2", mncLength="2"),
    ),
    dict(
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMQAP-2",
        list_name="cfgSliceId",
        elements=dict(sd="13714341", sst="1"),
    ),
]


# DU

PARAMS_TO_DELETE_DU_8204_C1 = [
    dict(dist_name="MRBTS-10550/NRBTS-10550/NRCELL-1", p_name="trackingAreaDN"),
    dict(dist_name="MRBTS-10550/NRBTS-10550/NRCELL-2", p_name="trackingAreaDN"),
    dict(dist_name="MRBTS-10550/NRBTS-10550/SNSSAI-1", list_name="f1Uplane"),
    dict(dist_name="MRBTS-10550/NRBTS-10550/TRACKINGAREA-1", list_name="snssaiDNList"),
]

MOs_TO_ADD_8204_DU_C1 = [
    dict(
        class_name="com.nokia.srbts.nrbts:NRPMCCP",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMCCP-1",
        version="NRBTSVDU23R1_2220_101",
    ),
    dict(
        class_name="com.nokia.srbts.nrbts:NRPMQAP",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMQAP-1",
        version="NRBTSVDU23R1_2220_101",
    ),
    dict(
        class_name="com.nokia.srbts.nrbts:NRPMQAP",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMQAP-2",
        version="NRBTSVDU23R1_2220_101",
    ),
]

PARAMS_TO_MODIFY_DU_8204_C1 = [
    dict(value="true", dist_name="MRBTS-10550/NRBTS-10550", p_name="actIpThpt"),
    dict(
        value="true", dist_name="MRBTS-10550/NRBTS-10550", p_name="actNrpmqapProfiles"
    ),
    dict(
        value="true",
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-1",
        p_name="actDynUlDataSplitMode",
    ),
    dict(
        value="2",
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-1",
        p_name="consecRlOThreshold",
    ),
    dict(
        value="2",
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-1",
        p_name="consecRlRThreshold",
    ),
    dict(
        value="110",
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-1",
        p_name="rlResumePathLossThreshold",
    ),
    dict(
        value="-30",
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-1",
        p_name="rlResumeSinrThreshold",
    ),
    dict(
        value="true",
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-2",
        p_name="actDynUlDataSplitMode",
    ),
    dict(
        value="2",
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-2",
        p_name="consecRlOThreshold",
    ),
    dict(
        value="2",
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-2",
        p_name="consecRlRThreshold",
    ),
    dict(
        value="110",
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-2",
        p_name="rlResumePathLossThreshold",
    ),
    dict(
        value="-30",
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-2",
        p_name="rlResumeSinrThreshold",
    ),
    dict(
        value="15min",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1",
        p_name="miNrCellUtilization",
    ),
    dict(
        value="15min",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1",
        p_name="miNrHighRlcCell",
    ),
    dict(
        value="15min",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1",
        p_name="miNrHighRlcCellNrpmqap",
    ),
    dict(
        value="Bin ranges based on SCS",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMCCP-1",
        p_name="cfgTAcounters",
    ),
    dict(
        value="1-15",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMQAP-1",
        p_name="cfgArpRange",
    ),
    dict(
        value="NSA",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMQAP-1",
        p_name="cfgProfType",
    ),
    dict(
        value="7,8,9",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMQAP-1",
        p_name="cfgQciRange",
    ),
    dict(
        value="5-7",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMQAP-2",
        p_name="cfg5qiRange",
    ),
    dict(
        value="1-15",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMQAP-2",
        p_name="cfgArpRange",
    ),
    dict(
        value="SA",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMQAP-2",
        p_name="cfgProfType",
    ),
    # NSA parameters
    dict(value="false", dist_name="MRBTS-10550/NRBTS-10550", p_name="actPaging"),
    dict(
        value="disabled",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1",
        p_name="miNrPaging",
    ),
    dict(value="NSA", dist_name="MRBTS-10550/NRBTS-10550", p_name="gNbCuType"),
    dict(
        value="NSA", dist_name="MRBTS-10550/NRBTS-10550/NRCELL-1", p_name="cellDepType"
    ),
    dict(
        value="NSA", dist_name="MRBTS-10550/NRBTS-10550/NRCELL-2", p_name="cellDepType"
    ),
    dict(
        value="false",
        dist_name="MRBTS-10550/NRBTS-10550",
        p_name="actSACallProcessingDU",
    ),
]

LIST_PARAMS_TO_MODIFY_DU_8204_C1 = []

LIST_TO_ADD_8204_DU_C1 = [
    dict(
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMQAP-1",
        list_name="cfgPlmnId",
        elements=dict(mcc="460", mnc="2", mncLength="2"),
    ),
    dict(
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMQAP-2",
        list_name="cfgPlmnId",
        elements=dict(mcc="460", mnc="2", mncLength="2"),
    ),
    dict(
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMQAP-2",
        list_name="cfgSliceId",
        elements=dict(sd="13714341", sst="1"),
    ),
]

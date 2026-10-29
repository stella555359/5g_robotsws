import os

__team__ = "MN 5G RAN I&V 4 Pz HZG SG1"
__email__ = "I_MN_5G_RAN_IV4_LINE_HZG_1@internal.nsn.com"


# modify CB008009 SCF
# CU
PARAMS_TO_DELETE_CU_8009 = []

MOs_TO_ADD_CU_8009 = [
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

PARAMS_TO_MODIFY_CU_8009 = [
    dict(value="true", dist_name="MRBTS-10550/NRBTS-10550", p_name="actIpThpt"),
    dict(value="true", dist_name="MRBTS-10550/NRBTS-10550", p_name="actThpDist"),
    dict(value="enabled", dist_name="MRBTS-10550/NRBTS-10550", p_name="thpTimeCalc"),
    dict(
        value="1000000",
        dist_name="MRBTS-10550/NRBTS-10550",
        p_name="thpHistDownlinkMaxRange",
    ),
    dict(
        value="100",
        dist_name="MRBTS-10550/NRBTS-10550",
        p_name="thpHistDownlinkMinRange",
    ),
    dict(
        value="logarithmic", dist_name="MRBTS-10550/NRBTS-10550", p_name="thpHistScale"
    ),
    dict(
        value="300000",
        dist_name="MRBTS-10550/NRBTS-10550",
        p_name="thpHistUplinkMaxRange",
    ),
    dict(
        value="100", dist_name="MRBTS-10550/NRBTS-10550", p_name="thpHistUplinkMinRange"
    ),
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
        value="1000000",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMQAP-1",
        p_name="thpHistDownlinkMaxRange",
    ),
    dict(
        value="100",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMQAP-1",
        p_name="thpHistDownlinkMinRange",
    ),
    dict(
        value="logarithmic",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMQAP-1",
        p_name="thpHistScale",
    ),
    dict(
        value="300000",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMQAP-1",
        p_name="thpHistUplinkMaxRange",
    ),
    dict(
        value="100",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMQAP-1",
        p_name="thpHistUplinkMinRange",
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
    dict(
        value="1000000",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMQAP-2",
        p_name="thpHistDownlinkMaxRange",
    ),
    dict(
        value="100",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMQAP-2",
        p_name="thpHistDownlinkMinRange",
    ),
    dict(
        value="logarithmic",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMQAP-2",
        p_name="thpHistScale",
    ),
    dict(
        value="300000",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMQAP-2",
        p_name="thpHistUplinkMaxRange",
    ),
    dict(
        value="100",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMQAP-2",
        p_name="thpHistUplinkMinRange",
    ),
    dict(
        value="50",
        dist_name="MRBTS-10550/NRBTS-10550/NRDRB-1",
        p_name="durationThresDiscardDl",
    ),
    dict(
        value="20",
        dist_name="MRBTS-10550/NRBTS-10550/NRDRB-1",
        p_name="durationThresDiscardUl",
    ),
    dict(
        value="50",
        dist_name="MRBTS-10550/NRBTS-10550/NRDRB-2",
        p_name="durationThresDiscardDl",
    ),
    dict(
        value="20",
        dist_name="MRBTS-10550/NRBTS-10550/NRDRB-2",
        p_name="durationThresDiscardUl",
    ),
]


LIST_PARAMS_TO_MODIFY_CU_8009 = []


LIST_TO_ADD_CU_8009 = [
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

PARAMS_TO_DELETE_DU_8009 = []

MOs_TO_ADD_DU_8009 = [
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

PARAMS_TO_MODIFY_DU_8009 = [
    dict(value="true", dist_name="MRBTS-10550/NRBTS-10550", p_name="actIpThpt"),
    dict(value="true", dist_name="MRBTS-10550/NRBTS-10550", p_name="actThpDist"),
    dict(value="enabled", dist_name="MRBTS-10550/NRBTS-10550", p_name="thpTimeCalc"),
    dict(
        value="1000000",
        dist_name="MRBTS-10550/NRBTS-10550",
        p_name="thpHistDownlinkMaxRange",
    ),
    dict(
        value="100",
        dist_name="MRBTS-10550/NRBTS-10550",
        p_name="thpHistDownlinkMinRange",
    ),
    dict(
        value="logarithmic", dist_name="MRBTS-10550/NRBTS-10550", p_name="thpHistScale"
    ),
    dict(
        value="300000",
        dist_name="MRBTS-10550/NRBTS-10550",
        p_name="thpHistUplinkMaxRange",
    ),
    dict(
        value="100", dist_name="MRBTS-10550/NRBTS-10550", p_name="thpHistUplinkMinRange"
    ),
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
        value="1000000",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMQAP-1",
        p_name="thpHistDownlinkMaxRange",
    ),
    dict(
        value="100",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMQAP-1",
        p_name="thpHistDownlinkMinRange",
    ),
    dict(
        value="logarithmic",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMQAP-1",
        p_name="thpHistScale",
    ),
    dict(
        value="300000",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMQAP-1",
        p_name="thpHistUplinkMaxRange",
    ),
    dict(
        value="100",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMQAP-1",
        p_name="thpHistUplinkMinRange",
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
    dict(
        value="1000000",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMQAP-2",
        p_name="thpHistDownlinkMaxRange",
    ),
    dict(
        value="100",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMQAP-2",
        p_name="thpHistDownlinkMinRange",
    ),
    dict(
        value="logarithmic",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMQAP-2",
        p_name="thpHistScale",
    ),
    dict(
        value="300000",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMQAP-2",
        p_name="thpHistUplinkMaxRange",
    ),
    dict(
        value="100",
        dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1/NRPMQAP-2",
        p_name="thpHistUplinkMinRange",
    ),
    dict(
        value="50",
        dist_name="MRBTS-10550/NRBTS-10550/NRDRB-1",
        p_name="durationThresDiscardDl",
    ),
    dict(
        value="20",
        dist_name="MRBTS-10550/NRBTS-10550/NRDRB-1",
        p_name="durationThresDiscardUl",
    ),
    dict(
        value="50",
        dist_name="MRBTS-10550/NRBTS-10550/NRDRB-2",
        p_name="durationThresDiscardDl",
    ),
    dict(
        value="20",
        dist_name="MRBTS-10550/NRBTS-10550/NRDRB-2",
        p_name="durationThresDiscardUl",
    ),
]

LIST_PARAMS_TO_MODIFY_DU_8009 = []

LIST_TO_ADD_DU_8009 = [
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

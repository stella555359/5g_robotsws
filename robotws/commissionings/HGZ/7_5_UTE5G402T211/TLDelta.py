import os

__team__ = "MN 5G RAN I&V 4 Pz HZG SG1"
__email__ = "I_MN_5G_RAN_IV4_LINE_HZG_1@internal.nsn.com"

# GoldenSCF = '/21A/Configuration_5G21A_FDD_Classical_RFSharing_10MHz_three_cells_v5.xml'
GoldenSCF = "/21A/GoldenSCF_6Cell_v24.xml"


CASE_INPUT_5GC002479 = {
    "5GC002479": {
        "StreamPrefix": "5G_",
        "NETACT_URL": "https://shanxilbwas.sui6.srnhz.nsn-rdnet.net",
        "NETACT_USER": "omc",
        "NETACT_PASSWORD": "Nokia126_",
        "NETACT_LOGSERVER_IP": "10.110.144.140",
        "NETACT_LOGSERVER_USERNAME": "root",
        "NETACT_LOGSERVER_PASSWORD": "arthur",
    },
    "5GC002479_AA_01": {
        "Duration_SCFLoad": "20",
        "Duration_ValidationError": "270",
        "Duration_Validation": "140",
        "Duration_Activation": "575",
    },
    "5GC002479_AA_02": {
        "Duration_DeltaValidation": "1000",
    },
    "5GC002479_AA_03": {
        "SCF_backup_duration": "30",
    },
    "5GC002479_AA_04": {
        "Duration_DeltaActivation": "600",
    },
    "5GC002479_AA_05": {
        "Delta_Plan_Provision_Durtion": "110",
    },
    "5GC002479_AA_06": {
        "Full_Plan_Provision_Durtion": "635",
    },
    "5GC002479_AA_07": {
        "Delta_Plan_PreProvision_Durtion": "60",
    },
    "5GC002479_AA_08": {
        "Import_Delta_Plan_Durtion": "20",
    },
    "5GC002479_AA_09": {
        "Delta_Plan_Provision_Durtion_Reboot": "635",
    },
    "5GC002479_AA_10": {
        "CMUplod_Durtion": "30",
    },
    "5GC002479_AA_11": {
        "Duration_ChangeNoti": "17",
    },
    "5GC002479_BA_02": {
        "Duration_PM_Kept": "180",
    },  # should be 86400  24h  / 180 for test
    "5GC002479_BA_03": {
        "PM_MAX_Size": "272.7",
    },
    "5GC002479_BA_04": {
        "CPU_Jitter": "4",
    },
    "5GC002479_CA_01": {
        "alarm_report_time": "60",
    },
    "5GC002479_CA_02": {
        "Alarm_Upload_Durtion": "55",
    },
    "5GC002479_DA_01": {
        "snapshot_save_time": "900",
    },
    "5GC002479_DA_02": {
        "FilePresentTime": "15",
    },
    "5GC002479_DA_03": {
        "StartAndStopLtency": "15",
    },
    "5GC002479_FA_01": {
        "MaxFileSize": "2147483648",
    },
    "5GC002479_FA_02": {
        "MaxSession": "10",
    },
    "5GC002479_FA_03": {
        "Duration_Loading_WebEM": "5",
    },
    "5GC002479_FA_04": {
        "Login_duration_time": "25",
    },
    "5GC002479_FA_05": {
        "StartupView_Login_duration_time": "30",
    },
    "5GC002479_FA_06": {
        "RMToolSessionCount": "5",
    },
    "5GC002479_FA_07": {
        "RMToolRequestLatency": "30",
    },
    "5GC002479_FA_08": {
        "RMToolConnectionLatency": "30",
    },
    "5GC002479_FA_09": {
        "RMToolRequestLatencyServerMode": "5",
    },
    "5GC002479_HA_07": {
        "CellLockUnLockDurtion": "40",
    },
    "5GC002479_IA": {
        "OriginalStream": "5G_0.800",
        "OriginalStreamSCF": "OriginalStreamSCF.xml",  # please fill following on dualcore env
        "SecondaryUTEVMIP": "10.57.155.4",
        "SecondaryTLName": "7_5_CLOUD402T014",
    },
    "5GC002479_IA_01": {
        "SW_Download_MAX": "900",
    },
    "5GC002479_IA_KPI2a": {
        "KPI2a_AVG": "660",
        "KPI2a_MAX": "792",
    },
    "5GC002479_IA_KPI2b": {
        "KPI2b_AVG": "900",
        "KPI2b_MAX": "1080",
    },
    "5GC002479_IA_KPI2c": {
        "KPI2c_AVG": "480",
        "KPI2c_MAX": "576",
    },
    "5GC002479_IA_KPI2d": {
        "KPI2d_AVG": "720",
        "KPI2d_MAX": "888",
    },
    "5GC002479_IA_KPI2e": {
        "KPI2e_AVG": "720",
        "KPI2e_MAX": "888",
    },
    "5GC002479_IA_KPI4": {
        "KPI4_AVG": "1320",
        "KPI4_MAX": "1584",
    },
    "5GC002479_IA_KPI4a": {
        "KPI4a_AVG": "1560",
        "KPI4a_MAX": "1872",
    },
}


TC5GC001817_AA_01 = {
    "ue_number": "1",
    "UE0": {
        "ue_type": "huawei_sigspark",
        "power_reset": "true",
        "ul_throughput": "50MKbits/sec",
        "dl_throughput": "100MKbits/sec",
        "dl_traffic": "50MKbits/sec",
        "ul_traffic": "100MKbits/sec",
        "duration": "300",
        "ue_mode": "SA",
        "APN": "wap1.nokia.com",
        "ue_imsi": "460028001006401",
    },
    "UE1": {
        "ue_type": "huawei_sigspark",
        "power_reset": "true",
        "ul_throughput": "50MKbits/sec",
        "dl_throughput": "100MKbits/sec",
        "dl_traffic": "50MKbits/sec",
        "ul_traffic": "100MKbits/sec",
        "duration": "300",
        "ue_mode": "SA",
        "APN": "wap1.nokia.com",
        "ue_imsi": "460023100007899",
    },
}


# modify Golden to TL1103 SCF
TL_PARAMS_TO_DELETE_1CELL = [
    # SISO Configuration
    dict(dist_name="MRBTS-12345/EQM-1/APEQM-1/RMOD-2"),
    dict(dist_name="MRBTS-12345/EQM-1/APEQM-1/RMOD-3"),
    dict(dist_name="MRBTS-12345/EQM-1/APEQM-1/RMOD-1/ANTL-3"),
    dict(dist_name="MRBTS-12345/EQM-1/APEQM-1/RMOD-1/ANTL-4"),
    dict(dist_name="MRBTS-12345/EQM-1/HWTOP-1/CABLINK-3"),
    dict(dist_name="MRBTS-12345/EQM-1/HWTOP-1/CABLINK-4"),
    dict(dist_name="MRBTS-12345/EQM-1/HWTOP-1/CABLINK-5"),
    dict(dist_name="MRBTS-12345/EQM-1/HWTOP-1/CABLINK-6"),
    dict(dist_name="MRBTS-12345/EQM-1/HWTOP-1/CABLINK-7"),
    dict(dist_name="MRBTS-12345/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2"),
    dict(dist_name="MRBTS-12345/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3"),
    dict(dist_name="MRBTS-12345/EQM-1/SMOD_EXT-1"),
    dict(dist_name="MRBTS-12345/MNL-1/MNLENT-1/SYNC-1/ECPRIMASTER-1"),
    dict(dist_name="MRBTS-12345/NRBTS-1/LTEENB-1"),
    dict(dist_name="MRBTS-12345/EQM-1/APEQM-1/RMOD-1/PHYANT-1"),
    dict(
        dist_name="MRBTS-12345/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5"
    ),
    dict(
        dist_name="MRBTS-12345/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6"
    ),
    dict(
        dist_name="MRBTS-12345/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7"
    ),
    dict(
        dist_name="MRBTS-12345/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8"
    ),
    dict(dist_name="MRBTS-12345/NRBTS-1/NRPLMN-2"),
    dict(dist_name="MRBTS-12345/MNL-1/MNLENT-1/PMMNL-1"),
    dict(dist_name="MRBTS-12345/NRBTS-1/BWP_PROFILE-2"),
    dict(dist_name="MRBTS-12345/NRBTS-1/BWP_PROFILE-21"),
    # Cell Configuration
    dict(dist_name="MRBTS-12345/NRBTS-1/NRCELL-2"),
    dict(dist_name="MRBTS-12345/NRBTS-1/NRCELL-3"),
    dict(dist_name="MRBTS-12345/NRBTS-1/NRCELL-4"),
    dict(dist_name="MRBTS-12345/NRBTS-1/NRCELL-5"),
    dict(dist_name="MRBTS-12345/NRBTS-1/NRCELL-6"),
    dict(dist_name="MRBTS-12345/NRBTS-1/NRCELLGRP-1"),
    dict(dist_name="MRBTS-12345/NRBTS-1/NRCELLGRP-2"),
    dict(dist_name="MRBTS-12345/NRBTS-1/NRCELLGRP-3"),
    dict(dist_name="MRBTS-12345/NRBTS-1/NRCELLGRP-4"),
    dict(dist_name="MRBTS-12345/NRBTS-1/NRCELLGRP-5"),
    dict(dist_name="MRBTS-12345/NRBTS-1/NRCELL-1", list_name="fPdcchMonOccsnPo"),
    dict(dist_name="MRBTS-12345/NRBTS-1/NRCELL-1", list_name="tddFrameStructure"),
    dict(dist_name="MRBTS-12345/NRBTS-1/NRDU-1", list_name="refNrCellGroup"),
    dict(dist_name="MRBTS-12345/NRBTS-1/NRCELL-1", list_name="beamSet"),
    dict(dist_name="MRBTS-12345/NRBTS-1/NRCELL-1", list_name="drxProfile1"),
    dict(dist_name="MRBTS-12345/NRBTS-1/TRACKINGAREA-8201"),
    dict(dist_name="MRBTS-12345/NRBTS-1/NRCELL-2/NRCELL_FDD-1"),
    dict(dist_name="MRBTS-12345/NRBTS-1/NRCELL-3/NRCELL_FDD-1"),
    dict(dist_name="MRBTS-12345/MRBTSDESC-0"),
    dict(dist_name="MRBTS-12345/NRBTS-1/NRCELL-1", p_name="chBw"),
    dict(dist_name="MRBTS-12345/NRBTS-1/NRCELL-1", p_name="nrarfcn"),
    dict(
        dist_name="MRBTS-12345/EQM-1/APEQM-1/RMOD-1", p_name="climateControlProfiling"
    ),
    # TNL Configuration
    dict(dist_name="MRBTS-12345/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1"),
    dict(dist_name="MRBTS-12345/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-2"),
    dict(dist_name="MRBTS-12345/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-3"),
    dict(dist_name="MRBTS-12345/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1/DSCPTOQMAP-1"),
    dict(dist_name="MRBTS-12345/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1/PCP2QMAP-1"),
    dict(dist_name="MRBTS-12345/TNLSVC-1/TNL-1/IPNO-1/IPIF-2"),
    dict(dist_name="MRBTS-12345/TNLSVC-1/TNL-1/IPNO-1/IPIF-3"),
    dict(dist_name="MRBTS-12345/TNLSVC-1/TNL-1/IPNO-1/QOS-1/DSCP2PCPMAP-1"),
    dict(dist_name="MRBTS-12345/TNLSVC-1/TNL-1/IPNO-1/QOS-1/DSCP2QMAP-1"),
    dict(dist_name="MRBTS-12345/TNLSVC-1/TNL-1/IPNO-1/QOS-1/FSTSCH-1"),
    dict(
        dist_name="MRBTS-12345/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1/BRGPRT-1",
        list_name="l2VlanIdList",
    ),
    dict(
        dist_name="MRBTS-12345/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1/BRGPRT-1",
        p_name="portDefaultVlanPriority",
    ),
    dict(
        dist_name="MRBTS-12345/TNLSVC-1/TNL-1/IPNO-1/IPRT-1", list_name="staticRoutes"
    ),
]


TL_ADD_MOS_1CELL = [
    # BTS Configuration
    # BTS Configuration: Tracking Area
    dict(
        class_name="com.nokia.srbts.nrbts:NRPLMN",
        dist_name="MRBTS-12345/NRBTS-1/NRPLMN-1",
        version="EQM20B_2010_001",
    ),
    dict(
        class_name="com.nokia.srbts.nrbts:NRSYSINFO_PROFILE",
        dist_name="MRBTS-12345/NRBTS-1/NRSYSINFO_PROFILE-1",
        version="EQM20B_2010_001",
    ),
    dict(
        class_name="com.nokia.srbts.nrbts:NRIAFIM",
        dist_name="MRBTS-12345/NRBTS-1/NRSYSINFO_PROFILE-1/NRIAFIM-1",
        version="EQM20B_2010_001",
    ),
    dict(
        class_name="com.nokia.srbts.nrbts:NRIRFIM",
        dist_name="MRBTS-12345/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-1",
        version="EQM20B_2010_001",
    ),
    dict(
        class_name="com.nokia.srbts.nrbts:NRLIM",
        dist_name="MRBTS-12345/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-1",
        version="EQM20B_2010_001",
    ),
    # BTS Configuration Slice
    dict(
        class_name="com.nokia.srbts.nrbts:SNSSAI",
        dist_name="MRBTS-12345/NRBTS-1/SNSSAI-1",
        version="EQM20B_2010_001",
    ),
    # BTS Configuration: Tracking Area
    dict(
        class_name="com.nokia.srbts.nrbts:TRACKINGAREA",
        dist_name="MRBTS-12345/NRBTS-1/TRACKINGAREA-210",
        version="EQM20B_2010_001",
    ),
    dict(
        class_name="com.nokia.srbts.nrbts:NRREDRT",
        dist_name="MRBTS-12345/NRBTS-1/NRCELL-1/NRREDRT-1",
        version="EQM20B_2010_001",
    ),
    dict(
        class_name="com.nokia.srbts.tnl:ETHIF",
        dist_name="MRBTS-12345/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-2",
        version="EQM20B_2010_001",
    ),
    # PROFILE
    dict(
        class_name="com.nokia.srbts.nrbts:BWP_PROFILE",
        dist_name="MRBTS-12345/NRBTS-1/BWP_PROFILE-1",
        version="EQM20B_2010_001",
    ),
    dict(
        class_name="com.nokia.srbts.nrbts:PDCCH",
        dist_name="MRBTS-12345/NRBTS-1/BWP_PROFILE-1/PDCCH-1",
        version="EQM20B_2010_001",
    ),
    dict(
        class_name="com.nokia.srbts.nrbts:PDCCH_CONFIG_COMMON",
        dist_name="MRBTS-12345/NRBTS-1/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1",
        version="EQM20B_2010_001",
    ),
    dict(
        class_name="com.nokia.srbts.nrbts:BWP_PROFILE",
        dist_name="MRBTS-12345/NRBTS-1/BWP_PROFILE-2",
        version="EQM20B_2010_001",
    ),
    dict(
        class_name="com.nokia.srbts.nrbts:PDCCH",
        dist_name="MRBTS-12345/NRBTS-1/BWP_PROFILE-2/PDCCH-1",
        version="EQM20B_2010_001",
    ),
    dict(
        class_name="com.nokia.srbts.nrbts:PDCCH_CONFIG_COMMON",
        dist_name="MRBTS-12345/NRBTS-1/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1",
        version="EQM20B_2010_001",
    ),
    dict(
        class_name="com.nokia.srbts.nrbts:PDCCH_CONFIG_DEDICATED",
        dist_name="MRBTS-12345/NRBTS-1/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_DEDICATED-1",
        version="EQM20B_2010_001",
    ),
]
TL_LIST_TO_ADD_1CELL = [
    # NRBTS/NRCELL
    # NRBTS SA ngplane/xnplane
    dict(
        dist_name="MRBTS-12345/NRBTS-1",
        list_name="ngCplane",
        elements=dict(
            ipV4AddressDN1="MRBTS-12345/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1"
        ),
    ),
    dict(
        dist_name="MRBTS-12345/NRBTS-1",
        list_name="ngUplane",
        elements=dict(
            ipV4AddressDN1="MRBTS-12345/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1"
        ),
    ),
    dict(
        dist_name="MRBTS-12345/NRBTS-1",
        list_name="xnCplane",
        elements=dict(
            ipV4AddressDN1="MRBTS-12345/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1"
        ),
    ),
    dict(
        dist_name="MRBTS-12345/NRBTS-1",
        list_name="xnUplane",
        elements=dict(
            ipV4AddressDN1="MRBTS-12345/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1"
        ),
    ),
    # NRCELL SA fpdcch
    dict(
        dist_name="MRBTS-12345/NRBTS-1/NRCELL-1",
        list_name="fPdcchMonOccsnPo",
        elements=["0"],
    ),
    # NRBTS:SA SIBs
    dict(
        dist_name="MRBTS-12345/NRBTS-1/NRSYSINFO_PROFILE-1",
        list_name="sibSchedulingList",
        elements=dict(
            sibBroadcastStatus="broadcasting",
            sibPeriodicity="rf64",
            sibScope="cellSpecific",
            sibType="sibType2",
        ),
    ),
    dict(
        dist_name="MRBTS-12345/NRBTS-1/NRSYSINFO_PROFILE-1",
        list_name="sibSchedulingList",
        elements=dict(
            sibBroadcastStatus="broadcasting",
            sibPeriodicity="rf64",
            sibScope="cellSpecific",
            sibType="sibType3",
        ),
    ),
    dict(
        dist_name="MRBTS-12345/NRBTS-1/NRSYSINFO_PROFILE-1",
        list_name="sibSchedulingList",
        elements=dict(
            sibBroadcastStatus="broadcasting",
            sibPeriodicity="rf64",
            sibScope="cellSpecific",
            sibType="sibType4",
        ),
    ),
    dict(
        dist_name="MRBTS-12345/NRBTS-1/NRSYSINFO_PROFILE-1",
        list_name="sibSchedulingList",
        elements=dict(
            sibBroadcastStatus="broadcasting",
            sibPeriodicity="rf64",
            sibScope="cellSpecific",
            sibType="sibType5",
        ),
    ),
    dict(
        dist_name="MRBTS-12345/NRBTS-1/NRSYSINFO_PROFILE-1",
        list_name="sibSchedulingList",
        elements=dict(
            sibBroadcastStatus="broadcasting",
            sibPeriodicity="rf16",
            sibScope="cellSpecific",
            sibType="sibType6",
        ),
    ),
    dict(
        dist_name="MRBTS-12345/NRBTS-1/NRSYSINFO_PROFILE-1",
        list_name="sibSchedulingList",
        elements=dict(
            sibBroadcastStatus="broadcasting",
            sibPeriodicity="rf16",
            sibScope="cellSpecific",
            sibType="sibType7",
        ),
    ),
    dict(
        dist_name="MRBTS-12345/NRBTS-1/NRSYSINFO_PROFILE-1",
        list_name="sibSchedulingList",
        elements=dict(
            sibBroadcastStatus="broadcasting",
            sibPeriodicity="rf16",
            sibScope="cellSpecific",
            sibType="sibType8",
        ),
    ),
    # NRBTS:SA SNSSAI
    dict(
        dist_name="MRBTS-12345/NRBTS-1/SNSSAI-1",
        list_name="nrPlmnDNList",
        elements=["MRBTS-12345/NRBTS-1/NRPLMN-1"],
    ),
    dict(
        dist_name="MRBTS-12345/NRBTS-1/TRACKINGAREA-210",
        list_name="snssaiDNList",
        elements=["MRBTS-12345/NRBTS-1/SNSSAI-1"],
    ),
    # NRBTS:DU
    dict(
        dist_name="MRBTS-12345/NRBTS-1/NRDU-1",
        list_name="refNrCellGroup",
        elements=["0"],
    ),
    # TNL
    dict(
        dist_name="MRBTS-12345/TNLSVC-1/TNL-1/IPNO-1/IPRT-1",
        list_name="staticRoutes",
        elements=dict(
            destinationIpPrefixLength="0",
            destIpAddr="0.0.0.0",
            gateway="10.68.88.97",
            routeIpMtu="1450",
        ),
    ),
    dict(
        dist_name="MRBTS-12345/NRBTS-1/NRCELL-1",
        list_name="a2MeasReleaseSsbRsrp",
        elements=dict(
            a2HysteresisReleaseSsbRsrp="0",
            a2ThresholdReleaseSsbRsrp="47",
            a2TimeToTriggerReleaseSsbRsrp="ms480",
        ),
    ),
    dict(
        dist_name="MRBTS-12345/NRBTS-1/NRCELL-1",
        list_name="drxProfile1",
        elements=dict(
            drxInactivityTimer="40ms",
            drxLongCycle="40ms",
            drxOnDurationTimer="10ms",
            drxRetransTimerDl="16slot",
            drxRetransTimerUl="16slot",
        ),
    ),
    dict(
        dist_name="MRBTS-12345/NRBTS-1/NRCELL-1",
        list_name="a3MeasSsbRsrp",
        elements=dict(
            a3HysteresisSsbRsrp="7",
            a3OffsetSsbRsrp="-30",
            a3TimeToTriggerSsbRsrp="ms5120",
        ),
    ),
    dict(
        dist_name="MRBTS-12345/NRBTS-1/NRCELL-1",
        list_name="a3MeasSsbRsrq",
        elements=dict(
            a3HysteresisSsbRsrq="8",
            a3OffsetSsbRsrq="2",
            a3TimeToTriggerSsbRsrq="ms5120",
        ),
    ),
    dict(
        dist_name="MRBTS-12345/NRBTS-1/NRCELL-1",
        list_name="a5MeasSsbRsrp",
        elements=dict(
            a5HysteresisSsbRsrp="10",
            a5Threshold1SsbRsrp="70",
            a5Threshold2SsbRsrp="40",
            a5TimeToTriggerSsbRsrp="ms5120",
        ),
    ),
    dict(
        dist_name="MRBTS-12345/NRBTS-1/BWP_PROFILE-1",
        list_name="locationAndBandwidthDl",
        elements=dict(cRbSizeDl="coreset0", cRbStartDl="coreset0"),
    ),
    dict(
        dist_name="MRBTS-12345/NRBTS-1/BWP_PROFILE-1",
        list_name="locationAndBandwidthUl",
        elements=dict(cRbSizeUl="sameAsDl", cRbStartUl="sameAsDl"),
    ),
    dict(
        dist_name="MRBTS-12345/NRBTS-1/BWP_PROFILE-2",
        list_name="locationAndBandwidthDl",
        elements=dict(cRbSizeDl="allRb", cRbStartDl="crb0"),
    ),
    dict(
        dist_name="MRBTS-12345/NRBTS-1/BWP_PROFILE-2",
        list_name="locationAndBandwidthUl",
        elements=dict(cRbSizeUl="sameAsDl", cRbStartUl="sameAsDl"),
    ),
    dict(
        dist_name="MRBTS-12345/NRBTS-1/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1",
        list_name="searchSpaceCommon",
        elements=dict(
            coresetId="0",
            dciFormat="formats0-0-And-1-0",
            duration="1",
            monitoringSymbolWithinSlot="symbol_0",
            numOfPdcchCandidatesInAL16="n1",
            numOfPdcchCandidatesInAL4="n4",
            numOfPdcchCandidatesInAL8="n2",
            numOfPdcchCandidatesInAL2="n0",
            periodicity="sl1",
            searchSpaceId="1",
            searchSpaceType="Type0A",
            slotOffset="0",
        ),
    ),
    dict(
        dist_name="MRBTS-12345/NRBTS-1/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1",
        list_name="searchSpaceCommon",
        elements=dict(
            coresetId="0",
            dciFormat="formats0-0-And-1-0",
            duration="1",
            monitoringSymbolWithinSlot="symbol_0_1",
            numOfPdcchCandidatesInAL16="n0",
            numOfPdcchCandidatesInAL4="n4",
            numOfPdcchCandidatesInAL8="n0",
            numOfPdcchCandidatesInAL2="n0",
            periodicity="sl1",
            searchSpaceId="2",
            searchSpaceType="Type1",
            slotOffset="0",
        ),
    ),
    dict(
        dist_name="MRBTS-12345/NRBTS-1/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1",
        list_name="searchSpaceCommon",
        elements=dict(
            coresetId="0",
            dciFormat="formats0-0-And-1-0",
            duration="1",
            monitoringSymbolWithinSlot="symbol_0",
            numOfPdcchCandidatesInAL16="n1",
            numOfPdcchCandidatesInAL4="n4",
            numOfPdcchCandidatesInAL8="n2",
            numOfPdcchCandidatesInAL2="n0",
            periodicity="sl1",
            searchSpaceId="3",
            searchSpaceType="Type2",
            slotOffset="0",
        ),
    ),
    dict(
        dist_name="MRBTS-12345/NRBTS-1/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1",
        list_name="searchSpaceCommon",
        elements=dict(
            coresetId="0",
            dciFormat="formats0-0-And-1-0",
            duration="1",
            monitoringSymbolWithinSlot="symbol_0",
            numOfPdcchCandidatesInAL16="n1",
            numOfPdcchCandidatesInAL4="n4",
            numOfPdcchCandidatesInAL8="n2",
            numOfPdcchCandidatesInAL2="n0",
            periodicity="sl1",
            searchSpaceId="11",
            searchSpaceType="Type0A",
            slotOffset="0",
        ),
    ),
    dict(
        dist_name="MRBTS-12345/NRBTS-1/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1",
        list_name="searchSpaceCommon",
        elements=dict(
            coresetId="0",
            dciFormat="formats0-0-And-1-0",
            duration="1",
            monitoringSymbolWithinSlot="symbol_0_1",
            numOfPdcchCandidatesInAL16="n0",
            numOfPdcchCandidatesInAL4="n2",
            numOfPdcchCandidatesInAL8="n0",
            numOfPdcchCandidatesInAL2="n0",
            periodicity="sl1",
            searchSpaceId="12",
            searchSpaceType="Type1",
            slotOffset="0",
        ),
    ),
    dict(
        dist_name="MRBTS-12345/NRBTS-1/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1",
        list_name="searchSpaceCommon",
        elements=dict(
            coresetId="0",
            dciFormat="formats0-0-And-1-0",
            duration="1",
            monitoringSymbolWithinSlot="symbol_0",
            numOfPdcchCandidatesInAL16="n1",
            numOfPdcchCandidatesInAL4="n4",
            numOfPdcchCandidatesInAL8="n2",
            numOfPdcchCandidatesInAL2="n0",
            periodicity="sl1",
            searchSpaceId="13",
            searchSpaceType="Type2",
            slotOffset="0",
        ),
    ),
    dict(
        dist_name="MRBTS-12345/NRBTS-1/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_DEDICATED-1",
        list_name="searchSpaceDedicated",
        elements=dict(
            coresetId="0",
            dciFormat="formats0-0-And-1-0",
            duration="1",
            monitoringSymbolWithinSlot="symbol_0_1",
            numOfPdcchCandidatesInAL1="n0",
            numOfPdcchCandidatesInAL16="n0",
            numOfPdcchCandidatesInAL2="n0",
            numOfPdcchCandidatesInAL4="n2",
            numOfPdcchCandidatesInAL8="n0",
            periodicity="sl1",
            searchSpaceId="4",
            searchSpaceType="Type3",
            slotOffset="0",
        ),
    ),
    dict(
        dist_name="MRBTS-12345/NRBTS-1/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_DEDICATED-1",
        list_name="searchSpaceDedicated",
        elements=dict(
            coresetId="0",
            dciFormat="formats0-1-And-1-1",
            duration="1",
            monitoringSymbolWithinSlot="symbol_0_1",
            numOfPdcchCandidatesInAL1="n0",
            numOfPdcchCandidatesInAL16="n0",
            numOfPdcchCandidatesInAL2="n0",
            numOfPdcchCandidatesInAL4="n2",
            numOfPdcchCandidatesInAL8="n0",
            periodicity="sl1",
            searchSpaceId="5",
            searchSpaceType="UE-Specific",
            slotOffset="0",
        ),
    ),
]

TL_PARAMS_TO_MODIFY_1CELL = [
    # TL name
    dict(value="SG1_TL211_FDD", dist_name="MRBTS-12345", p_name="btsName"),
    # SISO Configuration
    # SISO Configuration:SMOD
    dict(
        value="false",
        dist_name="MRBTS-12345/EQM-1/APEQM-1/CABINET-1/SMOD-1",
        p_name="climateControlOcxoTemperatureLearning",
    ),
    dict(
        value="Optimized Cooling",
        dist_name="MRBTS-12345/EQM-1/APEQM-1/CABINET-1/SMOD-1",
        p_name="climateControlProfiling",
    ),
    dict(
        value="473764A.102",
        dist_name="MRBTS-12345/EQM-1/APEQM-1/CABINET-1/SMOD-1",
        p_name="prodCodePlanned",
    ),
    # SISO Configuration:BBMOD-1
    dict(
        value="Unlocked",
        dist_name="MRBTS-12345/EQM-1/APEQM-1/CABINET-1/BBMOD-1",
        p_name="administrativeState",
    ),
    dict(
        value="474020A.102",
        dist_name="MRBTS-12345/EQM-1/APEQM-1/CABINET-1/BBMOD-1",
        p_name="prodCodePlanned",
    ),
    dict(
        value="true",
        dist_name="MRBTS-12345/EQM-1/APEQM-1/CABINET-1/BBMOD-1",
        p_name="useFullCapacity",
    ),
    # SISO Configuration:RMOD-1
    dict(
        value="false",
        dist_name="MRBTS-12345/EQM-1/APEQM-1/RMOD-1",
        p_name="actPimCancellation",
    ),
    dict(
        value="false",
        dist_name="MRBTS-12345/EQM-1/APEQM-1/RMOD-1",
        p_name="actSnapshotCollection",
    ),
    dict(
        value="Unlocked",
        dist_name="MRBTS-12345/EQM-1/APEQM-1/RMOD-1",
        p_name="administrativeState",
    ),
    dict(
        value="Auto", dist_name="MRBTS-12345/EQM-1/APEQM-1/RMOD-1", p_name="linkSpeed"
    ),
    dict(
        value="false",
        dist_name="MRBTS-12345/EQM-1/APEQM-1/RMOD-1",
        p_name="pimCancellingEnabled",
    ),
    dict(
        value="474119A.101",
        dist_name="MRBTS-12345/EQM-1/APEQM-1/RMOD-1",
        p_name="prodCodePlanned",
    ),
    dict(
        value="60", dist_name="MRBTS-12345/EQM-1/APEQM-1/RMOD-1", p_name="ptpSyncRepPrd"
    ),
    # SISO Configuration:CABLINK-1/CABLINK-2
    dict(
        value="MRBTS-12345/EQM-1/APEQM-1/CABINET-1/SMOD-1",
        dist_name="MRBTS-12345/EQM-1/HWTOP-1/CABLINK-1",
        p_name="firstEndpointDN",
    ),
    dict(
        value="BACKPLANE",
        dist_name="MRBTS-12345/EQM-1/HWTOP-1/CABLINK-1",
        p_name="firstEndpointLabel",
    ),
    dict(
        value="1",
        dist_name="MRBTS-12345/EQM-1/HWTOP-1/CABLINK-1",
        p_name="firstEndpointPortId",
    ),
    dict(
        value="false",
        dist_name="MRBTS-12345/EQM-1/HWTOP-1/CABLINK-1",
        p_name="linkModeConfiguration",
    ),
    dict(
        value="false",
        dist_name="MRBTS-12345/EQM-1/HWTOP-1/CABLINK-1",
        p_name="linkModeDC",
    ),
    dict(
        value="false",
        dist_name="MRBTS-12345/EQM-1/HWTOP-1/CABLINK-1",
        p_name="linkModeData",
    ),
    dict(
        value="false",
        dist_name="MRBTS-12345/EQM-1/HWTOP-1/CABLINK-1",
        p_name="linkModeSynchronization",
    ),
    dict(
        value="MRBTS-12345/EQM-1/APEQM-1/CABINET-1/BBMOD-1",
        dist_name="MRBTS-12345/EQM-1/HWTOP-1/CABLINK-1",
        p_name="secondEndpointDN",
    ),
    dict(
        value="BACKPLANE",
        dist_name="MRBTS-12345/EQM-1/HWTOP-1/CABLINK-1",
        p_name="secondEndpointLabel",
    ),
    dict(
        value="MRBTS-12345/EQM-1/APEQM-1/CABINET-1/BBMOD-1",
        dist_name="MRBTS-12345/EQM-1/HWTOP-1/CABLINK-2",
        p_name="firstEndpointDN",
    ),
    dict(
        value="QSFP",
        dist_name="MRBTS-12345/EQM-1/HWTOP-1/CABLINK-2",
        p_name="firstEndpointLabel",
    ),
    dict(
        value="2",
        dist_name="MRBTS-12345/EQM-1/HWTOP-1/CABLINK-2",
        p_name="firstEndpointPortId",
    ),
    dict(
        value="none",
        dist_name="MRBTS-12345/EQM-1/HWTOP-1/CABLINK-2",
        p_name="iqCompression",
    ),
    dict(
        value="Cpri7",
        dist_name="MRBTS-12345/EQM-1/HWTOP-1/CABLINK-2",
        p_name="linkSpeed",
    ),
    dict(
        value="FDDCPRI",
        dist_name="MRBTS-12345/EQM-1/HWTOP-1/CABLINK-2",
        p_name="radioProtocolType",
    ),
    dict(
        value="MRBTS-12345/EQM-1/APEQM-1/RMOD-1",
        dist_name="MRBTS-12345/EQM-1/HWTOP-1/CABLINK-2",
        p_name="secondEndpointDN",
    ),
    dict(
        value="SFP",
        dist_name="MRBTS-12345/EQM-1/HWTOP-1/CABLINK-2",
        p_name="secondEndpointLabel",
    ),
    dict(
        value="1",
        dist_name="MRBTS-12345/EQM-1/HWTOP-1/CABLINK-2",
        p_name="secondEndpointPortId",
    ),
    # SISO Configuration:CHANNEL
    dict(
        value="1",
        dist_name="MRBTS-12345/EQM-1/APEQM-1/RMOD-1/ANTL-1",
        p_name="antPortId",
    ),
    dict(
        value="22",
        dist_name="MRBTS-12345/EQM-1/APEQM-1/RMOD-1/ANTL-1",
        p_name="antennaPathDelayDL",
    ),
    dict(
        value="22",
        dist_name="MRBTS-12345/EQM-1/APEQM-1/RMOD-1/ANTL-1",
        p_name="antennaPathDelayUL",
    ),
    dict(
        value="215",
        dist_name="MRBTS-12345/EQM-1/APEQM-1/RMOD-1/ANTL-1",
        p_name="cwaThreshold",
    ),
    dict(
        value="OFF",
        dist_name="MRBTS-12345/EQM-1/APEQM-1/RMOD-1/ANTL-1",
        p_name="dcVoltage",
    ),
    dict(
        value="false",
        dist_name="MRBTS-12345/EQM-1/APEQM-1/RMOD-1/ANTL-1",
        p_name="hdlcCommunicationAllowed",
    ),
    dict(
        value="30",
        dist_name="MRBTS-12345/EQM-1/APEQM-1/RMOD-1/ANTL-1",
        p_name="totalLoss",
    ),
    dict(
        value="0", dist_name="MRBTS-12345/EQM-1/APEQM-1/RMOD-1/ANTL-1", p_name="ulDelay"
    ),
    dict(
        value="2",
        dist_name="MRBTS-12345/EQM-1/APEQM-1/RMOD-1/ANTL-2",
        p_name="antPortId",
    ),
    dict(
        value="22",
        dist_name="MRBTS-12345/EQM-1/APEQM-1/RMOD-1/ANTL-2",
        p_name="antennaPathDelayDL",
    ),
    dict(
        value="22",
        dist_name="MRBTS-12345/EQM-1/APEQM-1/RMOD-1/ANTL-2",
        p_name="antennaPathDelayUL",
    ),
    dict(
        value="215",
        dist_name="MRBTS-12345/EQM-1/APEQM-1/RMOD-1/ANTL-2",
        p_name="cwaThreshold",
    ),
    dict(
        value="OFF",
        dist_name="MRBTS-12345/EQM-1/APEQM-1/RMOD-1/ANTL-2",
        p_name="dcVoltage",
    ),
    dict(
        value="false",
        dist_name="MRBTS-12345/EQM-1/APEQM-1/RMOD-1/ANTL-2",
        p_name="hdlcCommunicationAllowed",
    ),
    dict(
        value="30",
        dist_name="MRBTS-12345/EQM-1/APEQM-1/RMOD-1/ANTL-2",
        p_name="totalLoss",
    ),
    dict(
        value="0", dist_name="MRBTS-12345/EQM-1/APEQM-1/RMOD-1/ANTL-2", p_name="ulDelay"
    ),
    dict(
        value="TX",
        dist_name="MRBTS-12345/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-1",
        p_name="direction",
    ),
    dict(
        value="MRBTS-12345/EQM-1/APEQM-1/RMOD-1/ANTL-1",
        dist_name="MRBTS-12345/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-1",
        p_name="antlDN",
    ),
    dict(
        value="RX",
        dist_name="MRBTS-12345/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-2",
        p_name="direction",
    ),
    dict(
        value="MRBTS-12345/EQM-1/APEQM-1/RMOD-1/ANTL-1",
        dist_name="MRBTS-12345/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-2",
        p_name="antlDN",
    ),
    dict(
        value="TX",
        dist_name="MRBTS-12345/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-3",
        p_name="direction",
    ),
    dict(
        value="MRBTS-12345/EQM-1/APEQM-1/RMOD-1/ANTL-2",
        dist_name="MRBTS-12345/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-3",
        p_name="antlDN",
    ),
    dict(
        value="RX",
        dist_name="MRBTS-12345/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-4",
        p_name="direction",
    ),
    dict(
        value="MRBTS-12345/EQM-1/APEQM-1/RMOD-1/ANTL-2",
        dist_name="MRBTS-12345/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-4",
        p_name="antlDN",
    ),
    # SISO Configuration:RF sharing disable
    dict(
        value="false",
        dist_name="MRBTS-12345/MNL-1/MNLENT-1/FEATCADM-1",
        p_name="rfSharingEnabled",
    ),
    # SISO Configuration:SYNC
    dict(
        value="GPS only",
        dist_name="MRBTS-12345/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/GNSSE-1",
        p_name="gnssControlMode",
    ),
    # Mplane
    dict(
        value="MRBTS-12345/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1",
        dist_name="MRBTS-12345/MNL-1/MNLENT-1/MPLANENW-1",
        p_name="mPlaneIpv4AddressDN",
    ),
    # NRBTS
    # NRBTS:SA related
    dict(value="true", dist_name="MRBTS-12345/NRBTS-1", p_name="actPaging"),
    dict(value="true", dist_name="MRBTS-12345/NRBTS-1", p_name="actSACallProcessingDU"),
    dict(value="600", dist_name="MRBTS-12345/NRBTS-1", p_name="drbInactivityTimerSA"),
    dict(value="600", dist_name="MRBTS-12345/NRBTS-1", p_name="srbInactivityTimerSA"),
    # NRBTS:CuType
    dict(value="both", dist_name="MRBTS-12345/NRBTS-1", p_name="gNbCuType"),
    # NRBTS:Plmn
    dict(value="460", dist_name="MRBTS-12345/NRBTS-1", p_name="mcc"),
    dict(value="2", dist_name="MRBTS-12345/NRBTS-1", p_name="mnc"),
    # NRBTS:IP
    dict(
        value="10.108.221.70",
        dist_name="MRBTS-12345/NRBTS-1/SERVEDAMF-1",
        p_name="amfIPAddress",
    ),
    # NRBTS:PLMN
    dict(value="460", dist_name="MRBTS-12345/NRBTS-1/NRPLMN-1", p_name="mcc"),
    dict(value="2", dist_name="MRBTS-12345/NRBTS-1/NRPLMN-1", p_name="mnc"),
    dict(value="2", dist_name="MRBTS-12345/NRBTS-1/NRPLMN-1", p_name="mncLength"),
    # NRBTS:SystemInfo
    # NRSYSINFO_PROFILE-1
    dict(
        value="dB-2",
        dist_name="MRBTS-12345/NRBTS-1/NRSYSINFO_PROFILE-1",
        p_name="addHystSfHigh",
    ),
    dict(
        value="dB-2",
        dist_name="MRBTS-12345/NRBTS-1/NRSYSINFO_PROFILE-1",
        p_name="addHystSfMedium",
    ),
    dict(
        value="16",
        dist_name="MRBTS-12345/NRBTS-1/NRSYSINFO_PROFILE-1",
        p_name="nCellChangeHigh",
    ),
    dict(
        value="15",
        dist_name="MRBTS-12345/NRBTS-1/NRSYSINFO_PROFILE-1",
        p_name="nCellChangeMedium",
    ),
    dict(
        value="dB0", dist_name="MRBTS-12345/NRBTS-1/NRSYSINFO_PROFILE-1", p_name="qHyst"
    ),
    dict(
        value="s40",
        dist_name="MRBTS-12345/NRBTS-1/NRSYSINFO_PROFILE-1",
        p_name="siWindowLength",
    ),
    dict(
        value="251",
        dist_name="MRBTS-12345/NRBTS-1/NRSYSINFO_PROFILE-1",
        p_name="systemInformationTargetRate",
    ),
    dict(
        value="s30",
        dist_name="MRBTS-12345/NRBTS-1/NRSYSINFO_PROFILE-1",
        p_name="tEvaluation",
    ),
    dict(
        value="s30",
        dist_name="MRBTS-12345/NRBTS-1/NRSYSINFO_PROFILE-1",
        p_name="tHystNormal",
    ),
    dict(
        value="0",
        dist_name="MRBTS-12345/NRBTS-1/NRSYSINFO_PROFILE-1",
        p_name="tReselectionEutra",
    ),
    dict(
        value="0",
        dist_name="MRBTS-12345/NRBTS-1/NRSYSINFO_PROFILE-1",
        p_name="threshServingLowP",
    ),
    dict(
        value="0",
        dist_name="MRBTS-12345/NRBTS-1/NRSYSINFO_PROFILE-1",
        p_name="threshServingLowQ",
    ),
    # NRSYSINFO_PROFILE-1/NRIAFIM-1
    dict(
        value="false",
        dist_name="MRBTS-12345/NRBTS-1/NRSYSINFO_PROFILE-1/NRIAFIM-1",
        p_name="deriveSsbIndexFromCell",
    ),
    dict(
        value="-56",
        dist_name="MRBTS-12345/NRBTS-1/NRSYSINFO_PROFILE-1/NRIAFIM-1",
        p_name="qRxLevMin",
    ),
    dict(
        value="22",
        dist_name="MRBTS-12345/NRBTS-1/NRSYSINFO_PROFILE-1/NRIAFIM-1",
        p_name="sIntraSearchP",
    ),
    dict(
        value="0",
        dist_name="MRBTS-12345/NRBTS-1/NRSYSINFO_PROFILE-1/NRIAFIM-1",
        p_name="sIntraSearchQ",
    ),
    dict(
        value="1",
        dist_name="MRBTS-12345/NRBTS-1/NRSYSINFO_PROFILE-1/NRIAFIM-1",
        p_name="tReselectionNr",
    ),
    # NRSYSINFO_PROFILE-1/NRIRFIM-1
    dict(
        value="false",
        dist_name="MRBTS-12345/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-1",
        p_name="deriveSsbIndexFromCell",
    ),
    dict(
        value="127180",
        dist_name="MRBTS-12345/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-1",
        p_name="dlCarrierFreq",
    ),
    dict(
        value="28",
        dist_name="MRBTS-12345/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-1",
        p_name="freqBandIndicatorNR",
    ),
    dict(
        value="-4dB",
        dist_name="MRBTS-12345/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-1",
        p_name="qOffsetFreq",
    ),
    dict(
        value="-56",
        dist_name="MRBTS-12345/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-1",
        p_name="qRxLevMin",
    ),
    dict(
        value="15KHz",
        dist_name="MRBTS-12345/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-1",
        p_name="ssbScs",
    ),
    dict(
        value="1",
        dist_name="MRBTS-12345/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-1",
        p_name="tReselectionNr",
    ),
    dict(
        value="30",
        dist_name="MRBTS-12345/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-1",
        p_name="threshXHighP",
    ),
    dict(
        value="1",
        dist_name="MRBTS-12345/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-1",
        p_name="threshXHighQ",
    ),
    dict(
        value="22",
        dist_name="MRBTS-12345/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-1",
        p_name="threshXLowP",
    ),
    dict(
        value="0",
        dist_name="MRBTS-12345/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-1",
        p_name="threshXLowQ",
    ),
    # NRSYSINFO_PROFILE-1/NRLIM-1
    dict(
        value="mbw100",
        dist_name="MRBTS-12345/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-1",
        p_name="allowedMeasBw",
    ),
    dict(
        value="40890",
        dist_name="MRBTS-12345/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-1",
        p_name="carrierFreq",
    ),
    dict(
        value="23",
        dist_name="MRBTS-12345/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-1",
        p_name="pMaxEutra",
    ),
    dict(
        value="false",
        dist_name="MRBTS-12345/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-1",
        p_name="presenceAntPort1",
    ),
    dict(
        value="-34",
        dist_name="MRBTS-12345/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-1",
        p_name="qQualMin",
    ),
    dict(
        value="-22",
        dist_name="MRBTS-12345/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-1",
        p_name="qRxLevMin",
    ),
    dict(
        value="0",
        dist_name="MRBTS-12345/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-1",
        p_name="threshXHigh",
    ),
    dict(
        value="0",
        dist_name="MRBTS-12345/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-1",
        p_name="threshXLow",
    ),
    # NRBTS:SNSSAI
    dict(
        value="Unlocked",
        dist_name="MRBTS-12345/NRBTS-1/SNSSAI-1",
        p_name="administrativeState",
    ),
    dict(value="13714341", dist_name="MRBTS-12345/NRBTS-1/SNSSAI-1", p_name="sd"),
    dict(value="1", dist_name="MRBTS-12345/NRBTS-1/SNSSAI-1", p_name="sst"),
    # NRBTS::TRACKINGAREA
    dict(
        value="210",
        dist_name="MRBTS-12345/NRBTS-1/TRACKINGAREA-210",
        p_name="fiveGsTac",
    ),
    # NRBTS:OtherTL_WantChange
    dict(value="32", dist_name="MRBTS-12345/NRBTS-1", p_name="gNbIdLength"),
    dict(value="15min", dist_name="MRBTS-12345/NRBTS-1/NRPMRNL-1", p_name="miNrPaging"),
    # NRCELL/NRCELLGRP
    # NRCELL1: Cell SA related
    dict(
        value="none",
        dist_name="MRBTS-12345/NRBTS-1/NRCELL-1",
        p_name="a1MeashoEnabledSA",
    ),
    dict(
        value="none",
        dist_name="MRBTS-12345/NRBTS-1/NRCELL-1",
        p_name="a2MeashoEnabledSA",
    ),
    dict(
        value="MRBTS-12345/NRBTS-202/NRSYSINFO_PROFILE-1",
        dist_name="MRBTS-12345/NRBTS-1/NRCELL-1",
        p_name="nrSysInfoProfileDN",
    ),
    dict(
        value="pagingDciAggregation",
        dist_name="MRBTS-12345/NRBTS-1/NRCELL-1",
        p_name="pagingTargetRate",
    ),
    dict(
        value="12",
        dist_name="MRBTS-12345/NRBTS-1/NRCELL-1",
        p_name="prachConfigurationIndex",
    ),
    dict(
        value="sl20",
        dist_name="MRBTS-12345/NRBTS-1/NRCELL-1",
        p_name="raResponseWindow",
    ),
    dict(
        value="0", dist_name="MRBTS-12345/NRBTS-1/NRCELL-1", p_name="sMeasConfigSsbRsrp"
    ),
    dict(
        value="0",
        dist_name="MRBTS-12345/NRBTS-1/NRCELL-1",
        p_name="siChangeIndDuration",
    ),
    dict(
        value="15", dist_name="MRBTS-12345/NRBTS-1/NRCELL-1", p_name="ssPbchBlockPower"
    ),
    dict(value="15KHz", dist_name="MRBTS-12345/NRBTS-1/NRCELL-1", p_name="ssbScs"),
    dict(
        value="MRBTS-12345/NRBTS-202/TRACKINGAREA-210",
        dist_name="MRBTS-12345/NRBTS-1/NRCELL-1",
        p_name="trackingAreaDN",
    ),
    dict(
        value="6",
        dist_name="MRBTS-12345/NRBTS-1/NRCELL-1",
        p_name="type0CoresetConfigurationIndex",
    ),
    dict(
        value="4",
        dist_name="MRBTS-12345/NRBTS-1/NRCELL-1",
        p_name="type0SearchSpaceConfigurationIndex",
    ),
    # NRCELL1: Cell Related
    dict(value="both", dist_name="MRBTS-12345/NRBTS-1/NRCELL-1", p_name="cellDepType"),
    dict(
        value="FDD", dist_name="MRBTS-12345/NRBTS-1/NRCELL-1", p_name="cellTechnology"
    ),
    dict(
        value="2x2 Open Loop Spatial Multiplexing",
        dist_name="MRBTS-12345/NRBTS-1/NRCELL-1",
        p_name="dlMimoMode",
    ),
    dict(
        value="28",
        dist_name="MRBTS-12345/NRBTS-1/NRCELL-1",
        p_name="freqBandIndicatorNR",
    ),
    dict(value="1949", dist_name="MRBTS-12345/NRBTS-1/NRCELL-1", p_name="gscn"),
    dict(value="2DL2UL", dist_name="MRBTS-12345/NRBTS-1/NRCELL-1", p_name="nrCellType"),
    dict(
        value="10MHz",
        dist_name="MRBTS-12345/NRBTS-1/NRCELL-1/NRCELL_FDD-1",
        p_name="chBwDl",
    ),
    dict(
        value="10MHz",
        dist_name="MRBTS-12345/NRBTS-1/NRCELL-1/NRCELL_FDD-1",
        p_name="chBwUl",
    ),
    dict(
        value="156100",
        dist_name="MRBTS-12345/NRBTS-1/NRCELL-1/NRCELL_FDD-1",
        p_name="nrarfcnDl",
    ),
    dict(
        value="145100",
        dist_name="MRBTS-12345/NRBTS-1/NRCELL-1/NRCELL_FDD-1",
        p_name="nrarfcnUl",
    ),
    dict(value="370", dist_name="MRBTS-12345/NRBTS-1/NRCELL-1", p_name="pMax"),
    dict(value="20", dist_name="MRBTS-12345/NRBTS-1/NRCELL-1", p_name="pMaxNROwnCell"),
    dict(value="211", dist_name="MRBTS-12345/NRBTS-1/NRCELL-1", p_name="physCellId"),
    dict(
        value="n0",
        dist_name="MRBTS-12345/NRBTS-1/NRCELL-1",
        p_name="timingAdvanceOffset",
    ),
    dict(
        value="100", dist_name="MRBTS-12345/NRBTS-1/NRCELL-1", p_name="configuredEpsTac"
    ),
    # NRCELL1: Cell GRP
    dict(value="15 KHz", dist_name="MRBTS-12345/NRBTS-1/NRCELLGRP-0", p_name="scs"),
    dict(
        value="20",
        dist_name="MRBTS-12345/NRBTS-1/NRCELLGRP-0",
        p_name="ssBurstSetPeriod",
    ),
    # TNL
    dict(
        value="1048576",
        dist_name="MRBTS-12345/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1/BRGPRT-1",
        p_name="l2BurstSize",
    ),
    dict(
        value="1000000",
        dist_name="MRBTS-12345/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1/BRGPRT-1",
        p_name="l2ShaperRate",
    ),
    # TNL:IP
    dict(
        value="10.68.88.105",
        dist_name="MRBTS-12345/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1",
        p_name="localIpAddr",
    ),
    dict(
        value="27",
        dist_name="MRBTS-12345/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1",
        p_name="localIpPrefixLength",
    ),
    dict(
        value="50",
        dist_name="MRBTS-12345/NRBTS-1",
        p_name="maxPercentageDrbOverF1UOvld",
    ),
    dict(value="680", dist_name="MRBTS-12345/NRBTS-1", p_name="ulsVoipPacketSize"),
    dict(
        value="false",
        dist_name="MRBTS-12345/NRBTS-1/NRCELL-1",
        p_name="actPdschRmCsirsForTracking",
    ),
    dict(
        value="false",
        dist_name="MRBTS-12345/NRBTS-1/NRCELL-1",
        p_name="actPrachMultiplexing",
    ),
    dict(
        value="250",
        dist_name="MRBTS-12345/NRBTS-1/NRCELL-1",
        p_name="maxNumOfCaUsersNRCell",
    ),
    dict(
        value="40",
        dist_name="MRBTS-12345/NRBTS-1/NRDRB-1",
        p_name="maxDddsPeriodCpuOvld",
    ),
    dict(
        value="40",
        dist_name="MRBTS-12345/NRBTS-1/NRDRB-2",
        p_name="maxDddsPeriodCpuOvld",
    ),
    dict(
        value="40",
        dist_name="MRBTS-12345/NRBTS-1/NRDRB-3",
        p_name="maxDddsPeriodCpuOvld",
    ),
    dict(
        value="40",
        dist_name="MRBTS-12345/NRBTS-1/NRDRB-4",
        p_name="maxDddsPeriodCpuOvld",
    ),
    dict(
        value="40",
        dist_name="MRBTS-12345/NRBTS-1/NRDRB-5",
        p_name="maxDddsPeriodCpuOvld",
    ),
    dict(
        value="40",
        dist_name="MRBTS-12345/NRBTS-1/NRDRB-6",
        p_name="maxDddsPeriodCpuOvld",
    ),
    dict(
        value="40",
        dist_name="MRBTS-12345/NRBTS-1/NRDRB-7",
        p_name="maxDddsPeriodCpuOvld",
    ),
    dict(
        value="40",
        dist_name="MRBTS-12345/NRBTS-1/NRDRB-8",
        p_name="maxDddsPeriodCpuOvld",
    ),
    dict(
        value="40",
        dist_name="MRBTS-12345/NRBTS-1/NRDRB-9",
        p_name="maxDddsPeriodCpuOvld",
    ),
    dict(
        value="40",
        dist_name="MRBTS-12345/NRBTS-1/NRDRB-10",
        p_name="maxDddsPeriodCpuOvld",
    ),
    dict(
        value="40",
        dist_name="MRBTS-12345/NRBTS-1/NRDRB-11",
        p_name="maxDddsPeriodCpuOvld",
    ),
    dict(
        value="40",
        dist_name="MRBTS-12345/NRBTS-1/NRDRB-12",
        p_name="maxDddsPeriodCpuOvld",
    ),
    dict(
        value="40",
        dist_name="MRBTS-12345/NRBTS-1/NRDRB-13",
        p_name="maxDddsPeriodCpuOvld",
    ),
    dict(
        value="40",
        dist_name="MRBTS-12345/NRBTS-1/NRDRB-14",
        p_name="maxDddsPeriodCpuOvld",
    ),
    dict(
        value="disabled", dist_name="MRBTS-12345/NRBTS-1/NRPMRNL-1", p_name="miNrPdcch"
    ),
    dict(
        value="-150",
        dist_name="MRBTS-12345/NRBTS-1/NRCELL-1",
        p_name="ullaDeltaSinrMin",
    ),
    dict(
        value="pos3",
        dist_name="MRBTS-12345/NRBTS-1/NRCELL-1",
        p_name="dmrsTypeAPosition",
    ),
    dict(value="3000ms", dist_name="MRBTS-12345/NRBTS-1", p_name="tRLFindForDU"),
    dict(value="true", dist_name="MRBTS-12345/NRBTS-1", p_name="actA2SgnbRelease"),
    dict(
        value="rsrp",
        dist_name="MRBTS-12345/NRBTS-1/NRCELL-1",
        p_name="a2MeasReleaseEnabled",
    ),
    dict(value="true", dist_name="MRBTS-12345/NRBTS-1", p_name="actInactDetNSAUe"),
    dict(value="true", dist_name="MRBTS-12345/NRBTS-1/NRCELL-1", p_name="actCDrx"),
    dict(value="true", dist_name="MRBTS-12345/NRBTS-1", p_name="actNonGbrServiceDiff"),
    dict(value="1", dist_name="MRBTS-12345/NRBTS-1/NRDRB-1", p_name="schedulWeight"),
    dict(value="1", dist_name="MRBTS-12345/NRBTS-1/NRDRB-2", p_name="schedulWeight"),
    dict(value="1", dist_name="MRBTS-12345/NRBTS-1/NRDRB-3", p_name="schedulWeight"),
    dict(value="1", dist_name="MRBTS-12345/NRBTS-1/NRDRB-4", p_name="schedulWeight"),
    dict(value="1", dist_name="MRBTS-12345/NRBTS-1/NRDRB-5", p_name="schedulWeight"),
    dict(value="1", dist_name="MRBTS-12345/NRBTS-1/NRDRB-6", p_name="schedulWeight"),
    dict(value="1", dist_name="MRBTS-12345/NRBTS-1/NRDRB-7", p_name="schedulWeight"),
    dict(value="1", dist_name="MRBTS-12345/NRBTS-1/NRDRB-8", p_name="schedulWeight"),
    dict(value="1", dist_name="MRBTS-12345/NRBTS-1/NRDRB-9", p_name="schedulWeight"),
    dict(value="true", dist_name="MRBTS-12345/NRBTS-1", p_name="actRedirect"),
    dict(value="true", dist_name="MRBTS-12345/NRBTS-1", p_name="actNormVCFallback"),
    dict(
        value="redirection",
        dist_name="MRBTS-12345/NRBTS-1/NRCELL-1",
        p_name="voiceFBMode",
    ),
    dict(value="true", dist_name="MRBTS-12345/NRBTS-1", p_name="actIntraFreqHoSA"),
    dict(
        value="15min",
        dist_name="MRBTS-12345/NRBTS-1/NRPMRNL-1",
        p_name="miNrRelReportCu",
    ),
    dict(
        value="true",
        dist_name="MRBTS-12345/NRBTS-1",
        p_name="actIntraFreqInterGnbMobilityNSA3x",
    ),
    dict(
        value="true",
        dist_name="MRBTS-12345/NRBTS-1",
        p_name="actIntraFreqIntraGnbMobilityNSA",
    ),
    dict(value="true", dist_name="MRBTS-12345/NRBTS-1", p_name="actIntraMeNBMobility"),
    dict(
        value="2300",
        dist_name="MRBTS-12345/NRBTS-1/NRCELL-1/NRREDRT-1",
        p_name="redirFreqEutra",
    ),
    dict(
        value="1",
        dist_name="MRBTS-12345/NRBTS-1/NRCELL-1/NRREDRT-1",
        p_name="redirPrio",
    ),
    dict(
        value="eutra",
        dist_name="MRBTS-12345/NRBTS-1/NRCELL-1/NRREDRT-1",
        p_name="redirRat",
    ),
    dict(
        value="MRBTS-12345/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1",
        dist_name="MRBTS-12345/TNLSVC-1/TNL-1/IPNO-1/IPIF-1",
        p_name="interfaceDN",
    ),
    dict(
        value="rsrp", dist_name="MRBTS-12345/NRBTS-1/NRCELL-1", p_name="a3MeasEnabled"
    ),
    dict(
        value="0",
        dist_name="MRBTS-12345/NRBTS-1/NRCELL-1",
        p_name="absThreshSsbRsrqConsolidation",
    ),
    dict(
        value="0",
        dist_name="MRBTS-12345/NRBTS-1/NRCELL-1",
        p_name="absThreshSsbRsrpConsolidation",
    ),
    dict(
        value="false",
        dist_name="MRBTS-12345/NRBTS-1",
        p_name="actInterFreqInterGnbMobilityNSA",
    ),
    dict(
        value="false",
        dist_name="MRBTS-12345/MNL-1/MNLENT-1/SYNC-1/CLOCK-1",
        p_name="holdOverModeUsed",
    ),
    dict(
        value="MRBTS-12345/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1/BRGPRT-1",
        dist_name="MRBTS-12345/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-2",
        p_name="linkSelectorDN",
    ),
    dict(
        value="false",
        dist_name="MRBTS-12345/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-2",
        p_name="txPriorityTagging",
    ),
    dict(
        value="initial", dist_name="MRBTS-12345/NRBTS-1/BWP_PROFILE-1", p_name="bwpType"
    ),
    dict(
        value="dedicated",
        dist_name="MRBTS-12345/NRBTS-1/BWP_PROFILE-2",
        p_name="bwpType",
    ),
    dict(
        value="static",
        dist_name="MRBTS-12345/NRBTS-1/BWP_PROFILE-1/PDCCH-1",
        p_name="alSelection",
    ),
    dict(
        value="AL4",
        dist_name="MRBTS-12345/NRBTS-1/BWP_PROFILE-1/PDCCH-1",
        p_name="dciDedicatedAggregationLevel",
    ),
    dict(
        value="AL4",
        dist_name="MRBTS-12345/NRBTS-1/BWP_PROFILE-1/PDCCH-1",
        p_name="dciPagingAggregationLevel",
    ),
    dict(
        value="AL4",
        dist_name="MRBTS-12345/NRBTS-1/BWP_PROFILE-1/PDCCH-1",
        p_name="dciRaCompletionAggregationLevel",
    ),
    dict(
        value="AL4",
        dist_name="MRBTS-12345/NRBTS-1/BWP_PROFILE-1/PDCCH-1",
        p_name="dciRaMsg2AggregationLevel",
    ),
    dict(
        value="AL4",
        dist_name="MRBTS-12345/NRBTS-1/BWP_PROFILE-1/PDCCH-1",
        p_name="dciSiAggregationLevel",
    ),
    dict(
        value="allowed",
        dist_name="MRBTS-12345/NRBTS-1/BWP_PROFILE-1/PDCCH-1",
        p_name="downgradeAL16toAL8",
    ),
    dict(
        value="static",
        dist_name="MRBTS-12345/NRBTS-1/BWP_PROFILE-2/PDCCH-1",
        p_name="alSelection",
    ),
    dict(
        value="AL4",
        dist_name="MRBTS-12345/NRBTS-1/BWP_PROFILE-2/PDCCH-1",
        p_name="dciDedicatedAggregationLevel",
    ),
    dict(
        value="AL4",
        dist_name="MRBTS-12345/NRBTS-1/BWP_PROFILE-2/PDCCH-1",
        p_name="dciPagingAggregationLevel",
    ),
    dict(
        value="AL4",
        dist_name="MRBTS-12345/NRBTS-1/BWP_PROFILE-2/PDCCH-1",
        p_name="dciRaCompletionAggregationLevel",
    ),
    dict(
        value="AL4",
        dist_name="MRBTS-12345/NRBTS-1/BWP_PROFILE-2/PDCCH-1",
        p_name="dciRaMsg2AggregationLevel",
    ),
    dict(
        value="AL4",
        dist_name="MRBTS-12345/NRBTS-1/BWP_PROFILE-2/PDCCH-1",
        p_name="dciSiAggregationLevel",
    ),
    dict(
        value="allowed",
        dist_name="MRBTS-12345/NRBTS-1/BWP_PROFILE-2/PDCCH-1",
        p_name="downgradeAL16toAL8",
    ),
    dict(value="true", dist_name="MRBTS-12345/NRBTS-1", p_name="actFdmScheduling"),
]

TL_LIST_PARAMS_TO_MODIFY_1CELL = [
    dict(
        dist_name="MRBTS-12345/NRBTS-1",
        list_name="x2Cplane",
        elements=[
            dict(
                p_name="ipV4AddressDN1",
                value="MRBTS-12345/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1",
                index=0,
            )
        ],
    ),
    dict(
        dist_name="MRBTS-12345/MNL-1/MNLENT-1/SYNC-1/CLOCK-1",
        list_name="syncInputList",
        elements=[
            dict(p_name="syncInputType", value="1pps/ToD from Sync Hub Master", index=0)
        ],
    ),
    dict(
        dist_name="MRBTS-12345/NRBTS-1/NRCELL-1",
        list_name="cellBwpList",
        elements=[
            dict(p_name="bwpDN", value="MRBTS-12345/NRBTS-1/BWP_PROFILE-1", index=0)
        ],
    ),
    dict(
        dist_name="MRBTS-12345/NRBTS-1/NRCELL-1",
        list_name="cellBwpList",
        elements=[
            dict(p_name="bwpDN", value="MRBTS-12345/NRBTS-1/BWP_PROFILE-2", index=1)
        ],
    ),
    dict(
        dist_name="MRBTS-12345/NRBTS-1/NRSYSINFO_PROFILE-1",
        list_name="sibSchedulingList",
        elements=[dict(p_name="sibPeriodicity", value="rf64", index=0)],
    ),
    dict(
        dist_name="MRBTS-12345/NRBTS-1/NRSYSINFO_PROFILE-1",
        list_name="sibSchedulingList",
        elements=[dict(p_name="sibPeriodicity", value="rf64", index=1)],
    ),
    dict(
        dist_name="MRBTS-12345/NRBTS-1/NRSYSINFO_PROFILE-1",
        list_name="sibSchedulingList",
        elements=[dict(p_name="sibPeriodicity", value="rf64", index=2)],
    ),
    dict(
        dist_name="MRBTS-12345/NRBTS-1/NRSYSINFO_PROFILE-1",
        list_name="sibSchedulingList",
        elements=[dict(p_name="sibPeriodicity", value="rf64", index=3)],
    ),
    dict(
        dist_name="MRBTS-12345/NRBTS-1/NRSYSINFO_PROFILE-1",
        list_name="sibSchedulingList",
        elements=[dict(p_name="sibPeriodicity", value="rf16", index=4)],
    ),
    dict(
        dist_name="MRBTS-12345/NRBTS-1/NRCELL-1",
        list_name="ulPowerControlCommon",
        elements=[dict(p_name="p0NominalPucch", value="-80", index=0)],
    ),
    dict(
        dist_name="MRBTS-12345/NRBTS-1/NRCELL-1",
        list_name="ulPowerControlCommon",
        elements=[dict(p_name="p0NominalPucchF1F3", value="-108", index=0)],
    ),
    dict(
        dist_name="MRBTS-12345/NRBTS-1/NRCELL-1",
        list_name="ulPowerControlCommon",
        elements=[dict(p_name="p0NominalPusch", value="-74", index=0)],
    ),
    dict(
        dist_name="MRBTS-12345/NRBTS-1/NRCELL-1",
        list_name="ulPowerControlCommon",
        elements=[dict(p_name="p0NominalSrs", value="-80", index=0)],
    ),
    dict(
        dist_name="MRBTS-12345/NRBTS-1/NRCELL-1",
        list_name="ulPowerControlCommon",
        elements=[dict(p_name="pucchF1DeltaF", value="-10", index=0)],
    ),
]

# modify Golden to TL1103 SCF

TL_LIST_PARAMS_TO_MODIFY_2CELL = []
TL_LIST_PARAMS_TO_MODIFY_3CELL = []

TL_ADD_MOS_1CELL = []
TL_ADD_MOS_3CELL = []

TL_LIST_TO_ADD_1CELL = []
TL_LIST_TO_ADD_3CELL = []

TL_PARAMS_TO_DELETE_1CELL = []
TL_PARAMS_TO_DELETE_3CELL = []

TL_PARAMS_TO_MODIFY_1CELL = []
TL_PARAMS_TO_MODIFY_3CELL = []

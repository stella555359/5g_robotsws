*** Settings ***
Documentation
...           Description :  Test Cases for 5G Counters Downlink PDSCH
...           AUTHOR (I&V):  Yvan Maurin       yvan.maurin@nokia.com
...                       :  Youssef Leulmi    youssef.leulmi@nokia.com
...         Last update : 28.06.2023    Y. Maurin
...
...         TL req :
...         gNB Classical 1 x ASIK, 1 x ABIL, 1 RU cmW (AEQA)
...         UE Qualcomm
...         5G Real
...         CN Real


Variables         ../../../../resources/ST/python/custom.py
Resource          ../Resources/robot/5GCounters_SA_Uplink_Channel_Multiplexing_ON_1_Ue_PUSCH_FDM_resource_7827.robot

#Force Tags      CA_RAN_PZ_NPS    QCD_MN_RAN    QCP_RAN_ST   SBTS00   SBTS22R4    SBTS22R3

Suite Setup          5GCounters_Suite_Setup        gnb_id=${index_gnb}
Suite Teardown       5GCounters_Suite_Teardown     gnb_id=${index_gnb}


*** Variables ***
${ue_capability}=        REAL_ANDROID_UE
${dl_time_s}=            3000s
${dl_throughput}=        600M
${index_gnb}=            0
${index_ue}=             0

*** Test Case ***
[1][1.0] Counters_5G_1001_M55301C01000_PDSCH_RANK2_64TBL_MCS_00
    [Setup]    Get Scout Bts Name
    [Teardown]    Run Keywords    Set Scout Confid Id     Share Scout Config Id
	5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C01000   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1002_M55301C01001_PDSCH_RANK2_64TBL_MCS_01
	Set Tags      ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C01001   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1003_M55301C01002_PDSCH_RANK2_64TBL_MCS_02
    Set Tags      ${shared_config_id}
	5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C01002   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1004_M55301C01003_PDSCH_RANK2_64TBL_MCS_03
    Set Tags      ${shared_config_id}
	5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C01003   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1005_M55301C01004_PDSCH_RANK2_64TBL_MCS_04
    Set Tags      ${shared_config_id}
	5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C01004   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1006_M55301C01005_PDSCH_RANK2_64TBL_MCS_05
    Set Tags      ${shared_config_id}
	5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C01005   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1007_M55301C01006_PDSCH_RANK2_64TBL_MCS_06
    Set Tags      ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C01006   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1008_M55301C01007_PDSCH_RANK2_64TBL_MCS_07
    Set Tags      ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C01007   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1009_M55301C01008_PDSCH_RANK2_64TBL_MCS_08
    Set Tags      ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C01008   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1010_M55301C01009_PDSCH_RANK2_64TBL_MCS_09
    Set Tags      ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C01009   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1011_M55301C01010_PDSCH_RANK2_64TBL_MCS_10
    Set Tags      ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C01010   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1012_M55301C01011_PDSCH_RANK2_64TBL_MCS_11
    Set Tags      ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C01011   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1013_M55301C01012_PDSCH_RANK2_64TBL_MCS_12
    Set Tags      ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C01012   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1014_M55301C01013_PDSCH_RANK2_64TBL_MCS_13
    Set Tags      ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C01013   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1015_M55301C01014_PDSCH_RANK2_64TBL_MCS_14
    Set Tags      ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C01014   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1016_M55301C01015_PDSCH_RANK2_64TBL_MCS_15
    Set Tags      ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C01015   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1017_M55301C01016_PDSCH_RANK2_64TBL_MCS_16
    Set Tags      ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C01016   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1018_M55301C01017_PDSCH_RANK2_64TBL_MCS_17
    Set Tags      ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C01017   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1019_M55301C01018_PDSCH_RANK2_64TBL_MCS_18
    Set Tags      ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C01018   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1020_M55301C01019_PDSCH_RANK2_64TBL_MCS_19
    Set Tags      ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C01019   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1021_M55301C01020_PDSCH_RANK2_64TBL_MCS_20
    Set Tags      ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C01020   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1022_M55301C01021_PDSCH_RANK2_64TBL_MCS_21
    Set Tags      ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C01021   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1023_M55301C01022_PDSCH_RANK2_64TBL_MCS_22
    Set Tags      ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C01022   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1024_M55301C01023_PDSCH_RANK2_64TBL_MCS_23
    Set Tags      ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C01023   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1025_M55301C01024_PDSCH_RANK2_64TBL_MCS_24
    Set Tags      ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C01024   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1026_M55301C01025_PDSCH_RANK2_64TBL_MCS_25
    Set Tags      ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C01025   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1027_M55301C01026_PDSCH_RANK2_64TBL_MCS_26
    Set Tags      ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C01026   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1028_M55301C01027_PDSCH_RANK2_64TBL_MCS_27
    Set Tags      ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C01027   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1029_M55301C01028_PDSCH_RANK2_64TBL_MCS_28
    Set Tags      ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C01028   gnb_id=${index_gnb}    ue_id=${index_ue}   min_value=100000

[1][1.0] Counters_5G_1030_M55301C01029_PDSCH_RANK2_64TBL_MCS_29
    Set Tags      ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C01029   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1031_M55301C01030_PDSCH_RANK2_64TBL_MCS_30
    Set Tags      ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C01030   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1032_M55301C01031_PDSCH_RANK2_64TBL_MCS_31
    Set Tags      ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C01031   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1101_M55301C16000_PDSCH_RANK2_256TBL_MCS_00
    [Setup]    Get Scout Bts Name
    [Teardown]    Run Keywords    Set Scout Confid Id     Share Scout Config Id
	5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C16000   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1102_M55301C16001_PDSCH_RANK2_256TBL_MCS_01
	Set Tags      ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C16001   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1103_M55301C16002_PDSCH_RANK2_256TBL_MCS_02
    Set Tags      ${shared_config_id}
	5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C16002   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1104_M55301C16003_PDSCH_RANK2_256TBL_MCS_03
    Set Tags      ${shared_config_id}
	5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C16003   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1105_M55301C16004_PDSCH_RANK2_256TBL_MCS_04
    Set Tags      ${shared_config_id}
	5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C16004   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1106_M55301C16005_PDSCH_RANK2_256TBL_MCS_05
    Set Tags      ${shared_config_id}
	5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C16005   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1107_M55301C16006_PDSCH_RANK2_256TBL_MCS_06
    Set Tags      ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C16006   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1108_M55301C16007_PDSCH_RANK2_256TBL_MCS_07
    Set Tags      ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C16007   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1109_M55301C16008_PDSCH_RANK2_256TBL_MCS_08
    Set Tags      ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C16008   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1110_M55301C16009_PDSCH_RANK2_256TBL_MCS_09
    Set Tags      ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C16009   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1111_M55301C16010_PDSCH_RANK2_256TBL_MCS_10
    Set Tags      ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C16010   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1112_M55301C16011_PDSCH_RANK2_256TBL_MCS_11
    Set Tags      ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C16011   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1113_M55301C16012_PDSCH_RANK2_256TBL_MCS_12
    Set Tags      ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C16012   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1114_M55301C16013_PDSCH_RANK2_256TBL_MCS_13
    Set Tags      ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C16013   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1115_M55301C16014_PDSCH_RANK2_256TBL_MCS_14
    Set Tags      ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C16014   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1116_M55301C16015_PDSCH_RANK2_256TBL_MCS_15
    Set Tags      ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C16015   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1117_M55301C16016_PDSCH_RANK2_256TBL_MCS_16
    Set Tags      ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C16016   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1118_M55301C16017_PDSCH_RANK2_256TBL_MCS_17
    Set Tags      ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C16017   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1119_M55301C16018_PDSCH_RANK2_256TBL_MCS_18
    Set Tags      ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C16018   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1120_M55301C16019_PDSCH_RANK2_256TBL_MCS_19
    Set Tags      ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C16019   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1121_M55301C16020_PDSCH_RANK2_256TBL_MCS_20
    Set Tags      ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C16020   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1122_M55301C16021_PDSCH_RANK2_256TBL_MCS_21
    Set Tags      ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C16021   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1123_M55301C16022_PDSCH_RANK2_256TBL_MCS_22
    Set Tags      ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C16022   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1124_M55301C16023_PDSCH_RANK2_256TBL_MCS_23
    Set Tags      ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C16023   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1125_M55301C16024_PDSCH_RANK2_256TBL_MCS_24
    Set Tags      ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C16024   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1126_M55301C16025_PDSCH_RANK2_256TBL_MCS_25
    Set Tags      ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C16025   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1127_M55301C16026_PDSCH_RANK2_256TBL_MCS_26
    Set Tags      ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C16026   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1128_M55301C16027_PDSCH_RANK2_256TBL_MCS_27
    Set Tags      ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C16027   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1129_M55301C16028_PDSCH_RANK2_256TBL_MCS_28
    Set Tags      ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C16028   gnb_id=${index_gnb}    ue_id=${index_ue}   min_value=100000

[1][1.0] Counters_5G_1130_M55301C16029_PDSCH_RANK2_256TBL_MCS_29
    Set Tags      ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C16029   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1131_M55301C16030_PDSCH_RANK2_256TBL_MCS_30
    Set Tags      ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C16030   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1132_M55301C16031_PDSCH_RANK2_256TBL_MCS_31
    Set Tags      ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C16031   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1033_M55308C10001_PRB_USED_PDSCH
    Set Tags      ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55308C10001   gnb_id=${index_gnb}    ue_id=${index_ue}  min_value=0

[1][1.0] Counters_5G_1034_M55308C00005_DATA_SLOT_PDSCH
    Set Tags      ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55308C00005   gnb_id=${index_gnb}    ue_id=${index_ue}  min_value=0

[1][1.0] Counters_5G_1035_M55308C00015_SSB_SLOT_PDSCH
    Set Tags      ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55308C00015   gnb_id=${index_gnb}    ue_id=${index_ue}  min_value=0

[1][1.0] Counters_5G_1036_M55308C00016_SSB_SLOT_PDSCH_TIME
    Set Tags      ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55308C00016   gnb_id=${index_gnb}    ue_id=${index_ue}  min_value=0

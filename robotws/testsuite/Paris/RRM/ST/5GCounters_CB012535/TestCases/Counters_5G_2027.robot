*** Settings ***
Documentation
...           Description :  Test Cases for 5G Counters CB012535
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

Suite Setup          5GCounters_Suite_Setup_youssef        gnb_id=${index_gnb}   direction=DL
Suite Teardown       5GCounters_Suite_Teardown     gnb_id=${index_gnb}


*** Variables ***
${ue_capability}=        REAL_ANDROID_UE
${dl_time_s}=            3000s
${ul_throughput}=        200M
${index_gnb}=            0
${index_ue}=             0
${M55308C00133}=         0

*** Test Case ***
[1][1.0] Counters_5G_1041_M55301C17000_PDSCH_RANK3_256TBL_MCS_00
    [Setup]    Get Scout Bts Name
    [Teardown]    Run Keywords    Set Scout Confid Id    Share Scout Config Id
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C17000   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1042_M55301C17001_PDSCH_RANK3_256TBL_MCS_01
    Set Tags    ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C17001   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1043_M55301C17002_PDSCH_RANK3_256TBL_MCS_02
    Set Tags    ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C17002   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1044_M55301C17003_PDSCH_RANK3_256TBL_MCS_03
    Set Tags    ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C17003   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1045_M55301C17004_PDSCH_RANK3_256TBL_MCS_04
    Set Tags    ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C17004   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1046_M55301C17005_PDSCH_RANK3_256TBL_MCS_05
    Set Tags    ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C17005   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1047_M55301C17006_PDSCH_RANK3_256TBL_MCS_06
    Set Tags    ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C17006   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1048_M55301C17007_PDSCH_RANK3_256TBL_MCS_07
    Set Tags    ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C17007   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1049_M55301C17008_PDSCH_RANK3_256TBL_MCS_08
    Set Tags    ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C17008   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1050_M55301C17009_PDSCH_RANK3_256TBL_MCS_09
    Set Tags    ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C17009   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1051_M55301C17010_PDSCH_RANK3_256TBL_MCS_10
    Set Tags    ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C17010   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1052_M55301C17011_PDSCH_RANK3_256TBL_MCS_11
    Set Tags    ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C17011   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1053_M55301C17012_PDSCH_RANK3_256TBL_MCS_12
    Set Tags    ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C17012   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1054_M55301C17013_PDSCH_RANK3_256TBL_MCS_13
    Set Tags    ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C17013   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1055_M55301C17014_PDSCH_RANK3_256TBL_MCS_14
    Set Tags    ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C17014   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1056_M55301C17015_PDSCH_RANK3_256TBL_MCS_15
    Set Tags    ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C17015   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1057_M55301C17016_PDSCH_RANK3_256TBL_MCS_16
    Set Tags    ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C17016   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1058_M55301C17017_PDSCH_RANK3_256TBL_MCS_17
    Set Tags    ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C17017   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1059_M55301C17018_PDSCH_RANK3_256TBL_MCS_18
    Set Tags    ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C17018   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1060_M55301C17019_PDSCH_RANK3_256TBL_MCS_19
    Set Tags    ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C17019   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1061_M55301C17020_PDSCH_RANK3_256TBL_MCS_20
    Set Tags    ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C17020   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1062_M55301C17021_PDSCH_RANK3_256TBL_MCS_21
    Set Tags    ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C17021   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1063_M55301C17022_PDSCH_RANK3_256TBL_MCS_22
    Set Tags    ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C17022   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1064_M55301C17023_PDSCH_RANK3_256TBL_MCS_23
    Set Tags    ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C17023   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1065_M55301C17024_PDSCH_RANK3_256TBL_MCS_24
    Set Tags    ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C17024   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1066_M55301C17025_PDSCH_RANK3_256TBL_MCS_25
    Set Tags    ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C17025   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1067_M55301C17026_PDSCH_RANK3_256TBL_MCS_26
    Set Tags    ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C17026   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1068_M55301C17027_PDSCH_RANK3_256TBL_MCS_27
    Set Tags    ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C17027   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1069_M55301C17028_PDSCH_RANK3_256TBL_MCS_28
    Set Tags    ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C17028   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1070_M55301C17029_PDSCH_RANK3_256TBL_MCS_29
    Set Tags    ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C17029   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1071_M55301C17030_PDSCH_RANK3_256TBL_MCS_30
    Set Tags    ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C17030   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1072_M55301C17031_PDSCH_RANK3_256TBL_MCS_31
    Set Tags    ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55301C17031   gnb_id=${index_gnb}    ue_id=${index_ue}

[1][1.0] Counters_5G_1033_M55308C10001_PRB_USED_PDSCH
    Set Tags    ${shared_config_id}
    5GCounters_TC_Check_PI_vs_l1l2   counter=M55308C10001   gnb_id=${index_gnb}    ue_id=${index_ue}  min_value=0

#test_youssef_UL
    # on appel ce testcase avec     direction=UL dans le setup
   # ${l1}    Create List   M55303C05    1    26
   # ${l2}    Create List   M55308C00    123    129
   # ${l3}    Create List   M55308C00    133    139

  #  @{tmp_list}=    Create List    ${l1}  ${l2}  ${l3}
  #  FOR    ${list}    IN    @{tmp_list}
#    ${counter}=    Set Variable    ${list}[0]
#    ${from}=    Set Variable    ${list}[1]
#    ${to}=    Set Variable    ${list}[2]
#    FOR  ${i}  IN RANGE    ${from}   ${to}
#        ${i}=    Evaluate    '${i}'.zfill(3)
#        ${l1l2_name}=    Catenate    SEPARATOR=    ${counter}    ${i}
#        Run Keyword And Warn On Failure    5GCounters_TC_Check_PI_vs_l1l2   counter=${l1l2_name}   gnb_id=${index_gnb}    ue_id=${index_ue}
#        Log To Console    ${l1l2_name}
#    END
#    END

#    Run Keyword And Warn On Failure    5GCounters_TC_Check_PI_vs_l1l2   counter=M55308C10002   gnb_id=${index_gnb}    ue_id=${index_ue}
#    ...    min_value=10000000
#    Run Keyword And Warn On Failure    5GCounters_TC_Check_PI_vs_l1l2   counter=M55308C00006   gnb_id=${index_gnb}    ue_id=${index_ue}
#    Run Keyword And Warn On Failure    5GCounters_TC_Check_PI_vs_l1l2   counter=M55303C06001   gnb_id=${index_gnb}    ue_id=${index_ue}

*** Settings ***
Force Tags      CLOUD_5G_I_LN_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_SC_TDD    5G_RAN     SBTS00     SBTS23R1    CONFIGURED

Resource         ./CB008379_Resource.robot

Suite Setup         Run keywords     Suite setup from scratch
...                 AND     Perform SCF Delta Commissioning with Delta_Configuration_1CC_TDD_GBR_MultiUE_with_8379_1_4.json
...            AND     sleep    400
...                 AND     Reboot gNB System Module from Console and check Airscale is ready
...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file}

Suite Teardown      Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}

Documentation
...
...      author:            Kiran Vilas Gawade, kiran.vilas_gawade@nokia.com
...      maintainer:        Kiran Vilas Gawade, kiran.vilas_gawade@nokia.com
...
...      INTRODUCTION:    Use case of the Test case is to verify Accessability,Retainability counter for 3GPP
...                       and user defined nonVonrGBR 5QI updated successfully in gnb.
...      TEST SET NAME:  [1]CB008379-B_4_SA_Accessability_counters_Total_QoS_Flow_Identifiers_ID Setup_at_Profile_Level
...                The purpose of this test is to verify the number of Total DRB attempts for SA call
...                at Profile level and Total number of SA initial DRBs sucessful Setup at Profile level
...                [2]CB008379-B_5_SA_Retainability_counters_Total_Number_of_qfi_Released_for_SA_call_Profile_Level
...                The purpose of this test is to verify measure the Total number of qosFlowIdentifiers
...                attempted to be released at profile level
...                [3]CB008379-B_6_SA_Retainability_counters_Number_of_qfi_Released_for_SA_call_wth_Normal_Profile_Level
...                The purpose of this test is to verify counter for measuring the number of qosFlowIdentifiers
...                that are Released for a SA call with Normal cause
...             TESTING SPLIT:    See CB008379 testplan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008379 CFAM
...             Requirement ID:   5G_PM_36,5G_PM_261,5G_PM_262,5G_PM_196,5G_PM_40,5G_PM_43,5G_PM_274

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_1CC_max_gfbr_30_tdd_um_mode.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
${st_ue_id}      ${1}
${en_ue_id}      ${2}
# GFBR and MFBR profile <qos flow id>_gfbr_<dir>=speed
&{gfbr_mfbr_profile}                6_gfbr_ul=10   6_gfbr_dl=20    6_mfbr_ul=40     6_mfbr_dl=50
...                                 7_gfbr_ul=10   7_gfbr_dl=20    7_mfbr_ul=40     7_mfbr_dl=50
...                                 3_gfbr_ul=10   3_gfbr_dl=20    3_mfbr_ul=40     3_mfbr_dl=50
#Make sure VONR Traffic profile should in kbps for 5QI1 and 5QI 5 i.e QFI 2 and 3
@{QOS_Prof1}               1      2       3                    4             #5QI 2
@{QOS_Prof1_speed_dl}      1      32      amr_wb_18_25         30
@{QOS_Prof1_speed_ul}      1      32      amr_wb_18_25         30
@{QOS_Prof1_unit}          mbps   kbps    rtp_codec            mbps

@{QOS_Prof2}               1       5            #5QI 3
@{QOS_Prof2_speed_dl}      1       30
@{QOS_Prof2_speed_ul}      1       30
@{QOS_Prof2_unit}          mbps     mbps

@{QOS_Prof3}               1        6            #5QI 4
@{QOS_Prof3_speed_dl}      1        30
@{QOS_Prof3_speed_ul}      1        30
@{QOS_Prof3_unit}          mbps     mbps

@{QOS_Prof4}               1        7            #5QI 71
@{QOS_Prof4_speed_dl}      1        30
@{QOS_Prof4_speed_ul}      1        30
@{QOS_Prof4_unit}          mbps     mbps

@{QOS_Prof5}               1        8            #5QI 72
@{QOS_Prof5_speed_dl}      1        30
@{QOS_Prof5_speed_ul}      1        30
@{QOS_Prof5_unit}          mbps     mbps

@{QOS_Prof6}               1        9            #5QI 76
@{QOS_Prof6_speed_dl}      1        30
@{QOS_Prof6_speed_ul}      1        30
@{QOS_Prof6_unit}          mbps     mbps

@{QOS_Prof7}               1        10            #5QI 128
@{QOS_Prof7_speed_dl}      1        30
@{QOS_Prof7_speed_ul}      1        30
@{QOS_Prof7_unit}          mbps     mbps

@{QOS_Prof8}               1        11            #5QI 129
@{QOS_Prof8_speed_dl}      1        30
@{QOS_Prof8_speed_ul}      1        30
@{QOS_Prof8_unit}          mbps     mbps

@{QOS_Prof9}               1        12           #5QI 130
@{QOS_Prof9_speed_dl}      1        30
@{QOS_Prof9_speed_ul}      1        30
@{QOS_Prof9_unit}          mbps     mbps

@{QOS_Prof10}               1        13            #5QI 132
@{QOS_Prof10_speed_dl}      1        30
@{QOS_Prof10_speed_ul}      1        30
@{QOS_Prof10_unit}          mbps     mbps

@{QOS_Prof11}               1        14           #5QI 200
@{QOS_Prof11_speed_dl}      1        30
@{QOS_Prof11_speed_ul}      1        30
@{QOS_Prof11_unit}          mbps     mbps

@{QOS_Prof12}               1        15            #5QI 201
@{QOS_Prof12_speed_dl}      1        30
@{QOS_Prof12_speed_ul}      1        30
@{QOS_Prof12_unit}          mbps     mbps

*** Test Cases ***

[1]CB008379-5G-B_5_SA_Retainability_counters_Total_Number_of_qosFlowIdentifiers_Released_for_SA_call_Profile_Level_Counter

    set test variable      ${LOG_PATH}
    Increase Buffer Size for VM and IPHY
    log to console   UE attach trigerring now...
    Wait until the next Measurement Period starts  additional_time=${0}

    ${qos_profile}               Create Dictionary   ${1}=${QOS_Prof5}              ${2}=${QOS_Prof11}
    ${qos_profile_speed_ul}      Create Dictionary   ${1}=${QOS_Prof5_speed_ul}     ${2}=${QOS_Prof11_speed_ul}
    ${qos_profile_speed_dl}      Create Dictionary   ${1}=${QOS_Prof5_speed_dl}     ${2}=${QOS_Prof11_speed_dl}
    ${qos_profile_unit}          Create Dictionary   ${1}=${QOS_Prof5_unit}         ${2}=${QOS_Prof11_unit}
#Step 1. Attach NGBR+GBR UEs, with PDU session 5QI-6 nonGBR qosflow which is default QOS
    ${ue_to_bearer_list}=      MultiUE Register should be Successful with Fetch Bearer ID     ${st_ue_id}    ${en_ue_id}
    ...        pdu_id=1    nw_id=1

#Step 2. Attach GBR UEs, with PDU session 5QI-X GBR qosflow
    Create Modify PDU session   ${st_ue_id}    ${en_ue_id}    ${qos_profile}   pdu_id=1
    ...     gfbr_mfbr_profile=${gfbr_mfbr_profile}                       ue_to_bearer_list=${ue_to_bearer_list[1]}
    ${duration}      Set Variable    20
    ${trf_id}      Set Variable    ${1}
#Step 3. Running traffic on GBR UE for verification
    Start Data Transfer     ${st_ue_id}     ${en_ue_id}     ${duration}    both   ${trf_id}   ${qos_profile_unit}
    ...      ${qos_profile_speed_ul}     ${qos_profile_speed_dl}    ${qos_profile}
    sleep   ${duration}s
    ${gbr_tp_read}=     Verify data transfer and get tp      ${st_ue_id}     ${en_ue_id}     ${duration}
    ...   both   ${trf_id}   ${qos_profile_unit}   ${qos_profile_speed_ul}     ${qos_profile_speed_dl}    ${qos_profile}
    log to console     GBR Throughput ${gbr_tp_read}

    MultiUE PDU Release should be Successful   ${st_ue_id}    ${en_ue_id}
    MultiUE Deregister should be Successful   ${st_ue_id}    ${en_ue_id}
    sleep       300s
    Wait until the current Measurement Period stops  additional_time=${0}
#Counter collection and verification
    CB008379_Resource.Collect PM Counters
    Get Retainability counters and validate    M55163C00002     M55163C00001    M55163C00003     M55163C00004
    ...     ${qos_profile}         NRCELL=NRCELL-1
    Get Throughput counters and validate    M55352C01001    M55352C00001    M55353C00001    M55353C01001
    ...      M55161C00001     M55161C00002     ${qos_profile}        NRCELL=NRCELL-1

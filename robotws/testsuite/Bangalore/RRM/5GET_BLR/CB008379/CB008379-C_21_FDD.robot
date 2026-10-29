*** Settings ***
Force Tags      CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_FDD
...             CRT    RAN_5G_FDD    RAN_5G    5G_RAN_FDD    5G_SC_FDD    5G_RAN     SBTS00    SBTS23R1    CONFIGURED

Resource         ./CB008379_Resource.robot

Suite Setup         Run keywords     Suite setup from scratch
...                 AND     Perform SCF Delta Commissioning with Delta_Configuration_1CC_FDD_GBR_MultiUE_with_8379_Short_PUCCH.json
...            AND     sleep    400
...                 AND     Reboot gNB System Module from Console and check Airscale is ready
...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file}

Suite Teardown      Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}

Documentation
...
...             author:            Kiran Vilas Gawade, kiran.vilas_gawade@nokia.com
...             maintainer:        Kiran Vilas Gawade, kiran.vilas_gawade@nokia.com
...
...             INTRODUCTION:     The purpose of this test is to verify UE with a 5QI-3 GBR bearer should receive
...                               scheduling priority over non-GBR data transmissions over short PUCCH.
...             TEST SET NAME:    CB008379-C_21_Single_GBR_UE_with_5QI_3_Over_Short_PUCCH_with_Multiple_non_GBR-Ues_FDD
...                               Test case is to verify the data Transfer rate of nonVonrGBR 5QI-3 UE with 20mbps tp
...                               without packet drop when nonGBR UEs have occupied the total bandwidth on Classical gNB
...             TESTING SPLIT:     See CB008200 testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB008200 CFAM
...             Requirement ID:    5G_RAN_USR_RRM_14716,5G_RAN_USR_RRM_14806

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_1CC_max_gfbr_30_fdd_um_mode.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
${st_ue_id}         ${1}                   # Total UE ngbr+gbr
${en_ue_id}         ${5}

# GFBR and MFBR profile <qos flow id>_gfbr_<dir>=speed
&{gfbr_mfbr_profile}                6_gfbr_ul=10   6_gfbr_dl=20    6_mfbr_ul=40     6_mfbr_dl=50
...                                 7_gfbr_ul=10   7_gfbr_dl=20    7_mfbr_ul=40     7_mfbr_dl=50
...                                 3_gfbr_ul=10   3_gfbr_dl=20    3_mfbr_ul=40     3_mfbr_dl=50
#Make sure VONR Traffic profile should in kbps for 5QI1 and 5QI 5 i.e QFI 2 and 3
@{QOS_Prof1}               1
@{QOS_Prof1_speed_ul}      15
@{QOS_Prof1_speed_dl}      47
@{QOS_Prof1_unit}          mbps

@{QOS_Prof2}               1         5        #5QI3
@{QOS_Prof2_speed_ul}      1         20
@{QOS_Prof2_speed_dl}      10        20
@{QOS_Prof2_unit}          mbps     mbps

*** Test Cases ***
[1]CB008379-5G-C_21_Single_GBR_UE_with_5QI_3_Over_Short_PUCCH_with_Multiple_non_GBR-Ues_FDD

    set test variable      ${LOG_PATH}
    Increase Buffer Size for VM and IPHY
    log to console   UE attach trigerring now...
    Wait until the next Measurement Period starts  additional_time=${0}
    ${qos_profile}            Create Dictionary   ${1}=${QOS_Prof1}   ${2}=${QOS_Prof1}   ${3}=${QOS_Prof1}
    ...      ${4}=${QOS_Prof1}   ${5}=${QOS_Prof2}
    ${qos_profile_speed_ul}      Create Dictionary   ${1}=${QOS_Prof1_speed_ul}    ${2}=${QOS_Prof1_speed_ul}
    ...    ${3}=${QOS_Prof1_speed_ul}     ${4}=${QOS_Prof1_speed_ul}   ${5}=${QOS_Prof2_speed_ul}
    ${qos_profile_speed_dl}      Create Dictionary   ${1}=${QOS_Prof1_speed_dl}    ${2}=${QOS_Prof1_speed_dl}
    ...    ${3}=${QOS_Prof1_speed_dl}     ${4}=${QOS_Prof1_speed_dl}   ${5}=${QOS_Prof2_speed_dl}
    ${qos_profile_unit}       Create Dictionary   ${1}=${QOS_Prof1_unit}    ${2}=${QOS_Prof1_unit}
    ...    ${3}=${QOS_Prof1_unit}    ${4}=${QOS_Prof1_unit}   ${5}=${QOS_Prof2_unit}
    ${total_ue}=   Get Dictionary Keys   ${qos_profile}
    ${ngbr_ue}=   Get Slice From List   ${total_ue}      0        -1      #Change as per GBR UE count


#Step 1. Attach NGBR+GBR UEs, with PDU session 5QI-6 nonGBR qosflow which is default QOS
    ${ue_to_bearer_list}=      MultiUE Register should be Successful with Fetch Bearer ID     ${st_ue_id}    ${en_ue_id}
    ...   pdu_id=1    nw_id=1
#Step 2. Attach GBR UEs, with PDU session 5QI-3 GBR qosflow
    Create Modify PDU session   ${st_ue_id}    ${en_ue_id}    ${qos_profile}   pdu_id=1
    ...    gfbr_mfbr_profile=${gfbr_mfbr_profile}                     ue_to_bearer_list=${ue_to_bearer_list[1]}

    ${duration}      Set Variable    20
    ${trf_id}        Set Variable    ${1}

    Start Data Transfer     ${ngbr_ue}[0]     ${ngbr_ue}[-1]     ${duration}    both   ${trf_id}   ${qos_profile_unit}
    ...     ${qos_profile_speed_ul}    ${qos_profile_speed_dl}    ${qos_profile}

    Start and Stop TTI TRACE
    sleep   ${duration}s

     ${nongbr_tp_read}=     Verify data transfer and get tp gbr_nongbr      ${ngbr_ue}[0]     ${ngbr_ue}[-1]
    ...     ${duration}    both   ${trf_id}   ${qos_profile_unit}  ${qos_profile_speed_ul}
    ...     ${qos_profile_speed_dl}    ${qos_profile}       gbr_chk=1
    log to console     NGBR Throughput ${nongbr_tp_read}
    Collect TTI Trace   NGBR_Trace

    ${trf_id}      Set Variable    ${2}
    Reset Bearer Stats     ${st_ue_id}    ${en_ue_id}

#Step 3. Running traffic on NGBR+GBR UE for verification
    Start Data Transfer     ${st_ue_id}     ${en_ue_id}     ${duration}    both   ${trf_id}   ${qos_profile_unit}
    ...     ${qos_profile_speed_ul}      ${qos_profile_speed_dl}    ${qos_profile}

    Start and Stop TTI TRACE
    sleep   ${duration}s

    ${gbr_nongbr_tp_read}=     Verify data transfer and get tp gbr_nongbr      ${st_ue_id}     ${en_ue_id}
    ...     ${duration}    both   ${trf_id}   ${qos_profile_unit}  ${qos_profile_speed_ul}     ${qos_profile_speed_dl}
    ...     ${qos_profile}       gbr_chk=1
    log to console     NGBR+GBR Throughput ${gbr_nongbr_tp_read}
    Collect TTI Trace   NGBR_GBR_Trace

    utility.compare_tp  ${wts_cfg_file}     ${st_ue_id}     ${nongbr_tp_read}      ${gbr_nongbr_tp_read}
    ...    ${qos_profile}    ${qos_profile_speed_ul}    ${qos_profile_speed_dl}      ${vonr_codec_rate}
    ...      ${qos_profile_unit}      dirct=both

    MultiUE PDU Release should be Successful   ${st_ue_id}    ${en_ue_id}
    MultiUE Deregister should be Successful   ${st_ue_id}    ${en_ue_id}












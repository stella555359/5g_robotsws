*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO
...             CRT    RAN_5G_FDD    RAN_5G    5G_RAN_FDD    5G_SC_FDD    5G_RAN     SBTS00    SBTS23R1    CONFIGURED

Resource         ./CB008379_Resource.robot
Resource         ../resources/robot/common_log_collection.robot

Suite Setup         Run keywords     Suite setup from scratch
...            AND     Reboot gNB System Module from Console and check Airscale is ready
...            AND     Start Default Logging    output_dirpath=${LOG_PATH}
...            AND     Perform SCF Delta Commissioning with Delta_Configuration_1CC_FDD_GBR_MultiUE_with_8379_20MHz_TMO.json
...            AND     Start WTS Using WTS_Runner      ${wts_cfg_file}

Suite Teardown      Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}

Test Teardown        Link SCOUT SCF to Configuration ID for Reporting

Documentation
...
...             author:            Dheeraj Neravati, neravati.dheeraj_nehru@nokia.com
...             maintainer:        Dheeraj Neravati, neravati.dheeraj_nehru@nokia.com
...
...             INTRODUCTION:     Use case of the Test case is to verify the data Transfer rate with Max GFBR
...                               of 30mbps consistently for nonVonrGBR 5QI-132
...             TEST SET NAME:    [1]CB008379-B_16_Verify_Max_UL_throughput_for_5QI-132_FDD
...                                  Use case of the Test case is to verify the data Transfer rate in uplink direaction
...                                  with Max GFBR of 30mbps consistently for with 30 minutes with nonVonrGBR 5QI-132
...                               [2]CB008379-B_19_Verify_Max_DL_throughput_for_5QI-132_FDD
...                                  Use case of the Test case is to verify the data Transfer rate in downlink direction
...                                  with Max GFBR of 30mbps consistently for with 30 minutes with nonVonrGBR 5QI-132
...             TESTING SPLIT:     See CB008379 testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB008379 CFAM
...             Requirement ID:    5G_RAN_USR_RRM_14713,5G_RAN_USR_RRM_14714,5G_RAN_USR_RRM_14762,5G_RAN_USR_RRM_14763,
...                                5G_RAN_USR_RRM_14765,5G_CP_OTH_7909
...
...             author:            Vaibhav Tyagi, vaibhav.3.tyagi@nokia.com
...             maintainer:        Vaibhav Tyagi, vaibhav.3.tyagi@nokia.com
...
...             INTRODUCTION:     The purpose of this test is to verify UE with a 5QI-128 GBR bearer should receive
...                               scheduling priority over 5QI-129 configured as non-GBR data transmissions.
...             TEST SET NAME:    CB008379-5G-C_3_Single_GBR_UE_with_5QI_128_Multiple_UE_with_non_GBR_5QI_129_FDD.
...                               The purpose of this test is to verify UE with a 5QI-128 GBR bearer should receive
...                               scheduling priority over 5QI-129 configured as non-GBR data transmissions.
...             TESTING SPLIT:    See CB008379 testplan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008379 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_14716,5G_RAN_USR_RRM_14714

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts/basic_TMO.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/

${st_ue_id}      ${51}
${en_ue_id}      ${51}

${st_ue_id_c3}      ${51}
${en_ue_id_c3}      ${54}

@{cell_id}           51    57

# GFBR and MFBR profile <qos flow id>_gfbr_<dir>=speed
&{gfbr_mfbr_profile}                6_gfbr_ul=10   6_gfbr_dl=20    6_mfbr_ul=40     6_mfbr_dl=50
...                                 7_gfbr_ul=10   7_gfbr_dl=20    7_mfbr_ul=40     7_mfbr_dl=50
...                                 3_gfbr_ul=10   3_gfbr_dl=20    3_mfbr_ul=40     3_mfbr_dl=50
#Make sure VONR Traffic profile should in kbps for 5QI1 and 5QI 5 i.e QFI 2 and 3
@{QOS_Prof1}               1        13               # 5QI 132
@{QOS_Prof1_speed_ul}      10       30
@{QOS_Prof1_speed_dl}      10       30
@{QOS_Prof1_unit}          mbps    mbps

@{QOS_Prof2}                1           17
@{QOS_Prof2_speed_ul}       1           20
@{QOS_Prof2_speed_dl}       1           20
@{QOS_Prof2_unit}           kbps        mbps


@{QOS_Prof7}               1        5          6                10
@{QOS_Prof7_speed_ul}      20       32         amr_wb_18_25     10
@{QOS_Prof7_speed_dl}      20       32         amr_wb_18_25     10
@{QOS_Prof7_unit}          mbps    kbps        rtp_codec        mbps

*** Test Cases ***
[1]CB008379-5G-B_16_Verify_Max_UL_throughput_for_5QI-132_FDD
    [tags]	    TC01
    set test variable      ${LOG_PATH}
    Increase Buffer Size for VM and IPHY
    log to console   UE attach trigerring now...
    Wait until the next Measurement Period starts  additional_time=${0}
    ${qos_profile}               Create Dictionary   ${51}=${QOS_Prof1}
    ${qos_profile_speed_ul}      Create Dictionary   ${51}=${QOS_Prof1_speed_ul}
    ${qos_profile_speed_dl}      Create Dictionary   ${51}=${QOS_Prof1_speed_dl}
    ${qos_profile_unit}          Create Dictionary   ${51}=${QOS_Prof1_unit}
#Step 1. Attach NGBR+GBR UEs, with PDU session 5QI-6 nonGBR qosflow which is default QOS
    ${ue_to_bearer_list}=       MultiUE Register should be Successful with Fetch Bearer ID     ${st_ue_id}
    ...     ${en_ue_id}    pdu_id=1    nw_id=1
#Step 2. Attach GBR UEs, with PDU session 5QI-X GBR qosflow
    Create Modify PDU session   ${st_ue_id}    ${en_ue_id}    ${qos_profile}   pdu_id=1
    ...       gfbr_mfbr_profile=${gfbr_mfbr_profile}          ue_to_bearer_list=${ue_to_bearer_list[1]}
    ${duration}      Set Variable    100
    ${trf_id}      Set Variable    ${1}
    Start Data Transfer     ${st_ue_id}     ${en_ue_id}     ${duration}    ul   ${trf_id}   ${qos_profile_unit}
    ...     ${qos_profile_speed_ul}      ${qos_profile_speed_dl}    ${qos_profile}
    Start and Stop TTI TRACE    cell_ids=@{cell_id}
    sleep   ${duration}s
    ${new_path}     Collect TTI Trace   GBR_Trace

    ${gbr_tp_read}=     Verify data transfer and get tp      ${st_ue_id}     ${en_ue_id}     ${duration}    ul
    ...     ${trf_id}   ${qos_profile_unit}  ${qos_profile_speed_ul}      ${qos_profile_speed_dl}    ${qos_profile}
    log to console     GBR Throughput ${gbr_tp_read}
    ${tti_tp_ul}    tti_trace_utility.get_tp_frm_tti    ${ue_to_bearer_list[0]}     ${ue_to_bearer_list[1]}
    ...    ul       ${new_path}/output_ul_formated.csv
    ${status}=      tti_trace_utility.verify_tp_from_tti    ${ue_to_bearer_list[1]}   ${tti_tp_ul}
    ...     ${qos_profile_speed_ul}      ${qos_profile_unit}     ${vonr_codec_rate}  ${0}   ${0}
    Should Contain     ${status}    Pass

    MultiUE PDU Release should be Successful   ${st_ue_id}    ${en_ue_id}
    MultiUE Deregister should be Successful   ${st_ue_id}    ${en_ue_id}

[1]CB008379-5G-B_19_Verify_Max_DL_throughput_for_5QI-132_FDD
    [tags]	    TC02
    set test variable      ${LOG_PATH}
    Increase Buffer Size for VM and IPHY
    log to console   UE attach trigerring now...
    Wait until the next Measurement Period starts  additional_time=${0}
    ${qos_profile}               Create Dictionary   ${51}=${QOS_Prof1}
    ${qos_profile_speed_ul}      Create Dictionary   ${51}=${QOS_Prof1_speed_ul}
    ${qos_profile_speed_dl}      Create Dictionary   ${51}=${QOS_Prof1_speed_dl}
    ${qos_profile_unit}          Create Dictionary   ${51}=${QOS_Prof1_unit}
#Step 1. Attach NGBR+GBR UEs, with PDU session 5QI-6 nonGBR qosflow which is default QOS
    ${ue_to_bearer_list}=       MultiUE Register should be Successful with Fetch Bearer ID     ${st_ue_id}
    ...     ${en_ue_id}    pdu_id=1    nw_id=1
#Step 2. Attach GBR UEs, with PDU session 5QI-X GBR qosflow
    Create Modify PDU session   ${st_ue_id}    ${en_ue_id}    ${qos_profile}   pdu_id=1
    ...           gfbr_mfbr_profile=${gfbr_mfbr_profile}         ue_to_bearer_list=${ue_to_bearer_list[1]}
    ${duration}      Set Variable    100
    ${trf_id}      Set Variable    ${1}
    Start Data Transfer     ${st_ue_id}     ${en_ue_id}     ${duration}    dl   ${trf_id}   ${qos_profile_unit}
    ...     ${qos_profile_speed_ul}     ${qos_profile_speed_dl}    ${qos_profile}
    Start and Stop TTI TRACE    cell_ids=@{cell_id}
    sleep   ${duration}s
    ${new_path}     Collect TTI Trace   GBR_Trace

    ${gbr_tp_read}=     Verify data transfer and get tp      ${st_ue_id}     ${en_ue_id}     ${duration}    dl
    ...     ${trf_id}   ${qos_profile_unit}  ${qos_profile_speed_ul}      ${qos_profile_speed_dl}    ${qos_profile}
    log to console     GBR Throughput ${gbr_tp_read}
    ${tti_tp_dl}    tti_trace_utility.get_tp_frm_tti    ${ue_to_bearer_list[0]}     ${ue_to_bearer_list[1]}
    ...    dl       ${new_path}/output_dl_formated.csv
    ${status}=      tti_trace_utility.verify_tp_from_tti    ${ue_to_bearer_list[1]}   ${tti_tp_dl}
    ...     ${qos_profile_speed_dl}       ${qos_profile_unit}     ${vonr_codec_rate}  ${0}   ${0}
    Should Contain     ${status}    Pass
    MultiUE PDU Release should be Successful   ${st_ue_id}    ${en_ue_id}
    MultiUE Deregister should be Successful   ${st_ue_id}    ${en_ue_id}

[1]CB008379-5G-C_3_Single_GBR_UE_with_5QI_128_Multiple_UE_with_non_GBR_5QI_129_FDD
    [tags]	    TC03
    set test variable      ${LOG_PATH}
    Increase Buffer Size for VM and IPHY
    log to console   UE attach trigerring now...
    ${qos_profile}               Create Dictionary   ${51}=${QOS_Prof7}              ${52}=${QOS_Prof7}
    ...     ${53}=${QOS_Prof2}    ${54}=${QOS_Prof2}
    ${qos_profile_speed_ul}      Create Dictionary   ${51}=${QOS_Prof7_speed_ul}     ${52}=${QOS_Prof7_speed_ul}
    ...     ${53}=${QOS_Prof2_speed_ul}     ${54}=${QOS_Prof2_speed_ul}
    ${qos_profile_speed_dl}      Create Dictionary   ${51}=${QOS_Prof7_speed_dl}     ${52}=${QOS_Prof7_speed_dl}
    ...     ${53}=${QOS_Prof2_speed_dl}     ${54}=${QOS_Prof2_speed_dl}
    ${qos_profile_unit}          Create Dictionary   ${51}=${QOS_Prof7_unit}         ${52}=${QOS_Prof7_unit}
    ...     ${53}=${QOS_Prof2_unit}            ${54}=${QOS_Prof2_unit}

#Step 1. Attach 1 UE with profile GFBR profile 30mbps with 5QI128 and 129

    ${ue_to_bearer_list}=       MultiUE Register should be Successful with Fetch Bearer ID     ${st_ue_id_c3}    ${en_ue_id_c3}
    ...    pdu_id=1    nw_id=1
    Create Modify PDU session New   ${st_ue_id_c3}     ${en_ue_id_c3}    ${qos_profile}   pdu_id=1    gfbr_mfbr_profile=${gfbr_mfbr_profile}
    ...    ue_to_bearer_list=${ue_to_bearer_list[1]}
    ${duration}      Set Variable    300
    ${trf_id}      Set Variable    ${1}
# For UL and DL data transfer a List tp will return in a list other wise a single dict will come direction both means ul and DL
# Make sure that Non GBR call is fully occupying the network bandwidth then only  utility.compare_tp will work
    Start Data Transfer     ${st_ue_id_c3}     ${en_ue_id_c3}     ${duration}    both   ${trf_id}   ${qos_profile_unit}  ${qos_profile_speed_ul}
    ...     ${qos_profile_speed_dl}    ${qos_profile}
    Start and Stop TTI TRACE    cell_ids=@{cell_id}
    sleep   ${duration}s
    Collect TTI Trace   tti_trace

    ${nongbr_tp_read}=     Verify data transfer and get tp gbr_nongbr    ${st_ue_id_c3}    ${en_ue_id_c3}    ${duration}    both   ${trf_id}
    ...    ${qos_profile_unit}    ${qos_profile_speed_ul}     ${qos_profile_speed_dl}    ${qos_profile}    gbr_chk=1

    MultiUE Deregister should be Successful   ${st_ue_id}    ${en_ue_id}
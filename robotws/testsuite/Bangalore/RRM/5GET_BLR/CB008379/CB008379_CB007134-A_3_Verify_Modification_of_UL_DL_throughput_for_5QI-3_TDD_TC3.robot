*** Settings ***
Force Tags      CLOUD_5G_I_LN_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_SC_TDD    5G_RAN     SBTS00     SBTS23R1    CONFIGURED

Resource         ./CB008379_Resource.robot
Resource         ../resources/robot/common_log_collection.robot

#Suite Setup         Run keywords    Prepare TL with all config files
#...                 AND     Suite setup from scratch
Suite Setup         Run keywords     Suite setup from scratch
...                 AND     Perform SCF Delta Commissioning with Delta_Configuration_1CC_TDD_GBR_8379_FS_3_7.json
#...                 AND     sleep    600
#...                 AND     Reboot gNB System Module from Console and check Airscale is ready
...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
...                 AND     Check Cell On Air      ${wts_cfg_file}

Suite Teardown      Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}

Test Teardown    Run Keywords   MultiUE Deregister should be Successful      ${st_ue_id}    ${en_ue_id}
...              AND        Link SCOUT SCF to Configuration ID for Reporting

Documentation
...
...             author:            Samik Sarkar, samik.sarkar@nokia.com
...             maintainer:        Samik Sarkar, samik.sarkar@nokia.com
...
...             INTRODUCTION:     Use case of the Test case is to verify the GFBR modification triggered from
...                               AMF from initial GFBR value of 30mbps to 20mbps for nonVonrGBR 5QI-3
...             TEST SET NAME:    CB008379-5G-A_3_Verify_Modification_of_UL_DL_throughput_for_5QI-3_TDD.
...                               This user scenario describes the gNB behaviour for the successful UL and DL
...                               throughput Modification of GBR QoS Flow with 5Q3 for any value in range
...                               within 30Mbps on Classical gNB
...             TESTING SPLIT:    See CB008379 testplan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008379 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_5,5G_RAN_USR_RRM_14713,5G_RAN_USR_RRM_14714,5G_RAN_USR_RRM_1649,
...                               5G_RAN_USR_RRM_1227

*** Variables ***
#${SCFC}             ${CURDIR}/config/SCF/SCF_CB008379_CB007134-A_3_TDD_LN_LO.xml
${SCFC}             ${CURDIR}/config/SCF/SCF_CB008379_CB007134-A_3_TDD_MP_LO.xml
${AP_XML}           ${CURDIR}/config/SCF/iphy_CB008379_CB007134-A_3_TDD_LN_LO.xml
${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_1CC_max_gfbr_30_tdd_um_mode.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
${st_ue_id}      ${1}
${en_ue_id}      ${1}

# GFBR and MFBR profile <qos flow id>_gfbr_<dir>=speed it is in the unit of Kn for mb add three 0s
&{gfbr_mfbr_profile}        5_gfbr_ul=20480   5_gfbr_dl=20480    5_mfbr_ul=20480     5_mfbr_dl=20480


@{QOS_Prof1}                1           5
@{QOS_Prof1_speed_ul}       20          30
@{QOS_Prof1_speed_dl}       20          30
@{QOS_Prof1_unit}           mbps        mbps

*** Test Cases ***
[1][1.0] CB008379-5G-A_3_Verify_Modification_of_UL_DL_throughput_for_5QI-3_TDD

#Starting CPRT Trace Capturing
    set test variable      ${LOG_PATH}
    Increase Buffer Size for VM and IPHY
    log to console   UE attach trigerring now...

    ${qos_profile}               Create Dictionary   ${1}=${QOS_Prof1}
    ${qos_profile_speed_ul}      Create Dictionary   ${1}=${QOS_Prof1_speed_ul}
    ${qos_profile_speed_dl}      Create Dictionary   ${1}=${QOS_Prof1_speed_dl}
    ${qos_profile_unit}          Create Dictionary   ${1}=${QOS_Prof1_unit}

#Step 1. Attach 1 UE having non-GBR and non-VoNR QOS Profile

    ${ue_to_bearer_list}=       MultiUE Register should be Successful with Fetch Bearer ID     ${st_ue_id}    ${en_ue_id}    pdu_id=1    nw_id=1
    Log to Console             Bearerlist with${ue_to_bearer_list}
    Create Modify PDU session   ${st_ue_id}     ${en_ue_id}    ${qos_profile}   pdu_id=1    gfbr_mfbr_profile=${gfbr_mfbr_profile}
    ...    ue_to_bearer_list=${ue_to_bearer_list[1]}
    Log to Console             Bearerlist with${ue_to_bearer_list}
    ${total_duration}      Set Variable    600
    ${trf_id}      Set Variable    ${1}

# For UL and DL data transfer a List tp will return in a list other wise a single dict will come direction both means ul and DL

    ${trigger_point_dur}=     Set Variable      300
    ${remainined_dur}=     Evaluate   ${total_duration}-${trigger_point_dur}
    ${updated_qos_profile_speed_ul}=    Copy Dictionary      ${qos_profile_speed_ul}      deepcopy=True
    ${updated_qos_profile_speed_dl}=    Copy Dictionary      ${qos_profile_speed_dl}      deepcopy=True
    ${prf1}=       Create List    20            20
    Set To Dictionary  ${updated_qos_profile_speed_ul}     ${1}    ${prf1}
    Set To Dictionary  ${updated_qos_profile_speed_dl}     ${1}    ${prf1}
    ${updated_ue_list}=        Create List         ${1}
    log to console     ${updated_qos_profile_speed_ul}
    log to console     ${qos_profile_speed_ul}

    ${delta_time}=     Start Data Transfer After GFBR Update   ${st_ue_id}     ${en_ue_id}    ${total_duration}   ${trigger_point_dur}
    ...   both  ${trf_id}   ${qos_profile_unit}     ${qos_profile_speed_ul}    ${qos_profile_speed_dl}    ${qos_profile}
    ...   ${updated_ue_list}    ${updated_qos_profile_speed_ul}    ${updated_qos_profile_speed_dl}    both
    ...   ${gfbr_mfbr_profile}    tti_trace_1   update=1    tti_dur=10

    ${bearer_stats_ul}=   Get Received Sent Bytes New     ${st_ue_id}    ${en_ue_id}    ${qos_profile}    ul
    ${bearer_stats_dl}=   Get Received Sent Bytes New     ${st_ue_id}    ${en_ue_id}    ${qos_profile}    dl

    ${status}=      utility.verify_tp_on_dr_modif       ${bearer_stats_ul}   ${remainined_dur}       ${delta_time[0]}
    ...     ${qos_profile_speed_ul}     ${updated_qos_profile_speed_ul}     ${qos_profile_unit}     ${vonr_codec_rate}
    ...     ${updated_ue_list}
    Should Contain     ${status}    Pass

    ${status}=      utility.verify_tp_on_dr_modif       ${bearer_stats_dl}   ${remainined_dur}       ${delta_time[1]}
    ...     ${qos_profile_speed_dl}     ${updated_qos_profile_speed_dl}     ${qos_profile_unit}     ${vonr_codec_rate}
    ...     ${updated_ue_list}
    Should Contain     ${status}    Pass

    ${tti_tp_ul}    tti_trace_utility.get_tp_frm_tti    ${ue_to_bearer_list[0]}     ${ue_to_bearer_list[1]}
    ...    ul       ${delta_time[2]}/output_ul_formated.csv    tti_dur=10
    ${tti_tp_dl}    tti_trace_utility.get_tp_frm_tti    ${ue_to_bearer_list[0]}     ${ue_to_bearer_list[1]}
    ...    dl       ${delta_time[2]}/output_dl_formated.csv    tti_dur=10

    ${status}=      tti_trace_utility.verify_tp_from_tti    ${ue_to_bearer_list[1]}   ${tti_tp_dl}   ${updated_qos_profile_speed_dl}
    ...      ${qos_profile_unit}     ${vonr_codec_rate}  ${total_duration}    ${trigger_point_dur}
    Should Contain     ${status}    Pass
    ${status}=      tti_trace_utility.verify_tp_from_tti    ${ue_to_bearer_list[1]}   ${tti_tp_ul}   ${updated_qos_profile_speed_ul}
    ...      ${qos_profile_unit}     ${vonr_codec_rate}  ${remainined_dur}    ${trigger_point_dur}
    Should Contain     ${status}    Pass
    MultiUE PDU Release should be Successful   ${st_ue_id}    ${en_ue_id}
#    MultiUE Deregister should be Successful   ${st_ue_id}    ${en_ue_id}

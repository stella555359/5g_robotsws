*** Settings ***
Force Tags      CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_FDD
...             CRT    RAN_5G_FDD    RAN_5G    5G_RAN_FDD    5G_SC_FDD    5G_RAN     SBTS00    SBTS23R1    CONFIGURED

Resource         ./CB008379_Resource.robot
Resource         ../resources/robot/common_log_collection.robot

#Suite Setup         Run keywords    Prepare TL with all config files
#...                 AND     Suite setup from scratch
Suite Setup         Run keywords     Suite setup from scratch
...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
...                 AND     Perform SCF Delta Commissioning with Delta_Configuration_1CC_FDD_GBR_8379_20MHz_LA.json
...                 AND     Reboot gNB System Module from Console and check Airscale is ready
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
...             INTRODUCTION:     Use case of the Test case is to verify the data Transfer rate with Max GFBR
...                               of 30mbps consistently for nonVonrGBR 5QI-4
...             TEST SET NAME:    CB008379-A_6_Verify_Max_UL_throughput_for_5QI-4_FDD_TC6.
...                               Use case of the Test case is to verify the data Transfer rate with Max GFBR
...                               of 30mbps consistently for with 30 minutes with nonVonrGBR 5QI-4 and SINR -250
...                               on Classical gNB
...             TESTING SPLIT:    See CB008379 testplan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008379 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_5,5G_RAN_USR_RRM_14713,5G_RAN_USR_RRM_14714,5G_RAN_USR_RRM_1649,
...                               5G_RAN_USR_RRM_1227

*** Variables ***
${SCFC}             ${CURDIR}/config/SCF/SCF_CB008379-A_6_FDD_20MHZ.xml
${AP_XML}           ${CURDIR}/config/SCF/iphy_CB008379-A_6_FDD_20MHZ.xml
${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_max_gfbr_30_fdd_um_mode_mp.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
${st_ue_id}      ${1}
${en_ue_id}      ${1}

# GFBR and MFBR profile <qos flow id>_gfbr_<dir>=speed
&{gfbr_mfbr_profile}                6_gfbr_ul=10   6_gfbr_dl=20    6_mfbr_ul=40     6_mfbr_dl=50

#Make sure VONR Traffic profile should in kbps for 5QI1 and 5QI 5 i.e QFI 2 and 3
@{QOS_Prof1}                1            6
@{QOS_Prof1_speed_ul}       2            30
@{QOS_Prof1_speed_dl}       2            30
@{QOS_Prof1_unit}           mbps         mbps

*** Test Cases ***
[1][1.0] CB007425_A_CB008379-5G-A_6_Verify_Max_UL_throughput_with_Link_Adaptation_for_5QI-4_FDD
    set test variable      ${LOG_PATH}
    Increase Buffer Size for VM and IPHY
    log to console   UE attach trigerring now...
    ${qos_profile}               Create Dictionary   ${1}=${QOS_Prof1}
    ${qos_profile_speed_ul}      Create Dictionary   ${1}=${QOS_Prof1_speed_ul}
    ${qos_profile_speed_dl}      Create Dictionary   ${1}=${QOS_Prof1_speed_dl}
    ${qos_profile_unit}          Create Dictionary   ${1}=${QOS_Prof1_unit}

#Step 1. Attach 1 UE with profile GFBR profile 30mbps with fiveQI3
    ${ue_to_bearer_list}=       MultiUE Register should be Successful with Fetch Bearer ID     ${st_ue_id}
    ...    ${en_ue_id}    pdu_id=1    nw_id=1
    Log to Console             Bearerlist with${ue_to_bearer_list}
    Create Modify PDU session   ${st_ue_id}     ${en_ue_id}    ${qos_profile}   pdu_id=1    gfbr_mfbr_profile=${gfbr_mfbr_profile}
    ...    ue_to_bearer_list=${ue_to_bearer_list[1]}
    ${duration}      Set Variable    1800
    ${trf_id}      Set Variable    ${1}

# For UL and DL data transfer a List tp will return in a list other wise a single dict will come direction both means ul and DL
    Start Data Transfer     ${st_ue_id}     ${en_ue_id}     ${duration}    ul   ${trf_id}   ${qos_profile_unit}  ${qos_profile_speed_ul}
    ...     ${qos_profile_speed_dl}    ${qos_profile}
    Set fixed cqi bler for single UE    ${st_ue_id}    ul
    Start and Stop TTI TRACE    duration=${10}
    sleep   ${duration}s
    ${new_path}      Collect TTI Trace   tti_trace
    ${tti_tp_ul}    tti_trace_utility.get_tp_frm_tti    ${ue_to_bearer_list[0]}     ${ue_to_bearer_list[1]}
    ...    ul       ${new_path}/output_ul_formated.csv
    ${nongbr_tp_read}=     Verify data transfer and get tp      ${st_ue_id}     ${en_ue_id}     ${duration}    ul   ${trf_id}
   ...    ${qos_profile_unit}    ${qos_profile_speed_ul}    ${qos_profile_speed_dl}    ${qos_profile}
    ${status}=      tti_trace_utility.verify_tp_from_tti    ${ue_to_bearer_list[1]}   ${tti_tp_ul}   ${qos_profile_speed_ul}
    ...      ${qos_profile_unit}     ${vonr_codec_rate}  ${0}   ${0}
    Should Contain     ${status}    Pass
#    MultiUE Deregister should be Successful   ${st_ue_id}    ${en_ue_id}



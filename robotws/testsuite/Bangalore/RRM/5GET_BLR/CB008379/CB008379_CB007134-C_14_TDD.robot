*** Settings ***
Force Tags      CLOUD_5G_I_LN_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_SC_TDD    5G_RAN     SBTS00     SBTS23R1    CONFIGURED

Resource         ./CB008379_Resource.robot
Resource         ../resources/robot/common_log_collection.robot

Suite Setup         Run keywords     Suite setup from scratch
...            AND     Perform SCF Delta Commissioning with Delta_Configuration_1CC_TDD_GBR_MultiUE_with_8379_1_4.json
...            AND     sleep    40
...            AND     Reboot gNB System Module from Console and check Airscale is ready
...            AND     sleep    300
...            AND     Start Default Logging    output_dirpath=${LOG_PATH}
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
...                               of 30mbps consistently for VinrGBR 5QI-2 and VonrGBR 5QI-1
...             TEST SET NAME:    CB008379-5G-C_14_Scheduling_Priority_for_UE_with_5QI1_and_5QI2_GBR_bearers_TDD
...                               Use case of the Test case is to verify the data Transfer rate with Max GFBR
...                               of 30mbps consistently for 30 minutes with VinrGBR 5QI-2 on Classical gNB
...             TESTING SPLIT:    See CB008379 testplan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008379 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_14716,5G_RAN_USR_RRM_14807

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_2CC_max_gfbr_30_tdd_um_mode.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
${st_ue_id}      ${1}
${en_ue_id}      ${5}
# GFBR and MFBR profile <qos flow id>_gfbr_<dir>=speed
&{gfbr_mfbr_profile}                5_gfbr_ul=10   5_gfbr_dl=20    5_mfbr_ul=40     5_mfbr_dl=50

#Make sure VONR Traffic profile should in kbps for 5QI1 and 5QI 5 i.e QFI 2 and 3


@{QOS_Prof2}                1
@{QOS_Prof2_speed_ul}       30
@{QOS_Prof2_speed_dl}       30
@{QOS_Prof2_unit}           mbps


@{QOS_Prof7}               1       2           3                4
@{QOS_Prof7_speed_ul}      30       32         amr_wb_18_25     30
@{QOS_Prof7_speed_dl}      30       32         amr_wb_18_25     30
@{QOS_Prof7_unit}          mbps    kbps        rtp_codec        mbps


*** Test Cases ***
[1]CB008379-5G-C_14_Scheduling_Priority_for_UE_with_5QI1_and_5QI2_GBR_bearers_and_Multiple_UEs_with_a_non-GBR_bearer_TDD

    set test variable      ${LOG_PATH}
    Increase Buffer Size for VM and IPHY
    log to console   UE attach trigerring now...

    ${qos_profile}               Create Dictionary   ${1}=${QOS_Prof7}              ${2}=${QOS_Prof2}
    ...     ${3}=${QOS_Prof2}                ${4}=${QOS_Prof2}      ${5}=${QOS_Prof2}
    ${qos_profile_speed_ul}      Create Dictionary   ${1}=${QOS_Prof7_speed_ul}     ${2}=${QOS_Prof2_speed_ul}
    ...     ${3}=${QOS_Prof2_speed_ul}     ${4}=${QOS_Prof2_speed_ul}     ${5}=${QOS_Prof2_speed_ul}
    ${qos_profile_speed_dl}      Create Dictionary   ${1}=${QOS_Prof7_speed_dl}     ${2}=${QOS_Prof2_speed_dl}
    ...     ${3}=${QOS_Prof2_speed_dl}     ${4}=${QOS_Prof2_speed_dl}   ${5}=${QOS_Prof2_speed_dl}
    ${qos_profile_unit}          Create Dictionary   ${1}=${QOS_Prof7_unit}         ${2}=${QOS_Prof2_unit}
    ...     ${3}=${QOS_Prof2_unit}            ${4}=${QOS_Prof2_unit}       ${5}=${QOS_Prof2_unit}

#Step 1. Attach 1 UE with profile GFBR profile 30mbps with fiveQI3

    ${ue_to_bearer_list}=       MultiUE Register should be Successful with Fetch Bearer ID     ${st_ue_id}
    ...    ${en_ue_id}     pdu_id=1    nw_id=1
    Create Modify PDU session   ${st_ue_id}     ${en_ue_id}    ${qos_profile}   pdu_id=1
    ...     gfbr_mfbr_profile=${gfbr_mfbr_profile}     ue_to_bearer_list=${ue_to_bearer_list[1]}
    ${duration}      Set Variable    300
    ${trf_id}      Set Variable    ${1}
# For UL and DL data transfer a List tp will return in a list other wise a single dict will come direction both means ul and DL
# Make sure that Non GBR call is fully occupying the network bandwidth then only  utility.compare_tp will work
    Start Data Transfer     ${st_ue_id}     ${en_ue_id}     ${duration}    both   ${trf_id}   ${qos_profile_unit}
    ...     ${qos_profile_speed_ul}      ${qos_profile_speed_dl}    ${qos_profile}
    Start and Stop TTI TRACE
    sleep   ${duration}s
    Collect TTI Trace   tti_trace

    ${nongbr_tp_read}=     Verify data transfer and get tp gbr_nongbr      ${st_ue_id}     ${en_ue_id}     ${duration}
    ...     both   ${trf_id}   ${qos_profile_unit}    ${qos_profile_speed_ul}     ${qos_profile_speed_dl}
    ...     ${qos_profile}    gbr_chk=1


    MultiUE Deregister should be Successful   ${st_ue_id}    ${en_ue_id}



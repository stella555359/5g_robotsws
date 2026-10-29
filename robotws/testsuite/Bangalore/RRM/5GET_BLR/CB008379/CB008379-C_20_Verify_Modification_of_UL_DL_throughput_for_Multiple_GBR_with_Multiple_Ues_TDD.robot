*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_SC_TDD    5G_RAN     SBTS00    SBTS22R3    CONFIGURED

Resource         ./CB008379_Resource.robot

Suite Setup         Run keywords     Suite setup from scratch
...                 AND     Perform SCF Delta Commissioning with Delta_Configuration_1CC_TDD_GBR_8379_FS_3_7_tc20.json
...            AND     sleep    400
...                 AND     Reboot gNB System Module from Console and check Airscale is ready
...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file}

Suite Teardown      Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}

Documentation
...
...             author:            Vaibhav Tyagi, vaibhav.3.tyagi@nokia.com
...             maintainer:        Vaibhav Tyagi, vaibhav.3.tyagi@nokia.com
...
...             INTRODUCTION:     Use case of the Test case is to verify NIDD parameter online modification
...                               of 30mbps consistently for no
...             TEST SET NAME:    CB008379-5G-C_20_Verify_Modification_of_UL_DL_throughput_for_Multiple_GBR_with_Multiple_Ues_TDD
...                               Use case of the Test case is to verify the data before and after
...                               online modification of NIDD parameter
...             TESTING SPLIT:    See CB008379 testplan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008379 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_5,5G_RAN_USR_RRM_14713,5G_RAN_USR_RRM_14714,5G_RAN_USR_RRM_1649,
...                               5G_RAN_USR_RRM_1227

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_1CC_max_gfbr_20_tdd_um_mode.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
${st_ue_id}      ${1}
${en_ue_id}      ${6}
# GFBR and MFBR profile <qos flow id>_gfbr_<dir>=speed it is in the unit of Kn for mb add three 0s
&{gfbr_mfbr_profile}        5_gfbr_ul=30720   5_gfbr_dl=30720    5_mfbr_ul=30720     5_mfbr_dl=30720
...                         3_gfbr_ul=25      3_gfbr_dl=25       3_mfbr_ul=30720     3_mfbr_dl=30720
...                         4_gfbr_ul=30720   4_gfbr_dl=30720    4_mfbr_ul=30720     4_mfbr_dl=30720

#Make sure VONR Traffic profile should in kbps for 5QI1 and 5QI 5 i.e QFI 2 and 3
@{QOS_Prof1}                1           5
@{QOS_Prof1_speed_ul}       2           20
@{QOS_Prof1_speed_dl}       2           20
@{QOS_Prof1_unit}           mbps        mbps


@{QOS_Prof2}               1       2       3                5
@{QOS_Prof2_speed_ul}      1       32      amr_wb_18_25     20
@{QOS_Prof2_speed_dl}      1       32      amr_wb_18_25     20
@{QOS_Prof2_unit}          mbps    kbps    rtp_codec        mbps


@{QOS_Prof3}               1       2       3                4
@{QOS_Prof3_speed_ul}      1       32      amr_wb_18_25     20
@{QOS_Prof3_speed_dl}      1       32      amr_wb_18_25     20
@{QOS_Prof3_unit}          mbps    kbps    rtp_codec        mbps
*** Test Cases ***
[1]CB008379-5G-C_20_Verify_Modification_of_UL_DL_throughput_for_Multiple_GBR_with_Multiple_Ues_TDD

#Starting CPRT Trace Capturing
    set test variable      ${LOG_PATH}
    Increase Buffer Size for VM and IPHY
    log to console   UE attach trigerring now...

    ${qos_profile}    Create Dictionary   ${1}=${QOS_Prof2}    ${2}=${QOS_Prof3}
    ...     ${3}=${QOS_Prof3}
    ${qos_profile_speed_ul}     Create Dictionary   ${1}=${QOS_Prof2_speed_ul}    ${2}=${QOS_Prof3_speed_ul}
    ...    ${3}=${QOS_Prof3_speed_ul}

    ${qos_profile_speed_dl}      Create Dictionary   ${1}=${QOS_Prof2_speed_dl}     ${2}=${QOS_Prof3_speed_dl}
    ...    ${3}=${QOS_Prof3_speed_dl}

    ${qos_profile_unit}    Create Dictionary    ${1}=${QOS_Prof2_unit}    ${2}=${QOS_Prof3_unit}
    ...    ${3}=${QOS_Prof3_unit}

    ${trf_id}        Set Variable    ${1}
    ${duration}      Set Variable    ${180}
    ${ue_to_bearer_list}=       MultiUE Register should be Successful with Fetch Bearer ID     ${st_ue_id}    ${3}    pdu_id=1    nw_id=1
    Log to Console             Bearerlist with${ue_to_bearer_list}

    Create Modify PDU session   ${1}     ${1}    ${qos_profile}   pdu_id=1    gfbr_mfbr_profile=${gfbr_mfbr_profile}
    ...     ue_to_bearer_list=${ue_to_bearer_list[1]}     num_ues=${3}
    Start Data Transfer     ${1}     ${1}     ${duration}    both   ${trf_id}   ${qos_profile_unit}  ${qos_profile_speed_ul}
    ...     ${qos_profile_speed_dl}    ${qos_profile}

    Perform SCF Delta Commissioning with Delta_Configuration_1CC_GBR_MultiUE_with_8379_FS_3_7_C20_TLmod.json

    Create Modify PDU session   ${2}     ${2}    ${qos_profile}   pdu_id=1    gfbr_mfbr_profile=${gfbr_mfbr_profile}
    ...     ue_to_bearer_list=${ue_to_bearer_list[1]}     num_ues=${3}

    Start Data Transfer     ${2}     ${2}     ${duration}    both   ${trf_id}   ${qos_profile_unit}  ${qos_profile_speed_ul}
    ...     ${qos_profile_speed_dl}    ${qos_profile}

    MultiUE Deregister should be Successful   ${1}    ${2}


*** Settings ***
Force Tags      CLOUD_5G_I_BO_AP_KL_SANSA_FS_CPRI_CMWV_FDD
...             CRT    RAN_5G_FDD    RAN_5G    5G_RAN_FDD     5G_RAN     SBTS00    SBTS23R1    CONFIGURED

Resource         ./CB009425_Resource_New.robot
Resource         ../resources/robot/common_log_collection.robot

Suite Setup         Run keywords     Suite setup from scratch
...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
...                 AND     Perform SCF Delta Commissioning with Delta_Configuration_FDD_with_9425.json
...                 AND    gnb.Perform gNB reboot
...                 AND    Sleep   360s    reason=wait for RMOD- to comeup
...                 AND     Check Cell On Air      ${wts_cfg_file}

Suite Teardown      Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}

Documentation
...
...             author:            Prerana N S, prerana.n_s@nokia
...             maintainer:        Prerana N S, prerana.n_s@nokia
...
...             INTRODUCTION:     This user scenario describes L2-PS behaviour in controlling of the DL MCS downgrade for
...                               VoNR transport block sizes.The purpose of this user scenario is to arrive at a favorabled
...                               step-size to limit this downgrade.
...             TEST SET NAME:    CB009425-A_TC24_Improved transmission link reliability due to inhibiting MCS downgrade control for VoNR Ues
...             TESTING SPLIT:    See CB009425 testplan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB009425 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_17671

*** Variables ***
#${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_2CC_max_gfbr_30_fdd_um_mode.cfg
${wts_cfg_file}     ${WTS_DIR}/basic_setup.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
${st_ue_id}      ${51}
${en_ue_id}      ${52}

# GFBR and MFBR profile <qos flow id>_gfbr_<dir>=speed
&{gfbr_mfbr_profile}                6_gfbr_ul=10   6_gfbr_dl=20    6_mfbr_ul=40     6_mfbr_dl=50

#Make sure VONR Traffic profile should in kbps for 5QI1 and 5QI 5 i.e QFI 2 and 3
@{QOS_Prof1}               1
@{QOS_Prof1_speed_ul}      1
@{QOS_Prof1_speed_dl}      1
@{QOS_Prof1_unit}          mbps

@{QOS_Prof2}               1       2          3                #4
@{QOS_Prof2_speed_ul}      1      32         amr_wb_18_25     #30
@{QOS_Prof2_speed_dl}      1      32         amr_wb_18_25     #30
@{QOS_Prof2_unit}          kbps    kbps       rtp_codec        #mbps

*** Test Cases ***
[1]CB009425-A_TC24_Improved_transmission_link_reliability_due_to_inhibiting_MCS_downgrade_control_for_VoNR_Ues
    set test variable      ${LOG_PATH}
    Increase Buffer Size for VM and IPHY
    log to console   UE attach trigerring now...
    ${qos_profile}               Create Dictionary   ${1}=${QOS_Prof2}       ${2}=${QOS_Prof2}
    ${qos_profile_speed_ul}      Create Dictionary   ${1}=${QOS_Prof2_speed_ul}    ${2}=${QOS_Prof2_speed_ul}
    ${qos_profile_speed_dl}      Create Dictionary   ${1}=${QOS_Prof2_speed_dl}    ${2}=${QOS_Prof2_speed_dl}
    ${qos_profile_unit}          Create Dictionary   ${1}=${QOS_Prof2_unit}    ${2}=${QOS_Prof2_unit}

    Start Log    btslog
    ${crnti_list}     ${ue_to_bearer_list}=       MultiUE Register should be Successful with Fetch Bearer ID
    ...     ${st_ue_id}    ${en_ue_id}    pdu_id=1    nw_id=1
    Log to Console             Bearerlist with${ue_to_bearer_list}
    Log to Console             crnti_list with${crnti_list}
    Create Modify PDU session   ${st_ue_id}     ${en_ue_id}    ${qos_profile}   pdu_id=1    gfbr_mfbr_profile=${gfbr_mfbr_profile}
    ...    ue_to_bearer_list=${ue_to_bearer_list}
    ${duration}      Set Variable    1200
    ${trf_id}      Set Variable    ${1}

    Start Data Transfer     ${st_ue_id}     ${en_ue_id}     ${duration}    both   ${trf_id}   ${qos_profile_unit}  ${qos_profile_speed_ul}
    ...     ${qos_profile_speed_dl}    ${qos_profile}
    Set fixed cqi bler for single UE    ${st_ue_id}    dl
    Start log    ttitrace
    sleep    3s
    ${new_path}    Stop log    ttitrace    test_scenario=ttitrace1

    Decode TTI Trace    ttitrace1

    final verdict for mcs drop     ${crnti_list[0]}     ${new_path}[ttitrace]/output_dl_formated.csv      dlMcsDropLimitForVoNR=${2}    tc_scen=${1}

    MultiUE Deregister should be Successful   ${st_ue_id}    ${en_ue_id}

# Disabling the dlMCSdowngrade parameter value i.e dlMCSdowngrade=0
    Perform SCF Delta Commissioning with Delta_Configuration_2CC_FDD_GBR_MultiUE_with_9425_15MHz_online3.json

    ${crnti_list1}     ${ue_to_bearer_list1}=       MultiUE Register should be Successful with Fetch Bearer ID
    ...     ${st_ue_id}    ${en_ue_id}    pdu_id=1    nw_id=1
    Log to Console             Bearerlist with${ue_to_bearer_list1}
    Log to Console             crnti_list with${crnti_list1}
    Create Modify PDU session   ${st_ue_id}     ${en_ue_id}    ${qos_profile}   pdu_id=1    gfbr_mfbr_profile=${gfbr_mfbr_profile}
    ...    ue_to_bearer_list=${ue_to_bearer_list1}
    ${duration}      Set Variable    1200
    ${trf_id}      Set Variable    ${1}

    Start Data Transfer     ${st_ue_id}     ${en_ue_id}     ${duration}    both   ${trf_id}   ${qos_profile_unit}  ${qos_profile_speed_ul}
    ...     ${qos_profile_speed_dl}    ${qos_profile}
    Set fixed cqi bler for single UE    ${st_ue_id}    dl

    Start log    ttitrace
    sleep    3s
    ${new_path1}    Stop log    ttitrace    btslog    test_scenario=ttitrace2

    MultiUE Deregister should be Successful   ${st_ue_id}    ${en_ue_id}

    Decode TTI Trace    ttitrace2

    final verdict for mcs drop    ${crnti_list1[0]}     ${new_path1}[ttitrace]/output_dl_formated.csv     dlMcsDropLimitForVoNR=${0}    tc_scen=${4}
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting

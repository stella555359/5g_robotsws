*** Settings ***
Force Tags      CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_FDD
...             CRT    RAN_5G_FDD    RAN_5G    5G_RAN_FDD    5G_RAN     SBTS00    SBTS23R1    CONFIGURED

Resource         ./CB009425_Resource_New.robot
Resource         ../resources/robot/common_log_collection.robot

Suite Setup         Run keywords     Suite setup from scratch
...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
...                 AND     Perform SCF Delta Commissioning with Delta_Configuration_1CC_FDD_CB009425_26_15MHz.json
...                 AND     Reboot gNB System Module from Console and check Airscale is ready
...                 AND    Configure UTE ETH3 IPs
...                 AND     Check Cell On Air      ${wts_cfg_file}

Suite Teardown      Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}

Documentation
...
...             author:            Prerana N S, prerana.n_s@nokia.com
...             maintainer:        Prerana N S, prerana.n_s@nokia.com
...
...             INTRODUCTION:     This user scenario describes gNB behaviour to improve link level performance when
...                               several enhancements to improve transmission link budget for VoNR UEs are enabled together.
...             TEST SET NAME:    CB009425-A5 Verifying with several enhancements to improve transmission link budget for multiple VoNR UEs
...             TESTING SPLIT:    See CB009425 testplan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB009425 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_17673

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_1CC_max_gfbr_30_fdd_um_mode.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
${st_ue_id}      ${1}
${en_ue_id}      ${2}

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
@{QOS_Prof2_unit}          kbps   kbps       rtp_codec        #kbps

*** Test Cases ***
[1]CB009425-A_TC26_Verifying_with_several_enhancements_to_improve_transmission_link_budget_for_multiple_VoNR_Ues
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
    ${duration}      Set Variable    -1
    ${trf_id}      Set Variable    ${1}

    Start Data Transfer     ${st_ue_id}     ${en_ue_id}     ${duration}    both   ${trf_id}   ${qos_profile_unit}  ${qos_profile_speed_ul}
    ...     ${qos_profile_speed_dl}    ${qos_profile}
    Set user defined bler for multiple UE    ${st_ue_id}       ${en_ue_id}     dl    60
    Start log    ttitrace
    sleep    3s
    ${tti_path}    Stop log    ttitrace    btslog    test_scenario=ttitrace_Vonr

    MultiUE Deregister should be Successful   ${st_ue_id}    ${en_ue_id}

    Decode TTI Trace    ttitrace_Vonr

    final verdict for enh retx    ${crnti_list[0]}    ${tti_path}[ttitrace]/output_dl_formated.csv    maxPrbsVoNR=${32}    tc_scen=${4}
    final verdict for mcs drop    ${crnti_list[0]}     ${tti_path}[ttitrace]/output_dl_formated.csv     dlMcsDropLimitForVoNR=2      tc_scen=${1}
    final verdict for min tbs prb    ${crnti_list[0]}    ${tti_path}[ttitrace]/output_ul_formated.csv
    ...    minPuschPrbForMinTbsVoNR=${3}     ulMinTbsForVoNR=${224}    tc_scen=${1}
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting

*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_FDD
...             CRT    RAN_5G_FDD    RAN_5G    5G_RAN_FDD    5G_SC_FDD    5G_RAN     SBTS00    SBTS23R2    CONFIGURED

Resource         ./CB009425_Resource_New.robot
#Resource         ../resources/robot/TTI.robot
Resource         ../resources/robot/common_log_collection.robot
Suite Setup         Run keywords     Suite setup from scratch
...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
...                 AND     Perform SCF Delta Commissioning with delta_config_2CC_intraDU_Intercell_ho.json
...                 AND     Reboot gNB System Module from Console and check Airscale is ready
...                 AND     Check Cell On Air      ${wts_cfg_file}

Suite Teardown      Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}
...                 AND     Link SCOUT SCF to Configuration ID for Reporting

Documentation
...             author:            Vaibhav Tyagi, vaibhav.3.tyagi@nokia.com
...             maintainer:        Vaibhav Tyagi, vaibhav.3.tyagi@nokia.com
...
...             INTRODUCTION:     Use case of the Test case is to verify the DeltaCQI with handover
...                               One UE in cell-1 and another in cell-2. HO of UE-1 from cell-1 to cell-2
...             TEST SET NAME:    CB009425-A_TC21_Improved transmission link reliability due to conservative initial
...                               Delta cqi for VoNR UEs during incoming Handover.
...             TESTING SPLIT:    See CB009425-A testplan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB009425 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_17672


*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_1.cfg
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

@{QOS_Prof2}               1       2          3
@{QOS_Prof2_speed_ul}      1       32         amr_wb_18_25
@{QOS_Prof2_speed_dl}      1       32         amr_wb_18_25
@{QOS_Prof2_unit}          mbps    kbps       rtp_codec

*** Test Cases ***
[1]CB009425-A2_Improved_DL_UL_transmission_link_reliability_in_VoNR_Ues_when_low_initial_BLER_target_configured_for_2VoNR_Ues_and_2nGBR_Ues
    set test variable      ${LOG_PATH}
    log to console    ${LOG_PATH}
    Increase Buffer Size for VM and IPHY
    log to console   UE attach trigerring now...
    ${qos_profile}               Create Dictionary   ${1}=${QOS_Prof2}       ${2}=${QOS_Prof1}
#    ...     ${3}=${QOS_Prof1}      ${4}=${QOS_Prof1}
    ${qos_profile_speed_ul}      Create Dictionary   ${1}=${QOS_Prof2_speed_ul}    ${2}=${QOS_Prof1_speed_ul}
#    ...     ${3}=${QOS_Prof1_speed_ul}    ${4}=${QOS_Prof1_speed_ul}
    ${qos_profile_speed_dl}      Create Dictionary   ${1}=${QOS_Prof2_speed_dl}    ${2}=${QOS_Prof1_speed_dl}
#    ...     ${3}=${QOS_Prof1_speed_dl}    ${4}=${QOS_Prof1_speed_dl}
    ${qos_profile_unit}          Create Dictionary   ${1}=${QOS_Prof2_unit}    ${2}=${QOS_Prof1_unit}
#    ...     ${3}=${QOS_Prof1_unit}    ${4}=${QOS_Prof1_unit}

#Step 1. Attach 1 UE with profile GFBR profile 30mbps with fiveQI3
    ${crnti_list}     ${ue_to_bearer_list}=       MultiUE Register should be Successful with Fetch Bearer ID
    ...     ${st_ue_id}    ${en_ue_id}    pdu_id=1    nw_id=1
    Log to Console             Bearerlist with${ue_to_bearer_list}
    Log to Console             crnti_list with${crnti_list}
    Create Modify PDU session   ${st_ue_id}     ${en_ue_id}    ${qos_profile}   pdu_id=1    gfbr_mfbr_profile=${gfbr_mfbr_profile}
    ...    ue_to_bearer_list=${ue_to_bearer_list}
    ${duration}      Set Variable    -1
    ${trf_id}      Set Variable    ${1}

# For UL and DL data transfer a List tp will return in a list other wise a single dict will come direction both means ul and DL
    Start Data Transfer     ${st_ue_id}     ${en_ue_id}     ${duration}    both   ${trf_id}   ${qos_profile_unit}  ${qos_profile_speed_ul}
    ...     ${qos_profile_speed_dl}    ${qos_profile}
    Start Log     ttitrace     cell_id=50,51
    sleep   3s
    ${new_path1}      Stop Log    ttitrace    test_scenario=b4_ho
    IntragNB Intercell HO SA A3 UE measurements
    wtsrunner.bearer_stats    ue=1    pdu=2    qfi=3    trf_id=1

    ${bearer_stat}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30

    Start Log     ttitrace     cell_id=50,51
    sleep   10s
    ${new_path2}      Stop Log    ttitrace    test_scenario=after_ho

    ${x}    Run   cat ${LOG_PATH}/enb/default_syslog_enbNone.log|grep -i "isEarlyDllaActive and VoNR configured iniDeltaCqi"|awk '{print $16}'
    ${y}    Run   cat ${LOG_PATH}/enb/default_syslog_enbNone.log|grep -i "isEarlyDllaActive and VoNR configured iniDeltaCqi"|awk '{print $19}'
    ${z}       Evaluate    ${x}*${100}
    ${z}    Convert to Integer    ${z}
    Log to Console    ${z}
    ${y}    Convert to Integer    ${y}
    Should be Equal    ${z}    ${y}

    sleep    15s

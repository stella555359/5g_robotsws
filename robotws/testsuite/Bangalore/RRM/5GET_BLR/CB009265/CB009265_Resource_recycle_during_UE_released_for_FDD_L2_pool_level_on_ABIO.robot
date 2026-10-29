*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD

...             CRT    RAN_5G_FDD    RAN_5G    5G_RAN_FDD    5G_SC_FDD    5G_RAN     SBTS00    SBTS23R1    CONFIGURED

Resource         ./CB009265_Resource.robot

Suite Setup         Run keywords     Suite setup from scratch

...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
...                 AND     Perform SCF Delta Commissioning with Delta_requiredParamChange_1.json
...                 AND     Reboot gNB System Module from Console and check Airscale is ready
...                 AND     Check Cell On Air      ${wts_cfg_file}

Suite Teardown      Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}

Documentation
...
...             author:            Rahul Kumar Singh, rahul.kumar_singh@nokia.com
...             maintainer:        Rahul Kumar Singh, rahul.kumar_singh@nokia.com
...
...             INTRODUCTION:     Use case of the Test case is to verify the data Transfer rate with Max GFBR
...                               of 30mbps consistently for nonVonrGBR 5QI-4
...             TEST SET NAME:    CB009265-B_Verifying_Peak_Value_for_NIDD_Parameters_for_RRC_UEs_on_ABIO_for_FR1_FDD_
...                               pooling.
...                               Use case of the Test case is to This user scenario describes  verification for peak
...                               value assingment of  NIDD Parameters for RRC UEs on ABIO/ASOE/ABIN for a FR1-FDD
...                               pooling gNB configuration.
...             TESTING SPLIT:    See CB009265 testplan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB009265 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_5,5G_RAN_USR_RRM_14713,5G_RAN_USR_RRM_14714,5G_RAN_USR_RRM_1649,
...                               5G_RAN_USR_RRM_1227

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_1CC_max_gfbr_30_fdd_um_mode.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
${st_ue_id}      ${1}
${en_ue_id}      ${3}

# GFBR and MFBR profile <qos flow id>_gfbr_<dir>=speed
&{gfbr_mfbr_profile}                6_gfbr_ul=10   6_gfbr_dl=20    6_mfbr_ul=40     6_mfbr_dl=50

#Make sure VONR Traffic profile should in kbps for 5QI1 and 5QI 5 i.e QFI 2 and 3
@{QOS_Prof1}                1            6
@{QOS_Prof1_speed_ul}       2            30
@{QOS_Prof1_speed_dl}       2            30
@{QOS_Prof1_unit}           mbps         mbps

@{QOS_Prof2}               1         5            #5QI 3
@{QOS_Prof2_speed_dl}      10        30
@{QOS_Prof2_speed_ul}      10        30
@{QOS_Prof2_unit}          mbps     mbps

*** Test Cases ***


[1]CB009265-B_Verifying_Peak_Value_for_NIDD_Parameters_for_RRC_UEs_on_ABIO_for_FR1_FDD_pooling
    set test variable      ${LOG_PATH}
    Increase Buffer Size for VM and IPHY
    log to console   UE attach trigerring now...
    ${qos_profile}               Create Dictionary   ${1}=${QOS_Prof1}    ${2}=${QOS_Prof2}    ${3}=${QOS_Prof2}
    ${qos_profile_speed_ul}      Create Dictionary   ${1}=${QOS_Prof1_speed_ul}    ${2}=${QOS_Prof2_speed_ul}
    ...    ${3}=${QOS_Prof2_speed_ul}
    ${qos_profile_speed_dl}      Create Dictionary   ${1}=${QOS_Prof1_speed_dl}    ${2}=${QOS_Prof2_speed_dl}
    ...    ${3}=${QOS_Prof2_speed_dl}
    ${qos_profile_unit}          Create Dictionary   ${1}=${QOS_Prof1_unit}     ${2}=${QOS_Prof2_unit}
    ...     ${3}=${QOS_Prof2_unit}





#Step 1. Attach 1 UE with profile GFBR profile 30mbps with fiveQI3
    FOR    ${ue_id}    IN RANGE    ${st_ue_id}    ${en_ue_id}

   ${ue_to_bearer_list}=    Run Keyword If     ${ue_id}!=${3}    MultiUE Register should be Successful with Fetch Bearer ID
   ...     ${ue_id}    ${ue_id}    pdu_id=1    nw_id=1
   Run Keyword If     ${ue_id}!=${3}            Create Modify PDU session   ${ue_id}     ${ue_id}    ${qos_profile}   pdu_id=1
   ...      ue_to_bearer_list=${ue_to_bearer_list[1]}    gfbr_mfbr_profile=${gfbr_mfbr_profile}
   ${duration}      Set Variable    180
   ${trf_id}      Set Variable    ${1}
   Run Keyword If     ${ue_id}!=${3}     Start Data Transfer     ${ue_id}     ${ue_id}     ${duration}    ul   ${trf_id}
   ...    ${qos_profile_unit}  ${qos_profile_speed_ul}    ${qos_profile_speed_dl}    ${qos_profile}

   Run Keyword If     ${ue_id}==${3}
   ...    MultiUE Register Reject with RRC Reject was received   ${ue_id}     ${ue_id}
   END
   sleep   ${duration}s



   MultiUE Deregister should be Successful   ${st_ue_id}    ${2}



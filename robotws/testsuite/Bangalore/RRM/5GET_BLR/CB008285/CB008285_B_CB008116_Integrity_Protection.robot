*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    CONFIGURED   VARIANT_SA_FS_ECPRI_MMWV_TDD

Resource         CB008285_Resource.robot
Resource         ./basic_resource.robot
Resource         ../resources/robot/configuration_id.robot

Suite Setup        Run keywords     Log to console      "Suite Setup started"
...                 AND     Log to console     ${SCFC}
...                 AND     Prepare TL with config files
...                 AND     Suite setup from scratch
...                 AND     update_delta_and_create.update_cfg  ${CURDIR}/config/B_8116/basic_setup_2CC_tdd_ref.cfg      ${ue_profile}
...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file}


Suite Teardown      Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}
Test Teardown       Run Keywords
...                 Run Keyword if test failed     Stop CPRT capture  ${CaptureCPRT}
...                 AND    Log To Console       Test_Case_Tear_down

Documentation
...
...             author:            Mundanad Vishnu
...             maintainer:        mundanad.vishnu@nokia.com
...
...             INTRODUCTION:     CB008285 covers parity of CB008116 FR1 feature to FR2.
...                               This user scenario describes the behaviour of Nokia gNB in SA mode for the successful setup
...                               and operation of integrity protection(SNOW-3G) for user plane traffic up to maximum-UE-rate.

...             TEST SET NAME:    CB008285
...             TESTING SPLIT:    See CB008285 testplan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008285 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_20146





*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/B_8116/basic_32_8116.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
&{ciph}         nea0=1      nea1_128=2  nea2_128=3  nea3_128=4
&{intgr}        nia0=1      nia1_128=4  nia2_128=2  nia3_128=3
${ip_prof}      null
${ip_prof1}      zuc
${ip_prof2}      aes
${ip_prof3}      snow3g
&{ue_profile}    ${1}=${ip_prof3}

&{ip_ie}    ${1}=required
&{ip_result}      ${1}=performed
&{max_ip_rate}    ${1}=maximum-UE-rate
&{max_ip_rate_dl}    ${1}=maximum-UE-rate
${st_ue_id}      ${1}
${en_ue_id}      ${1}
# GFBR and MFBR profile <qos flow id>_gfbr_<dir>=speed
&{gfbr_mfbr_profile}                5_gfbr_ul=10   5_gfbr_dl=20    5_mfbr_ul=40     5_mfbr_dl=50

#Make sure VONR Traffic profile should in kbps for 5QI128 and 5QI 129 i.e QFI 2 and 3
@{QOS_Prof7}               1
@{QOS_Prof7_speed_ul}      5
@{QOS_Prof7_speed_dl}      5
@{QOS_Prof7_unit}          mbps

${SCFC}=                   ${CURDIR}/config/B_8116/SCF_Integrity_FR2.xml
${AP_XML}=                 ${CURDIR}/config/B_8116/Iphy_B_8116.xml


*** Test Cases ***
[1]USCB008285-B#B1#CB008116#TC5_US2_UPIP_traffic_anyDataRate_UPIPInd-Req-ZUC_maxUERate_5QI6-3_DLUL_TDD_LN
    ${ue_profile}       Create Dictionary   ${1}=${ip_prof3}
    Set Suite Variable    ${ip_ie}      &{ip_ie}
    Set Suite Variable    ${max_ip_rate}      &{max_ip_rate}
    Set Suite Variable    ${max_ip_rate_dl}      &{max_ip_rate_dl}
    Set Suite Variable    ${ip_result}      &{ip_result}
    Set Suite Variable    ${ue_profile}      &{ue_profile}

    Increase Buffer Size for VM and IPHY
    ${qos_profile}               Create Dictionary   ${1}=${QOS_Prof7}
    ${qos_profile_speed_ul}      Create Dictionary   ${1}=${QOS_Prof7_speed_ul}
    ${qos_profile_speed_dl}      Create Dictionary   ${1}=${QOS_Prof7_speed_dl}
    ${qos_profile_unit}          Create Dictionary   ${1}=${QOS_Prof7_unit}
    Run Keyword And Continue On Failure       Link SCOUT SCF to Configuration ID for Reporting
    ${ue_to_bearer_list}=  MultiUE Register should be Successful Custom      ${st_ue_id}    ${en_ue_id}   pdu_session_setup
    ... 	${ip_ie}      ${max_ip_rate}     pdu_id=1    nw_id=1

    Create Modify PDU session   ${st_ue_id}     ${en_ue_id}    ${qos_profile}   pdu_id=1    gfbr_mfbr_profile=${gfbr_mfbr_profile}
    ...    ue_to_bearer_list=${ue_to_bearer_list[1]}
    ${duration}      Set Variable    180
    ${trf_id}      Set Variable    ${1}
    Start Data Transfer     ${st_ue_id}     ${en_ue_id}     ${duration}    both   ${trf_id}   ${qos_profile_unit}  ${qos_profile_speed_ul}
    ...     ${qos_profile_speed_dl}    ${qos_profile}
    sleep   ${duration}s

   Check Integrity failure count
   ${nongbr_tp_read}=     Verify data transfer and get tp gbr_nongbr    ${st_ue_id}    ${en_ue_id}    ${duration}    both   ${trf_id}
    ...    ${qos_profile_unit}    ${qos_profile_speed_ul}     ${qos_profile_speed_dl}    ${qos_profile}

   MultiUE Deregister should be Successful      ${st_ue_id}    ${en_ue_id}











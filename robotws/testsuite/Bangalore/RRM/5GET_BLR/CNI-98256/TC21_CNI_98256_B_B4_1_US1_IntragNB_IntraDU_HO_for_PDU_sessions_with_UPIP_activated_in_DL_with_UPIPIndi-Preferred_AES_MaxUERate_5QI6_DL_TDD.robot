*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD
...             CRT    RAN_5G_FDD    RAN_5G    5G_RAN_FDD    5G_SC_FDD    5G_RAN     SBTS00    SBTS23R4    CONFIGURED

Resource         ./basic_resource.robot
Resource         ../resources/robot/PM_Counters.robot

Suite Setup         Run keywords     Suite setup from scratch
...                 AND     update_delta_and_create.update_and_gen    ${CURDIR}/config/SBTS23R4/basic_delta.json   ${intgr}    ${ciph}
...                 AND     Perform SCF Delta Commissioning with Delta_Configuration_scf_IntraDU_intrafreq.json
...                 AND     Reboot gNB System Module from Console and check Airscale is ready
...                 AND     update_delta_and_create.update_cfg  ${CURDIR}/config/wts/basic_setup_gen_HO.cfg     ${ue_profile}
...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
...                 AND    Configure UTE ETH3 IPs
...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file}
...                 AND     sleep      80

Suite Teardown      Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}

Documentation
...
...             author:            prerana.n_s@nokia.com
...             maintainer:        prerana.n_s@nokia.com
...
...             INTRODUCTION:     This user scenario describes the behaviour of Nokia gNB in SA mode during
...                               intra-gNB handover of a SA call with active UP IP in source cell and with
...                               Security Indication IE : UP Integrity Potection Indication as preferred.
...             TEST SET NAME:    CNI_98256_B_B4_1_US1_IntragNB_IntraDU_HO_for_PDU_sessions_with_UPIP_activated_in_DL_with
...                               _UPIPIndi-Preferred_AES_MaxUERate_5QI6_DL_TDD
...             TESTING SPLIT:    See CNI-98256 testplan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CNI-98256 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_20851,5G_PM_1207

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_gen.cfg
#${wts_cfg_file}     /opt/iphy/latest/basic_setup.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
# nea0 is NULL , nea1_128 is SNOW3G , nea2_128 is AES, nea3_128 is ZUC
&{ciph}         nea0=0      nea1_128=2  nea2_128=4  nea3_128=6
# nia0 is NULL , nia1_128 is SNOW3G , nia2_128 is AES, nia3_128 is ZUC
&{intgr}        nia0=0      nia1_128=2  nia2_128=4  nia3_128=6
${ip_prof}      zuc
${ip_prof1}      null
${ip_prof2}      aes
${ip_prof3}      snow3g
&{ue_profile}    ${1}=${ip_prof2}

&{ip_ie}    ${1}=preferred
&{max_ip_rate}    ${1}=bitrate64kbs

&{max_ip_rate_dl}    ${1}=bitrate64kbs

&{ip_result}      ${1}=performed

${st_ue_id}      ${1}
${en_ue_id}      ${1}
${SCFC}=            testsuite/Bangalore/RRM/5GET_BLR/CNI-98256/config/SCF/FDD_2cell_scf.xml
${AP_XML}=          testsuite/Bangalore/RRM/5GET_BLR/CNI-98256/config/SCF/FDD_2cell_iphy.xml
# GFBR and MFBR profile <qos flow id>_gfbr_<dir>=speed
&{gfbr_mfbr_profile}                5_gfbr_ul=10   5_gfbr_dl=20    5_mfbr_ul=40     5_mfbr_dl=50

#Make sure VONR Traffic profile should in kbps for 5QI128 and 5QI 129 i.e QFI 2 and 3

#@{QOS_Prof1}               1        2          3
#@{QOS_Prof1_speed_ul}      5       32         amr_wb_18_25
#@{QOS_Prof1_speed_dl}      5       32         amr_wb_18_25
#@{QOS_Prof1_unit}          kbps    kbps        rtp_codec

@{QOS_Prof1}               1
@{QOS_Prof1_speed_ul}      64
@{QOS_Prof1_speed_dl}      64
@{QOS_Prof1_unit}          kbps


*** Test Cases ***
[1]CNI_98256_B_B4_1_US1_IntragNB_IntraDU_HO_for_PDU_sessions_with_UPIP_activated_in_DL_with_UPIPIndi-Preferred_AES_MaxUERate_5QI6_DL_TDD
    Set Suite Variable    ${ip_ie}      &{ip_ie}
    Set Suite Variable    ${max_ip_rate}      &{max_ip_rate}
    Set Suite Variable    ${max_ip_rate_dl}      &{max_ip_rate_dl}
    Set Suite Variable    ${ip_result}      &{ip_result}
    Set Suite Variable    ${ue_profile}      &{ue_profile}
    Increase Buffer Size for VM and IPHY

    ${qos_profile}               Create Dictionary   ${1}=${QOS_Prof1}
    ${qos_profile_speed_ul}      Create Dictionary   ${1}=${QOS_Prof1_speed_ul}
    ${qos_profile_speed_dl}      Create Dictionary   ${1}=${QOS_Prof1_speed_dl}
    ${qos_profile_unit}          Create Dictionary   ${1}=${QOS_Prof1_unit}

    Wait until the next Measurement Period starts

    ${ue_to_bearer_list}=  MultiUE Register should be Successful Custom      ${st_ue_id}    ${en_ue_id}   pdu_session_setup
    ...  	${ip_ie}      ${max_ip_rate}     pdu_id=1    nw_id=1   only_ul=${1}

    Wait until the current Measurement Period stops

    Create Modify PDU session   ${st_ue_id}     ${en_ue_id}    ${qos_profile}   pdu_id=1    gfbr_mfbr_profile=${gfbr_mfbr_profile}
        ...    ue_to_bearer_list=${ue_to_bearer_list[1]}

    ${duration}      Set Variable    180
    ${trf_id}      Set Variable    ${1}
    Start Data Transfer     ${st_ue_id}     ${en_ue_id}     ${duration}    both   ${trf_id}   ${qos_profile_unit}  ${qos_profile_speed_ul}
    ...     ${qos_profile_speed_dl}    ${qos_profile}
    Trigger A3 RsrpAndRsrq Measurement for intragnb HO    ${st_ue_id}     1    53
    sleep   30s
    Start Log    biptaf
    sleep  2s
    ${scen1}     Stop Log     biptaf     test_scenario=call_bip
    sleep   150s

   Check Integrity failure count
    Collect PM Counter
#    Validate DL Traffic For MultiUE for SA    ${st_ue_id}    ${en_ue_id}     dl_rate=0.0185   pdu_id=2   qfi_id=3
#    Validate UL Traffic For MultiUE for SA    ${st_ue_id}    ${en_ue_id}     ul_rate=0.0185   pdu_id=2   qfi_id=3
  ${Counters}    Create Dictionary    ${PDU_SES_STP_ATT_UPIP_PREF}=${1}     ${PDU_SES_STP_SUC_UPIP_ACT_PREF}=${1}
  ...   ${PDU_SES_STP_SUC_UPIP_NACT_PREF}=${0}
  Verify Counters upip   ${Counters}

   ${nongbr_tp_read}=     Verify data transfer and get tp gbr_nongbr    ${st_ue_id}    ${en_ue_id}    ${duration}    both   ${trf_id}
    ...    ${qos_profile_unit}    ${qos_profile_speed_ul}     ${qos_profile_speed_dl}    ${qos_profile}

   MultiUE Deregister should be Successful      ${st_ue_id}    ${en_ue_id}
   [Teardown]    Link SCOUT SCF to Configuration ID for Reporting

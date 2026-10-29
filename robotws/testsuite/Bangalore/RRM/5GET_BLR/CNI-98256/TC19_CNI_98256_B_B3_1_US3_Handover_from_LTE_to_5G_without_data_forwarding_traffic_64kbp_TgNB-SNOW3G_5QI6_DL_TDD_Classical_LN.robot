*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_SC_TDD    5G_RAN     SBTS00    SBTS23R4    CONFIGURED

Resource         ./basic_resource.robot

Suite Setup         Run keywords     Suite setup from scratch
...                 AND     OperatingSystem.Run     sudo ip addr add 10.0.1.3/24 dev eth3
...                 AND     OperatingSystem.Run     sudo ip addr add 10.0.1.4/24 dev eth3
...                 AND     OperatingSystem.Run     sudo ip addr add 10.0.1.5/24 dev eth3
...                 AND     OperatingSystem.Run     sudo ip addr add 10.0.1.6/24 dev eth3
...                 AND     OperatingSystem.Run     sudo ip addr add 10.0.1.7/24 dev eth3
...                 AND     OperatingSystem.Run     sudo ip addr add 10.0.1.121/24 dev eth3
...                 AND     Modify IPHY File And Send to Airphone Custom    ${IPHY_FILE}
...                 AND     Find Scfc And Fix And Send Full Commissioning
...                         scfc_filename=lte_to_5g_ho.xml
#...                 AND     Reboot gNB System Module from Console and check Airscale is ready
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
...             INTRODUCTION:     This test case verifies the gNB behavior for an inter-RAT handover from LTE to 5G without data forwarding.
...             TEST SET NAME:    CNI_98256_B_B3_1_US3_Handover_from_LTE_to_5G_without_data_forwarding_traffic_64kbp_TgNB-SNOW3G_5QI6
...                               _DL_TDD_Classical_LN
...             TESTING SPLIT:    See CNI-98256 testplan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CNI-98256 CFAM
...             Requirement ID:   5G_CP_IF_NTW_2847

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts/lte_to_5g_ho.cfg
${IPHY_FILE}         ${CURDIR}/config/wts/iphy.xml
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
${SCFC}=            testsuite/Bangalore/RRM/5GET_BLR/CNI-98256/config/SCF/TDD_2cell_scf.xml
${AP_XML}=          testsuite/Bangalore/RRM/5GET_BLR/CNI-98256/config/SCF/TDD_2cell_iphy.xml
# GFBR and MFBR profile <qos flow id>_gfbr_<dir>=speed
&{gfbr_mfbr_profile}                5_gfbr_ul=10   5_gfbr_dl=20    5_mfbr_ul=40     5_mfbr_dl=50

@{QOS_Prof1}               1
@{QOS_Prof1_speed_ul}      6
@{QOS_Prof1_speed_dl}      6
@{QOS_Prof1_unit}          mbps


*** Test Cases ***
[1]CNI_98256_B_B3_1_US3_Handover_from_LTE_to_5G_without_data_forwarding_traffic_64kbp_TgNB-SNOW3G_5QI6_DL_TDD_Classical_LN
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
    sleep   10s
    Wait until the next Measurement Period starts
    ${ue_to_bearer_list}=  MultiUE Register should be Successful Custom      ${st_ue_id}    ${en_ue_id}   pdu_session_setup
    ...  	${ip_ie}      ${max_ip_rate}     pdu_id=1    nw_id=1

    Create Modify PDU session   ${st_ue_id}     ${en_ue_id}    ${qos_profile}   pdu_id=1    gfbr_mfbr_profile=${gfbr_mfbr_profile}
    ...    ue_to_bearer_list=${ue_to_bearer_list[1]}
    Wait until the current Measurement Period stops
    ${duration}      Set Variable    180
    ${trf_id}      Set Variable    ${1}

    Start Data Transfer     ${st_ue_id}     ${en_ue_id}     ${duration}    both   ${trf_id}   ${qos_profile_unit}  ${qos_profile_speed_ul}
    ...     ${qos_profile_speed_dl}    ${qos_profile}

#    Validate DL Traffic For MultiUE for SA    ${st_ue_id}    ${en_ue_id}     dl_rate=6   pdu_id=1   qfi_id=1
#    Validate UL Traffic For MultiUE for SA    ${st_ue_id}    ${en_ue_id}     ul_rate=6   pdu_id=1   qfi_id=1
    trigger handover to LTE
    sleep  20s
    trigger handover to 5G
    sleep   60s
        Collect PM Counter
      ${Counters}    Create Dictionary    ${PDU_SES_STP_ATT_UPIP_PREF}=${1}     ${PDU_SES_STP_SUC_UPIP_ACT_PREF}=${1}
    ...    ${PDU_SES_STP_SUC_UPIP_NACT_PREF}=${0}
    Verify Counters upip   ${Counters}


    Check Integrity failure count

#    Validate DL Traffic For MultiUE for SA    ${st_ue_id}    ${en_ue_id}     dl_rate=6   pdu_id=1   qfi_id=1
#    Validate UL Traffic For MultiUE for SA    ${st_ue_id}    ${en_ue_id}     ul_rate=6   pdu_id=1   qfi_id=1

    MultiUE Deregister should be Successful      ${st_ue_id}    ${en_ue_id}
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting

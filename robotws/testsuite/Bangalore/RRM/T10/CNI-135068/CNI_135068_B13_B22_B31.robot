*** Settings ***
Force Tags      CLOUD_5G_O_E_AP_LOOO
...             CRT    RAN_5G_FDD    RAN_5G    5G_RAN_FDD     5G_RAN     SBTS00    SBTS23R3    CONFIGURED

Resource         ./CNI_135068_Resource.robot

Suite Setup         Run keywords    Suite setup from scratch
...                 AND     Update bsr package
...                 AND     OperatingSystem.Run     sudo ip addr add 10.0.1.3/24 dev eth3
...                 AND     OperatingSystem.Run     sudo ip addr add 10.0.1.4/24 dev eth3
...                 AND     OperatingSystem.Run     sudo ip addr add 10.0.1.112/24 dev eth3
...                 AND     OperatingSystem.Run     sudo ip addr add 10.0.1.102/24 dev eth3
...                 AND     OperatingSystem.Run     sudo ip addr add 10.0.1.101/24 dev eth3
...                 AND     Perform SCF Delta Commissioning with Delta_config_135068_B1.json
...                 AND     Perform SCF Delta Commissioning with ETH_DEL.json
...                 AND     Add RD Parameters To GNB Swconfig File    ${radparam}
...                 AND     Reboot gNB System Module from Console and check Airscale is ready
#...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}/Suite_Setup_Logs
...                 AND     Load CFG and verify cell status with CPRT    ${wts_cfg_file}	 ${start_cell}	 ${end_cell}

Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
...                 AND     Copy WTS Log Files
#...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}/Suite_Setup_Logs
...                 AND     Stop Log   sosreport
...                 AND     Clean edaemon and egate

Test Teardown       Run keywords
...                 Run Keyword and Ignore Error    Link SCOUT SCF to Configuration ID for Reporting
...                 AND      Run Keyword and Ignore Error     MultiUE Deregister should be Successful    ${st_sa_id}     ${en_sa_id}

Documentation
...
...             author:           Rahul Singh
...             maintainer:       Rahul Singh
...             INTRODUCTION:     This testcases is verifying and validating the functionalities of
...                               1. UE enters Rankdowngrade mode when it is cell edge condition
...                               2. applying Additional Delta CQI on target cell during Handin
...                               3. lowered BLER target in low spectral efficiency (SE) region when CNI-135068 is activated
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CNI 135068 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_29935,5G_RAN_ARC_11393,5G_RAN_ARC_11401,5G_RAN_ARC_11402,
...                               5G_RAN_USR_RRM_29959,5G_RAN_USR_RRM_29958

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_OE_LOO_HO.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}              Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}     /tmp/

${st_sa_id}             ${3}
${en_sa_id}             ${4}

${nwslice_ID}           ${1}
${Pdu_session_ID}       ${1}
${eNB_ID}               ${1}
${eNB_target}           ${2}
${start_cell}           4
${end_cell}             6
${TEST_NAME}            All_in_one_SCF
${radparam}             SEPARATOR=${EMPTY}    0x890073=0;0x58057a=4;0x58057c=1024

${target_bler1}         100,90,80,70,60,50,40,20,10,8,5,0.5,0,0,0
${target_bler2}         100,90,80,70,60,50,40,20,10,8,5,0.5,0,0,0
${target_bler3}         100,90,80,60,40,20,15,13,10,8,5,0.5,0,0,0
${target_bler4}         100,90,80,60,40,20,15,13,10,8,5,0.5,0,0,0

${target_bler5}         100,90,80,60,40,20,15,13,10,8,5,0.5,0,0,0
${target_bler6}         100,90,80,60,40,20,15,10,5,2,1,0.5,0,0,0
${target_bler7}         100,90,80,60,40,20,15,10,5,2,1,0.5,0,0,0

@{target_bler_d}        ${target_bler1}  ${target_bler2}    ${target_bler3}  ${target_bler4}
@{target_mcs_d}         8   4   2   1
@{report_cqi_d}         8   7   6   4

@{target_bler_i}        ${target_bler5}  ${target_bler6}    ${target_bler7}
@{target_mcs_i}         7   14   22
@{report_cqi_i}         7   11   14

@{cell_id_b13}          53
@{cell_id_b22}          53    54
@{cell_id_b31}          53

*** Test Cases ***
[1][1.0] CNI_135068_B13_Forced_rank_downgrade_upon_feature_activation_and_deactivation_BW_10
    [Tags]    B13
    [Documentation]
    ...    This user scenario describes the forced rank downgrade at low CQI for FR1 FDD cell when feature is activated.
    ...    feature is enabled.VoNR DRB + non-GBR DRB are configured for UE-1 and only non-GBR DRB for UE-2.Both UEs are
    ...    in good radio condition so that high rank can be achieved.Downlink signal is tuned by adding attenuation
    ...    slower so that the condition for triggering rank downgrade state is met and rank downgrade
    ...    is triggered for UE-2,rank downgrade is performed(rank2->rank1, rank3->rank2, rank4->rank2)
    ...    Requirement ID: 5G_RAN_USR_RRM_29935,5G_RAN_ARC_11393,5G_RAN_ARC_11401,5G_RAN_ARC_11402

    Increase Buffer Size for VM and IPHY
    ${crnti_list_sa}     ${ue_to_bearer_list_sa}     MultiUE Register should be Successful with Fetch Bearer ID
    ...     ${st_sa_id}   ${en_sa_id}    pdu_id=${Pdu_session_ID}    nw_id=${nwslice_ID}

    Add 5QI for VoNR and VINR    ${st_sa_id}   ${st_sa_id}    ${ue_to_bearer_list_sa}   isVoNR=True
    Add 5QI for VoNR and VINR    ${en_sa_id}   ${en_sa_id}    ${ue_to_bearer_list_sa}
    ${crnti_to_bearer_list_sa}    map bearer list to crnti   ${crnti_list_sa}     ${ue_to_bearer_list_sa}
    log to console     crnti_to_bearer_list_sa-${crnti_to_bearer_list_sa}
    MultiUE Trigger DL Traffic for SA        ${en_sa_id}   ${en_sa_id}    mbps    20   pdu_id=${Pdu_session_ID}
    ...     trf_id=1    qfi_id=1
    Trigger MultiUE VoNR and VINR DL Traffic for SA      ${st_sa_id}    ${st_sa_id}    isVoNR=True
    Trigger MultiUE VoNR and VINR DL Traffic for SA      ${en_sa_id}    ${en_sa_id}
    sleep    5m
    ${tobad}     TM_Profile_creation_for_varying_channel_condition   ${target_bler_d}    ${target_mcs_d}
    ...    ${report_cqi_d}
    ${togood}    TM_Profile_creation_for_varying_channel_condition   ${target_bler_i}    ${target_mcs_i}
    ...    ${report_cqi_i}    profile_id=${tobad}
    sleep   60s

    Start log   btslog    ttitrace    cell_id=@{cell_id_b13}

    TM Profile activation for varying channel condition    ${st_sa_id}-${en_sa_id}    ${target_mcs_d}
    ...     pausetime=3s
    TM Profile activation for varying channel condition    ${st_sa_id}-${en_sa_id}    ${target_mcs_i}
    ...     profile_id=${tobad}    pausetime=3s
    TM Profile deactivation for varying channel condition   ${st_sa_id}-${en_sa_id}    ${togood}
    ${path_SCN_1}   Stop log    ttitrace   btslog    snapshot_ims2    test_scenario=good_bad_good
#    MultiUE Deregister should be Successful    ${st_sa_id}     ${en_sa_id}
    Common TTI PCAP to CSV Converter    good_bad_good   dir=dl
    Verify Rank Downgrade Entry Exit    ${path_SCN1}[ttitrace]/output_dl_formated.csv    ${crnti_to_bearer_list_sa}

[1][1.0] CNI_135068_B22_Additional_delta_CQI_offset_during_Handin_intra_freq_intra_gnb
    [Tags]    B22
    [Documentation]
    ...    This user scenario describes the additional delta CQI offset applied in DL LA upon Handin on target cell
    ...    when CNI-135068 is activated. This additional delta CQI offset will be applicable for only Non-GBR BR DRB
    ...    Requirement ID: 5G_RAN_USR_RRM_29959

    Increase Buffer Size for VM and IPHY
    Perform SCF Delta Commissioning with Delta_config_135068_B2.json
    sleep   10s
    ${crnti_list_sa}     ${ue_to_bearer_list_sa}     MultiUE Register should be Successful with Fetch Bearer ID
    ...     ${st_sa_id}   ${en_sa_id}    pdu_id=${Pdu_session_ID}    nw_id=${nwslice_ID}

    Add 5QI for VoNR and VINR    ${st_sa_id}   ${st_sa_id}    ${ue_to_bearer_list_sa}   isVoNR=True   isViNR=False
    Add 5QI for VoNR and VINR    ${en_sa_id}   ${en_sa_id}    ${ue_to_bearer_list_sa}

    ${crnti_to_bearer_list_sa}    map bearer list to crnti   ${crnti_list_sa}     ${ue_to_bearer_list_sa}
    log to console     crnti_to_bearer_list_sa-${crnti_to_bearer_list_sa}

    MultiUE Trigger DL Traffic for SA        ${st_sa_id}   ${en_sa_id}    mbps    10   pdu_id=${Pdu_session_ID}
    ...     trf_id=1    qfi_id=1
    Trigger MultiUE VoNR and VINR DL Traffic for SA      ${st_sa_id}    ${st_sa_id}
    ...    isVoNR=True    isViNR=False   #dl_rate_5qi2=1
    Trigger MultiUE VoNR and VINR DL Traffic for SA      ${en_sa_id}    ${en_sa_id}
    sleep   10m
    Start log   ttitrace    cell_id=@{cell_id_b22}
    ${crnti_list_after_ho}	 ${crnt_to_bearer_list_after_ho}   Trigger IntraFreq Intragnb A3 based HO
    ...    ${st_sa_id}   ${en_sa_id}    ${ue_to_bearer_list_sa}
    ...    source_lcr=4    target_lcr=5    targetcell=54
    ${path_SCN_2}   Stop log    ttitrace    test_scenario=after_intraFreq_HO
    sleep    10m
#    MultiUE Deregister should be Successful    ${st_sa_id}     ${en_sa_id}
    Common TTI PCAP to CSV Converter    after_intraFreq_HO   dir=dl
    Verification of rrmDeltaCqi Handin    ${path_SCN2}[ttitrace]/output_dl_formated.csv
    ...    ${crnt_to_bearer_list_after_ho}    ${54}   ${3}

[1][1.0] CNI_135068_B31_Lowered_BLER_target_in_low_spectral_efficiency_region
    [Tags]    B31
    [Documentation]
    ...    This user scenario describes lowered BLER target in low spectral efficiency (SE) region when CNI-135068 is activated.
    ...    In areas with low spectral efficiency, a specific BLER target is adopted. This approach reduces the BLER
    ...    target in these low-SE zones, allowing for more lenient performance requirements and better adaptation to BLER.
    ...    Requirement ID: 5G_RAN_USR_RRM_29958

    Increase Buffer Size for VM and IPHY
    Perform SCF Delta Commissioning with Delta_config_135068_B3.json
    sleep   10s
    ${crnti_list_sa}     ${ue_to_bearer_list_sa}     MultiUE Register should be Successful with Fetch Bearer ID
    ...     ${st_sa_id}   ${st_sa_id}    pdu_id=${Pdu_session_ID}    nw_id=${nwslice_ID}
    Add 5QI for VoNR and VINR    ${st_sa_id}   ${st_sa_id}    ${ue_to_bearer_list_sa}
    ${crnti_to_bearer_list_sa}    map bearer list to crnti   ${crnti_list_sa}     ${ue_to_bearer_list_sa}
    log to console     crnti_to_bearer_list_sa-${crnti_to_bearer_list_sa}
    MultiUE Trigger DL Traffic for SA        ${st_sa_id}   ${st_sa_id}    mbps   10   pdu_id=${Pdu_session_ID}
    ...     trf_id=1    qfi_id=1
    sleep    10m
    ${tobad}     TM_Profile_creation_for_varying_channel_condition   ${target_bler_d}    ${target_mcs_d}
    ...    ${report_cqi_d}
    ${togood}    TM_Profile_creation_for_varying_channel_condition   ${target_bler_i}    ${target_mcs_i}
    ...    ${report_cqi_i}    profile_id=${tobad}
    sleep   60s
    Start log   btslog    ttitrace    cell_id=@{cell_id_b31}
    TM Profile activation for varying channel condition    ${st_sa_id}-${st_sa_id}    ${target_mcs_d}
    ...     pausetime=3s
    TM Profile activation for varying channel condition    ${st_sa_id}-${st_sa_id}    ${target_mcs_i}
    ...     profile_id=${tobad}    pausetime=3s
    TM Profile deactivation for varying channel condition   ${st_sa_id}-${st_sa_id}    ${togood}
    ${path_SCN_3}   Stop log    ttitrace   btslog    snapshot_ims2    test_scenario=good_bad_good
#    MultiUE Deregister should be Successful    ${st_sa_id}     ${st_sa_id}
    Common TTI PCAP to CSV Converter    good_bad_good   dir=dl
    Verify low SE    ${path_SCN3}[ttitrace]/output_dl_formated.csv  ${crnti_to_bearer_list_sa}    ${7}   ${51}

*** Keywords ***
Update bsr package
    Run     mkdir ${CURDIR}/BSR
    ${dllink}   Set Variable     https://artifactory-espoo1.ext.net.nokia.com:443/artifactory/mnpute-rotta-local/BSR
    ${filename}    Set variable     BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001_CB010471.zip
    Run     sudo wget ${dllink}/${filename} --user=dheerajn --password=AP33ZXKC1P9cgTCGJmyvY3bv5NA -P ${CURDIR}/BSR
    coam.setup admin    bts_host=192.168.255.129
    ${ret}     coam.Update Software      ${CURDIR}/BSR/${filename}
    coam.teardown admin


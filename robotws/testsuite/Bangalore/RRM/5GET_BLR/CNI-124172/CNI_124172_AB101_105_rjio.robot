*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO
...             CRT    RAN_5G_FDD    RAN_5G    5G_RAN_FDD     5G_RAN     SBTS00    SBTS23R3    CONFIGURED

Resource         ./CNI_124172_Resource.robot

Suite Setup         Run keywords    Suite setup from scratch
...                 AND     Update bsr package
...                 AND     OperatingSystem.Run     sudo ip addr add 10.0.1.3/24 dev eth3
...                 AND     OperatingSystem.Run     sudo ip addr add 10.0.1.4/24 dev eth3
...                 AND     Add RD Parameters To GNB Swconfig File    ${radparam}
##...                 AND     Perform SCF Delta Commissioning with Delta_Configuration_scf_IntraDU_intrafreq.json
...                 AND     Perform SCF Delta Commissioning with Delta_Configuration_scf_IntraDU_intrafreq_rjio_2.json
...                 AND     sleep   30s
...                 AND     Perform SCF Delta Commissioning with Delta_Configuration_scf_IntraDU_intrafreq_rjio_4.json
...                 AND     Reboot gNB System Module from Console and check Airscale is ready
...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}/Suite_Setup_Logs
...                 AND     Load CFG and verify cell status    ${wts_cfg_file}	 ${start_cell}	 ${end_cell}

Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}/Suite_Setup_Logs
...                 AND     Copy WTS Log Files
...                 AND     Stop Log   snapshot     sosreport
...                 AND     Clean edaemon and egate

Test Teardown       Link SCOUT SCF to Configuration ID for Reporting

Documentation
...
...             author:           Samik Sarkar
...             maintainer:       Samik Sarkar
...             TC Name:          CNI_124172_AB101_intra_freq_A3_A5_trigger_during_inter_gnb_HO_via_Xn_in_post_HO_phase_
...                               leading_to_intra_gnb_intra_DU_HO
...             INTRODUCTION:     This testcase is verifying and validating the new concurrency handling of Intra Freq_A3/A5
...                               triggered during intr-gnb intra-du HO in post HO phase leading to inter-gnb XnHO
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CNI 124172 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_5, 5G_RAN_USR_RRM_27394, 5G_RAN_USR_RRM_27395, CNI_FIM_1357, CNI_FIM_1360

...             TC Name:          CNI_124172_AB105_intra_freq_A3_A5_trigger_during_Intra_gnb_HO_leading_to_inter_gnb_Xn_HO
...             INTRODUCTION:     This testcase is verifying and validating the new concurrency handling of Intra Freq_A3/A5
...                               triggered during intr-gnb intra-du HO in post HO phase leading to inter-gnb XnHO
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CNI 124172 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_5, 5G_RAN_USR_RRM_27394, 5G_RAN_USR_RRM_27395, CNI_FIM_1357, CNI_FIM_1360

*** Variables ***
#${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup.cfg
#${wts_cfg_file}     ${CURDIR}/config/wts/modified.cfg
${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_rjio.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
${st_ue_id_a3}          ${1}
${en_ue_id_a3}          ${2}
${st_ue_id_a5}          ${71}
${en_ue_id_a5}          ${71}
${nwslice_ID}           ${1}
${Pdu_session_ID}       ${1}
${eNB_ID}               ${1}
${eNB_target}           ${2}
${start_cell}           1
${end_cell}             4
${TEST_NAME}            AB101_105
${radparam}             SEPARATOR=${EMPTY}    0x890073 = 0

*** Test Cases ***
[1][1.0] CNI_124172_AB105_intra_freq_A3_A5_trigger_during_Intra_gnb_HO_leading_to_inter_gnb_Xn_HO
    [tags]    AB105
    Increase Buffer Size for VM and IPHY
#    NSA X2AP Link Should be UP     ${eNB_ID}		${eNB_target}
    Setup Simulator GNB
    ${crnti_list}   MultiUE Register should be Successful    ${st_ue_id_a3}   ${en_ue_id_a3}    pdu_id=${Pdu_session_ID}     nw_id=${nwslice_ID}
    MultiUE Trigger DL Traffic for SA        ${st_ue_id_a3}    ${en_ue_id_a3}    mbps    20   pdu_id=${Pdu_session_ID}
    ...     trf_id=1    qfi_id=1
    MultiUE Trigger UL Traffic for SA         ${st_ue_id_a3}    ${en_ue_id_a3}    mbps    20   pdu_id=${Pdu_session_ID}
    ...     trf_id=1    qfi_id=1
    sleep   5s
    Validate DL Traffic For MultiUE SA   ${st_ue_id_a3}    ${en_ue_id_a3}    20   pdu_id=${Pdu_session_ID}     qfi_id=1
    Validate UL Traffic For MultiUE SA   ${st_ue_id_a3}    ${en_ue_id_a3}    20   pdu_id=${Pdu_session_ID}     qfi_id=1


    Intrafreq A3A5 trigger during intra-du intra-gnb HO in post HO phase leading to XnHO Real to SIM gNB
    ...      ${st_ue_id_a3}    ${en_ue_id_a3}    action=drop_and_send_measurement_report
    ...      tgt_cell_ssb=634080    source_real_lcr=1   first_target_real_lcr=2    sec_target_sim_lcr=2
    sleep   5s
    Validate DL Traffic For MultiUE SA   ${st_ue_id_a3}    ${en_ue_id_a3}    20   pdu_id=${Pdu_session_ID}     qfi_id=1
    Validate UL Traffic For MultiUE SA   ${st_ue_id_a3}    ${en_ue_id_a3}    20   pdu_id=${Pdu_session_ID}     qfi_id=1

    MultiUE Deregister should be Successful    ${st_ue_id_a3}    ${en_ue_id_a3}

    #update measurement type from A3 to A5
    ${chg_a3_a5}    Set Variable
    ...    gnb_param id=3 xn_listening_socket=on send_xn_setup=on measEvent=A5 sa_ho=xn_based sib1_period=40 sib2_period=40 sib5_period=40
    ute_wtssim.Execute Egate Command        ${chg_a3_a5}
    sleep   5s

    ${crnti_list}   MultiUE Register should be Successful    ${st_ue_id_a5}   ${en_ue_id_a5}    pdu_id=${Pdu_session_ID}     nw_id=${nwslice_ID}

    MultiUE Trigger DL Traffic for SA      ${st_ue_id_a5}    ${en_ue_id_a5}    mbps    20   pdu_id=${Pdu_session_ID}
    ...     trf_id=1    qfi_id=1
    MultiUE Trigger UL Traffic for SA      ${st_ue_id_a5}    ${en_ue_id_a5}    mbps    20   pdu_id=${Pdu_session_ID}
    ...     trf_id=1    qfi_id=1
    sleep   5s
    Validate DL Traffic For MultiUE SA   ${st_ue_id_a5}    ${en_ue_id_a5}    20   pdu_id=${Pdu_session_ID}     qfi_id=1
    Validate UL Traffic For MultiUE SA   ${st_ue_id_a5}    ${en_ue_id_a5}    20   pdu_id=${Pdu_session_ID}     qfi_id=1

    Intrafreq A3A5 trigger during intra-du intra-gnb HO in post HO phase leading to XnHO Real to SIM gNB
    ...      ${st_ue_id_a5}    ${en_ue_id_a5}    meas_event=A5   source_cell=53    first_target=54    sec_target=60
    ...      action=drop_and_send_measurement_report    tgt_cell_ssb=156510      source_real_lcr=4   first_target_real_lcr=5
    ...      sec_target_sim_lcr=4

    sleep   5s
    Validate DL Traffic For MultiUE SA   ${st_ue_id_a5}    ${en_ue_id_a5}    20   pdu_id=${Pdu_session_ID}     qfi_id=1
    Validate UL Traffic For MultiUE SA   ${st_ue_id_a5}    ${en_ue_id_a5}    20   pdu_id=${Pdu_session_ID}     qfi_id=1

    MultiUE Deregister should be Successful    ${st_ue_id_a5}    ${en_ue_id_a5}

    #update measurement type from A5 to A3
    ${chg_a5_a3}    Set Variable
    ...    gnb_param id=3 xn_listening_socket=on send_xn_setup=on measEvent=A3 sa_ho=xn_based sib1_period=40 sib2_period=40 sib5_period=40
    ute_wtssim.Execute Egate Command        ${chg_a5_a3}
    sleep   5s

    #Handover Failure Scenario
    Perform SCF Delta Commissioning with Delta_Config_HO_Fail_Preparation.json
    sleep   5s
    UE Change Location    ${st_ue_id_a3}   ${en_ue_id_a3}

    ${crnti_list}   MultiUE Register should be Successful    ${st_ue_id_a3}   ${en_ue_id_a3}    pdu_id=${Pdu_session_ID}     nw_id=${nwslice_ID}
    MultiUE Trigger DL Traffic for SA     ${st_ue_id_a3}    ${en_ue_id_a3}    mbps    20   pdu_id=${Pdu_session_ID}
    ...     trf_id=1    qfi_id=1
    MultiUE Trigger UL Traffic for SA     ${st_ue_id_a3}    ${en_ue_id_a3}    mbps    20   pdu_id=${Pdu_session_ID}
    ...     trf_id=1    qfi_id=1

    ${crnti_list}   MultiUE Register should be Successful    111   111    pdu_id=${Pdu_session_ID}     nw_id=${nwslice_ID}
    MultiUE Trigger DL Traffic for SA     111    111    mbps    20   pdu_id=${Pdu_session_ID}
    ...     trf_id=1    qfi_id=1
    MultiUE Trigger UL Traffic for SA     111    111    mbps    20   pdu_id=${Pdu_session_ID}
    ...     trf_id=1    qfi_id=1

    ${log_path}     Handover failure During Preparation phase of intra-du intra gnb resulted in post inter freq intra-du HO
    ...     ${st_ue_id_a3}   ${en_ue_id_a3}     source_cell=50   first_target=54    sec_target=56    action=drop_and_send_measurement_report
    ...     tgt_cell_ssb=156510    source_real_lcr=1   first_target_real_lcr=5    sec_target_sim_lcr=6

    log to console      ${log_path}
    MultiUE Deregister should be Successful    ${st_ue_id_a3}    ${en_ue_id_a3}
    MultiUE Deregister should be Successful    111    111
    Perform SCF Delta Commissioning with Delta_Config_maxNumOfRrcSA_275.json

[1][1.0] CNI_124172_AB101_intra_freq_A3_A5_trigger_during_inter_gnb_HO_via_Xn_in_post_HO_phase_leading_to_intra_gnb_intra_DU_HO

    Increase Buffer Size for VM and IPHY
#    NSA X2AP Link Should be UP     ${eNB_ID}		${eNB_target}
    Location Update to Sim GNB    ${st_ue_id_a3}   ${en_ue_id_a3}
    ${crnti_list}   MultiUE Register should be Successful    ${st_ue_id_a3}   ${en_ue_id_a3}    pdu_id=${Pdu_session_ID}     nw_id=${nwslice_ID}
    MultiUE Trigger DL Traffic for SA        ${st_ue_id_a3}    ${en_ue_id_a3}    mbps    20   pdu_id=${Pdu_session_ID}
    ...     trf_id=1    qfi_id=1
    MultiUE Trigger UL Traffic for SA         ${st_ue_id_a3}    ${en_ue_id_a3}    mbps    2   pdu_id=${Pdu_session_ID}
    ...     trf_id=1    qfi_id=1
    sleep   5s
    Run keyword and ignore error
    ...    Validate DL Traffic For MultiUE SA   ${st_ue_id_a3}    ${en_ue_id_a3}    20   pdu_id=${Pdu_session_ID}     qfi_id=1
    Run keyword and ignore error
    ...    Validate UL Traffic For MultiUE SA   ${st_ue_id_a3}    ${en_ue_id_a3}    2    pdu_id=${Pdu_session_ID}     qfi_id=1

    Intrafreq A3A5 trigger during XnHO in post HO phase leading to intra-gnb intra-DU HO SIM to Real gNB
    ...      ${st_ue_id_a3}    ${en_ue_id_a3}    action=drop_and_send_measurement_report
    ...      tgt_cell_ssb=634080    source_sim_lcr=1   first_target_real_lcr=1    sec_target_real_lcr=2
    sleep   5s

    Run keyword and ignore error
    ...    Validate DL Traffic For MultiUE SA   ${st_ue_id_a3}    ${en_ue_id_a3}    20   pdu_id=${Pdu_session_ID}     qfi_id=1
    Run keyword and ignore error
    ...     Validate UL Traffic For MultiUE SA   ${st_ue_id_a3}    ${en_ue_id_a3}    2    pdu_id=${Pdu_session_ID}     qfi_id=1

    MultiUE Deregister should be Successful    ${st_ue_id_a3}    ${en_ue_id_a3}

    #update measurement type from A3 to A5
    ${chg_a3_a5}    Set Variable
    ...    gnb_param id=3 xn_listening_socket=on send_xn_setup=on measEvent=A5 sa_ho=xn_based sib1_period=40 sib2_period=40 sib5_period=40
    ute_wtssim.Execute Egate Command        ${chg_a3_a5}

    Location Update to Sim GNB    ${st_ue_id_a5}   ${en_ue_id_a5}    cell=3
    ${crnti_list}   MultiUE Register should be Successful    ${st_ue_id_a5}   ${en_ue_id_a5}    pdu_id=${Pdu_session_ID}     nw_id=${nwslice_ID}
    MultiUE Trigger DL Traffic for SA        ${st_ue_id_a5}    ${en_ue_id_a5}    mbps    20   pdu_id=${Pdu_session_ID}
    ...     trf_id=1    qfi_id=1
    MultiUE Trigger UL Traffic for SA         ${st_ue_id_a5}    ${en_ue_id_a5}    mbps    2   pdu_id=${Pdu_session_ID}
    ...     trf_id=1    qfi_id=1
    sleep   5s

    Run keyword and ignore error
    ...     Validate DL Traffic For MultiUE SA   ${st_ue_id_a5}    ${en_ue_id_a5}    20   pdu_id=${Pdu_session_ID}     qfi_id=1
    Run keyword and ignore error
    ...     Validate UL Traffic For MultiUE SA   ${st_ue_id_a5}    ${en_ue_id_a5}    2    pdu_id=${Pdu_session_ID}     qfi_id=1

    Intrafreq A3A5 trigger during XnHO in post HO phase leading to intra-gnb intra-DU HO SIM to Real gNB
    ...      ${st_ue_id_a5}    ${en_ue_id_a5}    meas_event=A5   source_cell=59    first_target=53    sec_target=55
    ...      action=drop_and_send_measurement_report    tgt_cell_ssb=156510      source_sim_lcr=3   first_target_real_lcr=4
    ...      sec_target_real_lcr=6
    sleep   5s

    Run keyword and ignore error
    ...     Validate DL Traffic For MultiUE SA   ${st_ue_id_a5}    ${en_ue_id_a5}    20   pdu_id=${Pdu_session_ID}     qfi_id=1
    Run keyword and ignore error
    ...     Validate UL Traffic For MultiUE SA   ${st_ue_id_a5}    ${en_ue_id_a5}    2    pdu_id=${Pdu_session_ID}     qfi_id=1

    MultiUE Deregister should be Successful    ${st_ue_id_a5}    ${en_ue_id_a5}


*** Keywords ***
Update bsr package
    Run     mkdir ${CURDIR}/BSR
    ${dllink}   Set Variable     https://artifactory-espoo1.ext.net.nokia.com:443/artifactory/mnpute-rotta-local/BSR
    ${filename}    Set variable     BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001_CB010471.zip
    Run     sudo wget ${dllink}/${filename} --user=dheerajn --password=AP33ZXKC1P9cgTCGJmyvY3bv5NA -P ${CURDIR}/BSR
    admin.setup admin
    ${ret}     admin.Update Software      ${CURDIR}/BSR/${filename}
    admin.teardown admin
